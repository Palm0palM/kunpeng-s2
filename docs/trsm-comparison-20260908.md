# TRSM：2026-09-08 比较与后续优化记录

> 本页及所链接日志为公开脱敏副本；性能与源码身份不变，原始日志及已有哈希保留在本地。公开副本不用于原件校验或重新晋级，见 [公开说明](../PUBLICATION.md)。

本页保存首轮历史结果。后续已通过同一作业内交错测量确认 T1-panel 收益，并将相同实现以 T1-panel-r2 记录晋级；当前结果见 [后续优化与晋级记录](trsm-continuation-20260908.md)。

当前最佳仍为 **T0**。先完成既有 T0 / T1-panel 三轮比较，再完成各一次三轮复测和后续 T1-colreuse 三轮实验；5 个 benchmark 作业、45 个官方用例结果全部 PASS。两种候选均未获得足以晋级的稳定收益。没有取消其他作业、正式提交比赛或推送 Git。

## 结论与逐实验汇总

每个作业独立执行三轮完整套件，每条打印耗时是官方程序内部 `TEST_RUNS=3` 次计时的均值。下表为三个独立均值的中位数；合计是各用例中位数之和，仅用于内部筛选，不是官方分数。

|实验（源码版本）|作业|NUMA / CPU|512×19968 ms|2432×17024 ms|17024×512 ms|合计 ms|结论|
|---|---|---|---:|---:|---:|---:|---|
|T0|1485178|6 / 228–265|22.27|256.19|502.78|781.24|已建立当前测量基线|
|T1-panel|1485182|6 / 228–265|22.75|256.10|482.56|761.41|未晋级：改善低于波动，首组退步|
|T0-r1|1485186|7 / 266–303|22.69|258.37|503.74|784.80|同源码复测；NUMA不同，单列保存|
|T1-panel-r1|1485188|6 / 228–265|22.27|258.69|481.95|762.91|同源码复测；波动仍较大|
|T1-colreuse|1485191|6 / 228–265|23.20|255.93|487.13|766.26|未晋级：未优于T1-panel，波动较大|

首轮 T0 与 T1-panel 的机器、CPU/NUMA、编译器、线程、绑定、参考库和计时参数完全相同。T1-panel 大用例改善 **4.02%**，合计改善 **2.54%**，但首组退步 **2.16%**，合计改善未超过 **3.59%** 波动门槛。工具判定不晋级。

后续按 T0 → T1-panel → T0-r1 → T1-panel-r1 的作业顺序复测，但 T0-r1 被分配到 NUMA 7、CPU 266–303，T1-panel-r1 回到 NUMA 6、CPU 228–265。工具拒绝把该复测对直接比较，没有合并不同 NUMA 样本。T1-panel-r1 可与同 CPU 的首轮 T0 作时间上分离的对照：大用例改善 4.14%、合计改善 2.35%，仍低于该次 9.70% 最大逐用例波动。小用例本次中位数相同，说明首轮的小幅变化尚不能解释为稳定的算法退化或改善。

T1-colreuse 相对当前 T0 的合计改善 1.92%，首组退步 4.18%，波动门槛 8.62%；相对 T1-panel 的合计反而增加 0.64%，大用例增加 0.95%。这一轮没有支持循环交换带来额外收益，保留为未晋级尝试。没有挑选更快的单次测量晋级。

比较输出：
- [T0-vs-T1-panel.json](../records/evidence/trsm-20260908/T0-vs-T1-panel.json)
- [T0-r1-vs-T1-panel-r1.json](../records/evidence/trsm-20260908/T0-r1-vs-T1-panel-r1.json)
- [T0-vs-T1-panel-r1.json](../records/evidence/trsm-20260908/T0-vs-T1-panel-r1.json)
- [T0-vs-T1-colreuse.json](../records/evidence/trsm-20260908/T0-vs-T1-colreuse.json)
- [T1-panel-vs-T1-colreuse.json](../records/evidence/trsm-20260908/T1-panel-vs-T1-colreuse.json)

## 完整逐用例样本

以下全部为实际打印值；范围波动为 `(最大值−最小值)/中位数`。没有对样本去异常值或选择性删除。

|实验|用例|第1轮 ms|第2轮 ms|第3轮 ms|中位数 ms|波动 %|最大绝对误差|
|---|---|---:|---:|---:|---:|---:|---:|
|T0|512×19968|21.86|22.66|22.27|22.27|3.59|1.67e-16|
|T0|2432×17024|256.29|253.66|256.19|256.19|1.03|2.22e-16|
|T0|17024×512|512.21|502.17|502.78|502.78|2.00|1.11e-15|
|T1-panel|512×19968|22.75|23.24|22.67|22.75|2.51|1.67e-16|
|T1-panel|2432×17024|254.07|257.25|256.10|256.10|1.24|2.22e-16|
|T1-panel|17024×512|482.56|486.84|482.52|482.56|0.90|1.11e-15|
|T0-r1|512×19968|22.69|22.69|23.34|22.69|2.86|1.67e-16|
|T0-r1|2432×17024|261.47|258.37|257.04|258.37|1.71|2.22e-16|
|T0-r1|17024×512|503.74|513.62|502.84|503.74|2.14|1.11e-15|
|T1-panel-r1|512×19968|22.26|22.27|24.42|22.27|9.70|1.67e-16|
|T1-panel-r1|2432×17024|257.64|268.03|258.69|258.69|4.02|2.22e-16|
|T1-panel-r1|17024×512|481.95|489.89|481.85|481.95|1.67|1.11e-15|
|T1-colreuse|512×19968|22.33|24.33|23.20|23.20|8.62|1.67e-16|
|T1-colreuse|2432×17024|255.63|255.93|257.29|255.93|0.65|2.22e-16|
|T1-colreuse|17024×512|487.13|486.96|488.61|487.13|0.34|1.11e-15|

## 策略、来源与源码身份

T0 无 parent 建立初始当前测量基线，源码与当前 trsm/ 完全一致，已通过 experiment.py record 和 promote。T0-r1 与 T1-panel-r1 是原源码的独立复测 ID，不代表新优化版本。

T1-panel 仅将大工作集分块前代的已解 RHS 打包成连续 256×8 面板供下方行块共享读取；块尺寸、内核、算法阈值及累计次序保持不变，分配失败回退原读取方式。

T1-colreuse 的 parent 保留为当前最佳 T0，策略明确记为 derived_from T1-panel。相对已测 T1-panel 只有更新微块的 i/j 循环交换为 j/i，使一个面板连续供同一 64 行块中的多个 4 行更新消费；这是测试缓存复用的单一后续假设，没有改点积顺序、OpenMP 分工、同步、块尺寸、benchmark 或 runner。独立候选路径为 `.runs/trsm/T1-colreuse/source/`。

|源码身份|SHA-256|
|---|---|
|T0 trsm.c|`6b66766196b2a6024fcbbeac45ff1b4189e19cc8ac8d75d001e4ddfea004abac`|
|T1-panel trsm.c|`fea6ee11cce8785ac3f13f641f9feb195a829493a27a9c902000a743545dbf73`|
|T1-colreuse trsm.c|`e0cee4d518144cfbc83e25cfffc55e64cfabc1687ef79ac449720fa84ed76d9f`|
|全部实验相同的 bench_trsm.c|`e051d897622f73093179f93c33cfcf1b5511216f286a3050b814e1dd7582d8ac`|
|全部实验相同的 run.sh|`ff786ed858fcc3dd32f9714ca0e93edc3a92146bc40b4d4fd63f98e47dd0fe21`|
|全部实验相同的 compat/kblas.h|`7b12cdf204c79d8acd82f6c0657392fb9e3f75726c6109151738b8dfc25aa26b`|

完整源码哈希清单在各实验 source-sha256.txt 与 measurement-record.json，候选快照保留在 .runs/。创建时 experiment.json 中 source_hashes 是创建快照的身份；checkpoint 写入 records，submit/record 再计算实际源码，因此测量身份以已核对的本地、上传和远端哈希为准。

## 环境与参考库差异

全部 benchmark 运行于 COMPUTE_NODE_1 / q_kunpeng，GCC 10.3.1，`-O3 -ffp-contract=off -fopenmp -mcpu=generic`，无 fast-math。38 核单 NUMA、24 GiB 内存申请、1800 秒作业上限；`OMP_NUM_THREADS=38`、`OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`。runner 对 CPU 和内存绑定到调度允许的 NUMA，wrapper 验证恰好 38 个允许 CPU 且归属单 NUMA。官方用例、精度 `1e-12` 和计时区不变。每次比较均由工具检查真实 machine 字典，环境 ID 相同不用于掩盖 CPU 差异。

参考库路径：`/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a`。

参考库身份：OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0。

计算节点环境检查作业 **1485185** 在 COMPUTE_NODE_1、CPU 266–303 上完成。其 OpenBLAS 查询结果为 `OpenBLAS 0.3.28 NO_LAPACK NO_LAPACKE NO_AFFINITY USE_OPENMP ARMV8 MAX_THREADS=38`，`openblas_get_parallel()=2`、`openblas_get_num_threads()=38`。登录节点检查、计算节点检查前后，以及各 benchmark 完成后的库哈希均一致。

官方路径 `/home/HPC/HPCKit/latest/modulefiles` 不存在；可见模块列表仅含基础模块，在所查常用安装目录未发现 KML；实际 `#include <kblas.h>` 编译及 `-lkblas` 链接检查均失败。结论限定为**当前计算节点环境的官方 KML 配置不可用**，不能扩展为全集群无任何 KML 安装。**本轮是 OpenBLAS 参考环境下的官方用例校验，未完成官方 KML 25.2.0 复验。** 环境检查作业成功仅表示检查脚本执行完成，不表示失败的 KML 编译探针通过。

五个远端 wrapper 的 SHA-256 均为 `cc7a15fc79998db6403c363b1939112a045cf1fbc507f32c5d98a19e10bd9711`。执行程序哈希、编译器 .comment 与动态链接依赖另存逐作业 remote-provenance.log。未修改公共工具；收尾时读取的工具哈希只标记观察时状态，不能当作此前所有时刻的工具版本。

## 验证与证据

五个 benchmark 作业均为 SUCCEEDED，调度器 jobExitCode/systemExitCode 均为 0，wrapper 退出 0，9 条严格按顺序的 PASS 各自齐全。工具已核对 job ID、官方 benchmark 哈希、源文件三方一致性、下载产物哈希和实际机器信息。没有服务器 sanitizer 成功记录。

T1-colreuse 通过 Apple ARM64 纯 UBSan：1/4 线程原始 7 组与扩展 4 组，以及 4 线程强制分配失败回退 4 组，共 26 次 TRSM 用例检查；最大误差 3.886e-16，padding 与 L 不变，构建/执行均退出 0，无 UBSan 诊断。本机检查不作为鲲鹏性能或官方 KML 证据。T1-panel 的既有本机检查沿用原候选文档，未重复声称新测试。

- [本机候选报告与命令](../records/evidence/trsm-20260908/T1-colreuse/local-validation/REPORT.md)
- [唯一循环交换差异](../records/evidence/trsm-20260908/T1-colreuse/local-validation/source-vs-T1-panel.diff)
- [参考环境原始日志](../records/evidence/trsm-20260908/environment-job/environment-probe.log)
- [实际命令重放说明](../records/evidence/trsm-20260908/COMMANDS.md)
- [证据 SHA-256 清单](../records/evidence/trsm-20260908/manifest.json)
- [T0 原始 benchmark 日志](../records/evidence/trsm-20260908/T0/benchmark.log)；[逐实验机器与测量台账](../records/experiments/trsm/T0.json)
- [T1-panel 原始 benchmark 日志](../records/evidence/trsm-20260908/T1-panel/benchmark.log)；[逐实验机器与测量台账](../records/experiments/trsm/T1-panel.json)
- [T0-r1 原始 benchmark 日志](../records/evidence/trsm-20260908/T0-r1/benchmark.log)；[逐实验机器与测量台账](../records/experiments/trsm/T0-r1.json)
- [T1-panel-r1 原始 benchmark 日志](../records/evidence/trsm-20260908/T1-panel-r1/benchmark.log)；[逐实验机器与测量台账](../records/experiments/trsm/T1-panel-r1.json)
- [T1-colreuse 原始 benchmark 日志](../records/evidence/trsm-20260908/T1-colreuse/benchmark.log)；[逐实验机器与测量台账](../records/experiments/trsm/T1-colreuse.json)

所有原始目录、原始日志与未晋级候选均保留；没有覆盖既有 run。当前没有仍在运行或待处理的本轮作业，也没有需要用户重新认证的连接事项。正式比赛提交未进行。下一轮应先在同一资源分配内组织 T0 与 T1-panel 的交错测量、确认波动来源，再判断打包方案能否稳定晋级；本轮按用户收尾时间要求不再追加测试。
