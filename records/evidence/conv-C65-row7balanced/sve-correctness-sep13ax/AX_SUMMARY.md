# AX 原作业数值与生命周期摘要

候选 C65-row7balanced，原作业 1591086。共查询 2 次，末次 status/fetch 均退出0，调度器 SUCCEEDED，job/system/wrapper = 0/0/0。

实际 25 个有序阶段退出0；九配置总 80100 例，full/dispatch/direct = 51696/24516/3888。issues = []。

|SVE字节LOCAL_USER线程|full|dispatch|direct|
LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|16|1|5744|2724|432|
|16|4|5744|2724|432|
|16|38|5744|2724|432|
|32|1|5744|2724|432|
|32|4|5744|2724|432|
|32|38|5744|2724|432|
|64|1|5744|2724|432|
|64|4|5744|2724|432|
|64|38|5744|2724|432|

每配置3156个dispatch/direct用例全部输出通过predicate-aware SVE store恰写一次检查；共28404个用例、110027484个输出值。写计数观察原predicate活跃lane并执行原svst1_f32；非instrumented fullguard另行保留。
|SVE字节LOCAL_USER线程|Dispatch入口|Direct入口LOCAL_USER恰写一次用例LOCAL_USER输出值LOCAL_USER
LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|16|1|4008|1080|3156|5239404|
|16|4|6168|1080|3156|5239404|
|16|38|24010|1080|3156|5239404|
|32|1|4008|1080|3156|10478808|
|32|4|6168|1080|3156|10478808|
|32|38|24010|1080|3156|10478808|
|64|1|4008|1080|3156|20957616|
|64|4|6168|1080|3156|20957616|
|64|38|24010|1080|3156|20957616|

旧fallback计数仅按原AX checker要求五类均非零；以下为实际观测，不是预期值。没有沿用AP或其他轮次观测作为固定预期。
|SVE字节LOCAL_USER线程|PREFIX|TAIL|ROWPAIR|ROWTRIPLE|ROWQUAD|
LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|16|1|27290|27290|612|7048|4130|
|16|4|31636|31636|1008|7840|4724|
|16|38|54664|54664|3582|11956|8270|
|32|1|27290|27290|612|7048|4130|
|32|4|31636|31636|1008|7840|4724|
|32|38|54664|54664|3582|11956|8270|
|64|1|27290|27290|612|7048|4130|
|64|4|31636|31636|1008|7840|4724|
|64|38|54664|54664|3582|11956|8270|

实际 GCC 10.3.1，三条完整 gcc argv 来自 probe.log 的 xtrace，strict/generic/关闭FP融合；38CPU、24576MiB、单packed NUMA、1800秒，允许CPU 76–113，node2。九配置实际线程1/4/38，close/cores绑定。

五份运输源的返回字节、远端manifest、原件、prepared/job与本地清单一致。未运行sanitizer或官方runner；汇编原件已返回，目标spill分析由独立审查者处理。此摘要不执行接受/归档，不填性能或提速。

原始日志在 raw/；完整逐配置、source关联、资源及所有status/fetch外层argv/UTC/输出路径见 AX_SUMMARY.json。用户已取消40%停止阈值；未使用reset。此子任务只读取日志，不执行本机题目或提交新作业。
