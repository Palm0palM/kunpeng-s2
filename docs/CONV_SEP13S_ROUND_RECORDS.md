# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r24](../records/experiments/conv/C26-r24.json) |  | passed | Unchanged C6 S-round confirmation control | 4096×6144×39×39: 51.39; 6144×4096×41×41: 61.96; 4256×6390×55×55: 107.28; 6390×4256×81×81: 231.63 | 452.26 | 基线复测 | Unchanged C6 confirmation control; not a candidate. |
| [C51-r1](../records/experiments/conv/C51-r1.json) | C26-r25 | passed | One independent confirmation of unchanged R-qualified C51 source; same frozen Q, new S controls, no pooled R/S samples or relaxed case gate | 4096×6144×39×39: 51.83; 6144×4096×41×41: 59.29; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.59 | 438.88 | 否 | Independent S confirmation failed at least one current S C6 gate. Preserve every original sample and C6; do not repeat failed confirmation or combine R/S samples. |
| [C26-r25](../records/experiments/conv/C26-r25.json) |  | passed | Unchanged C6 S-round confirmation control | 4096×6144×39×39: 51.40; 6144×4096×41×41: 61.89; 4256×6390×55×55: 107.32; 6390×4256×81×81: 231.65 | 452.26 | 基线复测 | Unchanged C6 confirmation control; not a candidate. |
