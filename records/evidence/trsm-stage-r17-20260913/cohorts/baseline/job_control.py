#!/usr/bin/env python3
"""TRSM-local KML experiment controller. No source digests or shared-tool changes."""
from pathlib import Path
import copy
import importlib.util
import json
import re
import shlex
import shutil
import subprocess
import sys
import tarfile
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster
import experiment

cfg = cluster.load_config(HERE / 'cluster.local.json')
state_path = HERE / 'cohort-submission.json'
SOURCES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
PREPARE_REVIEW_PENDING = False  # Root must finish independent review before setting False.
EXPECTED_NAMES = ['T19-control13']
EXPECTED_VERSIONS = ['T19-control13']
PRIOR_JOB_ID = '1579861'
FIXED = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
             OMP_PLACES='cores', CPU_TARGET='generic', TEST_RUNS='3', KBLAS_LIB='', CC='gcc')


def exclusive_json(path, value):
    with path.open('x') as output:
        output.write(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def record_helpers():
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('r17_baseline_nohash_records', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    return helper


def prepare():
    if PREPARE_REVIEW_PENDING:
        raise RuntimeError('Baseline controller is pending final review')
    plan = cluster.read_json(HERE / 'plan.json')
    if state_path.exists():
        raise RuntimeError('Preparation already attempted; preserve its state')
    members = plan['members']
    if (len(members) != 1 or members[0]['run_name'] != 'T19-control13'
            or members[0]['version'] != 'T19-control13' or members[0]['parent'] is not None
            or members[0]['source_from'] != 'T19-panel8x16budget'
            or members[0]['source_implementation_id'] != 'T19-panel8x16budget'
            or members[0].get('repeat_existing', False)):
        raise RuntimeError('Expected one unchanged new baseline measurement')
    item = members[0]
    declared = plan['measurement_protocol']
    if (declared['warmup_order'] != EXPECTED_NAMES or declared['warmup_suites_per_member'] != 1
            or declared['formal_round_order'] != [EXPECTED_NAMES.copy() for _ in range(3)]
            or declared['formal_suites_per_member'] != 3 or declared['TEST_RUNS'] != 3
            or declared['formal_case_count'] != 9 or declared['warmup_case_count'] != 3
            or declared['sample_policy'] != 'Keep all three formal suites; no slow-sample exclusion'):
        raise RuntimeError('Predeclared baseline protocol changed')
    helper = record_helpers()
    if cluster.read_json(ROOT / 'records/best.json')['trsm'] != item['source_from']:
        raise RuntimeError('The baseline source is no longer current best')
    prior_path = ROOT / 'records/experiments/trsm' / (item['source_from'] + '.json')
    prior_bytes = helper.regular_bytes(prior_path)
    prior = json.loads(prior_bytes)
    if (prior.get('job_id') != PRIOR_JOB_ID or prior.get('verified') is not True
            or not prior.get('promoted_at') or helper.record_reasons(prior)):
        raise RuntimeError('The T19 origin lacks its expected verified promotion')
    folder = ROOT / '.runs/trsm' / item['run_name']
    target = ROOT / 'records/experiments/trsm' / (item['version'] + '.json')
    if folder.exists() or folder.is_symlink() or target.exists() or target.is_symlink():
        raise RuntimeError('Baseline run or record already exists')
    source_bytes = {name: helper.regular_bytes(ROOT / 'trsm' / name) for name in SOURCES}
    import zipfile
    final = ROOT / '.runs/trsm/final-package-20260912-r16'
    with zipfile.ZipFile(final / 'trsm.zip') as archive:
        for name in SOURCES:
            if name != 'README.md' and (source_bytes[name] != helper.regular_bytes(helper.measured_source(prior, name))
                    or source_bytes[name] != archive.read('trsm/' + name)):
                raise RuntimeError('Task source differs from the verified T19 source/ZIP: ' + name)
    group_id = 'trsm-kml251-' + uuid.uuid4().hex[:12]
    group = dict(state='preparing', cohort_id=group_id, remote_dir=cfg['remote_root'] + '/' + group_id,
                 created_at=cluster.now(), job_id=None, phase=plan['phase'],
                 validation_policy='No hash computation or validation at explicit user request')
    exclusive_json(state_path, group)
    payload = HERE / 'payload'
    payload.mkdir()
    folder.mkdir()
    for name, data in source_bytes.items():
        for base in (folder / 'source', payload / item['run_name'] / 'source'):
            destination = base / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            with destination.open('xb') as handle:
                handle.write(data)
            destination.chmod(0o755 if name == 'run.sh' else 0o644)
    meta = dict(schema_version=1, problem='trsm', version=item['version'], parent=None,
                source_from=item['source_from'], source_implementation_id=item['source_implementation_id'],
                strategy=item['strategy'], created_at=cluster.now(), status='prepared', verified=False,
                validation_policy=group['validation_policy'],
                settings=dict(bench_repeats=3, environment=copy.deepcopy(FIXED)))
    meta['settings'] = cluster.effective_settings(cfg, meta)
    exclusive_json(folder / 'experiment.json', meta)
    exclusive_json(target, meta)
    with (HERE / 'origin-record.json').open('xb') as output:
        output.write(prior_bytes)
    origin = dict(source_version=item['source_from'], source_job_id=PRIOR_JOB_ID,
                  exact_zip_job_id='1581516', unchanged_task_files=list(SOURCES[:4]),
                  current_and_measured_and_verified_zip_task_bytes_equal=True,
                  README_origin='Current delivered trsm/README.md', fresh_preflight_executed=False,
                  historical_preflight='r16 job1579861; not new baseline test results')
    exclusive_json(HERE / 'source-origin.json', origin)
    config = dict(cohort_id=group_id, members={item['run_name']: dict(settings=meta['settings'],
                      version=item['version'], repeat_existing=False)},
                  warmup_order=EXPECTED_NAMES.copy(), warmup_suites_per_member=1,
                  round_order=[EXPECTED_NAMES.copy() for _ in range(3)])
    config['warmup_protocol'] = dict(
        protocol_id='trsm-r17-baseline-one-official-warmup-v1', declared_at=group['created_at'],
        declared_before_new_performance_data=True,
        purpose='One full official warmup before three independent unchanged-source baseline suites.',
        runner='./run.sh', TEST_RUNS='3', cases=[[512, 19968], [2432, 17024], [17024, 512]],
        excluded_from_comparison=True, formal_suites_per_member=3,
        formal_sample_policy='Keep all three formal suites; no slow-sample exclusion')
    exclusive_json(HERE / 'cohort-config.json', config)
    shutil.copy2(HERE / 'cohort-config.json', payload / 'cohort-config.json')
    for name in ('cohort_driver.py', 'remote_job.sh'):
        shutil.copy2(HERE / name, payload / name)
    shutil.copytree(HERE / 'reference', payload / 'reference')
    manifest = dict(state='prepared', created_at=cluster.now(), host=cfg['host'], user=cfg['user'],
                    port=cfg['port'], remote_dir=group['remote_dir'] + '/' + item['run_name'],
                    settings=meta['settings'], job_id=None, cohort_id=group_id,
                    problem='trsm', version=item['version'], validation_policy=group['validation_policy'])
    exclusive_json(folder / 'cluster.json', manifest)
    with tarfile.open(HERE / 'payload.tar.gz', 'x:gz') as archive:
        for path in sorted(payload.iterdir()):
            archive.add(path, arcname=path.name)
    if (helper.regular_bytes(prior_path) != prior_bytes
            or cluster.read_json(ROOT / 'records/best.json')['trsm'] != item['source_from']
            or helper.regular_bytes(target) != helper.regular_bytes(folder / 'experiment.json')):
        raise RuntimeError('Origin or prepared baseline record changed while freezing')
    for name, data in source_bytes.items():
        if any(helper.regular_bytes(base / name) != data for base in
               (ROOT / 'trsm', folder / 'source', payload / item['run_name'] / 'source')):
            raise RuntimeError('Frozen baseline source changed: ' + name)
    group['state'] = 'prepared'
    cluster.write_json(state_path, group)
    print('Prepared new unchanged T19 baseline', group_id, 'without hashes')

def known_job(group):
    job = group.get('job_id')
    if not isinstance(job, str) or not re.fullmatch(r'\d+', job):
        raise RuntimeError('Known numeric job ID required; inspect uncertain submission, never resubmit')
    return job


def confirm_job_identity(group):
    known_job(group)
    if group.get('state') not in ('submitted', 'collected'):
        raise RuntimeError('Only an already submitted known job may receive its marker')
    # Safe to retry only this marker transfer for an already known job ID.
    program = ('from pathlib import Path;import sys; p=Path(sys.argv[1]); value=sys.argv[2]+"\\n"; '
               'old=p.read_text() if p.exists() else None; '
               'assert old is None or old==value; '
               'p.write_text(value) if old is None else None')
    command = shlex.join(['python3', '-c', program, group['remote_dir'] + '/assigned-job-id.txt', group['job_id']])
    result = cluster.remote(cfg, command)
    (HERE / 'job-marker.log').write_text(cluster.output_text(result))
    if result.returncode:
        raise RuntimeError('Known job submitted but marker failed; use confirm-job, never submit again')
    group['identity_marker_sent_at'] = cluster.now()
    cluster.write_json(state_path, group)


def submit():
    with (HERE / 'submit-attempt.txt').open('x') as handle:
        handle.write(cluster.now() + '\n')
    group = cluster.read_json(state_path)
    if group['state'] != 'prepared':
        raise RuntimeError('Submission was already attempted; inspect the stored job ID')
    command = shlex.join(['mkdir', group['remote_dir']]) + ' && ' + shlex.join(['tar', '-xzf', '-', '-C', group['remote_dir']])
    group.update(state='uploading', upload_command=command)
    cluster.write_json(state_path, group)
    with (HERE / 'payload.tar.gz').open('rb') as data:
        result = cluster.remote(cfg, command, stdin=data, timeout=cfg['transfer_timeout'])
    (HERE / 'upload.log').write_text(cluster.output_text(result))
    if result.returncode:
        raise RuntimeError('Upload failed; no job submitted')
    command = cluster.submit_command(cfg, group['remote_dir'], group['cohort_id'])
    group.update(state='submit_unknown', submit_command=command, submission_started_at=cluster.now())
    cluster.write_json(state_path, group)
    result = cluster.remote(cfg, command)
    output = cluster.output_text(result)
    (HERE / 'submit.log').write_text(output)
    ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
    if result.returncode or len(set(ids)) != 1 or not re.fullmatch(r'\d+', ids[0]):
        raise RuntimeError('Uncertain submission; preserve response and never resubmit')
    group.update(state='submitted', job_id=ids[0], submitted_at=cluster.now())
    cluster.write_json(state_path, group)
    for name in cluster.read_json(HERE / 'cohort-config.json')['members']:
        path = ROOT / '.runs/trsm' / name / 'cluster.json'
        manifest = cluster.read_json(path)
        manifest.update(state='submitted', job_id=group['job_id'], submitted_at=group['submitted_at'])
        cluster.write_json(path, manifest)
    confirm_job_identity(group)
    print('Submitted job', group['job_id'])


def status():
    group = cluster.read_json(state_path)
    result = cluster.remote(cfg, 'djob -ll ' + known_job(group))
    (HERE / 'scheduler-status.txt').write_bytes(result.stdout + result.stderr)
    print(cluster.output_text(result))
    return result


def collect():
    group = cluster.read_json(state_path)
    config = cluster.read_json(HERE / 'cohort-config.json')
    scheduler = status()
    if (scheduler.returncode or not experiment.scheduler_ok(cluster.output_text(scheduler))
            or record_helpers().scheduler_job_id(cluster.output_text(scheduler)) != known_job(group)):
        raise RuntimeError('Job has not succeeded; no measurements registered')
    for name, member in config['members'].items():
        folder = ROOT / '.runs/trsm' / name
        (folder / 'scheduler-status.txt').write_bytes(scheduler.stdout + scheduler.stderr)
        for artifact in ('benchmark.log', 'environment.log', 'exit-code.txt', 'wrapper.stdout.log',
                         'linkage.log', 'runtime-settings.json', 'warmup.log', 'warmup-linkage.log',
                         'warmup/summary.json'):
            result = cluster.remote(cfg, 'cat ' + shlex.quote(group['remote_dir'] + '/' + name + '/' + artifact))
            if result.returncode:
                raise RuntimeError('Missing artifact: ' + name + '/' + artifact)
            destination = folder / artifact
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(result.stdout)
        warmup = cluster.read_json(folder / 'warmup/summary.json')
        if (warmup.get('passed') is not True or warmup.get('member') != name
                or warmup.get('job_id') != group['job_id']
                or warmup.get('cohort_id') != config['cohort_id']
                or warmup.get('warmup_suites_completed') != 1
                or warmup.get('protocol') != config['warmup_protocol']):
            raise RuntimeError('Missing or invalid completed warm-up evidence: ' + name)
        manifest = cluster.read_json(folder / 'cluster.json')
        manifest['settings'] = cluster.read_json(folder / 'runtime-settings.json')
        manifest['state'] = 'collected'
        cluster.write_json(folder / 'cluster.json', manifest)
    # Store all diagnostics as a remote-created archive. Never hash or execute it.
    script = 'import pathlib,tarfile,sys; root=pathlib.Path(sys.argv[1]); a=tarfile.open(fileobj=sys.stdout.buffer,mode="w|gz"); '\
             '[(a.add(p,arcname=str(p.relative_to(root)),recursive=False)) for p in sorted(root.rglob("*")) if p.is_file() and not p.is_symlink() and (p.suffix in (".log",".txt",".tsv",".json",".s") or p.name=="instrumented-trsm.c")]; a.close()'
    result = cluster.remote(cfg, shlex.join(['python3', '-c', script, group['remote_dir']]), timeout=cfg['transfer_timeout'])
    if result.returncode:
        raise RuntimeError('Diagnostic archive transfer failed')
    (HERE / 'diagnostics.tar.gz').write_bytes(result.stdout)
    group.update(state='collected', collected_at=cluster.now())
    cluster.write_json(state_path, group)
    print('Collected raw evidence; register explicitly with records-kml.py after inspecting diagnostics')


actions = dict(prepare=prepare, submit=submit, status=status, collect=collect,
               **{'confirm-job': lambda: confirm_job_identity(cluster.read_json(state_path))})
if len(sys.argv) != 2 or sys.argv[1] not in actions:
    raise SystemExit('Use prepare, submit, status, collect or confirm-job')
actions[sys.argv[1]]()
