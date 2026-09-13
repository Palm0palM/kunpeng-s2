# CONV AC：共享三列展开诊断

C55-row7x3shared3从原C52-row7x3shared2出发，仅把shared主循环两列改为三列，逐累加器保持ik/ik+1/ik+2顺序，原u1余数0..2。其余十二阶段、7行×3VL/21累加器、尾部/防御/分派与三个非实现文件保持。意图是减少循环控制开销，同时避免四列展开的高寄存器压力；源码形状不是速度证明。

原AC作业1582860在AB1582814实际终结后唯一提交；submit/status/fetch各一次退出0。调度SUCCEEDED，job/system/wrapper和十九实际阶段均0。六配置VL16/32/64×线程1/4，每组full5744/dispatch1212/direct432，合计44328全部逐位scalar通过。实际GCC10.3.1、严格浮点/generic三条编译argv以及38CPU/单NUMA符合要求。

两个C checker与AA完全同字节，保留full五家族3888/144/720/32/960、dispatch972/240及入口1236/1080、mask1/15。quad_boundary仅继承网格名称；kw1/2跳main、kw3一轮、kw4/5一轮余1/2、kw6/7/8两轮余0/1/2、kw15/81多轮。未增加kw79/80、direct ow1、L/2L邻界、逐行guard或sanitizer覆盖。输入/权重只读、分配边界guard、页内canary、output poison不变。

实际生产汇编已审查。全部四个dispatch函数的完整标签到.size文本与已完整审阅的AA对应函数逐字节相同，root据全文等同性复用已审控制流/栈结论，没有声称重新手动逐行审当前dispatch或整个机器代码相同。C55自身helper5705–7360全部1656行独立审完，实际1492条指令；三列主循环189指令/63FMUL/63FADD、9输入载入/21广播、5Z读/5Z写，余数u1每列63指令且体内无spill。实际13语义阶段、14算术范围，所有21条三次FADD链、五个栈槽、重置/转换/尾部及防御均已审，全源FMA0。

完整栈帧880+5VL字节（VL16/32/64对应960/1040/1200），全helper30LDR Z/45STR Z，含五次零初始化；D8..D15的低64位ABI保存另列。外围u1体内零spill不代表整个函数零spill。原父C52的shared两列123指令、固定720字节且无Zspill；同六列工作T为369指令、C55为378，静态数量不能推出速度。

Root首次accept退出0，status=passed/complete=true、44328项；随后首次freeze退出0，完整记录位于 `.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac/`，首次source/prepared/manifest、原job、所有日志及真实汇编不回写。冻结外层输出保留于树外。AD固定C26-r32/C55/C52-r3参考/C26-r33四版三套同环境性能对比已由root唯一提交为AD1582956；AD已完成48/48 PASS，C55总中位466.81ms，比结束C6的452.66ms慢3.125967%，初筛未通过；见[全部48样本](CONV_SEP13AD.md)。

最佳仍C6；原C54 AB退化、C52 Yfalse、C51 Sfalse及全部慢样本保留。没有生成新提交包。
