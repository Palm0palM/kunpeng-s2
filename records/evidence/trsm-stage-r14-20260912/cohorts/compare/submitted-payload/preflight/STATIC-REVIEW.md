# R14 预算预检独立静态审查

2026-09-12，审查冻结的 check-panel.c、run.sh、README.md、guard.py，并对照 T17-lhistbudget4/T18-budgetwide 已审查源码。**未发现阻塞缺陷；在声明的 r14 目标节点协议内可供 root 集成。** 这只是静态 ready，不表示预检已编译、执行或通过。未检查由另一审查者负责的 preflight_audit.py，未修改四份冻结输入；仅新增本报告。未本机编译/测试、SSH 或哈希。

## 分配观察与 fixture 隔离

check-panel.c 47–86 行先定义真实分配包装，81 行对 posix_memalign 的调用出现在宏定义之前，因而不会递归。87–93 行仅在 include 候选期间替换 posix_memalign，include 后立即 undef；stdlib.h 也提前包含，fixture 的 malloc/calloc 与候选外代码不受替换。TEST_NO_SVE 同样只在 include 候选期间替换 getauxval，随后解除，main 仍可检查真实 HWCAP。

包装器按独立计算的原 64MiB 整算法路径与 omp_get_level 分类：小路径 level0 是 history，大路径 level0 是 KB RHS，level1 是 worker X。55–65 行检查 alignment=64、精确单次 bytes、合法层级和 worker 编号；任何 level2 等异常会设置 shape_bad，不会悄悄归为合格 X。omp_get_level 在单线程串行化 parallel 中仍是1，避免了 omp_in_parallel 无法区分该情况的问题。

每类调用数、累计请求字节、成功/失败、层级、总调用与注入数均用原子记录，case 完成并离开并行区后审计。170–198 行要求小路径每个实际 team worker 恰好一次 X 调用，其余 worker 为0；大路径必须只有一次 KB 请求且没有 X。所有调用都经统计，额外/漏掉/形状错误的请求会使检查失败。请求字节总和不等于实际成功分配量。

## 预算、分派与失败模式

静态断言直接检查候选命名常量为4MiB且double为8字节（94–98行）。C fixture 与 Python parser 都独立用固定 RHS8/KB256 和原三角工作集规则推导请求形状，而不是从被测分配结果反推期望。history 的实际预算为 `1024*b*(b-1)`，b=floor(m/16)。以下为正常SVE8、n=9、X成功时的预算候选期望：

| m | history bytes（若请求） | history调用 | 原核入口 | packed入口 |
|---|---:|---:|---:|---:|
| 1023 | 3,999,744 | 1 | 2 | 124 |
| 1024 | 4,128,768 | 1 | 2 | 126 |
| 1039 | 4,128,768 | 1 | 2 | 126 |
| 1040 | 4,259,840 | 0 | 130 | 0 |
| 1041 | 4,259,840 | 0 | 130 | 0 |
| 4095 | 66,324,480 | 0 | 510 | 0 |
| 4097 | 不走小路径 | 0 | 0 | 0 |

4097×9 的根分配应归 KB：ceil(9/8)*256*8*8=32,768 bytes，level0；不是 history。预算38线程的 n313 给出40个RHS面板，1039的原核/packed为40/2520，1040为2600/0。

C 的 allocation_check 和 run.sh 199–209 行逐字段要求超预算 history_calls=0、history_bytes=0、success/fail=0、level=-1；因此 packed入口0不能冒充未发生分配。入口公式另行核对：小路径全部完整行块 `floor(m/16)*ceil(n/8)`，允许packed且有成功history时其中 `(floor(m/16)-1)*ceil(n/8)` 属于packed。首块、没有完整块和算法切换分别处理。

窄VL下 effective_sve 仍为1，只把 can_enter 置0；与源码“history依赖HWCAP/预算、核使用依赖worker VL”的区别相符。预算内窄VL正常目标仍必须成功分配history，但两个SVE核入口都是0。no-SVE屏蔽候选HWCAP并将effective_sve置0，才要求无history。仅X失败目标对每个kind1调用注入ENOMEM，history仍按预算成功，实际X成功数0、失败数等于threads、新旧SVE核入口0，并检查标量结果正确。

shared-only仅对kind0注入，预算内恰好一次失败且先于每线程X；预算外没有kind0调用，必须注入0次、所有X成功、原核入口完整。C中later_alloc_successes只统计全局call>1的成功，因此预算外为threads-1是该辅助计数定义的正确结果；是否所有X成功另外由实际x_success=threads与逐worker计数证明，未依赖这个辅助计数推断。SHARED_ALLOC_PASS只在真正发生history注入的case打印，预算外不能打印虚假的成功注入行。

## 精度、宽度和资源门禁

fixture构造一般非dyadic、对角占优L及独立long-double RHS；逐元素误差必须有限且≤1e-12，检查B列padding，完整memcmp保护L及其padding。微核保留7种start×2种lda padding的14例，按显式fma构造有序参考，位比较整个X含前缀/后缀、L与history保护区，并检查一次真实对应核入口。每个whole进程的4个非正维度no-op同时要求L/B不动且没有核/分配调用。

main在测试前检查真实HWCAP、线程上限、actual team数，正常进程各worker helper确认8 lanes；窄VL先真实prctl设置当前线程16bytes，再要求各worker均不走8-lane helper（396–415行）。这验证运行时无SVE/窄VL回退，不等于把候选的TRSM_CAN_DISPATCH_SVE=0编译分支实际编译过。

run.sh先执行guard，再运行编译器/构建。guard要求Linux aarch64、38 CPU、单NUMA及job环境变量存在；实际数字job ID及可信调度归属仍由父wrapper/controller提供，guard本身不独立联系调度器。该使用限制与继承r13的契约一致，不能脱离父调度门禁作为任意本机执行许可。

## 严格解析器与真实过程数量

run.sh 的解析器拒绝重复字段、非法整数、重复/缺失维度行、缺失/额外ALLOC或CASE字段、错误SOURCE_FEATURES/MODE/threads，以及FAIL/PREFLIGHT_BLOCKED。每个label的完整维度顺序固定；共享注入记录、分配总表、whole/noop summary与有限精度分别精确匹配。微核汇总要求唯一14例有序FMA标记。

summary.tsv在verify-results执行过程中应恰好包含此前build+micro+whole步骤且退出码全0；verify-results自身还未被run_step追加，故此时不要求该行。只有解析完成退出0后，外层run_step才追加最后verify-results成功行。控制器仍应要求整个runner成功，不能仅凭部分JSON/出现过completion就认定完成；中途写文件失败会返回失败，排他输出禁止用旧产物补齐。

按冻结进程规格作纯整数复核，结果与README及解析器一致：

| 成员特征 | micro例数 | whole/ALLOC | noop | shared-only实际注入case | budget cases | whole进程 | micro进程 | process_count | TSV步骤（含verify） |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| T8 | 14 | 433 | 52 | 0 | 27 | 13 | 1 | 14 | 22 |
| T10 | 28 | 518 | 64 | 85 | 32 | 16 | 2 | 18 | 27 |
| T17/T18 | 28 | 518 | 64 | 83 | 32 | 16 | 2 | 18 | 27 |

原base whole是406，packed增加80个旧shared-only；新增budget分别27/32例。budget进程数为6/7；budget-only shared注入为0/5/3，故总shared为0/85/83。budget_x_fail、no-SVE、narrow各5例的固定汇总均有逐label五个实际维度的严格核对作为前提。JSON process_count含micro；processes列表只含whole，二者不是同一种数量。

结论范围仅为冻结通用预检与T8/T10/T17/T18声明特征相符。T18的大4×32核、packed-KB失败等完整宽核路径仍由独立wide32模块覆盖；本通用4097×9不能替代宽核入口验证。目标编译、所有实际日志和最终控制器复核仍待执行，不预测候选性能或晋级。
