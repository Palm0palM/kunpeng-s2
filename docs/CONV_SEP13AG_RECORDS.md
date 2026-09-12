# CONV SEP13AG：C57 数值失败记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C57-row7shared2fma](../records/experiments/conv/C57-row7shared2fma.json) | C52-row7x3shared2 | failed | 仅将原 C52 shared main 两列 42 处及 u1 余数 21 处显式改为 svmla，保留其它源码和严格 flags；先待超算原官方四例三套 1e-5 绝对误差数值可行性，不借旧 memcmp/FMA0 结论，不据伴随时间晋级。 |  |  | 否（数值失败） | AG original job1583276: all12 official numerical checks FAIL at unchanged tolerance1e-5; printed A/B/C/D max absolute errors1.53e-4/1.83e-4/3.66e-4/6.10e-4 in all3 suites. Each process0 but PASS_CHECK1; wrapper/job1, system10001. No performance timing; explicit FMA candidate rejected; retain C6. |

AG 原 job1583276：12/12 FAIL，数值失败分支在计时前返回；所有耗时为空，不计算中位数、spread 或提速。当前 C6 保持，C57 不晋级。全部原始数值和退出含义见 evidence 中 TARGETED_REVIEW.md / AG_SUMMARY.json；原程序进程退出 0 不等于数值 PASS。
