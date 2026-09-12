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

if len(sys.argv) != 4 or sys.argv[1] not in ('C40-row6x3u1','C41-row5x5u1','C42-row5x5asm') or sys.argv[3] not in ('submit', 'status', 'fetch', 'gate'):
    raise SystemExit('Usage: python3 .runs/conv/sep12g-checks/driver.py VERSION VERIFIED_CONFIG submit|status|fetch|gate')
version, config, action = sys.argv[1:]
full, dispatch, direct = {'C40-row6x3u1': (3560,432,360), 'C41-row5x5u1': (3776,504,288), 'C42-row5x5asm': (3776,504,288)}[version]
expected_checks = dict(full_per_configuration=full, dispatch_per_configuration=dispatch, direct_per_configuration=direct, configurations=6, total=(full+dispatch+direct)*6)
base = Path(__file__).resolve().parent / version
cfg = cluster.load_config(config)
cfg['scheduler'].update(cpus=38, memory_mb=24576, numa_count=1, numa_distribution='pack', walltime_seconds=1800)
manifest = base / 'job.json'

def check_f_gate():
    folder = ROOT / '.runs/conv'
    plan = json.loads((folder / 'sep12f-campaign.json').read_text())
    if plan.get('status') != 'performance_complete':
        raise SystemExit('F is not formally complete; wait, do not submit.')
    if plan.get('performance_job') != '1579528':
        raise SystemExit('Unexpected F job identity; stop for root.')
    order = ['C26-r10','C37-row4u1','C38-splitbuild','C39-tunehip11','C26-r11']
    if plan.get('measurement_order') != order:
        raise SystemExit('Unexpected F member order; stop for root.')
    rows = plan.get('results', [])
    if len(rows) != 5 or [r.get('version') for r in rows] != order:
        raise SystemExit('F results are incomplete; wait for root.')
    if any(r.get('qualified_for_confirmation') is not False for r in rows):
        raise SystemExit('F has a qualifier or undecided result; root must handle it first.')
    evidence = []
    for name in order:
        rec = json.loads((ROOT/'records/experiments/conv'/(name+'.json')).read_text())
        if rec.get('verified') is not True or rec.get('status') != 'passed' or rec.get('repeats') != 3 or rec.get('job_id') != '1579528':
            raise SystemExit('F real record not verified: '+name)
        if rec.get('qualified_for_confirmation') is not False:
            raise SystemExit('F record has qualifier or no decision: '+name)
        run = json.loads((folder/name/'cluster.json').read_text())
        status = run.get('scheduler_status') or {}
        if run.get('job_id') != '1579528' or status.get('jobId') != '1579528' or status.get('status') != 'SUCCEEDED' or status.get('jobExitCode') != 0 or status.get('systemExitCode') != 0:
            raise SystemExit('F formal scheduler/exit evidence not complete: '+name)
        evidence.append(dict(version=name, verified=True, job_id=rec['job_id'], qualified_for_confirmation=False))
    return dict(performance_job='1579528',status='performance_complete',records=evidence)

def check_serial_gate():
    if version == 'C40-row6x3u1':
        profile = ROOT/'.runs/diagnostics/conv-profile-sep12-r2'
        state = json.loads((profile/'job.json').read_text())
        validation = json.loads((profile/'validation.json').read_text())
        status = state.get('scheduler_status') or {}
        if not state.get('job_id') or status.get('jobId') != state['job_id'] or status.get('status') in (None,'PENDING','RUNNING'):
            raise SystemExit('Profile r2 has not terminated; keep serial order.')
        if validation.get('review_complete') is not True or validation.get('job_id') != state['job_id']:
            raise SystemExit('Profile r2 results have not been reviewed.')
    else:
        prior = {'C41-row5x5u1':'C40-row6x3u1','C42-row5x5asm':'C41-row5x5u1'}[version]
        validation = json.loads((ROOT/'.runs/conv'/prior/'sve-correctness-sep12g/validation.json').read_text())
        if validation.get('complete') is not True or validation.get('status') != 'passed':
            raise SystemExit('Previous G diagnostic has not passed: '+prior)
        status = validation.get('scheduler') or {}
        if status.get('status') != 'SUCCEEDED' or status.get('jobExitCode') != 0 or status.get('systemExitCode') != 0 or validation.get('exit_code') != 0:
            raise SystemExit('Previous G diagnostic scheduler/exit not complete: '+prior)

if action == 'gate':
    print(json.dumps(check_f_gate(),indent=2))
    raise SystemExit(0)

if action == 'submit':
    f_gate = check_f_gate()
    check_serial_gate()
    if manifest.exists():
        raise SystemExit('Refusing repeat submission; inspect and reconcile existing job.json')
    remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep12g-' + version + '-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    data = {'version': version, 'remote_dir': remote_dir, 'submitted': False, 'expected_checks': expected_checks, 'f_gate': f_gate}
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
    command = cluster.submit_command(cfg, remote_dir, 'conv-sep12g-' + version)
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
        if result.returncode:
            stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
            (base / ('status-failed-' + stamp + '.log')).write_text(output)
            raise SystemExit('Status failed; last successful state preserved; reuse the same job ID.')
        (base / 'scheduler.log').write_text(output)
        data['scheduler_status'] = cluster.parse_scheduler_status(output, job_id)
        manifest.write_text(json.dumps(data, indent=2) + '\n')
        print(json.dumps(data['scheduler_status'], indent=2))
    else:
        if (data.get('scheduler_status') or {}).get('status') in (None, 'PENDING', 'RUNNING'):
            raise SystemExit('Wait for a confirmed terminal scheduler state before fetch.')
        result = cluster.remote(cfg, 'tar -czf - -C ' + shlex.quote(data['remote_dir']) + ' .', timeout=120)
        if result.returncode: raise SystemExit('Fetch failed')
        dest = base / 'raw'
        dest.mkdir(exist_ok=True)
        with tarfile.open(fileobj=io.BytesIO(result.stdout), mode='r:gz') as archive:
            for member in archive.getmembers():
                name = Path(member.name)
                if not member.isfile() or len(name.parts) != 1 or member.size > 16 * 1024 * 1024: continue
                if name.suffix not in ('.c', '.sh', '.log', '.txt', '.s', '.env', '.md', '.json') and name.name != 'production-conv2d.o': continue
                (dest / name.name).write_bytes(archive.extractfile(member).read())
        print('Fetched diagnostic text/source/assembly. Apply README acceptance checks; fetching is not validation.')
