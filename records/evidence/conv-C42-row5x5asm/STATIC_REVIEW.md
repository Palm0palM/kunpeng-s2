# C42 静态复核

仅轻量文本编辑/比较，没有执行编译、shell语法测试、算子、SSH或调度任务。

- 创建时使用experiment new及其工作流锁，parent=C41-row5x5u1；只修改新快照。
- 精确匹配并替换共享中段的五组、每组五条intrinsic乘加，共25条；将五个新块逐一逆替换后，整个conv2d.c与C41原文完全一致。由此确认其它八阶段、所有声明/输入表达式、尾部和分派均保持原文。其余三份提交源码逐字节一致。
- 五个asm各10条模板指令，25FMUL+25FADD；每段5个+&w acc、1个=&w scratch、6个w输入、memory屏障。模板不使用固定寄存器、谓词写入、访存、FMA或预取。当前GCC10.3.1是否接受及实际寄存器分配未知。
- 满块条件ow-i>=5*lanes不改，pg始终ptrue。对n=0..4、ik=0..kw-1，最大读列i+n*lanes+(lanes-1)+ik <= ow+kw-2；未增加读取或存储地址。t=4..kh-1、输出r=0..4使用kernel[t-r]合法，旧输入行范围保持不变。
- kh<5、窄宽和余行余列继续原逻辑；所有索引/分配/任务乘积表达式原文不变，未引入整数算术或溢出路径。非SVE代码完全相同，asm仅在既有SVE目标helper内。
- 各输出仍逐kernel行列、v×coeff后acc+product，两次独立FP舍入；没有重关联或跨输出求和。unpredicated只作用于完整输出向量，不能泛化用于tail。
- memory屏障是片段间调度假设，并不保证无spill或提速；其它20acc和5coeff仍活跃，32Z理论预算无余量，九阶段均需实际汇编检查。

准备后conv2d.c SHA256：`cbdadacaa24a28f2eff0b9d01810ccae69ddc127da22942f30b15a6713265def`。权威prepared身份由experiment checkpoint写入对应record；未取得任何正确性或速度结果。
