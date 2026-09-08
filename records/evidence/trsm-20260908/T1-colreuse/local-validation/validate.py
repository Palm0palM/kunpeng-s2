#!/usr/bin/env python3
"""Local UBSan validation only; all outputs stay inside this candidate."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import time

LOCAL = Path(__file__).resolve().parent
ROOT = LOCAL.parents[3]
SOURCE = LOCAL.parent / 'source/trsm.c'
RESULTS = []


def run(name, argv, overrides=None):
    env = os.environ.copy()
    env.update(overrides or {})
    command = ' '.join(shlex.quote(k + '=' + v) for k, v in (overrides or {}).items())
    command = (command + ' ' + shlex.join([str(a) for a in argv])).strip()
    start = datetime.datetime.now(datetime.timezone.utc).isoformat()
    before = time.monotonic()
    with (LOCAL / (name + '.log')).open('w') as output:
        output.write('Working directory: ' + str(ROOT) + '\n')
        output.write('Command: ' + command + '\nStarted UTC: ' + start + '\n')
        output.flush()
        result = subprocess.run(argv, cwd=ROOT, env=env, stdout=output, stderr=subprocess.STDOUT)
        elapsed = time.monotonic() - before
        end = datetime.datetime.now(datetime.timezone.utc).isoformat()
        output.write(f'\nExit code: {result.returncode}\nEnded UTC: {end}\nWall seconds: {elapsed:.6f}\n')
    entry = dict(name=name, command=command, cwd=str(ROOT), environment=overrides or {},
                 start_utc=start, end_utc=end, exit_code=result.returncode,
                 wall_seconds=elapsed, log=name + '.log')
    RESULTS.append(entry)
    (LOCAL / 'commands-results.json').write_text(json.dumps(RESULTS, indent=2) + '\n')
    print(f'{name}: exit {result.returncode}', flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)


run('environment-uname', ['uname', '-a'])
run('environment-macos', ['sw_vers'])
run('environment-clang', ['clang', '--version'])
run('environment-libomp', ['ls', '-l', '/opt/homebrew/opt/libomp', '/opt/homebrew/opt/libomp/lib/libomp.dylib'])
flags = ['clang', '-O2', '-fno-fast-math', '-ffp-contract=off',
         '-fsanitize=undefined', '-fno-sanitize-recover=undefined']
omp = ['-Xpreprocessor', '-fopenmp', '-I/opt/homebrew/opt/libomp/include']
link = ['-L/opt/homebrew/opt/libomp/lib', '-lomp']
run('build-check-final-ubsan', flags + omp + link + [str(LOCAL / 'check-final.c'),
    str(ROOT / 'zgemm/zgemm.c'), str(SOURCE), '-o', str(LOCAL / 'check-final-ubsan')])
run('build-check-packed-ubsan', flags + omp + link + [str(LOCAL / 'check-packed.c'),
    str(SOURCE), '-o', str(LOCAL / 'check-packed-ubsan')])
run('build-trsm-fail-alloc-object', flags + omp + ['-Dposix_memalign=trsm_test_alloc_fail',
    '-c', str(SOURCE), '-o', str(LOCAL / 'trsm-fail-alloc.o')])
run('build-check-packed-fail-alloc', flags + link + [str(LOCAL / 'check-packed.c'),
    str(LOCAL / 'fail-alloc.c'), str(LOCAL / 'trsm-fail-alloc.o'),
    '-o', str(LOCAL / 'check-packed-fail-alloc')])
for binary, threads, name in [
    ('check-final-ubsan', 1, 'check-final-t1'),
    ('check-final-ubsan', 4, 'check-final-t4'),
    ('check-packed-ubsan', 1, 'check-packed-t1'),
    ('check-packed-ubsan', 4, 'check-packed-t4'),
    ('check-packed-fail-alloc', 4, 'check-packed-fail-alloc-t4')]:
    run(name, [str(LOCAL / binary)], {'OMP_NUM_THREADS': str(threads),
        'OMP_DYNAMIC': 'FALSE', 'UBSAN_OPTIONS': 'halt_on_error=1:print_stacktrace=1'})
    text = (LOCAL / (name + '.log')).read_text()
    if 'PASS' not in text or 'FAIL' in text or 'runtime error:' in text:
        raise SystemExit('Missing PASS or detected validation failure: ' + name)

manifest = {str(p.relative_to(LOCAL)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(LOCAL.rglob('*')) if p.is_file() and p.name != 'validation-sha256.json'}
(LOCAL / 'validation-sha256.json').write_text(json.dumps(manifest, indent=2) + '\n')
print('All five local UBSan runs passed with exit code 0.', flush=True)
