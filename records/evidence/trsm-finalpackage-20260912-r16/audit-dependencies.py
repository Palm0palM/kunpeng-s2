#!/usr/bin/env python3
"""Target loader audit with raw ldd and resolved KML/private-GOMP paths; no hashes."""
from pathlib import Path
import os
import re
import subprocess
import sys

if len(sys.argv) not in (3, 5):
    raise SystemExit('Use BINARY RAW_LDD_LOG [REPEAT LINKAGE_LOG]')
binary = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2])
result = subprocess.run(['ldd', str(binary)], stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT, text=True)
with output.open('x') as handle:
    handle.write(result.stdout)
print(result.stdout, end='')
expected = dict(kblas=(Path(os.environ['KML251_LIBDIR']) / 'libkblas.so.25.1.0').resolve(),
                gomp=Path(os.environ['GOMP_LIBRARY']).resolve())
loaded = {}
for key, soname in (('kblas', 'libkblas.so.25.1.0'), ('gomp', 'libgomp.so.1')):
    rows = re.findall(r'^\s*' + re.escape(soname) + r'\s+=>\s+(\S+)', result.stdout, re.M)
    loaded[key] = Path(rows[0]).resolve() if len(rows) == 1 else None
passed = (result.returncode == 0 and 'not found' not in result.stdout.lower()
          and 'openblas' not in result.stdout.lower() and loaded == expected)
fields = 'KML251_LINKED_LIBRARY={}\nGOMP_LINKED_LIBRARY={}\nKML251_DEPENDENCY_AUDIT_PASS={}\n'.format(
    loaded['kblas'], loaded['gomp'], int(passed))
print(fields, end='')
if len(sys.argv) == 5:
    repeat = sys.argv[3]
    if repeat not in ('1', '2', '3') or binary.name != 'trsm_test':
        raise SystemExit('Invalid official repeat or binary identity')
    job = os.environ['TRSM_SCHEDULER_JOB_ID']
    if not re.fullmatch(r'\d+', job):
        raise SystemExit('Confirmed scheduler job ID required')
    with Path(sys.argv[4]).open('x' if repeat == '1' else 'a') as handle:
        handle.write('LINKAGE_REPEAT {}/3 BEGIN\nJOB_ID={}\nBINARY={}\nLDD_EXIT_CODE={}\n'.format(
            repeat, job, binary, result.returncode))
        handle.write(result.stdout + ('' if result.stdout.endswith('\n') else '\n'))
        handle.write(fields + 'LINKAGE_REPEAT {}/3 END\n'.format(repeat))
if not passed:
    raise SystemExit('KML251_BLOCKED: actual KML/private-GOMP dependency audit failed')
