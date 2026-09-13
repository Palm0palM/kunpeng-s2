# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r28](../records/experiments/conv/C26-r28.json) |  | passed | Unchanged C6 Y-round confirmation control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.98; 4256×6390×55×55: 107.30; 6390×4256×81×81: 231.69 | 452.40 | 基线复测 | Unchanged C6 confirmation control; not a candidate. |
| [C52-r1](../records/experiments/conv/C52-r1.json) | C26-r29 | passed | One independent confirmation of unchanged W-qualified C52 source; same own frozen T, new Y controls, no pooled W/Y samples or relaxed case gate | 4096×6144×39×39: 51.60; 6144×4096×41×41: 58.44; 4256×6390×55×55: 103.88; 6390×4256×81×81: 222.76 | 436.68 | 否 | Independent Y confirmation failed at least one current Y C6 gate. Preserve every original sample and C6; do not repeat failed confirmation or combine W/Y samples. |
| [C26-r29](../records/experiments/conv/C26-r29.json) |  | passed | Unchanged C6 Y-round confirmation control | 4096×6144×39×39: 51.50; 6144×4096×41×41: 61.96; 4256×6390×55×55: 107.46; 6390×4256×81×81: 231.64 | 452.56 | 基线复测 | Unchanged C6 confirmation control; not a candidate. |
| [C53-row7cursors](../records/experiments/conv/C53-row7cursors.json) | C51-row7x3u1 | prepared | Replace only the seven rowseven shared coefficient row-base plus ik expressions with per-tile cursors initialized at kernel rows6..0 and advanced once per coefficient across t; preserve one-column ik loops,all21 ordered updates,input indices,other12 stages,dispatch and submission settings. Test actual address induction only; no assumed codegen or speed gain. |  |  | 待判定 | 尚未取得完整远程测量 |
