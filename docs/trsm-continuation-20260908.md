# TRSM：2026-09-08 同分配交错测量与继续优化

> 本页及所链接日志为公开脱敏副本；性能与源码身份不变，原始日志及已有哈希保留在本地。公开副本不用于原件校验或重新晋级，见 [公开说明](../PUBLICATION.md)。

当前最佳已晋级为 **T1-panel-r2**，主目录采用原有 **T1-panel 打包实现**；r2 是这份不变源码的确认测量身份，不是新造的提速源码。本轮先完成 KB=128 和两步展开两个独立候选，均未达到晋级条件；再在同一真实分配内交错确认 T0 与 T1-panel，合计中位数由 776.95 ms 降至 758.31 ms，改善 **2.40%**，大用例改善 **3.71%**，通过原工具判定后晋级。

本轮两个真实调度作业、五个测量成员各三轮，共 **45 条官方用例结果全部 PASS**；加上前轮为 90 条。所有本轮作业已结束，没有正式提交比赛。

## 已完成测量与判定

每个成员独立执行三轮完整套件，每条打印耗时为官方程序内部 `TEST_RUNS=3` 次计时的均值。表中的中位数取自这三个独立均值；合计为各用例中位数之和，是内部筛选指标，不是官方分数。

|实验|真实作业|NUMA / CPU|512×19968 ms|2432×17024 ms|17024×512 ms|合计 ms|判定|
|---|---|---|---:|---:|---:|---:|---|
|T0-r2（T0 源码）|1485273|6 / 228–265|22.42|254.59|501.17|778.18|本次同分配对照|
|T2-k128|1485273|6 / 228–265|22.60|257.12|505.02|784.74|慢 0.84%，未晋级|
|T2-unroll|1485273|6 / 228–265|22.52|255.22|495.31|773.05|快 0.66%，未超过波动，未晋级|
|T0-r3（T0 源码）|1485286|6 / 228–265|22.39|255.29|499.27|776.95|最后确认的同分配基线|
|T1-panel-r2（原 T1-panel 源码）|1485286|6 / 228–265|22.54|255.04|480.73|758.31|快 2.40%，已晋级|

三成员的真实 machine、完整 CPU 列表、编译器、参考库与参数完全相同，且共享作业 1485273 的真实调度状态。T2-k128 三组分别慢 0.80%、0.99%、0.77%，没有证据支持缩小 KB 的收益。T2-unroll 大用例快 1.17%，前两组分别慢 0.45%、0.25%；合计快 0.66%，仍未达到由本次样本计算的 1.06% 门槛。没有选择最快的单个样本或改变晋级规则。

比较结果：[T0-r2 与 T2-k128](../records/evidence/trsm-continuation-20260908/continuation/T0-r2-vs-T2-k128.json)、[T0-r2 与 T2-unroll](../records/evidence/trsm-continuation-20260908/continuation/T0-r2-vs-T2-unroll.json)。

最后确认使用作业 1485286：T0-r3 和 T1-panel-r2 在相同 CPU、NUMA、参考库和全部计时参数下交错执行，各有 9 条 PASS。打包版三组分别慢 0.67%、快 0.10%、快 3.71%；合计改善 2.3991%，超过本次最大逐用例范围波动 2.2626%，且没有单组退步超过 1%。工具返回 `eligible=true`。门槛余量较小，应保留这个具体限制，不把 2.40% 扩大为所有环境的保证。

在核对当时主源码仍为 T0 后，先通过原工具晋级等源码测量基线 T0-r3，再晋级其子记录 T1-panel-r2；两次命令均退出 0。主源码哈希已变为 `fea6ee11…45dbf73`，与已测原 T1-panel 完全一致。此决定使用完整三轮结果和既定门槛，没有改写此前未晋级记录，也没有把两次作业样本混合后选优。证据：[最终比较](../records/evidence/trsm-continuation-20260908/confirmation/T0-r3-vs-T1-panel-r2.json)、[实际晋级命令与退出码](../records/evidence/trsm-continuation-20260908/confirmation/promotion-commands.json)。

## 完整逐用例样本

所有数值均来自实际日志；范围波动为 `(最大值−最小值)/中位数`，没有去除异常值或混合不同作业样本。

|实验|用例|第1轮 ms|第2轮 ms|第3轮 ms|中位数 ms|波动 %|最大绝对误差|
|---|---|---:|---:|---:|---:|---:|---:|
|T0-r2|512×19968|22.42|22.30|22.43|22.42|0.58|1.67e-16|
|T0-r2|2432×17024|254.59|253.70|255.21|254.59|0.59|2.22e-16|
|T0-r2|17024×512|502.04|499.13|501.17|501.17|0.58|1.11e-15|
|T2-k128|512×19968|22.74|22.40|22.60|22.60|1.50|1.67e-16|
|T2-k128|2432×17024|255.59|264.23|257.12|257.12|3.36|2.22e-16|
|T2-k128|17024×512|505.67|500.34|505.02|505.02|1.06|1.39e-15|
|T2-unroll|512×19968|22.52|22.61|22.46|22.52|0.67|1.67e-16|
|T2-unroll|2432×17024|255.22|256.43|253.73|255.22|1.06|2.22e-16|
|T2-unroll|17024×512|495.31|495.14|496.25|495.31|0.22|1.11e-15|
|T0-r3|512×19968|22.46|22.34|22.39|22.39|0.54|1.67e-16|
|T0-r3|2432×17024|253.46|255.29|258.13|255.29|1.83|2.22e-16|
|T0-r3|17024×512|499.27|500.32|498.55|499.27|0.35|1.11e-15|
|T1-panel-r2|512×19968|22.68|22.17|22.54|22.54|2.26|1.67e-16|
|T1-panel-r2|2432×17024|259.85|254.20|255.04|255.04|2.22|2.22e-16|
|T1-panel-r2|17024×512|480.73|481.40|480.38|480.73|0.21|1.11e-15|

## 单一假设、来源与源码身份

T0-r2 无 parent 建立，全部源码与当时主目录 T0 相同，只是新的同分配测量基线 ID。T2-k128 和 T2-unroll 的父测量记录在远程提交前统一为 T0-r2；修改前元数据已留档，没有事后变更父版本来迎合测量结果。

T2-k128 只将大工作集 `solve_blocked` 的 KB 从 256 改为 128，CT=64、4×8 微核、线程分工和小工作集路径不变。假设是缩小活动输入工作集和对角求解成本；代价是更多同步与 B 写回，且点积分组变化。官方大用例最大误差为 1.39e-15，仍小于 1e-12；实测未支持该变更带来速度收益。

T2-unroll 只对大工作集 NEON `update4x8` 的 k 循环显式展开两步，每个累加器仍依次处理 k、k+1，保留奇数尾项。假设是减少循环分支和地址计算，增加加载与 FMA 的调度机会；没有拆分归约、预取或其他同时变化。其收益不足以晋级。

最后的 T1-panel-r2 使用原 T1-panel 源码，仍是已解 RHS 连续窄面板方案的复测，不是新优化版本。

|源码身份|SHA-256|
|---|---|
|T0 / T0-r2 / T0-r3 trsm.c|`6b66766196b2a6024fcbbeac45ff1b4189e19cc8ac8d75d001e4ddfea004abac`|
|T2-k128 trsm.c|`6e78257dd61e581ad4fe3720dc91e25c63ab91e81efa3bf972617d6165407790`|
|T2-unroll trsm.c|`bff1a285b4e454d26fecdc548409d424ae2fe18e042620319db026105149910c`|
|T1-panel / T1-panel-r2 trsm.c|`fea6ee11cce8785ac3f13f641f9feb195a829493a27a9c902000a743545dbf73`|
|全部相同的 bench_trsm.c|`e051d897622f73093179f93c33cfcf1b5511216f286a3050b814e1dd7582d8ac`|
|全部相同的 run.sh|`ff786ed858fcc3dd32f9714ca0e93edc3a92146bc40b4d4fd63f98e47dd0fe21`|
|全部相同的 compat/kblas.h|`7b12cdf204c79d8acd82f6c0657392fb9e3f75726c6109151738b8dfc25aa26b`|

## 一个调度分配内的真实交错执行

本轮使用实验专属 `cohort_driver.py` 和 `submit_cohort.py`，放在 `.runs/trsm/continuation-20260908/` 与 `.runs/trsm/confirmation-20260908/`。未修改 `tools/cluster.py`、`tools/remote_job.sh`、官方 benchmark 或候选 run.sh。它是明确留档的自定义外层编排，不声称执行了标准三轮 wrapper。

作业 1485273 的三轮顺序分别为 `T0-r2 → T2-k128 → T2-unroll`、`T2-k128 → T2-unroll → T0-r2`、`T2-unroll → T0-r2 → T2-k128`，每个成员在每个先后位置出现一次。最后确认作业 1485286 的实际顺序为 `T0-r3 → T1-panel-r2`、`T1-panel-r2 → T0-r3`、`T0-r3 → T1-panel-r2`。每轮每成员都直接执行完整且未改的 run.sh，成员之间不并发。

提交前使用原工具函数冻结真实源码、设置与上传包，保存 payload SHA-256，并防止重复提交。每组仅有一个真实 dsub job ID；成员 cluster.json 指向各自真实远端目录，使用共同 job ID，另外记录编排 ID、顺序和 driver 哈希。没有把不同调度分配写成同一个作业。

driver 检查实际 affinity 恰好 38 CPU、属于一个 NUMA，并固定原 OMP 设置；初始化和每轮后核对源码，每轮前后核对参考库哈希。stdout/stderr 在执行时逐字节保存到成员日志及总作业输出，不提取 PASS 行拼接成绩。所有成员完整完成三轮、日志 flush/fsync 后才生成成功退出文件；失败使用非零状态，仅清理自身启动的进程组。最后继续使用原 `cluster.py status/fetch` 与 `experiment.py record/compare`，核查真实调度状态、job ID、下载 artifact 哈希、源码三方一致性与逐用例结果。

|编排|真实作业|driver SHA-256|冻结上传包 SHA-256|
|---|---|---|---|
|continuation|1485273|`a879ad820443a5ef1bf931b66835baa1c5cab237bc6fb2d1ee088a6c2c647f6d`|`18835723df539d51f572e904004017d73b50e9f49778cb0e64c85c3041cf22e8`|
|confirmation|1485286|`9389eb3d22b574608a9ca6941560ba4dacc8e2dfb29b6e3adbd6566c4e4f841b`|`3eb8bf4abf5d5989857af5f7f303cea48602070d54d00ae8c0273ec932d5bf6b`|

## 环境、参考库与本机检查

两个已完成的编排均运行于 COMPUTE_NODE_1 / q_kunpeng、NUMA 6、CPU 228–265，GCC 10.3.1，`-O3 -ffp-contract=off -fopenmp -mcpu=generic`，无 fast-math。资源为 38 核单 NUMA、24576 MiB 内存、1800 秒上限；`OMP_NUM_THREADS=38`、`OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`。官方用例、1e-12 容差及计时区域均保持不变。

参考库仍为 `/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a`，OpenBLAS 0.3.28 static，USE_OPENMP ARMV8，SHA-256 为 `c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0`。前一轮计算节点探针报告 MAX_THREADS=38、实际查询线程数 38；本轮按此已确认身份检查库哈希。此前官方模块目录缺失，kblas.h 编译与 -lkblas 链接失败的证据继续保留；本轮没有新增 KML 成功证据。**这是 OpenBLAS 参考环境下的官方用例验证，未完成官方 KML 25.2.0 复验。** 参考环境详情见[前轮比较记录](trsm-comparison-20260908.md)。

T2-k128 在 Apple ARM64 纯 UBSan 下完成正常 1/4 线程共 22 次 TRSM 用例检查，强制分配失败构建另完成 4 次检查，均 PASS。它基于 T0，大工作集路径没有共享打包区；其中只有 4095×9 触发小工作集分配失败回退，不把另外三组记为共享面板回退覆盖。

T2-unroll 完成正常路径 22 次检查、分配失败版本 11 次整算子检查，以及直接调用更新微核的 55 组 count/步长组合，均 PASS。直接微核检查覆盖 0/1/奇数/偶数 count，并与有序标量 FMA 逐位一致。整算子检查继续验证 B padding 与 L 不变；本机结果不作为鲲鹏性能，没有服务器 sanitizer 成功记录。本机报告保留准备时状态，鲲鹏测量结论以本页与已登记记录为准。

- [T2-k128 本机报告](../records/evidence/trsm-continuation-20260908/T2-k128/local-validation/REPORT.md)
- [T2-unroll 本机报告](../records/evidence/trsm-continuation-20260908/T2-unroll/local-validation/REPORT.md)

## 命令与证据索引

两个编排分别调用各自目录中的 `python3 submit_cohort.py prepare` 和 `python3 submit_cohort.py submit`；已保存的提交记录包含真实完整 dsub 命令及唯一 job ID，不能重复执行提交。随后对各成员执行原工具的 status、fetch、record，再按父测量记录 compare。完整实际参数与退出码保存在编排目录的 record-compare-commands.json，参考库名称没有写成 KML。

- [首次编排配置与顺序](../records/evidence/trsm-continuation-20260908/continuation/cohort-config.json)、[编排源码](../records/evidence/trsm-continuation-20260908/continuation/cohort_driver.py)、[真实提交命令与包身份](../records/evidence/trsm-continuation-20260908/continuation/cohort-submission.json)、[登记和比较命令](../records/evidence/trsm-continuation-20260908/continuation/record-compare-commands.json)
- [最后确认配置与顺序](../records/evidence/trsm-continuation-20260908/confirmation/cohort-config.json)、[编排源码](../records/evidence/trsm-continuation-20260908/confirmation/cohort_driver.py)、[真实提交命令与包身份](../records/evidence/trsm-continuation-20260908/confirmation/cohort-submission.json)
- [最后确认的登记比较命令](../records/evidence/trsm-continuation-20260908/confirmation/record-compare-commands.json)、[晋级命令](../records/evidence/trsm-continuation-20260908/confirmation/promotion-commands.json)
- [T0-r2 原始日志](../records/evidence/trsm-continuation-20260908/T0-r2/benchmark.log)、[测量台账](../records/experiments/trsm/T0-r2.json)
- [T2-k128 原始日志](../records/evidence/trsm-continuation-20260908/T2-k128/benchmark.log)、[测量台账](../records/experiments/trsm/T2-k128.json)
- [T2-unroll 原始日志](../records/evidence/trsm-continuation-20260908/T2-unroll/benchmark.log)、[测量台账](../records/experiments/trsm/T2-unroll.json)
- [T0-r3 原始日志](../records/evidence/trsm-continuation-20260908/T0-r3/benchmark.log)、[测量台账](../records/experiments/trsm/T0-r3.json)
- [T1-panel-r2 原始日志](../records/evidence/trsm-continuation-20260908/T1-panel-r2/benchmark.log)、[测量台账](../records/experiments/trsm/T1-panel-r2.json)
- [证据 SHA-256 清单](../records/evidence/trsm-continuation-20260908/manifest.json)

两次调度作业均 SUCCEEDED，jobExitCode/systemExitCode 均为 0；五成员退出文件均为 0，各有三轮完整的 9 条 PASS，均已由原工具登记为 passed/verified。所有原始日志、源码快照与未晋级尝试保留。当前最佳测量身份为 T1-panel-r2，来源实现为原 T1-panel；本轮无未结束作业，不再追加测试。正式比赛提交由用户负责，本轮没有正式提交比赛。
