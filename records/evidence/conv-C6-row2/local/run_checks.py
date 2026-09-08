from pathlib import Path
import json, os, subprocess, shlex, hashlib
root=Path(__file__).resolve().parent
source=root.parent/'source/conv2d.c'
flags=['-O3','-g','-fno-fast-math','-ffp-contract=off','-Xpreprocessor','-fopenmp','-I/opt/homebrew/opt/libomp/include','-L/opt/homebrew/opt/libomp/lib','-Wl,-rpath,/opt/homebrew/opt/libomp/lib','-lomp']
checks=[
 ('ubsan','check_conv.c',['-fsanitize=undefined','-fno-sanitize-recover=all']),
 ('guard','check_conv_guard.c',[]),
 ('heights-ubsan','check_conv_heights.c',['-fsanitize=undefined','-fno-sanitize-recover=all']),
 ('heights-guard','check_conv_guard_heights.c',[]),
 ('fallback-b24','check_conv_guard_heights.c',['-fsanitize=undefined','-fno-sanitize-recover=all','-DCONV_BLOCK=24']),
 ('unroll1','check_conv_guard_heights.c',['-fsanitize=undefined','-fno-sanitize-recover=all','-DCONV_KERNEL_UNROLL=1']),
]
result={'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'compiler':subprocess.check_output(['clang','--version'],text=True),'checks':[]}
for name,harness,extra in checks:
 exe=root/('check_'+name)
 command=['clang',*flags,*extra,str(source),str(root/harness),'-o',str(exe)]
 compiled=subprocess.run(command,capture_output=True,text=True)
 (root/(name+'-build.log')).write_text(shlex.join(command)+'\n'+compiled.stdout+compiled.stderr)
 if compiled.returncode: raise SystemExit(compiled.stderr)
 for threads in [1,4]:
  env=dict(os.environ,OMP_NUM_THREADS=str(threads),OMP_DYNAMIC='FALSE')
  run=subprocess.run([str(exe)],env=env,capture_output=True,text=True)
  log=root/(name+f'-{threads}thread.log')
  log.write_text(f'OMP_NUM_THREADS={threads} OMP_DYNAMIC=FALSE '+shlex.join([str(exe)])+'\n'+run.stdout+run.stderr+f'EXIT_CODE={run.returncode}\n')
  result['checks'].append({'name':name,'threads':threads,'command':command,'harness_sha256':hashlib.sha256((root/harness).read_bytes()).hexdigest(),'exit_code':run.returncode,'result':run.stdout.strip(),'log':str(log)})
  print(name,threads,run.returncode,run.stdout.strip(),flush=True)
  if run.returncode: raise SystemExit(run.stderr)
(root/'results.json').write_text(json.dumps(result,indent=2)+'\n')
