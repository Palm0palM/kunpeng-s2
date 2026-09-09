# 1492058：SVE 预检查通过，官方计时前参数检查停止

真实作业 `1492058`（cohort `trsm-cohort-c5c8ab4768a3`）已结束，调度器状态为 FAILED，jobExitCode=125、systemExitCode=10001。作业在 COMPUTE_NODE_1 上获得 CPU 342–379、38 核、单 NUMA 分配；预检查使用 GCC 10.3.1、`-O3 -ffp-contract=off -fopenmp -mcpu=generic`。调度器记录运行时间为 34 秒。[原始调度器状态](scheduler-status.txt)

两候选完成 SVE 预检查后，编排器发现实验环境未显式设置 `TEST_RUNS=3`，立即报错停止，尚未开始任何官方 runner 轮次。日志没有 `BENCH_REPEAT`，本组 **零官方成绩**，不用于性能比较或晋级。[真实 wrapper 日志](wrapper.stdout.log)、[完整预检查日志](preflight.log)、[结构化汇总](preflight-summary.json)

|项目|T3-svepanel-r1|T3-sveupdate-r1|
|---|---:|---:|
|直接 SVE 微核有序 FMA 对照|30 组合 × 1/4 线程两次，均 PASS|30 组合 × 1/4 线程两次，均 PASS|
|正常整算子已知解|10 尺寸 + 4 个 no-op，1/4 线程各 PASS|10 尺寸 + 4 个 no-op，1/4 线程各 PASS|
|强制分配失败回退|相同 14 项，4 线程 PASS|相同 14 项，4 线程 PASS|
|正常整算子真实 SVE 函数入口|1 线程 2161；4 线程 2161|1 线程 84992；4 线程 84992|
|已知解最大绝对误差|0|0|

合计为 120 组直接微核组合检查，以及 6 套已知解检查（60 个有效尺寸、24 个 no-op），均通过。入口计数在直接微核检查结束后清零，因此表中入口来自整算子执行。基线 T1-control4 的官方 runner 未启动；不能把候选的预检查登记成基线官方通过。

已知解含 4095×9、4096×8、4097×9、4355×65，检查算法切换边界、行列尾部、padding 和 L 不变性。输入使用分母为 2^14 的有限二进制数，按源码中的界限证明用 binary64 精确构造 B，避免软件 long-double 构造造成的额外耗时；这仅是独立预检查，官方 benchmark、尺寸和精度容差未改。[已知解源码](preflight/check-trsm.c)、[微核与实际入口检查源码](preflight/check-sve.c)、[实际预检查命令](preflight/run-preflight.sh)

静态读取服务器生成的汇编可见两个 SVE helper 使用 `ld1d`、四条 `fmla z*.d` 累加和 `st1d`；update helper 最后使用单独的 `fsub z*.d`。向量宽度 helper 使用 `cntd` 与 8 比较；普通 OpenMP 调度函数处于 `.arch armv8-a`，先检查 HWCAP_SVE 对应 bit 22，再调用目标 helper，且原 NEON 路径保留。[panel 汇编](preflight/trsm-panel.s)、[update 汇编](preflight/trsm-update.s)

同分配参考环境探测确认 OpenBLAS 0.3.28 静态库报告 `USE_OPENMP ARMV8 MAX_THREADS=38`、实际线程 38；官方 HPCKit module 根目录缺失，`kblas.h` 和 `-lkblas` 探测失败。TRSM 独立预检查没有链接 BLAS；本组也没有官方 benchmark 或官方 KML 复验。[参考环境原始日志](preflight/environment-probe.log)

本次取证只通过已配置 SSH 读取状态与下载 13 份文本文件，包括预检查源码、日志和汇编；没有下载可执行文件或对象文件，没有在本机编译或运行测试。首次沙盒网络读取被拒的原始错误也保留，随后使用获准的 SSH 读取完成取回。

用户在取证期间明确禁止后续任何哈希计算和验证。本归档、摘要及三条失败 JSON 均按该要求直接写入，没有调用 `experiment.py record` 或 `cluster.fetch`。原有实验记录、cohort 元数据中的旧哈希字段只作为历史内容保留，**没有重新计算或据此验证当前、远程或归档文件**。这里的路径清单不包含新哈希。[取回命令](text-collection-commands.json)、[无哈希归档脚本](archive-stopped-nohash.py)、[文件清单](file-inventory-nohash.json)

三条失败记录分别保存于 [T1-control4](experiment-records/T1-control4.json)、[T3-svepanel-r1](experiment-records/T3-svepanel-r1.json)、[T3-sveupdate-r1](experiment-records/T3-sveupdate-r1.json)；登记前版本位于 `records-before/`。没有更改这三份源码、当前主源码或其他组作业。
