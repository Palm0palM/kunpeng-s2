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
| trsm | T0 | — | prepared | — | 当前TRSM已验证源码的同环境三轮基线复测，优先验证官方KML |
| trsm | T1-panel | T0 | prepared | — | 大工作集分块前代每个已解256x8右端项块共享打包为连续面板，使所有下方4x8更新复用连续读取，降低跨行大步长访存；其余算法与分块不变 |
| zgemm | Z0 | — | prepared | — | 当前ZGEMM已验证源码的同环境三轮基线复测 |
| zgemm | Z1-pack | Z0 | prepared | — | 仅重排A为3行K优先的连续微面板并用NEON向量lane读取9个分量，减少内核A的独立加载流和load指令；保留3x4形状、MB24及3M运算顺序 |
