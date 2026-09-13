# C34-colmajor256：256列条带优先的任务顺序

- parent / source_parent：C30-colchunks。只使用其不可变源码快照；不改写 C30 原始测量和未晋级判定，不把它当作当前最佳。正式版本仍为 C6。
- 状态：prepared，仅源码/文档编辑和静态审查，尚未编译、做专项或测量性能。准备完成后停止，是否提交由根代理另行安排。
- 单一假设：让同一256列条带中的相邻四行组连续执行，有机会保留滑窗输入，减少相邻行组之间重新遍历整行宽度带来的工作集扩大。只改变任务访问顺序。

## 唯一源码差异

C30 的 row-group-major 编号：

```c
const size_t group = work / column_chunks;
const size_t column = (work % column_chunks) * column_step;
```

C34 的 column-chunk-major 编号：

```c
const size_t group = work % groups;
const size_t column = (work / groups) * column_step;
```

其它源码逐字节保持 C30：column_step=256、groups/column_chunks/tasks 计算、单个 size_t work 循环、OpenMP schedule(static)、原 quad/triple/pair/prefix helpers、局部 chunk_width、全局输出行距、输入 stride、非 SVE 路径均不变。benchmark、runner、源码 README、flags、参考与容差不改；不添加预取、硬件计数器、官方尺寸识别或额外算术变化。

## 硬件与实验依据

已有 C26-r5 environment.log 报告 L2 总计456 MiB、608个实例；算术平均为每实例768 KiB。该日志没有逐实例缓存拓扑，**平均值不是已验证的单个 L2 容量或独占可用空间**，不能据此断言新工作集一定驻留。

C30 以一个四行组的所有列块为内层顺序，再进入下个四行组；C34 先保持一个列块，连续处理所有四行组，再进入下个列块。相邻四行组的输入行重叠随 kernelHeight 增大而增加。在单线程连续处理同一条带时，条带的有效输入列宽为 chunk_width+kernelWidth-1；相对完整输出宽度的循环顺序，可能缩小连续重用的输入范围。本实现始终是四输出行，不改变 kernel helper 的运算量。

OpenMP static 将连续 work 区间分配给各线程，因此每个线程区间内可能连续推进同条带的相邻行组；但不能保证某个条带完全落在单个线程，也不能保证跨线程边界共享私有缓存。缓存行大小、相联度、实际页落点和 cache-miss 数据均未知。C30 原来的小幅改善未通过既定门槛，本候选不借用那份结果宣称有效；其代码只作为单变量顺序对照。

## 双射与覆盖证明

设 G=groups、C=column_chunks，合法尺寸检查保证G>=1、C>=1，tasks=G*C。对每个0<=work<G*C，令 g=work%G、c=work/G，则0<=g<G、0<=c<C。反向编号 work=c*G+g 唯一，故 work 与 (四行组,列块) 是双射，只改变遍历次序，不改变任务集合。

每个四行组覆盖输出行 `[4g,min(4g+4,oh))`，每个列块覆盖 `[256c,min(256c+256,ow))`。不同行组或不同列块不重叠，其笛卡尔积完整覆盖输出。每个输出仍仅由一个任务调用的一个原 helper 写入，不需要锁、原子操作、部分和或跨线程归约。

## 余行、余列与地址安全

- row=4*g<oh，column=256*c<ow，因此 remaining=oh-row、remaining_columns=ow-column 均为正，不下溢。局部宽度为min(256,remaining_columns)，在1..256内，可安全转换int。
- 最后1/2/3输出行仍调用原prefix/pair/triple；完整四行调用原quad。各dst行地址仍加全局output_stride=ow，helper只使用局部chunk_width作为列宽，输入stride仍为inputWidth。
- 最后列块不足256时仍用原 helper 的满向量/尾部处理；最大输入列 column+chunk_width+kw-2<=ow+kw-2=inputWidth-1，行边界证明也完全沿用C30。
- ow<=256时C=1，新的group=work%G=work、column=0，与C30每组一个任务的解码完全相同。oh<=4时G=1，新group=0、column=work*256，也与C30相同。
- groups/column_chunks/tasks/work/group/row/column均为size_t。AArch64 64位size_t、32位int尺寸下G<=2^29、C<=2^23，G*C<=2^52，不发生任务数乘法溢出。row和column分别小于oh和ow；输入/输出偏移继续遵循原接口有效且足量缓冲区的前提。
- 每个输出内部仍由原 helpers 以相同 kernel 行列顺序、独立mul/add计算；只改变独立输出之间的执行顺序，不改变数值表达式。非 SVE 路径原文不变。

## 风险与待验证

窄条带优先可能改善滑窗输入复用，也可能使输出写入更跨步、增大TLB压力、改变静态负载边界和线程间缓存行共享。实际 CPU 缓存容量、替换行为或内存放置可能使理论重用无法实现，性能可能不变或退化。不能仅凭平均 L2 大小选择“必然更优”的顺序。

待根代理安排超算逐位/保护页检查：多个VL、1/4线程、oh跨1/4/5/8/9及更多行，ow跨255/256/257和511/512/513，确保G/C同时大于1以实际覆盖新解码，同时覆盖G=1或C=1退化路径。随后同分配保留不变C6和C30顺序对照，三个独立完整套件，原样保存全部样本；不把跨allocation差值当作任务顺序的因果改善。

当前不SSH、不编译或测试、不提交计算作业、不推送、不使用重置卡。new/checkpoint自动登记身份，不增加重复人工哈希审计；所有原版本、正式C6和队友文件保持不变。
