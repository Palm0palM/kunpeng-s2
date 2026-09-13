"""Accept returned G-round text only; never compile or execute operator code.

Usage: python3 .runs/conv/sep12g-checks/accept_returned.py VERSION
Required input: job.json, source-manifest.json, raw/*, assembly-review.json.
Writes validation.json only after every gate passes. A failed acceptance gets
a separate timestamped report; original evidence and prepared state remain.
"""
import collections
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import shlex
import sys

PLANS = {
    'C40-row6x3u1': dict(full=3560, dispatch=432, direct=360, total=26112,
        rows=6, vectors=3, helper='rowsix', dispatch_entries=432, direct_entries=900,
        matrix=(2808,144,576,32), direct_kh_max=5),
    'C41-row5x5u1': dict(full=3776, dispatch=504, direct=288, total=27408,
        rows=5, vectors=5, helper='rowquint', dispatch_entries=528, direct_entries=720,
        matrix=(3168,144,432,32), direct_kh_max=4),
    'C42-row5x5asm': dict(full=3776, dispatch=504, direct=288, total=27408,
        rows=5, vectors=5, helper='rowquint', dispatch_entries=528, direct_entries=720,
        matrix=(3168,144,432,32), direct_kh_max=4),
}

def require(value, message):
    if not value:
        raise ValueError(message)

def one_match(pattern, text, message):
    matches = re.findall(pattern, text, re.M)
    require(len(matches) == 1, message)
    return matches[0]

def validate(base, version):
    p = PLANS[version]
    raw = base / 'raw'
    job = json.loads((base / 'job.json').read_text())
    require(job['version'] == version, 'Job candidate mismatch')
    scheduler = job['scheduler_status']
    require(scheduler['jobId'] == job['job_id'], 'Scheduler ID mismatch')
    require(scheduler['status'] == 'SUCCEEDED', 'Scheduler has not succeeded')
    require(scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0, 'Scheduler exit failure')
    expected_checks = dict(full_per_configuration=p['full'], dispatch_per_configuration=p['dispatch'],
        direct_per_configuration=p['direct'], configurations=6, total=p['total'])
    require(job['expected_checks'] == expected_checks, 'Job plan mismatch')
    require((raw / 'exit-code.txt').read_text().strip() == '0', 'Wrapper exit failure')
    require((raw / 'compiler-version.txt').read_text().strip() == '10.3.1', 'Compiler version mismatch')
    probe = (raw / 'probe.log').read_text()
    one_match(r'^PROBE_COMPLETE=1$', probe, 'Probe incomplete')
    one_match(r'^EXPECTED_TOTAL_CHECKS=' + str(p['total']) + '$', probe, 'Final count marker mismatch')
    require('SANITIZER_STATUS=NOT_RUN' in probe, 'Sanitizer scope missing')
    cpus = one_match(r'^ALLOWED_CPUS=([0-9,]+)$', probe, 'Missing allocation evidence')
    cpu_ids = [int(x) for x in cpus.split(',')]
    require(len(cpu_ids) == len(set(cpu_ids)) == 38, 'Expected exactly 38 allocated CPUs')
    numa = one_match(r'^NUMA_NODE=(node[0-9]+)$', probe, 'Missing unique NUMA result')

    manifest = json.loads((base / 'source-manifest.json').read_text())
    expected = {name: value['sha256'] for name, value in manifest.items()}
    require(set(expected) == {'conv2d.c','check_conv_guard.c','check_sve_dispatch.c','remote_job.sh','candidate.env'}, 'Unexpected transport source set')
    pairs = re.findall(r'^([0-9a-f]{64})  (\S+)$', (raw / 'source-sha256.txt').read_text(), re.M)
    require(len(pairs) == len(expected) and {name:digest for digest,name in pairs} == expected,
        'Automated transport and returned source manifests differ')

    # Read actual xtrace argv, never evaluate or execute log contents.
    commands = [shlex.split(line) for line in re.findall(r'^\+ (gcc -O3 .+)$', probe, re.M)]
    flags = ['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra','-fno-fast-math',
        '-ffp-contract=off','-mcpu=generic','-fopenmp',f'-DEXPECTED_ACC={p["vectors"]}']
    require(commands == [flags + ['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],
        flags + ['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],
        flags + ['-S','conv2d.c','-o','conv2d-sve.s']], 'Actual build argv mismatch')
    for name in ('build-guard.log','build-dispatch.log','build-assembly.log'):
        require(not re.search(r'\berror:', (raw/name).read_text(), re.I), 'Compiler error in '+name)

    configurations = []
    for vl in (16,32,64):
        for threads in (1,4):
            lanes = vl//4
            header = f'SVE_BYTES={vl} SVE_LANES={lanes} BLOCK_OUTPUTS={p["vectors"]*lanes} THREADS={threads}'
            guard = (raw/f'guard-vl{vl}-t{threads}.log').read_text()
            dispatch = (raw/f'dispatch-vl{vl}-t{threads}.log').read_text()
            for log in (guard,dispatch):
                one_match('^'+re.escape(header)+'$', log, 'Worker VL/thread header mismatch')
                require(not re.search(r'\bFAIL(?:ED)?\b|ENTRY_FAIL',log), 'Numerical or entry failure')
            matrix = tuple(map(int,one_match(r'^FULL_MATRIX_COUNTS core=(\d+) narrow=(\d+) small=(\d+) larger=(\d+)$', guard, 'Missing full family counts')))
            require(matrix == p['matrix'], 'Full matrix family mismatch')
            one_match(r'^PASS: '+str(p['full'])+r' convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference$', guard, 'Full bitwise/guard pass missing')
            one_match(r'^PASS: '+str(p['dispatch'])+r' dispatch cases; exact per-case '+p['helper']+r' entries and bitwise scalar reference$', dispatch, 'Dispatch summary mismatch')
            one_match(r'^PASS: '+str(p['direct'])+r' direct fallback cases; kh1\.\.'+str(p['direct_kh_max'])+r', readonly/guard/canary and bitwise scalar reference$', dispatch, 'Direct fallback summary mismatch')
            worker_mask=(1 << threads)-1
            actual = {}
            for phase in ('dispatch','direct'):
                values=tuple(map(int,one_match('^'+phase.upper()+'_'+p['helper'].upper()+r'_ACTUAL_ENTRIES=(\d+) EXPECTED=(\d+) WORKER_MASK=(\d+) EXPECTED_MASK=(\d+)$',dispatch,'Entry/worker evidence missing')))
                require(values == (p[phase+'_entries'],p[phase+'_entries'],worker_mask,worker_mask),'Entry or worker mask mismatch')
                actual[phase+'_entries']=values[0]
                actual[phase+'_worker_mask']=values[2]
            entries={}
            for name in ('prefix','tail','rowpair','rowtriple','rowquad'):
                entries[name]=int(one_match('SVE_'+name.upper()+r'_ACTUAL_ENTRIES=(\d+)',dispatch,'Legacy entry evidence missing'))
                require(entries[name]>0,'Legacy helper not entered: '+name)
            configurations.append(dict(sve_bytes=vl,threads=threads,lanes=lanes,
                block_outputs_per_row=p['vectors']*lanes,full_cases=p['full'],dispatch_cases=p['dispatch'],
                direct_cases=p['direct'],helper_entries=entries,passed=True,**actual))

    # Human-reviewed mappings distinguish the new 9/11 stages and transitions.
    # Counts come from actual returned uninstrumented assembly, never from C6.
    review=json.loads((base/'assembly-review.json').read_text())
    for key in ('review_complete','production_uninstrumented','all_stages_and_transitions_reviewed',
                'whole_helper_stack_reviewed','abi_saves_distinguished'):
        require(review.get(key) is True,'Incomplete actual assembly review: '+key)
    helper='conv_sve_'+p['helper']
    require(review['helper']==helper and review['compiler_version']=='10.3.1','Assembly scope/compiler mismatch')
    assembly=(raw/'conv2d-sve.s').read_text()
    lines=assembly.splitlines()
    helper_start=lines.index(helper+':')+1
    helper_end=next(i+1 for i in range(helper_start,len(lines)) if re.match(r'\s*\.size\s+'+helper+r',',lines[i]))
    fma_count=len(re.findall(r'^\s*(?:fmla|fmls|fmad|fmsb|fnmla|fnmls|fnmad|fnmsb|fmadd|fmsub|fnmadd|fnmsub|fmlal2?|fmlsl2?|fmmla)\b',assembly,re.M))
    require(fma_count==review['whole_source_fma_count']==0,'Unexpected FMA')
    stage_ids=[f'input_{i}' for i in range(p['rows']-1)]+['shared']+[f'trailing_{i}' for i in range(p['rows']-1)]
    require([s['stage'] for s in review['stages']]==stage_ids,'Missing or misidentified 9/11-stage review')
    derived=[]
    reviewed_ranges=[]
    for stage in review['stages']:
        a,z=stage['line_start'],stage['line_end']
        require(type(a) is int and type(z) is int and helper_start<=a<=z<helper_end,'Invalid assembly stage range')
        require(all(z<old_a or a>old_z for old_a,old_z in reviewed_ranges),'Repeated or overlapping assembly stage ranges')
        reviewed_ranges.append((a,z))
        require(type(stage['kernel_columns_per_iteration']) is int and stage['kernel_columns_per_iteration']>0,'Missing iteration work unit')
        require(bool(stage['source_mapping']) and bool(stage['spill_notes']),'Missing source/spill interpretation')
        for key in ('vector_spill_loads','vector_spill_stores'):
            require(type(stage[key]) is int and stage[key]>=0,'Invalid spill observation')
        counts=collections.Counter()
        for line in lines[a-1:z]:
            m=re.match(r'^\s*([a-z][a-z0-9.]*)\s+',line)
            if m: counts[m[1]]+=1
        require(counts['fmul']>0 and counts['fadd']>0,'Stage lacks actual arithmetic')
        derived.append(dict(stage=stage['stage'],line_start=a,line_end=z,
            instructions=sum(counts.values()),fmul=counts['fmul'],fadd=counts['fadd'],
            input_ld1w=counts['ld1w'],kernel_ld1rw=counts['ld1rw'],
            ext=counts['ext'],movprfx=counts['movprfx'],
            kernel_columns_per_iteration=stage['kernel_columns_per_iteration'],
            vector_spill_loads=stage['vector_spill_loads'],vector_spill_stores=stage['vector_spill_stores']))
    require(bool(review['transition_spill_review']) and bool(review['stack_frame_description']), 'Missing transition/frame review')
    if version=='C42-row5x5asm':
        explicit=review['explicit_asm_review']
        for key in ('compiler_accepted','concrete_operands_reviewed','scratch_disjoint_from_inputs_and_accumulators','accumulator_order_reviewed'):
            require(explicit.get(key) is True,'C42 concrete inline-asm review incomplete: '+key)
        require(explicit['blocks_per_shared_iteration']==5 and bool(explicit['notes']),'C42 five-block template review missing')
    review['derived_stage_counts']=derived
    review['stage_count']=len(derived)
    review['fma_count']=fma_count
    review['transitions_reviewed']=review['all_stages_and_transitions_reviewed']
    hardware_metadata=None
    if (raw/'hardware-metadata.log').exists():
        hardware_text=(raw/'hardware-metadata.log').read_text()
        try:
            hardware_exit=int((raw/'hardware-metadata.exit.txt').read_text())
        except (OSError,ValueError):
            hardware_exit=None
        files=[]
        for name,value,status in re.findall(r'^FILE=([^\n]+)\n(.*?)^READ_STATUS=([^\n]+)$',hardware_text,re.M|re.S):
            files.append(dict(path=name,value=value.rstrip('\n'),read_status=status))
        hardware_metadata=dict(log='raw/hardware-metadata.log',collection_exit_code=hardware_exit,
            files=files,correctness_gate=False,raw_values_only=True,
            note='Optional read-only lscpu, default SVE length and first allocated CPU cache geometry. Missing reads are retained; model-name-based geometry is not inferred.')
    return dict(status='passed',complete=True,candidate=version,job_id=job['job_id'],scheduler=scheduler,
        exit_code=0,compiler_version='10.3.1',source_hashes_verified=True,source_manifest_remote_matches=True,
        source_hashes=expected,source_manifest=manifest,extra_manual_hash_audit=False,
        source_hash_verification_scope='Existing automated transport manifest compared with returned source-sha256.txt; no repeated manual byte-hash audit.',
        allocation=dict(cpus=cpu_ids,numa_node=numa),build_commands=commands,
        rows_per_group=p['rows'],accumulators_per_row=p['vectors'],total_accumulators=p['rows']*p['vectors'],
        configurations=configurations,full_cases=p['full']*6,dispatch_cases=p['dispatch']*6,
        direct_cases=p['direct']*6,total_cases=p['total'],expected_checks=expected_checks,
        assembly=review,hardware_metadata=hardware_metadata,executed_locally=False,executed_remotely=True,sanitizer='not_run',
        evidence_directory='raw',issues=[],spill_is_correctness_failure=False,
        note='Strict bitwise/readonly/guard checks and all actual-entry/worker evidence passed. Assembly spills are recorded observations; no speed or promotion conclusion.')

if __name__=='__main__':
    if len(sys.argv)!=2 or sys.argv[1] not in PLANS:
        raise SystemExit('Usage: python3 .runs/conv/sep12g-checks/accept_returned.py VERSION')
    version=sys.argv[1]
    base=Path(__file__).resolve().parent/version
    try:
        current=json.loads((base/'validation.json').read_text())
        require(current.get('complete') is not True,'Refusing to overwrite accepted evidence')
        result=validate(base,version)
    except Exception as exc:
        stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        failure=base/('acceptance-failure-'+stamp+'.json')
        failure.write_text(json.dumps(dict(status='acceptance_failed',complete=False,candidate=version,
            exception_type=type(exc).__name__,reason=str(exc),original_evidence_unchanged=True),indent=2)+'\n')
        raise SystemExit('Acceptance failed; original evidence unchanged. '+str(failure))
    (base/'validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(candidate=version,complete=True,total_cases=result['total_cases'],configurations=6),indent=2))
