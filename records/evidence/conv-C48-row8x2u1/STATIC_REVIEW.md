# C48 静态复核（不是运行验证）

仅轻量源文本/生成器/patch复核。没有本机编译、运行、测试、sanitizer、SSH或计算作业；prepared不等于正确性通过。正式C6及所有已测快照不变。

## 修改范围与命名

标准experiment new以C40为parent建立独立快照，编辑在`.runs/.workflow.lock`内完成。只替换C40专用six helper及其紧接的首个六行分派；它之前所有旧helper和之后完整C6分派/非SVE实现保留父版文本。README.md/bench_conv.c/run.sh保留原字节。生成器与candidate.patch仅在新候选目录，不加入提交source。生成器第八系数行指针使用krow_h，避免遮蔽int kh；源声明和加载已同步。

## 数值顺序与15阶段

各输出r=0..7的acc[r][0..1]初始化正零。阶段按输入行t从0到kh+6递增；活跃条件恰为r<=t<=r+kh-1。

- leading t=0..6：仅r=0..t，kernel行t-r从非负常量导出。
- shared t=7..kh-1：r=0..7均活跃，kernel行t-r在0..kh-1。
- trailing t=kh+q，q=0..6：仅r=q+1..7，kernel行kh-(r-q)，最小kh-7>=1（kh>=8），最大kh-1。

因此固定r看到t=r..r+kh-1，映射kernel行0..kh-1恰好各一次；每行内ik=0..kw-1逐列单步，每个输出标量仅一次svmul后一次svadd，不含部分和/FMA/重关联/跨线程reduction。两次舍入策略与原flags保持。修改只改变不同输出之间的调度顺序。

## 行列边界、整数与分派

有效入口先检查kh/kw>0且不超过输入尺寸，随后oh/ow为正int。八行入口检查oh>=8/kh>=8；组数用size_t `oh/8+(oh%8!=0)`，没有oh+7；group*8<=oh-1，因此remaining=oh-first_row不下溢。块内最后输出行first_row+7在remaining>=8时<=oh-1。最大输入行first_row+kh+6=(first_row+7)+kh-1<=inputHeight-1；trailing使用(size_t)kh+q先拓宽，不在int中算kh+6。

设L=svcntw()。block=2L（SVE上限仅128个float），i从0起，条件ow-i>=block确保0<=i<=ow-block；i+=block不超过ow，不会int溢出。每次n=0/1的完整向量覆盖i+nL..i+(n+1)L-1；加ik最大kw-1后，最后输入列i+2L+kw-2<=ow+kw-2=inputWidth-1。代码以row+ik+n*L进行指针推进；没有把i+ik组合成潜在溢出的int。kernel行乘kw、输出行乘ow、输入行乘stride均先为size_t。对合法可表示的buffer合同，正int32尺寸乘积可在目标64位size_t中表示；本接口无buffer长度参数，不能用非法超大指针声称极值动态覆盖。

每group写且只写first_row..min(first_row+7,oh-1)，组间不重叠。剩余行映射如下，所有dst间距仍全局ow、所有base间距仍原input stride：

| remaining | helper分解 |
| --- | --- |
| >=8 | 新roweight |
| 7 | quad行0..3 + triple行4..6 |
| 6 | quad行0..3 + pair行4..5 |
| 5 | quad行0..3 + prefix行4 |
| 4 / 3 / 2 / 1 | 原quad / triple / pair / prefix |

新helper最后0<ow-i<2L时，两次旧quad分别处理行0..3与4..7的相同尾列；旧helper各自安全选prefix/tail，主块与尾列不重叠。直接调用helper且kh<8时防御回退也用这两个quad；其调用合同仍须提供完整八输出行。公共kh<8或oh<8则完全绕过新helper，走保留C6路径。非SVE/invalid路径保持父版。

## 静态限制

源级16acc/8coeff和理论load/broadcast比率不证明实际GCC寄存器分配、无spill、吞吐或线程效率。新生成器不构成独立正确性证明；必须后续独立审查实际展开的15阶段及超算逐位guard。没有改变线程上限、调度资源、benchmark计时/校验或runner。此次仅停在prepared，未创建诊断包。
