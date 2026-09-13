# AT 原作业数值与生命周期摘要

候选 C63-row7x2shared4rowwise，原作业 1590603。首次 status/fetch 均退出0，调度器 SUCCEEDED，job/system/wrapper = 0/0/0。

实际 19 个有序阶段退出0；六配置总 44328 例，full/dispatch/direct = 34464/7272/2592。issues = []。

|SVE字节LOCAL_USER线程|full|dispatch|direct|
LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|16|1|5744|1212|432|
|16|4|5744|1212|432|
|32|1|5744|1212|432|
|32|4|5744|1212|432|
|64|1|5744|1212|432|
|64|4|5744|1212|432|

旧fallback计数仅按原AT checker要求五类均非零；以下为实际观测，不是预期值。没有沿用AP或AR固定计数。
|SVE字节LOCAL_USER线程|PREFIX|TAIL|ROWPAIR|ROWTRIPLE|ROWQUAD|
LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|16|1|10064|10064|234|2587|1778|
|16|4|10064|10064|234|2587|1778|
|32|1|10064|10064|234|2587|1778|
|32|4|10064|10064|234|2587|1778|
|64|1|10064|10064|234|2587|1778|
|64|4|10064|10064|234|2587|1778|

实际 GCC 10.3.1，三条完整 gcc argv 来自 probe.log 的 xtrace，strict/generic/关闭FP融合；38CPU、24576MiB、单packed NUMA、1800秒，允许CPU 76–113，node2。六配置实际线程1/4，close/cores绑定。

五份运输源的返回字节、远端manifest、原件、prepared/job与本地清单一致。未运行sanitizer或官方runner；汇编原件已返回，目标spill分析由独立审查者处理。此摘要不执行接受/归档，不填性能或提速。

原始日志在 raw/；完整逐配置、source关联、资源及两次外层argv/UTC/输出路径见 AT_SUMMARY.json。用户已取消40%停止阈值；未使用reset。此子任务只读取日志，不执行本机题目或提交新作业。
