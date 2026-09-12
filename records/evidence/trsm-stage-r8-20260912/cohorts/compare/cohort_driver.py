#!/usr/bin/env python3
"""Target-only, TRSM-only KML cohort; unchanged official runners and no digests."""
import json
import math
import os
from pathlib import Path
import platform
import re
import signal
import socket
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent
FIXED = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
             OMP_PLACES='cores', CPU_TARGET='generic', TEST_RUNS='3', KBLAS_LIB='', CC='gcc')
REFERENCE_KEYS = ('KML251_ROOT', 'KML251_ARCH', 'KML251_LIBDIR', 'COMPILER_ROOT',
                  'GOMP_LIBRARY', 'CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH', 'COMPILER_VERSION')
CASE_DIMS = [[512, 19968], [2432, 17024], [17024, 512]]


def stamp():
    return time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())


def cpus(value):
    result = set()
    for part in value.strip().split(','):
        if part:
            bounds = part.split('-')
            result.update(range(int(bounds[0]), int(bounds[-1]) + 1))
    return result


def assigned_identity():
    if platform.system() != 'Linux' or platform.machine() != 'aarch64':
        raise RuntimeError('Allocated Linux aarch64 compute node required')
    allowed = set(os.sched_getaffinity(0))
    if len(allowed) != 38:
        raise RuntimeError('Exactly 38 allocated CPUs required')
    nodes = [p.parent.name[4:] for p in Path('/sys/devices/system/node').glob('node[0-9]*/cpulist')
             if allowed <= cpus(p.read_text())]
    if len(nodes) != 1:
        raise RuntimeError('Single NUMA allocation required')
    # Controller persists the dsub response locally before sending this marker.
    # A missing marker must never trigger a duplicate submission or a test run.
    deadline = time.monotonic() + 180
    marker = ROOT / 'assigned-job-id.txt'
    while not marker.is_file() and time.monotonic() < deadline:
        time.sleep(1)
    job = marker.read_text().strip() if marker.is_file() else ''
    if not re.fullmatch(r'[0-9]+', job):
        raise RuntimeError('Confirmed scheduler job ID marker missing or invalid')
    return nodes[0], allowed, job


def stream(argv, cwd, env, outputs):
    process = subprocess.Popen(argv, cwd=cwd, env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, start_new_session=True)
    try:
        for data in iter(process.stdout.readline, b''):
            for output in outputs:
                output.write(data)
                output.flush()
            sys.stdout.buffer.write(data)
            sys.stdout.buffer.flush()
        return process.wait()
    except BaseException:
        # This process group contains only the current TRSM child.
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
        raise


def audit_linkage(folder, env, suite, job, warmup=False):
    binary = (folder / 'source/trsm_test').resolve()
    result = subprocess.run(['ldd', str(binary)], env=env, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True)
    output = result.stdout
    matches = {}
    for label, soname in [('kblas', 'libkblas.so.25.1.0'), ('gomp', 'libgomp.so.1')]:
        lines = re.findall(r'^\s*' + re.escape(soname) + r'\s+=>\s+(\S+)', output, re.M)
        matches[label] = Path(lines[0]).resolve() if len(lines) == 1 else None
    expected_kblas = (Path(env['KML251_LIBDIR']) / 'libkblas.so.25.1.0').resolve()
    expected_gomp = Path(env['GOMP_LIBRARY']).resolve()
    passed = (result.returncode == 0 and 'not found' not in output.lower()
              and 'openblas' not in output.lower() and matches['kblas'] == expected_kblas
              and matches['gomp'] == expected_gomp)
    filename = 'warmup-linkage.log' if warmup else 'linkage.log'
    marker = 'WARMUP_LINKAGE_REPEAT {}/1'.format(suite) if warmup else 'LINKAGE_REPEAT {}/3'.format(suite)
    with (folder / filename).open('x' if warmup else 'a') as log:
        log.write('{} BEGIN\nJOB_ID={}\nBINARY={}\nLDD_EXIT_CODE={}\n'.format(
            marker, job, binary, result.returncode))
        log.write(output + ('' if output.endswith('\n') else '\n'))
        log.write('KML251_LINKED_LIBRARY={}\nGOMP_LINKED_LIBRARY={}\n'.format(matches['kblas'], matches['gomp']))
        log.write('KML251_DEPENDENCY_AUDIT_PASS={}\n{} END\n'.format(int(passed), marker))
    if not passed:
        raise RuntimeError('Actual benchmark KML/OpenMP dependency check failed')
    return dict(passed=True, ldd_exit_code=result.returncode,
                kml251_linked_library=str(matches['kblas']), gomp_linked_library=str(matches['gomp']),
                log=filename)


def warmup_cases(text, node, allowed):
    """Audit the unchanged official runner's one full suite; retain all printed rows."""
    rows = re.findall(r'^\s*\d+\s*x\s*\d+[^\n]*$', text, re.M)
    parsed = [re.fullmatch(r'\s*(\d+)\s*x\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(PASS|FAIL)\s*',
                           line) for line in rows]
    if len(parsed) != 3 or any(row is None for row in parsed):
        raise RuntimeError('Warm-up must contain exactly three valid official case rows')
    results = []
    for row in parsed:
        m, n, elapsed, gflops, error, status = row.groups()
        values = list(map(float, (elapsed, gflops, error)))
        if (status != 'PASS' or not all(map(math.isfinite, values))
                or values[0] <= 0 or values[1] <= 0 or not 0 <= values[2] <= 1e-12):
            raise RuntimeError('Warm-up official case failed or violated original precision')
        results.append(dict(dims=[int(m), int(n)], time_ms=values[0], gflops=values[1],
                            max_error=values[2], status=status, raw_line=row.group(0)))
    if [case['dims'] for case in results] != CASE_DIMS:
        raise RuntimeError('Warm-up official cases missing, duplicated, or out of order')
    completions = re.findall(r'^All three official cases PASS\. Logs: (results/run-[^\s]+)$', text, re.M)
    resource_rows = re.findall(r'^CPUs=([0-9,-]+) NUMA=(\d+) threads=(\d+)$', text, re.M)
    if (len(completions) != 1 or re.search(r'\bFAIL(?:ED)?\b', text, re.I)
            or len(resource_rows) != 1 or cpus(resource_rows[0][0]) != allowed
            or resource_rows[0][1:] != (node, '38')
            or text.splitlines().count('Reference BLAS: official kblas') != 1
            or 'Reference BLAS override:' in text):
        raise RuntimeError('Warm-up completion, allocation, or default KML runner evidence invalid')
    return results, completions[0]


def run_warmup(folder, config, env, details, node, allowed, job):
    """Finish and persist this audit before any formal benchmark log is opened."""
    output = folder / 'warmup'
    output.mkdir()
    summary = dict(schema_version=1, cohort_id=config['cohort_id'], member=folder.name,
                   job_id=job, started_at=stamp(), protocol=config['warmup_protocol'],
                   warmup_suites_completed=0, passed=False, runner_exit_code=None,
                   environment=dict(env_values={key: env[key] for key in (*FIXED, *REFERENCE_KEYS)},
                                    NUMA_NODE=node, ALLOWED_CPUS=sorted(allowed)),
                   excluded_from_comparison=True, raw_log='warmup.log', linkage_log='warmup-linkage.log')
    with (folder / 'warmup.log').open('xb') as log:
        log.write(('WARMUP_REPEAT 1/1 BEGIN COHORT={} MEMBER={}\n'.format(config['cohort_id'], folder.name)
                   + 'WARMUP_EXCLUDED_FROM_COMPARISON=1\n' + details).encode())
        log.flush()
        try:
            code = stream(['/bin/bash', './run.sh'], folder / 'source', env, [log])
            summary['runner_exit_code'] = code
            if code:
                raise RuntimeError('{} warm-up runner exit {}'.format(folder.name, code))
            summary['cases'], summary['official_log_directory'] = warmup_cases(
                (folder / 'warmup.log').read_text(), node, allowed)
            summary['dependency_audit'] = audit_linkage(folder, env, 1, job, warmup=True)
            summary.update(passed=True, warmup_suites_completed=1, case_pass_count=3,
                           official_completion_markers=1)
            log.write(b'WARMUP_REPEAT 1/1 END\nWARMUP_COMPLETE=1\n')
        except BaseException as error:
            summary['error'] = repr(error)
            log.write(('WARMUP_INCOMPLETE ' + repr(error) + '\n').encode())
            raise
        finally:
            log.flush()
            os.fsync(log.fileno())
            summary['finished_at'] = stamp()
            with (output / 'summary.json').open('x') as audit:
                audit.write(json.dumps(summary, indent=2) + '\n')


def main():
    config = json.loads((ROOT / 'cohort-config.json').read_text())
    node, allowed, job = assigned_identity()
    names = list(config['members'])
    order = config['round_order']
    if (names != ['T8-control12-repeat-r8', 'T11-sve8x16']
            or order != [names, list(reversed(names)), names]):
        raise RuntimeError('The predeclared r8 protocol requires formal A/B, B/A, A/B rounds')
    protocol = config.get('warmup_protocol', {})
    if (config.get('warmup_order') != names or config.get('warmup_suites_per_member') != 1
            or protocol.get('protocol_id') != 'trsm-r8-one-official-warmup-v1'
            or not protocol.get('declared_at') or not protocol.get('purpose')
            or protocol.get('declared_before_new_performance_data') is not True
            or protocol.get('excluded_from_comparison') is not True
            or protocol.get('runner') != './run.sh' or protocol.get('TEST_RUNS') != '3'
            or protocol.get('cases') != CASE_DIMS or protocol.get('formal_suites_per_member') != 3
            or protocol.get('formal_sample_policy') != 'Keep all three formal suites; no slow-sample exclusion'):
        raise RuntimeError('Missing or changed predeclared one-suite-per-member warm-up protocol')
    runtime = {key: os.environ[key] for key in REFERENCE_KEYS}
    if '12.3.1' not in runtime['COMPILER_VERSION']:
        raise RuntimeError('GCC 12.3.1 required')
    env = dict(os.environ, **FIXED, NUMA_NODE=node, BENCH_REPEATS='3', TRSM_SCHEDULER_JOB_ID=job)
    identity = dict(HOST=socket.gethostname(), ARCH=platform.machine(), NUMA_NODE=node,
                    ALLOWED_CPUS=','.join(map(str, sorted(allowed))), JOB_ID=job, UTC=stamp())
    machine = ''.join('{}={}\n'.format(k, v) for k, v in dict(identity, **FIXED, **runtime).items())
    for argv in [['lscpu'], ['numactl', '--show'], ['gcc', '--version']]:
        result = subprocess.run(argv, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        machine += '\nCOMMAND ' + repr(argv) + '\n' + result.stdout
        if result.returncode:
            raise RuntimeError('Environment inspection failed: ' + repr(argv))
    (ROOT / 'environment.log').write_text(machine)
    # Compile actual KML header / required symbols once, before official timing.
    code = stream(['/bin/bash', str(ROOT / 'reference/probe.sh'), str(ROOT / names[0] / 'source'),
                   str(ROOT / 'reference-results')], ROOT, env, [])
    if code:
        raise RuntimeError('Real KML header/link/thread probe failed')
    with (ROOT / 'preflight.log').open('xb') as log:
        for name in names:
            code = stream(['/bin/bash', str(ROOT / 'preflight/run.sh'), str(ROOT / name / 'source'),
                           str(ROOT / 'preflight-results' / name)], ROOT, env, [log])
            if code:
                raise RuntimeError('Preflight failed for ' + name)
    # T11 changes a wide large-path kernel that the old 4097x9 boundary cannot enter.
    with (ROOT / 'preflight-wide.log').open('xb') as log:
        code = stream(['/bin/bash', str(ROOT / 'preflight-wide/run.sh'),
                       str(ROOT / 'T11-sve8x16/source'),
                       str(ROOT / 'preflight-wide-results/T11-sve8x16')], ROOT, env, [log])
        if code:
            raise RuntimeError('Wide-kernel and large-path supplemental preflight failed')
    completion = (ROOT / 'preflight-wide-results/T11-sve8x16/completion.txt').read_text()
    if 'TRSM_WIDE_PREFLIGHT_COMPLETE=1' not in completion:
        raise RuntimeError('Wide supplemental preflight completion missing')
    handles = {}
    try:
        member_details = {}
        for name in names:
            folder = ROOT / name
            settings = config['members'][name]['settings']
            if settings['bench_repeats'] != 3 or any(settings['environment'].get(k) != v for k, v in FIXED.items()):
                raise RuntimeError('Competition settings differ from required values')
            settings['environment'].update(runtime)
            (folder / 'runtime-settings.json').write_text(json.dumps(settings, indent=2) + '\n')
            details = machine + 'COHORT_ID=' + config['cohort_id'] + '\nVALIDATION_POLICY=no_hash_at_user_request\n'
            details += 'REFERENCE=Huawei KML 25.1.0; not specified KML 25.2.0\n'
            details += json.dumps(settings, indent=2, sort_keys=True) + '\n'
            (folder / 'environment.log').write_text(details)
            member_details[name] = details
        for name in config['warmup_order']:
            run_warmup(ROOT / name, config, env, member_details[name], node, allowed, job)
        # Formal logs are created only after every member's warm-up has passed.
        for name in names:
            folder, details = ROOT / name, member_details[name]
            logs = [(folder / filename).open('xb') for filename in ('benchmark.log', 'wrapper.stdout.log')]
            handles[name] = logs
            for log in logs:
                log.write(('BENCH_JOB_BEGIN ' + stamp() + '\n' + details).encode())
        for suite, row in enumerate(order, 1):
            for name in row:
                folder, logs = ROOT / name, handles[name]
                marker = '\nBENCH_REPEAT {}/3 BEGIN COHORT={} MEMBER={}\n'.format(suite, config['cohort_id'], name)
                for log in logs:
                    log.write(marker.encode())
                    log.flush()
                code = stream(['/bin/bash', './run.sh'], folder / 'source', env, logs)
                if code:
                    raise RuntimeError('{} suite {} runner exit {}'.format(name, suite, code))
                audit_linkage(folder, env, suite, job)
                for log in logs:
                    log.write(('BENCH_REPEAT {}/3 END\n'.format(suite)).encode())
                    log.flush()
        for name, logs in handles.items():
            for log in logs:
                log.write(('BENCH_JOB_END ' + stamp() + '\n').encode())
                log.flush()
                os.fsync(log.fileno())
                log.close()
            (ROOT / name / 'exit-code.txt').write_text('0\n')
    except BaseException as exc:
        for name, logs in handles.items():
            for log in logs:
                if not log.closed:
                    log.write(('COHORT_INCOMPLETE ' + repr(exc) + '\n').encode())
                    log.close()
            (ROOT / name / 'exit-code.txt').write_text('125\n')
        raise


if __name__ == '__main__':
    try:
        main()
    except BaseException as error:
        (ROOT / 'cohort-exit-code.txt').write_text('125\n')
        print('COHORT_FAILED:', repr(error), file=sys.stderr)
        sys.exit(125)
    (ROOT / 'cohort-exit-code.txt').write_text('0\n')
