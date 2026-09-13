# C56 源码静态复核

已完整读取三个差异hunk和N final假设。标准new创建时四文件与父C55完全相同，且conv2d.c与冻结AC1582860 source字节一致。新源仅插入三段各10行、完全相同的empty volatile asm，总30行/1311字节；新源112355字节、SHA `6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`。

每段严格依序读取a0/a1/a2到g0/g1/g2全部21值，操作数约束均为w。输出列表为空，唯一clobber为memory，模板为空；没有+w或=w，没有寄存器clobber，没有用asm编造累加器结果。三个位置均在完整列的七行×三向量更新之后，第三个位置位于main循环尾，仍在原循环内。

生成器在共享workflow锁中对父精确SHA、冻结job/mode、首次planned记录与四文件字节做断言，再按三个固定原始行插入。其可逆字节检查确认删除这三段即恢复整个父conv2d.c，因此全部乘/加、输入/系数索引、循环条件、u1、其他阶段、输出和dispatch保持原字节顺序。该检查是文本核对，不是编译或算子测试。

其他生产文件README.md/bench_conv.c/run.sh的独立cmp均0、SHA均保持。官方benchmark和严格FP/线程配置未改。experiment.json及creation-experiment.json/creation-record.json保留创建时父源哈希；对应当前record由标准checkpoint保存本候选源SHA，不能把initial planned快照误认成当前源。

空asm本身不读写内存或修改累加器，但memory及输入依赖改变编译器安排。这里没有声称寄存器运算绝对隔离、实际零spill或编译器接受；实际GCC可能分配失败，也可能加重五槽或把spill移到边界/外围。需要自身机器证据说明。

完成范围：轻量源码/文档编辑、SHA、cmp、diff、标准experiment new/checkpoint及其退出原件留存。未编译、测试、运行算子、SSH、新job、导入诊断工具、打包或晋级。该报告为作者静态复核，后续root独立审查另行进行。
