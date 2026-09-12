# TRSM 提交包 — T8-svepanel16

解压后进入 `trsm/`，仅在调度分配的鲲鹏计算节点运行，使用不超过 38 核的单 NUMA 分配。

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

需要 Linux、GCC/OpenMP、numactl 和 KML/kblas。run.sh 根据分配选取 NUMA，使用 close/cores 绑定，默认链接 -lkblas。TEST_RUNS=3 是每用例内部计时三次；独立三轮需在同分配运行三次 run.sh。官方模块目录可用时会自动加载指定 GCC12.3.1/KML25.2.0。

小工作集将历史点积与 16 行块内前代合入 16×8 SVE 微核，复用 X 向量和累加器。每个历史 k 与块内 q 都按递增次序累计；块内显式 FMA 与旧 NEON 路径的舍入可能不同，仍按原 1e-12 校验。原 NEON4 和标量尾部保留。

大工作集保留 T7 的 KB=256、CT=64、共享对角面板前代及 16×8 SVE 更新，含 8/4/标量尾块。SVE 仅在支持的 Linux GCC、硬件 HWCAP 和每个工作线程 svcntd()==8 时使用，否则走 NEON。保留 lda/ldb、尾列、L 只读、分配失败和非正维度回退；不按官方精确尺寸分派。算子本身不调用 BLAS。

源码验证作业 1576028 使用 KML25.1.0 真实头文件及动态库、GCC12.3.1、私有 libgomp、38线程单 NUMA。三轮完整官方用例 9/9 PASS，最大误差 1.11e-15；三组中位数18.74、236.16、192.69 ms，合计447.59 ms，同作业内较 T7 降低11.99%。这些是内部耗时指标，不是官方分数。另有14组直接微核、406组整算子和28组空操作预检通过，含窄 VL、屏蔽 SVE、分配失败及非二进制精确输入。

KML25.1.0 验证不等同指定的 KML25.2.0 复验，也不能与历史 OpenBLAS/GCC10 环境混算策略收益。原 benchmark、尺寸、1e-12 容差、计时区和 runner 保持不变。兼容头仅供显式 KBLAS_LIB 覆盖；包内不带参考库二进制。

最终 ZIP 的计算节点解压复跑记录见 GitHub 仓库 outputs/trsm-best.json 与 docs/trsm-final-20260912-r5.md，优化证据见 docs/trsm-stage-r5-20260912.md。未正式提交比赛；未运行本机题目测试，未额外计算或验证哈希。
