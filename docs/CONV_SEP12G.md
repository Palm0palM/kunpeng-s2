# CONV 2026-09-12 第七轮：多行块形状、显式调度与 C6 采样

**正式最佳仍为 C6 = C26-r1，源码来源 C26-row4loads。** 继续使用[已发布的 C6 原包](https://github.com/Palm0palM/kunpeng-s2/blob/b5ef7ea27958b1531feadf3cc50f66a23c3a02f4/conv/result/C6/conv.zip)。F轮性能已完成且没有合格候选；本轮C40/C41已完成专项验证；C42在目标编译器上失败，协调者已明确将性能组缩减为两项纯C候选加两端C6控制。四成员性能作业1579643已完成，12套件48/48 PASS、最大误差0。C40为444.40 ms，比关闭C6控制452.45 ms少1.7792%，但未超过两端控制的实际波动门槛；C41为471.53 ms，慢4.2170%。两候选的资格均为false，本轮不晋级、不生成新提交包。

C40作业1579597与C41作业1579607均已SUCCEEDED、job/system/wrapper退出0，专项分别26112和27408项全部PASS，累计53520项冻结通过。C42作业1579627在首个生产guard编译阶段被GCC10.3.1拒绝`%Z`操作数前缀，0项数值测试、没有生产汇编。失败原件保留，不改成通过，也不自动重试。独立C6 profile r2作业1579588已完成复核，取得可归属quad的2666个样本；它是诊断证据，不是本轮正式性能测量。

## 候选及对照关系

| 候选 | 源码父版本 | 唯一方案 | 当前可确认范围 |
| --- | --- | --- | --- |
| C40-row6x3u1 | C26-row4loads（C6） | 新增六输出行×3VL、18累加器、单kernel列循环；完整保留原C6 helpers，六行分派及余行回退 | 专项26112 PASS、十一阶段汇编已冻结；正式444.40 ms，双控制波动门槛未通过 |
| C41-row5x5u1 | C33-row5x4u1（历史实验，非正式最佳） | 纯C五输出行helper由4VL扩至5VL、25累加器；保持单列循环、五行分派和其它helpers | 专项27408 PASS、九阶段汇编已冻结；正式471.53 ms，比关闭C6慢4.2170% |
| C42-row5x5asm | C41-row5x5u1（同形状纯C对照） | 仅五行共享中段的五个输入scope改成显式五对独立FMUL/FADD，各复用一个scratch，带memory编译器屏障 | 目标GCC10编译失败，0项数值测试；明确排除出本轮性能，原源码保留 |

C40增加同一输入对六行输出的复用，但横向块变窄、系数广播与循环回跳摊销、首尾阶段数量和OMP组数也改变，净效果必须看同组正式测量，不能从输入复用量单独推出收益。C41在同一五行形状扩大横向块，可能分摊权重及控制开销；25累加器+5系数+1输入+1乘积的源级估算已占32个向量值，没有名义余量，不能据此预判真实spill或速度。G轮没有新C33同轮控制，因此不得把C41对C6的差值单独归因为4VL到5VL。

C42原方案包含五个`+&w`累加器、一个`=&w` scratch、六个`w`输入和`%Z`模板；目标GCC10现已实际拒绝`%Z`，因此没有可供分析的寄存器分配。`memory`仅是编译器屏障；该方案同时约束片段内乘加顺序和片段间内存调度，原计划C42/C41差值只能讨论这个整体方案，不能分别归因；本轮因编译失败根本没有该性能比较。其它八个首尾阶段、完整5VL条件、尾部、分派与非SVE路径保持C41。源级静态审查不等于实际模板接受或无spill保证。

三候选均保持每个输出自身kernel行、列递增顺序，使用独立乘法和加法，不拆部分和、不引入FMA或fast-math。C40的kh<6、余1..5行及3VL列尾使用原helpers；C41/C42的kh<5、余1..4行及5VL列尾保持原回退。生产benchmark、run.sh及源码README沿用各自源父原件；检查插桩与生产翻译单元分离。

本地归档标识：各候选的`.runs/conv/<版本>/PLAN.md`、`STATIC_REVIEW.md`及`records/experiments/conv/<版本>.json`。checkpoint记录的conv2d.c SHA如下，仅转录已有记录，没有新增哈希审计：

| 候选 | checkpoint源码SHA256 |
| --- | --- |
| C40-row6x3u1 | `cb471782329b01b9bf72d6e992941edde1361d19ced2bb69a576ec5fa8ee69e7` |
| C41-row5x5u1 | `ca50684addef168079d4f960df721f5af195b20b3b021ff0eb7c47ec42692a95` |
| C42-row5x5asm | `cbdadacaa24a28f2eff0b9d01810ccae69ddc127da22942f30b15a6713265def` |

## 专项计划与实际进度

六配置为SVE 16/32/64字节×1/4线程。每配置分别执行未插桩生产full、真实分派入口dispatch、强制防御回退direct；使用strict逐位reference、只读input/kernel、分配边界guard pages、输出poison/canary及实际worker VL检查。四线程检查还要求所有四worker入口mask=15。下表矩阵列保留原计划数，状态列记录实际通过或编译失败。C40/C41六配置的生产full、dispatch和direct均已全部通过；C42原计划27408项没有执行。

| 候选 | full/config | dispatch/config | direct/config | 六配置预计总数 | 预计dispatch/direct入口数（每配置） | 调度 / 验收状态 |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| C40 | 3560 | 432 | 360 | 26112 | 432 / 900 | 1579597 SUCCEEDED；26112项已冻结PASS |
| C41 | 3776 | 504 | 288 | 27408 | 528 / 720 | 1579607 SUCCEEDED；27408项已冻结PASS |
| C42 | 3776 | 504 | 288 | 27408 | 528 / 720 | 1579627编译失败；实际0项、无入口结果 |

C40重点覆盖3VL/6VL前后、kh5/6/7、kw1及奇偶、六行组余1..5行和oh24四worker；direct强制kh1..5防御分支。C41及原C42计划使用相同27408项矩阵，覆盖4VL..5VL尾列、5VL/10VL前后、kh4/5/6、五行组余1..4行及oh20四worker；direct强制kh1..4。真实入口计数在每case完成及OMP join后核对，不能只凭函数存在或静态模板推断覆盖。

实际汇编验收必须覆盖C40十一阶段、C41/C42九阶段及各转场、整个helper栈访问，追踪间接栈地址并区分ABI D寄存器保存与Z/Q spill；整源码FMA计数单独检查。C42原计划还要求确认五个实际asm块、具体输入/累加器/scratch的互斥与累加顺序；因编译失败未取得该项证据，不能预写通过。接受规则不要求零spill；有spill如实记录，不能拿理论计数替代返回汇编。

本地归档标识为`.runs/conv/sep12g-checks/<版本>/`下的`job.json`、`raw/`、`assembly-review.json`及`validation.json`；全部验收通过才冻结到各实验的`sve-correctness-sep12g/`。原三候选流程因C42失败停止；协调者已明确批准缩减为C40/C41，四成员顺序在性能提交前固定，C42失败留在excluded_diagnostics而不抹除。

C40冻结validation为status=passed、complete=true，GCC10.3.1；生产full共21360、dispatch共2592、direct共2160，合计26112。六配置每项均通过，每配置真实rowsix入口dispatch=432、direct=900；单线程mask=1、四线程mask=15。旧prefix/tail/pair/triple/quad入口也均实际大于0。传输manifest对应、原始构建命令、参考及日志逐项验收；没有sanitizer或性能结论。冻结归档为`.runs/conv/C40-row6x3u1/sve-correctness-sep12g/`。

C40实际未插桩生产汇编的十一阶段均按单kernel列计数：

| 阶段 | 指令数 | FMUL / FADD | 输入LD1W / 系数LD1RW | 向量spill load / store |
| --- | ---: | --- | --- | --- |
| input_0 | 14 | 3 / 3 | 3 / 1 | 0 / 0 |
| input_1 | 23 | 6 / 6 | 3 / 2 | 0 / 0 |
| input_2 | 31 | 9 / 9 | 3 / 3 | 0 / 0 |
| input_3 | 39 | 12 / 12 | 3 / 4 | 0 / 0 |
| input_4 | 47 | 15 / 15 | 3 / 5 | 0 / 0 |
| shared | 55 | 18 / 18 | 3 / 6 | 0 / 0 |
| trailing_0 | 47 | 15 / 15 | 3 / 5 | 0 / 0 |
| trailing_1 | 39 | 12 / 12 | 3 / 4 | 0 / 0 |
| trailing_2 | 31 | 9 / 9 | 3 / 3 | 0 / 0 |
| trailing_3 | 23 | 6 / 6 | 3 / 2 | 0 / 0 |
| trailing_4 | 14 | 3 / 3 | 3 / 1 | 0 / 0 |

共享内循环.L405实际为汇编6129..6183行。整个rowsix及阶段转场均没有Z/Q spill，固定528 B栈帧，d8在sp112的保存/恢复属于ABI；地址和计数器的标量栈保存另行区分，也追踪了间接栈地址。所有阶段EXT/MOVPRFX均0，整源码FMA为0。这里的55条指令处理18个输出向量的一列，不能直接拿C6的93条双列指令相除当作速度提升。

C40同一诊断作业内的可选只读硬件元数据采集退出0，以下为系统报告的默认SVE长度及首个已分配CPU的cache几何，所有列出的读取均成功：

| 项目 | 容量 / 默认长度 | cache line | sets | ways |
| --- | --- | ---: | ---: | ---: |
| 默认SVE vector length | 64字节（512 bit） | — | — | — |
| L1 Data | 32K | 64字节 | 64 | 8 |
| L1 Instruction | 32K | 64字节 | 128 | 4 |
| L2 Unified | 768K | 64字节 | 1024 | 12 |

归档为冻结目录`raw/hardware-metadata.log`及validation中的hardware_metadata。此处转录实际sysfs值，不依据机型名称补推全平台配置；默认64字节不替代专项实际16/32/64字节六配置的worker验证。cache几何不是cache-miss或访存延迟计数，也不能解释profile的LD1RW采样集中现象；该可选元数据不是正确性通过门槛。


## C41通过与C42编译失败

C41冻结validation为status=passed、complete=true；生产full22656、dispatch3024、direct1728，合计27408。六配置均通过，每配置真实quint入口dispatch=528、direct=720，单线程mask=1、四线程mask=15；旧helpers入口均大于0。作业1579607的调度、源码传输、编译参数、逐位reference和guard证据均已验收。冻结归档为`.runs/conv/C41-row5x5u1/sve-correctness-sep12g/`。

实际未插桩quint九阶段每单列指令数为20/33/45/57/69/57/45/33/20，对应input_0..3、shared、trailing_0..3。共享.L417（6378..6446行）69条指令：25 FMUL、25独立FADD、5输入LD1W、5系数LD1RW。所有阶段EXT/MOVPRFX均0，整源码FMA为0；全部九阶段、转场与整个helper均无Z/Q spill。固定640 B栈帧，d8..d15低64位保存/恢复属于ABI。

这里GCC选择保留五个输入向量，按输出行加载系数，复用z13作系数及末向量乘积、z15作其它乘积；25个累加器均在Z寄存器。实际没有将五个系数同时保留，因此不能从源级寄存器预算推断必然溢出。它也不能证明C41会更快；本轮同allocation实际471.53 ms，比关闭C6控制慢4.2170%。

C42冻结validation为status=failed、complete=false，failure_stage=build-production-guard。作业1579627 FAILED，job退出1、system退出10001、wrapper退出1；GCC10.3.1在五个asm块中报告invalid operand prefix `%Z`。源码传输manifest已对应，原候选未修改。生产full、dispatch、direct均0，configurations为空；生产.s未生成，spill、FMA及具体寄存器约束没有可填的实际结果。不得用C41的汇编或静态模板替代C42证据。冻结归档为`.runs/conv/C42-row5x5asm/sve-correctness-sep12g/`。

这项失败证明当前模板未被目标工具链接受，不能概括为所有SVE内联汇编不可行。当前任务保留失败，不修原候选、不重试、不生成C42性能记录，也不声称获得asm收益。

## C6 profile r2：实际取得的证据

证据：[profile结果](../records/evidence/conv-profile-sep12-r2/RESULT.md)、[本地复核分析](../records/evidence/conv-profile-sep12-r2/profile-analysis.json)、[验证范围](../records/evidence/conv-profile-sep12-r2/validation.json)、[原远端分类](../records/evidence/conv-profile-sep12-r2/raw/profile-status.json)与[实际注释](../records/evidence/conv-profile-sep12-r2/raw/quad.annotate.txt)。这些公开文本由本地`.runs/diagnostics/conv-profile-sep12-r2/`脱敏导出；原件继续保留。

作业1579588已SUCCEEDED，job/system/wrapper退出均0，原官方第四case打印1个PASS；record、report-all、report-quad、annotate、objdump工具退出均0。编译器为GCC10.3.1，原C6编译前缀和严格浮点flags保持，源码传输manifest及符号/ELF地址映射已核实。最终本地复核记录为status=reviewed、complete=true、review_complete=true；**该状态仅表示本次profile证据复核完成，不是候选性能通过或晋级。**

| 观测 | 实际值 | 分母 / 含义 |
| --- | ---: | --- |
| 事件 / 频率 | cycles:u / 99 Hz | task-only周期采样 |
| 全次record样本 | 38266 | 含参考计算及算子等整个被采样进程 |
| 可归属conv_sve_rowquad的样本 | 2666 | report与annotate均明确给出该数量 |
| lost samples | 0 | 本次记录报告的丢样数 |
| quad事件period占比 | 6.75% | 全进程采样period分母 |
| 官方reference事件period占比 | 93.10% | 同一全进程分母；不是算子比例、CPI或优化指标 |
| quad共享双列主循环 | 约92.90% | 仅quad内部注释行的local period比例之和 |
| 主循环首LD1RW指令IP | 25.25% | quad内部local period归属到该采样IP的位置；不是该指令延迟 |

共享双列循环对应本次ELF的`0x4055f8..0x405768`，实际93条指令，其中32 FMUL、32独立FADD；首LD1RW位于`0x405604`。注释各行百分比已经四舍五入，总和为100.11%，所以92.90%只是近似值。样本数与period占比采用不同计数，不能将2666/38266当作6.75%的替代计算。

原远端分类器仍保留inconclusive：其正则未容许report符号后新增的IPC尾列，因而漏匹配。此次本地复核以原report、annotate中的2666样本、各工具退出和ELF符号映射为依据修正“是否取得可归属quad数据”的判定；原始分类文件和日志未覆盖，也没有将尾列解释成已测得的算子CPI。

符号过滤后的quad样本混合了官方第四case的校验、预热及计时调用，没有分离纯计时区域。低频cycles采样存在IP skid与归属偏差；25.25%的LD1RW只说明采样IP集中于此，不能证明cache miss代价、权重广播瓶颈或指令延迟。此次没有收集instructions/cache-miss/stall事件，不提供算子CPI或硬件吞吐因果结论。全进程93.10%的reference占比也不能用于解释算子内部瓶颈。

本次证据支持把quad共享主循环作为后续分析和优化的重点区域，但不足以选定某种缓存或调度方案。perf下打印的249.79 ms仅作诊断，绝不计入正式性能表、同allocation比较或晋级。该1个case PASS同样不计入G三候选专项或正式性能套件。

## 四成员正式性能结果（1579643 已完成）

原五成员计划因C42编译失败停止；协调者依据冻结证据明确批准并在提交前固定新顺序：C26-r12 → C40-row6x3u1 → C41-row5x5u1 → C26-r13。C42失败1579627作为显式排除依据保留。没有自动删失败或重排已运行的样本。

作业1579643为SUCCEEDED，job/system退出均0、四成员wrapper均0；campaign为performance_complete，四份正式record均status=passed、verified=true、repeats=3且全部checks=true。四成员在同一allocation、相同CPU/NUMA分配和GCC10.3.1下各运行三个完整官方套件，合计12套件、48/48 PASS，所有逐case最大误差均0。保留原benchmark和reference、strict FP、CPU_TARGET=generic、38线程、OMP_DYNAMIC=FALSE、OMP_PROC_BIND=close、OMP_PLACES=cores。未将专项、profile或runner探测算入性能。

A/B/C/D依次为输入4096×6144/核39×39、6144×4096/核41×41、4256×6390/核55×55、6390×4256/核81×81。每个样本是官方程序一次完整套件打印的Time(ms)；合计为四case各自三样本中位数之和，波动为(max−min)/median。它们是内部耗时指标，不是官方分数。

| 顺序 / 成员 | A中位数 | B中位数 | C中位数 | D中位数 | 中位数合计 ms | 最大case波动 | 相对关闭C6耗时减少 | 资格 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1. C26-r12（开场C6控制） | 51.44 | 61.92 | 107.32 | 231.90 | 452.58 | 3.4399% | — | 控制 |
| 2. C40-row6x3u1（六行×3VL） | 50.42 | 60.30 | 107.36 | 226.32 | 444.40 | 0.1190% | +1.7792% | false |
| 3. C41-row5x5u1（五行×5VL） | 53.84 | 62.94 | 113.64 | 241.11 | 471.53 | 0.2043% | -4.2170% | false |
| 4. C26-r13（预先关闭C6控制） | 51.47 | 61.97 | 107.29 | 231.72 | 452.45 | 1.9623% | — | 控制 |

全部48个样本按实际成员顺序及成员内套件顺序列出，不排序、不剔除异常值；每行四项均PASS、最大误差0：

| 成员 | 套件顺序 | A ms | B ms | C ms | D ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| C26-r12 | 1 | 51.44 | 61.89 | 107.35 | 231.90 |
| C26-r12 | 2 | 51.46 | 61.92 | 107.32 | 231.62 |
| C26-r12 | 3 | 51.41 | 64.02 | 107.28 | 231.93 |
| C40-row6x3u1 | 1 | 50.39 | 60.30 | 107.32 | 226.42 |
| C40-row6x3u1 | 2 | 50.45 | 60.29 | 107.36 | 226.32 |
| C40-row6x3u1 | 3 | 50.42 | 60.32 | 107.37 | 226.32 |
| C41-row5x5u1 | 1 | 53.85 | 62.94 | 113.64 | 241.11 |
| C41-row5x5u1 | 2 | 53.74 | 62.97 | 113.69 | 240.76 |
| C41-row5x5u1 | 3 | 53.84 | 62.92 | 113.59 | 241.18 |
| C26-r13 | 1 | 52.44 | 61.97 | 107.38 | 231.65 |
| C26-r13 | 2 | 51.43 | 61.80 | 107.29 | 231.91 |
| C26-r13 | 3 | 51.47 | 61.98 | 107.25 | 231.72 |

| 成员 | A波动 | B波动 | C波动 | D波动 |
| --- | ---: | ---: | ---: | ---: |
| C26-r12 | 0.0972% | 3.4399% | 0.0652% | 0.1337% |
| C40-row6x3u1 | 0.1190% | 0.0498% | 0.0466% | 0.0442% |
| C41-row5x5u1 | 0.2043% | 0.0794% | 0.0880% | 0.1742% |
| C26-r13 | 1.9623% | 0.2905% | 0.1212% | 0.1122% |

预先规定每个候选必须同时通过前后C6：合计改善严格超过max(1%,该次比较全部case波动)，且任何case退化不超过1%。实际比较如下，正数代表耗时减少：

| 候选 / 对照 | A改善 | B改善 | C改善 | D改善 | 合计改善 | 波动/最低门槛 | eligible |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| C40-row6x3u1 / C26-r12 | +1.9829% | +2.6163% | -0.0373% | +2.4062% | +1.8074% | 3.4399% | false |
| C40-row6x3u1 / C26-r13 | +2.0400% | +2.6949% | -0.0652% | +2.3304% | +1.7792% | 1.9623% | false |
| C41-row5x5u1 / C26-r12 | -4.6656% | -1.6473% | -5.8889% | -3.9715% | -4.1871% | 3.4399% | false |
| C41-row5x5u1 / C26-r13 | -4.6046% | -1.5653% | -5.9185% | -4.0523% | -4.2170% | 1.9623% | false |

C40自身最大波动仅0.1190%，A/B/D有所改善，C有0.0652%的轻微退化；但关闭C6的A样本52.44/51.43/51.47形成1.9623%波动，开场C6的B样本61.89/61.92/64.02形成3.4399%波动，分别高于C40的1.7792%和1.8074%合计改善。因此两次eligible及qualified_for_confirmation均false。64.02和52.44均保留；现有证据不能确定这些计时偏离的内部原因，不能删掉它们后补算通过。

C41比关闭C6慢4.2170%，四个case均退化且都超过1%；对开场控制也慢4.1871%。实际没有向量spill仍然未获得性能收益，不能把无spill当成提速充分条件，也不能在没有同轮C33控制的情况下单独归因于横向5VL。

C42没有正式性能记录，也没有C42/C41同形状比较，不能宣称asm贡献。G没有候选通过双控制门槛，没有最终ZIP复验或晋级。协调者决定另建J轮，以未改源码的C40作独立同allocation复测，重新加入前后C6控制；截至本稿J仅准备，尚未提交。J不会覆盖G的样本、噪声或false判定。

## 公开证据与交付状态

逐版本汇总见[本轮记录](CONV_SEP12G_ROUND_RECORDS.md)，脱敏范围见[公开说明](../PUBLICATION-CONV-SEP12G.md)，导出清单见[G证据manifest](../records/conv-publication-sep12g.json)与[profile r2 manifest](../records/conv-profile-sep12g-r2-publication.json)。正式性能原顺序日志及结构化记录：

| 成员 | 完整日志 | 正式record |
| --- | --- | --- |
| C26-r12 | [benchmark.log](../records/evidence/conv-C26-r12/benchmark.log) | [记录](../records/experiments/conv/C26-r12.json) |
| C40-row6x3u1 | [benchmark.log](../records/evidence/conv-C40-row6x3u1/benchmark.log) | [记录](../records/experiments/conv/C40-row6x3u1.json) |
| C41-row5x5u1 | [benchmark.log](../records/evidence/conv-C41-row5x5u1/benchmark.log) | [记录](../records/experiments/conv/C41-row5x5u1.json) |
| C26-r13 | [benchmark.log](../records/evidence/conv-C26-r13/benchmark.log) | [记录](../records/experiments/conv/C26-r13.json) |

专项冻结：[C40验证](../records/evidence/conv-C40-row6x3u1/sve-correctness-sep12g/validation.json)及[十一阶段汇编](../records/evidence/conv-C40-row6x3u1/sve-correctness-sep12g/assembly-review.json)、[C41验证](../records/evidence/conv-C41-row5x5u1/sve-correctness-sep12g/validation.json)及[九阶段汇编](../records/evidence/conv-C41-row5x5u1/sve-correctness-sep12g/assembly-review.json)、[C42失败结果](../records/evidence/conv-C42-row5x5asm/sve-correctness-sep12g/RESULT.md)及[失败validation](../records/evidence/conv-C42-row5x5asm/sve-correctness-sep12g/validation.json)。[实际硬件元数据](../records/evidence/conv-C40-row6x3u1/sve-correctness-sep12g/raw/hardware-metadata.log)只描述该诊断分配，profile证据范围见前节。

本轮最终范围为53520专项PASS、C42编译失败0项数值测试、12套件48/48正式PASS且误差0，另有独立profile r2完成证据复核。**正式提交仍使用C6原包，G不新增提交版本。** 所有题目编译、正确性、benchmark和profile均在超算调度计算节点执行；本机仅轻量编辑和证据整理，没有使用重置卡。官方提交由队友手动进行，官方分数未知。
