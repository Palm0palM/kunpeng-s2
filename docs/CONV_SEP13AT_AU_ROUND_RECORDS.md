# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r10](../records/experiments/conv/C58-r10.json) |  | passed | Unchanged C7 control around C63 row-wise seven-row two-vector shared4 scheduling | 4096×6144×39×39: 51.86; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.15; 6390×4256×81×81: 223.22 | 437.63 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C63-row7x2shared4rowwise](../records/experiments/conv/C63-row7x2shared4rowwise.json) | C58-r11 | passed | C7-based joint 7-row 2VL shared4 tile with rowwise weight lifetime: start from C62 design and only load two input vectors then broadcast one weight per output row within each of four ordered columns. Preserve 14 accumulators, other C62 code and strict arithmetic; own verification and measurement required. | 4096×6144×39×39: 55.18; 6144×4096×41×41: 60.95; 4256×6390×55×55: 109.92; 6390×4256×81×81: 237.61 | 463.66 | 否 | AU initial comparison rejected; retain C7 and all samples. |
| [C58-r11](../records/experiments/conv/C58-r11.json) |  | passed | Unchanged C7 control around C63 row-wise seven-row two-vector shared4 scheduling | 4096×6144×39×39: 51.86; 6144×4096×41×41: 58.41; 4256×6390×55×55: 104.16; 6390×4256×81×81: 223.15 | 437.58 | 基线复测 | 已验证；按共同基线比较后决定 |
