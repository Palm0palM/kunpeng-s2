# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C47-row6x4u1](../records/experiments/conv/C47-row6x4u1.json) | C40-row6x3u1 | prepared | Expand only the unchanged C40 six-row single-column helper from 3VL to 4VL (18 to 24 accumulators), preserving eleven phases, arithmetic order, six-row dispatch, existing helpers and build; source-only prepared hypothesis |  |  | 待判定 | 尚未取得完整远程测量 |
| [C48-row8x2u1](../records/experiments/conv/C48-row8x2u1.json) | C40-row6x3u1 | prepared | Independent eight-row by two-vector single-column tile replacing only C40 specialized six-row by three-vector tile and its dispatch; 16 accumulators and fifteen phases; input-load savings trade against 50 percent higher coefficient-broadcast amortization; source-only preparation |  |  | 待判定 | 尚未取得完整远程测量 |
