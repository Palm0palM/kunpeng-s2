#!/usr/bin/env python3
"""Create one public, redacted r8 evidence archive; never run tests or digests.

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
DEST = ROOT / 'records/evidence/trsm-stage-r8-20260912'
COHORTS = {
    'compare': RUNS / 'optimization-20260912-r8-compare',
}
MEMBERS = ('T8-control12-repeat-r8', 'T11-sve8x16')
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
WIDE_PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-wide.c', 'README.md')
TEXT_SUFFIXES = {'.c', '.h', '.py', '.sh', '.md', '.json', '.txt', '.log', '.tsv', '.s'}
COHORT_FILES = {
    'cohort_driver.py', 'remote_job.sh', 'job_control.py', 'plan.json', 'actual-run-audit.json',
    'cohort-config.json', 'cohort-submission.json', 'assigned-job-id.txt',
    'PREPARATION.md', 'README.md', 'NOTES.md',
    'submit.log', 'upload.log', 'job-marker.log', 'scheduler-status.txt',
    'latest-status.txt', 'pending-details.txt', 'collect.log', 'result.json',
    'failure.json', 'preflight.log', 'preflight-wide.log', 'STATIC-CONTROLLER-REVIEW.md', 'finish_records.py', 'environment.log', 'wrapper.stdout.log',
    'warmup.log', 'warmup-linkage.log',
    'cohort.stdout.log', 'cohort-exit-code.txt', 'compiler-environment.log',
    'omp-runtime-symbol.log', 'record-compare-commands.json', 'static-readiness.json',
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
            add(folder / name, prefix / name, required=name in ('plan.json', 'cohort-config.json', 'cohort-submission.json'))
        # Comparison/registration outputs have member-derived names.
        for pattern in ('*-vs-*.json', '*-record.log', '*-compare.log', '*-promote.log', '*NOTES*.md', '*failure*.json', '*failure*.log'):
            for path in sorted(folder.glob(pattern)):
                add(path, prefix / path.name)
        for name in ('preflight', 'preflight-wide', 'reference', 'warmup',
                     'preflight-results', 'preflight-wide-results', 'reference-results',
                     'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        assembly_reviews(folder, prefix)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json'):
            add(payload / name, prefix / 'submitted-payload' / name, required=True)
        for name in ('preflight', 'preflight-wide', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for name in WIDE_PREFLIGHT_FILES:
            add(folder / 'preflight-wide' / name, prefix / 'preflight-wide' / name, required=True)
            add(payload / 'preflight-wide' / name,
                prefix / 'submitted-payload/preflight-wide' / name, required=True)
        for member in MEMBERS:
            for name in SOURCE_FILES:
                add(payload / member / 'source' / name,
                    prefix / 'submitted-payload' / member / 'source' / name, required=True)

    for member in MEMBERS:
        folder = RUNS / member
        prefix = Path('members') / member
        for name in sorted(MEMBER_FILES):
            add(folder / name, prefix / name,
                required=member == 'T11-sve8x16' and name in ('PREPARATION.md', 'STATIC-REVIEW.md', 'VALIDATION-PLAN.md'))
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'warmup', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
        assembly_reviews(folder, prefix)
    prior = RUNS / 'T8-control12-repeat-r8/prior-record.json'
    add(prior, 'members/T8-control12-repeat-r8/prior-record.json', required=True)
    for version in ('T8-control12', 'T11-sve8x16'):
        add(ROOT / 'records/experiments/trsm' / (version + '.json'), Path('records/latest') / (version + '.json'), required=True)
    add(RUNS / 'nohash-tools/records-kml.py', 'tools/records-kml.py', required=True)
    add(RUNS / 'nohash-tools/records-kml-NOTES.md', 'tools/records-kml-NOTES.md', required=True)
    add(Path(__file__).resolve(), 'tools/archive-r8.py', required=True)

    # The r8 prior record belongs to the r7 repeat, not the initial T8 run.
    # The r7 archive keeps that repeat and its r6 prior record. The original
    # baseline is retained by r6; reference both without copying older runs.
    previous = read_object(prior)
    history_archive = ROOT / 'records/evidence/trsm-stage-r7-20260912'
    prior_run = 'T8-control12-repeat-r7'
    history_cluster = read_object(history_archive / 'members' / prior_run / 'cluster.json') or {}
    history_job = str(history_cluster.get('job_id') or '')
    prior_job = str((previous or {}).get('job_id') or '')
    prior_record_origin = {
        'record': 'members/T8-control12-repeat-r8/prior-record.json',
        'prior_run': prior_run,
        'prior_public_archive': '../trsm-stage-r7-20260912/',
        'prior_run_cluster': '../trsm-stage-r7-20260912/members/' + prior_run + '/cluster.json',
        'initial_baseline_archive': '../trsm-stage-r6-20260912/',
        'initial_baseline_run': '../trsm-stage-r6-20260912/members/T8-control12/',
        'prior_run_job_id': history_job or None,
        'record_job_id': prior_job or None,
        'job_id_match': bool(re.fullmatch(r'[0-9]+', history_job) and prior_job == history_job),
        'note': 'Job ID association only. The r7 archive retains the r7 repeat and its r6 prior record; the original T8 baseline is retained in the r6 archive, which references older history.',
    }
    if not prior_record_origin['job_id_match']:
        missing.append('r8 prior-record.json matching the r7 repeat job; inspect the referenced public r7 archive')

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
        version = 'T8-control12' if member.startswith('T8-control12') else member
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
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r8-20260912',
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
        'repeat_policy': 'The r8 T8 repeat and its prior record are separate objects; the prior record is associated with the r7 repeat by job ID. The r7 archive retains that repeat and its r6 prior record. Original baseline evidence is retained in the r6 public archive, which references older history.',
        'prior_record_origin': prior_record_origin,
        'warmup_policy': 'Warmup logs, linkage and warmup/summary.json are retained separately from timed run results; archive creation does not treat warmup as an additional measured round.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('''# TRSM r8 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/compare 保存本轮唯一 cohort 的控制脚本、计划、提交元数据、通用预检、preflight-wide 宽核预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。preflight-wide 的 guard、runner、check-wide.c 和 README 分别保留当前准备版与冻结提交版；实际 preflight-wide-results、目标汇编及已存在的 assembly review 从结果/diagnostics 目录另行收录。members 只保留 T8-control12-repeat-r8 与 T11-sve8x16 两个运行目录，T11 的 PREPARATION、STATIC-REVIEW 和 VALIDATION-PLAN 作为准备材料收录。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 下的 warmup 和原 run 结果分别保留。预热证据不作为额外计时轮次。static-readiness.json、STATIC-CONTROLLER-REVIEW 和候选静态/验证计划均为准备材料，不是编译、测试或运行验证结果。准备目录、submitted-payload、warmup 和实际取回的 diagnostics 分别保存，清单记录每份副本的来源路径；冻结快照或所需准备文件缺失会列入清单，不由当前文件补写。

本轮 T8 的 prior-record.json 保存在 members/T8-control12-repeat-r8，并以作业 ID 关联 [r7 repeat 的公开记录](../trsm-stage-r7-20260912/members/T8-control12-repeat-r7/cluster.json)。关联结果见 ARCHIVE.json 的 prior_record_origin；关联失败会明确列为缺失/待核对事项，不借版本名认定。[r7 公开档](../trsm-stage-r7-20260912/README.md)保存 r7 repeat 及其指向 r6 repeat 的 prior record；[原始 T8 初测](../trsm-stage-r6-20260912/members/T8-control12/)实际保存在 r6 公开档，更早 history 由[r6 说明](../trsm-stage-r6-20260912/README.md)继续引用。r8 不重建或覆盖旧运行。records/latest 保存归档时的 T8-control12 和 T11-sve8x16 台账，不能把不同作业的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
''')
    print('Created public TRSM r8 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
