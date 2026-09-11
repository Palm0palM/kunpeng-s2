# TRSM 提交包 — T5-sve16rows

本包采用已晋级的 TRSM 实现。解压后进入 `trsm/`，仅在调度分配的鲲鹏计算节点运行，使用不超过 38 核的单 NUMA 分配。

## 官方环境运行

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

需要 Linux、GCC/OpenMP、numactl 和官方 KML/kblas；run.sh 自动选取当前分配的 NUMA，使用 close/cores 绑定。默认链接 -lkblas。上面的 TEST_RUNS=3 与实测一致；runner 自身默认仍为 1。独立三轮复现时，在同一分配中执行 bash run.sh 三次。

## 实现

小工作集使用原 4×8 NEON 窄面板前代。

大工作集采用 KB=256、CT=64，打包已解右端项，完整行块采用 16×8 SVE 更新，保留 8/4/标量尾块。只有 Linux GCC 支持、硬件提供 SVE 且当前线程向量宽度为 8 个 double 时才调用 SVE；否则使用 NEON。保留独立 lda/ldb、尾列、L 只读及分配失败回退。算子本身不调用 BLAS。未按公开测试尺寸做等值分支。

## 验证范围

源码测量作业 1509711：三轮完整官方套件，每组 TEST_RUNS=3、38线程，9/9 PASS，最大误差不超过 1.11e-15。三组耗时中位数为 21.99、255.80、228.42 ms。各组中位数合计仅为内部指标，不是官方分数。

实际参考为 **OpenBLAS 0.3.28 静态库**，不是官方 KML 25.2.0 复验。兼容头仅供显式 KBLAS_LIB 覆盖使用，包内不携带任何参考库二进制。官方 benchmark、精度容差 1e-12、测试尺寸和计时区保持不变。

最终 ZIP 的计算节点解压复跑状态、逐用例日志见 GitHub 仓库 `outputs/trsm-best.json` 与 `docs/trsm-final-20260911-r2.md`。完整优化记录也在该文档链接的实验报告中。未执行比赛平台提交。按用户要求没有额外计算或验证哈希。
