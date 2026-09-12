"""Write the W report once, after root/lifecycle confirms original completion.

Usage after all 48 samples are recorded and compared:
  python3 .runs/conv/sep13w-write-report.py --confirmed-complete-job 1582256

Only lightweight local JSON/log processing and exclusive report creation.
No SSH, operator, record/campaign update, reservation, ZIP or promotion.
"""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
ORDER = ['C26-r26', 'C52-row7x3shared2', 'C51-r2', 'C26-r27']
CANDIDATE, REFERENCE, JOB = ORDER[1], ORDER[2], '1582256'
DIMS = [[4096, 6144, 39, 39], [6144, 4096, 41, 41],
        [4256, 6390, 55, 55], [6390, 4256, 81, 81]]


def read(path):
    return json.loads(path.read_text())


def load_completed():
    # Import only the standard local log parser/comparison after explicit CLI
    # confirmation; never import or call any submission/lifecycle main.
    sys.dont_write_bytecode = True
    sys.path.insert(0, str(ROOT / 'tools'))
    import experiment as e
    import cluster as c

    plan = read(ROOT / '.runs/conv/sep13w-campaign.json')
    assert plan['round'] == 'sep13w' and plan['status'] == 'performance_complete'
    assert plan['performance_job'] == JOB and plan['measurement_order'] == ORDER
    assert plan['candidate_versions'] == [CANDIDATE] and plan['reference_only_versions'] == [REFERENCE]
    assert plan['opening_control'] == ORDER[0] and plan['primary_baseline'] == ORDER[-1]
    assert plan['suites_per_member'] == 3 and plan['expected_benchmark_cases'] == 48
    assert plan['submitted'] is True and plan['submit_attempted'] is True
    assert plan['prior_decisions_unchanged'] is True and plan['final_selection'] is None
    assert all(plan[k] is False for k in ('automatic_confirmation', 'automatic_promotion', 'automatic_packaging'))
    comparison_run = read(ROOT / '.runs/conv/sep13w-lifecycle-compare.json')
    assert comparison_run['job_id'] == JOB and comparison_run['exit_code'] == 0
    assert comparison_run['stdout'] == '.runs/conv/sep13w-lifecycle-compare.stdout.json'
    compared = read(ROOT / comparison_run['stdout'])
    assert compared == dict(round='sep13w', results=plan['results'], prior_decisions_unchanged=True)
    records = {v: read(ROOT / 'records/experiments/conv' / (v + '.json')) for v in ORDER}
    rows = {r['version']: r for r in plan['results']}
    assert list(rows) == ORDER and len(plan['results']) == 4
    for name, rec in records.items():
        run = ROOT / '.runs/conv' / name
        manifest = read(run / 'cluster.json')
        assert rec['version'] == name and rec['status'] == 'passed' and rec['verified'] is True
        assert rec['job_id'] == manifest['job_id'] == JOB and rec['repeats'] == 3
        assert rec['settings'] == manifest['settings'] == plan['settings']
        assert rec['environment'] == plan['record_environment'] and rec['reference'] == plan['record_reference']
        assert set(rec['checks']) == {'scheduler', 'fetched_log', 'benchmark', 'wrapper', 'source_hashes', 'machine'}
        assert all(value is True for value in rec['checks'].values())
        assert manifest['measurement_order'] == ORDER and manifest['group_index'] == ORDER.index(name)
        assert manifest['group'] == plan['performance_group'] and rec['source_hashes'] == manifest['source_hashes']
        status = manifest['scheduler_status']
        assert status.get('state', status.get('status')) == 'SUCCEEDED' and str(status['jobId']) == JOB
        assert type(status['jobExitCode']) is int and type(status['systemExitCode']) is int
        assert status['jobExitCode'] == status['systemExitCode'] == 0
        assert c.parse_scheduler_status((run / 'scheduler-status.txt').read_text(), JOB) == status
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        raw = (run / 'benchmark.log').read_text()
        parsed = e.parse_log('conv', raw, 3)
        assert parsed['cases'] == rec['cases'] and parsed['total_median_ms'] == rec['total_median_ms']
        assert [case['dims'] for case in rec['cases']] == DIMS
        assert all(len(case['times_ms']) == 3 for case in rec['cases'])
        assert re.findall(r'^BENCH_REPEAT ([1-3])/3 (BEGIN|END)$', raw, re.M) == [
            (str(i), phase) for i in (1, 2, 3) for phase in ('BEGIN', 'END')]
        assert rec['machine'] == e.machine_profile(run, raw) == records[ORDER[-1]]['machine']
        assert rec['machine']['compiler_banners'] == ['gcc (GCC) 10.3.1']
        assert rec['machine']['ARCH'] == 'aarch64' and rec['machine']['OMP_NUM_THREADS'] == '38'
        assert rec['machine']['CPU_TARGET'] == 'generic'
        row = rows[name]
        assert row['total_median_ms'] == rec['total_median_ms']
        assert row['cases_ms'] == [case['median_ms'] for case in rec['cases']]
        assert row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        assert row['case_spreads_pct'] == [case['spread_pct'] for case in rec['cases']]
        assert row['max_spread_pct'] == max(row['case_spreads_pct'])
        assert row['gain_pct'] == (1 - rec['total_median_ms'] / records[ORDER[-1]]['total_median_ms']) * 100
        assert row['qualified_for_confirmation'] == rec['qualified_for_confirmation']
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 48
    assert records[ORDER[0]]['source_hashes'] == records[ORDER[-1]]['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    candidate, reference = records[CANDIDATE], records[REFERENCE]
    assert candidate['reference_only'] is False and candidate['promotion_allowed'] is True
    assert reference['reference_only'] is True and reference['promotion_allowed'] is False
    assert reference['qualified_for_confirmation'] is False
    gates = []
    for control, field in ((ORDER[0], 'opening_control_comparison'), (ORDER[-1], 'comparison'),
                           (REFERENCE, 'source_parent_reference_comparison')):
        base = records[control]
        actual = dict(baseline=control, **e.comparison(base, candidate),
            total_gain_pct=(base['total_median_ms'] - candidate['total_median_ms']) / base['total_median_ms'] * 100,
            threshold_pct=max([1.0] + [case['spread_pct'] for case in base['cases'] + candidate['cases']]))
        assert candidate[field] == rows[CANDIDATE][field] == actual
        gates.append(actual)
    assert candidate['qualified_for_confirmation'] is all(g['eligible'] for g in gates[:2])
    assert plan['confirmation_pending'] == ([CANDIDATE] if candidate['qualified_for_confirmation'] else [])
    assert candidate['source_parent_comparison_supported_in_initial_group'] == gates[2]['eligible']
    for name, source, job, suffix in ((CANDIDATE, CANDIDATE, '1582134', 't'),
                                       (REFERENCE, 'C51-row7x3u1', '1581822', 'q')):
        rec = records[name]
        assert rec['source_parent'] == plan['source_parents'][name] == 'C51-row7x3u1'
        assert rec['source_hashes'] == plan['candidate_source_hashes'][name]
        assert rec['diagnostic_source_version'] == plan['diagnostic_source_versions'][name] == source
        assert str(rec['diagnostic_job_id']) == str(plan['diagnostic_jobs'][name]) == job
        frozen = ROOT / '.runs/conv' / source / ('sve-correctness-sep13' + suffix)
        diag = read(frozen / 'validation.json')
        assert diag['candidate'] == source and diag['job_id'] == job
        assert diag['status'] == 'passed' and diag['complete'] is True
        assert diag['total_cases'] == plan['diagnostic_expected_checks'][name] == 37128
        assert diag['source_hashes']['conv2d.c'] == rec['source_hashes']['conv2d.c']
        assert read(frozen / 'freeze-source.json')['mode'] == 'passed'
    s = read(ROOT / '.runs/conv/sep13s-campaign.json')
    assert s['status'] == 'performance_complete' and s['performance_job'] == '1582067'
    assert s['confirmation_passed'] is False and e.get_record('conv', 'C51-r1')['confirmation_passed'] is False
    assert plan['prior_decisions']['S_confirmation_passed'] is False
    settings = plan['settings']; resources = settings['scheduler_resources']
    assert settings['bench_repeats'] == 3 and resources['cpus'] == 38 and resources['memory_mb'] == 24576
    assert resources['numa_count'] == 1 and resources['numa_distribution'] == 'pack'
    best = read(ROOT / 'outputs/conv-best.json')
    best_version = read(ROOT / 'records/best.json')['conv']
    assert best['experiment'] == best_version and best['source_hashes'] == e.get_record('conv', best_version)['source_hashes']
    return plan, records, rows, gates, best['label'], best_version


def generate(plan, records, rows, gates, best_label, best_version):
    qualified = records[CANDIDATE]['qualified_for_confirmation']
    verdict = ('C52 达到两端 C6 的初筛门槛，下一步须由 root 单独决定。' if qualified
               else 'C52 未达到两端 C6 的全部初筛门槛，本轮不具备独立确认资格。')
    best_sentence = f'生成报告时，已登记的当前最佳为 **{best_label}（{best_version}）**。'
    text = ['# CONV：C52 shared 两列展开的原 benchmark 对照', '', verdict + best_sentence,
        'C52 是本轮唯一候选；C51-r2 始终仅作参考，不能据本轮取得确认或晋级资格。', '',
        f'超算原作业 **{JOB}**，固定顺序 **C26-r26（C6）→ C52-row7x3shared2 → C51-r2（参考）→ C26-r27（C6）**。'
        '每成员三个独立完整原 benchmark 套件，合计 **48/48 PASS**，调度成功且 job/system/wrapper 退出均为0。'
        '数值通过与性能初筛分别判断。', '',
        '实际为同一次分配、GCC10.3.1、generic、38线程、24GiB、单NUMA，原 benchmark/runner、输入、参考和精度设置保持。'
        '每个样本为一套原 benchmark 打印的耗时；合计为四例各自三套打印值的中位数之和，仅是内部耗时指标，不是官方分数。', '',
        '| 版本 | A/B/C/D 中位数 ms | 合计 ms | 对结束C6改善 | 最大逐例波动 | 角色/结论 |',
        '| --- | --- | ---: | ---: | ---: | --- |']
    for name in ORDER:
        rec, row = records[name], rows[name]
        role = ('未改源码的C6对照' if name in (ORDER[0], ORDER[-1]) else '仅参考，不晋级' if name == REFERENCE
                else '通过初筛，待独立决定' if qualified else '未通过初筛')
        text.append('| ' + name + ' | ' + ' / '.join(f'{c["median_ms"]:.2f}' for c in rec['cases'])
            + f' | {rec["total_median_ms"]:.2f} | {row["gain_pct"]:.6f}% | {row["max_spread_pct"]:.6f}% | {role} |')
    text += ['', '## 两端 C6 门槛与辅助比较', '',
        'C52 必须分别对两端C6满足：总改善严格大于max(1%,双方全部case波动)，且任何case（包括A）退步不超过1%。'
        '波动=(最大样本−最小样本)/中位数。百分比显示6位小数，判定沿用完整精度；慢样本全部保留。', '',
        '| C52 对照 | 合计改善 | 门槛 | A改善 | B改善 | C改善 | D改善 | 通过 | 原因 |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |']
    for gate in gates:
        reason = '；'.join(gate['reasons']) or '总改善严格超过门槛且各case退步均未超过1%'
        label = gate['baseline'] + ('（仅辅助）' if gate['baseline'] == REFERENCE else '')
        text.append(f'| {label} | {gate["total_gain_pct"]:.6f}% | {gate["threshold_pct"]:.6f}% | '
            + ' | '.join(f'{r["gain_pct"]:.6f}%' for r in gate['cases'])
            + ' | ' + ('是' if gate['eligible'] else '否') + ' | ' + reason.replace('|', '\\|') + ' |')
    text += ['', f'`C52.qualified_for_confirmation={str(qualified).lower()}`。'
        'C52 对 C51-r2 比较的是同分配两份完整实现；代码布局、调度、尾部和分派均可能贡献差值，不能据此声称纯展开或单条指令的成本。'
        '该辅助比较不替代任何一个C6门槛，C51-r2的reference_only=true、promotion_allowed=false、qualified_for_confirmation=false保持。', '',
        '## 全部48个原始样本', '',
        '| 版本 | 用例 | 三套打印值 ms | 中位数 ms | 波动 | 最大误差 |',
        '| --- | --- | --- | ---: | ---: | ---: |']
    rendered, originals = [], []
    for name in ORDER:
        for index, case in enumerate(records[name]['cases']):
            values = ' / '.join(f'{x:.2f}' for x in case['times_ms'])
            rendered += list(map(float, values.split(' / ')))
            originals += case['times_ms']
            text.append(f'| {name} | {"ABCD"[index]} | {values} | {case["median_ms"]:.2f}'
                + f' | {case["spread_pct"]:.6f}% | {case["max_error"]:.8g} |')
    assert len(rendered) == 48 and rendered == originals, 'Rendered samples must retain every original value'
    text += ['', 'A=4096×6144 / 39×39；B=6144×4096 / 41×41；C=4256×6390 / 55×55；D=6390×4256 / 81×81。', '',
        '## 来源与结论边界', '',
        'C52 从 C51-row7x3u1 出发，仅将七行×3VL helper 的 shared 列循环作两列展开，保留单列余项和其它十二阶段。'
        '其自身 [T作业1582134](CONV_SEP13T.md) 已独立验证37128项（full28704、dispatch5832、direct2592，六个VL/线程配置，runner0）。'
        'C51-r2则使用原C51的相同字节和自身[Q验证](CONV_SEP13Q.md)，不能给改变源码的C52提供PASS。', '',
        '[S作业1582067](CONV_SEP13S.md) 的 confirmation=false 保持；C51-r2是本轮背景参考，不是失败S确认的重试。'
        '本页全部48样本只来自W原作业，没有与R/S/T或任何历史样本合并、挑选或替换，旧G/J/K/N/R/S判定保持。', '',
        best_sentence + '本轮只记录初筛，未自动确认、晋级或生成ZIP；报告生成仅整理本地文本，未改record、campaign、源码或公开副本。'
        '所有题目编译/运行仅在超算计算节点完成，本机未运行题目、未使用重置卡。', '',
        '逐版本完整原日志、源码、设置和比较原因已留档；公开副本仍需对账号、个人路径和内部节点脱敏。正式平台由队友手动提交，未估计官方分数或排名。', '']
    return '\n'.join(text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--confirmed-complete-job', choices=[JOB], required=True,
        help='Pass only after root/lifecycle confirms original W record and compare are complete')
    parser.parse_args()
    path = ROOT / 'docs/CONV_SEP13W.md'
    assert not path.exists(), 'The existing report is never overwritten'
    loaded = load_completed()
    content = generate(*loaded)
    with path.open('x') as output:
        output.write(content)
    assert path.read_text() == content
    plan, records, _, gates, best_label, best_version = loaded
    print(json.dumps(dict(report=str(path), job_id=JOB, samples=48,
        qualified_for_confirmation=records[CANDIDATE]['qualified_for_confirmation'],
        current_best=best_label, current_best_record=best_version,
        totals_ms={v: records[v]['total_median_ms'] for v in ORDER},
        gates=gates, original_samples_rendered_exactly=True, new_operator_execution=False),
        ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
