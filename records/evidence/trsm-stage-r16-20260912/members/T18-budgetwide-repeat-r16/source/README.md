# TRSM 优化提交包 — T4-sve8rows

本包为当前已晋级的 TRSM 实现，解压后进入 `trsm/`。只在调度分配的鲲鹏计算节点执行，分配不超过 38 核且位于单个 NUMA 节点。

## 运行

官方 KML 环境中清除参考库覆盖，并显式使用此前测量的重复数与线程设置：

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

脚本自动识别分配的 NUMA，使用 close/cores 绑定，默认链接官方 `-lkblas`。需要 Linux、GCC/OpenMP、numactl 和 KML；官方模块路径可用时加载对应模块。三组官方尺寸均由未修改的 benchmark 执行，容差仍为 `1e-12`，日志保存于 `results/`。

`run.sh` 的 TEST_RUNS 默认值仍是 1；上面的命令显式设为 3，与既有测量一致。三轮独立复测应在相同分配中连续执行上面的 `bash run.sh` 三次。

## 实现

小工作集使用 4×8 NEON 窄面板前代。大工作集采用 256 行对角块、64×64 输出块，打包已解右端项，使用 8×8 SVE 更新，4 行尾块使用 4×8 SVE。Linux GCC 支持该路径、CPU 提供 SVE 且当前线程向量长度为 8 个 double 时才启用 SVE，否则使用 NEON。保留尾部处理和分配失败回退。算子本身不调用 BLAS。

## 验证范围

2026-09-11 作业 1507689：该源码与 runner 在同一计算节点、38 线程、单 NUMA、GCC 10.3.1 下完成三轮完整官方用例，每组 TEST_RUNS=3，9/9 PASS，最大误差 1.11e-15。三组耗时中位数为 22.64、259.17、244.38 ms；合计 526.19 ms，比同轮 T3 对照减少 3.51%，大用例减少 6.97%。合计不是官方分数。预检覆盖 8 行 SVE 微核、已知解、尾部、padding、L 不变性、分配失败及强制 NEON 回退。

该测量使用 OpenBLAS 0.3.28 静态参考库，**不是官方 KML 25.2.0 复验**。兼容头仅供显式 KBLAS_LIB 覆盖使用，包内不附带任何 BLAS 二进制。

本包包含已晋级的 T4-sve8rows、未改动的官方 benchmark、runner 和可选兼容头。最终 ZIP 的计算节点解压复跑状态和日志见仓库 `outputs/trsm-best.json` 及 `docs/trsm-package-20260911.md`。未执行比赛平台提交。

完整对照证据见 GitHub 仓库 `docs/trsm-sve8rows-20260911.md` 与 `records/evidence/trsm-sve8rows-20260911/`。按用户要求未另行计算或验证哈希。
