"""Read-only gates for the conditional T19 exact-ZIP package workflow."""
import importlib.util
import json
from pathlib import Path
import re
import sys
import zipfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKAGE = ROOT / '.runs/trsm/final-package-20260912-r16'
TARGET = 'T19-panel8x16budget'
SOURCES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h')
NAMES = ('README.md', 'bench_trsm.c', 'compat/kblas.h', 'run.sh', 'trsm.c')
MEMBERS = ['trsm/' + name for name in NAMES]
_records = None


def regular_bytes(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise RuntimeError('Required regular file is missing or symlinked: ' + str(path))
    return path.read_bytes()


def read_json(path):
    result = json.loads(regular_bytes(path))
    if not isinstance(result, dict):
        raise RuntimeError('Expected a JSON object: ' + str(path))
    return result


def records_module():
    global _records
    if _records is None:
        spec = importlib.util.spec_from_file_location(
            'private_package_records_kml', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
        _records = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(_records)
    return _records


def validated_record():
    if read_json(ROOT / 'records/best.json').get('trsm') != TARGET:
        raise RuntimeError('Packaging requires T19 to be the current promoted TRSM best')
    record = read_json(ROOT / 'records/experiments/trsm' / (TARGET + '.json'))
    if (record.get('problem') != 'trsm' or record.get('version') != TARGET
            or record.get('verified') is not True or record.get('status') != 'passed'
            or not isinstance(record.get('promoted_at'), str) or not record['promoted_at'].strip()):
        raise RuntimeError('Only the actually verified and promoted T19 version can be packaged')
    helper = records_module()
    reasons = helper.record_reasons(record)
    if reasons:
        raise RuntimeError('Promoted measurement evidence is invalid: ' + '; '.join(reasons))
    for name in SOURCES:
        if regular_bytes(ROOT / 'trsm' / name) != regular_bytes(helper.measured_source(record, name)):
            raise RuntimeError('Current source differs from the promoted measured snapshot: ' + name)
    return record


def zip_contents(path):
    regular_bytes(path)
    with zipfile.ZipFile(path) as archive:
        infos = archive.infolist()
        if [info.filename for info in infos] != MEMBERS:
            raise RuntimeError('ZIP must contain exactly the five ordered TRSM package files')
        result = {}
        for info in infos:
            mode = (info.external_attr >> 16) & 0o777
            if (info.is_dir() or info.flag_bits & 1
                    or mode != (0o755 if info.filename == 'trsm/run.sh' else 0o644)
                    or ((info.external_attr >> 16) & 0o170000) != 0o100000):
                raise RuntimeError('Unexpected ZIP member mode or encryption: ' + info.filename)
            result[info.filename] = archive.read(info)
        return result


def validate_private():
    record = validated_record()
    meta = read_json(PACKAGE / 'metadata.json')
    if (meta.get('problem') != 'trsm' or meta.get('version') != TARGET
            or meta.get('archive') != 'trsm.zip' or meta.get('official_kml252_revalidated') is not False
            or meta.get('source_record') != 'source-record.json'):
        raise RuntimeError('Invalid private package identity or reference declaration')
    if regular_bytes(PACKAGE / 'source-record.json') != regular_bytes(
            ROOT / 'records/experiments/trsm' / (TARGET + '.json')):
        raise RuntimeError('Promoted source record changed after the private package was built')
    archive_bytes = regular_bytes(PACKAGE / 'trsm.zip')
    if meta.get('archive_bytes') != len(archive_bytes):
        raise RuntimeError('Private ZIP byte length differs from its metadata')
    contents = zip_contents(PACKAGE / 'trsm.zip')
    expected_files = []
    for name in NAMES:
        member = 'trsm/' + name
        if contents[member] != regular_bytes(PACKAGE / 'trsm' / name):
            raise RuntimeError('Private ZIP differs from its immutable stage: ' + name)
        if name in SOURCES and contents[member] != regular_bytes(ROOT / 'trsm' / name):
            raise RuntimeError('Private ZIP source differs from current promoted source: ' + name)
        expected_files.append(dict(path=member, bytes=len(contents[member]),
                                   mode='0755' if name == 'run.sh' else '0644'))
    if meta.get('files') != expected_files:
        raise RuntimeError('Private package file inventory changed')
    validation = meta.get('source_validation', {})
    if (validation.get('job_id') != record['job_id'] or validation.get('suites') != 3
            or validation.get('test_runs') != 3 or validation.get('official_rows_passed') != 9
            or validation.get('case_median_ms') != [case['median_ms'] for case in record['cases']]
            or validation.get('total_median_ms') != record['total_median_ms']
            or validation.get('max_error') != max(case['max_error'] for case in record['cases'])
            or validation.get('reference') != record['reference']):
        raise RuntimeError('Private package metadata differs from actual source measurements')
    return meta


def audit_collected():
    meta = validate_private()
    group = read_json(HERE / 'submission.json')
    result = read_json(HERE / 'result.json')
    job = str(group.get('job_id', ''))
    if (group.get('state') != 'collected' or group.get('source_version') != TARGET
            or not re.fullmatch(r'\d+', job) or str(result.get('job_id')) != job
            or result.get('source_version') != TARGET):
        raise RuntimeError('Collected package run identity does not match the promoted target')
    helper = records_module()
    status = regular_bytes(HERE / 'scheduler-status.txt').decode()
    if not helper.scheduler_ok(status) or helper.scheduler_job_id(status) != job:
        raise RuntimeError('Final package scheduler has not succeeded for the recorded job')
    private_zip = regular_bytes(PACKAGE / 'trsm.zip')
    if (regular_bytes(HERE / 'payload/trsm.zip') != private_zip
            or regular_bytes(HERE / 'received-trsm.zip') != private_zip):
        raise RuntimeError('The uploaded/returned ZIP differs from the same private package bytes')
    contents = zip_contents(PACKAGE / 'trsm.zip')
    for name in NAMES:
        if regular_bytes(HERE / 'source' / name) != contents['trsm/' + name]:
            raise RuntimeError('Returned extracted package member changed: ' + name)
    zip_check = read_json(HERE / 'zip-validation.json')
    if (zip_check.get('schema') != 'trsm-private-zip-check-v1'
            or zip_check.get('source_version') != TARGET or str(zip_check.get('job_id')) != job
            or zip_check.get('archive_bytes') != len(private_zip)
            or zip_check.get('members') != MEMBERS
            or any(zip_check.get(key) is not True for key in
                   ('zip_unchanged', 'extracted_members_match_before', 'extracted_members_match_after'))):
        raise RuntimeError('Compute-node exact-ZIP extraction evidence is incomplete')
    wrapper = regular_bytes(HERE / 'wrapper.stdout.log').decode()
    if wrapper.splitlines().count('KML251_THREE_SUITES_COMPLETE=1') != 1:
        raise RuntimeError('Final package three-suite wrapper completion is missing or duplicated')
    if 'KML251_PROBE_COMPLETE=1' not in regular_bytes(HERE / 'probe.log').decode():
        raise RuntimeError('Real KML header and required-symbol probe did not complete')
    observed = helper.audit(HERE, dict(problem='trsm', version=TARGET))
    if observed['failures'] or not all(observed['checks'].values()) or observed['job_id'] != job:
        raise RuntimeError('Final package official/dependency audit failed: ' + '; '.join(observed['failures']))
    for key in ('cases', 'repeats', 'total_median_ms'):
        if result.get(key) != observed['measurements'][key]:
            raise RuntimeError('Saved package result differs from actual original logs: ' + key)
    return dict(metadata=meta, group=group, result=result, observed=observed, zip_check=zip_check)
