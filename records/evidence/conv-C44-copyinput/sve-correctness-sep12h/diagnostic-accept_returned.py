"""Accept returned H diagnostic text; never compile or execute the operator.

Requires job.json, source-hashes.json, raw/* and assembly-review.json. Success
writes validation.json exclusively; failed acceptance writes separate evidence
without overwriting source, returned logs, a previous PASS, or prepared.json.
"""
import collections
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shlex
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
VERSIONS = {'C43-padinput': 'padded', 'C44-copyinput': 'original'}
SOURCE_NAMES = {'README.md','bench_conv.c','conv2d.c','run.sh','check_conv_guard.c',
    'copy_probe.h','copy_probe.c','instrumented_candidate.c','candidate.env','remote_job.sh'}
COUNTS = dict(configurations=6, production_per_configuration=24100,
    copy_success_per_configuration=6048, copy_failure_per_configuration=6048,
    production_cases=144600, copy_success_cases=36288, copy_failure_cases=36288,
    total_cases=217176, runner_cases=0)
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
    numa_distribution='pack', walltime_seconds=1800)
FP_FMA = r'^\s*(?:fmla|fmls|fmad|fmsb|fnmla|fnmls|fnmad|fnmsb|fmadd|fmsub|fnmadd|fnmsub|fmlal2?|fmlsl2?|fmmla)\b'


def require(value, message):
    if not value:
        raise ValueError(message)


def read_json(path):
    return json.loads(path.read_text())


def one_match(pattern, text, message):
    matches = re.findall(pattern, text, re.M)
    require(len(matches) == 1, message)
    return matches[0]


def hash_bytes(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_guard(text, vl, threads, count):
    header = f'SVE_BYTES={vl} SVE_LANES={vl//4} BLOCK_OUTPUTS={vl} THREADS={threads}'
    one_match('^' + re.escape(header) + '$', text, 'Actual SVE/worker-thread configuration mismatch')
    require(not re.search(r'\bFAIL(?:ED)?\b|COPY_PROBE_ERROR=|Worker VL/thread mismatch', text),
        'Guard, copy-path, or worker failure reported')
    one_match(r'^PASS: ' + str(count) + r' convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference$',
        text, 'Missing exact bitwise/readonly/guard/canary PASS count')


def copy_counts(text, mode, stride):
    line = one_match(r'^COPY_PROBE_MODE=.+$', text, 'Missing/duplicate copy-path summary')
    pairs = re.findall(r'([A-Z_]+)=([^ ]+)', line)
    row = dict(pairs)
    require(len(row) == len(pairs), 'Duplicate copy-path field')
    expected = dict(COPY_PROBE_MODE=mode, STRIDE_MODE=stride, CASES='6048', ELIGIBLE='2800',
        DISABLED='3248', MALLOC_ATTEMPTS='2800', MALLOC_SUCCESSES='2800' if mode=='success' else '0',
        FORCED_FAILURES='0' if mode=='success' else '2800',
        MEMCPY_CALLS='28280' if mode=='success' else '0',
        FREE_CALLS='2800' if mode=='success' else '0', ERROR_COUNT='0')
    require(row == expected and line == ' '.join(k+'='+v for k,v in pairs),
        'Actual allocation/copy/free/forced-failure counts differ from the frozen matrix')
    return {key.lower(): int(value) if value.isdecimal() else value for key,value in row.items()}


def function_bounds(lines, name):
    starts = [i+1 for i,line in enumerate(lines) if line == name+':']
    ends = [i+1 for i,line in enumerate(lines) if re.match(r'\s*\.size\s+'+re.escape(name)+r'\s*,',line)]
    require(len(starts)==len(ends)==1 and starts[0]<ends[0], 'Missing/ambiguous actual function range: '+name)
    return starts[0], ends[0]


def instruction_counts(lines, start, end):
    counts=collections.Counter()
    for line in lines[start-1:end]:
        match=re.match(r'^\s*([a-z][a-z0-9.]*)\s+', line)
        if match:
            counts[match[1]] += 1
    return dict(instructions=sum(counts.values()), fmul=counts['fmul'], fadd=counts['fadd'],
        input_ld1w=counts['ld1w'], kernel_ld1rw=counts['ld1rw'],
        movprfx=counts['movprfx'], ext=counts['ext'])


def assembly_review(base, job, source_hash, compiler):
    raw=base/'raw'
    review=read_json(base/'assembly-review.json')
    require(review.get('candidate')==job['version'] and review.get('job_id')==job['job_id'] and
        review.get('source_sha256')==source_hash and review.get('compiler_version')==compiler,
        'Assembly review identity/compiler mismatch')
    for key in ('review_complete','production_uninstrumented','production_object_disassembly_reviewed',
                'whole_source_fma_reviewed','whole_quad_and_dispatch_reviewed',
                'all_stages_and_transitions_reviewed','abi_saves_distinguished'):
        require(review.get(key) is True, 'Missing actual assembly review: '+key)
    assembly=(raw/'conv2d-sve.s').read_text()
    objdump=(raw/'production-conv2d-objdump.log').read_text()
    lines=assembly.splitlines()
    object_hash=one_match(r'^([0-9a-f]{64})  production-conv2d\.o$',
        (raw/'production-object-sha256.txt').read_text(), 'Missing actual production-object identity')
    require(review.get('production_object_sha256')==object_hash and
        review.get('assembly_sha256')==hashlib.sha256(assembly.encode()).hexdigest(),
        'Assembly review does not identify these returned artifacts')
    if (raw/'production-conv2d.o').exists():
        require(hash_bytes(raw/'production-conv2d.o')==object_hash, 'Returned object bytes differ from remote hash')
    require('file format elf64-littleaarch64' in objdump, 'Actual AArch64 object disassembly missing')
    fma=len(re.findall(FP_FMA,assembly,re.M))
    # Objdump lines carry address/opcode prefixes, unlike compiler .s output.
    object_fma=len(re.findall(r'\t(?:fmla|fmls|fmad|fmsb|fnmla|fnmls|fnmad|fnmsb|fmadd|fmsub|fnmadd|fnmsub|fmlal2?|fmlsl2?|fmmla)\s',objdump))
    require(fma==review.get('whole_source_fma_count')==0 and
        object_fma==review.get('production_object_fma_count')==0, 'Unexpected fused arithmetic')
    symbols=re.findall(r'^\s*\.type\s+([^,\s]+),\s*%function\s*$',assembly,re.M)
    quad_symbols=sorted(name for name in symbols if name=='conv_sve_rowquad' or name.startswith('conv_sve_rowquad.'))
    dispatch_symbols=sorted(name for name in symbols if name=='conv2d' or name.startswith('conv2d.'))
    require(quad_symbols and dispatch_symbols and 'conv2d' in dispatch_symbols,
        'Actual quad/dispatch function symbols missing')
    background=review.get('c6_background') or {}
    require(background.get('source_version')=='C26-row4loads' and background.get('quad_phases')==7
        and bool(background.get('notes')), 'C6 seven-stage background missing; it is not current machine-code evidence')
    quads=review.get('quad_helpers') or []
    dispatch=review.get('dispatch_functions') or []
    require(sorted(q['symbol'] for q in quads)==quad_symbols, 'Review must cover every actual quad function/clone')
    require(sorted(d['symbol'] for d in dispatch)==dispatch_symbols,
        'Review must cover conv2d and every actual outlined dispatch/copy worker')
    stages=['input_0','input_1','input_2','shared','trailing_0','trailing_1','trailing_2']
    for item in quads+dispatch:
        a,z=function_bounds(lines,item['symbol'])
        require((item['line_start'],item['line_end'])==(a,z), 'Full-function review range mismatch')
        require(bool(item.get('stack_frame_description')) and bool(item.get('spill_notes')),
            'Missing whole-function stack/spill review')
        require('<'+item['symbol']+'>:' in objdump, 'Actual object lacks reviewed function')
        for key in ('vector_spill_loads','vector_spill_stores'):
            require(type(item.get(key)) is int and item[key]>=0, 'Invalid whole-function spill observation')
        item['derived_function_counts']=instruction_counts(lines,a,z)
    for quad in quads:
        require([s['stage'] for s in quad.get('stages',[])]==stages, 'Missing/reordered seven-stage mapping')
        ranges=[]
        for stage in quad['stages']:
            a,z=stage['line_start'],stage['line_end']
            require(type(a) is int and type(z) is int and quad['line_start']<=a<=z<quad['line_end'],
                'Invalid actual stage range')
            require(all(z<old_a or a>old_z for old_a,old_z in ranges), 'Overlapping stage ranges')
            ranges.append((a,z))
            require(type(stage.get('kernel_columns_per_iteration')) is int and stage['kernel_columns_per_iteration']>0,
                'Missing stage normalization')
            require(bool(stage.get('source_mapping')) and bool(stage.get('spill_notes')), 'Missing stage interpretation')
            for key in ('vector_spill_loads','vector_spill_stores'):
                require(type(stage.get(key)) is int and stage[key]>=0, 'Invalid stage spill observation')
            counts=instruction_counts(lines,a,z)
            require(counts['fmul']>0 and counts['fadd']>0, 'Stage lacks independent arithmetic')
            stage['derived_counts']=counts
        require(bool(quad.get('transition_spill_review')), 'Missing quad transition spill review')
    for item in dispatch:
        require(bool(item.get('role')) and bool(item.get('copy_path_notes')) and bool(item.get('control_flow_notes')),
            'Missing dispatch/copy-worker control-flow interpretation')
    paths=review.get('copy_path_review') or {}
    for key in ('eligibility_and_overflow','malloc_and_null_fallback','row_memcpy_and_stride',
                'compute_and_free_order','noncopy_and_non_sve_fallback'):
        require(bool(paths.get(key)), 'Missing copy-path assembly/source mapping: '+key)
    require(review.get('whole_machine_code_identical_claimed') is False,
        'Do not infer complete machine-code identity from the unchanged source helpers')
    review.update(derived_whole_source_fma_count=fma,derived_production_object_fma_count=object_fma)
    return review


def validate(base, version):
    raw=base/'raw'
    job=read_json(base/'job.json')
    require(job.get('version')==version and job.get('submitted') is True and job.get('submit_attempted') is True
        and job.get('explicit_go') is True, 'Job candidate/submission identity mismatch')
    require(re.fullmatch(r'[0-9]+',job.get('job_id','')), 'Missing unique job ID')
    scheduler=job.get('scheduler_status') or {}
    require(str(scheduler.get('jobId'))==job['job_id'] and scheduler.get('status')=='SUCCEEDED'
        and type(scheduler.get('jobExitCode')) is int and scheduler['jobExitCode']==0
        and type(scheduler.get('systemExitCode')) is int and scheduler['systemExitCode']==0,
        'Scheduler identity/status/two exits not successful')
    # Cross-check the saved status against its actual returned text.
    sys.path.insert(0,str(ROOT/'tools'))
    import cluster
    require(cluster.parse_scheduler_status((base/'scheduler.log').read_text(),job['job_id'])==scheduler,
        'Saved scheduler fields disagree with returned scheduler text')
    require(job.get('resources')==RESOURCES and job.get('expected_checks')==COUNTS,
        'Resource/count plan mismatch')
    require((raw/'exit-code.txt').read_text().strip()=='0', 'Wrapper failed or is incomplete')
    stages=['allocation','source-manifest','production-kernel','production-guard','production-assembly']
    stages += [f'production-guard-vl{vl}-t{t}' for vl in (16,32,64) for t in (1,4)]
    stages += ['instrumented-kernel','instrumented-guard']
    stages += [f'copy-{mode}-vl{vl}-t{t}' for vl in (16,32,64) for t in (1,4) for mode in ('success','failure')]
    stages += ['complete']
    actual_stages=(raw/'stage-exits.txt').read_text().splitlines()
    require(actual_stages==['STAGE='+stage+' EXIT=0' for stage in stages],
        'Every stage must occur exactly once, in order, with exit 0')
    probe=(raw/'probe.log').read_text()
    one_match(r'^PROBE_COMPLETE=1$',probe,'Probe not complete')
    one_match(r'^PRODUCTION_GUARD_CASES=144600 COPY_SUCCESS_CASES=36288 COPY_FAILURE_CASES=36288 TOTAL_CASES=217176$',
        probe,'Final actual count marker mismatch')
    one_match(r'^RUNNER_CASES=0 SANITIZER_STATUS=NOT_RUN LARGE_ALLOCATION_EXTREMES=STATIC_ONLY$',
        probe,'Dynamic validation scope mismatch')
    require(not re.search(r'\bFAIL(?:ED)?\b|COPY_PROBE_ERROR=|Worker VL/thread mismatch',probe), 'Failure in wrapper log')
    cpus=list(map(int,one_match(r'^ALLOWED_CPUS=([0-9,]+)$',probe,'Missing actual allocation').split(',')))
    require(len(cpus)==len(set(cpus))==38,'Expected exactly 38 allocated CPUs')
    numa=one_match(r'^NUMA_NODE=(node[0-9]+)$',probe,'Missing single NUMA evidence')
    environment=(raw/'environment.log').read_text()
    one_match(r'^Threads=38 Bind=close Places=cores CPU_TARGET=generic$',environment,'Thread/binding settings mismatch')
    compiler=one_match(r'^gcc \([^\n]+\) ([0-9]+\.[0-9]+\.[0-9]+)(?: .*)?$',environment,'Missing actual compiler banner')
    require(compiler=='10.3.1','Compiler differs from the declared C6 diagnostic environment')

    expected=read_json(base/'source-hashes.json')
    require(set(expected)==SOURCE_NAMES and job.get('source_hashes')==expected,'Frozen transport identity mismatch')
    pairs=re.findall(r'^([0-9a-f]{64})  (\S+)$',(raw/'source-sha256.txt').read_text(),re.M)
    require(len(pairs)==len(expected) and {name:digest for digest,name in pairs}==expected,
        'Remote source manifest differs from frozen package')
    require(all(hash_bytes(raw/name)==digest for name,digest in expected.items()),
        'Fetched source bytes differ from the automatic transport manifest')
    record=read_json(ROOT/'records/experiments/conv'/(version+'.json'))
    require(record.get('version')==version and record.get('source_parent')=='C26-row4loads' and
        record.get('source_hashes')=={name:expected[name] for name in ('README.md','bench_conv.c','conv2d.c','run.sh')},
        'Frozen candidate checkpoint identity mismatch')
    require(record.get('reference_only') is (version=='C44-copyinput'), 'C44 control role mismatch')

    flags=['gcc','-O3','-std=c11','-Wall','-Wextra','-fno-fast-math','-ffp-contract=off',
        '-mcpu=generic','-fopenmp','-DCONV_BLOCK=32','-DCONV_KERNEL_UNROLL=2']
    guard=flags+['-D_DEFAULT_SOURCE','-DEXPECTED_ACC=4','-DCHECK_ROWTRIPLE=1','-DCHECK_ROWQUAD=1']
    expected_commands={
        'build-production.log':[flags+['-c','conv2d.c','-o','production-conv2d.o']],
        'build-guard.log':[guard+['-c','check_conv_guard.c','-o','production-guard.o'],
            flags+['production-guard.o','production-conv2d.o','-o','check_conv_guard','-lm']],
        'build-assembly.log':[flags+['-S','conv2d.c','-o','conv2d-sve.s']],
        'build-copy-probe.log':[flags+['-c','instrumented_candidate.c','-o','instrumented-conv2d.o'],
            guard+['-DCOPY_PATH_PROBE','-c','check_conv_guard.c','-o','copy-guard.o'],
            flags+[f'-DCOPY_EXPECT_PADDED={1 if version=="C43-padinput" else 0}','-c','copy_probe.c','-o','copy-probe.o'],
            flags+['copy-guard.o','instrumented-conv2d.o','copy-probe.o','-o','check_input_copy','-lm']]}
    commands={}
    for name, expected_argv in expected_commands.items():
        text=(raw/name).read_text()
        require(not re.search(r'\berror:|undefined reference',text,re.I),'Compiler/linker failure in '+name)
        # set -x can interleave the incremental BUILD_COMMAND printf marker.
        # Parse only actual executed '+ gcc ...' argv, never eval any log content.
        commands[name]=[shlex.split(line) for line in re.findall(r'^\+ (gcc .+)$',text,re.M)]
        require(commands[name]==expected_argv,'Actual production/instrumented compile or link argv mismatch: '+name)

    configurations=[]
    for vl in (16,32,64):
        for threads in (1,4):
            production=(raw/f'guard-vl{vl}-t{threads}.log').read_text()
            check_guard(production,vl,threads,24100)
            require('COPY_PROBE_MODE=' not in production,'Production guard must not be an instrumented result')
            modes={}
            for mode in ('success','failure'):
                text=(raw/f'copy-{mode}-vl{vl}-t{threads}.log').read_text()
                check_guard(text,vl,threads,6048)
                modes[mode]=copy_counts(text,mode,VERSIONS[version])
            configurations.append(dict(sve_bytes=vl,lanes=vl//4,threads=threads,block_outputs_per_row=vl,
                production_guard_cases=24100,copy_success_cases=6048,copy_failure_cases=6048,
                copy_success=modes['success'],copy_failure=modes['failure'],passed=True))
    review=assembly_review(base,job,expected['conv2d.c'],compiler)
    return dict(status='passed',complete=True,candidate=version,job_id=job['job_id'],scheduler=scheduler,
        exit_code=0,stage_exits=[dict(stage=s,exit_code=0) for s in stages],compiler_version=compiler,
        source_hashes_verified=True,source_manifest_remote_matches=True,source_hashes=expected,
        extra_manual_hash_audit=False,source_hash_verification_scope='Automatic frozen/returned source identity only.',
        allocation=dict(cpus=cpus,numa_node=numa,requested_resources=RESOURCES),build_commands=commands,
        configurations=configurations,production_guard_cases=144600,copy_success_cases=36288,
        copy_failure_cases=36288,total_cases=217176,runner_cases=0,combined_validation_cases=217176,
        copy_success_totals=dict(cases=36288,eligible=16800,disabled=19488,malloc_attempts=16800,
            malloc_successes=16800,forced_failures=0,memcpy_calls=169680,free_calls=16800,error_count=0),
        copy_failure_totals=dict(cases=36288,eligible=16800,disabled=19488,malloc_attempts=16800,
            malloc_successes=0,forced_failures=16800,memcpy_calls=0,free_calls=0,error_count=0),
        expected_checks=COUNTS,assembly=review,executed_locally=False,executed_remotely=True,
        sanitizer='not_run',large_allocation_and_size_t_extremes='static_only',
        production_object_uninstrumented=True,instrumentation_scope='Separate included-source candidate malloc/free/memcpy only; guard allocations remain real libc.',
        helper_entry_instrumentation=False,reference_only=version=='C44-copyinput',
        performance_measured=False,promotion_decision='none',evidence_directory='raw',issues=[],
        spill_is_correctness_failure=False,
        note='Production bitwise/readonly/guard checks and separate copy-path success/failure proof passed. No runner, benchmark, helper-entry evidence, speed conclusion or promotion; C6 remains current.')


if __name__=='__main__':
    if len(sys.argv)!=2 or sys.argv[1] not in VERSIONS:
        raise SystemExit('Usage: python3 .runs/conv/sep12h-checks/accept_returned.py C43-padinput|C44-copyinput')
    version=sys.argv[1]
    base=BASE/version
    try:
        require(not (base/'validation.json').exists(), 'Refusing to replace prior validation; retain earlier evidence')
        result=validate(base,version)
        with (base/'validation.json').open('x') as handle:
            json.dump(result,handle,indent=2)
            handle.write('\n')
    except Exception as exc:
        stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        failure=base/('acceptance-failure-'+stamp+'.json')
        failure.write_text(json.dumps(dict(status='acceptance_failed',complete=False,candidate=version,
            exception_type=type(exc).__name__,reason=str(exc),original_evidence_unchanged=True),indent=2)+'\n')
        raise SystemExit('Acceptance failed; original evidence retained: '+str(failure))
    print(json.dumps(dict(candidate=version,complete=True,total_cases=217176,runner_cases=0),indent=2))
