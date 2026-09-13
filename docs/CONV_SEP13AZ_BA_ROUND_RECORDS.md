# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C58-r16](../records/experiments/conv/C58-r16.json) |  | passed | One independent C65 confirmation after eligible AY; exact source clone, unchanged C7 controls | 4096×6144×39×39: 51.81; 6144×4096×41×41: 58.40; 4256×6390×55×55: 104.16; 6390×4256×81×81: 223.28 | 437.65 | 基线复测 | 已验证；按共同基线比较后决定 |
| [C65-r1](../records/experiments/conv/C65-r1.json) | C58-r17 | passed | One independent C65 confirmation after eligible AY; exact source clone, unchanged C7 controls | 4096×6144×39×39: 49.39; 6144×4096×41×41: 58.76; 4256×6390×55×55: 102.92; 6390×4256×81×81: 220.80 | 431.87 | 是 | AZ independent confirmation passed both C7 controls; no automatic promotion or ZIP. |
| [C58-r17](../records/experiments/conv/C58-r17.json) |  | passed | One independent C65 confirmation after eligible AY; exact source clone, unchanged C7 controls | 4096×6144×39×39: 51.82; 6144×4096×41×41: 58.39; 4256×6390×55×55: 104.17; 6390×4256×81×81: 223.17 | 437.55 | 已晋级 | 已验证；按共同基线比较后决定 |
| [C65-package](../records/experiments/conv/C65-package.json) | C65-r1 | passed | Exact original ZIP correctness verification after AY initial and independent AZ confirmation; no automatic promotion | 4096×6144×39×39: 49.39; 6144×4096×41×41: 58.92; 4256×6390×55×55: 102.90; 6390×4256×81×81: 220.74 | 431.95 | 仅参考，不晋级 | 已验证；按共同基线比较后决定 |
