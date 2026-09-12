# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r32](../records/experiments/conv/C26-r32.json) |  | passed | Unchanged C6 AD-round matched control | 4096×6144×39×39: 51.45; 6144×4096×41×41: 61.94; 4256×6390×55×55: 107.30; 6390×4256×81×81: 231.72 | 452.41 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C55-row7x3shared3](../records/experiments/conv/C55-row7x3shared3.json) | C26-r33 | passed | Source-only shared unroll2 to unroll3: kw-ik>=3 and ik+=3; three sequential complete original 21 mul/add column scopes, followed by unchanged u1 remainder0..2. Other12 stages/7rows3VL21acc/dispatch/tails/fallback and other submission files unchanged. Moderate-unroll hypothesis after reported C54 scalable spills, not a spill or speed promise and not a failed Y/S confirmation retry. | 4096×6144×39×39: 55.47; 6144×4096×41×41: 60.96; 4256×6390×55×55: 111.66; 6390×4256×81×81: 238.72 | 466.81 | 否 | C55 does not meet both C6 gates; retain every sample and C6. No automatic confirmation, promotion or ZIP. |
| [C52-r3](../records/experiments/conv/C52-r3.json) | C26-r33 | passed | Same-source C52 background reference for C55; promotion forbidden, not a failed Y confirmation retry | 4096×6144×39×39: 51.74; 6144×4096×41×41: 58.42; 4256×6390×55×55: 103.92; 6390×4256×81×81: 222.77 | 436.85 | 仅参考，不晋级 | Same-source C52 background reference for C55. Never qualifies or promotes; Y/S confirmations remain false. This is not a failed Y confirmation retry. |
| [C26-r33](../records/experiments/conv/C26-r33.json) |  | passed | Unchanged C6 AD-round matched control | 4096×6144×39×39: 51.45; 6144×4096×41×41: 61.95; 4256×6390×55×55: 107.38; 6390×4256×81×81: 231.88 | 452.66 | 基线复测 | Unchanged C6 control; not a new candidate. |
