# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r38](../records/experiments/conv/C26-r38.json) |  | passed | Unchanged C6 AK independent confirmation control | 4096×6144×39×39: 51.42; 6144×4096×41×41: 61.90; 4256×6390×55×55: 107.31; 6390×4256×81×81: 231.63 | 452.26 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C58-r1](../records/experiments/conv/C58-r1.json) | C26-r39 | passed | First independent confirmation of AI-qualified C58; identical source, own C58 AH diagnostic reuse, no failed-confirmation retry. | 4096×6144×39×39: 51.84; 6144×4096×41×41: 58.39; 4256×6390×55×55: 104.15; 6390×4256×81×81: 223.18 | 437.56 | 是 | Promoted to C7 after both independent AK gates passed and original C58-package job1589186 exact ZIP verification completed12PASS/error0. All samples retained. |
| [C26-r39](../records/experiments/conv/C26-r39.json) |  | passed | Unchanged C6 AK independent confirmation control | 4096×6144×39×39: 51.43; 6144×4096×41×41: 61.91; 4256×6390×55×55: 107.27; 6390×4256×81×81: 231.66 | 452.27 | 已晋级 | Unchanged C6 control; not a new candidate. |
| [C58-package](../records/experiments/conv/C58-package.json) | C58-r1 | passed | Exact original ZIP correctness verification after AI initial and independent AK confirmation; no automatic promotion | 4096×6144×39×39: 51.75; 6144×4096×41×41: 58.41; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.16 | 437.49 | 仅参考，不晋级 | 已验证；按共同基线比较后决定 |
