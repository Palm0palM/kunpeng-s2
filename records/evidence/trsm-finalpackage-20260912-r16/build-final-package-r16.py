#!/usr/bin/env python3
"""Build a private five-file ZIP only after T19 has actually been promoted."""
import datetime
import json
from pathlib import Path
import sys
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / '.runs/trsm/package-check-20260912-r16'))
from package_rules import NAMES, PACKAGE, SOURCES, TARGET, regular_bytes, validated_record, validate_private


def main():
    record = validated_record()
    record_path = ROOT / 'records/experiments/trsm' / (TARGET + '.json')
    record_bytes = regular_bytes(record_path)
    if json.loads(record_bytes) != record:
        raise RuntimeError('Promoted source record changed during package preparation')
    source_bytes = {name: regular_bytes(ROOT / 'trsm' / name) for name in SOURCES}
    cases = record['cases']
    source_rows = '\n'.join('| {}×{} | {:.2f} | {:.3g} |'.format(
        *case['dims'], case['median_ms'], case['max_error']) for case in cases)
    readme = '''# TRSM 提交包 — {version}

解压后进入 `trsm/`，仅在调度分配的 Linux aarch64 鲲鹏计算节点运行，使用不超过38核的单NUMA分配。

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
export CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

需要 GCC/OpenMP、numactl 和 KML/kblas。原 runner 默认链接 `-lkblas`，使用 close/cores 绑定；其指定模块可用时按原配置加载。`TEST_RUNS=3` 是每用例内部计时次数，三个独立完整套件须在同一分配下执行三次原 run.sh。

小路径保留T18的4MiB共享历史副本预算与整数溢出保护。当原SVE条件成立、历史字节数安全可算且超过预算时，T19改用8行×16列SVE历史前代核；每个线程分配一个对齐缓冲区，容纳两个连续的m×8 RHS面板。完整16列任务使用新核，不完整列任务保留原RHS8核；尾行、无SVE、窄向量宽度和分配失败继续各自原NEON/标量路径。预算内共享分配失败仍走旧路径，不能以NULL指针代替超预算条件。4MiB是实现预算，不代表机器缓存容量。原64MiB整算法选择不变。

大路径完整继承T18原实现（最初来自T13）：KB256、CT64，完整32列处使用4×32 SVE更新核，保留尾部和分配失败回退。SVE要求Linux GCC支持、真实HWCAP与每个worker恰好八double向量宽度。保留lda/ldb、L只读、非正维度行为，不按官方精确尺寸分派；算子本身不调用BLAS。

T19准备时来源T18尚未晋级。来源关系不代表通过验证；本包只在T19-panel8x16budget本身已实际验证、晋级且仍为当前TRSM best时生成，不混入其它候选或不同作业成绩。

实际晋级源码验证作业为 **{job}**：三个独立完整官方套件9/9 PASS，原精度要求1e-12；结果从当前有效晋级记录读取。

| M×N | 三轮报告均值的中位数 ms | 最大误差 |
| --- | ---: | ---: |
{rows}

合计中位数为 **{total:.2f} ms**，仅为内部耗时指标，不是官方分数或排名。该源码测量不能代替最终ZIP的独立解压复跑，也不把最终包测量用于重新计算策略增益。

实际已验证环境为 **Huawei KML25.1.0 / GCC12.3.1**，真实KML头文件、默认-lkblas及私有libgomp；**不等同指定官方KML25.2.0复验**。原benchmark、输入、计时区、1e-12容差和runner保持原样。兼容头仅供显式覆盖分支；包内没有参考库二进制。

最终ZIP独立计算节点复验和交付清单由仓库 `outputs/trsm-best.json`、`docs/trsm-final-20260912-r16.md` 单独记录。未正式提交比赛，未在本机运行题目，未计算或验证哈希。
'''.format(version=TARGET, job=record['job_id'], rows=source_rows, total=record['total_median_ms'])
    PACKAGE.mkdir()
    stage = PACKAGE / 'trsm'
    stage.mkdir()
    for name in NAMES:
        destination = stage / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(readme.encode() if name == 'README.md' else source_bytes[name])
        destination.chmod(0o755 if name == 'run.sh' else 0o644)
    (PACKAGE / 'source-record.json').write_bytes(record_bytes)
    archive_path = PACKAGE / 'trsm.zip'
    with zipfile.ZipFile(archive_path, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for name in NAMES:
            archive.write(stage / name, 'trsm/' + name)
    metadata = dict(problem='trsm', version=TARGET,
        created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        archive='trsm.zip', archive_bytes=archive_path.stat().st_size,
        files=[dict(path='trsm/' + name, bytes=(stage / name).stat().st_size,
                    mode='0755' if name == 'run.sh' else '0644') for name in NAMES],
        source_record='source-record.json', source_matches_measured_local_snapshot_by_bytes=True,
        source_validation=dict(job_id=record['job_id'], suites=3, test_runs=3, official_rows_passed=9,
            max_error=max(case['max_error'] for case in cases),
            case_median_ms=[case['median_ms'] for case in cases],
            total_median_ms=record['total_median_ms'], reference=record['reference']),
        implementation_provenance=dict(
            small_path='T19 8x16 forward-history kernel only for safely computed over-budget small path; paired RHS8 scratch',
            large_path='Unchanged complete T18 suffix, originally T13-sve4x32, from KB256/CT64 enum',
            immediate_source='T18-budgetwide',
            derivation_sources_promoted_when_combined=False,
            final_target_requires_own_verified_promotion=True,
            packed_history_budget_bytes=4*1024*1024, KB=256, CT=64),
        package_validation='private prepared ZIP; independent compute-node extraction and three suites pending',
        official_kml252_revalidated=False, hash_validation='not performed at user request',
        local_compilation_or_tests=False, contest_submission=False, unvalidated_candidate_included=False,
        published=False)
    with (PACKAGE / 'metadata.json').open('x') as handle:
        json.dump(metadata, handle, ensure_ascii=False, indent=2); handle.write('\n')
    validate_private()
    print('Private package prepared:', TARGET, metadata['archive_bytes'], 'bytes; outputs and main README untouched')


if __name__ == '__main__':
    main()
