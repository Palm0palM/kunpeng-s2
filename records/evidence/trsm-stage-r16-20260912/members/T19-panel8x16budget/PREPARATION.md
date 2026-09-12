# T19-panel8x16budget：超预算小路径双 RHS8 前代

2026-09-12，仅静态准备。五份源码文件原样复制 T18-budgetwide 后只修改 trsm.c；其余 bench_trsm.c、run.sh、compat/kblas.h、README.md 与 T18 字节相同。计划晋级父版本仍是 T8-control12；T18 只是同轮机理对照，来源关系不代表已晋级。本候选没有性能或正确性测试结论。

单一假设：原小路径已经安全计算出 packed_history 副本超过 4MiB 时，改用八行、两组 RHS8 的 SVE 前代核，尝试让一个 L 系数服务两个 X 向量，并把列任务从八列扩为十六列。预算是实现策略，不是硬件缓存容量，也不按公开用例尺寸分派。行块从十六行缩为八行会增加部分 X 历史读取，每 worker scratch 也翻倍；不能声称总输入字节或架构带宽需求减半。

## 改动与接口

- `solve8x16_panel_sve(start, lda, L, x0, x1)`，trsm.c:564，沿用 SVE target 与 noinline 属性。L 指当前八行首行、原列零；x0/x1 均以全局行零为原点，行步长固定 RHS=8。
- `solve_panel_wide8x16(m, n, L, lda, B, ldb)`，trsm.c:809。每 worker 一次 64 字节对齐分配 `m*2*RHS*sizeof(double)`，布局 `[2][m][8]`；x0=scratch，x1=scratch+m*RHS。分配表达式先经过 size_t 字节上限检查。
- 新核调用在 trsm.c:849。只有完整十六列任务且该 worker 的 HWCAP/VL8 检查通过时，每八行调用一次。`svcntd()==8` 检查继续使用已有 helper；窄 VL worker 不进入任何 SVE panel 核。
- solve_panel 在原两道溢出检查内的预算 `else` 才把 `history_over_budget` 置一（trsm.c:918），原 parallel 前调用独立 wrapper 并 return（trsm.c:923）。未用 packed_history==NULL 判定新分派。预算内、无 SVE、无法安全计算字节、预算内 shared 分配失败都继续原完整 T18 路径。

新核具有十六个具名零累加器。历史 k 从零递增到 start-1，每个 L 系数分别用于两个面板的显式 FMA。随后 q=0..7 顺序前代，每行先用原 RHS 减去累加和并除以原对角元，再对所有后续行各做一次 FMA；没有从 RHS 开始负 FMA、倒数近似或重排单输出的累加顺序。

## 任务、尾部与回退

任务数为 `n/16+(n%16!=0)`，task→jb=16*task，不使用可能向上溢出的 n+15。OpenMP static 分配的各任务列区间不重叠。

完整十六列完成所有八行块后，余下不足八行逐 RHS8 面板复用原四行 NEON/标量尾。最后不足十六列的任务，无论是一块还是两块短面板，都逐 RHS8 复用原十六行 SVE 核及原 NEON/标量尾；因此 n<16 时新微核入口为零。有效列以外的 scratch lane 补零，只把有效列写回任意合法 ldb 的 B。

worker scratch 分配失败时，仅对其已分配十六列任务的全部有效列执行原 direct 标量前代。其他 worker 的任务不被接管或重写。每 worker 私有 scratch 在其任务完成后释放；L 只读，无共享 scratch 或新增 barrier。

4MiB 边界仍由 b=floor(m/16) 的 `1024*b*(b-1)` 字节计算：b=64 为 4,128,768 字节，b=65 为 4,259,840 字节。原小路径中 m=1039/1040 分别对应预算内/超预算。在 m=2432 时单 worker scratch 从 155,648 增为 311,296 字节（152→304 KiB）；n=17024 的 1064 个任务在 38 worker 时每个 28 个。这些仅为整数推导，不是性能结果。

## 静态范围

删除新增两个函数及三处分派编辑后，trsm.c 精确恢复 T18 原文本。原小路径各已有核、producer/consumer、分配失败处理未修改；`enum { KB = 256, CT = 64 };`（新行号1019）开始的整个大路径后缀与 T18 完全一致。全局 RHS=8、ROWS=4 和公开 l_trsm 分派不变。所有新增 SVE 内容都在原 TRSM_CAN_DISPATCH_SVE 条件区域中。

已完成轻量文本/字节比较、预处理与括号平衡、表达式数量和上述整数推导；尚未在目标节点编译、运行或检查生成汇编。没有本机题目执行、SSH、prepare/submit、登记、晋级、哈希计算或比赛提交。
