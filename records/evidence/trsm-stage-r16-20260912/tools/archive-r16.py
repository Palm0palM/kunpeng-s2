#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Create one public, redacted r16 evidence archive; never run tests or digests.

Run only after collecting the desired finished/failed evidence. This script
does not download, validate, record, promote, package, or publish experiments.
The destination is exclusive, and every original file remains untouched.
"""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
RUNS = ROOT / '.runs/trsm'
DEST = ROOT / 'records/evidence/trsm-stage-r16-20260912'
COHORTS = {
    'compare': RUNS / 'optimization-20260912-r16-compare',
}
VERSION_BY_MEMBER = {
    'T8-control12-repeat-r16': 'T8-control12',
    'T18-budgetwide-repeat-r16': 'T18-budgetwide',
    'T19-panel8x16budget': 'T19-panel8x16budget',
}
MEMBERS = tuple(VERSION_BY_MEMBER)
# Both repeated members retain their own successful r15 run, job1579788.
REPEAT_ORIGINS = {
    'T8-control12-repeat-r16': {
        'run': 'T8-control12-repeat-r15', 'archive': 'trsm-stage-r15-20260912', 'job_id': '1579788',
    },
    'T18-budgetwide-repeat-r16': {
        'run': 'T18-budgetwide-repeat-r15', 'archive': 'trsm-stage-r15-20260912', 'job_id': '1579788',
    },
}
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-panel.c', 'README.md')
WIDE_PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-wide32.c', 'README.md')
CANDIDATE_DOCUMENTS = ('PREPARATION.md', 'VALIDATION-PLAN.md', 'STATIC-REVIEW.md')
COMPARISON_FILES = ('T8-control12-vs-T18-budgetwide.json',
                    'T8-control12-vs-T19-panel8x16budget.json',
                    'T18-budgetwide-vs-T19-panel8x16budget.json')
SPECIAL_PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-panel.c', 'audit_panel8x16.py', 'README.md', 'PLAN.md')
TEXT_SUFFIXES = {'.c', '.h', '.py', '.sh', '.md', '.json', '.txt', '.log', '.tsv', '.s'}
COHORT_FILES = {
    'cohort_driver.py', 'remote_job.sh', 'job_control.py', 'preflight_audit.py', 'plan.json', 'actual-run-audit.json',
    'cohort-config.json', 'cohort-submission.json', 'assigned-job-id.txt',
    'PREPARATION.md', 'README.md', 'NOTES.md', 'STATIC-READINESS.md', 'finish-attempt.json', 'finish-complete.json',
    'prepare.log', 'submit.log', 'upload.log', 'job-marker.log', 'scheduler-status.txt',
    'latest-status.txt', 'pending-details.txt', 'collect.log', 'result.json',
    'scheduler-pending-during-preflight.txt', 'latest-wrapper-tail.log', 'scheduler-json-query.txt',
    'collect-before-scheduler-terminal.log', 'scheduler-finalization-NOTES.md',
    'scheduler-done-query.txt', 'scheduler-steps-query.txt', 'djob-help.txt',
    'failure.json', 'preflight.log', 'preflight-wide32.log', 'preflight-panel8x16.log', 'ROOT-CONTROLLER-REVIEW.md', 'RESULT-REVIEW.md', 'finish_records.py', 'environment.log', 'wrapper.stdout.log',
    'warmup.log', 'warmup-linkage.log',
    'cohort.stdout.log', 'cohort-exit-code.txt', 'compiler-environment.log',
    'omp-runtime-symbol.log', 'record-compare-commands.json', 'static-readiness.json',
    'prepared-repeat-readiness.json', 'continuation-state.json', 'finish.log', 'ARCHIVE-STATIC-REVIEW.md',
    'submit-controller.log',
}
MEMBER_FILES = {
    'experiment.json', 'cluster.json', 'record.json', 'prior-record.json',
    'repeat-attempt.json', 'PREPARATION.md', 'STATIC-REVIEW.md', 'VALIDATION-PLAN.md', 'README.md', 'NOTES.md',
    'benchmark.log', 'environment.log', 'wrapper.stdout.log', 'scheduler-status.txt',
    'latest-status.txt', 'exit-code.txt', 'linkage.log', 'runtime-settings.json',
    'result.json', 'failure.json', 'record.log', 'compare.json',
    'warmup.log', 'warmup-linkage.log',
}
FORBIDDEN = re.compile(
    r'cluster\.local|known[_-]?hosts|ssh[-_]?config|keychain|reconnect|askpass|auth|doctor|'
    r'credential|password|private[-_]?key|session[-_]?reuse|ssh[-_]?sep|'
    r'(?:sha(?:1|256|512)|checksum|digest)', re.I)
PRIVATE_MATERIAL = re.compile(
    r'-----BEGIN [A-Z ]*PRIVATE KEY-----|\bgh[pousr]_[A-Za-z0-9]{25,}|'
    r'\bgithub_pat_[A-Za-z0-9_]{25,}')


def read_object(path):
    if not path.is_file() or path.is_symlink():
        return None
    try:
        value = json.loads(path.read_text())
    except (OSError, UnicodeError, ValueError):
        return None
    return value if isinstance(value, dict) else None


def main():
    if DEST.exists() or DEST.is_symlink():
        raise SystemExit('Archive destination already exists; preserve it and do not rerun in place.')
    planned = {}
    omitted = []
    missing = []

    def add(source, relative, required=False):
        source, relative = Path(source), Path(relative)
        relsource = source.relative_to(ROOT)
        if source.is_symlink() or any(p in ('.git', '.ssh', '__pycache__', 'compiler-private') for p in relsource.parts):
            omitted.append({'source': str(relsource), 'reason': 'symlink or excluded directory'})
            return
        if FORBIDDEN.search(str(relsource)) or source.suffix.lower() not in TEXT_SUFFIXES:
            omitted.append({'source': str(relsource), 'reason': 'private, digest, binary, or non-text name'})
            return
        if not source.is_file():
            if required:
                missing.append(str(relsource))
            return
        if relative.is_absolute() or '..' in relative.parts:
            raise RuntimeError('Invalid archive-relative destination')
        if relative in planned and planned[relative] != source:
            raise RuntimeError('Conflicting source for ' + str(relative))
        planned[relative] = source

    def tree(source, relative):
        source, relative = Path(source), Path(relative)
        if not source.is_dir() or source.is_symlink():
            return
        for directory, dirs, files in os.walk(source, followlinks=False):
            dirs[:] = sorted(d for d in dirs if d not in ('.git', '.ssh', '__pycache__', 'compiler-private')
                             and not FORBIDDEN.search(d) and not (Path(directory) / d).is_symlink())
            for name in sorted(files):
                path = Path(directory) / name
                add(path, relative / path.relative_to(source))

    def assembly_reviews(folder, relative):
        # Reviews may be written beside a cohort/member or within diagnostics.
        # Route every discovered path through the same public-evidence filters.
        for path in sorted(Path(folder).glob('*')):
            if re.search(r'(?:assembly.*review|review.*assembly)', path.name, re.I):
                if path.is_dir():
                    tree(path, Path(relative) / path.name)
                else:
                    add(path, Path(relative) / path.name)

    for label, folder in COHORTS.items():
        prefix = Path('cohorts') / label
        for name in sorted(COHORT_FILES):
            add(folder / name, prefix / name, required=name in ('plan.json', 'cohort-config.json', 'cohort-submission.json',
                                 'prepared-repeat-readiness.json', 'ROOT-CONTROLLER-REVIEW.md', 'STATIC-READINESS.md',
                                 'preflight_audit.py'))
        # Comparison/registration outputs have member-derived names.
        for pattern in ('*-vs-*.json', '*-record.log', '*-compare.log', '*-promote.log', '*NOTES*.md', '*failure*.json', '*failure*.log'):
            for path in sorted(folder.glob(pattern)):
                add(path, prefix / path.name)
        for name in ('preflight', 'preflight-wide32', 'preflight-panel8x16', 'reference', 'warmup',
                     'preflight-results', 'preflight-wide32-results', 'preflight-panel8x16-results', 'reference-results',
                     'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        assembly_reviews(folder, prefix)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json', 'preflight_audit.py'):
            add(payload / name, prefix / 'submitted-payload' / name, required=True)
        for name in ('preflight', 'preflight-wide32', 'preflight-panel8x16', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for name in PREFLIGHT_FILES:
            add(folder / 'preflight' / name, prefix / 'preflight' / name, required=True)
            add(payload / 'preflight' / name,
                prefix / 'submitted-payload/preflight' / name, required=True)
        # r16 retained its review in top-level STATIC-READINESS and root controller review.
        add(folder / 'preflight/STATIC-REVIEW.md', prefix / 'preflight/STATIC-REVIEW.md')
        for name in WIDE_PREFLIGHT_FILES:
            add(folder / 'preflight-wide32' / name, prefix / 'preflight-wide32' / name, required=True)
            add(payload / 'preflight-wide32' / name,
                prefix / 'submitted-payload/preflight-wide32' / name, required=True)
        for name in SPECIAL_PREFLIGHT_FILES:
            add(folder / 'preflight-panel8x16' / name, prefix / 'preflight-panel8x16' / name, required=True)
            add(payload / 'preflight-panel8x16' / name,
                prefix / 'submitted-payload/preflight-panel8x16' / name, required=True)
        for name in COMPARISON_FILES:
            add(folder / name, prefix / name, required=True)
        # These are expected successful-collection locations. Other actually
        # retrieved partial/failed result trees above remain preserved as-is.
        for member in ('T8-control12-repeat-r16', 'T18-budgetwide-repeat-r16'):
            result_prefix = Path('diagnostics/preflight-results') / member
            for name in ('summary.json', 'budget-summary.json', 'completion.txt',
                         'summary.tsv', 'commands.txt', 'guard.json', 'trsm-panel16.s'):
                add(folder / result_prefix / name, prefix / result_prefix / name, required=True)
        for member in ('T18-budgetwide-repeat-r16', 'T19-panel8x16budget'):
            wide_result_prefix = Path('diagnostics/preflight-wide32-results') / member
            for name in ('summary.json', 'completion.txt', 'summary.tsv', 'commands.txt',
                         'guard.json', 'instrumented-trsm.c', 'trsm-wide4x32.s'):
                add(folder / wide_result_prefix / name, prefix / wide_result_prefix / name, required=True)
        special_result = Path('diagnostics/preflight-panel8x16-results/T19-panel8x16budget')
        for name in ('summary.json', 'budget-summary.json', 'panel8x16-summary.json', 'completion.txt',
                     'summary.tsv', 'commands.txt', 'guard.json', 'instrumented-trsm.c', 'trsm-panel8x16.s'):
            add(folder / special_result / name, prefix / special_result / name, required=True)
        for member in MEMBERS:
            for name in SOURCE_FILES:
                add(payload / member / 'source' / name,
                    prefix / 'submitted-payload' / member / 'source' / name, required=True)

    candidate_preparation_origins = []
    for member in MEMBERS:
        folder = RUNS / member
        prefix = Path('members') / member
        for name in sorted(MEMBER_FILES):
            add(folder / name, prefix / name,
                required=member == 'T19-panel8x16budget' and name in CANDIDATE_DOCUMENTS)
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'warmup', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
        assembly_reviews(folder, prefix)
        if member == 'T18-budgetwide-repeat-r16':
            # The original r14 candidate documents have an explicit historical
            # origin. Never substitute the repeat's preparation for them.
            for name in CANDIDATE_DOCUMENTS:
                preparation = RUNS / 'T18-budgetwide' / name
                destination = prefix / 'candidate-preparation' / name
                add(preparation, destination, required=True)
                candidate_preparation_origins.append({
                    'run': member, 'version': VERSION_BY_MEMBER[member],
                    'document': str(destination), 'source': str(preparation.relative_to(ROOT)),
                    'historical_candidate_run': 'T18-budgetwide',
                    'historical_public_archive': '../trsm-stage-r14-20260912/',
                    'note': 'Original r14 candidate preparation, validation plan or static review only; not evidence of this repeat run passing a gate.',
                })
        if member == 'T19-panel8x16budget':
            for name in CANDIDATE_DOCUMENTS:
                candidate_preparation_origins.append({
                    'run': member, 'version': member, 'document': str(prefix / name),
                    'source': str((folder / name).relative_to(ROOT)),
                    'note': 'New r16 candidate preparation/static material; not a runtime success claim.',
                })
    previous_records = {}
    for member in REPEAT_ORIGINS:
        prior = RUNS / member / 'prior-record.json'
        add(prior, Path('members') / member / 'prior-record.json', required=True)
        previous_records[member] = read_object(prior)
    for version in VERSION_BY_MEMBER.values():
        add(ROOT / 'records/experiments/trsm' / (version + '.json'), Path('records/latest') / (version + '.json'), required=True)
    add(RUNS / 'nohash-tools/records-kml.py', 'tools/records-kml.py', required=True)
    add(RUNS / 'nohash-tools/records-kml-NOTES.md', 'tools/records-kml-NOTES.md', required=True)
    add(Path(__file__).resolve(), 'tools/archive-r16.py', required=True)

    # Associate each prior with its own r15 repeat run and public record.
    prior_record_origins = []
    for member, origin in REPEAT_ORIGINS.items():
        prior_run = origin['run']
        history_name = origin['archive']
        history_archive = ROOT / 'records/evidence' / history_name
        expected_history_job = origin['job_id']
        public_prefix = '../' + history_name + '/'
        version = VERSION_BY_MEMBER[member]
        previous = previous_records[member] or {}
        history_cluster = read_object(history_archive / 'members' / prior_run / 'cluster.json') or {}
        history_record = read_object(history_archive / 'records/latest' / (version + '.json')) or {}
        history_job = str(history_cluster.get('job_id') or '')
        public_record_job = str(history_record.get('job_id') or '')
        prior_job = str(previous.get('job_id') or '')
        job_id_match = history_job == public_record_job == prior_job == expected_history_job
        version_match = previous.get('version') == history_record.get('version') == version
        prior_record_origins.append({
            'run': member, 'version': version,
            'record': 'members/' + member + '/prior-record.json',
            'prior_run': prior_run,
            'prior_public_archive': public_prefix,
            'prior_public_record': public_prefix + 'records/latest/' + version + '.json',
            'prior_run_cluster': public_prefix + 'members/' + prior_run + '/cluster.json',
            'initial_baseline_archive': '../trsm-stage-r6-20260912/',
            'initial_baseline_run': '../trsm-stage-r6-20260912/members/T8-control12/',
            'expected_prior_job_id': expected_history_job,
            'prior_run_job_id': history_job or None,
            'public_record_job_id': public_record_job or None,
            'record_job_id': prior_job or None,
            'job_id_match': job_id_match, 'version_match': version_match,
            'note': 'Job ID/version association only. Each repeat uses its own historical run and public archive; this is not a byte identity claim. Different jobs are not merged into the r16 comparison.',
        })
        if not job_id_match or not version_match:
            missing.append(member + ' prior-record.json matching its public ' + history_name
                           + ' record and job ' + expected_history_job + '; inspect the referenced archive')

    # Discover current account names only from the already selected public evidence;
    # never read private config, SSH state, authentication files, or the Keychain.
    replacements = {
        '/LOCAL_USER_HOME': '/LOCAL_USER_HOME', '/CLUSTER_USER_HOME': '/CLUSTER_USER_HOME',
        '/CLUSTER_USER_HOME': '/CLUSTER_USER_HOME', 'LOCAL_HOST_1': 'LOCAL_HOST_1',
        'LOCAL_USER': 'LOCAL_USER', 'REDACTED_USER': 'REDACTED_USER', 'CLUSTER_HOST': 'CLUSTER_HOST',
        'COMPUTE_NODE_1': 'COMPUTE_NODE_1', 'LOGIN_NODE_4': 'LOGIN_NODE_4', 'LOGIN_NODE_3': 'LOGIN_NODE_3',
        'LOGIN_NODE_5': 'LOGIN_NODE_5', 'LOGIN_NODE_1': 'LOGIN_NODE_1', 'LOGIN_NODE_2': 'LOGIN_NODE_2',
    }
    accounts = {'CLUSTER_ACCOUNT'}
    texts = {}
    for relative, source in sorted(planned.items()):
        data = source.read_bytes()
        if b'\0' in data:
            omitted.append({'source': str(source.relative_to(ROOT)), 'reason': 'NUL-containing non-text file'})
            continue
        text = data.decode('utf-8', errors='replace')
        if PRIVATE_MATERIAL.search(text):
            raise RuntimeError('Credential-like material in selected evidence; refusing archive: ' + str(source.relative_to(ROOT)))
        texts[relative] = (source, len(data), text)
        if source.name == 'cluster.json':
            obj = read_object(source) or {}
            user = obj.get('user')
            host = obj.get('host')
            if isinstance(user, str) and re.fullmatch(r'[A-Za-z_][A-Za-z0-9_.-]{2,}', user):
                replacements[user] = 'REDACTED_USER'
            if isinstance(host, str) and host:
                replacements[host] = 'CLUSTER_HOST'
        if source.suffix.lower() in ('.log', '.txt', '.json'):
            accounts.update(re.findall(r'(?mi)^\s*account\s+([A-Za-z_][A-Za-z0-9_.-]*)\s*$', text))
            accounts.update(re.findall(r'"account"\s*:\s*"([A-Za-z_][A-Za-z0-9_.-]*)"', text))

    def redact(text):
        for old, new in sorted(replacements.items(), key=lambda item: (-len(item[0]), item[0])):
            text = text.replace(old, new)
        for account in sorted(accounts, key=len, reverse=True):
            text = text.replace(account, 'CLUSTER_ACCOUNT')
        text = re.sub(r'/LOCAL_USER_HOME/\s\"\'<>:]+', '/LOCAL_USER_HOME', text)
        text = re.sub(r'/CLUSTER_USER_HOME/\s\"\'<>:]+', '/CLUSTER_USER_HOME', text)
        text = re.sub(r'/CLUSTER_USER_HOME:/|\b))[^/\s\"\'<>:]+', '/CLUSTER_USER_HOME', text)
        text = re.sub(r'/(?:private/)?var/folders/[^\s\"\'<>]+', '/LOCAL_TEMP_PATH', text)
        text = re.sub(r'\blogin\d+\b', 'LOGIN_NODE_REDACTED', text)
        text = re.sub(r'\bcn\d+\b', 'COMPUTE_NODE_REDACTED', text)
File owner/group identifiers redacted for publication.
        return text

    DEST.mkdir()  # Exclusive protection; do not remove or reuse on partial failure.
    inventory = []
    for relative, (source, source_size, original) in sorted(texts.items()):
        destination = DEST / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        # Never place an unredacted original into the public destination, even
        # transiently. A partial failure keeps only already-redacted copies.
        public = redact(original)
        with destination.open('x', encoding='utf-8') as output:
            output.write(public)
        if 'submitted-payload' in relative.parts:
            role = 'prepared_upload_snapshot'
        elif 'candidate-preparation' in relative.parts:
            role = 'historical_candidate_preparation'
        elif relative.name == 'instrumented-trsm.c':
            role = 'collected_preflight_instrumented_source_not_benchmark'
        elif 'diagnostics' in relative.parts or any(part.endswith('-results') for part in relative.parts):
            role = 'collected_result_or_log_not_revalidated_by_archive'
        elif 'source' in relative.parts:
            role = 'run_local_source_snapshot'
        elif relative.name in ('preflight_audit.py', 'cohort_driver.py', 'remote_job.sh',
                               'job_control.py', 'finish_records.py') or any(
                part in ('preflight', 'preflight-wide32', 'preflight-panel8x16', 'reference') for part in relative.parts):
            role = 'current_local_preparation_or_audit_tool'
        else:
            role = 'local_evidence_record_or_preparation'
        inventory.append({'path': str(relative), 'source': redact(str(source.relative_to(ROOT))),
                          'provenance_role': role,
                          'source_bytes': source_size, 'public_bytes': destination.stat().st_size,
                          'text_changed_by_redaction': public != original,
                          'utf8_decode_policy': 'Replace invalid UTF-8 bytes in public copy only',
                          'source_snapshot': 'source' in relative.parts})

    # Report existing record claims by matching run job IDs, not by version alone.
    states = []
    for member in MEMBERS:
        folder = RUNS / member
        cluster = read_object(folder / 'cluster.json') or {}
        job = str(cluster.get('job_id', ''))
        version = VERSION_BY_MEMBER[member]
        current = read_object(ROOT / 'records/experiments/trsm' / (version + '.json'))
        candidates = [read_object(folder / 'record.json'), read_object(folder / 'repeat-attempt.json'), previous_records.get(member), current]
        matched = next((r for r in candidates if r and str(r.get('job_id', '')) == job and job), None)
        present = [name for name in ('benchmark.log', 'environment.log', 'scheduler-status.txt', 'exit-code.txt', 'linkage.log')
                   if (folder / name).is_file()]
        states.append({'run': member, 'job_id': job or None, 'run_state': cluster.get('state'),
                       'matching_record_status': matched.get('status') if matched else None,
                       'matching_record_reports_verified': matched.get('verified') is True if matched else False,
                       'recorded_at': matched.get('recorded_at') if matched else None,
                       'raw_member_evidence_present': present,
                       'note': 'Existing local record claim only; archive creation does not revalidate measurements, source identity, or transport.'})
    document = {
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r16-20260912',
        'created_at': datetime.now(timezone.utc).isoformat(),
        'publication_scope': 'Redacted public derivative; unredacted originals retained in local .runs/trsm directories.',
        'validation_policy': 'No hash computation or verification; no local compilation or tests; no promotion or contest submission by this script.',
        'reference_scope': 'KML 25.1.0 with private GCC 12.3.1; this archive does not establish the specified KML 25.2.0 revalidation.',
        'verified_by_archive_creation': False,
        'remote_source_identity_verified': False,
        'transport_integrity_verified': False,
        'public_copies_are_original_byte_evidence': False,
        'missing_optional_or_expected_evidence': missing,
        'omitted_files': omitted,
        'runs': states,
        'files': inventory,
        'SOURCE': [item for item in inventory if item['source_snapshot']],
        'file_count_excluding_generated_readme_and_manifest': len(inventory),
        'failure_policy': 'Only existing failed/partial logs are copied; missing logs and unverified runs are never filled with synthetic results.',
        'repeat_policy': 'T8 and T18 retain their own r15 repeat records, both job1579788. T19 is new. No historical samples enter r16 statistics.',
        'preparation_policy': 'static-readiness.json, prepared-repeat-readiness.json, ROOT-CONTROLLER-REVIEW, preflight STATIC-REVIEW and candidate documents are preparation evidence only; they do not establish r16 runtime or promotion success.',
        'submitted_helper_policy': 'Current preflight_audit.py and its frozen submitted-payload copy are both required and kept separately. The frozen copy is never replaced by the current helper when missing.',
        'preflight_evidence_policy': 'T8/T18 use the unchanged general budget module. T19 uses the dedicated panel8x16 module and all three result JSON files. T18/T19 each use CT64 wide32. Instrumented sources are test artifacts, not measured benchmark source.',
        'comparison_evidence': {
            'promotion_parent': 'T8-control12',
            'baseline_comparison_files': ['cohorts/compare/' + name for name in COMPARISON_FILES[:2]],
            'mechanism_comparison_files': ['cohorts/compare/' + COMPARISON_FILES[2]],
            'note_on_scope': 'T18-to-T19 isolates the small-path shape; it does not authorize promotion. Both candidates must be compared with current T8.',
            'note': 'References to expected actual outputs only; absent outputs remain missing and are never generated by this archive.',
        },
        'prior_record_origins': prior_record_origins,
        'candidate_preparation_origins': candidate_preparation_origins,
        'warmup_policy': 'Warmup logs, linkage and warmup/summary.json are retained separately from timed run results; archive creation does not treat warmup as an additional measured round.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('# TRSM r16 公开实验归档\n\n这是脱敏公开派生副本；原始私有日志保留于 .runs/trsm。归档只整理已存在文件，不编译、运行、登记、晋级或提交比赛，不计算或验证哈希，不由归档动作宣称实验通过。公开副本不替代原始证据或重新晋级输入。\n\n本轮成员为 T8-control12-repeat-r16、T18-budgetwide-repeat-r16 和新 T19-panel8x16budget。每个成员保留五份源码、实验/作业元数据、逐套日志及已有结果声明。两份 prior 分别关联 r15 的 T8/T18 repeat 与公开台账，均应为作业1579788；ARCHIVE.json逐项列出匹配结果，历史样本不并入本轮。\n\nT18 原候选的三份准备文档仍明确来自 r14 的 .runs/trsm/T18-budgetwide，并放在 member/candidate-preparation；T19三份准备文档来自本轮新候选目录。静态文档只说明准备与审查，不能代替实际精度或性能结果。\n\ncohorts/compare保留计划、控制器、driver、单次finish标记、参考探针、全部实际日志和比较。submitted-payload独立保存prepare冻结的三成员五源码、driver、remote_job、cohort-config、旧preflight_audit，以及preflight、preflight-wide32、preflight-panel8x16、reference完整输入；缺失冻结副本不得用当前文件替代。清单区分当前工具、上传快照、取回结果及插桩预检源码，不额外声称验证远端脚本身份或传输。\n\n旧general预算预检仅对应T8/T18，保存全部ALLOC/CASE/MODE日志、完成标记、双JSON、commands/TSV/guard与原源码汇编。T19专用模块保留check-panel.c、guard.py、run.sh、audit_panel8x16.py、PLAN/README及实际静态审查；结果包含summary.json、budget-summary.json、panel8x16-summary.json、全部原始分配/入口/参数/直接核/整算子日志、完成标记、commands/TSV/guard、插桩副本和未插桩源码的trsm-panel8x16.s。数目以运行前冻结契约和真实输出为准，不补造成功摘要。\n\nT18/T19各自的CT64 wide32完整结果分别保留，包含28直接/28整算子预检原日志与参数观察、原source汇编和独立插桩副本。所有实际汇编审查和其输入同时保留。测试二进制、编译器、私有配置/认证/doctor文件和ZIP/tar不收入公开档。\n\n预热独立保留，不计为正式样本。正式三轮日志及T8→T18、T8→T19晋级比较和T18→T19机理对照均记录；机理比较不能授权晋级。缺失、失败、未完成记录如实列入清单，不用历史成功填充。records/latest仅转述归档时与本轮job匹配的三版台账。\n\n实际参考为KML25.1/GCC12，不等同指定KML25.2复验。原件不改不删；目标目录排他，禁止原地重复执行归档。\n')
    print('Created public TRSM r16 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
