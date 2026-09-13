# C36 验收

原作业1579403 SUCCEEDED，job/system/wrapper退出0；六配置18052 full+96 smoke，共108888全通过，complete=true。VL、线程、pair/triple/quad真实入口、原逐位scalar/只读/保护页/输出检查及自动传输manifest匹配均通过。

独立实际汇编对比C26：两者共享.L342都是93条指令，32FMUL+32FADD、8LD1W+8LD1RW、10ADD、LSL/CMP/BGT各1。64条浮点指令连同Z寄存器逐行完全相同；并未形成源码希望的全16个ik更新后再全ik+1。C36交换x3/x4与x11/x12的用法；前置基址定义和sp656/sp664指针槽也对应交换，因此主循环操作/数据流顺序实际保持一致。外围地址初始化、栈槽布局仍有差异，不声称整helper或整文件字节相同。

热点无向量spill/FMA/EXT/MOVPRFX，七阶段配对循环指令32/55/75/93/75/55/32。整个quad无Z/Q ldr/str/ldp/stp和额外VL空间，固定752B，d8–d11为ABI保存。全源码FMA0。是否存在外围成本影响仍需根代理正式性能验证。

PMU探测 /usr/bin/perf 可用，paranoid=2，perf stat cycles,instructions /bin/true退出0：391562 cycles:u、154116 instructions:u，运行比例100%。仅证明该计算分配上本次用户态事件探测成功，不是算子数据，不声称其它事件支持。

已保留全部日志/实际汇编与自动manifest。没有本机编译测试、重置卡、性能提交、算法改写。C34/C35/C36均终止，可交根代理下一同组性能；C37只prepared，不能并行提交。
