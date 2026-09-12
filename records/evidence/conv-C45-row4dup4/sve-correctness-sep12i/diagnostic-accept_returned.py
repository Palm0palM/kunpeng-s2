"""Accept I returned text only. No SSH, compilation, tests or operator execution.

Usage: accept_returned.py VERSION [--failed]. Source/raw never change. An existing
prepared validation is preserved verbatim before a real final record replaces it.
Parsing failures get separate timestamped evidence, never invented numerical FAIL.
"""
import argparse
import collections
from datetime import datetime,timezone
import hashlib
import json
from pathlib import Path
import re
import shlex
import sys

sys.dont_write_bytecode=True
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
PLANS={
 'C45-row4dup4':dict(full=20164,dispatch=96,direct=0,total=121560,vectors=4,rows=4,helper='conv_sve_rowquad',parent='C26-row4loads'),
 'C46-row5x5asmfix':dict(full=3776,dispatch=504,direct=288,total=27408,vectors=5,rows=5,helper='conv_sve_rowquint',parent='C42-row5x5asm')}
SOURCE_NAMES={'conv2d.c','check_conv_guard.c','check_sve_dispatch.c','remote_job.sh','candidate.env'}
FMA=r'^\s*(?:fmla|fmls|fmad|fmsb|fnmla|fnmls|fnmad|fnmsb|fmadd|fmsub|fnmadd|fnmsub|fmlal2?|fmlsl2?|fmmla)\b'
TERMINAL={'SUCCEEDED','FAILED','CANCELLED','CANCELED','TIMEOUT','TERMINATED'}


def require(value,message):
    if not value: raise ValueError(message)

def read(path):
    return json.loads(path.read_text())

def one(pattern,text,message):
    values=re.findall(pattern,text,re.M)
    require(len(values)==1,message)
    return values[0]

def stage_names():
    return ['allocation','compiler','manifest','build-guard']+[f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-assembly','complete']

def source_identity(base,job,version,require_returned=True):
    hashes=read(base/'source-hashes.json')
    prepared=read(base/'prepared.json')
    require(set(hashes)==SOURCE_NAMES and job.get('source_hashes')==hashes,'Frozen/job source identity mismatch')
    require(prepared.get('candidate')==version and prepared.get('source_hashes')==hashes,'Prepared source identity mismatch')
    require(prepared.get('total_cases_planned')==PLANS[version]['total'],'Prepared total mismatch')
    if (base/'source-manifest.json').exists():
        manifest=read(base/'source-manifest.json')
        require({name:item['sha256'] for name,item in manifest.items()}==hashes,'Two original transport manifests disagree')
    record=read(ROOT/'records/experiments/conv'/(version+'.json'))
    require(record.get('version')==version and record.get('source_parent')==PLANS[version]['parent'] and record['source_hashes']['conv2d.c']==hashes['conv2d.c'],'Candidate checkpoint mismatch')
    path=base/'raw/source-sha256.txt'
    verified=False
    if path.exists():
        pairs=re.findall(r'^([0-9a-f]{64})  (\S+)$',path.read_text(),re.M)
        require(len(pairs)==5 and {name:digest for digest,name in pairs}==hashes,'Returned source manifest mismatch')
        for name,digest in hashes.items():
            require(hashlib.sha256((base/'raw'/name).read_bytes()).hexdigest()==digest,'Returned bytes differ from transport: '+name)
        verified=True
    require(not require_returned or verified,'Missing returned source manifest')
    return hashes,verified


def scheduler_identity(base,version):
    job=read(base/'job.json')
    require(job.get('version')==version and job.get('submitted') is True and job.get('submit_attempted') is True and job.get('explicit_go') is True,'Missing explicit unique submission identity')
    require(re.fullmatch(r'[0-9]+',job.get('job_id','')),'Missing job ID')
    status=job.get('scheduler_status') or {}
    require(str(status.get('jobId'))==job['job_id'] and status.get('status') in TERMINAL,'Missing true terminal scheduler state')
    require(type(status.get('jobExitCode')) is int and type(status.get('systemExitCode')) is int,'Missing scheduler exits')
    sys.path.insert(0,str(ROOT/'tools'))
    import cluster
    require(cluster.parse_scheduler_status((base/'scheduler.log').read_text(),job['job_id'])==status,'Saved scheduler differs from actual returned text')
    return job,status


def actual_commands(base,p):
    raw=base/'raw'
    flags=['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra','-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp',f'-DEXPECTED_ACC={p["vectors"]}']
    if p['rows']==4: flags+=['-DCHECK_ROWTRIPLE=1','-DCHECK_ROWQUAD=1']
    expected=[flags+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],
        flags+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],
        flags+['-S','conv2d.c','-o','conv2d-sve.s']]
    # BUILD_COMMAND printf is presentation only. Read actual shell xtrace argv.
    # Bash redirection can put that trace in probe or the individual build log;
    # accept only the exact three commands, in order, with consistent duplicates.
    traces={}
    names=['probe.log','build-guard.log','build-dispatch.log','build-assembly.log']
    for name in names:
        text=(raw/name).read_text()
        traces[name]=[shlex.split(line) for line in re.findall(r'^\+ (gcc -O3 .+)$',text,re.M)]
        require(not re.search(r'\berror:|undefined reference',text,re.I),'Compiler failure in '+name)
    probe_indices=[]
    for command in traces['probe.log']:
        require(command in expected,'Unexpected actual compile argv')
        probe_indices.append(expected.index(command))
    require(probe_indices==sorted(set(probe_indices)),'Repeated/reordered compile trace in probe')
    for i,name in enumerate(names[1:]):
        require(traces[name] in ([],[expected[i]]),'Unexpected actual compile trace in '+name)
        require(i in probe_indices or traces[name]==[expected[i]],'Actual compile argv not observed: '+name)
    return dict(commands=expected,actual_trace_locations=traces)


def bounds(lines,symbol):
    a=[i+1 for i,line in enumerate(lines) if line==symbol+':']
    z=[i+1 for i,line in enumerate(lines) if re.match(r'\s*\.size\s+'+re.escape(symbol)+r'\s*,',line)]
    require(len(a)==len(z)==1 and a[0]<z[0],'Ambiguous function bounds '+symbol)
    return a[0],z[0]


def instructions(lines,a,z):
    result=[]
    for line in lines[a-1:z]:
        m=re.match(r'^\s*([a-z][a-z0-9.]*)\s+(.+?)\s*$',line)
        if m: result.append((m[1],m[2]))
    return result


def counts(lines,a,z):
    inst=instructions(lines,a,z)
    c=collections.Counter(name for name,operands in inst)
    indexed=sum(name=='fmul' and bool(re.search(r'z\d+\.s\[\d+\]',operands)) for name,operands in inst)
    return dict(instructions=len(inst),fmul=c['fmul'],fmul_ordinary=c['fmul']-indexed,fmul_indexed=indexed,
        fadd=c['fadd'],ld1w=c['ld1w'],ld1rw=c['ld1rw'],ld1rqw=c['ld1rqw'],dup=c['dup'],
        indexed_mov=sum(name=='mov' and bool(re.search(r'z\d+\.s\[\d+\]',operands)) for name,operands in inst),
        ext=c['ext'],movprfx=c['movprfx'])


def range_review(item,lines,outer,prior,work):
    a,z=item['line_start'],item['line_end']
    require(type(a) is int and type(z) is int and outer[0]<=a<=z<outer[1],'Invalid actual loop range')
    require(all(z<x or a>y for x,y in prior),'Overlapping distinct phase/loop ranges')
    prior.append((a,z))
    require(item.get('kernel_columns_per_iteration')==work,'Incorrect loop work normalization')
    require(bool(item.get('source_mapping')) and bool(item.get('spill_notes')),'Missing actual loop mapping/spill interpretation')
    for key in ('vector_spill_loads','vector_spill_stores'):
        require(type(item.get(key)) is int and item[key]>=0,'Invalid spill observation')
    actual=counts(lines,a,z)
    require(actual['fmul']>0 and actual['fadd']>0,'Reviewed loop lacks separate arithmetic')
    item['derived_counts']=actual


def assembly_review(base,job,p,source_hash):
    raw=base/'raw'
    content=(raw/'conv2d-sve.s').read_bytes()
    text=content.decode()
    lines=text.splitlines()
    review=read(base/'assembly-review.json')
    require(review.get('candidate')==job['version'] and review.get('job_id')==job['job_id'] and review.get('source_sha256')==source_hash and review.get('compiler_version')=='10.3.1','Actual assembly review identity mismatch')
    require(review.get('assembly_sha256')==hashlib.sha256(content).hexdigest(),'Assembly review has wrong returned artifact')
    for key in ('review_complete','production_uninstrumented','whole_helper_stack_reviewed','all_stages_and_transitions_reviewed','abi_saves_distinguished','dispatch_reviewed'):
        require(review.get(key) is True,'Incomplete assembly review '+key)
    fma=len(re.findall(FMA,text,re.M))
    require(fma==review.get('whole_source_fma_count')==0,'Unexpected FMA')
    symbols=re.findall(r'^\s*\.type\s+([^,\s]+),\s*%function\s*$',text,re.M)
    targets=sorted(s for s in symbols if s==p['helper'] or s.startswith(p['helper']+'.'))
    helpers=review.get('helpers') or []
    require(targets and sorted(h['symbol'] for h in helpers)==targets,'Review every actual target helper/clone')
    phase_ids=[f'input_{i}' for i in range(p['rows']-1)]+['shared']+[f'trailing_{i}' for i in range(p['rows']-1)]
    for helper in helpers:
        outer=bounds(lines,helper['symbol'])
        require((helper['line_start'],helper['line_end'])==outer,'Whole helper range mismatch')
        for key in ('stack_frame_description','spill_notes','transition_spill_review','tail_and_fallback_review'):
            require(bool(helper.get(key)),'Missing whole helper interpretation '+key)
        for key in ('vector_spill_loads','vector_spill_stores'):
            require(type(helper.get(key)) is int and helper[key]>=0,'Invalid whole helper spill count')
        stages=helper.get('stages') or []
        require([s['stage'] for s in stages]==phase_ids,'Missing/reordered seven/nine phases')
        ranges=[]
        for stage in stages:
            work=(4 if stage['stage']=='shared' else 2) if p['rows']==4 else 1
            range_review(stage,lines,outer,ranges,work)
        if p['rows']==4:
            remainders=helper.get('shared_remainders') or []
            require([x['loop'] for x in remainders]==['remainder2','remainder1'],'Missing shared 2/1-column remainder mapping')
            for item,work in zip(remainders,(2,1)): range_review(item,lines,outer,ranges,work)
            require(bool(helper.get('nonshared_remainder_review')),'Other phase single-column remainders unreviewed')
    dispatch_symbols=sorted(s for s in symbols if s=='conv2d' or s.startswith('conv2d.'))
    dispatch=review.get('dispatch_functions') or []
    require(dispatch_symbols and sorted(x['symbol'] for x in dispatch)==dispatch_symbols,'Missing actual conv2d/outlined-worker review')
    for item in dispatch:
        require((item['line_start'],item['line_end'])==bounds(lines,item['symbol']),'Dispatch range mismatch')
        require(bool(item.get('control_flow_notes')) and bool(item.get('stack_notes')),'Dispatch/fallback interpretation missing')
    if p['rows']==4:
        comparison=review.get('codegen_comparison') or {}
        require(comparison.get('review_complete') is True and type(comparison.get('distinct_from_prior_machine_arrangements')) is bool,'C45 needs actual prior-machine comparison')
        require(set(comparison.get('prior_versions',[]))=={'C29-row4lane4','C32-row4lane4staged'},'Compare actual C29/C32 background')
        require(bool(comparison.get('normalization')) and bool(comparison.get('notes')),'Missing actual LD1RQ/DUP/indexed-vs-ordinary interpretation')
    else:
        explicit=review.get('explicit_asm_review') or {}
        for key in ('compiler_accepted','concrete_operands_reviewed','scratch_disjoint_from_inputs_and_accumulators','accumulator_order_reviewed'):
            require(explicit.get(key) is True,'C46 actual asm proof incomplete '+key)
        require(bool(explicit.get('notes')),'Missing asm interpretation')
        blocks=explicit.get('blocks') or []
        require(len(blocks)==5 and [b['input_vector'] for b in blocks]==list(range(5)),'Need all five concrete source asm scopes')
        shared_ranges=[(s['line_start'],s['line_end']) for h in helpers for s in h['stages'] if s['stage']=='shared']
        seen=[]
        for block in blocks:
            a,z=block['line_start'],block['line_end']
            require(any(x<=a<=z<=y for x,y in shared_ranges) and all(z<x or a>y for x,y in seen),'Invalid/repeated explicit asm range')
            seen.append((a,z))
            inst=instructions(lines,a,z)
            require([name for name,ops in inst]==['fmul','fadd']*5,'Actual asm block is not five ordered mul/add pairs')
            scratch=block['scratch_register']; input_reg=block['input_register']
            acc=block['accumulator_registers']; coeff=block['coefficient_registers']; live=block['live_accumulator_registers']
            require(len(acc)==len(coeff)==5 and len(set(acc))==5 and set(acc)<=set(live),'Actual accumulator mapping incomplete')
            require(all(re.fullmatch(r'z(?:[0-9]|[12][0-9]|3[01])',x) for x in [scratch,input_reg]+acc+coeff+live),'Invalid actual Z register name')
            require(scratch not in set(live+coeff+[input_reg]) and not set(acc)&set(coeff+[input_reg]),'Actual scratch/output aliases live operands')
            for i in range(5):
                mul=[x.strip() for x in inst[2*i][1].split(',')]
                add=[x.strip() for x in inst[2*i+1][1].split(',')]
                require(mul==[scratch+'.s',input_reg+'.s',coeff[i]+'.s'] and add==[acc[i]+'.s',acc[i]+'.s',scratch+'.s'],'Actual operands/order differ from reviewed mapping')
            require(bool(block.get('liveness_and_spill_notes')),'Missing other-live-accumulator/spill proof')
    review.update(stage_count=len(phase_ids),fma_count=fma,transitions_reviewed=True,
        production_object_disassembly_available=False,performance_submission_automatic=False)
    return review


def validate(base,version):
    p=PLANS[version]; raw=base/'raw'
    job,scheduler=scheduler_identity(base,version)
    require(scheduler['status']=='SUCCEEDED' and scheduler['jobExitCode']==scheduler['systemExitCode']==0,'Scheduler did not succeed')
    require(job.get('resources')==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800),'Resource plan mismatch')
    require(job.get('expected_checks')==dict(full_per_configuration=p['full'],dispatch_per_configuration=p['dispatch'],direct_per_configuration=p['direct'],configurations=6,total=p['total']),'Job count plan mismatch')
    require((raw/'exit-code.txt').read_text().strip()=='0','Wrapper failed')
    prepared=read(base/'prepared.json')
    require(prepared['expected_stages']==stage_names(),'Frozen stage plan mismatch')
    require((raw/'stage-exits.txt').read_text().splitlines()==['STAGE='+s+' EXIT=0' for s in stage_names()],'Expected 19 ordered zero stages')
    require((raw/'compiler-version.txt').read_text().strip()=='10.3.1','Compiler mismatch')
    probe=(raw/'probe.log').read_text()
    one(r'^CANDIDATE='+re.escape(version)+r'$',probe,'Missing candidate identity')
    one(r'^PROBE_COMPLETE=1$',probe,'Missing completion')
    one(r'^EXPECTED_TOTAL_CHECKS='+str(p['total'])+r'$',probe,'Final count mismatch')
    require('SANITIZER_STATUS=NOT_RUN' in probe,'Missing sanitizer scope')
    require(not re.search(r'\bFAIL(?:ED)?\b|ENTRY_FAIL|Worker VL/thread mismatch',probe),'Wrapper reports failure')
    cpus=list(map(int,one(r'^ALLOWED_CPUS=([0-9,]+)$',probe,'Missing CPU allocation').split(',')))
    require(len(cpus)==len(set(cpus))==38,'Expected 38 allocated CPUs')
    numa=one(r'^NUMA_NODE=(node[0-9]+)$',probe,'Missing one NUMA')
    hashes,verified=source_identity(base,job,version)
    commands=actual_commands(base,p)
    configurations=[]
    for vl in (16,32,64):
        for threads in (1,4):
            header=f'SVE_BYTES={vl} SVE_LANES={vl//4} BLOCK_OUTPUTS={p["vectors"]*(vl//4)} THREADS={threads}'
            guard=(raw/f'guard-vl{vl}-t{threads}.log').read_text()
            dispatch=(raw/f'dispatch-vl{vl}-t{threads}.log').read_text()
            for text in (guard,dispatch):
                one('^'+re.escape(header)+'$',text,'Worker VL/team mismatch')
                require(not re.search(r'\bFAIL(?:ED)?\b|ENTRY_FAIL|Worker VL/thread mismatch',text),'Case or entry failure')
            ending=r' convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference$'
            one(r'^PASS: '+str(p['full'])+ending,guard,'Production full count/PASS missing')
            entries={name:int(one(r'SVE_'+name.upper()+r'_ACTUAL_ENTRIES=(\d+)',dispatch,'Missing legacy entry '+name)) for name in ('prefix','tail','rowpair','rowtriple','rowquad')}
            if p['rows']==4:
                one(r'^PASS: 96'+ending,dispatch,'C45 smoke96 missing')
                require(all(entries[x]>0 for x in ('rowpair','rowtriple','rowquad')),'C45 required helper entry absent')
                extra=dict(entry_check_scope='Aggregate original C32 smoke entries; no per-case new-loop count or worker mask')
            else:
                one(r'^FULL_MATRIX_COUNTS core=3168 narrow=144 small=432 larger=32$',guard,'C46 matrix family mismatch')
                require(all(value>0 for value in entries.values()),'C46 legacy helper not entered')
                one(r'^PASS: 504 dispatch cases; exact per-case rowquint entries and bitwise scalar reference$',dispatch,'C46 dispatch504 missing')
                one(r'^PASS: 288 direct fallback cases; kh1\.\.4, readonly/guard/canary and bitwise scalar reference$',dispatch,'C46 direct288 missing')
                mask=(1<<threads)-1
                extra={}
                for phase,n in (('dispatch',528),('direct',720)):
                    values=tuple(map(int,one('^'+phase.upper()+r'_ROWQUINT_ACTUAL_ENTRIES=(\d+) EXPECTED=(\d+) WORKER_MASK=(\d+) EXPECTED_MASK=(\d+)$',dispatch,'Missing quint entry/mask')))
                    require(values==(n,n,mask,mask),'Quint per-phase entry/mask mismatch')
                    extra[phase+'_entries']=n;extra[phase+'_worker_mask']=mask
            configurations.append(dict(sve_bytes=vl,threads=threads,lanes=vl//4,block_outputs_per_row=p['vectors']*(vl//4),
                full_cases=p['full'],dispatch_cases=p['dispatch'],direct_cases=p['direct'],helper_entries=entries,passed=True,**extra))
    assembly=assembly_review(base,job,p,hashes['conv2d.c'])
    return dict(status='passed',complete=True,candidate=version,job_id=job['job_id'],scheduler=scheduler,exit_code=0,
        expected_checks=dict(full_per_configuration=p['full'],dispatch_per_configuration=p['dispatch'],direct_per_configuration=p['direct'],configurations=6,total=p['total']),
        total_cases=p['total'],full_cases=p['full']*6,dispatch_cases=p['dispatch']*6,direct_cases=p['direct']*6,runner_cases=0,
        configurations=configurations,source_hashes=hashes,source_hashes_verified=verified,source_manifest_remote_matches=verified,
        extra_manual_hash_audit=False,compiler_version='10.3.1',build_commands=commands,stage_exits=[dict(stage=s,exit_code=0) for s in stage_names()],
        allocation=dict(cpus=cpus,numa_node=numa),assembly=assembly,performance_measured=False,performance_requires_root_review=True,
        automatic_performance_submission=False,spill_is_correctness_failure=False,executed_locally=False,executed_remotely=True,
        sanitizer='not_run',issues=[],note='Actual independent I diagnostics only; old C32/C41/C42 logs provide no candidate PASS. No speed or promotion claim.')


def failed_result(base,version):
    p=PLANS[version]; raw=base/'raw'
    job,scheduler=scheduler_identity(base,version)
    wrapper=int((raw/'exit-code.txt').read_text().strip()) if (raw/'exit-code.txt').exists() else None
    stages=(raw/'stage-exits.txt').read_text().splitlines() if (raw/'stage-exits.txt').exists() else []
    failed_stages=re.findall(r'^STAGE=(\S+) EXIT=(-?\d+)$','\n'.join(stages),re.M)
    failed_stages=[dict(stage=name,exit_code=int(code)) for name,code in failed_stages if int(code)!=0]
    require(scheduler['status']!='SUCCEEDED' or scheduler['jobExitCode']!=0 or scheduler['systemExitCode']!=0 or wrapper not in (None,0) or failed_stages,'No actual execution failure; retain parser failure separately')
    identity_issues=[]
    try:
        hashes,verified=source_identity(base,job,version,False)
    except (ValueError,OSError,KeyError) as exc:
        hashes=read(base/'source-hashes.json')
        require(job.get('source_hashes')==hashes,'Failed job/prepared identity mismatch')
        verified=False
        identity_issues.append(str(exc))
    return dict(status='failed',complete=False,candidate=version,job_id=job['job_id'],scheduler=scheduler,exit_code=wrapper,
        reason='Actual remote scheduler/wrapper/stage failure; see original raw/probe.log, build logs and stage-exits.txt. No automatic source repair or retry.',
        failed_stages=failed_stages,stage_exit_lines=stages,planned_total_cases=p['total'],total_cases=None,
        full_cases=None,dispatch_cases=None,direct_cases=None,configurations=[],actual_cases_executed=None,
        source_hashes=hashes,source_hashes_verified=verified,source_manifest_remote_matches=verified,identity_issues=identity_issues,
        assembly_available=(raw/'conv2d-sve.s').exists(),assembly=dict(review_complete=False),
        original_evidence_unchanged=True,candidate_source_unchanged=True,retry_submitted=False,
        executed_locally=False,executed_remotely=True,performance_measured=False,sanitizer='not_run')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('version',choices=PLANS)
    parser.add_argument('--failed',action='store_true')
    args=parser.parse_args(); base=BASE/args.version
    path=base/'validation.json'
    prior=path.read_bytes() if path.exists() else None
    try:
        if prior is not None:
            old=json.loads(prior)
            require(old.get('status')=='prepared' and old.get('complete') is False and not old.get('job_id'),'Refusing to overwrite final validation')
        result=failed_result(base,args.version) if args.failed else validate(base,args.version)
        if prior is not None:
            require(path.read_bytes()==prior,'Prepared validation changed concurrently')
            with (base/'prepared-validation.json').open('xb') as handle: handle.write(prior)
        temporary=base/'validation.json.pending'
        with temporary.open('x') as handle: json.dump(result,handle,indent=2);handle.write('\n')
        temporary.replace(path)
    except Exception as exc:
        stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        failure=base/('acceptance-failure-'+stamp+'.json')
        failure.write_text(json.dumps(dict(status='acceptance_failed',complete=False,candidate=args.version,reason=str(exc),exception_type=type(exc).__name__,original_evidence_unchanged=True),indent=2)+'\n')
        raise SystemExit('Acceptance failed; original evidence retained: '+str(failure))
    print(json.dumps({key:result.get(key) for key in ('candidate','status','complete','job_id','total_cases')},indent=2))


if __name__=='__main__': main()
