# r14 controller / JSON 契约独立静态审查

**结论：READY，未发现会误拒正常预检输出或阻断本轮四成员协议的具体缺陷。** 只读审查preflight_audit.py、cohort_driver.py、finish_records.py、job_control.py、plan.json，并与冻结preflight/run.sh内嵌parser和wide32输出契约逐字段对照。本文件是此次唯一新增文件；没有导入或执行待审模块、prepare、SSH、题目编译/测试、登记、晋级或哈希操作。

prepare开头的draft RuntimeError是协调者有意保留的阻断，本审查不将其列为实现缺陷；审查时payload不存在。是否移除阻断并执行由协调者决定，READY不代表本轮已在计算节点验证。

## 共用审计的调用与冻结

cohort_driver和finish_records均从preflight_audit导入audit_general/audit_wide。target driver在每个通用run退出0后立即审计，四成员全部通过后才运行并审计T18宽核预检；所有门禁均在任何预热前。finish_records在collected状态、cohort退出0后，对解包诊断和本轮冻结payload源码调用同一审计器，全部通过后才开始record。

job_control将preflight_audit.py与driver/remote_job一起放入payload，并复制preflight、preflight-wide32、reference；目标端使用的helper能够随payload上传。诊断收集保留json/txt/tsv/log/汇编及所需插桩副本，双JSON能在本地再次审计。没有另写一套较弱的本地预算公式。

## summary.json及completion

源特征与实际四成员对应，原panel16均存在；T8无packed/无budget，T10有packed/无budget，T17有packed/4MiB budget，T18另有4×32大核。history_budget_bytes分别是null、0、4194304、4194304；0明确表示packed不限预算，不表示禁止分配。审计器与parser的source_features四个键完全相同。

| 必需项 | T8 | T10 | T17 / T18 |
| --- | ---: | ---: | ---: |
| micro_cases | 14 | 28 | 28 |
| old_micro_cases / packed_micro_cases | 14 / 0 | 14 / 14 | 14 / 14 |
| whole_cases / allocation_checked_cases | 433 / 433 | 518 / 518 | 518 / 518 |
| noop_cases | 52 | 64 | 64 |
| shared_fail_cases | 0 | 85 | 83 |
| budget_cases | 27 | 32 | 32 |
| budget_shared_injections | 0 | 5 | 3 |
| process_count（含micro） | 14 | 18 | 18 |
| processes数组长度（仅whole） | 13 | 16 | 16 |

schema=trsm-r14-preflight-v1、complete=true及所有表内字段与冻结parser一致。completion的字段顺序和值由同组常量构造，包括ALLOCATION_CASES/BUDGET_CASES/BUDGET_SHARED_INJECTIONS，未遗留r13的406/486旧总数。

processes数组只存whole进程，所以不能把它的长度误当process_count。审计器对唯一label及whole/noop/allocation/budget/shared-fail五项求和，分别得到表内总数。T8为原406+新增27=433，13×4=52个no-op；packed为原486+新增32=518，16×4=64个no-op。shared_fail_cases仅shared-only目标中实际注入的案例，原80加新5（T10）或新3（预算），不包含all-allocation-fail目标；求和口径一致。全局和逐进程max_error都要求有限且处于0..1e-12。

## budget-summary.json逐行契约

schema=trsm-packed-history-budget-v1、complete=true、source_features同上。budget_cases=27/32，budget_processes=6/7，budget_shared_injections=0/5/3，budget_x_fail_cases、budget_no_sve_cases、budget_narrow_vl_cases三个键均精确为5，与parser输出命名一致。allocation_rows长度及顺序与声明矩阵一致：五边界正常t1/t4、两边界t38、五个仅X失败、五个no-SVE、五个窄VL，packed再追加五个shared-only失败。

审计器逐行核对label/threads/injection/narrow_vl/m/n，并检查parser记录的全部实际观测字段：small、history_expected；history/x/kb各calls/bytes/success/fail/level；total/injected；shape_bad/x_each_worker_once；old_entries/packed_entries。没有漏掉最后加入的实际level字段。无调用level=-1，共享history与KB根层级为0、worker X为1，精确匹配冻结parser。

所有预算维度m=1023..1041均在原64MiB small路径，故small=1、KB三计数/bytes均0、kb_level=-1。b=m//16、panels=(n+7)//8，共享请求为1024*b*(b-1)，独立核算使用实际副本口径；预算内恰为前三个m（1023/1024/1039），1040/1041跳过。X请求总字节threads*m*8*8，与C wrapper累积实际请求字节的语义一致。

| 预算进程语义 | history | X | SVE入口 |
| --- | --- | --- | --- |
| normal | 依packed能力/HWCAP/预算分配成功 | 各worker一次成功 | 完整panel总数，history可用时除首块走packed |
| narrow VL | 同normal，不能因窄VL消掉history | 各worker一次成功 | 新旧核均0 |
| only X fail | 同normal，history仍成功 | 各worker一次失败 | 新旧核均0，原标量回退 |
| no-SVE | 0次，无请求字节，level=-1 | 各worker一次成功 | 新旧核均0 |
| shared-only fail | 若应分配则一次失败，否则0次/0注入 | 各worker一次成功 | packed0，原核完成全部完整行块 |

审计器的history条件不含narrow或X失败，正确保留了源码只按HWCAP及预算决定history分配的行为；sve条件另排除x/no-sve/narrow。packed_entries=(b−1)*panels仅在SVE、history可用且不是shared注入时成立；old_entries=全部panel−packed，非SVE时两者0。total/injected、history_success/fail和X成功失败与冻结parser的独立公式逐项一致，未发现正常日志会被误拒的分支。

## T18宽核与测量协议

driver显式只对T18-budgetwide调用wide32/run.sh，第三参数为字符串64。audit_wide要求固定28直接+28整算子、56参数检查、零参数不匹配、原候选未改、KB256/CT64、7个CT进程及正的实际参数观察量，completion与冻结r12宽核契约一致。通用预检的4097×9不会被误用来替代4×32核验证。

四成员固定A=T8、B=T10、C=T17、D=T18；config和driver均固定ABCD / BCDA / CDAB三轮。四者先各一套原runner独立预热，全部通过后才排他新建正式日志；每成员3套×3官方用例，finish要求36 formal和12 warm-up。TEST_RUNS=3、同allocation和原线程/NUMA/真实KML/GOMP环境门禁保留，预热不进入正式中位数，慢样本不剔除。

前两成员用--repeat-existing，T17/T18普通新record；计划性能parent分别为null/T8/T8/T8。T8/T10均使用r13作业1579673的最新记录，仍需prepare及record的既有验证/来源快照门禁。当前T8仍是已晋级best，T10未晋级，来源身份不被新run重定义。

finish_records保存T8对T10/T17/T18三份父基线比较；另存T10→T17和T17→T18机理比较，均明确promotion_authorization=false。脚本不调用promote，不能凭机理对照替代当前T8父基线的晋级门槛。

本审查聚焦controller/JSON接口；C观察器和runner由另一审查者独立检查。没有扩大到额外运行或重复旧性能评估；实际r14结果仍须计算节点产生。
