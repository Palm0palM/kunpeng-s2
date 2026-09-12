#!/usr/bin/env python3
"""Target-side loader path check, without digest computation or verification."""
from pathlib import Path
import os,re,subprocess,sys
binary=Path(sys.argv[1]).resolve()
output=Path(sys.argv[2])
result=subprocess.run(['ldd',str(binary)],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
output.write_text(result.stdout)
print(result.stdout,end='')
if result.returncode or 'not found' in result.stdout:raise SystemExit('KML251_BLOCKED: unresolved dependency')
if 'openblas' in result.stdout.lower():raise SystemExit('KML251_BLOCKED: OpenBLAS dependency must not be mixed into KML validation')
expected=(Path(os.environ['KML251_LIBDIR'])/'libkblas.so.25.1.0').resolve()
match=re.search(r'^\s*libkblas\.so\.25\.1\.0\s+=>\s+(\S+)',result.stdout,re.M)
if not match or Path(match.group(1)).resolve()!=expected:
    raise SystemExit('KML251_BLOCKED: loader did not resolve the selected KML 25.1 library')
print('KML251_LINKED_LIBRARY='+str(expected))
print('KML251_DEPENDENCY_AUDIT_PASS=1')
