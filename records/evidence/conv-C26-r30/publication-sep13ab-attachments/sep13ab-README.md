# CONV AB：C54 shared 四列展开的同分配初筛（仅准备）

固定顺序为 **C26-r30 / C54-row7x3shared4 / C52-r2（参考）/ C26-r31**。新 C26-r30、C52-r2、C26-r31 的 run/record 和 AB campaign 在准备前只读确认均不存在。C54 已有源码准备记录，AB 未修改候选或任何历史记录。本次只编辑三工具、本说明与静态差异，不导入/执行这些工具，不 SSH、不 new/checkpoint、不创建 campaign/job，不编译或测试。未来须 root 审查后明确 GO，由 root 唯一提交。

|AB 成员|source_parent|diagnostic_source_version|要求的独立诊断|角色|
|---|---|---|---|---|
|C26-r30|无，未变 C6|无|原样 C6 控制|前控制|
|C54-row7x3shared4|C52-row7x3shared2|C54-row7x3shared4|自身 AA1582656，44328，须实际通过且冻结|唯一初筛候选|
|C52-r2|C52-row7x3shared2|C52-row7x3shared2|原字节自身 T1582134，37128|参考，禁止晋级和确认资格|
|C26-r31|无，未变 C6|无|原样 C6 控制|后主基线|

source_parent 和 diagnostic_source_version 分开保存。C54 固定源 SHA `fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88`；C52-r2 只能复制原 C52/T 的 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。README、官方 benchmark、runner 三文件与 C6 保持一致。C52-r2 明确 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false、prior_confirmation_version=C52-r1、prior_confirmation_passed=false、prior_confirmation_job=1582410；它不构成失败 Y 确认的重试。

每成员三套原始完整官方 benchmark，共 4×3×4=48 个样本。复用 W/R 已审资源和 settings 验证：GCC10.3.1、generic、38 CPU、24576 MiB、单 packed NUMA、1800 秒，OMP 38/FALSE/close/cores。沿用原 benchmark/runner、TEST_RUNS 和编译 flags；总耗时是各 case 中位数之和这一内部指标。

历史入口以 Y1582410 的完整36 PASS及 confirmation_passed=false 为事实，逐成员校验原数组、源码、设置、机器、scheduler/job/system/wrapper 和标准两端比较。已审 Y 定义继续只读核对 W48、S36、R48 与原 C40 限制；Y/S false、W 的 C51-r2 参考身份和所有慢样本不改变。AB 的比较只能使用自己的48样本，禁止跨组拼接或挑选。

C54 只能使用 `.runs/conv/C54-row7x3shared4/sve-correctness-sep13aa` 的实际验证与冻结证据。准备开始时没有预填 AA ID；root 唯一提交后，本任务只读 `.runs/conv/sep13aa-checks/C54-row7x3shared4/job.json`，绑定实际原 ID1582656。该 ID 不代表 AA 已通过。门禁要求其原源码身份与 validation、冻结 job、调度日志、raw 和 source manifest 一致；ID 变化、缺文件、诊断不完整或未冻结均阻止 AB 创建。父 T37128 不证明 C54 四列主循环；C52-r2 的 T 门禁直接复用 W 已审定义。

AA 门禁要求19个有序 stage 全0、scheduler/job/system/wrapper 全0、六个 VL16/32/64 ×线程1/4 配置；每配置 full5744/dispatch1212/direct432，共34464/7272/2592=44328，入口1236/1080、mask1/15及旧 helper 入口非零。full 家族 core3888/narrow144/small720/larger32/quad_boundary960、dispatch 家族 core972/quad_boundary240 必须相符；quad_boundary 明确覆盖 kw4/5/6/7/8 与 kh7/8、横向3L/6L邻界及 oh7/8/14/28。实际 GCC argv、38 CPU 单 NUMA 分配、生产未插桩汇编和完整 helper/dispatch/ABI/转换/栈审查均必需。

AA 汇编 schema 固定 `aa-shared4-paths-v1`：7行×3VL/21acc、13语义阶段；shared.blocks 每块有独立 block_id、quad_main/u1_remainder 角色、loop/straight_line 类型、实际工作列数及一个或多个 ranges。quad main 每轮4列，u1 loop 每轮1列，连续直线 u1 可含1..3列；每块实际 FMUL/FADD 必须各为21×工作列数。remainder_paths 按0..3余数保存有序 sequence，并核对 executions×工作量。各实际范围须在完整 helper 内且互不重叠，区域数由真实范围派生，绝不固定为14。其它12阶段各1列。门禁还关联父 T 实际源码/汇编的调度及栈比较，但不把其计数或零 spill 当 C54 结论，也不把零 spill 设为性能门槛。完整差异见 `sep13ab-from-w.patch` 与 `sep13ab-STATIC_REVIEW.md`。

串行门禁仅查询固定 Y1582410、X1582372、T1582134、原 AA ID，以及已存在的明确 P/AB reservation；不扫描其它协作者任务。P 不存在不阻塞，存在且未获固定 ID 对账则阻塞；AB campaign/四成员 manifest 一旦存在也禁止重投。已知 ID 变化、查询失败、非终态或 job/system 整数退出码缺失均阻止提交。按 ID 去重，单次查询有45秒上限。该门禁不替代 root 的唯一提交协调。

提交入口先做全部只读门禁，再在公共锁内复核 C6、历史、来源及 ID 未占用，保存排他 campaign，之后才 new/checkpoint 三个新成员并登记四成员。任何保存后的预约、上传/提交结果不明或连接中断都必须恢复原作业，不删除预留或重投。创建时 metadata 的 source_hashes 快照保留；最终 prepared record、当前源与实际上传 manifest 必须一致。

record 只处理保存的原 AB 作业；真实 SUCCEEDED、所有退出0后取回原件，复用 W 成熟 case/checks/机器验证。只在内存 metadata 视图适配当前 source_hashes，不修改 creation 快照。已通过且完全相符的记录跳过；失败记录和首次工具输出保留，schema/解析差异先报 root，不重新测量或放宽校验。

compare 需要全部48 PASS和四成员完整同组环境/退出。沿用 R/W 原比较规则：C54 对前、后 C6 **分别**要求总中位数收益严格大于 max(1%, 两版本全部 case spread)，每个 case 退化不超过1%，第一 case 无例外。仅两端都 eligible 才标 qualified_for_confirmation，交 root 决定下一步；工具不自动确认。

C54 对 C52-r2 的辅助比较单独保存完整数组、中位数、spread、收益、门槛及 eligible；不能代替任一 C6 门槛，不能给参考版确认资格，也不能把整体差异归因为纯循环控制成本。所有慢样本保留，只写本组四 record 和 AB campaign。当前 C6 保持；无自动 ZIP、晋级、发布或失败确认重试。

以下仅为 root 审后未来接口，本次未执行：

```text
python3 .runs/conv/sep13ab-submit-performance.py --go
python3 .runs/conv/sep13ab-record-group.py
python3 .runs/conv/sep13ab-compare.py
```

状态等待始终使用唯一保存 job。每次实际 stdout/stderr/退出码由执行者留存；没有 AB job 时不得 record/compare 或把准备说明当成绩。
