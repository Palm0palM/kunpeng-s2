# 实验记录

耗时合计仅用于本地筛选，不是官方得分；排行榜数据尚未录入。

| 题目 | 版本 | 父版本 | 状态 | 合计 ms | 策略 |
|---|---|---|---|---:|---|
| conv | C0 | — | 历史证据 | 1881.67 | 输出方向 32 路分块；固定 16/8/4/2/1 尾块；kernel 两步展开；保持每个输出的累加顺序。 |
| zgemm | Z0 | — | 历史证据 | 4566.78 | 3×4 NEON 微内核；打包实部、虚部及两者之和；三个实数点积恢复复数结果；24 行缓存块。 |
| trsm | T0 | — | 历史证据 | 777.85 | 三角矩阵工作集不超过 64 MiB 时使用 4×8 打包前代；否则使用 256 行对角块、64×64 更新块和 4×8 NEON 更新微内核。64 MiB 是算法选择预算，并非机器缓存容量声明。 |
| conv | C0-r1 | — | passed | 1869.70 | Retry unchanged C0 baseline after fixing empty CPU-list handling in shared remote wrapper |
| conv | C0 | — | failed | — | 原包CONV当前源码在同一机器上的三轮基线复测 |
| conv | C1-block | C0 | prepared | — | 32列NEON块内复用相邻kernel列的重叠输入向量：每两个kernel元素16次向量加载减为9次，新增7次vext；保持float乘加分离和累加顺序，待鲲鹏测量确认。 |
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
| zgemm | Z0 | — | prepared | — | 当前ZGEMM已验证源码的同环境三轮基线复测 |
| zgemm | Z1-pack | Z0 | prepared | — | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |

TRSM 当前最佳为 T1-panel-r2；同分配三轮确认合计改善 2.40%，详见 [TRSM 晋级记录](../docs/trsm-continuation-20260908.md)。
