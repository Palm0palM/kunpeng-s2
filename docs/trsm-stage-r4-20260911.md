公开副本说明：此文件及对应证据已替换个人路径、账号、内网地址与节点名，未脱敏原件保留本地；下文关于原始复制的描述指本地归档阶段，公开副本不能作为原件完整性证据或用于重新晋级。

# TRSM 2026-09-11 r4：紧凑对角块面板减少大用例耗时

作业 **1522032** 在同一资源分配内交错测试 T5-control10、T7-sve24rows 和 T7-diagpanel，各完成三轮完整官方套件，**27/27 官方结果 PASS**。T7-diagpanel 的逐用例中位数合计从 **508.24 降至 467.29 ms，减少 8.0572%**，超过 3.6689% 波动门槛；大用例从 **227.13 降至 191.06 ms，减少 15.8808%**。三组用例中位数都改善，该候选已晋级。

T7-sve24rows 的合计只改善 0.2735%，低于 15.6237% 门槛，小用例退化 5.1007%，因此不晋级。两种候选及全部测量均保留。耗时合计是内部比较指标，不是官方分数或排名。本轮参考库仍为 OpenBLAS 0.3.28 静态库；新增搜索找到了 KML 25.1 安装文件，但本轮没有使用该库，不能将结果记作 KML 复验。

## 策略与测量条件

T5-control10 是已晋级 T5-sve16rows 的原样同环境复测，无 parent；两个候选均以它为共同测量父版本，源码都从 T5-sve16rows 派生，未混合两种优化。

**T7-diagpanel** 只改变大工作集 `solve_blocked` 的对角块求解及打包。每个列面板独占共享 packed 区，复制当前对角块的 B 后，复用既有 4×8 NEON `panel_sums` 前代，写回 B 并直接留下已解 X。原先对角求解和随后独立打包的两次 `omp for` 合并为一次，以其隐式 barrier 发布结果。此处 FMA 会改变对角块的舍入，使用官方容差和非二进制精确输入预检确认了精度。分配失败时保留原逐行对角求解和跨行更新回退。

**T7-sve24rows** 只给大工作集更新新增 24×8 SVE 核，用 24 条独立、递增 k 的 FMA 链复用 X；完整 CT=64 行块按 24+24+16 更新，保留原有 16/8/4/标量尾块。每行仍在求和结束后只作一次 C−sum，独立 ldx/ldc、SVE 硬件与每线程 8 个 double 宽度检查、非 SVE 和分配失败回退保留。更大复用没有转化为本轮稳定提升，日志不足以单独归因于寄存器、缓存或调度开销。

两者均保持 KB=256、CT=64、64 MiB 算法选择预算；64 MiB 是调优预算，不是硬件缓存容量声明。小工作集路径及官方 benchmark、runner、输入、容差、计时区均未改。T7-diagpanel 保留 T5 的 SVE16 更新核。

|项目|实际记录|
|---|---|
|调度器|q_kunpeng；作业 1522032；SUCCEEDED；jobExitCode=0、systemExitCode=0|
|运行时间|2026-09-11 19:01:39–19:05:41（调度器时间）；jobWallclockDuration=240 秒|
|计算节点|COMPUTE_NODE_1，Linux aarch64；NUMA 2；CPU 76–113，共 38 CPU|
|资源|38 CPU，24576 MiB，单 NUMA pack，时限 1800 秒|
|编译器及参数|GCC 10.3.1；`-O3 -ffp-contract=off -fopenmp -mcpu=generic`|
|线程与绑定|OMP_NUM_THREADS=38；OMP_DYNAMIC=FALSE；OMP_PROC_BIND=close；OMP_PLACES=cores|
|重复次数|三个独立完整套件，每套件每个用例 TEST_RUNS=3|
|参考库|`/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a`|
|精度|官方容差 1e-12；本轮官方结果最大误差 1.11e-15|

三轮顺序为 T5-control10 → T7-sve24rows → T7-diagpanel；T7-sve24rows → T7-diagpanel → T5-control10；T7-diagpanel → T5-control10 → T7-sve24rows。成员 benchmark 串行运行，三个 wrapper 退出码均为 0，各九行官方结果及顺序均通过登记检查。相对收益只使用本轮同分配对照，不与其他 NUMA 或历史阶段混算。详见[共同配置](../records/evidence/trsm-stage-r4-20260911/cohort/cohort-config.json)与[调度状态](../records/evidence/trsm-stage-r4-20260911/cohort/scheduler-status.txt)。每个成员的 environment.log 与 benchmark.log 保留环境和逐套件输出。

## 全部官方样本

每个耗时样本是 benchmark 内部三次计时的平均值；三项来自三个独立完整套件。中位数跨三个样本计算，波动为 `(最大值−最小值)/中位数`，GFLOPS 为官方打印值。所有样本均 PASS。

|版本|M×N|三轮耗时样本 ms|中位数 ms|波动|三轮 GFLOPS|最大误差|
|---|---|---|---:|---:|---|---:|
|T5-control10|512×19968|22.46 / 22.35 / 21.64|22.35|3.6689%|233.0746 / 234.2106 / 241.9250|1.67e-16|
|T5-control10|2432×17024|258.76 / 259.64 / 254.05|258.76|2.1603%|389.1213 / 387.8057 / 396.3426|2.22e-16|
|T5-control10|17024×512|227.55 / 227.13 / 226.99|227.13|0.2466%|652.1007 / 653.3107 / 653.7224|1.11e-15|
|T7-sve24rows|512×19968|22.22 / 23.49 / 25.89|23.49|15.6237%|235.5239 / 222.8742 / 202.1748|1.67e-16|
|T7-sve24rows|2432×17024|254.48 / 255.49 / 254.83|254.83|0.3963%|395.6782 / 394.1007 / 395.1341|2.22e-16|
|T7-sve24rows|17024×512|227.96 / 228.53 / 229.18|228.53|0.5338%|650.9281 / 649.3064 / 647.4604|1.11e-15|
|T7-diagpanel|512×19968|21.99 / 22.69 / 22.12|22.12|3.1646%|238.0283 / 230.6725 / 236.6044|1.67e-16|
|T7-diagpanel|2432×17024|254.34 / 253.49 / 254.11|254.11|0.3345%|395.8832 / 397.2214 / 396.2491|2.22e-16|
|T7-diagpanel|17024×512|192.39 / 191.06 / 190.69|191.06|0.8898%|771.2652 / 776.6596 / 778.1453|1.11e-15|

原始日志和源码快照见 [T5-control10](../records/evidence/trsm-stage-r4-20260911/T5-control10/nohash-recorded-evidence/benchmark.log)、[T7-sve24rows](../records/evidence/trsm-stage-r4-20260911/T7-sve24rows/nohash-recorded-evidence/benchmark.log)、[T7-diagpanel](../records/evidence/trsm-stage-r4-20260911/T7-diagpanel/nohash-recorded-evidence/benchmark.log)。每个成员目录的 record.json 另保留全部结构化样本和登记检查。

## 比较与晋级

晋级门槛要求同环境正确性通过，总改善严格超过 `max(1%, 基线和候选的最大逐用例波动)`，且任何官方用例中位数退化不超过 1%。这是项目内部晋级条件，不是官方评分规则。

|版本|中位数合计 ms|合计改善|比较门槛|逐用例耗时变化（小／中／大）|结论|
|---|---:|---:|---:|---|---|
|T5-control10|508.24|基线|—|—|原样测量对照|
|T7-sve24rows|506.85|0.2735%|15.6237%|增加 5.1007%／减少 1.5188%／增加 0.6164%|未超门槛，小用例超限，未晋级|
|T7-diagpanel|467.29|8.0572%|3.6689%|减少 1.0291%／减少 1.7970%／减少 15.8808%|通过门槛，已晋级|

[24 行比较](../records/evidence/trsm-stage-r4-20260911/cohort/T5-control10-vs-T7-sve24rows.json)返回 eligible=false，[对角面板比较](../records/evidence/trsm-stage-r4-20260911/cohort/T5-control10-vs-T7-diagpanel.json)返回 eligible=true。T5-control10 和 T7-diagpanel 的 record.json 已记录晋级时间；T7-sve24rows 的 passed 仅表示正确性和完整运行检查通过。

## 预检与 KML 探测

[预检日志](../records/evidence/trsm-stage-r4-20260911/cohort/preflight.log)以 TRSM_PREFLIGHT_COMPLETE=1 结束。两个候选各 29 组已知解、padding、L 不变和边界用例，在正常 1/4/38 线程、强制分配失败 4 线程、禁用 SVE 4 线程下均通过，总计 **290 次已知解、40 次无操作检查**，已知解最大误差为 0。覆盖 64 MiB 分流边界 m=4095/4096/4097、KB 尾块和 CT 尾部，以及列尾 n=1/7/8/9/15/17/63/64/65。

SVE24 的正常 1/4 线程检查包含在实际分派预检中；每次完整算子均记录 44160 次真实 SVE24 入口。同时分别通过 30 组 count/stride 的直接微核检查，共 **60 组**，与递增 k 的显式 FMA 参考逐字节一致并保留输出 padding。对角面板另在 1/4 线程各完成 50 组非二进制精确输入的直接 blocked 路径检查，共 **100 组**；以 long double 构造 RHS，最大误差 1.110e-16，padding 和 L 均保留。直接调用 blocked 的预检不修改提交实现的入口预算。预检源、替身和目标汇编均归档。本轮未运行 sanitizer；编译、预检及官方 benchmark 全部在超算计算节点执行。

[参考环境完整日志](../records/evidence/trsm-stage-r4-20260911/cohort/reference-environment.log)显示默认官方模块目录 `/home/HPC/HPCKit/latest/modulefiles` 缺失，默认头文件加链接探测报 `kblas.h: No such file or directory`，单独链接探测报 `cannot find -lkblas`，二者退出码均为 1。**这些结果只说明默认环境没有配置成功，不能证明超算没有安装 KML。**

本轮扩大搜索后，在 `/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/KunpengHPCKit-kml.25.1.0` 找到 `include/kblas.h`、`gcclib/libkml_rt.so.25.1.0`、`bishenglib/libkml_rt.so.25.1.0` 和模块文件。它们属于 **25.1.0**，与官方目标 **25.2.0** 有版本差异；发现文件也不等于已经完成该库的编译、链接与三轮验证。KML 25.1 独立复验另行记录，不混入本轮 A/B 数据。

本轮配置明确指定 OpenBLAS 0.3.28 静态库，探针确认 USE_OPENMP、ARMV8、MAX_THREADS=38，实际线程数 38，编译和运行探针均退出 0。因此这 27 行结果仍属于 OpenBLAS 参考环境下的官方用例验证，**不是官方 KML 25.2.0 复验**。

## 留痕范围

[本轮归档](../records/evidence/trsm-stage-r4-20260911/README.md)保留三个成员的 nohash-recorded-evidence、record.json、wrapper 原始输出，准备阶段策略说明，以及共同配置、提交命令、调度状态、driver、提交/收集/无哈希登记脚本、预检源码与日志、参考探测、汇编和[全部登记比较命令](../records/evidence/trsm-stage-r4-20260911/cohort/record-compare-commands.json)。准备说明保留原来“待验证”等历史措辞；最终结果以本报告及 record.json 为准，失败晋级结论和全部波动未被改写。

此处为已脱敏的公开派生副本；未脱敏原件本地保留。未复制 cluster.local.json、known_hosts、凭据或认证连接材料、payload 压缩包与二进制。依用户要求，未计算或验证任何哈希；源码证据仅限本地字节快照，不声称远端源码身份或传输完整性已验证。本次整理只写本阶段报告和证据目录；最终提交包、独立 KML 测试及 GitHub 发布另行记录，未正式提交比赛。
