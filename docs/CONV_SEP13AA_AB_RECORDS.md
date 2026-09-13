# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r30](../records/experiments/conv/C26-r30.json) |  | passed | Unchanged C6 AB-round matched control | 4096×6144×39×39: 51.45; 6144×4096×41×41: 61.93; 4256×6390×55×55: 107.31; 6390×4256×81×81: 231.81 | 452.50 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C54-row7x3shared4](../records/experiments/conv/C54-row7x3shared4.json) | C26-r31 | passed | Source-only shared unroll2 to unroll4: kw-ik>=4 and ik+=4; four sequential complete 21 mul/add column scopes; retain original u1 remainder for 0..3 columns. All other stages,dispatch,tail,fallback and submission files unchanged. Future own correctness/codegen/performance required; prior Y/S failed confirmations preserved. | 4096×6144×39×39: 80.90; 6144×4096×41×41: 88.46; 4256×6390×55×55: 168.31; 6390×4256×81×81: 369.32 | 706.99 | 否 | C54 does not meet both C6 gates; retain every sample and C6. No automatic confirmation, promotion or ZIP. |
| [C52-r2](../records/experiments/conv/C52-r2.json) | C26-r31 | passed | Same-source C52 background reference for C54; promotion forbidden, not a failed Y confirmation retry | 4096×6144×39×39: 51.77; 6144×4096×41×41: 58.46; 4256×6390×55×55: 103.88; 6390×4256×81×81: 222.79 | 436.90 | 仅参考，不晋级 | Same-source C52 background reference for C54. Never qualifies or promotes; Y/S confirmations remain false. This is not a failed Y confirmation retry. |
| [C26-r31](../records/experiments/conv/C26-r31.json) |  | passed | Unchanged C6 AB-round matched control | 4096×6144×39×39: 51.41; 6144×4096×41×41: 61.97; 4256×6390×55×55: 107.36; 6390×4256×81×81: 231.70 | 452.44 | 基线复测 | Unchanged C6 control; not a new candidate. |
