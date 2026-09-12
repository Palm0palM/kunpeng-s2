# TRSM r16 公开实验归档

这是脱敏公开派生副本；原始私有日志保留于 .runs/trsm。归档只整理已存在文件，不编译、运行、登记、晋级或提交比赛，不计算或验证哈希，不由归档动作宣称实验通过。公开副本不替代原始证据或重新晋级输入。

本轮成员为 T8-control12-repeat-r16、T18-budgetwide-repeat-r16 和新 T19-panel8x16budget。每个成员保留五份源码、实验/作业元数据、逐套日志及已有结果声明。两份 prior 分别关联 r15 的 T8/T18 repeat 与公开台账，均应为作业1579788；ARCHIVE.json逐项列出匹配结果，历史样本不并入本轮。

T18 原候选的三份准备文档仍明确来自 r14 的 .runs/trsm/T18-budgetwide，并放在 member/candidate-preparation；T19三份准备文档来自本轮新候选目录。静态文档只说明准备与审查，不能代替实际精度或性能结果。

cohorts/compare保留计划、控制器、driver、单次finish标记、参考探针、全部实际日志和比较。submitted-payload独立保存prepare冻结的三成员五源码、driver、remote_job、cohort-config、旧preflight_audit，以及preflight、preflight-wide32、preflight-panel8x16、reference完整输入；缺失冻结副本不得用当前文件替代。清单区分当前工具、上传快照、取回结果及插桩预检源码，不额外声称验证远端脚本身份或传输。

旧general预算预检仅对应T8/T18，保存全部ALLOC/CASE/MODE日志、完成标记、双JSON、commands/TSV/guard与原源码汇编。T19专用模块保留check-panel.c、guard.py、run.sh、audit_panel8x16.py、PLAN/README及实际静态审查；结果包含summary.json、budget-summary.json、panel8x16-summary.json、全部原始分配/入口/参数/直接核/整算子日志、完成标记、commands/TSV/guard、插桩副本和未插桩源码的trsm-panel8x16.s。数目以运行前冻结契约和真实输出为准，不补造成功摘要。

T18/T19各自的CT64 wide32完整结果分别保留，包含28直接/28整算子预检原日志与参数观察、原source汇编和独立插桩副本。所有实际汇编审查和其输入同时保留。测试二进制、编译器、私有配置/认证/doctor文件和ZIP/tar不收入公开档。

预热独立保留，不计为正式样本。正式三轮日志及T8→T18、T8→T19晋级比较和T18→T19机理对照均记录；机理比较不能授权晋级。缺失、失败、未完成记录如实列入清单，不用历史成功填充。records/latest仅转述归档时与本轮job匹配的三版台账。

实际参考为KML25.1/GCC12，不等同指定KML25.2复验。原件不改不删；目标目录排他，禁止原地重复执行归档。
