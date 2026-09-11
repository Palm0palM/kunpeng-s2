# TRSM 最新交付：T5-sve16rows

[下载最终 ZIP](../outputs/trsm-best.zip)。当前最佳为 **T5-sve16rows**，大工作集 SVE 更新由 8 行扩为 16 行，保留 8/4/标量尾块、NEON 和分配失败回退。

同分配三轮对照中，合计中位数 **518.01→506.21 ms，耗时减少 2.28%**；大用例 **241.76→228.42 ms，减少 5.52%**。改善超过 1.49% 观测波动门槛，无用例中位数退步超过 1%，据此晋级。合计仅为内部指标，不是官方分数。

## 本轮尝试

|作业|对照与候选|结果|
|---|---|---|
|1509711|T4-control8 / T5-sve16rows / T5-panelpair|27/27 PASS；16 行 SVE 晋级；无预算双面板中用例退化 4.39%，不晋级|
|1512595|T5-control9 / T6-pair2budget / T6-pair4budget|27/27 PASS；两种受限分组合计改善仅 0.21% / 0.94%，未超过波动门槛，均不晋级|
|1513942|最终 T5-sve16rows ZIP 解压复跑|三轮完整官方套件，9/9 PASS，调度器及程序均正常退出|

完整样本、环境、策略和失败原因见[第一轮记录](trsm-stage-r2-20260911.md)与[第二轮记录](trsm-stage-r3-20260911.md)。256 KiB 只是第二轮的调优工作集预算，未将其宣称为机器缓存容量。性能结果不支持将面板候选纳入最终包。

## 最终 ZIP 验证

该 ZIP 在调度分配的计算节点解压，直接用包内 run.sh 编译并运行三轮；源码、benchmark、runner 和兼容头沿用已晋级版本，README 更新。验证完成后 ZIP 内容未再改变。

|M×N|三轮耗时 ms|中位数 ms|最大误差|
|---|---|---:|---:|
|512×19968|23.14 / 22.20 / 22.68|22.68|1.67e-16|
|2432×17024|256.11 / 257.75 / 259.41|257.75|2.22e-16|
|17024×512|228.32 / 229.06 / 228.50|228.50|1.11e-15|

每个样本是 TEST_RUNS=3 的平均值，再对三轮独立套件取中位数，合计 508.93 ms。这次单版本复跑用于验证交付包，不替代同分配 A/B 对照成绩。

环境为鲲鹏计算节点、NUMA 3、CPU 114–151，38 线程，GCC 10.3.1，`-O3 -ffp-contract=off -fopenmp -mcpu=generic`，OMP_DYNAMIC=FALSE、close/cores 绑定。作业 SUCCEEDED，jobExitCode、systemExitCode 与 wrapper 退出码均为 0。

参考为 **OpenBLAS 0.3.28 静态库，实际 38 线程**。官方模块目录、kblas.h、-lkblas 探测仍未成功，因此**尚未完成官方 KML 25.2.0 复验**。算子本身不调用 BLAS，包中不包含参考库二进制或账号配置。

## 使用与证据

解压后进入 trsm/，只在调度分配的 38 核单 NUMA 鲲鹏计算节点运行。官方 KML 环境按以下命令执行：

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

[包清单与状态](../outputs/trsm-best.json)，最终包原始日志和运行脚本见 `records/evidence/trsm-finalpackage-20260911-r2/`。公开日志为脱敏副本，未脱敏原件本地保留，不将公开副本冒充原件重新自动验证。本机仅做编辑、传输和日志整理，未编译或运行题目；未额外计算或验证哈希。此次仅发布 GitHub，未执行比赛平台提交。
