# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r8](../records/experiments/conv/C58-r8.json) |  | passed | Unchanged C7 control around C62 joint seven-row two-vector shared4 tile | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.39; 4256×6390×55×55: 104.22; 6390×4256×81×81: 223.12 | 437.55 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C62-row7x2shared4](../records/experiments/conv/C62-row7x2shared4.json) | C58-r9 | passed | Joint tile hypothesis from C7: reduce only rowseven width from 3VL/21 accumulators to 2VL/14 accumulators to make room for shared four-column unrolling. Preserve seven-row dispatch, twelve boundary unroll2 hints, strict per-output ik0..3 separate mul/add, scalar-column remainder and all fallback/companion code. This jointly changes vector width and shared unroll, not an isolated single-parameter experiment. | 4096×6144×39×39: 64.05; 6144×4096×41×41: 69.84; 4256×6390×55×55: 128.37; 6390×4256×81×81: 276.72 | 538.98 | 否 | AS initial comparison rejected; retain C7 and all samples. |
| [C58-r9](../records/experiments/conv/C58-r9.json) |  | passed | Unchanged C7 control around C62 joint seven-row two-vector shared4 tile | 4096×6144×39×39: 51.81; 6144×4096×41×41: 58.41; 4256×6390×55×55: 104.20; 6390×4256×81×81: 223.20 | 437.62 | 基线复测 | 已验证；按共同基线比较后决定 |
