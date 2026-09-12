# CONV 2026-09-12 第六轮：共享单列循环与算子编译调优

**正式最佳仍为 C6 = C26-r1，源码来源 C26-row4loads。** 继续使用[已发布的 C6 原包](https://github.com/Palm0palM/kunpeng-s2/blob/b5ef7ea27958b1531feadf3cc50f66a23c3a02f4/conv/result/C6/conv.zip)。本轮唯一五成员性能作业1579528已完成并验收：同一调度分配内15个完整套件、60/60官方case PASS，最大误差0。C37为459.55 ms，C39为459.75 ms，均慢于主要关闭C6对照452.41 ms；C38构建归因对照为452.34 ms，不具备晋级角色。本轮没有合格的新最佳，不产生新提交包。

三包专项已冻结通过152688项，C38/C39另有8个原runner结果PASS；这些均与上述60个性能结果分开计数。本页另归档两次未获得算子数据的早期C6采样尝试，后续采样使用独立作业和记录。

## 方案与来源

| 版本 | 源码父版本 | 单一变更/角色 | 原始假设和限制 |
| --- | --- | --- | --- |
| C37-row4u1 | C26-row4loads | 保持四行×4VL，只将quad共享中段从kw双列展开改成原单列体遍历所有kw | 或可降低活跃权重/输入/临时量，但增加循环控制；原六个首尾阶段及其它helpers/runner不变 |
| C38-splitbuild | C26-row4loads | 将原一次编译链接拆成benchmark对象、算子对象、链接三个命令；只作构建归因对照，不可晋级 | 公共flags/宏/OMP、对象顺序及LINK_FLAGS原样保留；拆分命令不等于已证明二进制相同 |
| C39-tunehip11 | C26-row4loads | 使用C38布局，仅算子对象编译增加固定-mtune=hip11 | 可能改变调度/代价模型；benchmark和链接不加tune，不增加全局native ISA。参数不接受或实际target查询非hip11即停止，无generic tune回退 |

C37每输出仍按kernel行列顺序独立乘、加，不拆分累加链；kw=1沿用原单列行为，kh<4及余行/余列回退不改。旧单行或不同向量数版本的成绩仅作历史背景，不能替代本候选的同环境测量。

C38/C39的conv2d.c、benchmark和源码README与C26原字节一致。静态检查表明公共严格浮点参数、两个CONV宏、OMP参数、benchmark在前/算子在后的链接次序、原LINK_FLAGS、独立RUN_DIR、38线程上限和原官方case/PASS验收均保留。C39相对C38只有算子编译行的-mtune=hip11；两者真实构建日志及实际对象均已验收，C39本轮target查询明确返回hip11，正确性依据来自本轮实际生产对象而非旧native查询。

## 专项进度与计数边界

六配置统一为1/4线程×SVE 16/32/64字节。C37/C38/C39均已完整冻结；专项、原runner验收和正式性能套件分别计数。

| 候选/作业 | 生产/普通guard | 单独插桩dispatch | 专项total_cases | 原runner单独验收 | combined_validation_cases | 当前状态 |
| --- | --- | --- | ---: | ---: | ---: | --- |
| C37-row4u1 / 1579460 | 18052 full×6 | 96 smoke×6 | 108888 | 本包不另执行 | 108888 | 已冻结，全部PASS |
| C38-splitbuild / 1579469 | 实际生产对象guard smoke96×6 | 不执行 | 576 | 原四case一次，4/4 PASS | 580 | 已冻结，全部PASS |
| C39-tunehip11 / 1579482 | 实际生产对象guard full7108×6 | 96 smoke×6 | 43224 | 原四case一次，4/4 PASS | 43228 | 已冻结，全部PASS |

C37冻结validation为complete=true/status=passed，SUCCEEDED且job/system/wrapper退出均0，自动传输manifest与远端源码对应。六配置各18052 full+96 smoke全部通过，每配置实际pair/triple/quad入口为48/96/96。实际共享单列.L342为48指令：16 FMUL、16独立FADD、4输入加载和4系数广播，无spill/EXT/MOVPRFX；全源码FMA为0。其它六个阶段仍每次双列32/55/75/75/55/32指令，整个quad无Z/Q栈溢出或额外VL空间，576 B固定栈帧的d8–d11保存属于ABI。48指令处理一列，C6的93指令处理两列，不能仅比较原始条数而声称加速。

C38冻结validation为complete=true/status=passed，SUCCEEDED且job/system/wrapper退出均0，15个包装阶段均退出0，自动manifest一致。原run.sh真实执行三个BUILD_COMMAND，benchmark和算子各自严格编译、原次序链接且保留-lm，未添加tune；四个原case全部PASS。随后独立未tune的guard链接该runner真正生成的conv2d.o，六配置各96项全部通过；未运行dispatch，不声称有本包插桩入口结果。

C38实际生产对象反汇编和同生产flags的.s分别验收：共享双列93指令，32 FMUL、32独立FADD、8输入加载、8系数广播，无主循环栈访问/EXT/MOVPRFX/FMA。七阶段32/55/75/93/75/55/32，整个quad无Z/Q栈溢出或额外VL空间，752 B固定栈帧及d8–d11为ABI保存。这确认构建与该诊断的正确性；C38仍仅作归因对照，单次runner时间不构成三套件性能记录。

C39冻结validation为complete=true/status=passed，作业1579482 SUCCEEDED且job/system/wrapper与全部包装阶段退出均0，自动manifest一致。实际BUILD_COMMAND确认只有conv2d.o编译增加-mtune=hip11，benchmark、独立guard reference及链接均未tune；target-query返回hip11，没有fallback。原run.sh四case全部PASS，实际生产对象guard共42648项及单独插桩dispatch共576项全部PASS，每配置7108+96，专项合计43224。每配置实际pair/triple/quad入口为48/96/96，生产对象检查和插桩入口检查分别保留。

C39实际conv2d.o反汇编和生产.s均已审查：共享双列仍93指令、32 FMUL+32独立FADD、8输入加载+8系数广播，无主循环栈访问/EXT/MOVPRFX/FMA；七阶段计数仍32/55/75/93/75/55/32。整个quad无Z/Q栈溢出或额外VL空间，752 B固定帧及d8–d11保存属于ABI。与C38相比，部分地址ADD、第二次输入LD1W调度前移，整数寄存器分配也改变，说明实际codegen存在差异；相同操作数目不等于完整机器码相同，调度改变也不构成提速结论。

C39每配置7108项为原3268基础项，加24原边界宽度×8核×5输出高度×4放置方式=3840项。八核为(4,1)/(4,2)/(4,3)/(4,4)/(7,7)/(7,8)/(8,7)/(8,8)，五输出高度为2/3/4/5/16。原smoke96和strict有序逐位reference、guard pages、只读input/kernel、输出NaN/canary、worker VL检查保留。

C38/C39先在38CPU单NUMA分配中直接执行原runner完整四case，并保留真实BUILD_COMMAND、环境和每case日志；随后将**runner真正生成的conv2d.o**链接到独立、未tune的strict guard对象。C39的tune插桩dispatch另含源码，只检查实际入口，不是生产对象，也不将插桩速度当性能。实际对象反汇编、同生产flags的.s、target-query和每阶段退出分别保存。任何编译/链接/日志或case失败都停止，不静默换参数继续。

**三包已冻结通过152688项专项（108888+576+43224），另有C38/C39各4个runner结果，共8项PASS；组合验收152696项全部完成。** 此数量不包含本轮另外完成的15个性能套件、60个官方case结果。原runner的一次四case验收不是后续三个独立套件性能记录。C38不要求不存在的dispatch日志，不借旧入口检查补写通过。没有sanitizer结果。

## 采样故障与事件支持记录

本页归档的两次早期C6采样尝试均已保留原始证据，但**没有取得可解释的CONV热点样本或算子CPI**：

| 尝试 | 实际结果 | 范围与判定 |
| --- | --- | --- |
| 原1579436（[RESULT](../records/evidence/conv-profile-sep12/RESULT.md) / [validation](../records/evidence/conv-profile-sep12/validation.json)） | FAILED；job退出1、system退出10001、wrapper退出1 | NUMA cpulist中空项触发`ValueError: invalid literal for int() with base 10: ''`；发生在编译、benchmark和perf之前，不能计任何算子测试或采样结果 |
| 独立r1 / 1579456（[RESULT](../records/evidence/conv-profile-sep12-r1/RESULT.md) / [validation](../records/evidence/conv-profile-sep12-r1/validation.json)） | 调度SUCCEEDED、job/system/wrapper退出均0，但实际perf record退出255 | 已确认38CPU单NUMA和GCC10.3.1；带`-C` CPU筛选的采样命令在paranoid=2下被权限拒绝。benchmark.log为空，没有符号/annotate报告或quad样本 |

r1远端分类器因未匹配拒绝措辞保留inconclusive，复核记录将这条确切采样命令判为unsupported；原日志未改。它不能推出所有task-only perf调用都不可用，也不能因为wrapper退出0就称profile通过。没有修改权限或sysctl。

C38作业1579469中额外执行的仅当前子进程探针为`perf record -e cycles:u -F 99 -m 128 -T -P -o task-perf-probe.data -- /bin/true`，没有`-C`或全系统选项。原退出文件为0，stderr报告捕获5 samples、写入0.006 MB。**这仅证明该次task-only事件打开/记录成功；样本来自/bin/true，不是CONV数据，不进入正确性或性能计数。** 不能据此填写cache-miss、热点位置或收益。

原C6采样设计只包已编译ELF的第四case，且包括初始化、参考计算及校验/预热/计时中的算子调用；后续采样应区分全进程分母与quad内部period分母，检查有效样本和丢样/限频。cycles采样有skid，不能将单条指令占比当精确延迟或缓存因果。这两次尝试没有算子采样结论，采样时可能打印的耗时也不能进入正式性能表或晋级。

原perf.data/ELF及可能含地址路径的原始报告仅作私有证据，公开说明使用经过整理的必要文本。两次失败保留各自job与日志，不覆盖为后续成功状态。

## 五成员正式性能结果（1579528已完成）

作业1579528已SUCCEEDED，job/system退出均0，五成员wrapper退出均0。campaign状态为performance_complete；五份记录均status=passed、verified=true，调度、回收日志、benchmark、wrapper、源码一致性和机器环境检查均通过。预先固定的执行顺序如下，每成员连续执行三个独立完整套件，共15套件、60/60 PASS，所有打印最大误差及逐case记录最大误差均为0。主要关闭基线始终为C26-r11，开场C26-r10用于交叉检查。

各成员使用同一计算节点、38CPU单NUMA分配，GCC10.3.1、CPU_TARGET=generic、OMP_NUM_THREADS=38、OMP_DYNAMIC=FALSE、OMP_PROC_BIND=close、OMP_PLACES=cores；内存申请24576 MiB、时限1800秒。五份记录的job、settings、environment、官方内置reference和三次重复数一致后才写入比较结果。严格浮点、原benchmark、官方每case验收及资源条件保留；C38/C39的分对象构建以及C39算子对象的tune是明确记录的实验变量。

A/B/C/D依次为4096×6144/核39×39、6144×4096/核41×41、4256×6390/核55×55、6390×4256/核81×81。下表各case是三个独立完整套件打印时间的中位数；“合计”为四个中位数之和，是内部比较指标，不是官方分数。单项波动定义为(max−min)/median×100%，最大波动为四case中的最大值。

| 顺序 | 版本 / 证据 | A中位数ms | B中位数ms | C中位数ms | D中位数ms | 合计ms | 最大单项波动 | 角色 / 结果 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | C26-r10（[记录](../records/experiments/conv/C26-r10.json) / [原日志](../records/evidence/conv-C26-r10/benchmark.log)） | 51.40 | 61.95 | 107.34 | 231.73 | 452.42 | 0.0973% | 原C6开场控制 |
| 2 | C37-row4u1（[记录](../records/experiments/conv/C37-row4u1.json) / [原日志](../records/evidence/conv-C37-row4u1/benchmark.log)） | 52.82 | 62.54 | 109.32 | 234.87 | 459.55 | 1.6469% | 候选；不合格 |
| 3 | C38-splitbuild（[记录](../records/experiments/conv/C38-splitbuild.json) / [原日志](../records/evidence/conv-C38-splitbuild/benchmark.log)） | 51.40 | 61.92 | 107.31 | 231.71 | 452.34 | 0.1615% | 仅构建归因对照，不晋级 |
| 4 | C39-tunehip11（[记录](../records/experiments/conv/C39-tunehip11.json) / [原日志](../records/evidence/conv-C39-tunehip11/benchmark.log)） | 52.25 | 62.76 | 109.08 | 235.66 | 459.75 | 0.2750% | 候选；不合格 |
| 5 | C26-r11（[记录](../records/experiments/conv/C26-r11.json) / [原日志](../records/evidence/conv-C26-r11/benchmark.log)） | 51.43 | 61.97 | 107.32 | 231.69 | 452.41 | 0.9843% | 原C6主要关闭基线 |

逐case波动保留如下，避免用合计掩盖单项变动。

| 版本 | A波动 | B波动 | C波动 | D波动 |
| --- | ---: | ---: | ---: | ---: |
| C26-r10 | 0.0973% | 0.0807% | 0.0186% | 0.0518% |
| C37-row4u1 | 0.1704% | 1.6469% | 0.1281% | 0.0255% |
| C38-splitbuild | 0.1362% | 0.1615% | 0.0746% | 0.0777% |
| C39-tunehip11 | 0.1722% | 0.1115% | 0.2750% | 0.0891% |
| C26-r11 | 0.0778% | 0.9843% | 0.0186% | 0.0518% |

以下15行按真实执行顺序保留全部60个时间样本，单位ms；每行依次为该完整套件原日志的A/B/C/D打印值。三套件不等于benchmark内部TEST_RUNS，也不把打印时间解释成单次kernel调用原始计时。没有删除慢样本或挑选最快套件。

| 全组套件顺序 | 版本 | 该版本套件 | A | B | C | D |
| ---: | --- | ---: | ---: | ---: | ---: | ---: |
| 1 | C26-r10 | 1 | 51.40 | 61.91 | 107.34 | 231.73 |
| 2 | C26-r10 | 2 | 51.40 | 61.95 | 107.32 | 231.69 |
| 3 | C26-r10 | 3 | 51.45 | 61.96 | 107.34 | 231.81 |
| 4 | C37-row4u1 | 1 | 52.76 | 62.52 | 109.32 | 234.83 |
| 5 | C37-row4u1 | 2 | 52.85 | 62.54 | 109.28 | 234.87 |
| 6 | C37-row4u1 | 3 | 52.82 | 63.55 | 109.42 | 234.89 |
| 7 | C38-splitbuild | 1 | 51.40 | 61.92 | 107.30 | 231.80 |
| 8 | C38-splitbuild | 2 | 51.47 | 61.91 | 107.31 | 231.62 |
| 9 | C38-splitbuild | 3 | 51.40 | 62.01 | 107.38 | 231.71 |
| 10 | C39-tunehip11 | 1 | 52.18 | 62.78 | 109.00 | 235.66 |
| 11 | C39-tunehip11 | 2 | 52.27 | 62.76 | 109.08 | 235.48 |
| 12 | C39-tunehip11 | 3 | 52.25 | 62.71 | 109.30 | 235.69 |
| 13 | C26-r11 | 1 | 51.43 | 62.54 | 107.30 | 231.69 |
| 14 | C26-r11 | 2 | 51.39 | 61.97 | 107.32 | 231.79 |
| 15 | C26-r11 | 3 | 51.43 | 61.93 | 107.32 | 231.67 |

C37的B第三套63.55 ms、关闭C6的B第一套62.54 ms等较慢打印值均保留在上述原序列，并纳入中位数与波动。记录只能确认这些时间变动；本轮没有可用于解释其硬件原因的CONV采样数据。

预先规则要求总改善超过max(1%,双方实际最大单项波动)，没有任何case退化超过1%，且开场控制支持同一结论。C39另须通过同allocation的C38构建归因对照。下表“改善”=(对照合计−候选合计)/对照合计；负值表示候选更慢，逐case改善来自正式comparison字段。

| 候选 | 对照 | 合计改善 | A / B / C / D改善 | 本对照门槛 | 正式比较结论 |
| --- | --- | ---: | --- | ---: | --- |
| C37-row4u1 | C26-r11 | -1.5782% | -2.7027% / -0.9198% / -1.8636% / -1.3725% | 1.6469% | 不合格；合计退化，且有单项退化超过1% |
| C37-row4u1 | C26-r10 | -1.5760% | -2.7626% / -0.9524% / -1.8446% / -1.3550% | 1.6469% | 不合格；合计退化，且有单项退化超过1% |
| C38-splitbuild | C26-r11 | +0.0155% | +0.0583% / +0.0807% / +0.0093% / -0.0086% | 1.0000% | 不达门槛；仅参照 |
| C38-splitbuild | C26-r10 | +0.0177% | +0.0000% / +0.0484% / +0.0279% / +0.0086% | 1.0000% | 不达门槛；仅参照 |
| C39-tunehip11 | C26-r11 | -1.6224% | -1.5944% / -1.2748% / -1.6400% / -1.7135% | 1.0000% | 不合格；合计退化，且有单项退化超过1% |
| C39-tunehip11 | C26-r10 | -1.6202% | -1.6537% / -1.3075% / -1.6210% / -1.6959% | 1.0000% | 不合格；合计退化，且有单项退化超过1% |
| C39-tunehip11 | C38-splitbuild | -1.6381% | -1.6537% / -1.3566% / -1.6494% / -1.7047% | 1.0000% | 不合格；合计退化，且有单项退化超过1% |

C37相对关闭C6慢1.58%，开场比较同样退化；将共享双列展开改为单列循环没有取得本组性能收益。C39相对关闭C6慢1.62%、相对同构建C38慢1.64%，三个对照均不合格，不能将已观察到的codegen调度变化称为优化成功。C38相对两端C6的合计差异均不足0.02%，没有超过最低1%门槛，且按预先定义仅作构建归因参照。

C39与C38的benchmark编译flags、链接参数和公共严格浮点条件一致，唯一被测调优参数是conv2d.o的-mtune=hip11；实际构建命令已验收。此对照避免把分对象构建变化与tune混为一项。结论限于本组测量，不能仅据汇编调度次序推断缓存或执行吞吐瓶颈，也未拼接其它allocation的有利样本。

## 留痕与下一步

本轮性能记录与比较已全部完成，C37、C38、C39的qualified_for_confirmation均为false。正式最佳和提交包继续保持C6，没有晋级C7，也没有生成本轮候选提交ZIP。保留本轮源码、构建命令、专项汇编结论、全部性能样本以及采样失败证据；后续新候选须单独通过专项与同环境性能对照。符合门槛的新源码还需独立确认及最终原ZIP超算复验，才考虑晋级。

编译拒绝参数、数值失败、退化、无变化、超时或采样不可用均按真实版本、作业与原因留痕。不删慢样本，不事后换基线，不将诊断、原runner验收或/bin/true探针计入正式性能。本轮所有题目编译、测试、性能和profile均在调度计算节点执行；本机只编辑整理，没有本机题目编译或测试，没有使用重置卡。官方提交仍由队友手动操作，官方分数和反馈未知。
