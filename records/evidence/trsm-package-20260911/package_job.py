#!/usr/bin/env python3
"""Submit/extract/run the exact TRSM ZIP on allocated CPUs, with no digest work."""
from pathlib import Path
import json,sys,shlex,shutil,tarfile,uuid,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
cfg=cluster.load_config(ROOT/'.runs/trsm/optimization-20260911-nohash/cluster.local.json')
meta_path=HERE/'submission.json'
if sys.argv[1:]==['prepare']:
    package=cluster.read_json(ROOT/'outputs/trsm-best.json')
    group='trsm-package-'+uuid.uuid4().hex[:12]
    settings=cluster.read_json(ROOT/'.runs/trsm/T3-control7/experiment.json')['settings']
    info={'state':'preparing','cohort_id':group,'job_id':None,'remote_dir':cfg['remote_root']+'/'+group,'source_version':package['version'],'settings':settings,'created_at':cluster.now(),'hash_validation':'not performed at user request'}
    with meta_path.open('x') as f:json.dump(info,f,indent=2)
    payload=HERE/'payload';payload.mkdir()
    shutil.copy2(ROOT/'outputs/trsm-best.zip',payload/'trsm.zip')
    shutil.copy2(HERE/'cohort_driver.py',payload/'cohort_driver.py')
    shutil.copytree(HERE/'preflight',payload/'preflight')
    config={'cohort_id':group,'members':{'trsm-package':{'settings':settings}},'round_order':[['trsm-package']]*3}
    cluster.write_json(payload/'cohort-config.json',config)
    (payload/'remote_job.sh').write_text('''#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir unpacked trsm-package
unzip -q trsm.zip -d unpacked
mv unpacked/trsm trsm-package/source
exec python3 ./cohort_driver.py
''')
    with tarfile.open(HERE/'payload.tar.gz','w:gz') as tar:
        for p in sorted(payload.iterdir()):tar.add(p,arcname=p.name)
    info['state']='prepared';cluster.write_json(meta_path,info)
    print('Prepared final ZIP verification',group)
elif sys.argv[1:]==['submit']:
    info=cluster.read_json(meta_path)
    if info['state']!='prepared':raise RuntimeError('Submission already attempted; do not repeat')
    cmd=shlex.join(['mkdir',info['remote_dir']])+' && '+shlex.join(['tar','-xzf','-','-C',info['remote_dir']])
    info.update(state='uploading',upload_command=cmd);cluster.write_json(meta_path,info)
    with (HERE/'payload.tar.gz').open('rb') as f:r=cluster.remote(cfg,cmd,stdin=f,timeout=cfg['transfer_timeout'])
    (HERE/'upload.log').write_text(cluster.output_text(r))
    if r.returncode:raise RuntimeError('Upload failed; no job submitted')
    cmd=cluster.submit_command(cfg,info['remote_dir'],info['cohort_id'])
    info.update(state='submit_unknown',submit_command=cmd);cluster.write_json(meta_path,info)
    r=cluster.remote(cfg,cmd);output=cluster.output_text(r);(HERE/'submit.log').write_text(output)
    ids=re.findall(cfg['scheduler']['job_id_pattern'],output)
    if r.returncode or len(set(ids))!=1:raise RuntimeError('Submission uncertain; inspect saved log, do not resubmit')
    info.update(state='submitted',job_id=ids[0],submitted_at=cluster.now());cluster.write_json(meta_path,info)
    print('Submitted final ZIP verification',ids[0])
elif sys.argv[1:]==['collect']:
    import experiment
    info=cluster.read_json(meta_path);r=cluster.remote(cfg,'djob -ll '+info['job_id'])
    (HERE/'scheduler-status.txt').write_bytes(r.stdout+r.stderr)
    if r.returncode or not experiment.scheduler_ok(cluster.output_text(r)):raise RuntimeError('Job has not succeeded')
    for remote,local in [('trsm-package/benchmark.log','benchmark.log'),('trsm-package/environment.log','environment.log'),('trsm-package/exit-code.txt','exit-code.txt'),('trsm-package/wrapper.stdout.log','wrapper.stdout.log'),('preflight.log','preflight.log'),('preflight/environment-probe.log','reference-environment.log')]:
        r=cluster.remote(cfg,'cat '+shlex.quote(info['remote_dir']+'/'+remote))
        if r.returncode:raise RuntimeError('Download failed: '+remote)
        (HERE/local).write_bytes(r.stdout)
    if (HERE/'exit-code.txt').read_text().strip()!='0':raise RuntimeError('Wrapper did not succeed')
    result=experiment.parse_log('trsm',(HERE/'benchmark.log').read_text(),3)
    result.update(job_id=info['job_id'],source_version=info['source_version'],package_extracted_and_tested=True,reference='OpenBLAS 0.3.28 static; not official KML revalidation',settings=info['settings'],recorded_at=cluster.now(),hash_validation=info['hash_validation'])
    cluster.write_json(HERE/'result.json',result)
    print(json.dumps(result,ensure_ascii=False,indent=2))
else:raise SystemExit('Use prepare, submit or collect')
