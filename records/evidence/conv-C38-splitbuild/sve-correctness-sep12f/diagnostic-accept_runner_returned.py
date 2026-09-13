"""Validate returned text and metadata only; never runs operator code."""
import json
import re
import shlex
import sys
from pathlib import Path

version = sys.argv[1]
guard_count, dispatch_count, total = {
    'C38-splitbuild': (96, 0, 576),
    'C39-tunehip11': (7108, 96, 43224),
}[version]
base = Path(__file__).resolve().parent / version
raw = base / 'raw'
job = json.loads((base / 'job.json').read_text())
scheduler = job['scheduler_status']
assert scheduler['jobId'] == job['job_id']
assert scheduler['status'] == 'SUCCEEDED'
assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
assert (raw / 'exit-code.txt').read_text().strip() == '0'
assert job['expected_checks'] == dict(full_per_configuration=0 if dispatch_count == 0 else 7108,
    smoke_per_configuration=96, prefetch_probe_per_configuration=0,
    configurations=6, total=total, runner_cases=4)
probe = (raw / 'probe.log').read_text()
assert re.search(r'^PROBE_COMPLETE=1$', probe, re.M)
assert re.search(r'^DIAGNOSTIC_CHECKS=' + str(total) + r' RUNNER_CASES_SEPARATE=4$', probe, re.M)
assert 'SANITIZER_STATUS=NOT_RUN' in probe
expected = json.loads((base / 'source-hashes.json').read_text())
pairs = re.findall(r'^([0-9a-f]{64})  (\S+)$', (raw / 'source-sha256.txt').read_text(), re.M)
assert len(pairs) == len(expected) == 8
assert {name: digest for digest, name in pairs} == expected
stages = re.findall(r'^STAGE=(\S+) EXIT=(\d+)$', (raw / 'stage-exits.txt').read_text(), re.M)
assert stages and all(code == '0' for _, code in stages)
required = ['allocation', 'source-manifest', 'production-runner', 'production-object',
    'target-query', 'production-assembly', 'guard-compile', 'guard-link-production-object', 'complete']
required += [f'production-guard-vl{vl}-t{t}' for vl in (16, 32, 64) for t in (1, 4)]
if dispatch_count:
    required += ['dispatch-build'] + [f'dispatch-vl{vl}-t{t}' for vl in (16, 32, 64) for t in (1, 4)]
assert [name for name, _ in stages] == required[:8] + required[9:] + ['complete']

flags = ['-O3', '-std=c11', '-Wall', '-Wextra', '-fno-fast-math', '-ffp-contract=off',
    '-mcpu=generic', '-fopenmp', '-DCONV_BLOCK=32', '-DCONV_KERNEL_UNROLL=2']
tune = ['-mtune=hip11'] if dispatch_count else []
def commands(name):
    text = (raw / name).read_text()
    assert not re.search(r'\berror:', text, re.I)
    # set -x interleaves printf output in immutable runner logs. The executed
    # compiler argv has its own complete xtrace line; never execute log text.
    traced = re.findall(r'^\++ ((?:\S*/)?(?:gcc|clang|cc)(?:-[0-9.]+)?\s.+)$', text, re.M)
    assert traced, 'Missing actual executed compiler argv in xtrace'
    return [shlex.split(line) for line in traced]

cmds = commands('runner-build.log')
assert len(cmds) == 3
cc = cmds[0][0]
run_dir_match = re.fullmatch(r'RUNNER_RESULTS=(.+)\n?', (raw / 'runner-results.txt').read_text())
assert run_dir_match
run_dir = run_dir_match[1]
assert cmds == [
    [cc] + flags + ['-c', 'bench_conv.c', '-o', run_dir + '/bench_conv.o'],
    [cc] + flags + tune + ['-c', 'conv2d.c', '-o', run_dir + '/conv2d.o'],
    [cc] + flags + [run_dir + '/bench_conv.o', run_dir + '/conv2d.o', '-o', run_dir + '/conv2d_test', '-lm'],
]
environment = (raw / 'runner-environment.log').read_text()
assert '10.3.1' in environment
assert re.search(r'CPU target=generic$', environment, re.M)
assert re.search(r'^Block=32 Unroll=2 Threads=38 Bind=close Places=cores Node=\d+$', environment, re.M)
cases = []
for i, dims in enumerate(((4096,6144,39,39), (6144,4096,41,41), (4256,6390,55,55), (6390,4256,81,81)), 1):
    text = (raw / f'runner-case-{i}.log').read_text()
    rows = [line.split() for line in text.splitlines() if line.split() and line.split()[-1] in ('PASS', 'FAIL')]
    assert len(rows) == 1 and rows[0][-1] == 'PASS'
    numeric = re.findall(r'^\s*(\d+)\s+x\s*(\d+)\s+(\d+)\s+x\s*(\d+).*PASS\s*$', text, re.M)
    assert len(numeric) == 1 and tuple(map(int, numeric[0])) == dims
    cases.append(dict(case=i, dimensions=list(dims), passed=True))
assert re.search(r'^PASS cases: 4;', (raw / 'runner-summary.log').read_text(), re.M)
assert (raw / 'runner-status.txt').read_text().strip() == 'RUNNER_CASES=4 RUNNER_PASS=4 TIMINGS_NOT_PERFORMANCE_RECORD=1'
artifact_pairs = re.findall(r'^([0-9a-f]{64})  (\S+)$', (raw / 'production-artifacts-sha256.txt').read_text(), re.M)
artifacts = {name: digest for digest, name in artifact_pairs}
assert len(artifact_pairs) == len(artifacts) == 4
assert artifacts[run_dir + '/conv2d.o'] == artifacts['production-conv2d.o']
assert set(artifacts) == {run_dir + '/conv2d.o', run_dir + '/bench_conv.o', run_dir + '/conv2d_test', 'production-conv2d.o'}
disassembly = (raw / 'production-conv2d-objdump.log').read_text()
assert re.search(r'<conv_sve_rowquad>:', disassembly)
assert not re.search(r'\.inst|<unknown>', disassembly)
assert (raw / 'production-conv2d.o').is_file()
guard_cmds = commands('build-guard.log')
assert len(guard_cmds) == 2
remote = job['remote_dir']
guard_flags = flags + ['-D_DEFAULT_SOURCE', '-DEXPECTED_ACC=4', '-DCHECK_ROWTRIPLE=1', '-DCHECK_ROWQUAD=1']
assert guard_cmds == [
    [cc] + guard_flags + ['-c', 'check_conv_guard.c', '-o', remote + '/check_conv_guard.o'],
    [cc] + flags + [remote + '/check_conv_guard.o', run_dir + '/conv2d.o', '-o', remote + '/check_conv_guard', '-lm'],
]
assert commands('build-assembly.log') == [[cc] + flags + tune + ['-S', 'conv2d.c', '-o', 'conv2d-sve.s']]
assert commands('target-query.log') == [[cc] + flags + tune + ['-Q', '--help=target', '-c', '-x', 'c', '/dev/null', '-o', remote + '/target-query.o']]
query = (raw / 'target-query.log').read_text()
if tune:
    assert re.search(r'^\s*-mtune=\s+hip11\s*$', query, re.M)
    assert commands('build-dispatch.log') == [[cc] + guard_flags + tune + ['-finstrument-functions', 'check_sve_dispatch.c', '-o', 'check_sve_dispatch', '-lm']]
else:
    assert re.search(r'^\s*-mtune=\s+generic\s*$', query, re.M)

configs = []
for vl in (16, 32, 64):
    for t in (1, 4):
        header = f'SVE_BYTES={vl} SVE_LANES={vl//4} BLOCK_OUTPUTS={vl} THREADS={t}'
        entries = {}
        for kind, count in [('guard', guard_count)] + ([('dispatch', dispatch_count)] if dispatch_count else []):
            log = (raw / f'{kind}-vl{vl}-t{t}.log').read_text()
            assert len(re.findall('^' + re.escape(header) + '$', log, re.M)) == 1
            assert len(re.findall(r'^PASS: ' + str(count) + r' convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference$', log, re.M)) == 1
            assert not re.search(r'\bFAIL(?:ED)?\b', log)
            if kind == 'dispatch':
                for name in ('prefix', 'tail', 'rowpair', 'rowtriple', 'rowquad'):
                    values = re.findall('SVE_' + name.upper() + r'_ACTUAL_ENTRIES=(\d+)', log)
                    assert len(values) == 1
                    entries[name] = int(values[0])
                assert all(entries[name] > 0 for name in ('rowpair', 'rowtriple', 'rowquad'))
        configs.append(dict(sve_bytes=vl, threads=t, lanes=vl//4, block_outputs_per_row=vl,
            production_object_guard_cases=guard_count, dispatch_cases=dispatch_count, helper_entries=entries,
            production_object_tested=True, reference_untuned=True, passed=True))
assembly = json.loads((base / 'assembly-review.json').read_text())
assert assembly['review_complete'] is True
assert len(re.findall(r'^\s*(?:fmla|fmls|fmadd|fmsub|fnmadd|fnmsub)\b', (raw / 'conv2d-sve.s').read_text(), re.M)) == assembly['whole_source_fma_count'] == 0
assert assembly['production_object_reviewed'] is True
result = dict(status='passed', complete=True, candidate=version, job_id=job['job_id'], scheduler=scheduler,
    exit_code=0, source_hashes_verified=True, source_hashes=expected, source_manifest_remote_matches=True,
    source_hash_verification_scope='Existing automated transport manifest compared with remote wrapper SHA entries; no repeated manual byte-hash audit.',
    extra_manual_hash_audit=False, configurations=configs, production_object_guard_cases=guard_count*6,
    dispatch_cases=dispatch_count*6, total_cases=total, runner_cases=4, combined_validation_cases=total+4,
    runner=dict(passed=True,case_count=4,cases=cases,build_commands=cmds,production_object_tested=True,
        benchmark_flags_untuned=True,kernel_tune='hip11' if tune else None, timings_are_performance_record=False),
    stage_exits=[dict(stage=stage,exit_code=int(code)) for stage,code in stages],
    production_artifacts=artifacts, assembly=assembly, executed_locally=False, executed_remotely=True,
    sanitizer='not_run', issues=[], evidence_directory='raw')
if (raw / 'task-perf-probe.exit.txt').exists():
    perf_argv = shlex.split((raw / 'task-perf-probe-command.txt').read_text())
    assert perf_argv == ['perf','record','-e','cycles:u','-F','99','-m','128','-T','-P',
        '-o','task-perf-probe.data','--','/bin/true']
    perf_exit = int((raw / 'task-perf-probe.exit.txt').read_text())
    result['task_only_perf_probe'] = dict(command=perf_argv, exit_code=perf_exit,
        record_succeeded=perf_exit == 0, correctness_gate=False, operator_metric=False,
        stderr_file='raw/task-perf-probe.stderr.log',
        note='Own /bin/true child only; no CPU-wide selector, privilege or sysctl changes. Zero samples are allowed. This probes event-open/record support and cannot establish an operator hotspot.')
(base / 'validation.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(candidate=version,complete=True,total_cases=total,runner_cases=4,combined_validation_cases=total+4),indent=2))
