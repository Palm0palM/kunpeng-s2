# TRSM r7：限制打包微核的系数存活

从已晋级并在r6复验的T8-control12创建新的同版本run，与T10-lhistbarrier比较。源实现T8仍为最佳；T9-lhistpack为T10设计来源而非性能基线。原r6比较已结束并发布PR14，两个T9未晋级。上一goal回合分类为progress。

前两轮反复出现整份分配的首套件大用例慢约12%的现象。本轮在查看任何新性能数据前固定协议：预检后，每成员先跑1套完整官方warm-up（原run.sh/TEST_RUNS=3），所有原始日志、PASS与实际依赖映射单独保存；之后各跑3套计入比较的完整套件，次序AB/BA/AB。所有成员采用相同流程。warm-up不用于收益挑选；记录与比较仍使用完整3套，不删除其中任何慢样本。未改benchmark计时/输入/精度/threads。新方法的提速只在本轮同分配内比较，不与r6原时间混算。

所有编译、预检、warm-up、benchmark和汇编生成仅在38CPU/单NUMA/24GiB/1800秒的调度分配节点。KML25.1/GCC12；非指定KML25.2复验。不算哈希、不用重置卡、不本机测试、不关机、不取消别人作业、不提交比赛。

现阶段只准备；job_control.py prepare之后才有冻结payload与候选台账，submit保存唯一job ID。收集后必须同时核对warm-up和3套计时结果，再用records-kml.py record --repeat-existing增加T8-control12新run，保留prior-record及历史链，再登记T10和compare。目标汇编须确认spill变化，正式晋级仍按各例中位数、波动门槛及无>1%退化判断。
