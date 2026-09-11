#!/usr/bin/env python3
"""TRSM-only submission without digest computation or verification."""
from pathlib import Path
import json,shlex,shutil,sys,tarfile,uuid,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
NAMES=['T5-control10', 'T7-sve24rows', 'T7-diagpanel']
cfg=cluster.load_config(HERE/'cluster.local.json')
group_path=HERE/'cohort-submission.json'
if sys.argv[1:]==['prepare']:
    group_id='trsm-nohash-'+uuid.uuid4().hex[:12]
    remote_dir=cfg['remote_root']+'/'+group_id
    group=dict(state='preparing',cohort_id=group_id,remote_dir=remote_dir,created_at=cluster.now(),job_id=None,validation_policy='no hash computations or checks, as explicitly requested by user')
    with group_path.open('x') as f:json.dump(group,f,indent=2)
    payload=HERE/'payload';payload.mkdir()
    config={'cohort_id':group_id,'members':{},'round_order':[NAMES,NAMES[1:]+NAMES[:1],NAMES[2:]+NAMES[:2]]}
    for name in NAMES:
        folder=ROOT/'.runs/trsm'/name
        meta=cluster.read_json(folder/'experiment.json')
        settings=cluster.effective_settings(cfg,meta)
        assert settings['bench_repeats']==3 and settings['environment']['TEST_RUNS']=='3'
        assert settings['environment']['KBLAS_LIB'].endswith('/libopenblas.a')
        shutil.copytree(folder/'source',payload/name/'source')
        config['members'][name]={'settings':settings}
        manifest=dict(state='preparing',created_at=cluster.now(),host=cfg['host'],user=cfg['user'],port=cfg['port'],remote_dir=remote_dir+'/'+name,settings=settings,job_id=None,cohort_id=group_id,validation_policy=group['validation_policy'],cohort_round_order=config['round_order'])
        with (folder/'cluster.json').open('x') as f:json.dump(manifest,f,indent=2)
    assert all(m['settings']==config['members'][NAMES[0]]['settings'] for m in config['members'].values())
    cluster.write_json(HERE/'cohort-config.json',config)
    shutil.copy2(HERE/'cohort-config.json',payload/'cohort-config.json')
    shutil.copy2(HERE/'cohort_driver.py',payload/'cohort_driver.py')
    shutil.copytree(HERE/'preflight',payload/'preflight')
    (payload/'remote_job.sh').write_text('#!/usr/bin/env bash\nset -euo pipefail\ncd "$(dirname "$0")"\nexec python3 ./cohort_driver.py\n')
    with tarfile.open(HERE/'payload.tar.gz','w:gz') as tar:
        for p in sorted(payload.iterdir()):tar.add(p,arcname=p.name)
    group['state']='prepared';cluster.write_json(group_path,group)
    print('Prepared',group_id,'without hashes')
elif sys.argv[1:]==['submit']:
    group=cluster.read_json(group_path)
    if group['state']!='prepared':raise RuntimeError('Submission already attempted; do not repeat')
    cmd=shlex.join(['mkdir','-p',cfg['remote_root']])+' && '+shlex.join(['mkdir',group['remote_dir']])+' && '+shlex.join(['tar','-xzf','-','-C',group['remote_dir']])
    group.update(state='uploading',upload_command=cmd);cluster.write_json(group_path,group)
    with (HERE/'payload.tar.gz').open('rb') as f:r=cluster.remote(cfg,cmd,stdin=f,timeout=cfg['transfer_timeout'])
    (HERE/'upload.log').write_text(cluster.output_text(r))
    if r.returncode:raise RuntimeError('Upload failed; no job submitted')
    cmd=cluster.submit_command(cfg,group['remote_dir'],group['cohort_id'])
    group.update(state='submit_unknown',submit_command=cmd,submission_started_at=cluster.now());cluster.write_json(group_path,group)
    r=cluster.remote(cfg,cmd);output=cluster.output_text(r);(HERE/'submit.log').write_text(output)
    ids=re.findall(cfg['scheduler']['job_id_pattern'],output)
    if r.returncode or len(set(ids))!=1:raise RuntimeError('Uncertain submission; inspect log and never resubmit')
    group.update(state='submitted',job_id=ids[0],submitted_at=cluster.now());cluster.write_json(group_path,group)
    for name in NAMES:
        p=ROOT/'.runs/trsm'/name/'cluster.json';m=cluster.read_json(p)
        m.update(state='submitted',job_id=ids[0],submitted_at=group['submitted_at']);cluster.write_json(p,m)
    print('Submitted one no-hash TRSM job',ids[0])
else:raise SystemExit('Use prepare or submit')
