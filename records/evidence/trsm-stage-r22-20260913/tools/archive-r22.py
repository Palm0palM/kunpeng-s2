#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Archive existing r22 evidence once; never execute or synthesize tests."""
from pathlib import Path
import datetime
import json
import re

ROOT = Path(__file__).resolve().parents[2]
RUNS = ROOT / '.runs/trsm'
DEST = ROOT / 'records/evidence/trsm-stage-r22-20260913'
COHORTS = {
    'compare': ('optimization-20260913-r22-compare', ['T19-control13-repeat-r22', 'T24-smallbroadcast']),
}
TEXT = {'.c', '.h', '.py', '.sh', '.md', '.json', '.txt', '.log', '.tsv', '.s'}
EXCLUDE = re.compile(r'cluster\.local|known[_-]?hosts|ssh|keychain|reconnect|askpass|auth|doctor|credential|password|private[-_]?key|(?:sha(?:1|256|512)|checksum|digest)', re.I)
SOURCES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')


def obj(path):
    return json.loads(path.read_text())


def redact(text):
    pairs = [('/LOCAL_USER_HOME', '/LOCAL_USER_HOME'),
             ('/CLUSTER_USER_HOME', '/CLUSTER_USER_HOME'),
             ('LOCAL_USER', 'LOCAL_USER'), ('REDACTED_USER', 'REDACTED_USER'),
             ('CLUSTER_HOST', 'CLUSTER_HOST'), ('COMPUTE_NODE', 'COMPUTE_NODE')]
    for old, new in pairs:
        text = text.replace(old, new)
    text = re.sub(r'/LOCAL_USER_HOME/\s\"\'<>:]+', '/LOCAL_USER_HOME', text)
    text = re.sub(r'/CLUSTER_USER_HOME:share/)?[^/\s\"\'<>:]+', '/CLUSTER_USER_HOME', text)
    text = re.sub(r'\blogin\d+\b', 'LOGIN_NODE', text)
    text = re.sub(r'\bcn\d+\b', 'COMPUTE_NODE', text)
    text = re.sub(r'(?im)^(\s*account\s+)\S+', r'\1CLUSTER_ACCOUNT', text)
    text = re.sub(r'"account"\s*:\s*"[^"]+"', '"account": "CLUSTER_ACCOUNT"', text)
    return text


def main():
    if DEST.exists() or DEST.is_symlink():
        raise RuntimeError('Archive exists; never rerun over it')
    selected = {}
    missing = []
    excluded = []

    def add(source, relative, required=False):
        if not source.is_file():
            if required:
                missing.append(str(source.relative_to(ROOT)))
            return
        if (source.is_symlink() or source.suffix not in TEXT or EXCLUDE.search(source.name)
                or any(part in ('__pycache__', 'compiler-private', '.git') for part in source.parts)):
            excluded.append(str(source.relative_to(ROOT)))
            return
        if relative in selected and selected[relative] != source:
            raise RuntimeError('Conflicting archive input')
        selected[relative] = source

    def tree(source, relative):
        for path in sorted(source.rglob('*')):
            if path.is_file():
                add(path, relative / path.relative_to(source))

    states = {}
    for label, (directory, members) in COHORTS.items():
        folder = RUNS / directory
        prefix = Path('cohorts') / label
        for path in sorted(folder.iterdir()):
            if path.is_file() and path.name != 'best-before-promotion.json':
                add(path, prefix / path.name)
        for name in ('reference', 'preflight-panel8x16', 'diagnostics'):
            if (folder / name).is_dir():
                tree(folder / name, prefix / name)
        for name in ('cohort-config.json', 'cohort-submission.json', 'result.json',
                     'actual-run-audit.json', 'finish-complete.json', 'ROOT-CONTROLLER-REVIEW.md',
                     'ROOT-RESULT-REVIEW.md', 'assembly-review.json'):
            add(folder / name, prefix / name, required=True)
        tree(folder / 'payload', prefix / 'submitted-payload')
        for member in members:
            for name in SOURCES:
                add(folder / 'payload' / member / 'source' / name,
                    prefix / 'submitted-payload' / member / 'source' / name, required=True)
            run = RUNS / member
            tree(run, Path('members') / member)
            for name in ('benchmark.log', 'environment.log', 'scheduler-status.txt', 'exit-code.txt', 'linkage.log'):
                add(run / name, Path('members') / member / name, required=True)
        states[label] = dict(submission=obj(folder / 'cohort-submission.json'),
                             result=obj(folder / 'result.json'))

    compare = RUNS / COHORTS['compare'][0]
    associations = {}
    previous = ROOT / 'records/evidence/trsm-stage-r21-20260913/records/latest'
    for version, member in zip(('T19-control13',), COHORTS['compare'][1][:1]):
        add(ROOT / 'records/experiments/trsm' / (version + '.json'),
            Path('records/latest') / (version + '.json'), required=True)
        prior_path = RUNS / member / 'prior-record.json'
        add(prior_path, Path('members') / member / 'prior-record.json', required=True)
        prior = obj(prior_path)
        previous_public = obj(previous / (version + '.json'))
        valid = (prior['version'] == version and prior['job_id'] == '1582392'
                 and json.loads(redact(json.dumps(prior))) == previous_public)
        if not valid:
            raise RuntimeError('Repeat prior differs from archived r21 record: ' + version)
        associations[version] = dict(valid=True, prior_job_id='1582392',
                                     prior_public_record=str((previous / (version + '.json')).relative_to(ROOT)))
    associated = all(x['valid'] for x in associations.values())
    add(ROOT / 'records/experiments/trsm/T24-smallbroadcast.json',
        Path('records/latest/T24-smallbroadcast.json'), required=True)
    for name in ('PREPARATION.md', 'VALIDATION-PLAN.md', 'STATIC-REVIEW.md'):
        add(RUNS / 'T24-smallbroadcast' / name, Path('members/T24-smallbroadcast') / name, required=True)
    for name in ('T19-control13-vs-T24-smallbroadcast.json',):
        add(compare / name, Path('cohorts/compare') / name, required=True)
    for member in COHORTS['compare'][1]:
        for name in ('summary.json', 'completion.txt', 'summary.tsv', 'commands.txt',
                     'guard.json', 'instrumented-trsm.c', 'trsm-panel8x16.s'):
            rel = Path('diagnostics/preflight-panel8x16-results') / member / name
            add(compare / rel, Path('cohorts/compare') / rel, required=True)
    for name in ('records-kml.py', 'records-kml-NOTES.md'):
        add(RUNS / 'nohash-tools' / name, Path('tools') / name, required=True)
    add(Path(__file__), Path('tools/archive-r22.py'), required=True)
    if missing:
        raise RuntimeError('Required evidence missing: ' + repr(missing))
    prepared = []
    credentials = re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{25,}|\bgithub_pat_[A-Za-z0-9_]{25,}')
    for relative, source in sorted(selected.items()):
        data = source.read_bytes()
        if b'\0' in data:
            raise RuntimeError('Binary input with text suffix')
        text = data.decode('utf-8', errors='replace')
        if credentials.search(text):
            raise RuntimeError('Credential-like material excluded')
        role = ('local_frozen_upload_input' if 'submitted-payload' in relative.parts else
                'collected_result_or_log' if 'diagnostics' in relative.parts else 'local_record_or_input')
        prepared.append((relative, redact(text), dict(path=str(relative), source=str(source.relative_to(ROOT)), role=role)))
    DEST.mkdir()
    inventory = []
    for relative, text, entry in prepared:
        target = DEST / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)
        entry['public_bytes'] = target.stat().st_size
        inventory.append(entry)
    manifest = dict(schema_version=1, stage='r22-20260913', problem='trsm',
                    created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    states=states, repeat_prior_association_valid=associated,
                    repeat_prior_associations=associations,
                    historical_T19_validation_job='1579861', fresh_small_path_preflight=True,
                    historical_samples_pooled=False, archive_creation_validates_measurements=False,
                    public_redacted_derivative=True, hash_operations=False, local_task_execution=False,
                    remote_source_identity_claim=False, transport_integrity_claim=False,
                    missing_required_evidence=[], excluded_files=excluded, files=inventory)
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(manifest, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text("""# TRSM r22 evidence

This redacted public derivative preserves the same-allocation comparison of
unchanged T19-control13 with new T24-smallbroadcast. Submitted inputs, source
snapshots, commands, actual environment, formal/warmup results, target assembly
and the full T19 repeat prior record are retained. The prior matches the archived
r20 record from job1582392; historical samples are never pooled.

Both members execute the complete dedicated small-panel8x16 preflight, with
raw steps, allocation and argument observations audited afresh. No historical
validation substitutes for this new small-kernel change. T19 is the promotion
parent. The large-path implementation remains the same as T19.

Archiving copies existing evidence only; it does not itself validate tests or
promote any candidate. No local task execution, hash operations or contest
submission. Actual reference is KML25.1/GCC12, not specified KML25.2. Private
originals remain local. Never reuse this destination in place.
""")
    print('Archived', len(inventory), 'r22 text files; prior association valid, required missing=0')


if __name__ == '__main__':
    main()
