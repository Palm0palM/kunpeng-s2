#!/usr/bin/env python3
"""Create one public, redacted r13 evidence archive; never run tests or digests.

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
DEST = ROOT / 'records/evidence/trsm-stage-r13-20260912'
COHORTS = {
    'compare': RUNS / 'optimization-20260912-r13-compare',
}
VERSION_BY_MEMBER = {
    'T8-control12-repeat-r13': 'T8-control12',
    'T10-lhistbarrier-repeat-r13': 'T10-lhistbarrier',
    'T14-lhistcyclic': 'T14-lhistcyclic',
}
MEMBERS = tuple(VERSION_BY_MEMBER)
# These repeats deliberately have different historical cohorts and job IDs.
REPEAT_ORIGINS = {
    'T8-control12-repeat-r13': {
        'run': 'T8-control12-repeat-r12',
        'archive': 'trsm-stage-r12-20260912',
        'job_id': '1579645',
    },
    'T10-lhistbarrier-repeat-r13': {
        'run': 'T10-lhistbarrier',
        'archive': 'trsm-stage-r7-20260912',
        'job_id': '1579401',
    },
}
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
# r7 packed-L-aware general preflight; the strict result parser is inline in run.sh.
PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-panel.c', 'README.md')
TEXT_SUFFIXES = {'.c', '.h', '.py', '.sh', '.md', '.json', '.txt', '.log', '.tsv', '.s'}
COHORT_FILES = {
    'cohort_driver.py', 'remote_job.sh', 'job_control.py', 'plan.json', 'actual-run-audit.json',
    'cohort-config.json', 'cohort-submission.json', 'assigned-job-id.txt',
    'PREPARATION.md', 'README.md', 'NOTES.md',
    'submit.log', 'upload.log', 'job-marker.log', 'scheduler-status.txt',
    'latest-status.txt', 'pending-details.txt', 'collect.log', 'result.json',
    'scheduler-pending-during-preflight.txt', 'latest-wrapper-tail.log', 'scheduler-json-query.txt',
    'collect-before-scheduler-terminal.log', 'scheduler-finalization-NOTES.md',
    'scheduler-done-query.txt', 'scheduler-steps-query.txt', 'djob-help.txt',
    'failure.json', 'preflight.log', 'STATIC-CONTROLLER-REVIEW.md', 'finish_records.py', 'environment.log', 'wrapper.stdout.log',
    'warmup.log', 'warmup-linkage.log',
    'cohort.stdout.log', 'cohort-exit-code.txt', 'compiler-environment.log',
    'omp-runtime-symbol.log', 'record-compare-commands.json', 'static-readiness.json',
    'prepared-repeat-readiness.json', 'continuation-state.json',
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
                                 'prepared-repeat-readiness.json'))
        # Comparison/registration outputs have member-derived names.
        for pattern in ('*-vs-*.json', '*-record.log', '*-compare.log', '*-promote.log', '*NOTES*.md', '*failure*.json', '*failure*.log'):
            for path in sorted(folder.glob(pattern)):
                add(path, prefix / path.name)
        for name in ('preflight', 'reference', 'warmup',
                     'preflight-results', 'reference-results',
                     'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        assembly_reviews(folder, prefix)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json'):
            add(payload / name, prefix / 'submitted-payload' / name, required=True)
        for name in ('preflight', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for name in PREFLIGHT_FILES:
            add(folder / 'preflight' / name, prefix / 'preflight' / name, required=True)
            add(payload / 'preflight' / name,
                prefix / 'submitted-payload/preflight' / name, required=True)
        for name in ('T8-control12-vs-T10-lhistbarrier.json',
                     'T8-control12-vs-T14-lhistcyclic.json',
                     'T10-lhistbarrier-vs-T14-lhistcyclic.json'):
            add(folder / name, prefix / name, required=True)
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
                required=member == 'T14-lhistcyclic' and name == 'PREPARATION.md')
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'warmup', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
        assembly_reviews(folder, prefix)
        if member == 'T10-lhistbarrier-repeat-r13':
            # Original r7 candidate preparation is historical static material.
            # Never substitute a new repeat document for this explicit origin.
            for name in ('PREPARATION.md', 'VALIDATION-PLAN.md', 'STATIC-REVIEW.md'):
                preparation = RUNS / 'T10-lhistbarrier' / name
                destination = prefix / 'candidate-preparation' / name
                required = name == 'PREPARATION.md'
                if not required and (not preparation.is_file() or preparation.is_symlink()):
                    continue
                add(preparation, destination, required=required)
                candidate_preparation_origins.append({
                    'run': member, 'version': VERSION_BY_MEMBER[member],
                    'document': str(destination), 'source': str(preparation.relative_to(ROOT)),
                    'historical_candidate_run': 'T10-lhistbarrier',
                    'historical_public_archive': '../trsm-stage-r7-20260912/',
                    'note': 'Original r7 candidate preparation/static plan only; not evidence of this repeat run passing a gate.',
                })
        elif member == 'T14-lhistcyclic':
            candidate_preparation_origins.append({
                'run': member, 'version': VERSION_BY_MEMBER[member],
                'document': str(prefix / 'PREPARATION.md'),
                'source': str((folder / 'PREPARATION.md').relative_to(ROOT)),
                'note': 'Existing T14 preparation describing its single pragma change from T10; not an r13 runtime result.',
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
    add(Path(__file__).resolve(), 'tools/archive-r13.py', required=True)

    # Each repeat retains its own prior job and public archive association.
    # In particular, T10's prior job is r7, not T8's later r12 baseline repeat.
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
            'note': 'Job ID/version association only. Each repeat uses its own historical run and public archive; this is not a byte identity claim. Different jobs are not merged into the r13 comparison.',
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
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r13-20260912',
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
        'repeat_policy': 'T8 retains its r12 prior record/run at job 1579645; T10 retains its original r7 prior record/run at job 1579401. These are separate histories, not a CLUSTER_ACCOUNT prior cohort. Original T8 baseline evidence remains in r6. Samples from separate jobs are not merged.',
        'preparation_policy': 'static-readiness.json, prepared-repeat-readiness.json, static reviews and candidate preparation are preparation evidence only; they do not establish r13 compilation, preflight, benchmark or promotion success.',
        'comparison_evidence': {
            'promotion_parent': 'T8-control12',
            'baseline_comparison_files': ['cohorts/compare/T8-control12-vs-T10-lhistbarrier.json',
                                          'cohorts/compare/T8-control12-vs-T14-lhistcyclic.json'],
            'mechanism_comparison_file': 'cohorts/compare/T10-lhistbarrier-vs-T14-lhistcyclic.json',
            'mechanism_summary_field': 'cohorts/compare/result.json:mechanism_comparison',
            'mechanism_comparison_authorizes_promotion': False,
            'note': 'References to expected actual comparison outputs only; absent outputs remain missing and are never generated by this archive.',
        },
        'prior_record_origins': prior_record_origins,
        'candidate_preparation_origins': candidate_preparation_origins,
        'warmup_policy': 'Warmup logs, linkage and warmup/summary.json are retained separately from timed run results; archive creation does not treat warmup as an additional measured round.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('''# TRSM r13 公开实验归档

此目录为脱敏公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，公开文本不能用作原始字节身份依据或重新晋级输入。归档不计算或验证哈希，不运行编译、测试、benchmark、登记或晋级，也不声称当前测量已经完成或通过。

cohorts/compare 保存 r13 的控制脚本、计划、提交元数据、finish_records.py、r7 packed-L-aware 通用预检、KML 探针及实际已取回日志。submitted-payload 单独保存 prepare 时冻结的控制脚本、cohort-config.json、preflight/reference 和三个成员的五个源码文件。当前准备目录与冻结提交目录分别留痕，缺失项记入 ARCHIVE.json，不能拿当前文件补写冻结快照。本轮没有 wide32 预检；不得用旧宽核日志替代本轮通用预检。

通用预检的 guard.py、run.sh、check-panel.c 和 README.md 同时保留当前准备版与冻结版，严格结果 parser 完整内嵌在 run.sh 的 Python heredoc 中。三个成员的 preflight-results 分别从实际结果或 diagnostics 下递归收录，包括 summary.tsv、completion.txt、commands.txt、guard.json、trsm-panel16.s 和实际存在的所有日志。guard、compiler、build-normal、build-no-sve、build-fail-alloc、assembly、micro-t1、normal-t1、normal-t4、normal-t38、boundary-t1、no-sve-t4、fail-alloc-t4、narrow-vl-t4，以及 T10/T14 的 build-fail-shared、packed-micro-t1、shared-fail-t1、shared-fail-t4 证据按原文保留。函数插桩来自 check-panel.c/编译命令，预检产物不能代替 benchmark 源码；trsm-panel16.s 的实际生成命令及相关汇编审查/输入另行保留，归档不重新生成汇编。预期 T8 与 T10/T14 的覆盖计数不同，实际 completion 以各自日志为准；没有统一补造计数或成功标记。检查程序二进制不归档。

members 保存 T8-control12-repeat-r13、T10-lhistbarrier-repeat-r13 和 T14-lhistcyclic 的运行材料、源码、预热、登记及原日志。T10 的原 r7 PREPARATION.md 明确从 .runs/trsm/T10-lhistbarrier 收录到本轮 member 的 candidate-preparation 下；原候选已有的 VALIDATION-PLAN/STATIC-REVIEW 也按实际存在情况保留。T14 现有 PREPARATION.md 和五个源文件均为所需材料。candidate_preparation_origins 逐项说明来源，静态准备不能当作本轮通过验证的证据。

static-readiness.json、STATIC-CONTROLLER-REVIEW、prepared-repeat-readiness.json 及计划都是准备材料。其中 prepared-repeat-readiness.json 保存 prepare 后对 T8/T10 既有 repeat 资格的只读 helper 检查；不是 r13 新编译、预检或成绩验证。warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 的原 run 结果分开保留。计划为每成员一套预热和 ABC/BCA/CAB 三轮正式用例，只有实际取回并登记的结果才能证明完成；预热不并入正式三轮计时。失败或不完整运行只保存已有证据，缺失项与按 job ID 匹配的台账声明列在 ARCHIVE.json。

两份 prior 来源不同。T8 prior-record.json 关联 r12 公开档的 [T8 记录](../trsm-stage-r12-20260912/records/latest/T8-control12.json)和 [T8-control12-repeat-r12 运行](../trsm-stage-r12-20260912/members/T8-control12-repeat-r12/cluster.json)，预期作业 1579645。T10 prior-record.json 关联 r7 公开档的 [T10 记录](../trsm-stage-r7-20260912/records/latest/T10-lhistbarrier.json)和 [T10-lhistbarrier 原运行](../trsm-stage-r7-20260912/members/T10-lhistbarrier/cluster.json)，预期作业 1579401。ARCHIVE.json 的 prior_record_origins 分别核对版本与各自 job ID；不借相同版本认定来源，也不把两个历史作业写为同一个 cohort。原始 T8 初测仍见 [r6 公开档](../trsm-stage-r6-20260912/members/T8-control12/)，更早重复历史由相应公开档继续引用。本轮不重建或覆盖旧运行。

records/latest 保留归档时的 T8-control12、T10-lhistbarrier、T14-lhistcyclic 台账。T8-vs-T10 与 T8-vs-T14 两份机器可读比较、T10-lhistbarrier-vs-T14-lhistcyclic.json 机理对照，以及 result.json 的 mechanism_comparison 字段均按实际产物收录。T10-vs-T14 只用于区分共享 L 生产调度这一个改动，不能授权晋级；T14 晋级父版本仍为 T8-control12。归档不预判比较/晋级结论，不把历史样本混入本轮同一作业的比较。

实际参考环境以各作业证据为准；KML 25.1.0 + 私有 GCC 12.3.1 不等同指定 KML 25.2.0 复验。ARCHIVE.json 的 verified 只转述按本轮 job ID 匹配的原台账声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单记录相对路径、原件字节数和公开副本字节数，不包含摘要。tools/records-kml.py 与其 NOTES 保存所用 helper 及作者记录的审查说明，不补造独立检查结果。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均不归档。公共工具和其他题目没有因归档发生改动。
''')
    print('Created public TRSM r13 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
