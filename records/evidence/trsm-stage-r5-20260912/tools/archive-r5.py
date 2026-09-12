#!/usr/bin/env python3
"""Create one public, redacted r5 evidence archive; never run tests or digests.

Run only after collecting the desired finished/failed evidence. This script
does not download, validate, record, promote, package, or publish experiments.
The destination is exclusive, and every original file remains untouched.
"""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import re
import shutil


ROOT = Path(__file__).resolve().parents[2]
RUNS = ROOT / '.runs/trsm'
DEST = ROOT / 'records/evidence/trsm-stage-r5-20260912'
COHORTS = {
    'baseline': RUNS / 'optimization-20260912-r5',
    'compare': RUNS / 'optimization-20260912-r5-compare',
}
MEMBERS = ('T7-control11', 'T7-control11-repeat-r5', 'T8-svepanel16', 'T8-paneloutline')
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
TEXT_SUFFIXES = {'.c', '.h', '.py', '.sh', '.md', '.json', '.txt', '.log', '.tsv', '.s'}
COHORT_FILES = {
    'cohort_driver.py', 'remote_job.sh', 'job_control.py', 'plan.json',
    'cohort-config.json', 'cohort-submission.json', 'assigned-job-id.txt',
    'PREPARATION.md', 'README.md', 'NOTES.md',
    'submit.log', 'upload.log', 'job-marker.log', 'scheduler-status.txt',
    'latest-status.txt', 'pending-details.txt', 'collect.log', 'result.json',
    'failure.json', 'preflight.log', 'environment.log', 'wrapper.stdout.log',
    'cohort.stdout.log', 'cohort-exit-code.txt', 'compiler-environment.log',
    'omp-runtime-symbol.log', 'record-compare-commands.json',
}
MEMBER_FILES = {
    'experiment.json', 'cluster.json', 'record.json', 'prior-record.json',
    'repeat-attempt.json', 'PREPARATION.md', 'README.md', 'NOTES.md',
    'benchmark.log', 'environment.log', 'wrapper.stdout.log', 'scheduler-status.txt',
    'latest-status.txt', 'exit-code.txt', 'linkage.log', 'runtime-settings.json',
    'result.json', 'failure.json', 'record.log', 'compare.json',
}
FORBIDDEN = re.compile(
    r'cluster\.local|known[_-]?hosts|keychain|reconnect|askpass|auth|doctor|'
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
        if source.is_symlink() or any(p in ('.git', '__pycache__', 'compiler-private') for p in relsource.parts):
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
            dirs[:] = sorted(d for d in dirs if d not in ('.git', '__pycache__', 'compiler-private')
                             and not FORBIDDEN.search(d) and not (Path(directory) / d).is_symlink())
            for name in sorted(files):
                path = Path(directory) / name
                add(path, relative / path.relative_to(source))

    for label, folder in COHORTS.items():
        prefix = Path('cohorts') / label
        for name in sorted(COHORT_FILES):
            add(folder / name, prefix / name, required=name in ('plan.json', 'cohort-config.json', 'cohort-submission.json'))
        # Comparison/registration outputs have member-derived names.
        for pattern in ('*-vs-*.json', '*-record.log', '*-compare.log', '*-promote.log', '*NOTES*.md', '*failure*.json', '*failure*.log'):
            for path in sorted(folder.glob(pattern)):
                add(path, prefix / path.name)
        for name in ('preflight', 'reference', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json'):
            add(payload / name, prefix / 'submitted-payload' / name)
        for name in ('preflight', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for member in MEMBERS:
            for name in SOURCE_FILES:
                add(payload / member / 'source' / name, prefix / 'submitted-payload' / member / 'source' / name)

    for member in MEMBERS:
        folder = RUNS / member
        prefix = Path('members') / member
        for name in sorted(MEMBER_FILES):
            add(folder / name, prefix / name)
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
    prior = RUNS / 'T7-control11-repeat-r5/prior-record.json'
    add(prior, 'members/T7-control11-repeat-r5/prior-record.json', required=True)
    for version in ('T7-control11', 'T8-svepanel16', 'T8-paneloutline'):
        add(ROOT / 'records/experiments/trsm' / (version + '.json'), Path('records/latest') / (version + '.json'), required=True)
    add(RUNS / 'nohash-tools/records-kml.py', 'tools/records-kml.py', required=True)
    add(RUNS / 'nohash-tools/records-kml-NOTES.md', 'tools/records-kml-NOTES.md', required=True)
    add(Path(__file__).resolve(), 'tools/archive-r5.py', required=True)

    # Keep the old baseline's structured record associated with its old job.
    # The latest T7 record can legitimately be replaced by the same-source repeat.
    latest = read_object(ROOT / 'records/experiments/trsm/T7-control11.json')
    previous = read_object(prior)
    original_cluster = read_object(RUNS / 'T7-control11/cluster.json') or {}
    original_job = str(original_cluster.get('job_id', ''))
    if previous and str(previous.get('job_id', '')) == original_job:
        add(prior, 'members/T7-control11/record-for-original-run.json')
    elif latest and str(latest.get('job_id', '')) == original_job:
        add(ROOT / 'records/experiments/trsm/T7-control11.json', 'members/T7-control11/record-for-original-run.json')
    else:
        missing.append('structured record matching the original T7-control11 job; original raw evidence is still archived')

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
        shutil.copy2(source, destination)
        public = redact(original)
        destination.write_text(public, encoding='utf-8')
        inventory.append({'path': str(relative), 'source': redact(str(source.relative_to(ROOT))),
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
        version = 'T7-control11' if member.startswith('T7-control11') else member
        current = read_object(ROOT / 'records/experiments/trsm' / (version + '.json'))
        candidates = [read_object(folder / 'record.json'), read_object(folder / 'repeat-attempt.json'), previous, current]
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
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r5-20260912',
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
        'repeat_policy': 'Original T7-control11 raw run, repeat run, prior-record.json when present, and latest version record are separate objects.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('''# TRSM r5 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/baseline 与 cohorts/compare 分别保存控制脚本、计划、提交元数据、预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。members 保留四个运行目录的源码、原始结果副本与无哈希登记快照。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

T7-control11 原运行不会被新版台账覆盖：旧 raw run、T7-control11-repeat-r5 的 prior-record.json（存在时）、record-for-original-run.json（能按作业 ID 关联时），以及 records/latest 中归档时的台账分别保存。不要把不同作业或环境的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
''')
    print('Created public TRSM r5 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
