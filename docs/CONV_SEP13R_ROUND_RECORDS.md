# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r22](../records/experiments/conv/C26-r22.json) |  | passed | Unchanged C6 R-round matched control | 4096×6144×39×39: 51.39; 6144×4096×41×41: 61.97; 4256×6390×55×55: 107.29; 6390×4256×81×81: 231.67 | 452.32 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C51-row7x3u1](../records/experiments/conv/C51-row7x3u1.json) | C26-r23 | passed | Replace only the frozen C40 specialized6x3VL tile by7x3VL and corresponding row-group dispatch;21 independent accumulators,13 phases, one kernel column per step with separate FMUL/FADD. Explore input sharing and coefficient amortization relative to N context without any speed claim. Source preparation only. | 4096×6144×39×39: 51.86; 6144×4096×41×41: 59.30; 4256×6390×55×55: 104.18; 6390×4256×81×81: 223.61 | 438.95 | 是 | Initial C51 candidate qualifies versus both same-job C6 controls; return to root for an independent next-step decision. No automatic confirmation, promotion or ZIP. |
| [C40-r4](../records/experiments/conv/C40-r4.json) | C26-r23 | passed | Same-source C40 reference-only context for C51; promotion forbidden, not a confirmation repeat | 4096×6144×39×39: 50.41; 6144×4096×41×41: 60.31; 4256×6390×55×55: 107.32; 6390×4256×81×81: 226.36 | 444.40 | 仅参考，不晋级 | Same-source C40 reference-only for C51 context. Never qualifies or promotes; Gfalse/Jtrue/Kfalse and Nreference remain unchanged. Not a C40 confirmation. |
| [C26-r23](../records/experiments/conv/C26-r23.json) |  | passed | Unchanged C6 R-round matched control | 4096×6144×39×39: 51.40; 6144×4096×41×41: 61.90; 4256×6390×55×55: 107.29; 6390×4256×81×81: 231.69 | 452.28 | 基线复测 | Unchanged C6 control; not a new candidate. |
