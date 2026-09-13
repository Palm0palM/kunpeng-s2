"""Adapted C13 diagnostic transport; local actions only transfer files/logs.

Run from the repository root. Do not submit until the current SSH host key has
been confirmed and its verified known_hosts configuration has been restored.
"""
import io
import json
import re
import shlex
import sys
import tarfile

sys.dont_write_bytecode = True
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster

if len(sys.argv) != 4 or sys.argv[1] not in ('C28-row4x6u1', 'C29-row4lane4', 'C30-colchunks') or sys.argv[3] not in ('submit', 'status', 'fetch'):
    raise SystemExit('Usage: python3 .runs/conv/sep12b-checks/driver.py VERSION VERIFIED_CONFIG submit|status|fetch')
version, config, action = sys.argv[1:]
expected_full_cases = {'C28-row4x6u1': 18052, 'C29-row4lane4': 20164, 'C30-colchunks': 21748}[version]
expected_checks = {'full_per_configuration': expected_full_cases, 'smoke_per_configuration': 96, 'configurations': 6, 'total': (expected_full_cases + 96) * 6}
base = Path(__file__).resolve().parent / version
cfg = cluster.load_config(config)
cfg['scheduler']['walltime_seconds'] = 1800
manifest = base / 'job.json'
if action == 'submit':
    if manifest.exists():
        raise SystemExit('Refusing repeat submission; inspect and reconcile existing job.json')
    remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep12b-' + version + '-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    data = {'version': version, 'remote_dir': remote_dir, 'submitted': False, 'expected_checks': expected_checks}
    manifest.write_text(json.dumps(data, indent=2) + '\n')
    archive = io.BytesIO()
    with tarfile.open(fileobj=archive, mode='w:gz') as target:
        for path in sorted((base / 'source').iterdir()):
            if not path.is_file(): raise SystemExit('Source directory must contain files only')
            target.add(path, arcname=path.name)
    command = 'umask 077; mkdir -p ' + shlex.quote(remote_dir) + ' && tar -xzf - -C ' + shlex.quote(remote_dir)
    result = cluster.remote(cfg, command, input=archive.getvalue())
    (base / 'upload.log').write_text(cluster.output_text(result))
    if result.returncode: raise SystemExit('Upload failed; inspect upload.log')
    command = cluster.submit_command(cfg, remote_dir, 'conv-sep12b-' + version)
    data.update(command=command, submit_attempted=True)
    manifest.write_text(json.dumps(data, indent=2) + '\n')
    result = cluster.remote(cfg, command)
    output = cluster.output_text(result)
    (base / 'submit.log').write_text(output)
    ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
    if result.returncode or not ids or len(set(ids)) != 1:
        raise SystemExit('Submission uncertain; inspect submit.log and scheduler, do not repeat')
    data.update(job_id=ids[0], submitted=True)
    manifest.write_text(json.dumps(data, indent=2) + '\n')
    print('JOB_ID=' + data['job_id'])
else:
    data = json.loads(manifest.read_text())
    job_id = data.get('job_id', '')
    if not re.fullmatch(r'[0-9]+', job_id): raise SystemExit('No confirmed job ID; reconcile submission first')
    if action == 'status':
        command = shlex.join(part.replace('{job_id}', job_id) for part in cfg['scheduler']['status_argv'])
        result = cluster.remote(cfg, command)
        output = cluster.output_text(result)
        (base / 'scheduler.log').write_text(output)
        data['scheduler_status'] = cluster.parse_scheduler_status(output, job_id) if result.returncode == 0 else None
        manifest.write_text(json.dumps(data, indent=2) + '\n')
        print(json.dumps(data['scheduler_status'], indent=2))
        if result.returncode: raise SystemExit('Status failed; inspect scheduler.log')
    else:
        result = cluster.remote(cfg, 'tar -czf - -C ' + shlex.quote(data['remote_dir']) + ' .', timeout=120)
        if result.returncode: raise SystemExit('Fetch failed')
        dest = base / 'raw'
        dest.mkdir(exist_ok=True)
        with tarfile.open(fileobj=io.BytesIO(result.stdout), mode='r:gz') as archive:
            for member in archive.getmembers():
                name = Path(member.name)
                if not member.isfile() or len(name.parts) != 1 or member.size > 16 * 1024 * 1024: continue
                if name.suffix not in ('.c', '.sh', '.log', '.txt', '.s', '.env'): continue
                (dest / name.name).write_bytes(archive.extractfile(member).read())
        print('Fetched diagnostic text/source/assembly. Apply README acceptance checks; fetching is not validation.')
