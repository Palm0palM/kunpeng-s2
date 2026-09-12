#!/usr/bin/env python3
"""Publish only an independently verified exact private T19 source ZIP."""
import copy
import datetime
import io
import json
import os
from pathlib import Path
import re
import sys
import tarfile
import uuid

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / '.runs/trsm/package-check-20260912-r16'))
from package_rules import HERE, PACKAGE, TARGET, audit_collected, read_json, records_module, regular_bytes

SUBMITTED_FILES = ('remote_job.sh', 'run-three-suites.sh', 'probe.sh',
                   'target-environment.sh', 'required-symbols.c', 'audit-dependencies.py',
                   'package-metadata.json')


def submitted_payload_snapshot(zip_bytes):
    """Read the prepared upload snapshot, never substitute current scripts."""
    frozen = {name: regular_bytes(HERE / 'payload' / name) for name in SUBMITTED_FILES}
    if frozen['package-metadata.json'] != regular_bytes(PACKAGE / 'metadata.json'):
        raise RuntimeError('Submitted package metadata differs from the validated private package')
    expected = dict(frozen, **{'trsm.zip': zip_bytes})
    upload_bytes = regular_bytes(HERE / 'payload.tar.gz')
    with tarfile.open(fileobj=io.BytesIO(upload_bytes), mode='r:gz') as upload:
        entries = upload.getmembers()
        if (sorted(entry.name for entry in entries) != sorted(expected)
                or any(not entry.isfile() for entry in entries)):
            raise RuntimeError('Prepared upload archive has missing, duplicate or unexpected members')
        for name, data in expected.items():
            if upload.extractfile(name).read() != data:
                raise RuntimeError('Frozen submitted payload differs from prepared upload: ' + name)
    return frozen, upload_bytes


def json_bytes(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode()


def atomic_write(path, data):
    temporary = path.parent / ('.' + path.name + '.r16-' + uuid.uuid4().hex + '.tmp')
    try:
        with temporary.open('xb') as handle:
            handle.write(data); handle.flush(); os.fsync(handle.fileno())
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def main():
    checked = audit_collected()
    result, observed = checked['result'], checked['observed']
    meta = copy.deepcopy(checked['metadata'])
    job = str(checked['group']['job_id'])
    timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat()
    archive = ROOT / 'records/evidence/trsm-finalpackage-20260912-r16'
    document = ROOT / 'docs/trsm-final-20260912-r16.md'
    backup = PACKAGE / 'publication-backup'
    stage = PACKAGE / 'publication-stage'
    marker = PACKAGE / 'publication.json'
    for path in (archive, document, backup, stage, marker):
        if path.exists() or path.is_symlink():
            raise RuntimeError('Do not overwrite an existing finalization attempt: ' + str(path))
    outputs = [ROOT / 'outputs/trsm-best.zip', ROOT / 'outputs/trsm-best.json', ROOT / 'trsm/README.md']
    old = {path: regular_bytes(path) for path in outputs}
    zip_bytes = regular_bytes(PACKAGE / 'trsm.zip')
    frozen_submitted, upload_bytes = submitted_payload_snapshot(zip_bytes)
    meta.update(archive='trsm-best.zip', published=True, published_at=timestamp,
        official_kml252_revalidated=False, release_tag='trsm-t19-panel8x16budget-20260912-r16',
        package_validation=dict(status='passed', job_id=job, suites=3, test_runs=3,
            official_rows_passed=9, max_error=max(case['max_error'] for case in result['cases']),
            case_median_ms=[case['median_ms'] for case in result['cases']],
            total_median_ms=result['total_median_ms'], reference='Huawei KML 25.1.0; not specified KML 25.2.0',
            actual_compiler='GCC 12.3.1', true_kml251_and_private_gomp_all_suites=True,
            package_extracted_and_tested=True, same_uploaded_and_returned_zip_bytes=True,
            scheduler_succeeded=True, wrapper_exit_code=0))
    rows = '\n'.join('| {}×{} | {} | {:.2f} | {:.3g} |'.format(
        *case['dims'], ' / '.join('{:.2f}'.format(value) for value in case['times_ms']),
        case['median_ms'], case['max_error']) for case in result['cases'])
    doc = '''# TRSM 最终交付：{version}

提交包为当前实际晋级的 **{version}**，五个源码/说明文件，ZIP大小 **{size} bytes**。下载 [trsm-best.zip](../outputs/trsm-best.zip)，仅在调度分配的鲲鹏计算节点运行包内原run.sh；复现设置见包内README。

源码晋级前的有效测量来自作业 **{source_job}**；最终ZIP另在作业 **{job}** 独立解压完成三个完整官方套件。调度器成功、wrapper退出0、三个套件9/9 PASS，原容差1e-12。每用例TEST_RUNS=3，表中每个样本是该套件报告的内部计时均值。

| M×N | 三套报告均值 ms | 中位数 ms | 最大误差 |
| --- | --- | ---: | ---: |
{rows}

中位数合计 **{total:.2f} ms**，只是内部耗时指标，不是官方得分。此独立包验证不与此前作业混算增益，也不代替同分配优化比较。

实际环境为 **Huawei KML25.1.0 / GCC12.3.1**、38线程单NUMA；真实KML头文件、默认-lkblas及每套实际KML/私有libgomp依赖均已核对。**尚未完成指定官方KML25.2.0复验**。原benchmark、尺寸、精度、计时区和runner未修改。

本次从私有ZIP上传，计算节点检查解压五文件在运行前后与ZIP逐字节一致，并取回实际ZIP及解压源码再次核对本地私有原件。检查没有计算或验证哈希；这是直接字节与实际日志验证，不能宣称验证了历史远端源码身份。发布前备份旧outputs和主README，旧证据原件继续保留。

证据：[三套日志](../records/evidence/trsm-finalpackage-20260912-r16/benchmark.log)、[调度器状态](../records/evidence/trsm-finalpackage-20260912-r16/scheduler-status.txt)、[依赖审计](../records/evidence/trsm-finalpackage-20260912-r16/linkage.log)、[ZIP检查](../records/evidence/trsm-finalpackage-20260912-r16/zip-validation.json)、[包清单](../outputs/trsm-best.json)。公开证据是脱敏文本副本，未脱敏原件留在私有目录。

本包是T19-panel8x16budget本身通过并晋级后的完整实现：小路径仅在安全计算的历史副本超过4MiB预算时使用8×16 SVE历史前代和两个连续RHS8面板，预算内/无SVE/失败回退保持对应路径；大路径保留T18的4×32 SVE更新、KB256/CT64及完整尾部/回退。来源T18在准备时未晋级，不能代替T19自己的同环境验证。只发布这一实际晋级实现，不拼接不同作业成绩。未在本机编译或运行题目，未提交比赛，未更改其他主文档或总结。
'''.format(version=TARGET, size=len(zip_bytes), source_job=meta['source_validation']['job_id'],
           job=job, rows=rows, total=result['total_median_ms'])
    main_readme = regular_bytes(PACKAGE / 'trsm/README.md').decode()
    main_readme += ('\n最终ZIP独立计算节点复验：作业 **{}**，三个完整套件9/9 PASS，'
                    '中位数合计 **{:.2f} ms**；实际KML25.1/GCC12，非指定KML25.2复验。'
                    '详见 [最终交付](../docs/trsm-final-20260912-r16.md)。\n').format(job, result['total_median_ms'])
    cfg = read_json(ROOT / '.runs/trsm/optimization-20260912-r16-compare/cluster.local.json')
    replacements = [(str(Path.home()), '/LOCAL_USER_HOME')]
    for value, replacement in ((cfg.get('host'), 'CLUSTER_HOST'), (cfg.get('user'), 'CLUSTER_USER'),
                               (observed['machine'].get('HOST'), 'COMPUTE_NODE')):
        if isinstance(value, str) and value:
            replacements.append((value, replacement))

    def redact(text):
        text = re.sub(r'/LOCAL_USER_HOME/\s\"\']+', '/LOCAL_USER_HOME', text)
        text = re.sub(r'/CLUSTER_USER_HOME/)?[^/\s\"\']+', '/CLUSTER_USER_HOME', text)
        for original, replacement in sorted(replacements, key=lambda pair: len(pair[0]), reverse=True):
            text = text.replace(original, replacement)
        text = re.sub(r'(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?![\d.])', 'REDACTED_IP', text)
        return re.sub(r'(?im)^(\s*(?:account|user|username|login)\s*[:=]?\s+)\S+', r'\1REDACTED', text)

    required = ('benchmark.log', 'environment.log', 'exit-code.txt', 'scheduler-status.txt',
                'cluster.json', 'linkage.log', 'wrapper.stdout.log', 'zip-validation.json',
                'result.json', 'submission.json', 'probe.log', 'probe-ldd.log',
                'compiler-environment.log', 'omp-runtime-symbol.log', 'runtime-settings.json',
                'job_control.py', 'remote_job.sh', 'run-three-suites.sh', 'package_rules.py',
                'probe.sh', 'target-environment.sh', 'required-symbols.c', 'audit-dependencies.py', 'README.md')
    public = {name: redact(regular_bytes(HERE / name).decode()).encode() for name in required}
    for name in ('build-final-package-r16.py', 'finalize-r16.py'):
        public[name] = redact(regular_bytes(ROOT / '.runs/trsm' / name).decode()).encode()
    for name, data in frozen_submitted.items():
        public['submitted-payload/' + name] = redact(data.decode()).encode()
    public['package-metadata.json'] = json_bytes(meta)
    current_tools = ('job_control.py', 'remote_job.sh', 'run-three-suites.sh', 'package_rules.py',
                     'probe.sh', 'target-environment.sh', 'required-symbols.c',
                     'audit-dependencies.py', 'README.md')
    provenance = [dict(path='submitted-payload/' + name,
                       source=str((HERE / 'payload' / name).relative_to(ROOT)),
                       role='prepared_upload_snapshot') for name in SUBMITTED_FILES]
    provenance.extend(dict(path=name, source=str((HERE / name).relative_to(ROOT)),
                           role='current_local_tool_or_document_not_submitted_snapshot')
                      for name in current_tools)
    provenance.extend(dict(path=name, source=str((ROOT / '.runs/trsm' / name).relative_to(ROOT)),
                           role='current_local_tool_not_submitted_snapshot')
                      for name in ('build-final-package-r16.py', 'finalize-r16.py'))
    public['ARCHIVE.json'] = json_bytes(dict(created_at=timestamp, job_id=job, source_version=TARGET,
        public_redacted_derivative=True, original_evidence_retained=True,
        provenance=provenance,
        submitted_payload_policy='Six frozen scripts and original metadata come only from payload; '
            'their bytes match the prepared upload tar. Current tools are separately identified. '
            'This is a local upload-snapshot association, not a remote script byte-identity claim.',
        published_metadata_policy='Top-level package-metadata.json includes publication fields; '
            'submitted-payload/package-metadata.json preserves the original prepared metadata.',
        hash_validation='not performed', files=[dict(path=name, bytes=len(data)) for name, data in public.items()]))
    # All gates and text production complete before any published file changes.
    if (audit_collected() != checked
            or submitted_payload_snapshot(zip_bytes) != (frozen_submitted, upload_bytes)
            or any(regular_bytes(path) != data for path, data in old.items())):
        raise RuntimeError('Validated inputs or current published files changed during finalization')
    backup.mkdir()
    for path, data in old.items():
        label = 'main-README.md' if path.name == 'README.md' else path.name
        (backup / label).write_bytes(data)
    stage.mkdir()
    staged_archive = stage / 'evidence'
    staged_archive.mkdir()
    for name, data in public.items():
        destination = staged_archive / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
    replacements_out = {outputs[0]: zip_bytes, outputs[1]: json_bytes(meta),
                        outputs[2]: main_readme.encode(), document: doc.encode()}
    written = []
    try:
        os.rename(staged_archive, archive)
        for path, data in replacements_out.items():
            if path in old:
                if regular_bytes(path) != old[path]:
                    raise RuntimeError('Published file changed before replacement: ' + str(path))
            elif path.exists() or path.is_symlink():
                raise RuntimeError('New document appeared before publication: ' + str(path))
            atomic_write(path, data); written.append(path)
    except BaseException as error:
        rollback_errors = []
        for path in reversed(written):
            try:
                if regular_bytes(path) != replacements_out[path]:
                    raise RuntimeError('Concurrent publication change retained without rollback: ' + str(path))
                if path in old:
                    atomic_write(path, old[path])
                else:
                    path.unlink()
            except BaseException as rollback_error:
                rollback_errors.append(str(rollback_error))
        if archive.exists() and not staged_archive.exists():
            try:
                os.rename(archive, staged_archive)
            except BaseException as rollback_error:
                rollback_errors.append(str(rollback_error))
        marker.write_bytes(json_bytes(dict(status='publication_failed', error=str(error),
                                          rollback_errors=rollback_errors, backup=str(backup.relative_to(ROOT)))))
        raise
    marker.write_bytes(json_bytes(dict(status='published', version=TARGET, job_id=job,
        published_at=timestamp, archive_bytes=len(zip_bytes), backup=str(backup.relative_to(ROOT)),
        public_evidence=str(archive.relative_to(ROOT)), document=str(document.relative_to(ROOT)),
        contest_submission=False, hash_operations=False)))
    print('Published verified exact private package:', TARGET, 'job', job, len(zip_bytes), 'bytes')


if __name__ == '__main__':
    with records_module().locked():
        main()
