# CONV AD：C55 shared 三列展开同分配初筛（仅准备）

固定顺序为 **C26-r32 / C55-row7x3shared3 / C52-r3（参考）/ C26-r33**。准备前已只读确认三个新控制/参考 ID 的 run/record 及 AD campaign 不存在；C55 已有 prepared 源。此次只编辑 sep13ad-* 三工具、README、静态说明和差异，不导入/运行工具，不 SSH、new/checkpoint、创建版本/作业或改变 records/source/best。未来执行须 root 审后明确 GO，由 root 唯一提交。

|AD 成员|source_parent|diagnostic_source_version|要求的实际诊断|角色|
|---|---|---|---|---|
|C26-r32|无，未变 C6|无|原样 C6 控制|前控制|
|C55-row7x3shared3|C52-row7x3shared2|C55-row7x3shared3|自身 AC1582860，44328，须真实验收冻结|唯一初筛候选|
|C52-r3|C52-row7x3shared2|C52-row7x3shared2|原字节自身 T1582134，37128|参考，禁止确认与晋级|
|C26-r33|无，未变 C6|无|原样 C6 控制|后主基线|

C55 conv2d.c 固定 SHA `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`；C52-r3 必须复制原 C52/T 的 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。source_parent 与 diagnostic_source_version 独立保存。README、官方 benchmark、runner 与当前 C6 原字节一致。参考元数据固定 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false，并保留 prior_confirmation_version=C52-r1 / job1582410 / passed=false；不得成为 Y 失败确认的重试。

每成员三套原始完整官方 benchmark，共4×3×4=48个样本。完整复用已审 AB/W/R 设置：GCC10.3.1、generic、38 CPU、24576 MiB、单 packed NUMA、1800秒；OMP38/FALSE/close/cores，原 TEST_RUNS、flags、benchmark/runner 不变。内部总耗时是各 case 中位数之和，不是官方分数。

前史入口为原 AB1582814：完整48 PASS、所有成员原源码/数组/机器/设置/scheduler/job/system/wrapper 身份与退出均需核对，C54 qualified_for_confirmation=false、两端 eligible=false、confirmation_pending=[] 保持。C54 的两端及 C52-r2 辅助比较从原数组重新核对；全部慢样本保留，包括 D 的371.96 ms。原 C52-r2 即使数值 eligible，也继续只读保留 reference_only/promotionfalse/qualifiedfalse。复用 AB 的既有定义继续保留 Y/S false、W/R/N/C40 历史限制，不写这些旧记录。

C55 只接受 `.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac` 的实际 passed/complete 及 freeze-source.json。AC 原 job.json 已只读核实为1582860，工具固定这个真实 ID，并关联原传输清单、冻结 job、validation、源码、scheduler.log、raw 和 assembly；身份变化、缺件、失败、未完整验收或未冻结均阻止 AD。原 T/AA 的数值或机器码不替代 C55 自身通过，已有 AC 数值日志也不等于完整验收。

AC 数值合同保持44328：六 VL16/32/64×线程1/4，每配置 full5744/dispatch1212/direct432，总34464/7272/2592，runner0；entries1236/1080、mask1/15、旧 helper 入口非零。full 家族 core3888/narrow144/small720/larger32/quad_boundary960，dispatch core972/quad_boundary240。`quad_boundary` 是沿用 AA checker 的网格名，不能解释成 C55 四列执行；kw1/2跳三列 main，kw3进入，kw4/5余1/2，kw6/7/8覆盖两轮后余0/1/2，kw15/81长整轮。实际 GCC argv、19个有序 stage 全0、scheduler/job/system/wrapper全0及38 CPU单NUMA均必需。

AC 汇编 schema=`ac-shared3-paths-v1`，shape7rows/3VL/21acc、13语义阶段，shared_triple_and_remainder_reviewed=true。shared_unroll 为 main_columns3/remainder_source_columns1/remainder_max_columns2/other_stage_columns1。shared.blocks 的 role 为 triple_main/u1_remainder：main每轮3列；u1 loop每轮1列，直线可为1或2列。每块可含多个实际 ranges，derived_counts 汇总整个工作块并按 work 归一化，FMUL/FADD 各为21×work。remainder_paths 必须覆盖0/1/2，按有序 sequence 的 executions×work 核对动态工作量；直线不能假称循环。范围在完整 helper 内互不重叠，region count 由实际范围派生，不固定14或其它数量。

全部 helper/clone、另外12个u1阶段、转场/reset、dispatch、ABI、标量/地址栈与 Z/Q/谓词 spill 均需真实完整审查，FMA须实际为0。parent_codegen_comparison 仍绑定原 C52/T1582134 源与真实 `.s`，只作背景分析；不要求零 spill、不硬编码指令总数、不凭计数宣称速度。

串行门禁仅检查固定 AC1582860、AB1582814、AA1582656、Y1582410、X1582372、T1582134 及明确的 P/AD reservations；不扫描队友。P无文件不占用；未知/变化的 ID、查询失败、非终态、缺整数 job/system 退出码都阻塞。AD campaign/四成员 manifest 一旦存在即禁止重复提交。按 ID 去重，单次查询最多45秒；root仍负责唯一调度协调。

提交先读完所有门禁，再在共享 workflow lock 内重新核对历史/C6/source/ID，保存排他 campaign 后才 new/checkpoint。上传、提交或连接结果不明时保留预留并恢复原 job，不能删除重投。record只取回该保存作业：真实 SUCCEEDED/全部退出0后保留原件；prepared/current/submitted hash须一致，creation metadata的原 hash快照不改，只在内存视图适配。已录且一致的记录跳过，失败或 schema差异保留首次输出并停报root，不重测。

compare仅使用AD全部48原样本。C55分别对前、后未变C6要求总中位数收益 **严格大于 max(1%, 两版本所有 case spread)**，且任何 case退化不超过1%，第一case没有例外。两端都 eligible 才标初筛 qualified_for_confirmation；下一步交root，不自动确认。C55对C52-r3的完整辅助比较单独保存，不能替代C6门槛或赋予参考版确认资格，也不能把整体差异归因于单条指令成本。

只写本组四记录与AD campaign，保存全部慢样本、中位数、spread、理由及参考限制。当前C6、AB C54false、Y/Sfalse保持；无自动确认、ZIP、晋级、发布或失败确认重试。

未来接口仅供root审后调用，本次未执行：

```text
python3 .runs/conv/sep13ad-submit-performance.py --go
python3 .runs/conv/sep13ad-record-group.py
python3 .runs/conv/sep13ad-compare.py
```

完整相对AB差异在 sep13ad-from-ab.patch，静态范围在 sep13ad-STATIC_REVIEW.md。执行者需逐次保存原stdout/stderr/退出；无AD job时不能record/compare。
