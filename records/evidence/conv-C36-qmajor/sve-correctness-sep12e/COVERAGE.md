# C36 诊断准备

标准guard未改：3268+24宽度×14kernel×11高度×4放置=18052 full；smoke96。六配置1/4线程×128/256/512位，总108888。kh4/7/8、kw4/7/8以及满4VL边界覆盖真实共享双列循环，奇数kernel保留单列余数，小kh回退和尾列/余行不变。smoke kh4、kw3/4、ow193/385可达共享双列路径，实际pair/triple/quad入口均要求非零。

wrapper沿用尚未提交C35的非致命PMU元数据块：在计算节点、正式guard之前记录perf路径、perf_event_paranoid、perf stat cycles,instructions /bin/true及各退出码。没有改变算法或校验容差，失败不判定PMU可用，也不影响数值检查。源码身份通过首次传输manifest登记，无重复人工哈希。

C35终止后才提交本包。实际汇编需与冻结C26比较共享循环顺序、8输入/8系数加载、32mul+32add、FMA/spill，而非按源码排列推断机器顺序。所有证据冻结在sve-correctness-sep12e；本机不编译测试、不得使用重置卡或提交性能。
