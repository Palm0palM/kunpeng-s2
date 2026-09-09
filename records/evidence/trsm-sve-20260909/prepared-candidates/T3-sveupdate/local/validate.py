"""Standalone TRSM validation. No hashes, BLAS, ZGEMM or remote actions."""
import json
import os
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
os.chdir(HERE)
results=[]

def run(name,args,extra_env=None):
    env=os.environ.copy()
    env.update(extra_env or {})
    with (HERE/(name+'.log')).open('w') as stream:
        result=subprocess.run(args,stdout=stream,stderr=subprocess.STDOUT,env=env)
    results.append({'name':name,'argv':args,'cwd':str(HERE),'environment_overrides':extra_env or {},'returncode':result.returncode,'log':name+'.log'})
    (HERE/'commands-results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(name+': returncode='+str(result.returncode),flush=True)
    if result.returncode:
        sys.exit(result.returncode)

run('environment-uname',['uname','-sm'])
run('environment-clang',['clang','--version'])
run('environment-macos',['sw_vers'])
flags=['clang','-O2','-std=c11','-D_POSIX_C_SOURCE=200112L','-fno-fast-math','-ffp-contract=off','-fsanitize=undefined','-fno-sanitize-recover=undefined','-Xpreprocessor','-fopenmp','-I/opt/homebrew/opt/libomp/include']
link=['-L/opt/homebrew/opt/libomp/lib','-lomp','-lm']
run('build-check-update',flags+['check-update.c']+link+['-o','check-update-ubsan'])
run('build-check-trsm',flags+['check-trsm.c','../source/trsm.c']+link+['-o','check-trsm-ubsan'])
run('build-fail-alloc-object',flags+['-Dposix_memalign=trsm_test_alloc_fail','-c','../source/trsm.c','-o','trsm-fail-alloc.o'])
run('build-check-fail-alloc',flags+['check-trsm.c','fail-alloc.c','trsm-fail-alloc.o']+link+['-o','check-trsm-fail-alloc-ubsan'])
common={'OMP_DYNAMIC':'FALSE','OMP_PROC_BIND':'FALSE','UBSAN_OPTIONS':'halt_on_error=1:print_stacktrace=1'}
run('check-update', ['./check-update-ubsan'],common|{'OMP_NUM_THREADS':'4'})
for threads in ['1','4']:
    run('check-trsm-t'+threads,['./check-trsm-ubsan'],common|{'OMP_NUM_THREADS':threads})
run('check-trsm-fail-alloc-t4',['./check-trsm-fail-alloc-ubsan'],common|{'OMP_NUM_THREADS':'4'})
