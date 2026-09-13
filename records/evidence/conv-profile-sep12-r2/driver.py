"""Transport/status only. Never compiles or executes the operator locally."""
import io,json,re,shlex,sys,tarfile
from pathlib import Path
from datetime import datetime,timezone
sys.dont_write_bytecode=True
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
if len(sys.argv)<3 or sys.argv[2] not in ('submit','status','fetch'):
    raise SystemExit('Usage: python3 .runs/diagnostics/conv-profile-sep12-r2/driver.py CONFIG submit --go | CONFIG status | CONFIG fetch')
config,action=sys.argv[1:3]
if (action=='submit' and sys.argv[3:]!=['--go']) or (action!='submit' and len(sys.argv)!=3):
    raise SystemExit('Submit requires explicit --go after root authorization; status/fetch take no extra args')
cfg=cluster.load_config(config)
cfg['scheduler'].update(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
manifest=BASE/'job.json'
if action=='submit':
    if manifest.exists():raise SystemExit('Refusing duplicate submission. Reconcile existing job.json; use status/fetch.')
    remote_dir=cfg['remote_root']+'/diagnostics/conv-profile-sep12-r2-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    data=dict(kind='diagnostic_profile',source_version='C26-r1',formal_version='C6',profile_is_benchmark=False,complete=False,remote_dir=remote_dir,submitted=False,submit_attempted=False,resources=dict(cpus=38,memory_mb=24576,numa_count=1,walltime_seconds=1800))
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    archive=io.BytesIO()
    with tarfile.open(fileobj=archive,mode='w:gz') as target:
        for p in sorted((BASE/'source').iterdir()):
            if not p.is_file():raise SystemExit('Source must contain files only')
            target.add(p,arcname=p.name)
    command='umask 077; mkdir -p '+shlex.quote(remote_dir)+' && tar -xzf - -C '+shlex.quote(remote_dir)
    result=cluster.remote(cfg,command,input=archive.getvalue())
    (BASE/'upload.log').write_text(cluster.output_text(result))
    if result.returncode:raise SystemExit('Upload failed before submission; preserve state and reconcile before any retry')
    command=cluster.submit_command(cfg,remote_dir,'conv-profile-sep12-r2')
    data.update(command=command,submit_attempted=True)
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    result=cluster.remote(cfg,command)
    output=cluster.output_text(result);(BASE/'submit.log').write_text(output)
    ids=re.findall(cfg['scheduler']['job_id_pattern'],output)
    if result.returncode or not ids or len(set(ids))!=1:raise SystemExit('Submission uncertain. Preserve job.json/submit.log and reconcile scheduler; do not repeat')
    data.update(job_id=ids[0],submitted=True)
    manifest.write_text(json.dumps(data,indent=2)+'\n')
    print('JOB_ID='+data['job_id'])
else:
    data=json.loads(manifest.read_text());job_id=data.get('job_id','')
    if not re.fullmatch(r'[0-9]+',job_id):raise SystemExit('No confirmed ID; reconcile submission first')
    if action=='status':
        command=shlex.join(p.replace('{job_id}',job_id) for p in cfg['scheduler']['status_argv'])
        result=cluster.remote(cfg,command);output=cluster.output_text(result)
        if result.returncode:
            stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
            (BASE/('status-failed-'+stamp+'.log')).write_text(output)
            raise SystemExit('Status failed; last successful scheduler state preserved, retry same ID later')
        (BASE/'scheduler.log').write_text(output)
        data['scheduler_status']=cluster.parse_scheduler_status(output,job_id)
        manifest.write_text(json.dumps(data,indent=2)+'\n')
        print(json.dumps(data['scheduler_status'],indent=2))
    else:
        result=cluster.remote(cfg,'tar -czf - -C '+shlex.quote(data['remote_dir'])+' .',timeout=120)
        if result.returncode:raise SystemExit('Fetch failed; keep same job ID and retry fetch')
        dest=BASE/'raw';dest.mkdir(exist_ok=True);copied=[];skipped=[]
        with tarfile.open(fileobj=io.BytesIO(result.stdout),mode='r:gz') as archive:
            for member in archive.getmembers():
                name=Path(member.name)
                if not member.isfile() or len(name.parts)!=1 or name.name in ('.','..'):continue
                binary=name.name in ('conv2d_profile','perf.data')
                if not binary and name.suffix not in ('.c','.sh','.py','.log','.txt','.env','.json'):continue
                limit=512*1024*1024 if binary else 32*1024*1024
                if member.size>limit:skipped.append(dict(name=name.name,size=member.size,reason='retained remotely: exceeds bounded fetch limit'));continue
                (dest/name.name).write_bytes(archive.extractfile(member).read());copied.append(name.name)
        (BASE/'retrieval.json').write_text(json.dumps(dict(files=copied,skipped=skipped,complete=not skipped,validation_pending=True),indent=2)+'\n')
        print('Fetched raw artifacts; this is not validation. Check scheduler/exit/profile-status, source manifest, ELF identity and samples.')
