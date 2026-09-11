#!/usr/bin/env python3
"""Experiment-local TRSM cohort; run unmodified runners, preserve every byte."""
import json
import os
from pathlib import Path
import platform
import signal
import socket
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent
CONFIG = json.loads((ROOT / 'cohort-config.json').read_text())
FIXED = {'OMP_NUM_THREADS': '38', 'OMP_DYNAMIC': 'FALSE',
         'OMP_PROC_BIND': 'close', 'OMP_PLACES': 'cores', 'CPU_TARGET': 'generic'}


def cpus(value):
    result = set()
    for part in value.strip().split(','):
        if part:
            ends = part.split('-')
            result.update(range(int(ends[0]), int(ends[-1]) + 1))
    return result


def stamp():
    return time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())


def main():
    names = set(CONFIG['members'])
    if len(CONFIG['round_order']) != 3 or any(len(row) != len(names) or set(row) != names for row in CONFIG['round_order']):
        raise RuntimeError('Exactly three complete rounds with each member once are required')
    if platform.system() != 'Linux' or platform.machine() != 'aarch64':
        raise RuntimeError('Linux aarch64 compute node required')
    allowed = set(os.sched_getaffinity(0))
    if len(allowed) != 38:
        raise RuntimeError('Expected exactly 38 allocated CPUs')
    nodes = [p.parent.name[4:] for p in Path('/sys/devices/system/node').glob('node[0-9]*/cpulist')
             if allowed <= cpus(p.read_text())]
    if len(nodes) != 1:
        raise RuntimeError('Allocation must belong to exactly one NUMA node')
    identity = 'HOST={}\nARCH={}\nNUMA_NODE={}\nALLOWED_CPUS={}\nOMP_NUM_THREADS=38\nCPU_TARGET=generic\n'.format(
        socket.gethostname(), platform.machine(), nodes[0], ','.join(map(str, sorted(allowed))))
    machine = identity + 'UTC=' + stamp() + '\n' + platform.platform() + '\n'
    for cmd in [['lscpu'], ['numactl', '--show'], ['gcc', '--version'],
                ['/bin/bash', '-l', '-c', 'if type module >/dev/null 2>&1; then module list 2>&1; fi']]:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        machine += '\nCOMMAND ' + repr(cmd) + '\n' + result.stdout.decode('utf-8', 'replace')
    # Target-only SVE correctness and reference availability are checked before timing.
    probe_env = dict(os.environ, **FIXED, NUMA_NODE=nodes[0])
    with (ROOT / 'preflight.log').open('xb') as preflight_log:
        probe = subprocess.Popen(['/bin/bash', './run-preflight.sh'], cwd=str(ROOT / 'preflight'),
                                 env=probe_env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for data in iter(probe.stdout.readline, b''):
            preflight_log.write(data); preflight_log.flush()
            sys.stdout.buffer.write(data); sys.stdout.buffer.flush()
        code = probe.wait()
    if code:
        raise RuntimeError('Preflight failed; no benchmark members were started')
    handles, environments, completed = {}, {}, {}
    proc = None
    try:
        for name, member in CONFIG['members'].items():
            folder = ROOT / name
            settings = member['settings']
            env = {k: str(v) for k, v in settings['environment'].items()}
            if settings['bench_repeats'] != 3 or any(env.get(k) != v for k, v in FIXED.items()):
                raise RuntimeError('Invalid competition settings')
            if env.get('TEST_RUNS') != '3':
                raise RuntimeError('All members require TEST_RUNS=3')
            env.update(NUMA_NODE=nodes[0], BENCH_REPEATS='3')
            environments[name] = dict(os.environ, **env)
            lib = Path(env['KBLAS_LIB'])
            if not lib.is_file():
                raise RuntimeError('Configured reference library is missing')
            details = machine + json.dumps(settings, indent=2, sort_keys=True) + '\n'
            details += 'COHORT_ID=' + CONFIG['cohort_id'] + '\nVALIDATION_POLICY=no_hash_at_user_request\n'
            details += 'REFERENCE_LIBRARY=' + str(lib) + '\n'
            (folder / 'environment.log').write_text(details)
            logs = [(folder / 'benchmark.log').open('xb'), (folder / 'wrapper.stdout.log').open('xb')]
            handles[name] = logs
            completed[name] = 0
            for log in logs:
                log.write(('BENCH_JOB_BEGIN ' + stamp() + '\n' + details).encode())
                log.flush()
        # Alternate member order across the three complete rounds.
        for round_index, names in enumerate(CONFIG['round_order'], 1):
            for name in names:
                member = CONFIG['members'][name]
                folder = ROOT / name
                logs = handles[name]
                lib = Path(environments[name]['KBLAS_LIB'])
                marker = '\nBENCH_REPEAT {}/3 BEGIN COHORT={} MEMBER={}\n'.format(round_index, CONFIG['cohort_id'], name)
                sys.stdout.write(marker); sys.stdout.flush()
                for log in logs:
                    log.write(marker.encode()); log.flush()
                proc = subprocess.Popen(['/bin/bash', './run.sh'], cwd=str(folder / 'source'),
                                        env=environments[name], stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                        start_new_session=True)
                for data in iter(proc.stdout.readline, b''):
                    for log in logs:
                        log.write(data); log.flush()
                    sys.stdout.buffer.write(data); sys.stdout.buffer.flush()
                code = proc.wait()
                if code:
                    raise RuntimeError('Member {} round {} runner exit {}'.format(name, round_index, code))
                completed[name] += 1
                marker = 'BENCH_REPEAT {}/3 END\n'.format(round_index)
                for log in logs:
                    log.write(marker.encode()); log.flush()
        if any(value != 3 for value in completed.values()):
            raise RuntimeError('Incomplete cohort')
        for name, logs in handles.items():
            for log in logs:
                log.write(('BENCH_JOB_END ' + stamp() + '\n').encode())
                log.flush(); os.fsync(log.fileno())
                log.close()
            (ROOT / name / 'exit-code.txt').write_text('0\n')
        return 0
    except BaseException as exc:
        if proc is not None and proc.poll() is None:
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
        for name, logs in handles.items():
            for log in logs:
                if not log.closed:
                    log.write(('COHORT_INCOMPLETE ' + repr(exc) + '\n').encode())
                    log.flush(); os.fsync(log.fileno()); log.close()
            (ROOT / name / 'exit-code.txt').write_text('125\n')
        sys.stderr.write('COHORT FAILED: ' + repr(exc) + '\n')
        return 125


if __name__ == '__main__':
    sys.exit(main())
