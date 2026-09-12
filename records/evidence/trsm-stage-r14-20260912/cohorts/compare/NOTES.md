# r14：共享历史预算与大路径宽核

此目录是准备材料。r13已经完成并通过PR21合并，T10/T14均未晋级，最佳仍为T8-control12（T8-svepanel16）。本轮尚未建立payload、重复run或新实验台账，也未提交作业。独立审查通过并由root移除明确的prepare草稿阻断后，才能继续准备与提交。

四成员固定为A=T8-control12-repeat-r14、B=T10-lhistbarrier-repeat-r14、C=T17-lhistbudget4、D=T18-budgetwide。A/B同源码复测，各自prior均来自r13作业1579673，身份和更早历史由现有nohash helper保留。C由未晋级T10增加单一4MiB实际packed_history分配门禁，保留static生产；D由完整C小路径前缀与未晋级T13大路径后缀在原KB256/CT64 enum处分界组合。全部候选的晋级父基线仍为T8。

每成员独立预热一套，正式三轮固定ABCD/BCDA/CDAB，各原runner的TEST_RUNS仍为3；预期36正式和12预热PASS。这是三个循环移位，不声称覆盖四个位置的完全均衡设计。全部正式样本保留，预热另存、不合并不同作业。T8与三候选的比较用于晋级判断，T10→T17仅隔离预算策略、T17→T18仅隔离宽核，机理比较不能授权更换父版本。

通用预检的四输入已经准备，source_features和两个JSON契约见preflight/README.md。T8预期14直接核、433整算子/实际分配观察、52空操作；T10为28/518/64、85次shared-only失败；T17/T18同28/518/64，但预算外跳过共享分配后实际shared-only失败为83次。新增预算案例分别为27/32/32/32，包含真实history/X/KB分配次数、字节、成功/失败、层级与新旧核入口，不以packed入口零次替代未分配证明。

预算实际限制1024*b*(b-1)字节，b=floor(m/16)，允许到b64（m1039），b65（m1040）起跳过。它不表示硬件cache，也不改变原64MiB三角工作集算法分派。X分配失败、仅shared失败、无SVE和实际窄VL分别检查；窄VL仍可能允许history分配，无SVE才关闭它。

preflight_audit.py由target driver和本地finish共同使用：预热前及登记前分别核对成员源码特征、完整completion、两个summary、各进程合计、精度，以及所有预算行的身份、分配和入口公式。此文件必须随payload上传，并在公开归档同时保留当前版和冻结提交版。它只读取证据，不编译、测试或计算摘要。

T18另运行原r12宽核预检，第三参数固定64；28直接、28整算子、56参数检查、7个CT观察进程的契约不变，与通用计数分开。T8/T10/T17不运行wide32。原参考探针、线程绑定、38CPU单NUMA、24GiB/1800秒和官方runner保持不变；实际KML25.1/GCC12不能声称指定KML25.2复验。

控制器保留排他prepare、uploading/submit_unknown/submitted状态与已知job marker重试规则；不得因轮询超时重复提交。collect只接受调度器成功，finish排他提取diagnostics并通过原nohash helper登记，最后仍由root决定晋级。条件性T18打包脚本只在该版本已实际verified/promoted/currentbest后可使用，准备脚本本身不建立提交包或验证声明。

本机仅轻量编辑、AST/Bash语法检查和日志整理；编译、预检、汇编与benchmark全部只在调度计算节点。没有哈希操作、重置卡、关机、取消他人作业或正式比赛提交。公共工具与其他题目未改。
