import io,json,re,shlex,sys,tarfile
from pathlib import Path
from datetime import datetime,timezone
sys.path.insert(0,str(Path.cwd()/'tools'))
import cluster
base=Path('.runs/conv/C8-sve128/sve-correctness')
cfg=cluster.load_config('config/cluster.local.json')
cfg['scheduler']['walltime_seconds']=300
manifest=base/'job.json'
action=sys.argv[1]
if action=='submit':
    if manifest.exists(): raise SystemExit('Refusing repeat submission')
    remote_dir=cfg['remote_root']+'/diagnostics/conv-sve128-correctness-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    data={'remote_dir':remote_dir,'submitted':False}
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    archive=io.BytesIO()
    with tarfile.open(fileobj=archive,mode='w:gz') as t:
        for p in sorted((base/'source').iterdir()): t.add(p,arcname=p.name)
    upload='umask 077; mkdir -p '+shlex.quote(remote_dir)+' && tar -xzf - -C '+shlex.quote(remote_dir)
    result=cluster.remote(cfg,upload,input=archive.getvalue())
    (base/'upload.log').write_text(cluster.output_text(result))
    if result.returncode: raise SystemExit('Upload failed; inspect upload.log')
    command=cluster.submit_command(cfg,remote_dir,'conv-sve128-correctness')
    data['command']=command
    data['submit_attempted']=True
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    result=cluster.remote(cfg,command)
    out=cluster.output_text(result)
    (base/'submit.log').write_text(out)
    ids=re.findall(cfg['scheduler']['job_id_pattern'],out)
    if result.returncode or not ids or len(set(ids))!=1: raise SystemExit('Submission uncertain; inspect submit.log, do not repeat')
    data.update(job_id=ids[0],submitted=True)
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    print('JOB_ID='+data['job_id'])
else:
    data=json.loads(manifest.read_text())
    if action=='status':
        command=shlex.join(x.replace('{job_id}',data['job_id']) for x in cfg['scheduler']['status_argv'])
        result=cluster.remote(cfg,command)
        out=cluster.output_text(result)
        (base/'scheduler.log').write_text(out)
        for line in out.splitlines():
            if any(s in line.upper() for s in ('JOB STATE','STATUS','EXIT CODE','SUCCEEDED','RUNNING','PENDING','FAILED')): print(line)
    elif action=='fetch':
        result=cluster.remote(cfg,'tar -czf - -C '+shlex.quote(data['remote_dir'])+' .',timeout=120)
        if result.returncode: raise SystemExit('Fetch failed')
        with tarfile.open(fileobj=io.BytesIO(result.stdout),mode='r:gz') as t:
            dest=base/'raw';dest.mkdir(exist_ok=True)
            for m in t.getmembers():
                if m.isfile():
                    name=Path(m.name)
                    if len(name.parts)!=1: continue
                    (dest/name.name).write_bytes(t.extractfile(m).read())
        print('Fetched diagnostics')
