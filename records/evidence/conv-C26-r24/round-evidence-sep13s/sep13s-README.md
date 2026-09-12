# S 独立确认：仅准备，根代理审查后亲自一次提交

固定顺序 `C26-r24 / C51-r1 / C26-r25`，三个新编号在准备时未占用；实际 GO 时再次检查。只准备三个工具及本 README，没有导入/执行工具、创建成员、campaign、cluster manifest 或作业。

R 原组 1581911 的 C51 已通过两端初筛。S 是一次独立确认：每成员三个原始完整 benchmark 套件，共36个case样本，使用新的前后 C6。38 CPU、24576 MiB、单 NUMA pack、1800秒、实际 GCC10.3.1、generic、原 strict flags、38线程 close/cores，settings 与 R 完全相同。S 的机器和两个控制必须由本作业实际记录证明，R 仅提供初筛资格和源码身份。

## 复用接口与来源

提交工具复用已审 `sep13r-record-group.py` 的完整记录检查，及其 submit contract 的设置、真实诊断、原作业查询和历史限制定义；登记复用同一机器/CHECKS/DIMS定义；比较复用已审 R 的标准比较函数。import 只载入函数定义，各工具均有 main guard；本准备阶段没有导入或执行这些文件。

`C51-r1` 的 `source_parent` 明确为 `C51-row7x3u1`，说明源码来自 R 原候选的原字节。`diagnostic_source_version` 也明确为 `C51-row7x3u1`，但表示自身已冻结 Q 的诊断身份，不是新复测版本 C51-r1。两个字段角色分开定义，当前值相同；`reused_identical_source_diagnostic=true`。C51-r1 不创建新诊断或冒充 Q 的新结果。

Q 来源 `.runs/conv/C51-row7x3u1/sve-correctness-sep13q/`，真实 job1581822、37128项、13阶段/7×3VL/21acc；继续使用 R 已审真实冻结与源码一致性门禁。C51 源 SHA 为 `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`。原 benchmark、README、runner 也必须保持相同字节。

R 前置要求其完整4成员48样本、全部 PASS/退出码/机器/源证据，并检查 C51 的保存两端 verdict 和根据原48样本重新计算的标准门槛均为 true。R 的 C40-r4 始终 reference_only=true、promotion_allowed=false、qualified=false；原 Gfalse/Jtrue/Kfalse/Nreference 也保持。S 不写 R 或 C40 记录。

串行门禁复用已知 H/I/L/M/O/J/K/N/P/Q/R 原身份清单，并额外检测 `.runs/conv/sep13t-checks/C52-row7x3shared2/job.json`、S 三成员 cluster.json 和 `sep13s-campaign.json`。无 T/S 文件不阻塞；已有未知 job 身份的预留、非终态或查询失败会阻塞；已知 job 去重后有界查询。T 工作流另行准备，不由 S 提交。

## 三个工具的边界

`sep13s-submit-performance.py --go`：根代理明确 GO 才检查并执行；完整前置通过后先在共享锁内保存 S campaign 预留，再用标准 experiment.new 创建三成员并 checkpoint，最后只调用一次 group submit。只要已有 campaign、成员或 cluster.json，就禁止重新提交；不自动删除预留或重做失败确认。

`sep13s-record-group.py [versions...]`：默认记录原作业全部三成员。只有真实 SUCCEEDED、job/system/wrapper退出零、原始日志和源/环境证据完整才写标准记录。已 passed 记录核对后跳过，不覆盖；失败原件保留。继续采用 N/R 已审 metadata 适配：prepared/current/submitted哈希一致后，用内存 metadata 当前哈希视图校验原 Q 来源，不把创建时 experiment.json 快照强制改成最终源码身份。

`sep13s-compare.py`：仅对三份完整 S 记录的36样本应用与 R 相同的规则；候选对**两端 S C6**各自要求总 case 中位数之和收益严格大于 max(1%, 两成员全部case spread)，并且**任一case退步不超过1%，包含第一组**。不能跳过或调整第一组门槛。全部样本/逐case中位数/spread/实际阈值/收益/拒绝原因保留，绝不从 R/S 挑样本、合并样本或以 R 的好结果补救 S。

比较结果在 C51-r1 和 S campaign 写 `confirmation_passed`。失败也是最终保留结果，`failed_confirmation_retry_allowed=false`；此工具不再生成初筛候选，`confirmation_pending=[]`。成功也只交还根代理决定后续动作，绝不自动 ZIP、晋级或发布。

## 未来根代理 GO 后的命令

```bash
python3 .runs/conv/sep13s-submit-performance.py --go
python3 tools/cluster.py --config config/conv-sep12.local.json status .runs/conv/C26-r24
python3 .runs/conv/sep13s-record-group.py
python3 .runs/conv/sep13s-compare.py
```

提交后保存唯一原 job ID；断线、上传失败或 submit_unknown 均停止对账，不能重跑 submit。核对三成员 cluster.json、submit.log、remote group及调度器，保留首次输出和预留，再由根代理补齐原 campaign；禁止通过新组替代旧身份。只有原作业真正 terminal 后登记，真实 schema 差异先保留失败输出再根代理最小审查修复，不改源码/样本/门槛或重测。

本次仅准备完毕并 STOP。所有算子编译、正确性、sanitizer与benchmark都只能在超算调度计算节点执行；不使用本机替代。
