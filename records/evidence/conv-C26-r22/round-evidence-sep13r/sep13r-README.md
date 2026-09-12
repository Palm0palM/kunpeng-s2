# R 性能接口：仅准备，执行待根代理审查与 GO

本次只建立三个工具和本 README，未导入/执行工具，未创建 R campaign、control、reference、cluster manifest 或作业。C26-r22、C26-r23、C40-r4 在准备前核对未占用，实际提交时仍会重新检查。固定顺序：

`C26-r22 / C51-row7x3u1 / C40-r4 / C26-r23`

前后控制均逐字节使用正式最佳 C6。每成员执行三个原始完整 benchmark 套件，共 48 个 case 样本；38 CPU、24576 MiB、单 NUMA pack、1800 秒、GCC10.3.1、原 generic/strict flags、38 线程、close/cores，settings 与 N 原组完全相同。相同作业内比较实际 machine/compiler，不从不同 NUMA 的旧轮次宣称提速。

## 真实前置接口

N 原作业 1581459 的八份记录必须完整通过且仍为 performance_complete。G/J/K 的 false/true/false、N 的 C40-r3 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false 全部保留。

C51 必须引用自身真实 Q 冻结目录：

`.runs/conv/C51-row7x3u1/sve-correctness-sep13q/`

必须同时有真实 validation.json passed/complete、scheduler SUCCEEDED 且 job/system/各阶段/wrapper 为零、六个 VL×线程配置、源文件关联和实际无插桩汇编审查，以及 mode=passed 的 freeze-source.json。准备态 validation、来源 C40 的 PASS、未冻结结果或仅数值通过都不能满足入口。

当前与 Q 作者对接的**实际诊断包接口**是 full=4784、dispatch=972、direct=432 每配置，六配置合计 37128（28704/5832/2592），runner=0；dispatch_entries=756、direct_entries=1080，worker mask 为 1/15。该接口有别于 C51 作者建议矩阵的 40368；R 使用 Q 真正建立且独立审查的包接口，不能把建议计数当作执行结果。若 Q 后续实际 schema/矩阵调整，必须先保留原方案并由根代理复核 R 对接，不能静默放宽计数或使用另一来源代替。

C51 源 SHA 为 `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`。要求真实 `conv_sve_rowseven` 及其 clone、13 阶段（input_0..5/shared/trailing_0..5）、7×3VL/21acc、单 kernel 列、各阶段 FMUL/FADD、整个源 FMA=0，完整 helper/stack/阶段转换及 conv2d/outlined dispatcher 审查。spill 可存在；工具不要求或推定零 spill。Q stage 的 derived_counts 按其真实 schema 使用 fmul/fadd，整体 FMA 字段在 assembly 顶层核对。

C40-r4 仅引用原 G 冻结同源诊断 `.runs/conv/C40-row6x3u1/sve-correctness-sep12g/`，job 1579597、26112 项。历史 G 的 build_commands 是直接 argv 列表，新 Q 是 commands/actual_trace_locations 对象；适配保留真实字段，不补造新格式。C40-r4 不作为待确认候选，也不允许晋级。

## 三个工具

`sep13r-submit-performance.py`：显式 `--go` 才进入任何前置检查、SSH 或写入。先检查实际 Q/G 来源、完整 N 和历史限制，再有界查询已知 H/I/L/M/O/J/K/N/P/Q 原任务与预留；发现运行中、未知状态或未对账 job ID 则停止。通过后先在共享锁内保存 campaign 预留，才创建三份新 control/reference 快照及成员 metadata，再调用现有串行 group runner 一次。已有 campaign 或成员 cluster.json 一律拒绝再次提交。

`sep13r-record-group.py [versions...]`：只恢复 campaign 保存的原作业；默认全部四成员。逐成员核对真实终态、下载原日志、验证 wrapper/源文件/环境/四 case×三样本，再使用标准 experiment.record。已 passed 的记录只核验并跳过，不覆写已有测量；failed 测量不允许静默改写。

N 的元数据适配保留在本工具中：experiment.json 保存创建时父源码快照，checkpoint 只更新 prepared record；登记前要求 prepared record、当前 source、上传 manifest 一致，再用只在内存构造的当前 hash metadata 视图检查 campaign/真实冻结诊断关联。experiment.record 本身从当前源码计算 result hash 并核对取回的 source-sha256、artifact digest。不会强迫创建时 metadata hash 等于最终候选 hash，不会修改任何历史源码身份来通过检查。

`sep13r-compare.py`：必须四份同作业完整记录全部有效且恰 48 样本后才比较。C51 对两端 C6 分别要求总 case 中位数之和的收益严格大于 max(1%, 两成员全部 case spread)，且任一 case 退步不超过 1%。样本数组、逐 case 中位数/spread、实际 threshold、逐 case 收益及拒绝原因完整保存，不删慢样本。C51/C40-r4 另存 whole-implementation 辅助比较，不替代 C6 门槛或声称隔离 spill 成本。初筛只写 qualified/confirmation_pending 标记，绝不自动新建确认实验、晋级或 ZIP。

## 未来已获根代理 GO 后的命令

```bash
python3 .runs/conv/sep13r-submit-performance.py --go
python3 tools/cluster.py --config config/conv-sep12.local.json status .runs/conv/C26-r22
python3 .runs/conv/sep13r-record-group.py
python3 .runs/conv/sep13r-compare.py
```

提交后立即保存并报告原 job ID，状态轮询只恢复该 ID；必须等真实 terminal 后再登记。断线或 submit_unknown 不等于未提交，不能重新运行 submit。对照四份 cluster.json、submit.log、remote group 和调度器原身份，在根代理核对后补齐同一 campaign 的 performance_job/performance_group/submitted/status；保留首次失败与预留，无新组替代。若上传失败且尚未取得身份，也停止交由根代理处理，不自动清除预留。

记录/比较失败时保留原输出与所有样本，先区分真实测量失败和工具 schema 差异；仅后者可在根代理审查后作最小适配并恢复原结果。未通过原日志校验的成员不能剔除。执行前置不满足时不在本机编译或测试代替；当前 R 仅准备完毕并 STOP。
