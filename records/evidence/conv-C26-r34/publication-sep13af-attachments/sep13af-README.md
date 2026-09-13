# CONV AF：C56 三列末编译器约束同分配初筛（仅准备）

固定顺序 **C26-r34 / C56-row7shared3fence / C55-r1（参考）/ C26-r35**。准备前已只读确认三个新控制/参考 ID 的 run、record 及 AF campaign 均不存在；C56 已有 prepared 源。本次只写 sep13af-*，没有导入、执行、AST/py_compile/dry-run、SSH、new/checkpoint、预约、计算或修改记录。未来须 root 全文及独立审查后明确 GO，由 root 唯一提交。

|AF 成员|source_parent|diagnostic_source_version|要求的实际诊断|角色|
|---|---|---|---|---|
|C26-r34|无，未变 C6|无|原样 C6 控制|前控制|
|C56-row7shared3fence|C55-row7x3shared3|C56-row7shared3fence|自身 AE1583102，44328，须实际接受并冻结|唯一初筛候选|
|C55-r1|C55-row7x3shared3|C55-row7x3shared3|原字节自身 AC1582860，44328|父源码参考，禁止确认与晋级|
|C26-r35|无，未变 C6|无|原样 C6 控制|后主基线|

C56 conv2d.c 固定 SHA `6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`；C55-r1 必须复制原 C55 的 `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`。生产 README.md、bench_conv.c、run.sh 与当前 C6 原字节一致。source_parent 与 diagnostic_source_version 独立保存；首次候选身份核对用 source_parent 优先、缺省 parent，兼容标准 new/checkpoint，不改创建记录来适配。

C55-r1 固定 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false；其 prior_initial_version=C55-row7x3shared3、prior_initial_job=1582956、prior_initial_qualified_for_confirmation=false。原 AD 是 C55 初筛失败，不虚构为一次失败确认。原 Y/S confirmation=false 继续保留，AF 不能成为这些失败确认的重试。

每成员三套完整原官方 benchmark，共4×3×4=48原样本。复用最终 AD 资源和实际设置：GCC10.3.1/generic、38 CPU、24576 MiB、单 packed NUMA、1800秒、OMP38/FALSE/close/cores，原 TEST_RUNS、flags、runner 和 benchmark 不变。总中位数耗时是四个 case 中位数之和，不是官方分数。

前史入口仅重新核对最新完整 AD1582956 的48原样本，复用已审 AD 的 record、机器、manifest 与 comparison 定义；四成员源码/数组/设置、scheduler/job/system/wrapper 全0和相同机器须一致。C55 两端 eligible=false、qualified=false、confirmation_pending=[]，原 C52-r3 reference-only 限制和全部慢样本保持。更早历史只复用已审 decision 身份读取，不递归重新计算旧 campaign 样本，不写 AD/Y/S 或旧记录。

C56 必须有 `.runs/conv/C56-row7shared3fence/sve-correctness-sep13ae` 实际 passed/complete 和 freeze-source.json；AE 原1583102、传输清单、冻结 job、validation、源码、scheduler.log、raw 和实际 assembly 必须一致。缺件、失败、未完整审查或未冻结均阻止 AF。父 C55/AC 的通过不能替代 C56 自身 AE；准备文本不预填 AE PASS 或机器结果。

AE 保持44328：六组 VL16/32/64×线程1/4，每配置 full5744/dispatch1212/direct432，总34464/7272/2592，runner0；entries1236/1080、mask1/15、旧 helper 入口非零。full 家族 core3888/narrow144/small720/larger32/quad_boundary960，dispatch core972/quad_boundary240；quad_boundary 沿用真实 checker 网格名。实际 GCC argv、19有序 stage 全0、调度与 wrapper 全0、38 CPU单NUMA和源清单均必需。

AE schema=`ae-shared3-fence-paths-v1`，shape7rows/3VL/21acc、13语义阶段、main3/u1余0..2。复用 AC 的动态多 ranges、block 工作量、path sequence 与 region count 定义；不固定区域数量、指令总数或 spill 数。全部 helper/clone、其他12阶段、转场/reset、dispatch、ABI、标量/地址栈与 Z/Q/谓词 spill 均须真实完整审查，本轮 FMA0 条件不变。

新增 column_fences_reviewed=true，以及每 helper.shared 的完整 column_fence_review：source_contract 精确为三列末、每次21只读输入、0输出、memory_clobber=true、empty_template=true；四段实际解释非空，boundaries 为0/1/2且各有实际证据。schedule_tightened 和 all_accumulators_ready_before_next_column_loads 必须是实际 bool，**允许 false**。第三边界包括下一轮主循环；不要求空 asm 生成指令，不凭源码声称调度收紧。parent_codegen_comparison 必须绑定原 C55/AC1582860 的实际源和汇编，不能照搬原 C52/T 比较。

串行只检查固定 AE1583102、AD1582956、AC1582860、AB1582814、AA1582656、Y1582410、X1582372、T1582134，以及明确 P/AF reservations；不扫描队友。P 无文件不占用；未知或变化的 ID、查询失败、非终态、缺整数 job/system 退出码均阻止。按实际 ID 去重查询；AF campaign 或四成员 manifest 已存在即不得再次提交。失联或提交结果不明时保留预留，恢复原 ID，不能删除重投。

提交在共享 workflow lock 内重新核对 AD/C6/source/ID，先保存排他 campaign，再标准 new/checkpoint。每版首次补充关联字段前，排他保存 creation-experiment.json 的**原字节**；已有快照只核对不覆盖，C56 作者快照保持不变。experiment.json 按成熟流程补充 settings/source_parent/diagnostic 等关联元数据，但创建时 source_hashes 不刷新；checkpoint 更新当前 record。campaign 保存四个 creation 快照 SHA，record 再核对其不变。

record 仅恢复保存的唯一 AF job，实际 SUCCEEDED/所有退出0后取回原件。prepared record、当前生产源、上传 manifest 须一致；e.record 前仅在内存 metadata 视图适配当前 source_hashes，不覆盖独立 creation 快照或创建时 hash。已录且完全一致者跳过；失败记录、schema 差异或首次失败输出保留并停报 root，不重测、不放宽门槛。

compare 仅使用全部 AF48：C56 分别对前后 C6 要求总中位数收益 **严格大于 max(1%, 两版本全部 case spread)**，且任何 case 退化不超过1%，第一例无例外。两端均 eligible 才标初筛 qualified_for_confirmation，后续由 root 决定。C56 对 C55-r1 的完整辅助比较单独保存，不能替代 C6 门槛或赋予参考确认资格；它是整体实现比较，不能解释为单条 fence 的隔离成本。

只有 AF 四记录与 campaign 可接收本轮比较字段；C6、AD C55false、Y/Sfalse 保持。无自动确认、ZIP、晋级或发布，失败确认不重复。未来接口供 root 审后使用，本次未执行：

```text
python3 .runs/conv/sep13af-submit-performance.py --go
python3 .runs/conv/sep13af-record-group.py
python3 .runs/conv/sep13af-compare.py
```

完整 AD→AF 五文件差异见 sep13af-from-ad.patch，作者静态说明见 sep13af-STATIC_REVIEW.md，实际文件身份见 sep13af-PREPARED_FILES.json。执行者逐次保存原 stdout/stderr/退出；没有真实 AF job 时不能 record/compare。主额度达到40%停止，不用重置卡。
