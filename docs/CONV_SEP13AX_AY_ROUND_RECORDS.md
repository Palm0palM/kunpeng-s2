# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r14](../records/experiments/conv/C58-r14.json) |  | passed | Unchanged C7 control around C65 balanced rowseven dispatch scheduling | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.39; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.15 | 437.53 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C65-row7balanced](../records/experiments/conv/C65-row7balanced.json) | C58-r15 | passed | Balance only current C7 seven-row SVE dispatch: partition the flattened row-group/3VL-width-tile domain by actual OpenMP team using quotient/remainder intervals, merge each worker contiguous same-group tiles into one unchanged helper call, and preserve per-output arithmetic. One common 3VL partition width is selected after worker-local target-safe VL query. Existing helpers and all other dispatch remain unchanged. No fixed 256-column subcalls or timed allocation. | 4096×6144×39×39: 49.70; 6144×4096×41×41: 58.75; 4256×6390×55×55: 102.96; 6390×4256×81×81: 220.79 | 432.20 | 是 | AY initial comparison complete; independent confirmation required before promotion. |
| [C58-r15](../records/experiments/conv/C58-r15.json) |  | passed | Unchanged C7 control around C65 balanced rowseven dispatch scheduling | 4096×6144×39×39: 51.77; 6144×4096×41×41: 58.64; 4256×6390×55×55: 104.21; 6390×4256×81×81: 223.15 | 437.77 | 基线复测 | 已验证；按共同基线比较后决定 |
