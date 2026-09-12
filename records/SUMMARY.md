# 实验记录

耗时合计仅用于本地筛选，不是官方得分；排行榜数据尚未录入。

| 题目 | 版本 | 父版本 | 状态 | 合计 ms | 策略 |
|---|---|---|---|---:|---|
| conv | C0 | — | 历史证据 | 1881.67 | 输出方向 32 路分块；固定 16/8/4/2/1 尾块；kernel 两步展开；保持每个输出的累加顺序。 |
| zgemm | Z0 | — | 历史证据 | 4566.78 | 3×4 NEON 微内核；打包实部、虚部及两者之和；三个实数点积恢复复数结果；24 行缓存块。 |
| trsm | T0 | — | 历史证据 | 777.85 | 三角矩阵工作集不超过 64 MiB 时使用 4×8 打包前代；否则使用 256 行对角块、64×64 更新块和 4×8 NEON 更新微内核。64 MiB 是算法选择预算，并非机器缓存容量声明。 |
| conv | C0-r1 | — | passed | 1869.70 | Retry unchanged C0 baseline after fixing empty CPU-list handling in shared remote wrapper |
| conv | C0-r2 | — | passed | 1867.77 | Recheck unchanged 32-column baseline immediately before the single-step kernel-loop candidate |
| conv | C0-r3 | — | passed | 1867.62 | 本轮原版复测；保持32列两步展开，建立当前时段同资源的比较基线 |
| conv | C0-r4 | — | passed | 1867.88 | 同一调度作业内顺序比较的原版基线；与C4/C5/C6共享38核和NUMA，排除分配差异 |
| conv | C0-r5 | — | passed | 1867.33 | 与显式SVE候选共享同一次38核单NUMA分配的原版基线；官方编译与校验不变 |
| conv | C0 | — | failed | — | 原包CONV当前源码在同一机器上的三轮基线复测 |
| conv | C1-block | C0-r1 | passed | 2234.15 | 32列NEON块内复用相邻kernel列的重叠输入向量：每两个kernel元素16次向量加载减为9次，新增7次vext；保持float乘加分离和累加顺序，待鲲鹏测量确认。 |
| conv | C2-b64 | C0-r1 | passed | 2685.67 | Increase output tile from 32 to 64 while preserving scalar accumulation order; reduce kernel reload and loop overhead; verify register-pressure tradeoff. |
| conv | C3-u1 | C0-r2 | passed | 1883.78 | Keep 32 output columns and switch kernel loop unroll from 2 to 1; test reduced temporary-register pressure without changing accumulation order. |
| conv | C4-b24 | C0-r4 | passed | 1951.20 | 单因素假设：将 run.sh 的 CONV_BLOCK 默认值从 32 减到 24，降低同时存活的累加器与寄存器压力；保留双步展开、严格浮点、官方 benchmark 和全部评测条件。 父版本更新为本轮 C0-r3 复测，其源码与 C0-r2 完全一致。 |
| conv | C5-b48 | C0-r4 | passed | 2422.02 | 单因素假设：将 run.sh 的 CONV_BLOCK 默认值从 32 增到 48，分摊卷积核加载与循环控制开销；保留双步展开、严格浮点、官方 benchmark 和全部评测条件。 父版本更新为本轮 C0-r3 复测，其源码与 C0-r2 完全一致。 |
| conv | C6-row2 | C0-r4 | passed | 1899.90 | Fuse two output rows by sixteen columns with thirty-two float accumulators; share kernel coefficients, preserve strict jk/ik accumulation and two-step unroll; keep nondefault block fallback |
| conv | C7-r1 | — | passed | 643.06 | C1显式四向量SVE当前最佳版复测；与八向量候选共享同一38核单NUMA分配 |
| conv | C7-sve64 | C0-r5 | passed | 642.91 | 保持generic TU和严格累加顺序，仅SVE目标函数用4个寄存器向量处理连续输出；与同源码原版C0-r5共享一次38核单NUMA分配比较；非SVE保留通用路径 |
| conv | C8-r1 | — | passed | 629.91 | C2八向量SVE当前最佳版复测；与十六向量候选共享同一38核单NUMA分配 |
| conv | C8-sve128 | C7-r1 | passed | 630.50 | 与 C7-sve64 并行候选：以其已验证 SVE 实现为模板，将独立累加器从 4 增至 8，每块 8*svcntw() 个输出（当前实机128列），提高指令并行、分摊循环开销；可能增加寄存器和缓存压力。保持运行时 SVE 检查、逐输出严格累加顺序、回退路径、run.sh 和官方 benchmark 不变。 |
| conv | C9-sve256 | C8-r1 | passed | 649.39 | 本轮最后一个有界并行候选：以 C8 的 8 个 SVE 累加器实现为模板扩展到 16 个显式独立累加器，每块 16*svcntw() 个输出（当前实机256列）；提高独立指令并行并分摊循环控制，但更大工作集与寄存器压力可能导致栈spill。保持运行时检查、strict逐输出累加顺序、回退路径、run.sh和official benchmark。当前parent C7-r1（已晋级C1源码）；尚未性能测量前协调者按C8对照结果选择共同基线。 |
| trsm | T0-r1 | T0 | passed | 784.80 | 与首轮T0源码和参数完全相同的独立复测；按T0、T1-panel、T0-r1、T1-panel-r1顺序交错运行，核查小用例波动与打包收益；不代表新优化版本 |
| trsm | T0-r2 | — | passed | 778.18 | T0源码不变的同一资源分配内三轮测量基线；与T2-k128及T2-unroll交错测量，避免独立作业CPU/NUMA变化；不是新优化版本 |
| trsm | T0-r3 | — | passed | 776.95 | T0源码不变，专用于与T1-panel打包版在同一38核单NUMA分配内交错三轮确认收益；非新优化版本 |
| trsm | T0 | — | passed | 781.24 | 当前TRSM已验证源码的同环境三轮基线复测，优先验证官方KML |
| trsm | T1-colreuse | T0 | passed | 766.26 | derived_from T1-panel：基于已测已解右端项打包实现，仅将 solve_blocked 更新微块内部 i/j 循环顺序交换为 j/i，使同一已解 RHS 连续面板依次供同一 CT 块的多行更新复用；父版本仍为当前最佳 T0，其余代码、分块、线程、精度、benchmark 和 runner 均不变，检验面板复用局部性的单一假设 |
| trsm | T1-panel-r1 | T1-panel | passed | 762.91 | 与首轮T1-panel源码和参数完全相同的独立复测；按T0、T1-panel、T0-r1、T1-panel-r1顺序交错运行，核查小用例波动与打包收益；不代表新优化版本 |
| trsm | T1-panel-r2 | T0-r3 | passed | 758.31 | 与T1-panel源码逐字节相同的确认测量；同分配交错三轮，解决首轮波动过大的晋级不确定性；不是新实现 |
| trsm | T1-panel | T0 | passed | 761.41 | 大工作集分块前代每个已解256x8右端项块共享打包为连续面板，使所有下方4x8更新复用连续读取，降低跨行大步长访存；其余算法与分块不变 |
| trsm | T2-k128 | T0-r2 | passed | 784.74 | 仅将大工作集 solve_blocked 的 KB 从256改为128，减少每次4x8更新和对角求解的活动工作集；检验更小k块的缓存/地址转换收益是否超过新增barrier与B写回成本；CT=64、内核形状、小工作集路径、参考库、线程和benchmark不变 |
| trsm | T2-unroll | T0-r2 | passed | 773.05 | 基于T0，仅对大工作集NEON update4x8的k点积循环显式2步展开，保持每个累加器依次累计k与k+1，单独处理奇数尾项；假设减少循环分支和地址计算并增加load/FMA调度机会，不改小工作集、分块、微核形状、预取、线程、精度、benchmark或runner |
| trsm | T1-control3 | — | failed | — | T1-panel-r2晋级源码不变；为20260909的独立SVE小路径和大路径候选建立同一38核单NUMA分配内三轮完整官方用例对照。来源T1-panel-r2，不是新实现。 |
| trsm | T1-control4 | — | failed | — | T1-panel-r2源码不变；1492036仅因预检查参考构造过慢在官方计时前停止，本记录作为新同分配三轮对照，不复用未完成成绩。 |
| trsm | T1-control5 | — | failed | — | T1-panel-r2源码不变的同分配三轮对照；显式固定TEST_RUNS=3，前组仅完成SVE预检查后因计时参数不符被guard拒绝，零官方结果。 |
| trsm | T1-control6 | — | passed | 756.94 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T3-svepanel-r1 | T1-control4 | failed | — | 与T3-svepanel实现相同的重试：只用SVE替换小路径4x8累加，其他条件不变；前组在独立预检查因软件long-double构造过慢被停止，未有官方成绩。 |
| trsm | T3-svepanel-r2 | T1-control5 | failed | — | 原T3-svepanel源码不变；显式统一TEST_RUNS=3后重试，小路径SVE单因素对照。上一组SVE预检查通过但没有官方计时。 |
| trsm | T3-svepanel-r3 | T1-control6 | passed | 780.71 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T3-svepanel | T1-control3 | failed | — | 仅将solve_panel的4x8累加微核在Linux HWCAP确认且SVE宽度恰为8个double时替换为SVE；保持每元素k累加顺序、面板布局、4行前代、回退、线程、精度与官方benchmark和run.sh不变。其余平台保留NEON/标量。 |
| trsm | T3-sveupdate-r1 | T1-control4 | failed | — | 与T3-sveupdate实现相同的重试：只用SVE替换大路径4x8更新，其他条件不变；前组在独立预检查因软件long-double构造过慢被停止，未有官方成绩。 |
| trsm | T3-sveupdate-r2 | T1-control5 | failed | — | 原T3-sveupdate源码不变；显式统一TEST_RUNS=3后重试，大路径SVE单因素对照。上一组SVE预检查通过但没有官方计时。 |
| trsm | T3-sveupdate-r3 | T1-control6 | passed | 535.06 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T3-sveupdate | T1-control3 | failed | — | 仅将solve_blocked的4x8更新微核在Linux HWCAP确认且SVE宽度恰为8个double时替换为SVE；保持256x8打包布局、k顺序、分块、C减法、分配失败步长回退、线程、精度与官方benchmark和run.sh不变。其余平台保留NEON/标量。 |
| zgemm | Z0 | — | passed | 4522.77 | 当前ZGEMM已验证源码的同环境三轮基线复测 |
| zgemm | Z0-pair1 | — | passed | 4554.89 | 保持Z0源码不变，在单个38核NUMA作业内与冻结的Z1-pack各执行三轮完整官方用例，建立可比较基线；来源Z0，TEST_RUNS=3 |
| zgemm | Z1-control2 | — | passed | 3737.22 | 保持已晋级Z1-pack-pair1源码不变，与MB48候选在同一个38核NUMA作业内各执行三轮官方用例，建立第二轮可比较控制基线；来源Z1-pack-pair1 |
| zgemm | Z1-pack | Z0 | passed | 3738.57 | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |
| zgemm | Z1-pack-pair1 | Z0-pair1 | passed | 3738.92 | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |
| zgemm | Z2-mb48 | Z1-pack-pair1 | prepared | — | 仅将MB24改为MB48，保留三行A连续打包、3x4微内核和3M累加顺序；检验增加行复用能否降低B跨行块扫描开销，K512复用域理论约624KiB（不含C），仍需实测 |
| zgemm | Z2-mb48-pair2 | Z1-control2 | passed | 3862.22 | 仅将MB24改为MB48，保留三行A连续打包、3x4微内核和3M累加顺序；检验增加行复用能否降低B跨行块扫描开销，K512复用域理论约624KiB（不含C），仍需实测 |

TRSM 2026-09-09 历史最佳为 T3-sveupdate-r3；同分配三轮合计耗时降低29.31%，详见[2026-09-09 SVE记录](../docs/trsm-sve-20260909.md)。

CONV 2026-09-09 晋级 C3（C13-exttail）：同资源交错对照 631.31 → 590.36 ms，耗时减少 6.49%；最终 ZIP 三轮 12/12 PASS、最大误差 0。见 [完整报告](../docs/CONV_SEP9.md) 与 [本轮版本记录](../docs/CONV_SEP9_ROUND_RECORDS.md)。


TRSM 2026-09-11 较早晋级：**T4-sve8rows**（parent T3-control7，来源原最佳 T3-sveupdate-r3）。三轮官方用例均通过，合计 545.31→526.19 ms，改善3.51%。[完整对照](../docs/trsm-sve8rows-20260911.md) · [提交压缩包](../outputs/trsm-best.zip)。参考仍为 OpenBLAS，非 KML 复验。


TRSM 较早晋级：**T5-sve16rows**（parent T4-control8）。同分配三轮合计518.01→506.21ms，减少2.28%，大用例减少5.52%；3份面板候选未晋级并保留全部结果。最终ZIP作业1513942解压三轮9/9 PASS；OpenBLAS参考，非KML复验。[交付](../docs/trsm-final-20260911-r2.md)。


TRSM 当前最佳：**T7-diagpanel**（parent T5-control10）：同分配三轮合计508.24→467.29 ms，减少8.06%；大用例减少15.88%。24行SVE未晋级。最终ZIP作业1524188解压三轮9/9 PASS；参考库区别与KML独立验证见[交付记录](../docs/trsm-final-20260911-r4.md)。

## TRSM 2026-09-12：T8-svepanel16

KML25.1/GCC12 作业1576028，同分配三轮27/27官方结果PASS。T8-svepanel16逐用例中位数合计508.56→447.59ms，耗时降低11.99%，超过7.67%波动门槛，已晋级；T8-paneloutline未晋级。KML25.1不等同指定25.2.0复验。[本轮记录](../docs/trsm-stage-r5-20260912.md)。


## TRSM 2026-09-12 第六轮：保留T8

作业1579365同分配三轮27/27官方结果PASS；T8/T9-neondirect/T9-lhistpack中位数合计452.02/506.81/474.48ms。两个候选均退化未晋级，保留已验证T8提交包；测量基线为T8-control12，原样初测与同分配repeat均留证。KML25.1非指定25.2.0复验。[完整记录](../docs/trsm-stage-r6-20260912.md)。


## TRSM 2026-09-12 第七轮：编译器约束未带来整题收益

作业1579401中，T8/T10-lhistbarrier各预热一套后交错正式三轮，18/18正式与6/6预热PASS；中位数合计448.21/478.04ms，T10慢6.6554%，不晋级。实际汇编消除系数spill，仍保留整题退化结果；当前最佳和提交包保持T8。KML25.1非指定25.2复验。[完整记录](../docs/trsm-stage-r7-20260912.md)。

## TRSM 2026-09-12 第八轮：宽核大用例改善待确认

作业1579444同分配三轮18/18正式及6/6预热PASS；T8/T11-sve8x16中位数合计437.65/435.97ms，合计改善0.38%，大用例改善3.57%。总体未超过11.52%波动门槛，另两例慢1.34%/2.27%，暂不晋级，保持T8提交包。新增28组微核及8组大路径/回退检查通过。KML25.1非指定25.2复验。[完整记录](../docs/trsm-stage-r8-20260912.md)。

## TRSM 2026-09-12 第九轮：宽核确认与前代调度

作业1579479最终SUCCEEDED，同分配三轮27/27正式及9/9预热PASS；T8/T11/T12中位数合计450.27/444.76/452.53ms。T11合计改善1.22%、大例2.07%，未超过4.73%波动门槛；T12合计慢0.50%，均不晋级，保持T8提交包。两份旧run完整保留，调度终态等待与先前collect拒绝也已留证。KML25.1非指定25.2复验。[完整记录](../docs/trsm-stage-r9-20260912.md)。

## TRSM 2026-09-12 第十轮：4×32 SVE 更新

作业1579585 SUCCEEDED，18/18正式、6/6预热及全部预检通过。T8/T13三组中位数合计445.21/433.53ms，T13大用例快6.49%、合计快2.62%，未超过7.55%波动门槛，不晋级。保持T8-svepanel16与现有已验证ZIP，T8-control12台账增加同源码r10运行并保留r9 prior。真实KML25.1/GCC12，不等同指定KML25.2复验；无本机题目运行、哈希或正式比赛提交。[完整报告](../docs/trsm-stage-r10-20260912.md)。

## TRSM 2026-09-12 第十一轮：T13同源码确认

作业1579600 SUCCEEDED，18/18正式、6/6预热与通用/宽核预检全部通过。T8/T13三组中位数合计443.90/431.72ms；T13大用例快6.79%、合计快2.74%，未超过3.08%波动门槛，不晋级。原T8提交包保持不变，两版本r10 prior完整保留。真实KML25.1/GCC12，非指定KML25.2复验；无本机题目运行、哈希或比赛提交。[完整报告](../docs/trsm-stage-r11-20260912.md)。
