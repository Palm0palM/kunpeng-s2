# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r26](../records/experiments/conv/C26-r26.json) |  | passed | Unchanged C6 W-round matched control | 4096×6144×39×39: 51.54; 6144×4096×41×41: 61.98; 4256×6390×55×55: 107.41; 6390×4256×81×81: 231.88 | 452.81 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C52-row7x3shared2](../records/experiments/conv/C52-row7x3shared2.json) | C26-r27 | passed | Unroll only rowseven shared-stage kernel-column loop by2, with separate per-column scopes and original u1 odd remainder; preserve per-accumulator ik then ik+1 order,7rows x3VL/21acc, other12 phases and all fallback/dispatch bytes. Hypothesis: amortize shared loop/address overhead, with unmeasured liveness/code-size risk. Source preparation only. | 4096×6144×39×39: 51.71; 6144×4096×41×41: 58.43; 4256×6390×55×55: 103.86; 6390×4256×81×81: 222.78 | 436.78 | 是 | Initial C52 candidate qualifies versus both same-job C6 controls; return to root for an independent next-step decision. No automatic confirmation, promotion or ZIP. |
| [C51-r2](../records/experiments/conv/C51-r2.json) | C26-r27 | passed | Same-source C51 background reference for C52; promotion forbidden, not a failed S confirmation retry | 4096×6144×39×39: 51.86; 6144×4096×41×41: 59.29; 4256×6390×55×55: 104.22; 6390×4256×81×81: 223.64 | 439.01 | 仅参考，不晋级 | Same-source C51 background reference for C52. Never qualifies or promotes; S confirmation remains false. This is not a failed S confirmation retry. |
| [C26-r27](../records/experiments/conv/C26-r27.json) |  | passed | Unchanged C6 W-round matched control | 4096×6144×39×39: 51.40; 6144×4096×41×41: 61.98; 4256×6390×55×55: 107.30; 6390×4256×81×81: 231.72 | 452.40 | 基线复测 | Unchanged C6 control; not a new candidate. |
