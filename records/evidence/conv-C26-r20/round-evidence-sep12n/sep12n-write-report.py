"""Generate a Markdown report from completed N records; no operator execution."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def read(path):
    return json.loads(path.read_text())


def main():
    plan = read(ROOT / '.runs/conv/sep12n-campaign.json')
    assert plan['status'] == 'performance_complete'
    order = plan['measurement_order']
    assert len(order) == 8 and plan['expected_benchmark_cases'] == 96
    records = {v: read(ROOT / 'records/experiments/conv' / (v + '.json')) for v in order}
    assert all(r['verified'] and r['status'] == 'passed' and r['job_id'] == plan['performance_job']
               and len(r['cases']) == 4 and all(len(c['times_ms']) == 3 for c in r['cases'])
               for r in records.values())
    rows = {r['version']: r for r in plan['results']}
    assert list(rows) == order
    pending = plan['confirmation_pending']
    lines = ['# CONV：五种候选的同分配比较', '',
             '本轮仍保留 C6 提交包。' + ('初筛候选 ' + '、'.join(pending) + ' 达到两端 C6 门槛，仍需独立确认与原 ZIP 验证。' if pending else '没有候选同时达到两端 C6 的晋级门槛。'), '',
             '作业 ' + str(plan['performance_job']) + '，同一分配八成员、各三套完整原 benchmark，共 96/96 case 样本。所有数值和慢样本均保留，不与历史作业混合。耗时仅为内部比较指标，不是官方分数。', '',
             '固定顺序：' + ' → '.join(order) + '。C26-r20/r21 是未改动 C6；C40-r3 仅作形状参考，禁止晋级。其历史 G 未通过、J 初筛通过、K 独立确认未通过的结论不改写。', '',
             '| 版本 | A/B/C/D 中位数 ms | 合计 ms | 对结束 C6 改善 | 最大逐例波动 | 两端初筛 |',
             '| --- | --- | ---: | ---: | ---: | --- |']
    for v in order:
        r, row = records[v], rows[v]
        role = '对照' if v in (plan['opening_control'], plan['primary_baseline']) else '仅参考' if v in plan['reference_only_versions'] else '通过，待确认' if row['qualified_for_confirmation'] else '未通过'
        lines.append('| ' + v + ' | ' + ' / '.join(f'{c["median_ms"]:.2f}' for c in r['cases'])
                     + f' | {r["total_median_ms"]:.2f} | {row["gain_pct"]:.4f}% | {row["max_spread_pct"]:.4f}% | {role} |')
    lines += ['', '## 实际测量条件', '',
              'GCC 10.3.1、generic、38 线程、24 GiB、单 NUMA；原 run.sh/benchmark、输入、计时区和精度容差不改。调度、job/system/wrapper 退出码与逐 case PASS 均经登记器核对。各中位数来自三次独立完整套件的打印值，逐 case 波动为 (max−min)/median；包含全部慢样本。公开日志中的个人目录和计算节点另行脱敏。', '',
              '候选初筛要求合计改善超过对比双方全部逐 case 最大波动与 1% 的较大值，且任一 case 退步不超过 1%；必须同时满足开头和结尾 C6。初筛通过不会自动更新源码或生成提交包。', '',
              '五个候选均先通过自己的冻结诊断：C45 121560、C46 27408、C47 26112、C48 41664、C49 121560。C45/C49 smoke 没有 kh=5 动态覆盖或逐 case 新循环入口证明。实际汇编、全部 stages 和分派分别审查；没有用未测指令数推断速度。详见 [I](CONV_SEP12I.md)、[L/M](CONV_SEP12LM.md)、[O](CONV_SEP12O.md)。', '',
              '## 全部逐例样本', '',
              '| 版本 | 用例 | 三套打印值 ms | 中位数 ms | 波动 |',
              '| --- | --- | --- | ---: | ---: |']
    for v in order:
        for i, c in enumerate(records[v]['cases']):
            lines.append('| ' + v + ' | ' + 'ABCD'[i] + ' | ' + ' / '.join(f'{x:.2f}' for x in c['times_ms'])
                         + f' | {c["median_ms"]:.2f} | {c["spread_pct"]:.4f}% |')
    lines += ['', '## 判定与辅助比较', '']
    for v in plan['candidate_versions']:
        r = records[v]
        lines.append('- ' + v + '：结束 C6 ' + ('通过' if r['comparison']['eligible'] else '未通过')
                     + '；开头 C6 ' + ('通过' if r['opening_control_comparison']['eligible'] else '未通过') + '。'
                     + '；'.join(r['comparison'].get('reasons', []) + r['opening_control_comparison'].get('reasons', [])))
    lines += ['', 'C47/C48 对 C40-r3 的比较以及 C49 对 C45 的比较在对应实验 JSON 中单独记录，只解释整个形状/编译调度方案的差异，不能把收益归结为纯 spill 成本，也不替代对 C6 的实用性门槛。', '',
              '失败、退化、所有慢样本、源补丁与环境均保留。正式平台提交仍由队友手动完成；本轮没有使用重置卡、关机或在本机编译/测试算子。', '']
    target = ROOT / 'docs/CONV_SEP12N.md'
    assert not target.exists(), 'Do not overwrite an existing report'
    target.write_text('\n'.join(lines))
    print('Wrote completed N report with all 96 actual samples.')


if __name__ == '__main__':
    main()
