# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r6](../records/experiments/conv/C58-r6.json) |  | passed | Unchanged C7 control around C61 row-wise shared2 coefficient scheduling | 4096×6144×39×39: 51.81; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.19; 6390×4256×81×81: 223.16 | 437.56 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C61-row7shared2rowwise](../records/experiments/conv/C61-row7shared2rowwise.json) | C58-r7 | passed | Within each shared pair column, load three original input vectors then update each output row across all three vectors using one scoped coefficient broadcast. Shorten source-level coefficient lifetimes; preserve per-output arithmetic order,6 direct loads,14 broadcasts,all boundary hints,remainder and runner. No EXT, prefetch or fast math. | 4096×6144×39×39: 51.83; 6144×4096×41×41: 58.30; 4256×6390×55×55: 104.10; 6390×4256×81×81: 223.08 | 437.31 | 否 | AQ initial comparison rejected; retain C7 and all samples. |
| [C58-r7](../records/experiments/conv/C58-r7.json) |  | passed | Unchanged C7 control around C61 row-wise shared2 coefficient scheduling | 4096×6144×39×39: 51.83; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.15; 6390×4256×81×81: 223.18 | 437.56 | 基线复测 | 已验证；按共同基线比较后决定 |
