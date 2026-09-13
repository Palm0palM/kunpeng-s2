"""Summarize the original completed Y evidence only; no jobs or record writes."""
import hashlib
import json
import math
from pathlib import Path
import re
import statistics
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / '.runs/conv'
ORDER = ['C26-r28', 'C52-r1', 'C26-r29']
DIMS = [[4096, 6144, 39, 39], [6144, 4096, 41, 41], [4256, 6390, 55, 55], [6390, 4256, 81, 81]]


def read(path):
    return json.loads(path.read_text())


def write_new(path, obj):
    with path.open('x') as output:
        json.dump(obj, output, indent=2, ensure_ascii=False)
        output.write('\n')


def main():
    plan = read(BASE / 'sep13y-campaign.json')
    compare = read(BASE / 'sep13y-lifecycle-compare.stdout.log')
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1582410'
    assert plan['measurement_order'] == ORDER and plan['confirmation_passed'] is False
    assert compare['results'] == plan['results'] and compare['confirmation_passed'] is False
    assert plan['samples_mixed_with_initial_round'] is False and plan['prior_decisions_unchanged'] is True
    assert plan['prior_job'] == '1582256' and plan['initial_qualification_passed'] is True
    assert plan['prior_decisions']['S_confirmation_passed'] is False
    records = {name: read(ROOT / 'records/experiments/conv' / (name + '.json')) for name in ORDER}
    row_re = re.compile(r'^\s*(\d+)\s+x\s+(\d+)\s+(\d+)\s+x\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\deE+.\-]+)\s+(PASS|FAIL)\s*$', re.M)
    members = []
    for name, row in zip(ORDER, plan['results']):
        run = BASE / name
        rec = records[name]
        cluster = read(run / 'cluster.json')
        status = cluster['scheduler_status']
        assert cluster['job_id'] == rec['job_id'] == '1582410'
        assert cluster['measurement_order'] == ORDER and cluster['group'] == plan['performance_group']
        assert status['state'] == 'SUCCEEDED' and status['jobExitCode'] == status['systemExitCode'] == 0
        assert cluster['status_returncode'] == 0 and cluster['fetch_state'] == 'complete'
        assert rec['status'] == 'passed' and rec['verified'] is True and all(rec['checks'].values())
        assert rec['source_hashes'] == cluster['source_hashes']
        wrapper_exit = int((run / 'exit-code.txt').read_text().strip())
        assert wrapper_exit == 0
        log = (run / 'benchmark.log').read_text()
        samples = row_re.findall(log)
        assert len(samples) == 12 and all(x[-1] == 'PASS' and float(x[-2]) == 0 for x in samples)
        assert [list(map(int, x[:4])) for x in samples] == DIMS * 3
        arrays = [[float(samples[suite * 4 + case][4]) for suite in range(3)] for case in range(4)]
        assert arrays == row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        medians = [statistics.median(values) for values in arrays]
        spreads = [(max(values) - min(values)) / median * 100 for values, median in zip(arrays, medians)]
        assert medians == row['cases_ms'] == [case['median_ms'] for case in rec['cases']]
        assert all(math.isclose(a, b, abs_tol=1e-12) for a, b in zip(spreads, row['case_spreads_pct']))
        assert math.isclose(sum(medians), row['total_median_ms'], abs_tol=1e-12)
        begins = re.findall(r'^BENCH_REPEAT (\d)/3 BEGIN$', log, re.M)
        ends = re.findall(r'^BENCH_REPEAT (\d)/3 END$', log, re.M)
        assert begins == ends == ['1', '2', '3'] and len(re.findall(r'^PASS cases: 4;', log, re.M)) == 3
        assert rec['machine'] == records[ORDER[0]]['machine']
        assert rec['settings'] == cluster['settings'] == plan['settings']
        members.append(dict(version=name, record='records/experiments/conv/' + name + '.json',
            run=str(run.relative_to(ROOT)), scheduler=status, status_returncode=cluster['status_returncode'],
            wrapper_exit_code=wrapper_exit, checks=rec['checks'], raw_case_pass_count=len(samples),
            raw_suite_summary_count=3, repeat_begins=begins, repeat_ends=ends,
            source_hashes=rec['source_hashes'], artifact_hashes_from_fetch=cluster['artifacts_sha256'],
            log_sha256_from_record=rec['log_sha256'], cases=rec['cases'], result=row))
    candidate = records['C52-r1']
    assert candidate['diagnostic_job_id'] == '1582134'
    assert candidate['diagnostic_source_sha256'] == candidate['source_hashes']['conv2d.c'] == '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'
    opening, closing = candidate['opening_control_comparison'], candidate['comparison']
    assert opening['eligible'] is True and closing['eligible'] is False
    assert all(case['gain_pct'] >= -1 for gate in (opening, closing) for case in gate['cases'])
    steps = [read(BASE / ('sep13y-lifecycle-' + step + '.exit.json')) for step in ['status-1', 'status-2', 'status-3', 'record', 'compare']]
    assert all(step['exit_code'] == 0 for step in steps)
    assert all((ROOT / step['stderr']).read_bytes() == b'' for step in steps)
    best = read(ROOT / 'records/best.json')
    assert best['conv'] == 'C26-r1'
    absent = ['.runs/conv/C52-package', 'records/experiments/conv/C52-package.json', 'conv/result/C7']
    assert all(not (ROOT / path).exists() for path in absent)
    known_tool_hashes = {
        'sep13y-submit-performance.py': '20f754a5b1c60d02426022d079090013c34eef1723c2150f6152806b0802b307',
        'sep13y-record-group.py': 'a3879b88987627c0650a2d113f28d3f63ea113c8d12465d0f988bd00bab70b97',
        'sep13y-compare.py': 'e9ec8863a71eebea7fa3a79e4b69dd71cdf31726b107d48ffeaf0308c650c1d1',
        'sep13y-README.md': '8d559175e862d101b139b76a6bcee2ab4bdc32c3be764413a21043a1c0dda6cb',
    }
    for filename, digest in known_tool_hashes.items():
        assert hashlib.sha256((BASE / filename).read_bytes()).hexdigest() == digest
    summary = dict(round='sep13y', lifecycle_complete=True, job_id='1582410',
        group=plan['performance_group'], measurement_order=ORDER, confirmation_passed=False,
        total_original_samples=36, total_raw_case_passes=sum(m['raw_case_pass_count'] for m in members),
        total_raw_suite_summaries=9, settings=plan['settings'], machine=records[ORDER[0]]['machine'],
        members=members, opening_gate=opening, closing_gate=closing, actual_outer_steps=steps,
        lifecycle_failures=[], original_tool_hashes_unchanged=known_tool_hashes,
        submit_provenance=read(BASE / 'sep13y-lifecycle-submit-completion.json'),
        tool_completion_provenance=dict(status_1=dict(exit_code=0, chunk_id='1834db'),
            status_2=dict(exit_code=0, chunk_id='653e6a'), status_3=dict(exit_code=0, chunk_id='381b5c'),
            record=dict(session_id=70810, initial_chunk_id='e44e56', final_chunk_id='54b3c8', exit_code=0),
            compare=dict(chunk_id='786ce5', exit_code=0)),
        initial_qualification=dict(job_id=plan['prior_job'], passed=True, samples_mixed=False),
        diagnostic=dict(job_id=candidate['diagnostic_job_id'], source_version=candidate['diagnostic_source_version'],
            source_sha256=candidate['diagnostic_source_sha256'], evidence_directory=candidate['diagnostic_evidence_directory'], expected_checks=37128),
        best_retained=dict(label='C6', internal_version=best['conv']), absent_paths_checked=absent,
        prior_decisions_unchanged=plan['prior_decisions_unchanged'], failed_confirmation_retry_allowed=False,
        automatic_packaging=False, automatic_promotion=False, official_score=None,
        local_operator_compilation_or_testing=False, reset_used=False,
        usage_checks=[dict(path=str(p.relative_to(ROOT)), **read(p)) for p in sorted(BASE.glob('sep13y-lifecycle-usage-*.json'))],
        recorded_at=datetime.now(timezone.utc).isoformat())
    write_new(BASE / 'sep13y-lifecycle-summary.json', summary)
    lines = ['# CONV sep13Y：C52 独立确认未通过', '',
        '原作业 **1582410** 按 C26-r28 → C52-r1 → C26-r29 顺序完成。36 个原始逐例结果全部 PASS、最大误差均为 0；9 条 suite 汇总各为 4 PASS。原 record 与 compare 各执行一次且退出 0，未改变工具 schema。**confirmation_passed=false，保留 C6（内部版本 C26-r1）。**', '',
        '四例中位数之和分别为 **452.40 / 436.68 / 452.56 ms**。这是内部耗时指标，官方分数未知。结尾对照 A 的 61.24 ms 慢样本完整保留；不重跑本次失败确认，也不混用 W 与 Y 样本。', '',
        '| 版本 | 例 | 三次原始耗时（ms） | 中位数（ms） | spread（%） |', '|---|---|---|---:|---:|']
    for member in members:
        for index, case in enumerate(member['cases']):
            lines.append('| ' + member['version'] + ' | ' + 'ABCD'[index] + ' | ' + ' / '.join(f'{x:.2f}' for x in case['times_ms']) + f" | {case['median_ms']:.2f} | {case['spread_pct']:.9f} |")
    lines += ['', 'A/B/C/D 尺寸依次为 4096×6144 / 39×39、6144×4096 / 41×41、4256×6390 / 55×55、6390×4256 / 81×81。spread=(max−min)/median×100%，使用全部三次样本。', '',
        '| 对照 | 总收益（%） | 门槛（%） | 结果 |', '|---|---:|---:|---|']
    for gate in (opening, closing):
        lines.append(f"| {gate['baseline']} | {gate['total_gain_pct']:.9f} | {gate['threshold_pct']:.9f} | {'通过' if gate['eligible'] else '未通过'} |")
    lines += ['', '规则要求总收益严格超过 max(1%, 双方所有例的 spread)，且每例退步不超过 1%。开头门槛为 1%；结尾 A 的 51.48 / 61.24 / 51.50 ms 使门槛达到 18.951456311%，高于总收益 3.508926993%。', '',
        '| 例 | 相对开头收益（%） | 相对结尾收益（%） |', '|---|---:|---:|']
    for index, (a, b) in enumerate(zip(opening['cases'], closing['cases'])):
        lines.append(f"| {'ABCD'[index]} | {a['gain_pct']:.9f} | {b['gain_pct']:.9f} |")
    lines += ['', 'A 的退步分别为 0.330546374% 和 0.194174757%，均在 1% 限制内。失败来自结尾对照的全样本波动门槛，未删除或替换慢样本。', '',
        '三次外层 status 进程均退出 0，状态依次为 RUNNING、RUNNING、SUCCEEDED；前两次 job/system 退出码尚为空，最终均为 0。record 再核对三个成员的原作业 SUCCEEDED、job/system 退出码 0；三个 wrapper 退出码均为 0。record/compare 外层退出码均为 0，所有五次外层 stderr 为空，未发生生命周期失败或重试。', '',
        '环境为 COMPUTE_NODE_1、aarch64、GCC 10.3.1、generic、38 线程，OMP_DYNAMIC=FALSE、close/cores、单一 NUMA 3（CPU 114–151）；调度资源为 38 CPU、24576 MiB、1 packed NUMA、1800 秒。编译和测试均在调度计算节点完成。', '',
        'C52-r1 与 C52-row7x3shared2 的源码完全关联，conv2d.c SHA256 为 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`；README、bench_conv.c、run.sh 与两端 C6 对照一致。其独立 T 作业 1582134 的冻结诊断为 37128 检查，路径 `.runs/conv/C52-row7x3shared2/sve-correctness-sep13t`；该诊断不计入 Y 的 36 个性能样本。', '',
        'W1582256 初筛通过，与 Y1582410 独立确认分开保留。S1582067 的 C51 确认失败和 W 的 C51 仅参考身份保持原结论。Y 不生成新 ZIP、不晋级；C52-package 实验与 C7 提交目录均未创建，Z 工具保持准备状态。未使用重置卡。', '',
        '原始证据：三个成员各自的 benchmark.log、environment.log、source-sha256.txt、exit-code.txt、scheduler-status.txt、status/fetch driver 日志和 remote-results；对应 records/experiments/conv 下的三个记录，以及 `.runs/conv/sep13y-campaign.json`。完整数值和退出证据见 `.runs/conv/sep13y-lifecycle-summary.json`，精确路径清单见 `.runs/conv/sep13y-lifecycle-files.json`。提交来源摘要明确标记为 root 工具输出（PTY 19585、chunk b5f1f2、exit 0），未伪造原始提交 stdout。', '']
    with (ROOT / 'docs/CONV_SEP13Y.md').open('x') as output:
        output.write('\n'.join(lines))
    print(json.dumps(dict(report='docs/CONV_SEP13Y.md', summary='.runs/conv/sep13y-lifecycle-summary.json', original_samples=36, confirmation_passed=False)))


if __name__ == '__main__':
    main()
