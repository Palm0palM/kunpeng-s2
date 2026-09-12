# CONV H 轮输入复制与行距测量记录

C44为预先指定的只复制对照，不允许晋级。C43未通过前后C6控制的性能门槛，也没有形成独立padding贡献证据；四个成员全部正确，继续交付C6。

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C26-r14](../records/experiments/conv/C26-r14.json) |  | passed | Unchanged C6 matched H-round control | 4096×6144×39×39: 51.46; 6144×4096×41×41: 61.92; 4256×6390×55×55: 107.35; 6390×4256×81×81: 231.67 | 452.40 | 基线复测 | Unchanged C6 control; not a new candidate. |
| [C44-copyinput](../records/experiments/conv/C44-copyinput.json) | C26-r15 | passed | Reference-only input-copy/layout control for C43: identical eligibility and padded-sized malloc, copy/free and OpenMP stages, but use original inputWidth stride for copied rows and unchanged C6 helpers; all overhead timed, no promotion | 4096×6144×39×39: 57.49; 6144×4096×41×41: 66.36; 4256×6390×55×55: 112.11; 6390×4256×81×81: 235.89 | 471.85 | 否 | Reference-only matched input copy; preserve measurement, never promote this declared control. |
| [C43-padinput](../records/experiments/conv/C43-padinput.json) | C26-r15 | passed | Copy the complete input inside conv2d to an odd-number-of-16-float-lines internal row stride under common SVE/kh>=4/oh>=4/width>=64/changed-stride/512MiB gates; preserve C6 helpers and strict FP; allocation/copy/free remain timed and unmeasured | 4096×6144×39×39: 56.39; 6144×4096×41×41: 65.99; 4256×6390×55×55: 113.50; 6390×4256×81×81: 235.10 | 470.98 | 否 | Does not meet both predeclared C6 gates; preserve actual measurements and retain C6. |
| [C26-r15](../records/experiments/conv/C26-r15.json) |  | passed | Unchanged C6 matched H-round control | 4096×6144×39×39: 51.46; 6144×4096×41×41: 61.93; 4256×6390×55×55: 107.37; 6390×4256×81×81: 231.67 | 452.43 | 基线复测 | Unchanged C6 control; not a new candidate. |
