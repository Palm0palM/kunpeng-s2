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
| conv | C10-svetail | C8-r1 | passed | 620.40 | Replace generic remainder with full SVE vectors and one predicated vector; preserve eight-vector main kernel and strict jk/ik multiply/add order, runner and official benchmark unchanged |
| conv | C11-r1 | C8-r1 | passed | 609.89 | Repeat unchanged C11-sveext candidate; matched C2 baselines in the same allocation; preserves original benchmark and strict floating-point |
| conv | C11-r2 | C8-r1 | passed | 609.55 | Repeat unchanged C11-sveext candidate; matched C2 baselines in the same allocation; preserves original benchmark and strict floating-point |
| conv | C11-sveext | C8-r1 | passed | 613.04 | Within the unchanged eight-vector SVE main block, reuse first-coefficient input vectors with svext for the next coefficient; reduce sixteen input loads to nine per coefficient pair without overread or changing strict accumulation order. Keep original tail and runner to isolate load-reuse hypothesis. |
| conv | C12-sveu1 | C8-r1 | passed | 643.28 | Use one kernel coefficient per iteration in the eight-vector SVE main block to reduce live input vectors and scheduling pressure; preserve strict order, eight accumulators, original tail, fallback and runner. |
| conv | C13-exttail | C8-r3 | passed | 590.36 | Combine independently validated SVE input-vector reuse with SVE 4/2/1 predicated tail, hypothesizing that the load reduction and tail speedup are complementary. Keep eight-vector main block and strict reference accumulation. |
| conv | C13-package | — | passed | 590.65 | Final C3 ZIP verification: upload exact ZIP bytes, verify archive checksum on compute node, extract and check every source file before unmodified wrapper executes three full official suites. No local compilation or tests. |
| conv | C13-r1 | C8-r1 | passed | 590.17 | Repeat unchanged C13-exttail candidate; matched C2 baselines in the same allocation; preserves original benchmark and strict floating-point |
| conv | C13-r2 | — | passed | 591.44 | Unchanged newly promoted C3 ext-plus-tail code, matched baseline for four-coefficient reuse candidate |
| conv | C13-r3 | — | passed | 590.14 | C3 当前已晋级源码在 2026-09-11 同资源基线复测；保持四个文件与 C13-exttail 相同 |
| conv | C13-r4 | — | passed | 589.76 | C3 同一次分配末尾控制测量，检查 C13-r3 到候选后的性能漂移；源码完全相同 |
| conv | C13-r5 | — | passed | 589.08 | C3 与十六向量/尾部成对复用候选在同一38核单NUMA分配内的开头控制 |
| conv | C13-r6 | — | passed | 588.46 | C3 同一分配结束时控制测量，检查十六向量/尾部候选测试期间漂移 |
| conv | C13-r7 | — | passed | 588.87 | C3与SVE双行输入复用候选同一分配开头控制测量 |
| conv | C13-r8 | — | passed | 589.49 | C3与SVE双行输入复用候选同一分配末尾控制测量 |
| conv | C13-r9 | — | passed | 591.29 | Fresh C3 control to confirm rowpair gain after initial control noise |
| conv | C14-ext4 | C13-r2 | passed | 739.47 | Exploratory extension of C13-exttail: reuse eight loaded SVE vectors across four adjacent kernel coefficients instead of two; eleven input vector loads plus twenty-one extracts per four coefficients, versus eighteen loads/fourteen extracts for pairwise reuse. Preserve exact accumulation sequence, bounds, tail and official runner. |
| conv | C15-pipe8 | C13-r3 | passed | 590.71 | 八累加器不变，逐对处理相邻输入向量，缩短输入寄存器生存期并减少 svext 前复制；浮点累加顺序保持 |
| conv | C16-pipe12 | C13-r3 | passed | 586.78 | 使用十二个输出向量累加器与流式相邻输入复用，提高每次内核遍历覆盖；保留两系数顺序与原尾部处理 |
| conv | C17-pipe16 | C13-r5 | passed | 629.45 | 将十六累加器与流式相邻输入复用结合，验证缩短输入生存期能否消除旧 C9 的寄存器溢出；尾部与数值顺序不变 |
| conv | C18-tailpair | C13-r5 | passed | 588.27 | 主八向量内核保持C3不变；仅SVE尾部4/2完整向量采用两系数相邻输入复用并保留单系数与predicated尾部，减少尾部加载与循环开销 |
| conv | C19-package | C19-r2 | passed | 562.02 | Independent verification of the exact final submission ZIP on a scheduled compute node; three full official suites |
| conv | C19-r1 | C19-sverow2 | passed | 562.32 | 同一SVE双行候选重复三轮完整官方套件；与末尾C3控制共同确认稳定性，不构成新正式版本 |
| conv | C19-r2 | C13-r9 | passed | 561.54 | Repeat unchanged SVE rowpair source against a fresh C3 control, before final package validation |
| conv | C19-r3 | — | passed | 563.98 | Current verified C4 source, fresh opening control for the next optimization round |
| conv | C19-r4 | — | passed | 561.93 | Unchanged C4 closing control for the next matched-allocation comparison |
| conv | C19-r5 | — | passed | 562.29 | Fresh unchanged C4 closing control for reversed-order C21 confirmation |
| conv | C19-r6 | — | passed | 561.72 | Unchanged C4 opening control for bracketed C21 confirmation after noisy reversed-order run |
| conv | C19-r7 | — | passed | 561.60 | Unchanged C4 closing primary control for bracketed C21 confirmation after noisy reversed-order run |
| conv | C19-sverow2 | C13-r7 | passed | 562.12 | 把两行各4个SVE向量合成8累加器，通过错开kernel行索引复用同一输入行；每个输出仍保持jk/ik累加顺序，减少相邻输出行的重复加载 |
| conv | C2-b64 | C0-r1 | passed | 2685.67 | Increase output tile from 32 to 64 while preserving scalar accumulation order; reduce kernel reload and loop overhead; verify register-pressure tradeoff. |
| conv | C20-row2x6 | C19-r3 | passed | 555.90 | Expand the two-row SVE tile from four to six vectors per row, amortizing kernel traversal while preserving per-output accumulation order |
| conv | C21-package | C21-row3x4 | passed | 502.29 | Independent final ZIP identity, compute-node extraction, and three complete official suites for unchanged C21 source |
| conv | C21-r1 | C19-r5 | passed | 502.31 | Unchanged C21 three-output-row source; reversed-order confirmation against fresh C4 control C19-r5 |
| conv | C21-r2 | C19-r7 | passed | 502.20 | Unchanged C21 source; bracketed repeat after single-case timing outlier, primary comparison baseline C19-r7 declared before execution |
| conv | C21-row3x4 | C19-r3 | passed | 502.45 | Share an input row across three output rows, four SVE vectors per row, preserving each output kernel row order |
| conv | C22-row2loads | C19-r3 | passed | 522.48 | In the shared two-output-row loop only, replace overlapping SVE ext windows with direct shifted loads to trade three loads for three ext plus three movprfx instructions |
| conv | C3-u1 | C0-r2 | passed | 1883.78 | Keep 32 output columns and switch kernel loop unroll from 2 to 1; test reduced temporary-register pressure without changing accumulation order. |
| conv | C4-b24 | C0-r4 | passed | 1951.20 | 单因素假设：将 run.sh 的 CONV_BLOCK 默认值从 32 减到 24，降低同时存活的累加器与寄存器压力；保留双步展开、严格浮点、官方 benchmark 和全部评测条件。 父版本更新为本轮 C0-r3 复测，其源码与 C0-r2 完全一致。 |
| conv | C5-b48 | C0-r4 | passed | 2422.02 | 单因素假设：将 run.sh 的 CONV_BLOCK 默认值从 32 增到 48，分摊卷积核加载与循环控制开销；保留双步展开、严格浮点、官方 benchmark 和全部评测条件。 父版本更新为本轮 C0-r3 复测，其源码与 C0-r2 完全一致。 |
| conv | C6-row2 | C0-r4 | passed | 1899.90 | Fuse two output rows by sixteen columns with thirty-two float accumulators; share kernel coefficients, preserve strict jk/ik accumulation and two-step unroll; keep nondefault block fallback |
| conv | C7-r1 | — | passed | 643.06 | C1显式四向量SVE当前最佳版复测；与八向量候选共享同一38核单NUMA分配 |
| conv | C7-sve64 | C0-r5 | passed | 642.91 | 保持generic TU和严格累加顺序，仅SVE目标函数用4个寄存器向量处理连续输出；与同源码原版C0-r5共享一次38核单NUMA分配比较；非SVE保留通用路径 |
| conv | C8-r1 | — | passed | 629.91 | C2八向量SVE当前最佳版复测；与十六向量候选共享同一38核单NUMA分配 |
| conv | C8-r2 | — | passed | 631.13 | C2 unchanged source; September 9 matched-allocation baseline for SVE predicated tail candidate |
| conv | C8-r3 | — | passed | 631.31 | Unchanged C2 baseline; repeated before/after candidates in one pinned-node allocation to detect timing drift |
| conv | C8-r4 | — | passed | 631.37 | Unchanged C2 baseline; repeated before/after candidates in one pinned-node allocation to detect timing drift |
| conv | C8-sve128 | C7-r1 | passed | 630.50 | 与 C7-sve64 并行候选：以其已验证 SVE 实现为模板，将独立累加器从 4 增至 8，每块 8*svcntw() 个输出（当前实机128列），提高指令并行、分摊循环开销；可能增加寄存器和缓存压力。保持运行时 SVE 检查、逐输出严格累加顺序、回退路径、run.sh 和官方 benchmark 不变。 |
| conv | C9-sve256 | C8-r1 | passed | 649.39 | 本轮最后一个有界并行候选：以 C8 的 8 个 SVE 累加器实现为模板扩展到 16 个显式独立累加器，每块 16*svcntw() 个输出（当前实机256列）；提高独立指令并行并分摊循环控制，但更大工作集与寄存器压力可能导致栈spill。保持运行时检查、strict逐输出累加顺序、回退路径、run.sh和official benchmark。当前parent C7-r1（已晋级C1源码）；尚未性能测量前协调者按C8对照结果选择共同基线。 |
| conv | C21-r3 | — | passed | 502.27 | Fresh unchanged C5 baseline for the next optimization round; three complete official suites |
| conv | C21-r4 | — | passed | 502.34 | Unchanged C5 opening control for same-allocation comparison of C23/C24/C25 |
| conv | C23-row3loads | C21-r3 | passed | 486.55 | In the C5 three-output-row shared middle loop only, replace three ext windows with direct shifted loads to trade load bandwidth for fewer shuffle instructions |
| conv | C24-row4x4 | C21-r3 | passed | 483.59 | Share input rows across four output rows and four SVE vectors each, preserving strict per-output accumulation order |
| conv | C25-row3x6 | C21-r3 | passed | 499.01 | Expand the C5 three-output-row tile from four to six vectors per row, amortizing kernel and loop overhead with eighteen accumulators |
| conv | C21-r5 | — | passed | 502.31 | Unchanged C5 closing primary control for same-allocation comparison of C23/C24/C25; selected before performance execution |
| conv | C21-r6 | — | passed | 502.38 | Unchanged C5 opening control for Sep12 same-allocation followup |
| conv | C24-r1 | C21-r7 | passed | 483.83 | Repeat unchanged four-row/four-vector candidate alongside C26 and C27 and bracketed C5 controls |
| conv | C26-row4loads | C21-r7 | passed | 452.58 | Combine four-output-row sharing with direct shifted input loads in the shared middle phase only; remove three ext windows while preserving arithmetic order |
| conv | C27-row3staged | C21-r7 | passed | 521.20 | Keep the eighteen-accumulator tile but constrain GCC scheduling between per-vector three-row updates to reduce live input-window registers and target the observed c4 spill |
| conv | C21-r7 | — | passed | 502.51 | Unchanged C5 closing primary control predeclared before Sep12 followup |
| conv | C21-r8 | — | passed | 502.64 | Unchanged C5 confirmation control; no new algorithm version |
| conv | C26-r1 | C21-r9 | passed | 452.62 | Independent repeat of unchanged C26-row4loads against bracketed C5 controls |
| conv | C21-r9 | — | passed | 502.35 | Unchanged C5 confirmation control; no new algorithm version |
| conv | C26-package | C26-row4loads | passed | 452.66 | Independent exact final C26 ZIP compute-node extraction and three complete official suites; only submit after confirmation |
| trsm | T0-r1 | T0 | passed | 784.80 | 与首轮T0源码和参数完全相同的独立复测；按T0、T1-panel、T0-r1、T1-panel-r1顺序交错运行，核查小用例波动与打包收益；不代表新优化版本 |
| trsm | T0-r2 | — | passed | 778.18 | T0源码不变的同一资源分配内三轮测量基线；与T2-k128及T2-unroll交错测量，避免独立作业CPU/NUMA变化；不是新优化版本 |
| trsm | T0-r3 | — | passed | 776.95 | T0源码不变，专用于与T1-panel打包版在同一38核单NUMA分配内交错三轮确认收益；非新优化版本 |
| trsm | T0 | — | passed | 781.24 | 当前TRSM已验证源码的同环境三轮基线复测，优先验证官方KML |
| trsm | T1-colreuse | T0 | passed | 766.26 | derived_from T1-panel：基于已测已解右端项打包实现，仅将 solve_blocked 更新微块内部 i/j 循环顺序交换为 j/i，使同一已解 RHS 连续面板依次供同一 CT 块的多行更新复用；父版本仍为当前最佳 T0，其余代码、分块、线程、精度、benchmark 和 runner 均不变，检验面板复用局部性的单一假设 |
| trsm | T1-control3 | — | failed | — | T1-panel-r2晋级源码不变；为20260909的独立SVE小路径和大路径候选建立同一38核单NUMA分配内三轮完整官方用例对照。来源T1-panel-r2，不是新实现。 |
| trsm | T1-control4 | — | failed | — | T1-panel-r2源码不变；1492036仅因预检查参考构造过慢在官方计时前停止，本记录作为新同分配三轮对照，不复用未完成成绩。 |
| trsm | T1-control5 | — | failed | — | T1-panel-r2源码不变的同分配三轮对照；显式固定TEST_RUNS=3，前组仅完成SVE预检查后因计时参数不符被guard拒绝，零官方结果。 |
| trsm | T1-control6 | — | passed | 756.94 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T1-panel-r1 | T1-panel | passed | 762.91 | 与首轮T1-panel源码和参数完全相同的独立复测；按T0、T1-panel、T0-r1、T1-panel-r1顺序交错运行，核查小用例波动与打包收益；不代表新优化版本 |
| trsm | T1-panel-r2 | T0-r3 | passed | 758.31 | 与T1-panel源码逐字节相同的确认测量；同分配交错三轮，解决首轮波动过大的晋级不确定性；不是新实现 |
| trsm | T1-panel | T0 | passed | 761.41 | 大工作集分块前代每个已解256x8右端项块共享打包为连续面板，使所有下方4x8更新复用连续读取，降低跨行大步长访存；其余算法与分块不变 |
| trsm | T2-k128 | T0-r2 | passed | 784.74 | 仅将大工作集 solve_blocked 的 KB 从256改为128，减少每次4x8更新和对角求解的活动工作集；检验更小k块的缓存/地址转换收益是否超过新增barrier与B写回成本；CT=64、内核形状、小工作集路径、参考库、线程和benchmark不变 |
| trsm | T2-unroll | T0-r2 | passed | 773.05 | 基于T0，仅对大工作集NEON update4x8的k点积循环显式2步展开，保持每个累加器依次累计k与k+1，单独处理奇数尾项；假设减少循环分支和地址计算并增加load/FMA调度机会，不改小工作集、分块、微核形状、预取、线程、精度、benchmark或runner |
| trsm | T3-control7 | — | passed | 545.31 | 已晋级 T3-sveupdate-r3 原样复测，与 8 行 SVE 候选同分配交错三轮。 |
| trsm | T3-svepanel-r1 | T1-control4 | failed | — | 与T3-svepanel实现相同的重试：只用SVE替换小路径4x8累加，其他条件不变；前组在独立预检查因软件long-double构造过慢被停止，未有官方成绩。 |
| trsm | T3-svepanel-r2 | T1-control5 | failed | — | 原T3-svepanel源码不变；显式统一TEST_RUNS=3后重试，小路径SVE单因素对照。上一组SVE预检查通过但没有官方计时。 |
| trsm | T3-svepanel-r3 | T1-control6 | passed | 780.71 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T3-svepanel | T1-control3 | failed | — | 仅将solve_panel的4x8累加微核在Linux HWCAP确认且SVE宽度恰为8个double时替换为SVE；保持每元素k累加顺序、面板布局、4行前代、回退、线程、精度与官方benchmark和run.sh不变。其余平台保留NEON/标量。 |
| trsm | T3-sveupdate-r1 | T1-control4 | failed | — | 与T3-sveupdate实现相同的重试：只用SVE替换大路径4x8更新，其他条件不变；前组在独立预检查因软件long-double构造过慢被停止，未有官方成绩。 |
| trsm | T3-sveupdate-r2 | T1-control5 | failed | — | 原T3-sveupdate源码不变；显式统一TEST_RUNS=3后重试，大路径SVE单因素对照。上一组SVE预检查通过但没有官方计时。 |
| trsm | T3-sveupdate-r3 | T1-control6 | passed | 535.06 | 不计算或验证哈希的同源码重试；以T1-panel为对照，单独测量SVE小路径或大路径；显式OpenBLAS静态库、TEST_RUNS=3、三轮完整官方用例。 |
| trsm | T3-sveupdate | T1-control3 | failed | — | 仅将solve_blocked的4x8更新微核在Linux HWCAP确认且SVE宽度恰为8个double时替换为SVE；保持256x8打包布局、k顺序、分块、C减法、分配失败步长回退、线程、精度与官方benchmark和run.sh不变。其余平台保留NEON/标量。 |
| trsm | T4-control8 | — | passed | 518.01 | 已晋级 T4-sve8rows 源码原样复测，与16行SVE和双面板候选同分配交错三轮。 |
| trsm | T4-sve8rows | T3-control7 | passed | 526.19 | 大工作集 SVE 更新从4行扩至8行，一次X加载供8条按k递增的累加链复用；保留4行尾块、NEON与分配失败回退。 |
| trsm | T5-control9 | — | passed | 507.49 | 已晋级16行SVE源码原样同分配三轮复测，作为工作集受限2/4面板候选的对照。 |
| trsm | T5-panelpair | T4-control8 | passed | 523.48 | 小工作集前代按两组相邻8列面板共同行块推进，使L行数据复用；面板数至少为实际线程数4倍时配对，保持原NEON累加顺序、大路径与失败回退。 |
| trsm | T5-sve16rows | T4-control8 | passed | 506.21 | 大工作集完整行块从8x8扩为16x8 SVE更新，16条独立递增k累加链复用一次X加载；保留8/4行尾块、NEON和分配失败回退。 |
| trsm | T6-pair2budget | T5-control9 | passed | 506.43 | 保留原小路径，只有2组面板加4行L的估算工作集不超过256KiB时启用分组；分组后的任务至少为实际线程数2倍，其余走原始路径。 |
| trsm | T6-pair4budget | T5-control9 | passed | 502.70 | 保留原小路径，只有4组面板加4行L的估算工作集不超过256KiB时启用分组；分组后的任务至少为实际线程数2倍，其余走原始路径。 |
| zgemm | Z0-pair1 | — | passed | 4554.89 | 保持Z0源码不变，在单个38核NUMA作业内与冻结的Z1-pack各执行三轮完整官方用例，建立可比较基线；来源Z0，TEST_RUNS=3 |
| zgemm | Z0 | — | passed | 4522.77 | 当前ZGEMM已验证源码的同环境三轮基线复测 |
| zgemm | Z1-control2 | — | passed | 3737.22 | 保持已晋级Z1-pack-pair1源码不变，与MB48候选在同一个38核NUMA作业内各执行三轮官方用例，建立第二轮可比较控制基线；来源Z1-pack-pair1 |
| zgemm | Z1-pack-pair1 | Z0-pair1 | passed | 3738.92 | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |
| zgemm | Z1-pack | Z0 | passed | 3738.57 | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |
| zgemm | Z2-mb48-pair2 | Z1-control2 | passed | 3862.22 | 仅将MB24改为MB48，保留三行A连续打包、3x4微内核和3M累加顺序；检验增加行复用能否降低B跨行块扫描开销，K512复用域理论约624KiB（不含C），仍需实测 |
| zgemm | Z2-mb48 | Z1-pack-pair1 | prepared | — | 仅将MB24改为MB48，保留三行A连续打包、3x4微内核和3M累加顺序；检验增加行复用能否降低B跨行块扫描开销，K512复用域理论约624KiB（不含C），仍需实测 |

TRSM 2026-09-09 历史最佳为 T3-sveupdate-r3；同分配三轮合计耗时降低29.31%，详见[2026-09-09 SVE记录](../docs/trsm-sve-20260909.md)。

CONV 2026-09-09 晋级 C3（C13-exttail）：同资源交错对照 631.31 → 590.36 ms，耗时减少 6.49%；最终 ZIP 三轮 12/12 PASS、最大误差 0。见 [完整报告](../docs/CONV_SEP9.md) 与 [本轮版本记录](../docs/CONV_SEP9_ROUND_RECORDS.md)。


TRSM 2026-09-11 较早晋级：**T4-sve8rows**（parent T3-control7，来源原最佳 T3-sveupdate-r3）。三轮官方用例均通过，合计 545.31→526.19 ms，改善3.51%。[完整对照](../docs/trsm-sve8rows-20260911.md) · [提交压缩包](../outputs/trsm-best.zip)。参考仍为 OpenBLAS，非 KML 复验。


TRSM 较早晋级：**T5-sve16rows**（parent T4-control8）。同分配三轮合计518.01→506.21ms，减少2.28%，大用例减少5.52%；3份面板候选未晋级并保留全部结果。最终ZIP作业1513942解压三轮9/9 PASS；OpenBLAS参考，非KML复验。[交付](../docs/trsm-final-20260911-r2.md)。


TRSM 历史版本：**T7-diagpanel**（parent T5-control10）：同分配三轮合计508.24→467.29 ms，减少8.06%；大用例减少15.88%。24行SVE未晋级。最终ZIP作业1524188解压三轮9/9 PASS；参考库区别与KML独立验证见[交付记录](../docs/trsm-final-20260911-r4.md)。


CONV 2026-09-12：C28/C29/C30 三候选完成361,512项专项及60/60性能用例；均未达到晋级门槛，正式提交仍用C6。C30约1.04%的初步改善低于对照2.02%的波动，全部样本保留，见[本轮记录](../docs/CONV_SEP12B.md)。


CONV 2026-09-12 后续复测：C30-r1与C32同资源12套件48/48 PASS；C30-r1仅减少0.97%，C32增加10.62%，均不晋级，正式提交继续用C6。完整样本及C32的121,560项专项见[后续记录](../docs/CONV_SEP12C.md)。

## TRSM 2026-09-12：T8-svepanel16

KML25.1/GCC12 作业1576028，同分配三轮27/27官方结果PASS。T8-svepanel16逐用例中位数合计508.56→447.59ms，耗时降低11.99%，超过7.67%波动门槛，已晋级；T8-paneloutline未晋级。KML25.1不等同指定25.2.0复验。[本轮记录](../docs/trsm-stage-r5-20260912.md)。


CONV 五行共享 C33：250,008项专项及同资源9套件36/36性能用例全部通过，但467.13ms比C6的452.38ms增加3.26%，不晋级，仍交付C6。全部样本见[本轮记录](../docs/CONV_SEP12D.md)。

CONV 访问与调度三方案：419,076项专项和18套件72/72性能用例全部通过。C34比同轮C6慢4.66%，C35/C36差异不足0.1%，均未晋级；C30-r2仅作归因对照。正式提交仍为C6，[全部样本与结论](../docs/CONV_SEP12E.md)。

CONV 单列循环与编译调优：同资源15套件60/60 PASS；C37/C39比C6慢1.58%/1.62%，C38拆分构建仅作对照，无确认收益。另有152,688项专项及原runner的8个用例通过，继续交付C6。[完整记录](../docs/CONV_SEP12F.md)。

CONV 六行/五行分块：同资源12套件48/48 PASS，专项共53,520项通过。C40比C6快1.78%，仍低于前后对照的波动门槛；C41慢4.22%，C42因GCC10不接受汇编操作数格式而编译失败、零项数值执行。继续交付C6，完整样本与2,666个quad热点样本见[本轮记录](../docs/CONV_SEP12G.md)。

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

## TRSM 2026-09-12 第十二轮：CT分块比较

作业1579645 SUCCEEDED，同分配四成员三轮36/36正式、12/12预热及全部预检通过。T8/T13-CT64/T15-CT128/T16-CT32合计438.60/418.63/431.34/422.00ms；较T8分别改善4.55%/1.66%/3.78%，均未超过对应5.26%/5.26%/6.64%波动门槛，不晋级。T13大例快7.15%，CT128/CT32大例分别比T13慢4.75%/2.22%；小路径没有对应源码改动，前两例差异不归因为CT。保持T8和已验证ZIP，两份r11 prior保留。真实KML25.1/GCC12，非指定KML25.2复验；无本机题目运行、哈希或比赛提交。[完整报告](../docs/trsm-stage-r12-20260912.md)。

## TRSM 2026-09-12 第十三轮：共享历史生产调度未改善

作业1579673 SUCCEEDED，27/27正式、9/9预热及全部预检通过。T8/T10/T14中位数合计449.93/469.75/471.64ms；T14较T8中例慢11.28%、合计慢4.83%，相对T10中例慢0.09%、合计慢0.40%，不晋级。保留T8提交包，T8的r12 prior与T10的r7 prior分别留存。实际KML25.1/GCC12，非指定KML25.2复验；无本机题目运行、哈希或比赛提交。[完整报告](../docs/trsm-stage-r13-20260912.md)。

## CONV J/K 独立确认

CONV 六行方案追加两组独立测量，共18套件72/72 PASS、误差为零。J 轮比 C6 快1.737%，达到复测门槛；K 轮快1.763%，但候选自身波动2.738%，未通过独立确认。全部样本保留，继续交付 C6；没有生成 C7 提交包。[完整记录](../docs/CONV_SEP12K.md)。

## CONV 输入复制与行距对照

CONV 输入复制与行距对照完成：434,352项专项检查及12套件48/48性能用例全部通过，但C43调整行距比C6慢4.10%，C44只复制输入慢4.29%；C43/C44差异也未达到行距收益门槛。全部样本和退化策略已留档，继续交付C6。[完整记录](../docs/CONV_SEP12H.md)。
## TRSM 2026-09-12 第十四轮：预算与宽核组合待确认

作业1579730 SUCCEEDED，36/36正式、12/12预热及全部预算/宽核预检通过。T8/T10/T17/T18合计461.91/471.53/440.51/429.91ms；T17/T18较T8快4.63%/6.93%，均未超过27.56%波动门槛，不晋级，保持T8提交包。T18小/中/大例快22.95%/0.28%/13.04%；全部样本保留，两份r13 prior留存。下一步同源码复测T8/T18。真实KML25.1/GCC12，非指定KML25.2复验；无本机题目运行、哈希或比赛提交。[完整报告](../docs/trsm-stage-r14-20260912.md)。

## TRSM 2026-09-12 第十五轮：T18确认仍未越过波动门槛

作业1579788 SUCCEEDED，18/18正式、6/6预热及全部预算/宽核预检通过。T8/T18合计449.97/433.41ms，T18小例快21.93%、中例慢0.28%、大例快6.76%，合计改善3.68%未超过11.86%波动门槛，保持T8提交包。两版本r14 prior完整保留，未混合历史样本。真实KML25.1/GCC12，非指定KML25.2复验；无本机题目运行、哈希或比赛提交。[完整报告](../docs/trsm-stage-r15-20260912.md)。

## CONV I diagnostics

C45-row4dup4 and C46-row5x5asmfix independently passed 121560 and 27408 scheduled-node checks (jobs 1579762 and 1579795). GCC 10.3.1, six VL/thread configurations, all 19 stage exits and scheduler/job/wrapper exits zero. Actual C45 shared loop has six vector spill loads/stores; C46 quint has none. Performance remains unmeasured; retain C6. [Full report](../docs/CONV_SEP12I.md).

CONV N round completed 96/96 benchmark checks in job 1581459. C45/C49/C46/C47/C48 totals were 557.35/511.76/516.89/450.63/448.13 ms versus closing C6 452.38 ms; none passed both unchanged-C6 gates. C40-r3 444.44 ms remains reference-only and does not change G/J/K decisions. O diagnosis passed 121560 checks, but eliminating vector spills did not beat C6. All samples and the recovered metadata-recording failure are preserved in [N](../docs/CONV_SEP12N.md) and [O](../docs/CONV_SEP12O.md). C6 remains the submission package.

## TRSM 第十六轮：T19 8×16 双面板前代（2026-09-13交付）

T19-panel8x16budget 已晋级。作业1579861同分配ABC/BCA/CAB三轮，27/27正式与9/9预热PASS，T8→T19小/中/大用例耗时减少23.33%/48.85%/7.06%，合计444.75→313.20ms（减少29.58%），超过8.53%门槛。T18未晋级；全部原始样本及完整预检保留。最终ZIP作业1581516独立解压三套9/9 PASS，15,593字节，包验证合计317.01ms不与策略比较混算。实际KML25.1/GCC12，非指定KML25.2复验；未本机运行或算哈希，未正式提交比赛。[比较记录](../docs/trsm-stage-r16-20260912.md) · [最终交付](../docs/trsm-final-20260912-r16.md)。

## CONV 七行候选初筛通过

C51 的 Q 作业1581822完成37128/37128专项检查，完整七行helper无向量spill；R作业1581911的48/48原benchmark样本全部PASS。同分配C6开头/C51/C40参考/C6结尾合计为452.32/438.95/444.40/452.28ms。C51对两端C6快2.9559%/2.9473%，达到初筛门槛；第一例分别慢0.9146%/0.8949%，仍需独立确认，当前保留C6。C40辅助比较不通过，不改写其历史判定。全部48样本与严格门槛见[Q专项](../docs/CONV_SEP13Q.md)和[R测速](../docs/CONV_SEP13R.md)。

## CONV 七行独立确认保留全部波动

S作业1582067，36/36 PASS，C6/C51-r1/C6为452.26/438.88/452.26ms，收益2.958475%。开头门槛1%通过；结尾C6第一组54.13/51.40/51.38ms，波动5.350195%，结尾门槛未通过。候选第一组中位数退步0.856198%/0.836576%，均未超过1%；失败来自结束对照波动。全部样本保留，R初筛与S不混算，C6继续交付，不重复本次失败确认，也不生成C7包。[完整记录](../docs/CONV_SEP13S.md)。

## TRSM 第十七轮（2026-09-13）

T20-wideunroll2 同分配三轮大例快 3.70%、合计快 1.50%，低于 4.67% 波动门槛，中例慢 1.70%，不晋级。作业 1581862 的 18/18 正式和 6/6 预热结果通过，两个成员的宽核预检通过。保持 T19 实现和现有 ZIP，当前测量基线 T19-control13；实际 KML25.1/GCC12，未完成指定 KML25.2 复验。[记录](../docs/trsm-stage-r17-20260913.md)。

## TRSM 第十八轮（2026-09-13）

作业 1582004 同分配三轮 18/18 正式、6/6 预热及宽核预检通过。T20 小/中/大例快 2.05%/1.86%/3.26%，合计 318.05→309.57 ms（快 2.67%），低于 3.30% 波动门槛，未晋级，保持 T19 与既有 ZIP。完整 r17 prior 保留，不混合历史样本。实际 KML25.1/GCC12，非指定 KML25.2 复验；没有本机题目运行或哈希操作。[记录](../docs/trsm-stage-r18-20260913.md)。

## TRSM 第十九轮（2026-09-13）

作业 1582129 同分配三版交错三轮，27/27 正式、9/9 预热及全部宽核预检通过。T19/T20/T21 合计 316.73/308.10/314.81 ms；T20 快 2.72% 低于 8.32% 门槛，T21 快 0.61% 低于 5.98% 门槛且小例慢 1.24%，均不晋级。T21 减少 MOVPRFX 后大例仍比 T20 慢 3.29%，保持 T19 ZIP，下一步独立考察取消 memory clobber。实际 KML25.1/GCC12，非指定 KML25.2 复验，无本机题目运行或哈希操作。[记录](../docs/trsm-stage-r19-20260913.md)。

## TRSM 第二十轮（2026-09-13）

作业 1582239 同分配三版三轮，27/27 正式、9/9 预热及全部宽核预检通过。T19/T20/T22 合计 316.35/309.63/323.00 ms；T20 快 2.12% 低于 12.42% 门槛，T22 慢 2.10%，均不晋级。T22 取消 memory clobber 后整个目标汇编与 T21 相同，不将跨轮耗时差归因于该改动。全部慢样本保留，保持 T19 ZIP，转向小路径历史循环。实际 KML25.1/GCC12，非指定 KML25.2 复验，无本机题目执行或哈希操作。[记录](../docs/trsm-stage-r20-20260913.md)。

## CONV 共享两列展开 C52 初筛

T作业1582134的37128项专项通过，13语义阶段/14算术区域全部按实际汇编审查。W作业1582256同分配12套48/48 PASS，C6/C52/C51参考/C6为452.81/436.78/439.01/452.40ms；C52对两端C6快3.540116%/3.452697%，各自超过1.113262%/1%波动门槛，A退化0.329841%/0.603113%均≤1%，初筛通过。对C51参考仅快0.507961%，未过1%辅助门槛；C51仍禁止晋级，S失败结论保持。当前继续交付C6，等待C52独立确认。全部48样本、策略、阶段与退出、登记/比较原件见[T专项](../docs/CONV_SEP13T.md)与[W测速](../docs/CONV_SEP13W.md)。

2026-09-13 TRSM r21：作业1582392，T19/T23 合计314.46/324.68ms；T23中例慢7.33%、合计慢3.25%，不晋级；18正式+6预热PASS及两版完整小路径预检。保留T19，KML25.1/GCC12。[完整记录](../docs/trsm-stage-r21-20260913.md)。

## CONV X/Y：游标诊断与 C52 独立确认

X作业1582372通过37128项专项，13个u1阶段完整审查；C53 shared仍63指令/列，LSL、七个系数地址ADD和七个外层步进ADD均保留，未取得性能结果。Y作业1582410完整36/36 PASS，C6/C52-r1/C6为452.40/436.68/452.56ms，opening收益3.474801%超过1%门槛，closing收益3.508927%低于18.951456%门槛。结束C6第一例51.48/61.24/51.50ms原样保留，A候选退化均≤1%；确认false，不重跑、混样或晋级。C6继续交付，C52-package/C7未创建，Z工具只保留准备记录。[X完整诊断](../docs/CONV_SEP13X.md) · [Y全部36样本](../docs/CONV_SEP13Y.md)。

2026-09-13 TRSM r22：作业1582526，T19/T24合计316.97/316.06ms；改善0.29%低于10.61%波动，不晋级。18正式+6预热PASS及两版完整小路径预检；保留T19，KML25.1/GCC12。[完整记录](../docs/trsm-stage-r22-20260913.md)。

2026-09-13 TRSM r23：作业1582642，NUMA0 CPU0–37，T19/T25合计313.89/311.56ms；中例快3.65%，大例慢1.41%，不晋级。18正式+6预热PASS及完整预检，KML25.1/GCC12，保留T19。[完整记录](../docs/trsm-stage-r23-20260913.md)。

## CONV AA/AB：四列展开退化

CONV C54四列展开已完成44328项专项和48/48性能样本：总中位706.99ms，比两端C6慢约56%，不晋级。全部慢样本、优化策略与实际汇编栈访问保留，继续只交付C6。[专项诊断](../docs/CONV_SEP13AA.md) · [全部性能样本](../docs/CONV_SEP13AB.md)。

## CONV AC/AD：三列展开未通过初筛

CONV C55三列展开完成44328项专项和48/48性能样本，总中位466.81ms，比结束C6慢3.13%，未通过初筛。全部样本（含275.28ms慢样本）、策略与实际汇编记录保留，继续交付C6。[专项诊断](../docs/CONV_SEP13AC.md) · [全部性能样本](../docs/CONV_SEP13AD.md)。


## CONV AE/AF：列末约束未带来提速

C56完成AE1583102的44328项专项和AF1583230的48/48性能样本，最大误差0、所有退出为0。总中位467.46ms，比结束C6的452.33ms慢3.34%，两端初筛false；C55-r1仍仅作父源码参考。减少全helper栈访问没有带来实测提速，全部慢样本、策略、创建快照和原命令/退出保留；不确认、不晋级，继续交付C6，Y/S原判保持。[专项诊断](../docs/CONV_SEP13AE.md) · [全部性能样本](../docs/CONV_SEP13AF.md)。
