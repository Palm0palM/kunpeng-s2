# CONV J/K 轮版本与测量记录

本表“可晋级”保留各次比较的原始资格判断；J 轮 C40-r1 获得复测资格，随后 K 轮独立确认未通过波动门槛，因此未晋级，提交包仍为 C6。源码来源见 source_parent，表内 parent 为本次同环境比较基线。

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r16](../records/experiments/conv/C26-r16.json) |  | passed | Unchanged C6 matched J-round control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.86; 4256×6390×55×55: 107.34; 6390×4256×81×81: 231.81 | 452.44 | 基线复测 | Unchanged C6 J control; not a new algorithm version. |
| [C40-r1](../records/experiments/conv/C40-r1.json) | C26-r17 | passed | Independent same-source C40 repeat after noisy G controls; retain original inconclusive evidence and all samples | 4096×6144×39×39: 50.49; 6144×4096×41×41: 60.30; 4256×6390×55×55: 107.36; 6390×4256×81×81: 226.37 | 444.52 | 是 | Independent same-source J repeat qualifies against both J C6 controls; root decides confirmation and exact ZIP validation. Original noisy G result remains unqualified. |
| [C26-r17](../records/experiments/conv/C26-r17.json) |  | passed | Unchanged C6 matched J-round control | 4096×6144×39×39: 51.45; 6144×4096×41×41: 61.98; 4256×6390×55×55: 107.29; 6390×4256×81×81: 231.66 | 452.38 | 基线复测 | Unchanged C6 J control; not a new algorithm version. |
| [C26-r18](../records/experiments/conv/C26-r18.json) |  | passed | Unchanged C6 matched K confirmation control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.95; 4256×6390×55×55: 107.37; 6390×4256×81×81: 232.19 | 452.94 | 基线复测 | Unchanged C6 K control; not a new algorithm version. |
| [C40-r2](../records/experiments/conv/C40-r2.json) | C26-r19 | passed | Independent same-source confirmation of qualified C40-r1; original G remains inconclusive | 4096×6144×39×39: 50.44; 6144×4096×41×41: 60.33; 4256×6390×55×55: 107.36; 6390×4256×81×81: 226.47 | 444.60 | 否 | Independent K confirmation does not meet both C6 gates; retain every sample without promotion and preserve the separate J and G records. |
| [C26-r19](../records/experiments/conv/C26-r19.json) |  | passed | Unchanged C6 matched K confirmation control | 4096×6144×39×39: 51.47; 6144×4096×41×41: 62.00; 4256×6390×55×55: 107.34; 6390×4256×81×81: 231.77 | 452.58 | 基线复测 | Unchanged C6 K control; not a new algorithm version. |
