# C42-row5x5asm：五行五向量共享中段显式乘加

状态仅prepared；未编译、未执行任何正确性/性能测试，未SSH、提交调度或推送，不使用重置卡。父版本/source_parent为C41-row5x5u1，后者是同形状纯C对照，尚未测量且不是正式最佳。正式C6不变。

## 唯一调度假设

仅在conv_sve_rowquint的共享输入行t=4..kh-1、每个ik的五个输入向量scope中，将各自原五条svadd(svmul)替换成一段五次FMUL/FADD交替执行的volatile asm。每段固定复用一个乘积scratch，并带memory编译器屏障，限制后续输入加载跨过当前片段提前。它是“显式片段内乘加顺序及片段间内存调度”的一个方案，不将两个作用单独归因为性能原因。

每段五个输出均为+&w、scratch为=&w、输入v及ak/bk/ck/dk/ek为六个w，使用%Z寄存器模板；无固定寄存器、FMA、预取或其它指令。原25累加器声明、五系数声明、svld1输入表达式与顺序均保留。其余八个首尾阶段、kh<5回退、5VL满块条件、尾部stores与fallback、五行OMP分派、非SVE、benchmark、runner和源码README逐字节保持C41。

假设是减少GCC同时物化多个乘积或输入窗口的机会。25acc+5coeff+1input+1scratch=32只是零余量的源级预算，绝非无spill保证；跨片段寄存器分配、系数加载、循环衔接及未改的其它阶段仍可能需要额外状态。早期覆写约束/屏障限制调度，scratch复用也可能降低吞吐；性能可能不变或更慢。

## 数值和约束

该代码仅位于svptrue_b32的完整5VL块。unpredicated FMUL/FADD覆盖的全部lane均为合法输出，每条乘法保持v在前、系数在后；加法保持旧acc在前、product在后。两条独立FP指令保留两次舍入，不融合。每个输出自己的kernel行和ik递增顺序不变，不拆分部分和，不改FPCR或容差；尾部继续原helpers。

+表示累加器读写，&避免多指令段提前修改输出时与尚未消耗输入重叠；scratch同样早期覆写，不覆盖输入v、系数或旧acc。单段GCC操作数计数为5×2+1+6=17，小于30限制。memory只作保守编译器屏障，不是硬件fence，asm内本身没有内存或NZCV写指令。空scratch为write-only输出，不读取其未初始化C值。各段直接内联于原scope，没有额外函数调用或ABI边界。

依据：[GCC扩展汇编/earlyclobber/%Z](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)、[GCC AArch64 w约束](https://gcc.gnu.org/onlinedocs/gcc-15.2.0/gccint/Machine-Constraints.html)、[Arm SVE指令手册](https://documentation-service.arm.com/static/67e40f3398aa3c3b6eea6a85)。这些支持一般语义，当前目标GCC10.3.1的具体模板、分配与汇编接受必须远端验证，不能用文档或旧空asm通过代替。

## 远端验证要求

先在调度计算节点验证实际GCC/flags和模板接受；不接受则记录失败，不静默换intrinsics/约束/固定寄存器。查看未插桩生产汇编：共享段每个ik应含五个十FP指令片段，总25mul+25add；检查真实Z寄存器、scratch及输入生命周期、所有九阶段/循环边界spill、额外复制和整源码FMA。源级预算不能取代这一步。

逐位guard继续覆盖1/4线程和VL128/256/512，宽度围绕5VL及10VL与短宽/尾列，kh<5及kh=5/6和更大奇偶核、kw=1/2/3及更大奇偶值，输出高度覆盖五行组和余1..4行、足够行组触达所有worker；真实quint入口与其它helpers验证分开记录。所有源快照、benchmark和runner保持原样。

只有诊断通过后再由根安排同分配C41纯C形状对照和当前正式C6双控制，各三独立完整套件，保留全部样本与失败。C42/C41差值才能讨论这个显式调度方案，C42/C6另检验实际价值；未获收益不得晋级或生成提交包。
