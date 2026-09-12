"""Write the R report from completed records; only lightweight log processing."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]


def main():
    plan = json.loads((ROOT / '.runs/conv/sep13r-campaign.json').read_text())
    assert plan['status'] == 'performance_complete'
    order = plan['measurement_order']
    assert order == ['C26-r22', 'C51-row7x3u1', 'C40-r4', 'C26-r23']
    records = {v: json.loads((ROOT / 'records/experiments/conv' / (v + '.json')).read_text()) for v in order}
    assert all(r['status'] == 'passed' and r['verified'] and r['job_id'] == plan['performance_job']
               and len(r['cases']) == 4 and all(len(c['times_ms']) == 3 for c in r['cases']) for r in records.values())
    candidate = records['C51-row7x3u1']
    qualified = candidate['qualified_for_confirmation']
    rows = {r['version']: r for r in plan['results']}
    assert list(rows) == order
    text = ['# CONV：七行候选的原 benchmark 对照', '',
            ('C51 达到两端 C6 的初筛门槛，仍须独立确认和最终原 ZIP 验证。' if qualified
             else 'C51 未达到两端 C6 的初筛门槛。') + '本轮仍保留 C6 提交包。', '',
            f"超算作业 **{plan['performance_job']}**，四成员各三套完整原 benchmark，合计 **48/48 PASS**。"
            '所有样本与慢样本保留；合计是各用例三次独立套件打印值的中位数之和，仅作内部比较，不是官方分数。', '',
            '顺序为 C6 开头对照 → C51 → C40 同源参考 → C6 结束对照。相同分配、GCC 10.3.1、generic、38 线程、24 GiB、单 NUMA，使用原 benchmark/runner、输入、参考和精度设置；调度、job/system/wrapper 退出与全部逐例 PASS 经登记工具核对。', '',
            '| 版本 | A/B/C/D 中位数 ms | 合计 ms | 对结束 C6 改善 | 最大逐例波动 | 角色/结论 |',
            '| --- | --- | ---: | ---: | ---: | --- |']
    for v in order:
        r, row = records[v], rows[v]
        role = ('对照' if v in (order[0], order[-1]) else '仅参考，不晋级' if v == 'C40-r4'
                else '通过初筛，待独立确认' if qualified else '未通过')
        text.append('| ' + v + ' | ' + ' / '.join(f'{c["median_ms"]:.2f}' for c in r['cases'])
                    + f' | {r["total_median_ms"]:.2f} | {row["gain_pct"]:.4f}% | {row["max_spread_pct"]:.4f}% | {role} |')
    text += ['', '## 两端门槛与辅助比较', '',
             '| 比较 | 合计改善 | 实际门槛 | 通过 | 原因 |', '| --- | ---: | ---: | --- | --- |']
    for field in ('opening_control_comparison', 'comparison', 'rowsix_reference_comparison'):
        comparison = candidate[field]
        text.append(f"| C51 对 {comparison['baseline']} | {comparison['total_gain_pct']:.4f}% | {comparison['threshold_pct']:.4f}% | "
                    + ('是' if comparison['eligible'] else '否') + ' | '
                    + ('；'.join(comparison['reasons']) or '超过门槛，且没有用例退步超过 1%') + ' |')
    text += ['', '门槛为 max(1%, 对比双方所有逐例波动)，改善必须严格超过门槛，并且任一用例退步不超过 1%。'
             'C51 必须同时通过开头和结束 C6；辅助 C40 比较不替代该条件。C40-r4 始终仅参考，原 G 未通过、J 初筛通过、K 独立确认未通过和 N 仅参考的结论不变。', '',
             '## 全部逐例样本', '',
             '| 版本 | 用例 | 三套打印值 ms | 中位数 ms | 波动 |', '| --- | --- | --- | ---: | ---: |']
    for v in order:
        for index, c in enumerate(records[v]['cases']):
            text.append('| ' + v + ' | ' + 'ABCD'[index] + ' | ' + ' / '.join(f'{x:.2f}' for x in c['times_ms'])
                        + f' | {c["median_ms"]:.2f} | {c["spread_pct"]:.4f}% |')
    text += ['', '## 源码与记录', '',
             'C51 在 C40 的基础上使用七行 × 三向量、21 个独立累加器，保留逐列乘法/加法顺序和旧边界路径。'
             '自己的 [Q 专项验证](CONV_SEP13Q.md) 已通过 37128 项；实际完整 helper 无向量 spill、共享循环 63 条指令。'
             '这些汇编观察不用于代替本页实测，也不能把整个形状变化的收益归因于单一指令或 spill。', '',
             '完整源码补丁、来源、环境、调度与原样本均留档，公开副本对计算账号、个人路径和内部节点脱敏。'
             '登记沿用已审查的 N 元数据适配，创建时身份原件保持不变。正式平台仍由队友手动提交。'
             '本轮没有在本机编译/测试算子，没有使用重置卡、自动晋级或自动生成提交包。', '']
    output = ROOT / 'docs/CONV_SEP13R.md'
    assert not output.exists(), 'Existing report must not be overwritten'
    output.write_text('\n'.join(text))
    print('Wrote actual R report with all 48 samples.')


if __name__ == '__main__':
    main()
