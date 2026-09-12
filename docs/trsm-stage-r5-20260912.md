# TRSM 第五轮：KML 25.1 / GCC 12 基线与小工作集优化

本轮 `T8-svepanel16` 已通过同作业内三轮比较并晋级。比较作业 **1576028 SUCCEEDED，27/27 官方用例 PASS**；它相对共同 T7 对照的逐用例中位数合计从 **508.56 ms 降至 447.59 ms，降低 11.9888%**，超过本轮 **7.6661%** 的波动门槛。`T8-paneloutline` 合计 508.90 ms，未晋级。最终 ZIP 已完成独立超算解压三轮 9/9 PASS，见[最终交付](trsm-final-20260912-r5.md)。

此前基线初测作业 **1576015 SUCCEEDED，9/9 PASS**，建立了 `T7-control11`。其 NUMA 分配及初测成绩单独保留；候选收益全部来自作业 1576028 内的共同对照。

本轮仅涉及 TRSM。题目编译、预检和 benchmark 均在调度分配的鲲鹏计算节点执行；本机只做代码和文档编辑、连接传输及日志整理。未正式提交比赛。

## 已完成的基线初测

`T7-control11` 的 `parent=null`，`source_implementation_id=T7-diagpanel`，初测登记时四份必要源码与当时 TRSM 主目录的 T7 源码直接逐字节一致。作业 1576015 在北京时间 2026-09-12 10:22:25 开始、10:23:28 结束，调度器 `jobExitCode=0`、`systemExitCode=0`，cohort 和成员 wrapper 退出码均为 0。

下表每个样本是原 benchmark 内部 `TEST_RUNS=3` 次计时的均值；中位数取自三个独立完整套件，不是把同一套件内三次计时视为三轮。原官方尺寸、计时范围和 `1e-12` 精度要求保持不变。

| 官方尺寸 M×N | 第 1 套件 ms | 第 2 套件 ms | 第 3 套件 ms | 三套件中位数 ms | 跨度/中位数 | 最大误差 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 512×19968 | 23.76 | 23.97 | 23.62 | 23.76 | 1.4731% | 1.67e-16 |
| 2432×17024 | 290.48 | 291.02 | 290.46 | 290.48 | 0.1928% | 2.22e-16 |
| 17024×512 | 194.56 | 195.58 | 194.26 | 194.56 | 0.6785% | 1.11e-15 |

逐用例中位数合计 **508.80 ms**，是内部比较指标，官方分数与排名仍为空。基线初测只用于建立当前环境的已通过起点，不与此前 OpenBLAS/GCC10 的成绩计算策略增益。

基线登记时间为北京时间 10:24:04，晋级时间为 10:24:14。随后才创建 `parent=T7-control11` 的 `T8-svepanel16` 和 `T8-paneloutline` 实验记录，并提交共同比较作业。此前准备的候选代码不视为已完成验证的实验。

## 实际环境与 KML 验证范围

基线初测使用 Linux aarch64 鲲鹏计算节点、**NUMA 3、CPU 114–151**；比较作业 1576028 则使用同一计算节点的 **NUMA 2、CPU 76–113**。两次均恰好 38 个允许 CPU，队列 `q_kunpeng`，申请 24 GiB 内存、单 NUMA `pack` 分配、1800 秒时限。运行设置为 `OMP_NUM_THREADS=38`、`OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`、`CPU_TARGET=generic`、`TEST_RUNS=3`，编译参数保持原 runner 的 `-O3 -ffp-contract=off -fopenmp -mcpu=generic`。不同 NUMA 的初测样本没有混入候选比较。

实际编译器为 `gcc (gcc for openEuler 3.0.2) 12.3.1`，使用任务私有编译器目录中的 `libgomp.so.1.0.0`，其 `omp_get_supported_active_levels` 符号提供 `OMP_5.0.1` 版本。实际参考库为 **Huawei KML 25.1.0** 的 `gcclib/sme/kblas/multi/libkblas.so.25.1.0`；`sme` 选择遵循该软件包对 CPU 型号的 BLAS 映射。

参考探测完成以下检查：实际 KML `include/kblas.h` 头文件、默认 `-lkblas` 链接、`cblas_dgemm` 与 `cblas_domatcopy` 必要符号及数值冒烟测试、KML 软件版本 25.1.0，以及 KML 配置线程数和实际 OpenMP team 均为 38。日志中的 `KML_VERSION_QUERY_EXIT=1` 是版本查询 API 的返回值，不是探测进程失败；探测完成标记和 wrapper 退出码均成功。

初测与比较作业中每个成员的三套件均保存实际 `trsm_test` 的完整 `ldd` 输出与目标节点解析后的真实路径。审计确认各套件均加载所选 KML 25.1 和私有 GCC12 `libgomp`，没有 OpenBLAS 或 `not found` 依赖。`KBLAS_LIB` 显式记录为空，使用原 runner 默认 KML 分支，没有用兼容头加静态 OpenBLAS 覆盖替代本轮校验。

**这仍不是指定的官方 KML 25.2.0 配置复验。** 当前可用软件包版本为 25.1.0；指定的 25.2.0 模块配置尚未完成验证。原 runner 输出的 `Reference BLAS: official kblas` 是默认链接分支的原文，不能据此把实际 25.1.0 改写成 25.2.0。此前 OpenBLAS 与本轮 KML 的参考库、编译器差异分别保留，不混算性能结论。背景见 [KML 25.1 复验说明](trsm-kml251-20260911.md)。

## 基线预检的实际覆盖

作业 1576015 的预检汇总实际报告 **406 组整算子检查、28 组非正维度 no-op，全部通过**。其中使用非 dyadic 输入及 long-double 构造右端项，检查原精度、L 不变和 B padding；整算子预检最大误差为 `3.8857805861880479e-16`。各步骤退出码均为 0。

| 路径与线程 | 整算子检查数 | no-op 数 | 结果 |
| --- | ---: | ---: | --- |
| 正常路径，1 线程 | 80 | 4 | PASS |
| 正常路径，4 线程 | 80 | 4 | PASS |
| 正常路径，38 线程冒烟 | 4 | 4 | PASS |
| 算法边界 4095×9、4097×9，1 线程 | 2 | 4 | PASS |
| 屏蔽 SVE 能力，4 线程 | 80 | 4 | PASS |
| 强制分配失败，4 线程 | 80 | 4 | PASS |
| 将实际 SVE VL 设为 16 bytes，4 线程 | 80 | 4 | PASS |

基线不含候选新增的 `solve16x8_panel_sve` 小工作集微核，因此直接微核检查数为 **0**，该微核入口计数均为 0。候选后来执行的 14 组直接微核检查归属于比较作业中的 T8，单独列在下文。预检保存了构建命令、逐路径日志、退出码、实际路径计数和目标汇编；未执行 sanitizer。

## 两个独立候选

`T8-svepanel16` 只改变小工作集的打包前代：一次保留 16 行、每行 8 个 RHS 的 SVE 累加器，让历史项每次载入的 X 向量被 16 行复用，随后按前代顺序解行并更新块内依赖。每条求和链仍按递增 k，但块内使用显式 FMA，舍入行为与原四行块不同；本轮已通过原 `1e-12` 验收。完整 16 行之后由原 NEON4 和标量路径处理余行，SVE 能力、线程向量宽度和分配失败回退保留；大工作集仍用 T7。策略意图是减少重复 X 载入和中间 sums 写回；实际收益由下方同环境测量支持，代码体积、寄存器分配和向量除法成本仍受编译器及硬件影响。

`T8-paneloutline` 只将既有 NEON `panel_sums` 在 GNU 属性可用时改为 `noinline`，函数运算、调用点和其他路径不改。它检验 GCC12 下保留函数边界是否能减轻调用者寄存器压力和代码重复；该函数同时服务于小工作集和大工作集的对角面板。调用、寄存器保存恢复以及跨过程优化减少可能带来退化，不能仅凭属性推断提速。

两种策略分别从同一 T7 实现准备，不组合改动。benchmark、runner、官方输入与精度、KB=256、CT=64、64 MiB 算法预算及线程限制保持原样；64 MiB 是算法选择预算，不是硬件缓存容量声明。

## 同作业内三轮比较

作业 **1576028** 于北京时间 2026-09-12 **10:28:36–10:31:49** 执行，最终 **SUCCEEDED**，调度器和各 wrapper 退出码均为 0。它在 NUMA 2、CPU 76–113 的同一分配内执行三个成员：A=`T7-control11-repeat-r5`，B=`T8-svepanel16`，C=`T8-paneloutline`。三轮次序为 **ABC、BCA、CAB**，每个成员各跑三套完整官方用例，共 **27/27 PASS**。三个记录的全部精度、环境、依赖与资源检查均通过。

以下每个版本的第 1、2、3 样本是各自参加上述三轮时的完整套件结果。正的耗时降低百分比表示相对本表 T7 中位数更快；初测作业 1576015 的值不参与计算。

| 版本 | M×N | 第 1 套件 ms | 第 2 套件 ms | 第 3 套件 ms | 中位数 ms | 跨度/中位数 | 相对 T7 耗时降低 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| T7-control11 repeat | 512×19968 | 24.19 | 23.86 | 23.42 | 23.86 | 3.2272% | — |
| T7-control11 repeat | 2432×17024 | 290.75 | 291.12 | 292.08 | 291.12 | 0.4569% | — |
| T7-control11 repeat | 17024×512 | 207.38 | 192.54 | 193.58 | 193.58 | 7.6661% | — |
| T8-svepanel16 | 512×19968 | 18.50 | 18.79 | 18.74 | 18.74 | 1.5475% | 21.4585% |
| T8-svepanel16 | 2432×17024 | 236.86 | 227.23 | 236.16 | 236.16 | 4.0777% | 18.8788% |
| T8-svepanel16 | 17024×512 | 192.69 | 193.56 | 192.11 | 192.69 | 0.7525% | 0.4598% |
| T8-paneloutline | 512×19968 | 22.95 | 23.30 | 24.21 | 23.30 | 5.4077% | 2.3470% |
| T8-paneloutline | 2432×17024 | 290.95 | 290.26 | 291.30 | 290.95 | 0.3574% | 0.0584% |
| T8-paneloutline | 17024×512 | 194.65 | 194.08 | 194.76 | 194.65 | 0.3493% | −0.5527% |

三个版本的官方逐用例最大误差均分别为 `1.67e-16`、`2.22e-16`、`1.11e-15`，全部低于原 `1e-12` 限制。T8 块内显式 FMA 的舍入差异没有通过调整精度标准掩盖。

| 版本 | 三个用例中位数合计 ms | 相对共同 T7 耗时降低 | 本次判定门槛 | 结论 |
| --- | ---: | ---: | ---: | --- |
| T7-control11 repeat | 508.56 | — | — | 同作业共同对照 |
| T8-svepanel16 | 447.59 | 11.9888% | 7.6661% | 达到晋级条件，已晋级 |
| T8-paneloutline | 508.90 | −0.0669% | 7.6661% | 没有总耗时改善，未晋级 |

波动门槛使用 `max(1%, 基线和候选所有用例的跨度百分比)`，并要求任何用例不得退化超过 1%。T7 大用例首轮 **207.38 ms** 的波动完整保留，令本轮门槛升至 **7.666081%**；没有删除该样本或选取更有利的一轮。T8-svepanel16 的 **11.988753%** 总耗时降低仍高于此门槛，三个用例均未退化。收益主要来自前两个小工作集用例；未改变的大工作集仅有 0.4598% 差异，不据此宣称该路径获得了新的稳定优化。

`T8-svepanel16` 于北京时间 **10:32:42** 晋级，`parent=T7-control11`，当前 TRSM 主内核已更新为该候选。`T8-paneloutline` 保留通过精度但未改善总耗时的完整记录。

## 比较作业预检

三份源码在同一比较作业内均先完成预检，再进入官方测量。各源码的整算子测试覆盖与前述基线表相同，各有 406 组整算子和 28 组 no-op。T8-svepanel16 另完成新增微核的 14 组直接检查：7 个历史行起点 × 2 个 lda padding，结果与递增顺序显式 FMA 参考逐字节一致，并检查已解前缀、保护区和 L 不变。该参考顺序与新微核一致，此结果不代表新微核与原 T7 的块内舍入逐位相同。

| 比较成员 | 直接新增微核 | 整算子 | no-op | 结果 |
| --- | ---: | ---: | ---: | --- |
| T7-control11 repeat | 0 | 406 | 28 | 全部 PASS |
| T8-svepanel16 | 14 | 406 | 28 | 全部 PASS |
| T8-paneloutline | 0 | 406 | 28 | 全部 PASS |

T8 的正常路径核对了新增微核的实际入口次数；屏蔽 SVE、强制分配失败、实际窄 VL 和不足 16 行等回退情形均核对为预期入口数。它的整算子预检最大误差为 `3.8857805861880479e-16`，L 和 B padding 检查均通过。三份源码的构建、目标汇编和逐路径日志均保留；本轮没有 sanitizer 运行记录。

## 原记录保留与最终包状态

A 是同一 `T7-control11` 实现的新 run，目录名与版本名分开。登记使用 TRSM 专用无哈希工具的显式 `--repeat-existing`，在 T8 晋级前核对了 T7 仍是已通过且已晋级的当前 best、`parent=null`，四份源码与旧快照及当时 TRSM 主源码逐字节相同。新测量全部通过后，初测旧记录的完整字节已独占保存到 `.runs/trsm/T7-control11-repeat-r5/prior-record.json`，最新 T7 记录的 `previous_runs` 保存其引用，原 run 和证据没有被覆盖；策略、源码来源、创建时间及初次晋级时间保留。

因此，最新 `T7-control11` 台账指向 **1576028 / NUMA 2 / 508.56 ms**，本文初测段及 `prior-record.json` 保存 **1576015 / NUMA 3 / 508.80 ms**。两个 T8 只使用前者计算收益。该登记流程在新测量失败时会保存 `repeat-attempt.json` 并保留原通过记录。

最终 ZIP 为 **11740 bytes**，作业 **1576076 SUCCEEDED**；独立解压三轮9/9 PASS，真实KML与私有OpenMP依赖审计通过，最大误差1.11e-15。详细数据见[最终交付](trsm-final-20260912-r5.md)。

按用户要求，本轮不计算或验证源码哈希；保留源码快照、实际编译与运行环境、完整命令、逐用例样本、依赖映射、退出码和调度器日志，并使用本地直接字节比较。没有把这种留痕方式称为远程源码身份或传输完整性验证。

台账见 [T7-control11](../records/experiments/trsm/T7-control11.json)、[T8-svepanel16](../records/experiments/trsm/T8-svepanel16.json) 和 [T8-paneloutline](../records/experiments/trsm/T8-paneloutline.json)。公开证据已脱敏归档至 [本轮证据清单](../records/evidence/trsm-stage-r5-20260912/ARCHIVE.json)，包括：

- [初测 1576015 的原始记录](../records/evidence/trsm-stage-r5-20260912/members/T7-control11/record-for-original-run.json)。
- 同作业官方原始日志：[T7 repeat](../records/evidence/trsm-stage-r5-20260912/members/T7-control11-repeat-r5/nohash-recorded-evidence/benchmark.log)、[T8-svepanel16](../records/evidence/trsm-stage-r5-20260912/members/T8-svepanel16/nohash-recorded-evidence/benchmark.log)、[T8-paneloutline](../records/evidence/trsm-stage-r5-20260912/members/T8-paneloutline/nohash-recorded-evidence/benchmark.log)。
- 真实比较判定：[T8-svepanel16](../records/evidence/trsm-stage-r5-20260912/cohorts/compare/T7-control11-vs-T8-svepanel16.json)、[T8-paneloutline](../records/evidence/trsm-stage-r5-20260912/cohorts/compare/T7-control11-vs-T8-paneloutline.json)。
- [T8-svepanel16 预检实际计数](../records/evidence/trsm-stage-r5-20260912/cohorts/compare/diagnostics/preflight-results/T8-svepanel16/completion.txt)及同目录逐项日志。

工作区保留未脱敏原始日志及各成员的不可覆盖快照；公开报告不包含账户、主机地址或私人目录信息。

最终包作业 **1576076 SUCCEEDED**，三轮9/9 PASS，详细数据与版本范围见[最终交付](trsm-final-20260912-r5.md)。
