# TRSM r13 公开实验归档

此目录为脱敏公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，公开文本不能用作原始字节身份依据或重新晋级输入。归档不计算或验证哈希，不运行编译、测试、benchmark、登记或晋级，也不声称当前测量已经完成或通过。

cohorts/compare 保存 r13 的控制脚本、计划、提交元数据、finish_records.py、r7 packed-L-aware 通用预检、KML 探针及实际已取回日志。submitted-payload 单独保存 prepare 时冻结的控制脚本、cohort-config.json、preflight/reference 和三个成员的五个源码文件。当前准备目录与冻结提交目录分别留痕，缺失项记入 ARCHIVE.json，不能拿当前文件补写冻结快照。本轮没有 wide32 预检；不得用旧宽核日志替代本轮通用预检。

通用预检的 guard.py、run.sh、check-panel.c 和 README.md 同时保留当前准备版与冻结版，严格结果 parser 完整内嵌在 run.sh 的 Python heredoc 中。三个成员的 preflight-results 分别从实际结果或 diagnostics 下递归收录，包括 summary.tsv、completion.txt、commands.txt、guard.json、trsm-panel16.s 和实际存在的所有日志。guard、compiler、build-normal、build-no-sve、build-fail-alloc、assembly、micro-t1、normal-t1、normal-t4、normal-t38、boundary-t1、no-sve-t4、fail-alloc-t4、narrow-vl-t4，以及 T10/T14 的 build-fail-shared、packed-micro-t1、shared-fail-t1、shared-fail-t4 证据按原文保留。函数插桩来自 check-panel.c/编译命令，预检产物不能代替 benchmark 源码；trsm-panel16.s 的实际生成命令及相关汇编审查/输入另行保留，归档不重新生成汇编。预期 T8 与 T10/T14 的覆盖计数不同，实际 completion 以各自日志为准；没有统一补造计数或成功标记。检查程序二进制不归档。

members 保存 T8-control12-repeat-r13、T10-lhistbarrier-repeat-r13 和 T14-lhistcyclic 的运行材料、源码、预热、登记及原日志。T10 的原 r7 PREPARATION.md 明确从 .runs/trsm/T10-lhistbarrier 收录到本轮 member 的 candidate-preparation 下；原候选已有的 VALIDATION-PLAN/STATIC-REVIEW 也按实际存在情况保留。T14 现有 PREPARATION.md 和五个源文件均为所需材料。candidate_preparation_origins 逐项说明来源，静态准备不能当作本轮通过验证的证据。

static-readiness.json、STATIC-CONTROLLER-REVIEW、prepared-repeat-readiness.json 及计划都是准备材料。其中 prepared-repeat-readiness.json 保存 prepare 后对 T8/T10 既有 repeat 资格的只读 helper 检查；不是 r13 新编译、预检或成绩验证。warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 的原 run 结果分开保留。计划为每成员一套预热和 ABC/BCA/CAB 三轮正式用例，只有实际取回并登记的结果才能证明完成；预热不并入正式三轮计时。失败或不完整运行只保存已有证据，缺失项与按 job ID 匹配的台账声明列在 ARCHIVE.json。

两份 prior 来源不同。T8 prior-record.json 关联 r12 公开档的 [T8 记录](../trsm-stage-r12-20260912/records/latest/T8-control12.json)和 [T8-control12-repeat-r12 运行](../trsm-stage-r12-20260912/members/T8-control12-repeat-r12/cluster.json)，预期作业 1579645。T10 prior-record.json 关联 r7 公开档的 [T10 记录](../trsm-stage-r7-20260912/records/latest/T10-lhistbarrier.json)和 [T10-lhistbarrier 原运行](../trsm-stage-r7-20260912/members/T10-lhistbarrier/cluster.json)，预期作业 1579401。ARCHIVE.json 的 prior_record_origins 分别核对版本与各自 job ID；不借相同版本认定来源，也不把两个历史作业写为同一个 cohort。原始 T8 初测仍见 [r6 公开档](../trsm-stage-r6-20260912/members/T8-control12/)，更早重复历史由相应公开档继续引用。本轮不重建或覆盖旧运行。

records/latest 保留归档时的 T8-control12、T10-lhistbarrier、T14-lhistcyclic 台账。T8-vs-T10 与 T8-vs-T14 两份机器可读比较、T10-lhistbarrier-vs-T14-lhistcyclic.json 机理对照，以及 result.json 的 mechanism_comparison 字段均按实际产物收录。T10-vs-T14 只用于区分共享 L 生产调度这一个改动，不能授权晋级；T14 晋级父版本仍为 T8-control12。归档不预判比较/晋级结论，不把历史样本混入本轮同一作业的比较。

实际参考环境以各作业证据为准；KML 25.1.0 + 私有 GCC 12.3.1 不等同指定 KML 25.2.0 复验。ARCHIVE.json 的 verified 只转述按本轮 job ID 匹配的原台账声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单记录相对路径、原件字节数和公开副本字节数，不包含摘要。tools/records-kml.py 与其 NOTES 保存所用 helper 及作者记录的审查说明，不补造独立检查结果。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均不归档。公共工具和其他题目没有因归档发生改动。
