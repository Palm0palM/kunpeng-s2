# TRSM r14 公开实验归档

此目录是脱敏公开派生副本，未脱敏原件保留于本地 .runs/trsm。个人路径、账号、内网地址和节点名已替换；公开副本不能用作原始字节身份依据或重新晋级输入。归档没有运行编译、测试、benchmark、登记、晋级或提交比赛，没有计算或验证哈希；归档本身不证明本轮已经完成或通过。

cohorts/compare 保存 r14 四成员计划、控制器、finish_records.py、preflight_audit.py、提交及收集元数据、参考探针与实际原日志。submitted-payload 独立保存 prepare 时的四成员五源码、cohort_driver.py、remote_job.sh、cohort-config.json、preflight_audit.py 与 preflight/preflight-wide32/reference 全部冻结文本。当前 preflight_audit.py 和冻结副本都为所需证据；缺失冻结文件不能用当前文件补写。清单 source 和 provenance_role 区分当前准备/审计工具、prepare 上传快照、成员源文件、取回结果及插桩预检源码；该区分不额外宣称传输或远端脚本身份验证。

四个 members 分别为 T8-control12-repeat-r14、T10-lhistbarrier-repeat-r14、T17-lhistbudget4、T18-budgetwide。T17/T18 各自 PREPARATION.md、VALIDATION-PLAN.md、STATIC-REVIEW.md 及五个 source 文件全部为所需材料。T10 的原准备资料明确从 .runs/trsm/T10-lhistbarrier 收录到本轮 member/candidate-preparation，继续标注原 r7 静态来源，不能当作 r14 通过的证据。

通用 preflight 四输入 guard.py、run.sh、check-panel.c、README.md 保留当前版与冻结版，新增 STATIC-REVIEW.md 单独保留；冻结目录实际含有的审查也按原样收录。每个成员真实 preflight-results 或 diagnostics/preflight-results 树递归保存所有 ALLOC_PASS/CASE_PASS/SOURCE_FEATURES/MODE/失败注入原日志，以及 summary.tsv、commands.txt、guard.json、completion.txt、summary.json、budget-summary.json 和 trsm-panel16.s。请求字节、history/X/KB 层级、每 worker X 调用、预算外零 history 调用、窄 VL 与无 SVE 的区别均保留原观测；不以 packed 入口为0补造“没有分配”的结论。

通用模块的严格结果 parser 完整包含于 run.sh；候选只在预检编译时通过 check-panel.c 包装分配和函数入口。summary.json 与 budget-summary.json 来自实际输出，归档不重建它们。预算进程 budget-t1/t4/t38、budget-x-fail-t4、budget-no-sve-t4、budget-narrow-vl-t4，以及 packed 成员的 budget-shared-fail-t4 与全部继承的一般/微核/失败模式日志分别保留。不同成员的覆盖计数以其冻结特征和实际完成标记为准，不能用一个成员的结果替代另一个。

只有 T18-budgetwide 使用本轮单独 wide32 模块；四输入来自 r12 模块的准备副本，当前 preflight-wide32 与 submitted-payload/preflight-wide32 均明确收录 guard.py、run.sh、check-wide32.c、README.md。实际 preflight-wide32-results/T18-budgetwide 从取回结果树保存所有日志、summary.tsv/json、completion.txt、commands.txt、guard.json、instrumented-trsm.c 与 trsm-wide4x32.s。参数观察生成器和严格parser内嵌run.sh，不补造不存在的独立脚本。instrumented-trsm.c 仅是参数/入口观察的预检副本；真正 benchmark 源码仍是该成员 source/trsm.c，trsm-wide4x32.s 由原候选源码生成。原 KB256/CT64、参数与宽核完成标记按真实输出保留，缺失结果不生成。所有实际汇编审查及其输入另行收录；检查程序二进制不归档。

static-readiness.json、prepared-repeat-readiness.json、STATIC-CONTROLLER-REVIEW、preflight 静态审查及候选准备文件只说明准备过程。预热原日志、linkage 与 warmup/summary.json 单独保存，不作为额外正式轮次。各成员实际三轮日志、登记、三个 T8 比较、T10-lhistbarrier-vs-T17-lhistbudget4.json 和 T17-lhistbudget4-vs-T18-budgetwide.json 两个机理比较完整保留；result.json 的机制字段是 mechanism_comparisons。T10→T17 用于区分4MiB预算，T17→T18用于区分大宽核；二者不独立授权晋级，T8仍是本轮晋级比较父版本。不同作业样本不混入本轮比较，也不预判候选是否胜出。

T8/T10 的 prior-record.json 各自关联 r13 公开档：对应 [T8 台账](../trsm-stage-r13-20260912/records/latest/T8-control12.json)与 [T8-control12-repeat-r13](../trsm-stage-r13-20260912/members/T8-control12-repeat-r13/cluster.json)，以及 [T10 台账](../trsm-stage-r13-20260912/records/latest/T10-lhistbarrier.json)与 [T10-lhistbarrier-repeat-r13](../trsm-stage-r13-20260912/members/T10-lhistbarrier-repeat-r13/cluster.json)。这两份 prior 的预期作业均为1579673，但仍分别核对版本、run与公开记录；结果列于 ARCHIVE.json.prior_record_origins。r13 档案继续保存更早 T8/r12 和 T10/r7 的不同来源，T10 准备文档的原 r7 来源与本轮 prior 测量的 r13 来源不能混淆。原始 T8 初测仍见 r6 公开档。

records/latest 是归档时的四版本台账，仅按当前 run job ID匹配其已有声明。失败或不完整运行只收录已经存在的日志、失败JSON或failed-diagnostics等目录，预期正常收集位置缺失时明确列入 missing_optional_or_expected_evidence；不填补成功标记、JSON、源码或测量。原件不改、不删；目标排他，已有目录禁止原地重跑。

实际 KML25.1.0/GCC12.3.1 与指定官方KML25.2.0复验仍分开。ARCHIVE.json 的 verified 只转述已有台账声明，归档不重新验证成绩。SOURCE记录路径与字节数而不包含摘要。私有集群配置、SSH/认证/钥匙串/doctor文件、二进制、编译器、tar/ZIP和Git目录排除在外。
