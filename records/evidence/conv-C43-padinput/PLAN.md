# C43-padinput：奇数行距的算子内输入副本

状态仅prepared，未编译、测试、SSH、提交作业或推送，不使用重置卡。parent/source_parent均为C26-row4loads（正式C6来源）。本版本是未测候选，必须在同一分配中对照新C6控制与C44-copyinput；没有成绩不能晋级。

## 假设及唯一布局变量

原始较大输入行距可能影响缓存组分布，但没有已验证的cache几何或计数器证据；这不是已知瓶颈。用16 floats（64 bytes）作为固定实验行单位，将输入行向上取整到奇数个单位。64B只是参数，不能据此声称目标实际cache-line大小、set数或冲突原因。malloc只保证float所需对齐，不保证64B对齐。

C43与C44使用同一启用条件，分配相同padded_stride×inputHeight×sizeof(float)字节，逐行复制同样inputWidth个float，均在调用内释放。C43将副本行距和helpers输入stride设为padded_stride；C44实际副本行距和helpers stride仍是inputWidth，较大分配的尾部未使用。两版源码仅copy_stride初始化一行不同，其余完全一致。因此C44控制拷贝、分配容量、释放和额外OMP区开销；不能将C43/C6差值全部归为padding。内存实际触达布局本身仍是被测差异。

本版本实际copy_stride=padded_stride。目标padded_stride为ceil(inputWidth/16)后置最低位为1、再乘16，例如64→80、65→80、80→80（不启用）、96→112、128→144。padding不初始化、不可被读入浮点运算；helpers的逻辑输出宽度始终原ow，kernel及原input只读。

## 启用、溢出与回退

只在既有use_sve分支内部、kh>=4、oh>=4、inputWidth>=64、目标padded_stride不同于原stride时考虑复制。C44也按这个“假想padding目标”判定，而非把实际保持原stride误当作禁用条件。

先检查stride+15，再乘16，再检查height×padded_stride、元素数×sizeof(float)，原行字节数也在乘法前检查。分配总字节数必须<=512MiB；这是对有效复制总量的保守上界，也限制完整额外分配，不只限制padding增量。乘积无法表示或超过上限时不分配，原C6输入/stride直接继续。malloc返回NULL同样回原C6路径，无重试、无部分复制状态、无提前返回。

两版使用可移植malloc/free和逐行memcpy，分配、完整拷贝、计算和释放全部在conv2d内，原benchmark计时完整包含。没有静态缓存、跨调用复用、输入尺寸特判、外部环境开关或隐藏预计算。复制循环不指定更多线程，继承原runner的38线程上限。

## OpenMP与原计算保持

选择两个独立#pragma omp parallel for schedule(static)：先复制行，再运行原四行组计算。这样只在原SVE分派前增加复制并替换输入指针/stride，保持原计算的OMP循环与helpers调用形状。复制并行循环结束的隐式屏障保证所有行可见，计算循环结束的隐式屏障后才能free；不会让计算读到未复制行。

合并到同一个parallel region可能减少启动开销，但会进一步改变原调度结构，本候选不叠加。额外团队启动、memcpy带宽、malloc/页面首次触达以及更大stride/工作集都可能抵消收益；C44同样承担这些流程。不因线程数继承就声称严格内存NUMA绑定，原runner的CPU/OMP条件保持。

所有helper本体、原浮点次序、核索引、输出地址和ow行距、tail/小核、非SVE分支、benchmark/run.sh/README原文不改。无效尺寸在原检查返回后根本不会进入分配；tiny/kh<4/oh<4/stride无需padding时保持原input/stride，既有计算回退照常。

## 后续必需验证

当前只有轻量静态审核，正确性与速度均未知。先做独立源码审查，再由根/诊断代理在调度计算节点做原始guard/只读输入与kernel/输出canary/NaN/逐位scalar、VL128/256/512和1/4线程、所有余行余列及真实helpers入口。特别覆盖width63/64/65/79/80/81/95/96、kh3/4/5、oh3/4/5、目标stride相同关闭、最窄输出、odd/even核、512MiB门槛与size_t拒绝路径。

用独立诊断机制验证分配失败确实走原C6、每次成功分配释放一次、padding不参与计算、原输入/kernel不变；诊断拦截或注入不能混入生产源/计时。不在本机用测试替代。生产汇编与原helpers指令仍须实际核对，不能以文本相同声称最终代码一样。

仅全部验证后进行同资源多套件C6/C44/C43对照，完整记录分配/复制/释放已计时和所有慢样本；随后若合格还需独立确认及原ZIP复验。C44始终仅归因参照，C43无可靠改善则继续C6。此次不准备新的诊断脚本、不申请任何作业。
