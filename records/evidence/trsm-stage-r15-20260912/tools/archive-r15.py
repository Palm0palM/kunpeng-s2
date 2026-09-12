#!/usr/bin/env python3
"""Create one public, redacted r15 evidence archive; never run tests or digests.

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
DEST = ROOT / 'records/evidence/trsm-stage-r15-20260912'
COHORTS = {
    'compare': RUNS / 'optimization-20260912-r15-compare',
}
VERSION_BY_MEMBER = {
    'T8-control12-repeat-r15': 'T8-control12',
    'T18-budgetwide-repeat-r15': 'T18-budgetwide',
}
MEMBERS = tuple(VERSION_BY_MEMBER)
# Each repeat retains its own r14 measurement, both from job 1579730.
REPEAT_ORIGINS = {
    'T8-control12-repeat-r15': {
        'run': 'T8-control12-repeat-r14',
        'archive': 'trsm-stage-r14-20260912',
        'job_id': '1579730',
    },
    'T18-budgetwide-repeat-r15': {
        'run': 'T18-budgetwide',
        'archive': 'trsm-stage-r14-20260912',
        'job_id': '1579730',
    },
}
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-panel.c', 'README.md')
WIDE_PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-wide32.c', 'README.md')
CANDIDATE_DOCUMENTS = ('PREPARATION.md', 'VALIDATION-PLAN.md', 'STATIC-REVIEW.md')
COMPARISON_FILES = ('T8-control12-vs-T18-budgetwide.json',)
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
    'failure.json', 'preflight.log', 'preflight-wide32.log', 'STATIC-CONTROLLER-REVIEW.md', 'RESULT-REVIEW.md', 'finish_records.py', 'environment.log', 'wrapper.stdout.log',
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
                                 'prepared-repeat-readiness.json', 'STATIC-CONTROLLER-REVIEW.md', 'STATIC-READINESS.md',
                                 'preflight_audit.py'))
        # Comparison/registration outputs have member-derived names.
        for pattern in ('*-vs-*.json', '*-record.log', '*-compare.log', '*-promote.log', '*NOTES*.md', '*failure*.json', '*failure*.log'):
            for path in sorted(folder.glob(pattern)):
                add(path, prefix / path.name)
        for name in ('preflight', 'preflight-wide32', 'reference', 'warmup',
                     'preflight-results', 'preflight-wide32-results', 'reference-results',
                     'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        assembly_reviews(folder, prefix)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json', 'preflight_audit.py'):
            add(payload / name, prefix / 'submitted-payload' / name, required=True)
        for name in ('preflight', 'preflight-wide32', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for name in PREFLIGHT_FILES:
            add(folder / 'preflight' / name, prefix / 'preflight' / name, required=True)
            add(payload / 'preflight' / name,
                prefix / 'submitted-payload/preflight' / name, required=True)
        # r15 retained its review in top-level STATIC-READINESS and root controller review.
        add(folder / 'preflight/STATIC-REVIEW.md', prefix / 'preflight/STATIC-REVIEW.md')
        for name in WIDE_PREFLIGHT_FILES:
            add(folder / 'preflight-wide32' / name, prefix / 'preflight-wide32' / name, required=True)
            add(payload / 'preflight-wide32' / name,
                prefix / 'submitted-payload/preflight-wide32' / name, required=True)
        for name in COMPARISON_FILES:
            add(folder / name, prefix / name, required=True)
        # These are expected successful-collection locations. Other actually
        # retrieved partial/failed result trees above remain preserved as-is.
        for member in MEMBERS:
            result_prefix = Path('diagnostics/preflight-results') / member
            for name in ('summary.json', 'budget-summary.json', 'completion.txt',
                         'summary.tsv', 'commands.txt', 'guard.json', 'trsm-panel16.s'):
                add(folder / result_prefix / name, prefix / result_prefix / name, required=True)
        wide_result_prefix = Path('diagnostics/preflight-wide32-results/T18-budgetwide-repeat-r15')
        for name in ('summary.json', 'completion.txt', 'summary.tsv', 'commands.txt',
                     'guard.json', 'instrumented-trsm.c', 'trsm-wide4x32.s'):
            add(folder / wide_result_prefix / name, prefix / wide_result_prefix / name, required=True)
        for member in MEMBERS:
            for name in SOURCE_FILES:
                add(payload / member / 'source' / name,
                    prefix / 'submitted-payload' / member / 'source' / name, required=True)

    candidate_preparation_origins = []
    for member in MEMBERS:
        folder = RUNS / member
        prefix = Path('members') / member
        for name in sorted(MEMBER_FILES):
            add(folder / name, prefix / name)
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'warmup', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
        assembly_reviews(folder, prefix)
        if member == 'T18-budgetwide-repeat-r15':
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
    previous_records = {}
    for member in REPEAT_ORIGINS:
        prior = RUNS / member / 'prior-record.json'
        add(prior, Path('members') / member / 'prior-record.json', required=True)
        previous_records[member] = read_object(prior)
    for version in VERSION_BY_MEMBER.values():
        add(ROOT / 'records/experiments/trsm' / (version + '.json'), Path('records/latest') / (version + '.json'), required=True)
    add(RUNS / 'nohash-tools/records-kml.py', 'tools/records-kml.py', required=True)
    add(RUNS / 'nohash-tools/records-kml-NOTES.md', 'tools/records-kml-NOTES.md', required=True)
    add(Path(__file__).resolve(), 'tools/archive-r15.py', required=True)

    # Associate each prior with its own r14 run and public record: T8 was a
    # repeated baseline, while T18 was a newly measured candidate in r14.
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
            'note': 'Job ID/version association only. Each repeat uses its own historical run and public archive; this is not a byte identity claim. Different jobs are not merged into the r15 comparison.',
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
                part in ('preflight', 'preflight-wide32', 'reference') for part in relative.parts):
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
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r15-20260912',
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
        'repeat_policy': 'T8 and T18 each retain their own r14 prior record from job 1579730. T8 refers to T8-control12-repeat-r14 and T18 to the original T18-budgetwide run; no historical samples are merged into r15.',
        'preparation_policy': 'static-readiness.json, prepared-repeat-readiness.json, STATIC-CONTROLLER-REVIEW, preflight STATIC-REVIEW and candidate documents are preparation evidence only; they do not establish r15 runtime or promotion success.',
        'submitted_helper_policy': 'Current preflight_audit.py and its frozen submitted-payload copy are both required and kept separately. The frozen copy is never replaced by the current helper when missing.',
        'preflight_evidence_policy': 'Both repeated members retain their own actual general allocation/budget logs and both JSON summaries. Only T18 is scheduled for the separate r12-derived wide32 module; its instrumented source is a preflight artifact, not benchmark source.',
        'comparison_evidence': {
            'promotion_parent': 'T8-control12',
            'baseline_comparison_files': ['cohorts/compare/' + name for name in COMPARISON_FILES],
            'mechanism_comparison_files': [],
            'note_on_scope': 'This cohort repeats only T8 and T18; r14 mechanism comparisons are historical and are not regenerated or presented as r15 measurements.',
            'note': 'References to expected actual outputs only; absent outputs remain missing and are never generated by this archive.',
        },
        'prior_record_origins': prior_record_origins,
        'candidate_preparation_origins': candidate_preparation_origins,
        'warmup_policy': 'Warmup logs, linkage and warmup/summary.json are retained separately from timed run results; archive creation does not treat warmup as an additional measured round.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('''# TRSM r15 公开实验归档

此目录是脱敏公开派生副本，未脱敏原件保留于本地 .runs/trsm。个人路径、账号、内网地址和节点名已替换；公开副本不能用作原始字节身份依据或重新晋级输入。归档没有运行编译、测试、benchmark、登记、晋级或提交比赛，没有计算或验证哈希；归档本身不证明本轮已经完成或通过。

cohorts/compare 保存 r15 两成员计划、控制器、finish_records.py、preflight_audit.py、提交及收集元数据、参考探针与实际原日志。submitted-payload 独立保存 prepare 时两成员的全部五源码、cohort_driver.py、remote_job.sh、cohort-config.json、preflight_audit.py 与 preflight/preflight-wide32/reference 全部冻结文本。当前 preflight_audit.py 和冻结副本都为所需证据；缺失冻结文件不能用当前文件补写。清单 source 和 provenance_role 区分当前准备/审计工具、prepare 上传快照、成员源文件、取回结果及插桩预检源码；该区分不额外宣称传输或远端脚本身份验证。

两个 members 分别为 T8-control12-repeat-r15 和 T18-budgetwide-repeat-r15。两者均保留 run 自身文档和全部五个 source 文件。T18 原 PREPARATION.md、VALIDATION-PLAN.md、STATIC-REVIEW.md 全部从 .runs/trsm/T18-budgetwide 收录到本轮 member/candidate-preparation，明确标注原 r14 候选静态来源；不能用 repeat 文档替代，也不把历史验证计划称为 r15 已通过的验证。

通用 preflight 四输入 guard.py、run.sh、check-panel.c、README.md 保留当前版与冻结版，STATIC-REVIEW.md 单独保留；冻结目录实际含有的审查也按原样收录。两成员真实 preflight-results 或 diagnostics/preflight-results 树递归保存所有 ALLOC_PASS/CASE_PASS/SOURCE_FEATURES/MODE/失败注入原日志，以及 summary.tsv、commands.txt、guard.json、completion.txt、summary.json、budget-summary.json 和 trsm-panel16.s。请求字节、history/X/KB 层级、每 worker X 调用、预算外零 history 调用、窄 VL 与无 SVE 的区别均保留原观测；不以 packed 入口为0补造“没有分配”的结论。

通用模块的严格结果 parser 完整包含于 run.sh；候选只在预检编译时通过 check-panel.c 包装分配和函数入口。双 JSON 来自实际输出，归档不重建。预算进程 budget-t1/t4/t38、budget-x-fail-t4、budget-no-sve-t4、budget-narrow-vl-t4，以及 T18 的 budget-shared-fail-t4 与全部继承的一般/微核/失败模式日志分别保留。不同成员覆盖计数以其冻结特征和实际完成标记为准，不能互相替代。

只有 T18-budgetwide-repeat-r15 使用单独 wide32 模块；当前 preflight-wide32 与 submitted-payload/preflight-wide32 均明确保存 guard.py、run.sh、check-wide32.c、README.md。这是继承 r14、最初来自 r12 模块的准备流程；实际 r15 结果只从本轮 preflight-wide32-results/T18-budgetwide-repeat-r15 取回树保存，包含全部日志、summary.tsv/json、completion.txt、commands.txt、guard.json、instrumented-trsm.c 与 trsm-wide4x32.s。参数观察生成器和严格 parser 内嵌 run.sh，不补造不存在的独立脚本。instrumented-trsm.c 仅是预检副本；benchmark 源码仍是该成员 source/trsm.c，trsm-wide4x32.s 由原候选源码生成。KB256/CT64、参数与宽核完成标记按真实输出保留；缺失结果不生成。全部实际汇编审查及其输入另行收录；测试二进制不归档。

static-readiness.json、prepared-repeat-readiness.json、STATIC-CONTROLLER-REVIEW、preflight 静态审查及候选准备文件只说明准备过程。预热原日志、linkage 与 warmup/summary.json 单独保存，不作为额外正式轮次。两成员实际三轮日志、登记和单个 T8-control12-vs-T18-budgetwide.json 比较完整保留，仍以 T8 为晋级比较父版本。r14 的两个机理比较属于历史，本轮不重建或冒充本轮测量。不同作业样本不混入本轮比较，也不预判候选是否胜出。

两份 prior-record.json 分别关联 r14 公开档：[T8 台账](../trsm-stage-r14-20260912/records/latest/T8-control12.json)与 [T8-control12-repeat-r14](../trsm-stage-r14-20260912/members/T8-control12-repeat-r14/cluster.json)，以及 [T18 台账](../trsm-stage-r14-20260912/records/latest/T18-budgetwide.json)与 [原 T18-budgetwide](../trsm-stage-r14-20260912/members/T18-budgetwide/cluster.json)。两份 prior 预期作业均为1579730，仍分别核对版本、run与公开记录；结果列于 ARCHIVE.json.prior_record_origins。T18 准备文档和 prior 的历史来源均明确保留，不以历史声明代替本轮成功；原始 T8 初测仍见 r6 公开档。

records/latest 是归档时 T8-control12 与 T18-budgetwide 两版本台账，仅按当前 run job ID 匹配其已有声明。失败或不完整运行只收录已经存在的日志、失败 JSON 或 failed-diagnostics 等目录，预期正常收集位置缺失时明确列入 missing_optional_or_expected_evidence；不填补成功标记、JSON、源码或测量。原件不改、不删；目标排他，已有目录禁止原地重跑。

实际 KML25.1.0/GCC12.3.1 与指定官方 KML25.2.0 复验仍分开。ARCHIVE.json 的 verified 只转述已有台账声明，归档不重新验证成绩。SOURCE 记录路径与字节数而不包含摘要。私有集群配置、SSH/认证/钥匙串/doctor 文件、二进制、编译器、tar/ZIP和Git目录排除在外。
''')
    print('Created public TRSM r15 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
