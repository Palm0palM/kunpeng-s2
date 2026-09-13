# Sep12e 正确性诊断

仅计算节点编译执行，配置config/conv-sep12.local.json。C34后C35串行，唯一job ID，约60秒查询，所有diagnostic终止后根代理才可测性能。不本机编译测试，不用重置卡。

C34保留C30全套：每配置21748 full+96 smoke，六配置131064。full=3268+30宽度×14kernel×11高度×4放置，含255/256/257/511/512/513；六配置1/4线程×SVE128/256/512位。独立smoke额外计数每个OMP worker实际helper调用，要求1或4worker各非零。G/C同时大于1的用例可达新column-major解码（group=work%groups、column=work/groups*256）；全局ow行距、局部chunk_width、输出覆盖和bitwise均不变。G=1/C=1退化路径也覆盖。最大513列单rowgroup最多3块，不声称四线程同时处理单组；多组矩阵和真实worker计数证明四线程参与。

C35检查包准备中；计划每配置29668 full+168 smoke+18独立prefetch分支proof，六配置179124；具体proof和验收条件随独立包保存。两者严格参考、只读输入/kernel、保护页/输出canary及NaN、worker实际VL保持原样。wrapper先检查38CPU单NUMA计算分配，禁止本机/登录节点执行。

命令：python3 .runs/conv/sep12e-checks/driver.py VERSION config/conv-sep12.local.json submit|status|fetch（逐次执行，已有job禁止重提）。验收调度SUCCEEDED、job/system/wrapper0、PROBE_COMPLETE、确切逐组计数/VL/实际入口、自动传输manifest与远端SHA；无额外人工重复哈希。真实汇编单独读FMA/spill与预取位置。不凭静态指令推断提速。通过后冻结到候选sve-correctness-sep12e/，失败保留日志。
