# CONV 版本与测量记录

所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。

| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [C45-row4dup4](../records/experiments/conv/C45-row4dup4.json) | C26-row4loads | prepared | In quad shared middle only, batch four kernel columns with LD1RQ, explicit constant-lane DUP and ordinary separate FMUL/FADD in q-major order; retain C6 two/one remainders and all other code; diagnostic-first, no assumed speedup |  |  | 待判定 | 尚未取得完整远程测量 |
| [C46-row5x5asmfix](../records/experiments/conv/C46-row5x5asmfix.json) | C42-row5x5asm | prepared | Fix only GCC10 SVE inline-asm operand formatting from unsupported percent-Z named operands to default named operands with .s; preserve C42 early-clobber constraints, arithmetic and memory compiler barrier; independent compile/correctness remains pending |  |  | 待判定 | 尚未取得完整远程测量 |
