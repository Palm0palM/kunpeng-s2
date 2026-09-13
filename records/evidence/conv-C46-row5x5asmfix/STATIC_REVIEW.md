# C46-row5x5asmfix 静态复核

只进行轻量文本编辑/比较与标准experiment身份登记，未执行C编译、题目、测试、SSH或调度。

- 标准new/checkpoint和本次新候选编辑使用`.runs/.workflow.lock`。源父C42未改变，原1579627失败记录保留；只写C46源、PLAN、STATIC_REVIEW、candidate.patch、experiment元数据及其record。
- 变化严格限定150个`%Z[name]`→`%[name]`，分布于五个asm的50条字符串行。把新版本这150个默认named operand逆替换后，逐字恢复原C42整个conv2d.c；补丁没有其它源码改动。
- 操作数名仅a/b/c/d/e/t/v/ka/kb/kc/kd/ke，原`.s`后缀、每条指令三操作数位置、换行/制表转义、FMUL/FADD数量和顺序完全不变。
- 所有acc `+&w`、scratch `=&w`、六输入 `w`、volatile与memory clobber没有变化；没有降低early-clobber、增加固定寄存器、改变输入只读性或把乘加融合。所有operand原类型为svfloat32_t单向量，GCC10默认打印分支对应zN而非tuple范围。
- 所有C声明、输入/系数/输出地址、循环条件步长和分派完全原样，故本次未扩大任何索引、size_t/int算术、内存访问、输出写区间或线程资源范围。原C42的边界和数值源码证明沿用，但仍需目标动态验证。
- README、bench_conv.c、run.sh与C42逐字节一致；既有helpers、其它八阶段、尾路径、generic/invalid代码均被整个源码逆替换比较覆盖。
- 后端源码证据明确解释默认打印与%Z失败，但没有实际编译结果；constraint allocation、具体寄存器重叠、spill、FMA及五scope调度都待超算。准备记录不是PASS、不是提速，也不改写C42的0checks。

源码SHA256：`a04c74c8701c394fd620d9fa91d421898cf4aa2b7c96b87de21cf301cd4e2e8d`。最终prepared身份由标准checkpoint保存；独立补丁为`candidate.patch`。
