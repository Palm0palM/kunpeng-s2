# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r4](../records/experiments/conv/C26-r4.json) |  | passed | Unchanged C6 control | 4096×6144×39×39: 51.38; 6144×4096×41×41: 61.95; 4256×6390×55×55: 107.30; 6390×4256×81×81: 231.74 | 452.37 | 基线复测 | Unchanged C6 control; not a new algorithm version. |
| [C30-r1](../records/experiments/conv/C30-r1.json) | C26-r5 | passed | Independent exploratory repeat of unchanged C30; original inconclusive result retained | 4096×6144×39×39: 50.97; 6144×4096×41×41: 61.31; 4256×6390×55×55: 106.50; 6390×4256×81×81: 229.25 | 448.03 | 否 | Does not meet predeclared comparison gate; preserve actual samples without promotion. |
| [C32-row4lane4staged](../records/experiments/conv/C32-row4lane4staged.json) | C26-r5 | passed | Insert one empty volatile asm memory barrier after the first two vector positions in the four-coefficient quad middle loop, consuming eight completed accumulators to limit cross-half input-load hoisting while preserving all arithmetic and other code | 4096×6144×39×39: 56.79; 6144×4096×41×41: 67.08; 4256×6390×55×55: 119.19; 6390×4256×81×81: 257.43 | 500.49 | 否 | Does not meet predeclared comparison gate; preserve actual samples without promotion. |
| [C26-r5](../records/experiments/conv/C26-r5.json) |  | passed | Unchanged C6 control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.95; 4256×6390×55×55: 107.32; 6390×4256×81×81: 231.73 | 452.43 | 基线复测 | Unchanged C6 control; not a new algorithm version. |
