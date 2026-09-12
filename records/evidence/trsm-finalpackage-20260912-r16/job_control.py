#!/usr/bin/env python3
"""Private T19 source ZIP verification controller; no digest operations."""
from pathlib import Path
import importlib.util
import json
import re
import shlex
import shutil
import sys
import tarfile
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PRIVATE = ROOT / '.runs/trsm/final-package-20260912-r16'
STATE = HERE / 'submission.json'
VERSION = 'T19-panel8x16budget'
SOURCES = ('README.md', 'bench_trsm.c', 'compat/kblas.h', 'run.sh', 'trsm.c')
SCRIPTS = ('remote_job.sh', 'run-three-suites.sh', 'probe.sh',
           'target-environment.sh', 'required-symbols.c', 'audit-dependencies.py')
sys.path.insert(0, str(ROOT / 'tools'))
import cluster
import experiment
from package_rules import validate_private


def config():
    return cluster.load_config(ROOT / '.runs/trsm/optimization-20260912-r16-compare/cluster.local.json')


def regular_bytes(path):
    if path.is_symlink() or not path.is_file():
        raise RuntimeError('Required regular file missing or symlinked: ' + str(path))
    return path.read_bytes()


def exclusive_json(path, value):
    with path.open('x') as handle:
        handle.write(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def private_snapshot():
    package = validate_private()
    raw_metadata = regular_bytes(PRIVATE / 'metadata.json')
    frozen_zip = regular_bytes(PRIVATE / 'trsm.zip')
    if (json.loads(raw_metadata) != package or package.get('problem') != 'trsm'
            or package.get('version') != VERSION or package.get('archive') != 'trsm.zip'
            or len(frozen_zip) != package.get('archive_bytes')):
        raise RuntimeError('Private package changed during validation')
    return package, raw_metadata, frozen_zip


def verify_payload(package, raw_metadata, frozen_zip):
    payload = HERE / 'payload'
    if (regular_bytes(payload / 'trsm.zip') != frozen_zip
            or regular_bytes(payload / 'package-metadata.json') != raw_metadata
            or regular_bytes(HERE / 'package-metadata.json') != raw_metadata):
        raise RuntimeError('Prepared payload differs from the current validated private ZIP/metadata')
    expected = ('trsm.zip', 'package-metadata.json') + SCRIPTS
    with tarfile.open(HERE / 'payload.tar.gz', 'r:gz') as archive:
        members = archive.getmembers()
        if sorted(item.name for item in members) != sorted(expected) or any(not item.isfile() for item in members):
            raise RuntimeError('Unexpected upload archive members')
        for name in expected:
            if archive.extractfile(name).read() != regular_bytes(payload / name):
                raise RuntimeError('Upload archive differs from frozen payload: ' + name)
    if (regular_bytes(PRIVATE / 'trsm.zip') != frozen_zip
            or regular_bytes(PRIVATE / 'metadata.json') != raw_metadata
            or validate_private() != package):
        raise RuntimeError('Private package changed while preparing upload')


def prepare():
    cfg = config()
    package, raw_metadata, frozen_zip = private_snapshot()
    group = 'trsm-kml251-package-r16-' + uuid.uuid4().hex[:12]
    info = dict(state='preparing', cohort_id=group, job_id=None,
                remote_dir=cfg['remote_root'] + '/' + group, source_version=VERSION,
                created_at=cluster.now(), archive_bytes=len(frozen_zip),
                private_archive=str(PRIVATE.relative_to(ROOT) / 'trsm.zip'),
                reference='KML 25.1.0; not specified KML 25.2.0',
                hash_validation='not performed at user request')
    exclusive_json(STATE, info)
    payload = HERE / 'payload'
    payload.mkdir()
    (payload / 'trsm.zip').write_bytes(frozen_zip)
    (payload / 'package-metadata.json').write_bytes(raw_metadata)
    with (HERE / 'package-metadata.json').open('xb') as handle:
        handle.write(raw_metadata)
    for name in SCRIPTS:
        shutil.copy2(HERE / name, payload / name)
    with tarfile.open(HERE / 'payload.tar.gz', 'x:gz') as archive:
        for path in sorted(payload.iterdir()):
            archive.add(path, arcname=path.name, recursive=False)
    verify_payload(package, raw_metadata, frozen_zip)
    info['state'] = 'prepared'
    cluster.write_json(STATE, info)
    print('Prepared private T19 package verification', group)


def known_job(info):
    job = info.get('job_id')
    if not isinstance(job, str) or not re.fullmatch(r'\d+', job):
        raise RuntimeError('Known scheduler job ID required; inspect submission response, never resubmit')
    return job


def confirm_job_identity(info):
    job = known_job(info)
    if info.get('state') not in ('submitted', 'collected'):
        raise RuntimeError('Only an already submitted known job may receive its identity marker')
    program = ('from pathlib import Path;import sys; p=Path(sys.argv[1]); value=sys.argv[2]+"\\n"; '
               'old=p.read_text() if p.exists() else None; '
               'assert old is None or old==value; '
               'p.write_text(value) if old is None else None')
    command = shlex.join(['python3', '-c', program, info['remote_dir'] + '/assigned-job-id.txt', job])
    result = cluster.remote(config(), command)
    (HERE / 'job-marker.log').write_text(cluster.output_text(result))
    if result.returncode:
        raise RuntimeError('Known job submitted but marker transfer failed; retry confirm-job only')
    info['identity_marker_sent_at'] = cluster.now()
    cluster.write_json(STATE, info)


def submit():
    # Exclusive persistent attempt file prevents two processes submitting the same prepared payload.
    with (HERE / 'submit-attempt.txt').open('x') as handle:
        handle.write(cluster.now() + '\n')
    info = cluster.read_json(STATE)
    if info.get('state') != 'prepared' or info.get('source_version') != VERSION:
        raise RuntimeError('Submission already attempted or wrong version; never resubmit')
    package, raw_metadata, frozen_zip = private_snapshot()
    verify_payload(package, raw_metadata, frozen_zip)
    cfg = config()
    command = shlex.join(['mkdir', info['remote_dir']]) + ' && ' + shlex.join(['tar', '-xzf', '-', '-C', info['remote_dir']])
    info.update(state='uploading', upload_command=command)
    cluster.write_json(STATE, info)
    with (HERE / 'payload.tar.gz').open('rb') as handle:
        result = cluster.remote(cfg, command, stdin=handle, timeout=cfg['transfer_timeout'])
    (HERE / 'upload.log').write_text(cluster.output_text(result))
    if result.returncode:
        raise RuntimeError('Upload failed; no scheduler submission attempted')
    command = cluster.submit_command(cfg, info['remote_dir'], info['cohort_id'])
    info.update(state='submit_unknown', submit_command=command, submission_started_at=cluster.now())
    cluster.write_json(STATE, info)
    result = cluster.remote(cfg, command)
    output = cluster.output_text(result)
    (HERE / 'submit.log').write_text(output)
    ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
    if result.returncode or len(set(ids)) != 1 or not re.fullmatch(r'\d+', ids[0]):
        raise RuntimeError('Submission uncertain; inspect saved response and never resubmit')
    info.update(state='submitted', job_id=ids[0], submitted_at=cluster.now())
    cluster.write_json(STATE, info)
    confirm_job_identity(info)
    print('Submitted private T19 package verification', info['job_id'])


def status():
    info = cluster.read_json(STATE)
    result = cluster.remote(config(), shlex.join(['djob', '-ll', known_job(info)]))
    (HERE / 'scheduler-status.txt').write_bytes(result.stdout + result.stderr)
    print(cluster.output_text(result))
    return result


def record_helpers():
    spec = importlib.util.spec_from_file_location('package_record_helpers', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def collect():
    info = cluster.read_json(STATE)
    job = known_job(info)
    scheduler = status()
    helpers = record_helpers()
    if (scheduler.returncode or not experiment.scheduler_ok(cluster.output_text(scheduler))
            or helpers.scheduler_job_id(cluster.output_text(scheduler)) != job):
        raise RuntimeError('Scheduler success and exact stored job ID are required before collection')
    cfg = config()
    artifacts = {name: 'results/' + name for name in (
        'benchmark.log', 'environment.log', 'exit-code.txt', 'runtime-settings.json',
        'linkage.log', 'probe.log', 'probe-ldd.log', 'benchmark-ldd-1.log',
        'benchmark-ldd-2.log', 'benchmark-ldd-3.log')}
    artifacts.update({name: name for name in ('wrapper.stdout.log', 'compiler-environment.log',
                      'omp-runtime-symbol.log', 'zip-validation.json')})
    artifacts['received-trsm.zip'] = 'trsm.zip'
    artifacts['received-package-metadata.json'] = 'package-metadata.json'
    artifacts.update({'source/' + name: 'unpacked/trsm/' + name for name in SOURCES})
    for destination, remote in artifacts.items():
        result = cluster.remote(cfg, shlex.join(['cat', info['remote_dir'] + '/' + remote]),
                                timeout=cfg['transfer_timeout'])
        if result.returncode:
            raise RuntimeError('Missing artifact: ' + remote)
        target = HERE / destination
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(result.stdout)
    if regular_bytes(HERE / 'exit-code.txt').strip() != b'0':
        raise RuntimeError('Package wrapper did not succeed')
    if (regular_bytes(HERE / 'wrapper.stdout.log').decode().splitlines().count(
            'KML251_THREE_SUITES_COMPLETE=1') != 1
            or 'KML251_PROBE_COMPLETE=1' not in regular_bytes(HERE / 'probe.log').decode()):
        raise RuntimeError('Three-suite wrapper completion or real KML probe completion is missing')
    package, raw_metadata, frozen_zip = private_snapshot()
    if (regular_bytes(HERE / 'received-trsm.zip') != frozen_zip
            or regular_bytes(HERE / 'payload/trsm.zip') != frozen_zip
            or regular_bytes(HERE / 'received-package-metadata.json') != raw_metadata
            or regular_bytes(HERE / 'package-metadata.json') != raw_metadata):
        raise RuntimeError('Returned ZIP/metadata differ from the frozen private package')
    import io
    import zipfile
    with zipfile.ZipFile(io.BytesIO(frozen_zip)) as archive:
        for name in SOURCES:
            if regular_bytes(HERE / 'source' / name) != archive.read('trsm/' + name):
                raise RuntimeError('Returned source differs from the actual ZIP member: ' + name)
    audit = cluster.read_json(HERE / 'zip-validation.json')
    required = dict(schema='trsm-private-zip-check-v1', source_version=VERSION, job_id=job,
                    archive_bytes=len(frozen_zip), zip_unchanged=True,
                    extracted_members_match_before=True, extracted_members_match_after=True,
                    members=['trsm/' + name for name in SOURCES])
    if any(audit.get(key) != value for key, value in required.items()):
        raise RuntimeError('Missing or invalid target ZIP/source byte validation')
    settings = cluster.read_json(HERE / 'runtime-settings.json')
    cluster.write_json(HERE / 'cluster.json', dict(problem='trsm', version=VERSION, job_id=job,
                       state='collected', remote_dir=info['remote_dir'], settings=settings))
    checked = helpers.audit(HERE, {'version': VERSION})
    if checked['failures']:
        raise RuntimeError('Package evidence audit failed: ' + '; '.join(checked['failures']))
    result = experiment.parse_log('trsm', (HERE / 'benchmark.log').read_text(), 3)
    result.update(job_id=job, source_version=VERSION, package_extracted_and_tested=True,
                  reference=info['reference'], recorded_at=cluster.now(),
                  archive_bytes=len(frozen_zip), official_rows_passed=9,
                  package_metadata=package, source_and_zip_byte_equality=True,
                  official_kml252_revalidated=False, hash_validation=info['hash_validation'])
    cluster.write_json(HERE / 'result.json', result)
    info.update(state='collected', collected_at=cluster.now())
    cluster.write_json(STATE, info)
    print(json.dumps(result, ensure_ascii=False, indent=2))


def main():
    actions = dict(prepare=prepare, submit=submit, status=status, collect=collect,
                   **{'confirm-job': lambda: confirm_job_identity(cluster.read_json(STATE))})
    if len(sys.argv) != 2 or sys.argv[1] not in actions:
        raise SystemExit('Use prepare, submit, confirm-job, status or collect')
    actions[sys.argv[1]]()


if __name__ == '__main__':
    main()
