# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r2](../records/experiments/conv/C58-r2.json) |  | passed | Unchanged C7 control around C59 input_5 pragma removal | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.43; 4256×6390×55×55: 104.16; 6390×4256×81×81: 223.17 | 437.58 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C59-row7boundaryu2nofive](../records/experiments/conv/C59-row7boundaryu2nofive.json) | C58-r3 | passed | Only remove the GCC unroll 2 pragma before rowseven input_5 from C58. Preserve the other11 boundary pragmas, shared2/u1, all arithmetic, dispatch, flags and three companion files. Test possible reduction of repeated input_5 temporary-product spills; source-only preparation, performance unmeasured, no inherited AH PASS. | 4096×6144×39×39: 51.96; 6144×4096×41×41: 58.49; 4256×6390×55×55: 104.23; 6390×4256×81×81: 223.26 | 437.94 | 否 | AM initial comparison rejected; retain C7 and all samples. |
| [C58-r3](../records/experiments/conv/C58-r3.json) |  | passed | Unchanged C7 control around C59 input_5 pragma removal | 4096×6144×39×39: 51.86; 6144×4096×41×41: 58.43; 4256×6390×55×55: 104.20; 6390×4256×81×81: 223.17 | 437.66 | 基线复测 | 已验证；按共同基线比较后决定 |
