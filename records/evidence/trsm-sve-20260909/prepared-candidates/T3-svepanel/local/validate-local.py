#!/usr/bin/env python3
"""TRSM-only local fallback checks; deliberately do not compute hashes."""
from pathlib import Path
import datetime
import json
import os
import shlex
import subprocess
import time

LOCAL=Path(__file__).resolve().parent
ROOT=LOCAL.parents[3]
SOURCE=LOCAL.parent/'source/trsm.c'
results=[]

def run(name, args, extra=None):
    env=os.environ.copy()
    env.update(extra or {})
    command=' '.join(shlex.quote(k+'='+v) for k,v in (extra or {}).items())
    command=(command+' '+shlex.join([str(a) for a in args])).strip()
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    before=time.monotonic()
    with (LOCAL/(name+'.log')).open('w') as log:
        log.write('Working directory: '+str(ROOT)+'\nCommand: '+command+'\nStarted UTC: '+start+'\n')
        log.flush()
        result=subprocess.run(args,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT)
        elapsed=time.monotonic()-before
        log.write(f'\nExit code: {result.returncode}\nWall seconds: {elapsed:.6f}\n')
    results.append(dict(name=name,command=command,cwd=str(ROOT),environment=extra or {},
        start_utc=start,end_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        exit_code=result.returncode,wall_seconds=elapsed,log=name+'.log'))
    (LOCAL/'commands-results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(name+': exit '+str(result.returncode),flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)

run('environment-uname',['uname','-a'])
run('environment-macos',['sw_vers'])
run('environment-clang',['clang','--version'])
run('environment-libomp',['ls','-l','/opt/homebrew/opt/libomp','/opt/homebrew/opt/libomp/lib/libomp.dylib'])
flags=['clang','-O2','-fno-fast-math','-ffp-contract=off','-fsanitize=undefined','-fno-sanitize-recover=undefined']
omp=['-Xpreprocessor','-fopenmp','-I/opt/homebrew/opt/libomp/include']
link=['-L/opt/homebrew/opt/libomp/lib','-lomp']
for name in ['check-trsm','check-packed']:
    run('build-'+name,flags+omp+link+[str(LOCAL/(name+'.c')),str(SOURCE),'-o',str(LOCAL/(name+'-ubsan'))])
run('build-fail-alloc-object',flags+omp+['-Dposix_memalign=trsm_test_alloc_fail','-c',str(SOURCE),'-o',str(LOCAL/'trsm-fail-alloc.o')])
for name in ['check-trsm','check-packed']:
    run('build-'+name+'-fail-alloc',flags+link+[str(LOCAL/(name+'.c')),str(LOCAL/'fail-alloc.c'),str(LOCAL/'trsm-fail-alloc.o'),'-o',str(LOCAL/(name+'-fail-alloc'))])
for name,threads,binary in [
    ('check-trsm-t1',1,'check-trsm-ubsan'),
    ('check-trsm-t4',4,'check-trsm-ubsan'),
    ('check-packed-t1',1,'check-packed-ubsan'),
    ('check-packed-t4',4,'check-packed-ubsan'),
    ('check-trsm-fail-alloc-t4',4,'check-trsm-fail-alloc'),
    ('check-packed-fail-alloc-t4',4,'check-packed-fail-alloc')]:
    run(name,[str(LOCAL/binary)],dict(OMP_NUM_THREADS=str(threads),OMP_DYNAMIC='FALSE',UBSAN_OPTIONS='halt_on_error=1:print_stacktrace=1'))
    output=(LOCAL/(name+'.log')).read_text()
    if 'PASS' not in output or 'FAIL' in output or 'runtime error:' in output:
        raise SystemExit('Validation output failed: '+name)
print('All six local TRSM-only fallback runs passed. SVE execution is not tested here.',flush=True)
