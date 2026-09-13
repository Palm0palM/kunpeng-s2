# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r6](../records/experiments/conv/C26-r6.json) |  | passed | Unchanged C6 control for first C33 matched trial | 4096×6144×39×39: 51.48; 6144×4096×41×41: 61.91; 4256×6390×55×55: 107.32; 6390×4256×81×81: 231.58 | 452.29 | 基线复测 | Unchanged C6 control; not a new algorithm version. |
| [C33-row5x4u1](../records/experiments/conv/C33-row5x4u1.json) | C26-r7 | passed | Five adjacent output rows share each input row using four SVE vectors per row and twenty accumulators; advance kernel columns singly in nine row phases while preserving original C6 helpers, small-kernel paths and strict multiply/add order | 4096×6144×39×39: 53.34; 6144×4096×41×41: 63.71; 4256×6390×55×55: 111.95; 6390×4256×81×81: 238.13 | 467.13 | 否 | Does not meet predeclared comparison gate; preserve actual samples without promotion. |
| [C26-r7](../records/experiments/conv/C26-r7.json) |  | passed | Unchanged C6 control for first C33 matched trial | 4096×6144×39×39: 51.46; 6144×4096×41×41: 61.95; 4256×6390×55×55: 107.35; 6390×4256×81×81: 231.62 | 452.38 | 基线复测 | Unchanged C6 control; not a new algorithm version. |
