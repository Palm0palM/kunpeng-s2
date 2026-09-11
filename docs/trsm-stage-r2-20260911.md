# TRSM 2026-09-11 r2：16 行 SVE 晋级，双面板未晋级

本轮作业 **1509711** 在同一计算节点、同一资源分配内交错执行 T4-control8、T5-sve16rows、T5-panelpair，各完成三轮完整官方套件，**27/27 官方结果 PASS**。T5-sve16rows 的逐用例中位数合计从 518.01 ms 降至 506.21 ms，减少 **2.28%**，超过本轮 1.49% 波动门槛；大用例减少 **5.52%**，已晋级。T5-panelpair 虽将小用例减少 23.87%，中用例却增加 4.39%，合计增加 1.06%，未晋级。

这份记录仅描述 r2 阶段；后续候选与后续当前最佳应查对应台账。耗时合计是内部比较指标，不是官方分数或排名。验证参考为 **OpenBLAS 0.3.28 静态库，尚未完成官方 KML 复验**。

## 候选与比较条件

T4-control8 是已晋级 T4-sve8rows 的原样复测。T5-sve16rows 将大工作集更新的完整行块由 8×8 扩为 16×8 SVE，16 条独立的递增 k 累加链共用一次 X 加载，保留 8/4 行与标量尾部、独立 ldx/ldc、NEON 回退及每线程 SVE 宽度检查。T5-panelpair 基于同一 T4，将小工作集两组相邻 8 列面板按共同四行块推进，在面板数达到实际线程数四倍时启用配对，大路径保持 T4 不变。两个候选均未更改官方 benchmark、容差、输入尺寸、计时区或 runner。

|项目|实际记录|
|---|---|
|调度器|q_kunpeng；作业 1509711；SUCCEEDED；jobExitCode=0、systemExitCode=0|
|运行时间|2026-09-11 18:28:18–18:30:19（调度器时间）；jobWallclockDuration=120 秒|
|计算节点|COMPUTE_NODE_1，Linux aarch64；NUMA 2；CPU 76–113，共 38 CPU|
|资源|38 CPU，24576 MiB，单 NUMA pack，时限 1800 秒|
|编译器及参数|GCC 10.3.1；`-O3 -ffp-contract=off -fopenmp -mcpu=generic`|
|线程与绑定|OMP_NUM_THREADS=38；OMP_DYNAMIC=FALSE；OMP_PROC_BIND=close；OMP_PLACES=cores|
|重复次数|三个独立完整套件，每套件每个用例 TEST_RUNS=3|
|参考库|`/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a`|
|精度|官方容差 1e-12；本轮最大误差 1.11e-15|

三轮顺序为 T4-control8 → T5-sve16rows → T5-panelpair；T5-sve16rows → T5-panelpair → T4-control8；T5-panelpair → T4-control8 → T5-sve16rows。成员串行执行，没有并发 benchmark。每个成员 wrapper 退出码均为 0，记录器核对三轮共九行官方结果及顺序。完整环境和调度状态见[共同证据](../records/evidence/trsm-stage-r2-20260911/cohort/scheduler-status.txt)。

## 全部官方样本

以下每个样本是 benchmark 内部三次计时的平均值，三项分别来自三个独立完整套件。中位数跨这三个独立样本计算。波动定义为 `(最大值−最小值)/中位数`；GFLOPS 保留官方打印值。所有样本均 PASS。

|版本|M×N|三轮耗时样本 ms|中位数 ms|波动|三轮 GFLOPS|最大误差|
|---|---|---|---:|---:|---|---:|
|T4-control8|512×19968|22.21 / 22.34 / 22.25|22.25|0.5843%|235.6406 / 234.2921 / 235.2428|1.67e-16|
|T4-control8|2432×17024|253.65 / 254.00 / 254.79|254.00|0.4488%|396.9604 / 396.4245 / 395.1958|2.22e-16|
|T4-control8|17024×512|241.11 / 241.76 / 243.07|241.76|0.8107%|615.4328 / 613.7829 / 610.4672|1.11e-15|
|T5-sve16rows|512×19968|21.96 / 21.99 / 22.11|21.99|0.6821%|238.3562 / 237.9995 / 236.7744|1.67e-16|
|T5-sve16rows|2432×17024|252.35 / 255.80 / 256.16|255.80|1.4894%|399.0113 / 393.6372 / 393.0787|2.22e-16|
|T5-sve16rows|17024×512|227.26 / 228.42 / 228.45|228.42|0.5210%|652.9300 / 649.6204 / 649.5201|1.11e-15|
|T5-panelpair|512×19968|17.10 / 16.94 / 16.92|16.94|1.0626%|306.0967 / 308.9924 / 309.4260|1.67e-16|
|T5-panelpair|2432×17024|265.58 / 265.16 / 258.03|265.16|2.8473%|379.1403 / 379.7335 / 390.2251|2.22e-16|
|T5-panelpair|17024×512|241.38 / 241.78 / 241.34|241.38|0.1823%|614.7386 / 613.7199 / 614.8481|1.11e-15|

原始逐行记录与源码快照分别见 [T4-control8](../records/evidence/trsm-stage-r2-20260911/T4-control8/nohash-recorded-evidence/benchmark.log)、[T5-sve16rows](../records/evidence/trsm-stage-r2-20260911/T5-sve16rows/nohash-recorded-evidence/benchmark.log)、[T5-panelpair](../records/evidence/trsm-stage-r2-20260911/T5-panelpair/nohash-recorded-evidence/benchmark.log)。结构化 record.json 同时保留全部耗时与 GFLOPS 样本。

## 门槛与晋级结论

比较要求同环境通过三轮完整官方套件，总改善严格大于 `max(1%, 基线和候选的最大逐用例波动)`，且任何官方用例中位数退化不超过 1%。此为本项目的晋级门槛，不是官方评分公式。

|候选|中位数合计 ms|相对基线合计改善|门槛|逐用例耗时变化（小／中／大）|结论|
|---|---:|---:|---:|---|---|
|T4-control8|518.01|基线|—|—|建立同环境基线|
|T5-sve16rows|506.21|2.2779%|1.4894%|减少 1.1685%／增加 0.7087%／减少 5.5179%|符合门槛，晋级|
|T5-panelpair|523.48|−1.0560%|2.8473%|减少 23.8652%／增加 4.3937%／减少 0.1572%|合计退化，中用例超限，未晋级|

[16 行比较记录](../records/evidence/trsm-stage-r2-20260911/cohort/T4-control8-vs-T5-sve16rows.json)返回 eligible=true；[双面板比较记录](../records/evidence/trsm-stage-r2-20260911/cohort/T4-control8-vs-T5-panelpair.json)保留两个拒绝原因。先以原样源码晋级 T4-control8 为本轮测量基线，再晋级 T5-sve16rows，台账 promoted_at 分别为 2026-09-11T10:33:21.231214+00:00 和 2026-09-11T10:33:21.275239+00:00。双面板成果保留为后续限制分组工作集预算的依据，不能仅凭小用例改善宣称整题提速。

## 超算预检与参考差异

[预检日志](../records/evidence/trsm-stage-r2-20260911/cohort/preflight.log)完整通过。16 行微核在 1/4 线程各执行 30 组 count/stride 组合，与递增 k 的 FMA 参考逐位匹配，并保留输出 padding。两次整算子检测均实际进入 SVE16 微核 50176 次。17 组已知解在正常 1/4 线程、4 线程强制分配失败和4 线程屏蔽 SVE 路径下通过；双面板 23 组已知解在正常 1/4/38 线程及强制分配失败 1/4 线程下通过。合计 183 次已知解、36 次无操作边界，以及 60 次直接微核组合检查，已知解最大误差为 0；L 与 B padding 均保留。预检源码、参考探测脚本和目标生成汇编均归档；本轮没有运行 sanitizer，也没有本机编译或测试。

[参考环境探测](../records/evidence/trsm-stage-r2-20260911/cohort/reference-environment.log)记录官方模块目录 `/home/HPC/HPCKit/latest/modulefiles` 缺失，官方头文件和链接探测退出 1，单独链接 `-lkblas` 也退出 1。实际静态库查询为 OpenBLAS 0.3.28，USE_OPENMP、ARMV8、MAX_THREADS=38，实际线程查询 38；编译与运行探针退出 0。因此本轮是 OpenBLAS 参考环境下的官方用例验证，不能视为官方 KML 25.2.0 复验。

## 登记修正与证据范围

首次本地登记被记录器拒绝，报错 `A recorded result cannot be overwritten; create a new run/version`。原因是尚未登记的行政元数据被标为 submitted，该状态不属于无哈希记录器接受的初始状态；当时不存在 recorded_at、cases 或证据快照。[registration-status-fix](../records/evidence/trsm-stage-r2-20260911/cohort/registration-status-fix/README.md)保存了三份原元数据及首次错误。随后仅将这三份未测登记元数据恢复为 prepared，实际 job ID 仍保留于 cluster.json，再成功登记。没有重跑 benchmark，没有覆盖测试结果、修改成绩、源码或公共工具。成功的[登记与比较命令记录](../records/evidence/trsm-stage-r2-20260911/cohort/record-compare-commands.json)一并保存。

按用户要求，全流程未计算或验证哈希。每个成员的 nohash-recorded-evidence、最终 record.json、wrapper 原始输出，以及共同配置、提交命令、调度状态、driver、提交/收集/无哈希登记脚本、预检源码与日志、参考探测和汇编，均复制到[本轮公开证据归档](../records/evidence/trsm-stage-r2-20260911/README.md)。此处公开归档已替换个人路径、账号、内网地址与节点名，未脱敏原件保留在本地，不将公开副本用作原件完整性验证或重新晋级；cluster.local.json、known_hosts、凭据及认证材料、payload 压缩包和二进制均未复制。源码证据限于本地字节快照，不声称已验证远端源码身份或传输完整性。未正式提交比赛。
