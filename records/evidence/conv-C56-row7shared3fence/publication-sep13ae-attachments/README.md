# AE 准备入口

候选 `C56-row7shared3fence`；父 `C55-row7x3shared3` / 原 AC1582860。此目录只用于本版独立诊断，未授权计算、性能或晋级。完整合同见 [INTERFACE.md](INTERFACE.md)。

三工具、接口和五文件首次清单已完成静态准备，候选生产源为112355字节、SHA256=`6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`。最终文件身份与完整差异列在 PREPARED_FILES.json、AC-to-AE.patch；它们不是通过证据。首次准备schema KeyError原输出保留，record采用source_parent优先、缺省parent的兼容读取，未改历史。

唯一未来预约为 `C56-row7shared3fence/job.json`，冻结目标为候选原树的 `sve-correctness-sep13ae`。driver/accept/freezer 均只由 root 审查后另行授权；失联只恢复原ID，已有预约禁止重投。

复用两个原 AC checker 的44328矩阵、六VL/线程配置和19stage，不继承父PASS；实际汇编审查必须覆盖三列边界和整个helper栈。schema `ae-shared3-fence-paths-v1` 允许如实记录调度未收紧或仍有spill，不把它们等同数值失败，不推导提速。

本机只编辑/读文件，没有工具导入、编译、数值、SSH、预约或接受/冻结。AD原C55false、Yfalse/Sfalse与C6保持。用量40%停止，不用重置卡。准备完成，FINAL/STOP，等待root独立审查。
