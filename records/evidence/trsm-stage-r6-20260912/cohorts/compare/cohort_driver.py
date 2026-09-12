#!/usr/bin/env python3
"""Target-only, TRSM-only KML cohort; unchanged official runners and no digests."""
import json
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
NUMERIC_COMPLETE = ('TRSM_T9_NUMERIC_COMPLETE=1 CASES=105 ELEMENTS=62853 SOLVES=210 '
                    'FINITE_NUMERIC_BITWISE=1 TOLERANCE=1e-12 PADDING_L_UNCHANGED=1')
NUMERIC_SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')


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


def audit_linkage(folder, env, suite, job):
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
    with (folder / 'linkage.log').open('a') as log:
        log.write('LINKAGE_REPEAT {}/3 BEGIN\nJOB_ID={}\nBINARY={}\nLDD_EXIT_CODE={}\n'.format(
            suite, job, binary, result.returncode))
        log.write(output + ('' if output.endswith('\n') else '\n'))
        log.write('KML251_LINKED_LIBRARY={}\nGOMP_LINKED_LIBRARY={}\n'.format(matches['kblas'], matches['gomp']))
        log.write('KML251_DEPENDENCY_AUDIT_PASS={}\nLINKAGE_REPEAT {}/3 END\n'.format(int(passed), suite))
    if not passed:
        raise RuntimeError('Actual benchmark KML/OpenMP dependency check failed')


def run_numerical_preflight(config, env):
    """T7 is a frozen numeric reference, separate from benchmark participants."""
    settings = config.get('numerical_preflight')
    expected = dict(candidate_version='T9-neondirect', reference_implementation='T7-diagpanel',
                    reference_source='numeric-reference/T7/source',
                    reference_snapshot_files=list(NUMERIC_SOURCE_FILES),
                    runner='preflight-t9/run.sh', output_dir='preflight-t9-results/T9-neondirect',
                    completion_marker=NUMERIC_COMPLETE)
    if not isinstance(settings, dict) or any(settings.get(key) != value for key, value in expected.items()):
        raise RuntimeError('Explicit T9-neondirect numerical preflight configuration is missing or invalid')
    candidate = settings.get('candidate_run')
    if (not isinstance(candidate, str) or not re.fullmatch(r'[A-Za-z0-9_-]+', candidate)
            or candidate not in config['members']
            or config['members'][candidate].get('version') != 'T9-neondirect'):
        raise RuntimeError('Numerical candidate must identify the T9-neondirect benchmark source')
    if 'numeric-reference' in config['members']:
        raise RuntimeError('The historical T7 numeric reference must not be a benchmark member')
    reference_source = ROOT / settings['reference_source']
    candidate_source = ROOT / candidate / 'source'
    runner = ROOT / settings['runner']
    for path in [reference_source / name for name in NUMERIC_SOURCE_FILES] + [candidate_source / 'trsm.c', runner]:
        if not path.is_file() or path.is_symlink():
            raise RuntimeError('Required numeric source snapshot or runner is missing: ' + str(path))
    output_dir = ROOT / settings['output_dir']
    if output_dir.exists() or output_dir.is_symlink():
        raise RuntimeError('Numerical preflight requires a fresh output directory; preserve earlier attempts')
    with (ROOT / 'preflight-t9.log').open('xb') as log:
        code = stream(['/bin/bash', str(runner), str(reference_source), str(candidate_source),
                       str(output_dir)], ROOT, env, [log])
    output_dir.mkdir(parents=True, exist_ok=True)

    def evidence_text(name):
        path = output_dir / name
        return path.read_text(errors='replace') if path.is_file() and not path.is_symlink() else None

    completion = evidence_text('completion.txt')
    numeric = evidence_text('numeric-t1.log') or ''
    markers = [line for line in numeric.splitlines() if line.startswith('TRSM_T9_NUMERIC_COMPLETE')]
    expected_mode = ('MODE=T7_T9_NUMERIC_COMPARE THREADS=1 JOB_ID={} TOLERANCE=1e-12 '
                     'PERFORMANCE_BASELINE=T8-svepanel16').format(env['TRSM_SCHEDULER_JOB_ID'])
    checks = dict(
        script_exit_zero=code == 0,
        recorded_exit_zero=evidence_text('exit-code.txt') == '0\n',
        one_complete_marker=completion == NUMERIC_COMPLETE + '\n',
        one_actual_numeric_marker=markers == [NUMERIC_COMPLETE],
        marker_verification_log=evidence_text('verify-summary.log') == NUMERIC_COMPLETE + '\n',
        complete_actual_case_rows=len(re.findall(r'^CASE_PASS ', numeric, re.M)) == 105,
        no_numeric_failures=not re.search(r'^(?:CASE_FAIL|FAIL|DIFFERENCE|PREFLIGHT_BLOCKED)\b', numeric, re.M),
        one_worker_and_job=numeric.splitlines().count(expected_mode) == 1)
    audit = dict(candidate_version='T9-neondirect', candidate_run=candidate,
                 numerical_reference='T7-diagpanel', job_id=env['TRSM_SCHEDULER_JOB_ID'],
                 purpose='Numerical equivalence only; not a performance baseline',
                 checks=checks, passed=all(checks.values()), script_exit_code=code,
                 expected_completion_marker=NUMERIC_COMPLETE,
                 validation_policy='No hash computation or validation', completed_at=stamp())
    with (output_dir / 'cohort-audit.json').open('x') as handle:
        handle.write(json.dumps(audit, indent=2) + '\n')
    if not audit['passed']:
        raise RuntimeError('T7/T9 numerical preflight failed: ' + ', '.join(key for key, value in checks.items() if not value))


def main():
    config = json.loads((ROOT / 'cohort-config.json').read_text())
    node, allowed, job = assigned_identity()
    names = list(config['members'])
    order = config['round_order']
    if len(order) != 3 or any(len(row) != len(names) or set(row) != set(names) for row in order):
        raise RuntimeError('Exactly three complete rounds required')
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
    # Numeric validation is an additional gate after every general preflight and
    # before creating or running any official benchmark member logs.
    run_numerical_preflight(config, env)
    handles = {}
    try:
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
