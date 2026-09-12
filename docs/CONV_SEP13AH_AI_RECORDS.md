# CONV 版本与测量记录

本轮仅记录 AI 初筛：候选通过两端门槛，尚未独立确认或晋级；C6保留。
所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 本轮状态 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r36](../records/experiments/conv/C26-r36.json) |  | passed | Unchanged C6 AI-round matched control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.90; 4256×6390×55×55: 107.37; 6390×4256×81×81: 231.71 | 452.41 | C6基线复测 | Unchanged C6 control; not a new candidate. |
| [C58-row7boundaryu2](../records/experiments/conv/C58-row7boundaryu2.json) | C26-r37 | passed | Only add GCC unroll 2 pragmas before the six rowseven input and six trailing kernel-column loops. Keep shared2, arithmetic, dispatch and submission flags unchanged. Source-only hypothesis; own diagnostic required. | 4096×6144×39×39: 51.83; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.18; 6390×4256×81×81: 223.15 | 437.56 | 初筛通过，待独立确认 | Initial C58 candidate qualifies versus both same-job C6 controls; return to root for an independent next-step decision. No automatic confirmation, promotion or ZIP. |
| [C26-r37](../records/experiments/conv/C26-r37.json) |  | passed | Unchanged C6 AI-round matched control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.91; 4256×6390×55×55: 107.38; 6390×4256×81×81: 231.70 | 452.42 | C6基线复测 | Unchanged C6 control; not a new candidate. |
