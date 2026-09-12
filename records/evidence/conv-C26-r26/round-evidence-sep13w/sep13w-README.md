# CONV W：C52 shared 两列展开的同分配初筛（仅准备）

本次只写 `sep13w-submit-performance.py`、`sep13w-record-group.py`、`sep13w-compare.py` 和本说明。没有导入或执行这些工具，没有 SSH、new/checkpoint、campaign/reservation、作业、record/compare、编译或测试。创建前只读确认 C26-r26、C51-r2、C26-r27 的 run/record ID 均未占用。现有 C52 准备态源与 record 未修改。未来执行须 root 独立审查后明确 GO，由 root 唯一提交一次。

固定顺序为 **C26-r26 / C52-row7x3shared2 / C51-r2（参考）/ C26-r27**。每成员三套原始完整官方 benchmark，共 4×3×4=48 个样本。固定 GCC10.3.1、generic、38 CPU、24576 MiB、单 packed NUMA、1800 秒，OMP 38/FALSE/close/cores，沿用 R/S 实际完整 settings 与原 benchmark/runner，不改变 TEST_RUNS。内部总耗时为各 case 中位数之和，不是官方评分。

| W 成员 | source_parent | diagnostic_source_version | 真实诊断要求 | W 角色 |
|---|---|---|---|---|
| C26-r26 | 无，新建未变 C6 | 无 | 原样 C6 控制 | 前控制 |
| C52-row7x3shared2 | C51-row7x3u1 | C52-row7x3shared2 | 自身 T1582134 / 37128 | 唯一初筛候选 |
| C51-r2 | C51-row7x3u1 | C51-row7x3u1 | 原字节自身 Q1581822 / 37128 | 背景参考，禁止晋级或确认资格 |
| C26-r27 | 无，新建未变 C6 | 无 | 原样 C6 控制 | 后主基线 |

source_parent 表示源码来源，diagnostic_source_version 表示验证这份字节的原候选；两字段独立存储。C52 固定 conv2d.c SHA `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`；C51-r2 必须复制原 C51 的 `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`。其他三个文件与 C6 完全一致。C51-r2 的实际版本 ID 没有 ref 后缀，metadata 明确 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false、prior_confirmation_passed=false；W 不构成 S 的失败确认重试。

提交入口复用已审 S/R 的完整记录验证：R1581911 原48样本初筛保留，S1582067 原36样本及 confirmation_passed=false 保留。S 每一数组、三成员实际 scheduler/job/system/wrapper、同组机器、源码、设置及标准比较结果均校验，不能筛掉 54.13 ms 慢样本、合并 R/S/W 或改结论。Gfalse/Jtrue/Kfalse、N/R 的 C40 参考限制继续只读核对，不写 R/S/C40。

T 已由 root 真正验收冻结，准备时只读看到了 `.runs/conv/C52-row7x3shared2/sve-correctness-sep13t/validation.json` 的 passed/complete、job1582134、37128 及 `freeze-source.json`。这些事实不代表 W 已获提交许可。未来 GO 会重新要求真实冻结完整内容：19 个有序 stage 退出全0，scheduler/job/system/wrapper0，六 VL16/32/64×线程1/4，每配置 full4784/dispatch972/direct432、入口756/1080、mask1/15、旧 helper 入口非零，实际编译 argv、source manifest 与 allocation 相符。

T 汇编必须是 C52 自身未插桩产物及完整审查：7行×3VL/21acc，13个语义阶段 input_0..5/shared/trailing_0..5，shared 内 paired/odd_remainder 两个真实 block，共14个不重叠范围。paired 每次2列、42 FMUL/42 FADD；余列1列、21/21，允许真实 loop 或 straight_line；其他12阶段各1列。分别保存实际 derived_counts 及按列归一化计数、完整 helper/dispatch/ABI/转换/栈解释、全源 FMA0 和冻结同字节汇编。GO 不把 Q 的旧计数当 T，也不硬编码123/63指令或零 spill为性能门槛。Q 原冻结检查直接复用已审 R 定义，仅证明 byte-identical C51 参考。

串行门禁只查询固定 R1581911、S1582067、T1582134，以及实际存在的 P job.json 与明确 W campaign/四成员 cluster.json；不沿用 R 的广泛历史扫描。P 不存在不阻塞；存在但 ID 缺失、已知身份变化、查询失败、非终态、缺整数 job/system 退出码均阻塞。按 ID 去重，每次查询最多45秒。该门禁不替代 root 的唯一提交协调。campaign 先于 new/checkpoint 排他预约；任何已有 W campaign、已占用新 ID 或 C52 cluster.json 都禁止重复提交。上传或提交结果不明时保留预留并恢复原 ID，不删除重来。

record 只恢复保存的原 W 作业，实际 SUCCEEDED 与所有退出0后取回原件。通用机器、case维度与 checks 复用已审 S/R；W 实现自己的固定成员/来源映射。保留 experiment.json 的创建时 hash 快照，要求 prepared record、当前源与实际上传 manifest 完全一致，再只在内存 metadata 视图中适配 source_hashes。已通过记录验证后跳过，失败记录不能覆盖；status/fetch 外层日志使用排他创建的时间戳文件。遇到 schema/解析问题保留第一次输出和原件，停止报 root，不修改测量、门槛或重新测量。

compare 必须拥有全部48 PASS样本与完整四成员实际环境/退出；沿用已审 R 的 `comparison` 包装及 `experiment.comparison` 原规则。C52 对前、后 C6 **分别**要求总中位数收益严格大于 max(1%, 两版本所有 case 的 spread)，且每 case 退化不超过1%，第一 case 没有例外。只有两端都 eligible 才标记 qualified_for_confirmation，留给 root 决定下一步；不自动确认。

C52 对 C51-r2 的 `source_parent_reference_comparison` 单独保留完整收益、门槛、case 数据和 eligible，绝不能替代两端 C6 门槛，也不能给参考版确认资格。它比较同组两份完整实现，不能把差值归因成纯回边或单指令成本。四成员所有慢样本、数组、中位数、spread、理由都进入 campaign results。只写本组四 record 和 W campaign；C51-r2 始终不进入 confirmation_pending，Sfalse 不改。没有自动 promote、ZIP、发布或失败确认重试。

以下仅为 root 审后未来接口；本次未执行：

```text
python3 .runs/conv/sep13w-submit-performance.py --go
python3 .runs/conv/sep13w-record-group.py
python3 .runs/conv/sep13w-compare.py
```

状态等待沿用唯一保存的 job；每次原始 stdout/stderr、退出码和工具失败先独立保存。没有 W job 时，不能调用 record/compare 或把准备说明写成成绩。本轮交付后 STOP，等待 root 审查。
