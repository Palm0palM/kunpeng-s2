#!/usr/bin/env python3
"""Create one public, redacted r12 evidence archive; never run tests or digests.

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
DEST = ROOT / 'records/evidence/trsm-stage-r12-20260912'
COHORTS = {
    'compare': RUNS / 'optimization-20260912-r12-compare',
}
VERSION_BY_MEMBER = {
    'T8-control12-repeat-r12': 'T8-control12',
    'T13-sve4x32-repeat-r12': 'T13-sve4x32',
    'T15-svetile128': 'T15-svetile128',
    'T16-svetile32': 'T16-svetile32',
}
MEMBERS = tuple(VERSION_BY_MEMBER)
REPEAT_ORIGINS = {
    'T8-control12-repeat-r12': 'T8-control12-repeat-r11',
    'T13-sve4x32-repeat-r12': 'T13-sve4x32-repeat-r11',
}
SOURCE_FILES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h', 'README.md')
# The source-instrumentation generator and strict result parser are both
# inline Python heredocs in run.sh; there are no separate helper files.
WIDE_PREFLIGHT_FILES = ('guard.py', 'run.sh', 'check-wide32.c', 'README.md')
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
    'failure.json', 'preflight.log', 'preflight-wide32.log', 'STATIC-CONTROLLER-REVIEW.md', 'finish_records.py', 'environment.log', 'wrapper.stdout.log',
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
        for name in ('preflight', 'preflight-wide32', 'reference', 'warmup',
                     'preflight-results', 'preflight-wide32-results', 'reference-results',
                     'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        assembly_reviews(folder, prefix)
        # Preserve the exact submitted source/control snapshots separately from live preparation.
        payload = folder / 'payload'
        for name in ('cohort_driver.py', 'remote_job.sh', 'cohort-config.json'):
            add(payload / name, prefix / 'submitted-payload' / name, required=True)
        for name in ('preflight', 'preflight-wide32', 'reference'):
            tree(payload / name, prefix / 'submitted-payload' / name)
        for name in WIDE_PREFLIGHT_FILES:
            add(folder / 'preflight-wide32' / name, prefix / 'preflight-wide32' / name, required=True)
            add(payload / 'preflight-wide32' / name,
                prefix / 'submitted-payload/preflight-wide32' / name, required=True)
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
                required=member in ('T15-svetile128', 'T16-svetile32') and name == 'PREPARATION.md')
        for name in SOURCE_FILES:
            add(folder / 'source' / name, prefix / 'source' / name, required=True)
        for name in ('nohash-recorded-evidence', 'warmup', 'diagnostics', 'failed-diagnostics', 'failure-diagnostics', 'raw-failure'):
            tree(folder / name, prefix / name)
        for path in sorted(folder.glob('*NOTES*.md')):
            add(path, prefix / path.name)
        assembly_reviews(folder, prefix)
        if member == 'T13-sve4x32-repeat-r12':
            # A repeated run keeps separate source/log snapshots. Candidate
            # preparation may still come from the original candidate directory;
            # identify that provenance rather than imply a new runtime gate.
            for name in ('PREPARATION.md', 'VALIDATION-PLAN.md', 'STATIC-REVIEW.md'):
                preparation = folder / name
                destination = prefix / name
                if not preparation.is_file() or preparation.is_symlink():
                    preparation = RUNS / 'T13-sve4x32' / name
                    destination = prefix / 'candidate-preparation' / name
                required = name in ('PREPARATION.md', 'VALIDATION-PLAN.md')
                if not required and (not preparation.is_file() or preparation.is_symlink()):
                    continue
                add(preparation, destination, required=required)
                candidate_preparation_origins.append({
                    'run': member, 'version': VERSION_BY_MEMBER[member],
                    'document': str(destination), 'source': str(preparation.relative_to(ROOT)),
                    'note': 'Candidate preparation/static plan only; not evidence of this repeat run passing a gate.',
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
    add(Path(__file__).resolve(), 'tools/archive-r12.py', required=True)

    # Both repeats keep separate pre-r12 records. Associate each with its own
    # public r11 record and run using the known r11 job ID (no byte identity claim).
    history_archive = ROOT / 'records/evidence/trsm-stage-r11-20260912'
    expected_history_job = '1579600'
    prior_record_origins = []
    for member, prior_run in REPEAT_ORIGINS.items():
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
            'prior_public_archive': '../trsm-stage-r11-20260912/',
            'prior_public_record': '../trsm-stage-r11-20260912/records/latest/' + version + '.json',
            'prior_run_cluster': '../trsm-stage-r11-20260912/members/' + prior_run + '/cluster.json',
            'initial_baseline_archive': '../trsm-stage-r6-20260912/',
            'initial_baseline_run': '../trsm-stage-r6-20260912/members/T8-control12/',
            'expected_prior_job_id': expected_history_job,
            'prior_run_job_id': history_job or None,
            'public_record_job_id': public_record_job or None,
            'record_job_id': prior_job or None,
            'job_id_match': job_id_match, 'version_match': version_match,
            'note': 'Job ID/version association only. The r11 archive retains both prior records and their corresponding run evidence; older T8 history is referenced there. Original T8 baseline evidence is retained in r6.',
        })
        if not job_id_match or not version_match:
            missing.append(member + ' prior-record.json matching its public r11 record and job 1579600; inspect the referenced r11 archive')

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
        'schema_version': 1, 'problem': 'trsm', 'stage': 'r12-20260912',
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
        'repeat_policy': 'The r12 T8 and T13 repeats each retain a separate prior record associated by version and job 1579600 with the corresponding public r11 record. Older T8 history is referenced by r11; original T8 baseline evidence is retained in r6. Samples from separate jobs are not merged.',
        'prior_record_origins': prior_record_origins,
        'candidate_preparation_origins': candidate_preparation_origins,
        'warmup_policy': 'Warmup logs, linkage and warmup/summary.json are retained separately from timed run results; archive creation does not treat warmup as an additional measured round.',
    }
    (DEST / 'ARCHIVE.json').write_text(redact(json.dumps(document, ensure_ascii=False, indent=2)) + '\n')
    (DEST / 'README.md').write_text('''# TRSM r12 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/compare 保存本轮唯一 cohort 的控制脚本、计划、提交元数据、finish_records.py、通用预检、preflight-wide32 宽核预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。preflight-wide32 的 guard.py、run.sh、check-wide32.c 和 README.md 分别保留当前准备版与冻结提交版。参数观察生成脚本和严格结果 parser 均完整内嵌在 run.sh 的 Python heredoc 中；没有独立脚本文件。实际 preflight-wide32-results、目标汇编及已存在的 assembly review 从结果/diagnostics 或 assembly-review 目录另行收录。members 保留 T8-control12-repeat-r12、T13-sve4x32-repeat-r12、T15-svetile128 和 T16-svetile32 四个运行目录。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

宽核结果中的 instrumented-trsm.c 是仅供参数观察的预检副本，不能当作实际 benchmark 源码；trsm-wide4x32.s 则由原候选源码生成。实际已有的 summary.tsv、summary.json、completion.txt、commands.txt、guard.json，以及 guard、compiler、instrument-source、build-normal、build-no-sve、build-fail-shared、assembly、micro-t1、normal-t1、normal-t4、normal-t38、shared-fail-t4、no-sve-t4、narrow-vl-t4、verify-results 日志按原结果目录收录。三个宽核成员 T13-sve4x32-repeat-r12、T15-svetile128、T16-svetile32 分别保留自己的结果子目录，不能以其中一个成员的日志代替另一个。微核和整算子日志中的 TILE_CONFIG_PASS KB=256 CT=32/64/128，以及 summary.json 的 expected_CT、KB 和 tile_config_processes 字段按原文保留；它们记录各测试进程对实际候选 CT 的观察。参数观察仍由 ARGUMENTS_PASS 及汇总字段单独保存。检查程序二进制不归档，缺失的运行结果不生成。

T13 重复运行若没有独立 PREPARATION 或 VALIDATION-PLAN，相应文件从原 .runs/trsm/T13-sve4x32 目录收录到该 member 的 candidate-preparation 下，来源逐项记录于 candidate_preparation_origins 及文件清单；STATIC-REVIEW 仅在当前重复目录或原候选目录已有文件时收录，不补写不存在的审查报告。它们说明既有候选，不能作为 r12 运行通过验证的证据。新候选 T15-svetile128 与 T16-svetile32 各自的 PREPARATION.md 和五个源码文件均为所需材料，已有 VALIDATION-PLAN、STATIC-REVIEW 也分别保留；准备文档不作为运行验证结果。本轮 STATIC-CONTROLLER-REVIEW 另行保留，不假定重复 run 会重新撰写候选文档。

warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 下的 warmup 和原 run 结果分别保留。预热证据不作为额外计时轮次。static-readiness.json、STATIC-CONTROLLER-REVIEW 和候选静态/验证计划均为准备材料，不是编译、测试或运行验证结果。准备目录、submitted-payload、warmup 和实际取回的 diagnostics 分别保存，清单记录每份副本的来源路径；冻结快照或所需准备文件缺失会列入清单，不由当前文件补写。tools/records-kml.py 与 records-kml-NOTES.md 保存本轮登记 helper 及其作者记录的静态审查/纯元数据检查说明；没有独立保存的检查输出不会补造。

本轮 T8 与 T13 的 prior-record.json 分别保存在 T8-control12-repeat-r12 与 T13-sve4x32-repeat-r12 member 下，关联 r11 公开档的 [T8 记录](../trsm-stage-r11-20260912/records/latest/T8-control12.json)与 [T13 记录](../trsm-stage-r11-20260912/records/latest/T13-sve4x32.json)，以及对应的 [T8-control12-repeat-r11 运行](../trsm-stage-r11-20260912/members/T8-control12-repeat-r11/cluster.json)和 [T13-sve4x32-repeat-r11 运行](../trsm-stage-r11-20260912/members/T13-sve4x32-repeat-r11/cluster.json)。两份原记录及对应 run 的作业 ID 都应为 1579600；逐份关联结果见 ARCHIVE.json 的 prior_record_origins。关联失败会明确列为缺失/待核对事项，不借版本名认定。更早 T8 repeat/history 由 [r11 公开档](../trsm-stage-r11-20260912/README.md)继续引用；[原始 T8 初测](../trsm-stage-r6-20260912/members/T8-control12/)实际保存在 r6 公开档。r12 不重建或覆盖旧运行。records/latest 保存归档时的 T8-control12、T13-sve4x32、T15-svetile128 和 T16-svetile32 台账，仅按本轮 job ID 关联已有声明，不预判重复比较或晋级结论，也不把不同作业的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
''')
    print('Created public TRSM r12 archive:', DEST.relative_to(ROOT), 'text_files=', len(inventory))
    print('Missing expected/optional evidence entries:', len(missing), '; no measurements were generated or revalidated.')


if __name__ == '__main__':
    main()
