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
EXPECTED_NAMES = ['T19-control13-repeat-r21', 'T23-smallunroll2']
EXPECTED_VERSIONS = ['T19-control13', 'T23-smallunroll2']
PRIOR_JOB_ID = '1582239'
FIXED = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
             OMP_PLACES='cores', CPU_TARGET='generic', TEST_RUNS='3', KBLAS_LIB='', CC='gcc')


def exclusive_json(path, value):
    with path.open('x') as output:
        output.write(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def record_helpers():
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('r21_nohash_records', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    return helper


def prepare():
    if PREPARE_REVIEW_PENDING:
        raise RuntimeError('r21 preparation is blocked pending root independent review')
    plan = cluster.read_json(HERE / 'plan.json')
    if state_path.exists():
        raise RuntimeError('Cohort already prepared or attempted; preserve it')
    if ([item['run_name'] for item in plan['members']] != EXPECTED_NAMES
            or [item['version'] for item in plan['members']] != EXPECTED_VERSIONS
            or [item.get('parent') for item in plan['members']] != [None, 'T19-control13']
            or any(item.get('repeat_existing', False) is not (index == 0)
                   or (item.get('prior_job_id') != PRIOR_JOB_ID if index == 0 else item.get('prior_job_id') is not None)
                   for index, item in enumerate(plan['members']))):
        raise RuntimeError('The r21 protocol requires one unchanged baseline repeat and the new T23 member')
    declared = plan['measurement_protocol']
    if (declared['warmup_order'] != EXPECTED_NAMES or declared['warmup_suites_per_member'] != 1
            or declared['formal_round_order'] != [EXPECTED_NAMES[i:] + EXPECTED_NAMES[:i] for i in range(3)]
            or declared['formal_suites_per_member'] != 3 or declared['TEST_RUNS'] != 3
            or declared['formal_case_count'] != 18 or declared['warmup_case_count'] != 6
            or declared['sample_policy'] != 'Keep all three formal suites; no slow-sample exclusion'):
        raise RuntimeError('The r21 predeclared warm-up/formal protocol changed')
    helper = record_helpers()
    priors, prior_bytes, source_bytes = {}, {}, {}
    best = cluster.read_json(ROOT / 'records/best.json')['trsm']
    for item in plan['members']:
        for field in ('run_name', 'version', 'source_from'):
            if not re.fullmatch(r'[A-Za-z0-9_-]+', item[field]):
                raise RuntimeError('Invalid experiment identifier')
        if item.get('repeat_existing'):
            if item['source_from'] != item['version']:
                raise RuntimeError('Repeated members must keep their original implementation version')
            record_path = ROOT / 'records/experiments/trsm' / (item['version'] + '.json')
            prior_bytes[item['version']] = helper.regular_bytes(record_path)
            prior = json.loads(prior_bytes[item['version']])
            priors[item['version']] = prior
            if prior.get('job_id') != PRIOR_JOB_ID:
                raise RuntimeError('The r21 repeat must follow the registered r20 baseline repeat job 1582239')
            reasons = helper.record_reasons(prior)
            if reasons:
                raise RuntimeError('Invalid prior record: ' + '; '.join(reasons))
            if (prior.get('problem') != 'trsm' or prior.get('status') != 'passed'
                    or prior.get('verified') is not True or prior.get('official_kml252_revalidated') is not False):
                raise RuntimeError('Register the preceding successful measurement before preparing its repeat')
            for field in ('version', 'parent', 'strategy', 'source_implementation_id'):
                if field not in prior or item.get(field) != prior[field]:
                    raise RuntimeError('The r21 plan must preserve original implementation identity: ' + field)
            if item.get('parent') is None:
                if best != item['version'] or not prior.get('promoted_at'):
                    raise RuntimeError('The repeated baseline must remain the promoted current TRSM best')
            elif prior.get('promoted_at') is not None:
                raise RuntimeError('The repeated candidate must remain unpromoted')
            snapshot = (ROOT / prior['nohash_evidence']).resolve()
            snapshot.relative_to((ROOT / '.runs/trsm').resolve())
            original = ROOT / '.runs/trsm' / item['source_from'] / 'source'
            for name in ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h'):
                if (original / name).read_bytes() != (snapshot / 'source' / name).read_bytes():
                    raise RuntimeError('Repeat source differs from its prior measured snapshot: ' + name)
        if item.get('parent') and item['parent'] != best:
            raise RuntimeError('Candidate parent must already be the promoted current baseline')
        if item.get('parent'):
            parent = cluster.read_json(ROOT / 'records/experiments/trsm' / (item['parent'] + '.json'))
            if not parent.get('verified') or not parent.get('promoted_at') or parent.get('official_kml252_revalidated') is not False:
                raise RuntimeError('A measured KML baseline must be recorded and promoted before creating children')
        folder = ROOT / '.runs/trsm' / item['run_name']
        target_record = ROOT / 'records/experiments/trsm' / (item['version'] + '.json')
        if item.get('repeat_existing'):
            if folder.exists() or folder.is_symlink():
                raise RuntimeError('Repeat run directory already exists: ' + item['run_name'])
        else:
            if (folder.is_symlink() or any((folder / name).exists() or (folder / name).is_symlink()
                    for name in ('experiment.json', 'cluster.json', 'nohash-recorded-evidence', 'prior-record.json'))
                    or target_record.exists() or target_record.is_symlink()):
                raise RuntimeError('New candidate already has experiment, cluster or record evidence')
            if item['source_from'] != item['version'] or item['run_name'] != item['version']:
                raise RuntimeError('The new T23 member must use its prepared source directory')
        original = ROOT / '.runs/trsm' / item['source_from'] / 'source'
        source_bytes[item['version']] = {name: helper.regular_bytes(original / name) for name in SOURCES}
    group_id = 'trsm-kml251-' + uuid.uuid4().hex[:12]
    group = dict(state='preparing', cohort_id=group_id, remote_dir=cfg['remote_root'] + '/' + group_id,
                 created_at=cluster.now(), job_id=None, phase=plan['phase'],
                 validation_policy='No hash computation or validation at explicit user request')
    exclusive_json(state_path, group)
    payload = HERE / 'payload'
    payload.mkdir()
    config = dict(cohort_id=group_id, members={})
    for item in plan['members']:
        folder = ROOT / '.runs/trsm' / item['run_name']
        source = folder / 'source'
        folder.mkdir(exist_ok=True)
        original = ROOT / '.runs/trsm' / item['source_from'] / 'source'
        if not source.exists():
            source.mkdir()
            for name in SOURCES:
                destination = source / name
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(original / name, destination)
        if item.get('repeat_existing'):
            for name in SOURCES:
                if (source / name).read_bytes() != (original / name).read_bytes():
                    raise RuntimeError('Prepared repeat source differs from its original version: ' + name)
        if item.get('parent') is None and (source / 'trsm.c').read_bytes() != (ROOT / 'trsm/trsm.c').read_bytes():
            raise RuntimeError('An unmodified baseline must equal the current TRSM source')
        for name in ('bench_trsm.c', 'run.sh', 'compat/kblas.h'):
            if (source / name).read_bytes() != (ROOT / 'trsm' / name).read_bytes():
                raise RuntimeError('Official runner/benchmark/compat changed: ' + name)
        meta = dict(schema_version=1, problem='trsm', version=item['version'], parent=item.get('parent'),
                    source_from=item['source_from'], source_implementation_id=item['source_implementation_id'],
                    strategy=item['strategy'], created_at=cluster.now(), status='prepared', verified=False,
                    validation_policy=group['validation_policy'],
                    settings=dict(bench_repeats=3, environment=copy.deepcopy(FIXED)))
        if item.get('repeat_existing'):
            helper.preserve_repeat_identity(meta, priors[item['version']])
            meta.update(repeat_existing=True, prior_job_id=PRIOR_JOB_ID)
            helper.validate_repeat_existing(folder.resolve(), meta, priors[item['version']])
        settings = cluster.effective_settings(cfg, meta)
        meta['settings'] = settings
        exclusive_json(folder / 'experiment.json', meta)
        target = ROOT / 'records/experiments/trsm' / (item['version'] + '.json')
        if not item.get('repeat_existing'):
            exclusive_json(target, meta)
        config['members'][item['run_name']] = dict(settings=settings, version=item['version'],
                                                 repeat_existing=bool(item.get('repeat_existing')))
        for name in SOURCES:
            destination = payload / item['run_name'] / 'source' / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source / name, destination)
        manifest = dict(state='prepared', created_at=cluster.now(), host=cfg['host'], user=cfg['user'],
                        port=cfg['port'], remote_dir=group['remote_dir'] + '/' + item['run_name'],
                        settings=settings, job_id=None, cohort_id=group_id, problem='trsm', version=item['version'],
                        validation_policy=group['validation_policy'])
        exclusive_json(folder / 'cluster.json', manifest)
    names = list(config['members'])
    config['warmup_order'] = names.copy()
    config['warmup_suites_per_member'] = 1
    config['warmup_protocol'] = dict(
        protocol_id='trsm-r21-one-official-warmup-v1', declared_at=group['created_at'],
        declared_before_new_performance_data=True,
        purpose='One identical full official suite per member after full small-panel8x16 preflight, to apply the '
                'startup-warming protocol declared before viewing r21 measurements.',
        runner='./run.sh', TEST_RUNS='3', cases=[[512, 19968], [2432, 17024], [17024, 512]],
        excluded_from_comparison=True, formal_suites_per_member=3,
        formal_sample_policy='Keep all three formal suites; no slow-sample exclusion')
    config['round_order'] = [names[i:] + names[:i] for i in range(3)]
    exclusive_json(HERE / 'cohort-config.json', config)
    shutil.copy2(HERE / 'cohort-config.json', payload / 'cohort-config.json')
    for filename in ('cohort_driver.py', 'remote_job.sh'):
        shutil.copy2(HERE / filename, payload / filename)
    for directory in ('preflight-panel8x16', 'reference'):
        shutil.copytree(HERE / directory, payload / directory)
    with tarfile.open(HERE / 'payload.tar.gz', 'w:gz') as archive:
        for path in sorted(payload.iterdir()):
            archive.add(path, arcname=path.name)
    for item in plan['members']:
        record_path = ROOT / 'records/experiments/trsm' / (item['version'] + '.json')
        run = ROOT / '.runs/trsm' / item['run_name']
        if item.get('repeat_existing'):
            if helper.regular_bytes(record_path) != prior_bytes[item['version']]:
                raise RuntimeError('Prior record changed during preparation')
            helper.validate_repeat_existing(run.resolve(), cluster.read_json(run / 'experiment.json'),
                                            priors[item['version']])
        elif helper.regular_bytes(record_path) != helper.regular_bytes(run / 'experiment.json'):
            raise RuntimeError('New prepared candidate record changed during preparation')
        for name in SOURCES:
            expected = source_bytes[item['version']][name]
            if (helper.regular_bytes(payload / item['run_name'] / 'source' / name) != expected
                    or helper.regular_bytes(run / 'source' / name) != expected
                    or helper.regular_bytes(ROOT / '.runs/trsm' / item['source_from'] / 'source' / name) != expected):
                raise RuntimeError('Frozen source changed during preparation: ' + name)
    group['state'] = 'prepared'
    cluster.write_json(state_path, group)
    print('Prepared', plan['phase'], group_id, 'members=' + ','.join(names), 'without hashes')


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
