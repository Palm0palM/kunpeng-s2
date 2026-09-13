# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r12](../records/experiments/conv/C58-r12.json) |  | passed | Unchanged C7 control around C64 rowseven boundary rowwise weight scheduling | 4096×6144×39×39: 51.86; 6144×4096×41×41: 58.43; 4256×6390×55×55: 104.35; 6390×4256×81×81: 223.52 | 438.16 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C64-row7boundaryrowwise](../records/experiments/conv/C64-row7boundaryrowwise.json) | C58-r13 | passed | Only reschedule all12 C7 rowseven boundary column bodies: load v0/v1/v2 first, then broadcast one participating output-row weight and update its three vectors. Preserve shared2/u1,12 unroll2 hints, predicates, addresses and strict per-chain arithmetic. Hypothesis only; no spill or performance claim. | 4096×6144×39×39: 51.67; 6144×4096×41×41: 58.36; 4256×6390×55×55: 104.06; 6390×4256×81×81: 223.06 | 437.15 | 否 | AW initial comparison rejected; retain C7 and all samples. |
| [C58-r13](../records/experiments/conv/C58-r13.json) |  | passed | Unchanged C7 control around C64 rowseven boundary rowwise weight scheduling | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.43; 4256×6390×55×55: 104.30; 6390×4256×81×81: 223.19 | 437.74 | 基线复测 | 已验证；按共同基线比较后决定 |
