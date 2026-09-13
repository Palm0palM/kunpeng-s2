# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r4](../records/experiments/conv/C58-r4.json) |  | passed | Unchanged C7 control around C60 shared2 input EXT reuse | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.15 | 437.54 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C60-row7shared2ext](../records/experiments/conv/C60-row7shared2ext.json) | C58-r5 | passed | C7/C58-r1 shared two-column rowseven loop: reuse three first-column SVE windows using EXT for column two; load only one required tail float under a one-lane predicate; preserve every separate mul/add and all other code. Hypothesis only; register pressure may regress. | 4096×6144×39×39: 54.22; 6144×4096×41×41: 60.35; 4256×6390×55×55: 109.32; 6390×4256×81×81: 234.58 | 458.47 | 否 | AO initial comparison rejected; retain C7 and all samples. |
| [C58-r5](../records/experiments/conv/C58-r5.json) |  | passed | Unchanged C7 control around C60 shared2 input EXT reuse | 4096×6144×39×39: 51.83; 6144×4096×41×41: 58.42; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.13 | 437.55 | 基线复测 | 已验证；按共同基线比较后决定 |
