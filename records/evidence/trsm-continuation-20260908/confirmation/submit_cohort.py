#!/usr/bin/env python3
"""One guarded dsub submission using existing cluster transport and helpers."""
from pathlib import Path
import hashlib
import json
import shlex
import shutil
import sys
import tarfile
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster

cfg = cluster.load_config(ROOT / 'config/cluster.local.json')
group_path = HERE / 'cohort-submission.json'
members = ['T0-r3', 'T1-panel-r2']

if sys.argv[1:] == ['prepare']:
    group_id = 'trsm-cohort-' + uuid.uuid4().hex[:12]
    remote_dir = cfg['remote_root'] + '/' + group_id
    group = dict(state='preparing', cohort_id=group_id, remote_dir=remote_dir,
                 created_at=cluster.now(), job_id=None)
    with group_path.open('x') as f:
        json.dump(group, f, indent=2)
    payload = HERE / 'payload'
    payload.mkdir()
    driver = HERE / 'cohort_driver.py'
    driver_sha = hashlib.sha256(driver.read_bytes()).hexdigest()
    config = {'cohort_id': group_id, 'members': {},
              'reference_sha256': 'c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0',
              'round_order': [members, members[1:] + members[:1], members[2:] + members[:2]]}
    for name in members:
        folder = ROOT / '.runs/trsm' / name
        meta = cluster.read_json(folder / 'experiment.json')
        settings = cluster.effective_settings(cfg, meta)
        shutil.copytree(folder / 'source', payload / name / 'source', symlinks=True)
        hashes = cluster.source_hashes(payload / name / 'source')
        if hashes != cluster.source_hashes(folder / 'source'):
            raise RuntimeError('Source changed while freezing snapshot')
        config['members'][name] = {'settings': settings, 'source_hashes': hashes}
        manifest = dict(state='preparing', created_at=cluster.now(), host=cfg['host'], user=cfg['user'],
                        port=cfg['port'], remote_dir=remote_dir + '/' + name, settings=settings,
                        source_hashes=hashes, job_id=None, cohort_id=group_id,
                        cohort_driver_sha256=driver_sha, cohort_round_order=config['round_order'],
                        cohort_submission='One real scheduler job shared by all members; individual logs originate during each runner execution')
        with (folder / 'cluster.json').open('x') as f:
            json.dump(manifest, f, indent=2)
    if any(v['settings'] != config['members'][members[0]]['settings'] for v in config['members'].values()):
        raise RuntimeError('Cohort requires identical evaluation settings')
    shutil.copy2(driver, payload / driver.name)
    (HERE / 'cohort-config.json').write_text(json.dumps(config, indent=2) + '\n')
    shutil.copy2(HERE / 'cohort-config.json', payload / 'cohort-config.json')
    (payload / 'remote_job.sh').write_text('#!/usr/bin/env bash\nset -euo pipefail\ncd "$(dirname "$0")"\nexec python3 ./cohort_driver.py\n')
    with tarfile.open(HERE / 'payload.tar.gz', 'w:gz') as archive:
        for path in sorted(payload.iterdir()):
            archive.add(path, arcname=path.name)
    group.update(state='prepared', driver_sha256=driver_sha,
                 payload_sha256=hashlib.sha256((HERE / 'payload.tar.gz').read_bytes()).hexdigest())
    cluster.write_json(group_path, group)
    print('Prepared frozen cohort:', group_id)
elif sys.argv[1:] == ['submit']:
    group = cluster.read_json(group_path)
    if group['state'] != 'prepared':
        raise RuntimeError('Submission already attempted; do not repeat')
    if hashlib.sha256((HERE / 'payload.tar.gz').read_bytes()).hexdigest() != group['payload_sha256']:
        raise RuntimeError('Frozen upload changed')
    remote_dir = group['remote_dir']
    cmd = shlex.join(['mkdir', '-p', cfg['remote_root']]) + ' && ' + shlex.join(['mkdir', remote_dir]) + ' && ' + shlex.join(['tar', '-xzf', '-', '-C', remote_dir])
    group.update(state='uploading', upload_command=cmd)
    cluster.write_json(group_path, group)
    with (HERE / 'payload.tar.gz').open('rb') as f:
        result = cluster.remote(cfg, cmd, stdin=f, timeout=cfg['transfer_timeout'])
    (HERE / 'upload.log').write_text(cluster.output_text(result))
    if result.returncode:
        group.update(state='upload_failed')
        cluster.write_json(group_path, group)
        raise RuntimeError('Upload failed; no scheduler submission attempted')
    command = cluster.submit_command(cfg, remote_dir, group['cohort_id'])
    group.update(state='submit_unknown', submit_command=command, submission_started_at=cluster.now())
    cluster.write_json(group_path, group)
    for name in members:
        p = ROOT / '.runs/trsm' / name / 'cluster.json'
        manifest = cluster.read_json(p)
        manifest.update(state='submit_unknown', submit_command=command, submission_started_at=group['submission_started_at'])
        cluster.write_json(p, manifest)
    result = cluster.remote(cfg, command)
    output = cluster.output_text(result)
    (HERE / 'submit.log').write_text(output)
    import re
    ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
    if result.returncode or len(set(ids)) != 1:
        raise RuntimeError('Uncertain scheduler submission. Inspect saved log; never resubmit.')
    group.update(state='submitted', job_id=ids[0], submitted_at=cluster.now())
    cluster.write_json(group_path, group)
    for name in members:
        folder = ROOT / '.runs/trsm' / name
        manifest = cluster.read_json(folder / 'cluster.json')
        manifest.update(state='submitted', job_id=ids[0], submitted_at=group['submitted_at'])
        cluster.write_json(folder / 'cluster.json', manifest)
        (folder / 'submit.log').write_text(output)
        (folder / 'upload.log').write_text((HERE / 'upload.log').read_text())
    print('Submitted one cohort job', ids[0], 'members:', ', '.join(members))
else:
    raise SystemExit('Use prepare or submit')
