# C43-padinput 静态边界与释放复核

仅文本生成、读取与比较；未执行编译/测试/算子/SSH/调度。

- new/checkpoint使用标准experiment工具及工作流锁，只涉及新候选和其record。
- 所有helper从原typedef至conv2d之前逐字节一致；只在Linux/AArch64头部新增stdint/stdlib/string，在原use_sve分支增加局部副本流程、替换base/四helper的stride，并在原return前释放。逆去这些变更恢复原C6分支。无效检查及非SVE/后续代码原文一致，另外三个提交文件字节一致。
- 入口尺寸校验保证inputHeight/inputWidth为正；新增gate在use_sve内部且kh>=4、oh>=4、width>=64。stride+15在SIZE_MAX-15检查后；odd-line置位为位操作不会溢出。lines×16先检查，所得padded_stride>=stride且非0。
- height×padded_stride先检查除法上界，再检查×sizeof(float)；row_bytes=stride×sizeof(float)另行先检查。分配字节<=536870912。复制行r满足0<=r<height，actual copy_stride=padded_stride<=padded_stride，故r×copy_stride+stride不超过已核实分配元素数；源r×stride+stride也不超过原input元素数及size_t上界。copy_row最大INT_MAX-1后增至INT_MAX退出，不会再增溢出。
- memcpy仅复制每行width个float，位模式保持，不访问原输入行外；不同复制行目标区间不重叠。padding/未使用尾部不初始化，但原helpers最大逻辑读列仍<=inputWidth-1，ow和kw保持原值，因此不应参与计算；必须以独立远端检查补证。
- 行j的base仅换为sve_input+j×sve_stride；原helper的t/kh映射及stride行跳保持。输出地址完全不改，每输出仍由唯一原四行组写入，原kernel顺序和独立mul/add保持。
- 两个独立static parallel-for均有隐式结束屏障。先copy完成才赋sve_input/sve_stride进入compute，compute全完成才free。input_copy初始NULL、唯一malloc、仅成功后复制并切换输入，末尾非NULL只free一次；分配失败/所有gate拒绝均保留原input/stride且不free。没有其它新增return、goto、共享静态状态或跨调用生命周期。
- 本候选不改变原资源限制，不含固定线程扩容。小宽/小核/少输出行/无需padding不分配、不拷贝、不释放，仍用原C6 helpers；invalid及非SVE完全不触及新增分支。
- C43/C44相同allocation_bytes和gate，唯一源码差异为copy_stride选择。C44标记reference-only，不应晋级。malloc不是64B对齐分配，16float/64B只能称实验参数。padding导致缓存改善与否、复制与OMP开销、最终helpers代码均未知。

本次准备conv2d.c SHA256：`a805f1a60d22fd8ed88ac079c030be8186fa0e1048e39e38430880f49f5a59fa`。prepared状态及源身份由checkpoint保存；无任何PASS或性能结论。

## Independent root source review

Source/diff review only; no operator compilation or execution. Changes stay in SVE copy preparation, input pointer/stride selection, and final free; numerical helpers are unchanged. Positive dimensions make padded_stride nonzero. Round-up, multiplication by16, height*stride, and element_count*sizeof(float) each have preceding size_t bounds, and the512MiB limit covers the whole copy. Original stride<=padded_stride, so every copied row remains inside the allocation; C44 compact storage also fits the same capacity. The two parallel-for implicit barriers finish copying before computation and finish computation before the sole free. No premature return or double free appears. Allocation failure retains original input/stride; non-SVE, small kernels, and unchanged-stride gates retain C6. No static blocker found.

Target-node checks must still prove successful allocation entry, odd-stride bypass, forced allocation-failure fallback,1/4threads and all VLs, row/tail boundaries, input immutability and output guards. Separate production-object evidence from instrumented entry/failure checks. This review is not a PASS result. Performance must include allocation/copy/free and compare C43 with both C6 and C44 in the same environment.
