# TRSM 2026-09-11 r3：工作集预算受限的面板分组未晋级

作业 **1512595** 将 T5-control9、T6-pair2budget、T6-pair4budget 放在同一资源分配内交错测量，各完成三轮完整官方套件，**27/27 官方结果 PASS**。两个候选都改善了小用例，但合计改善均未超过各自波动门槛，**均不晋级，本阶段最佳保留 T5-sve16rows**。两个候选及全部样本均保留。

2 组候选中位数合计 507.49→506.43 ms，改善 0.2089%，低于 3.8572% 门槛，中用例还退化 2.1442%；4 组候选合计 507.49→502.70 ms，改善 0.9439%，低于 5.7646% 门槛。本轮没有建立稳定的整题提速结论。耗时合计只是内部指标，不是官方得分或排名；实际使用 OpenBLAS 静态参考库，**不是官方 KML 复验**。

## 策略和实际条件

T5-control9 是已晋级 T5-sve16rows 的原样同环境复测。两个候选都保留原 `solve_panel`，另增加按共同四行块推进的 `solve_panel_grouped`，每组最多 2 或 4 个相邻 8 列 RHS 面板。只在小工作集算法分支满足 `m*(分组数*8+4)*sizeof(double) <= 256*1024` 时进入分组实现；对应 2 组的 m≤1638、4 组的 m≤910。**256 KiB 是此次候选的调优预算，不是机器缓存容量声明。**

分组实现还要求 `ceil(n/8) >= 2*分组数*实际OpenMP线程数`，使分组后的任务至少为实际线程数两倍；不足时该实现按单面板任务运行。预算超限时直接调用保留的原始 `solve_panel`。两个候选保留原有递增 k/q 累加次序、尾部和分配失败回退，64 MiB 小/大工作集分流及 SVE16 大路径未改，官方 benchmark、runner、输入、容差和计时区未改。

本轮官方中用例 m=2432 超过两种预算，会调用原 `solve_panel`；仍应如实保留其测得的时间变化。现有日志不提供这些变化的瓶颈解释，本记录不作缓存或带宽原因归因。

|项目|实际记录|
|---|---|
|调度器|q_kunpeng；作业 1512595；SUCCEEDED；jobExitCode=0、systemExitCode=0|
|运行时间|2026-09-11 18:35:58–18:38:08（调度器时间）；jobWallclockDuration=127 秒|
|计算节点|COMPUTE_NODE_1，Linux aarch64；NUMA 3；CPU 114–151，共 38 CPU|
|资源|38 CPU，24576 MiB，单 NUMA pack，时限 1800 秒|
|编译器及参数|GCC 10.3.1；`-O3 -ffp-contract=off -fopenmp -mcpu=generic`|
|线程与绑定|OMP_NUM_THREADS=38；OMP_DYNAMIC=FALSE；OMP_PROC_BIND=close；OMP_PLACES=cores|
|重复次数|三个独立完整套件，每套件每个用例 TEST_RUNS=3|
|参考库|`/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a`|
|精度|官方容差 1e-12；本轮最大误差 1.11e-15|

三轮顺序为 T5-control9 → T6-pair2budget → T6-pair4budget；T6-pair2budget → T6-pair4budget → T5-control9；T6-pair4budget → T5-control9 → T6-pair2budget。成员 benchmark 串行运行，三个 wrapper 退出码均为 0，各自九行官方结果及顺序通过登记检查。相对收益只使用本轮同分配 T5-control9 数据，未以 r2 不同 NUMA 的数值混算。详见[共同配置](../records/evidence/trsm-stage-r3-20260911/cohort/cohort-config.json)与[调度状态](../records/evidence/trsm-stage-r3-20260911/cohort/scheduler-status.txt)。

## 全部官方样本

每个耗时样本是 benchmark 内部三次计时的平均值；三项来自三个独立完整套件。中位数跨这三个样本计算，波动为 `(最大值−最小值)/中位数`，GFLOPS 为官方打印值。所有列出的样本均 PASS。

|版本|M×N|三轮耗时样本 ms|中位数 ms|波动|三轮 GFLOPS|最大误差|
|---|---|---|---:|---:|---|---:|
|T5-control9|512×19968|23.00 / 22.93 / 22.73|22.93|1.1775%|227.6117 / 228.2401 / 230.3133|1.67e-16|
|T5-control9|2432×17024|254.64 / 254.29 / 259.11|254.64|1.8929%|395.4300 / 395.9634 / 388.5994|2.22e-16|
|T5-control9|17024×512|235.76 / 229.92 / 229.64|229.92|2.6618%|629.3822 / 645.3739 / 646.1653|1.11e-15|
|T6-pair2budget|512×19968|17.34 / 18.01 / 17.37|17.37|3.8572%|301.8224 / 290.6713 / 301.2761|1.67e-16|
|T6-pair2budget|2432×17024|255.16 / 260.10 / 263.45|260.10|3.1872%|394.6185 / 387.1174 / 382.1973|2.22e-16|
|T6-pair2budget|17024×512|228.96 / 228.87 / 229.06|228.96|0.0830%|648.0804 / 648.3402 / 647.7975|1.11e-15|
|T6-pair4budget|512×19968|16.48 / 17.39 / 16.44|16.48|5.7646%|317.6367 / 301.0064 / 318.3112|1.67e-16|
|T6-pair4budget|2432×17024|256.40 / 257.35 / 256.38|256.40|0.3783%|392.7067 / 391.2556 / 392.7373|2.22e-16|
|T6-pair4budget|17024×512|230.36 / 229.24 / 229.82|229.82|0.4873%|644.1612 / 647.3041 / 645.6536|1.11e-15|

原始日志与源码快照见 [T5-control9](../records/evidence/trsm-stage-r3-20260911/T5-control9/nohash-recorded-evidence/benchmark.log)、[T6-pair2budget](../records/evidence/trsm-stage-r3-20260911/T6-pair2budget/nohash-recorded-evidence/benchmark.log)、[T6-pair4budget](../records/evidence/trsm-stage-r3-20260911/T6-pair4budget/nohash-recorded-evidence/benchmark.log)。每个目录的 record.json 另保留全部结构化样本。

## 比较门槛与结论

本项目要求同环境正确性通过，总改善严格超过 `max(1%, 基线和候选的最大逐用例波动)`，同时所有官方用例中位数退化不超过 1%。这是晋级门槛，不是官方评分规则。

|版本|中位数合计 ms|合计改善|比较门槛|逐用例耗时变化（小／中／大）|结论|
|---|---:|---:|---:|---|---|
|T5-control9|507.49|基线|—|—|原样测量对照|
|T6-pair2budget|506.43|0.2089%|3.8572%|减少 24.2477%／增加 2.1442%／减少 0.4175%|未超门槛，中用例超限，未晋级|
|T6-pair4budget|502.70|0.9439%|5.7646%|减少 28.1291%／增加 0.6912%／减少 0.0435%|未超门槛，未晋级|

[2 组比较](../records/evidence/trsm-stage-r3-20260911/cohort/T5-control9-vs-T6-pair2budget.json)与[4 组比较](../records/evidence/trsm-stage-r3-20260911/cohort/T5-control9-vs-T6-pair4budget.json)均返回 eligible=false。两者的状态 passed 表示本轮正确性和完整运行检查通过，不能解释为获准晋级。r3 未进行晋级，继续使用前一阶段已晋级的 T5-sve16rows。

## 预检及参考库

两个候选分别在正常 1/4/38 线程和强制分配失败 4 线程下运行相同 38 组已知解及 4 组无操作边界，共 **304 次已知解、32 次无操作检查**。全部通过，已知解最大误差为 0；L 不变及 B padding 均保留。覆盖了 2/4 面板在 1/4/38 线程的启用阈值、部分列和尾组、预算边界 m=910/911 与 1638/1639、以及小/大路径边界附近 m=4095/4097。[预检日志](../records/evidence/trsm-stage-r3-20260911/cohort/preflight.log)以 TRSM_PREFLIGHT_COMPLETE=1 结束。源码、分配失败替身和目标生成汇编均归档。本轮未运行 sanitizer、未重复 r2 的独立 SVE 微核检查，没有把历史预检次数计入本轮；编译与全部测试均在超算计算节点执行。

[参考探测](../records/evidence/trsm-stage-r3-20260911/cohort/reference-environment.log)显示官方模块目录 `/home/HPC/HPCKit/latest/modulefiles` 缺失，官方头文件加链接与单独 `-lkblas` 链接探测均退出 1。实际库为 OpenBLAS 0.3.28 静态库，USE_OPENMP、ARMV8、MAX_THREADS=38，探针查询线程数 38，编译和运行探针均退出 0。本轮属于 OpenBLAS 参考环境下的官方用例验证，不是官方 KML 25.2.0 复验。

## 留痕范围

[本轮归档](../records/evidence/trsm-stage-r3-20260911/README.md)保留三个成员的 nohash-recorded-evidence、record.json、wrapper 原始输出，两个候选的准备策略说明，以及共同配置、提交命令、调度状态、driver、提交/收集/无哈希登记脚本、预检源码与日志、参考探测、汇编和[全部登记比较命令](../records/evidence/trsm-stage-r3-20260911/cohort/record-compare-commands.json)。失败晋级结论及原始波动完整保留，未以最好单次取代三轮结果。

此处公开归档已替换个人路径、账号、内网地址与节点名，未脱敏原件保留在本地，不将公开副本用作原件完整性验证或重新晋级。未复制 cluster.local.json、known_hosts、凭据或认证材料、payload 压缩包与二进制。依用户要求，未计算或验证任何哈希；源码证据仅限本地字节快照，不声称远端源码身份或传输完整性已验证。本阶段整理未在本机编译测试，未提交正式比赛。
