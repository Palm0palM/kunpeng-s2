# AE：C56 shared3 列末约束的独立诊断接口

仅适用于 `C56-row7shared3fence`，source parent=`C55-row7x3shared3`。root 转达作者 final/STOP 并完成独立源审后，已首次复制112355字节生产源，SHA256=`6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`；五文件/清单/三工具均完成准备。原 AC1582860 是工具、两个 checker 和父代码生成比较来源，不能提供 C56 PASS。所有示例入口均须 root 后续审查/GO，准备者未导入或执行。

源合同为 7 rows × 3VL、21 accumulators；13 semantic stages；shared main 三列 `ik/ik+1/ik+2`，原 u1 余数 0..2；其他十二阶段仍单列。唯一新增假设为三个完整列末的空 asm，各 21 个只读 `w` 输入、0 输出、`memory` clobber。它是编译器约束，不是硬件 fence，不能从源码推断实际调度或零 spill。

## 数值、资源与首次源合同

两个 C checker 必须与原 AC 字节相同。继承 `quad_boundary` 家族名以及 C54/four-column 注释仅表示原网格/来源，不表示本版主循环四列。六配置 SVE_BYTES={16,32,64} × threads={1,4}，worker 实际 VL/team 必须匹配。

| 数量 | full | dispatch | direct | 总数 |
|---|---:|---:|---:|---:|
| 每配置 | 5744 | 1212 | 432 | 7388 |
| 六配置 | 34464 | 7272 | 2592 | 44328 |

full 家族精确为 core3888/narrow144/small720/larger32/quad_boundary960；dispatch 为 core972/quad_boundary240。原 core：六宽 × kh6..8 × kw1..3 × 18个 oh × 四分配；18个 oh=1..15/21/22/28。narrow 是 ow1 × kh6..8 × kw1..3 × oh1/7/13/28 × 四分配；small 是三宽1/3L−1/3L+1 × kh1..5 × kw1..3 × 同四个oh × 四分配；larger 保留10×7、9×8、15×15、81×81两个oh四分配。新增于祖模板的网格为六宽3L/6L±1 × kh7/8 × kw4..8 × oh7/8/14/28；full 四分配，dispatch 固定 pad1/leading0。L=SVE_BYTES/4。

dispatch 的 rowseven 入口1236，direct1080，worker mask1/15；原逐 case 入口增量校验不改。direct 三宽3L−1/3L/3L+1 × kh1..6 × kw1..3 × oh7/28 × 四分配，共432，仅覆盖防御fallback，不进入shared。旧 prefix/tail/pair/triple/quad 必须 suite 累计非零，不能声称每 case 的尾路线均已单独证明。

kw1/2跳过main；3一轮；4/5一轮后余1/2；6/7/8两轮后余0/1/2；15/81长循环。kh7/8覆盖跨t，六宽和oh28覆盖跨tile/组重置。没有新增可选kw79/80、direct ow1、L/2L±1网格、逐行guard或sanitizer。保留逐位 scalar reference、只读input/kernel、分配两端PROT_NONE、页内canary、output poison。没有官方runner或性能测量。

资源固定38 CPU、24576 MiB、1 packed NUMA、1800秒，GCC10.3.1/generic。实际 xtrace 中三条 gcc argv 必须与原 AC 完全一致：`-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3`；full checker 与生产源分开translation unit，只有独立dispatch插桩，汇编从未插桩生产源 `-S` 获得。19阶段为allocation/compiler/manifest/build-guard、六guard、build-dispatch、六dispatch、build-assembly/complete。接受须真实scheduler SUCCEEDED、job/system/wrapper全0、19有序stage全0、完整12份数值日志；只打印编译命令或总PASS不足。

首次传输严格五文件：conv2d.c、两个原 AC checker、candidate.env、remote_job.sh；env/wrapper只改身份及实际源SHA。source-hashes.json和source-manifest.json分别保留实际SHA及bytes/SHA，prepared.json永远保持 prepared/complete=false/compiled=false/executed=false/verified=false/actual_job_id=null。完整源与checkpoint、原job manifest及返回五文件均须一致，首次清单不得静默刷新。

标准new/checkpoint的父字段为parent；未来性能record若存在source_parent则优先它。因此driver/accept使用`record.get('source_parent', record.get('parent'))`核对C55，不能改写creation metadata或record来适配。首次准备已核对候选source-audit的父C55/AC1582860和当前四文件SHA；第一次错误读取source_parent的KeyError原输出保留在preparation-failure-1.json。这是只读准备schema兼容，未放宽任何数值条件。

prepared 的 expected_checks 为 full5744/dispatch1212/direct432/configurations6/total44328；expected_rowseven_entries 为1236/1080；expected_semantic_stage_count=13、shared_kernel_columns_per_iteration=3、shared_remainder_source_columns_per_iteration=1、shared_remainder_max_columns=2、other_stage_kernel_columns_per_iteration=1。assembly_review_schema=`ae-shared3-fence-paths-v1`。新增 column_fence_contract 精确为：

```json
{"source_fences_per_main_iteration":3,"input_accumulators_per_fence":21,"output_operands":0,"memory_clobber":true,"empty_template":true}
```

## 原件返回后的 assembly-review.json

准备不创建 assembly-review、PC、行号、机器计数、spill 或 PASS。真实原件返回后，由完整实际函数审查填写：schema=`ae-shared3-fence-paths-v1`；candidate/job_id/source_sha256/compiler_version=10.3.1/assembly_sha256 全部绑定本版原件。review_complete、production_uninstrumented、whole_helper_stack_reviewed、all_stages_and_transitions_reviewed、abi_saves_distinguished、dispatch_reviewed、shared_triple_and_remainder_reviewed、column_fences_reviewed 只有实际完成对应审查才能为true。whole_source_fma_count必须全.s实际为0；whole_machine_code_identical_claimed=false。

shape={rows_per_group:7,vectors_per_row:3,accumulators:21}；shared_unroll={main_columns:3,remainder_source_columns:1,remainder_max_columns:2,other_stage_columns:1}。helpers须精确列实际conv_sve_rowseven及全部clone，symbol/line_start/line_end覆盖实际label到.size。每helper须有非空stack_frame_description、spill_notes、transition_spill_review、tail_and_fallback_review、arithmetic_and_load_review、shared_index_reset_review、input_kernel_bounds_review、scalar_address_stack_review及实际非负vector_spill_loads/stores。区分Z/Q/谓词、低64位D ABI和标量/间接栈，审查所有阶段转换、21输出、横向尾和kh<7防御。

stages精确为input_0..5/shared/trailing_0..5。其他12阶段沿用单真实区间、kernel_columns_per_iteration=1、source_mapping/spill_notes/vector_spill_loads/stores。shared要求非空source_mapping、control_flow_notes、accumulator_order_review、triple_to_remainder_review、transition_spill_review、t_and_tile_reset_review；其blocks/path规则保持 AC：

- blocks 非空、block_id唯一，role集合恰为triple_main/u1_remainder，region_kind为loop或straight_line。main完整work3且至少一个真实loop；余数loop work1，straight_line work1或2。
- 每block有一或多个真实ranges[{line_start,line_end}]，全部在helper内且互不重叠，也不与其他stage重叠。source_mapping/spill_notes/entry_exit_notes/column_order_review/control_flow_evidence必填，vector_spill_loads/stores为实际观察。分散区间须属于同一路径，不能把互斥分支相加凑工作。
- remainder_paths的path_id唯一，remainder_columns覆盖{0,1,2}。每path有path_condition/execution_order_review与有序sequence[{block_id,executions}]；只能引用u1_remainder，executions=1或2，straight_line只可1。总executions×work等于余数，余0为[]，每个实际余数block至少被一条路径引用。

接受器从实际ranges重算derived_counts与逐work的derived_counts_per_kernel_column。完整main为63 FMUL/63 FADD，每余数工作列21/21；载入/地址/总指令/spill数不预设。shared.actual_arithmetic_region_count、helper.actual_arithmetic_region_count和顶层arithmetic_region_counts由实际ranges派生，绝不固定14。若真实lowering不能表达为本合同，保留原件和首次解析失败再交root审，不能借原AC行号或挑区间。

每helper的shared新增 **column_fence_review**：

- source_contract等于上述column_fence_contract；actual_schedule_review、cross_column_motion_review、loop_boundary_review、spill_relocation_review均为非空实际解释。
- schedule_tightened为实际bool，**允许false**。boundaries依序三项column_index=0/1/2，各有非空actual_evidence和bool all_accumulators_ready_before_next_column_loads。column_index=2 的第三个边界包括下一主循环迭代。追踪全部21条本列FADD与后列LD1W/LD1RW的真实依赖/位置，不要求空asm产生指令或可见标号，也不伪造fence PC。
- 解释三处约束是否只读21输入、是否实际限制跨列/跨迭代调度，以及主循环减少的spill是否移至列边界、转场或函数外围。审查完成不等于调度收紧；调度未收紧、spill非零也不冒充数值失败。

dispatch_functions须完整覆盖实际conv2d/outlined workers的label到.size及control_flow_notes/stack_notes。parent_codegen_comparison固定candidate=`C55-row7x3shared3`、job_id=`1582860`、source_sha256=`cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`，assembly_sha256须匹配其`sve-correctness-sep13ac/raw/conv2d-sve.s`真实字节。shared_work_and_schedule_review/stack_and_spill_review必须比较原C55三列189指令、5Z读5写、全helper30/45及880+5VL框架的实际含义；这些仅是父参照，不是本版预期机器结果或提速保证。

## 串行、接受与冻结

driver仅检查固定AD1582956/AC1582860/AB1582814/AA1582656/Y1582410/X1582372/T1582134，以及现存P/AE job.json。AD/AB各原四成员cluster.json须与固定campaign ID相同；缺固定证据、未对账/冲突ID、查询失败、非terminal或缺真实job/system退出都阻塞。无P/AE job.json的prepared目录不阻塞。不扫描队友，不取消作业，root始终唯一提交者。

提交示例（准备者未执行）：

```text
python3 .runs/conv/sep13ae-checks/driver.py C56-row7shared3fence config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13ae-checks/driver.py C56-row7shared3fence config/conv-sep12.local.json status
python3 .runs/conv/sep13ae-checks/driver.py C56-row7shared3fence config/conv-sep12.local.json fetch
python3 .runs/conv/sep13ae-checks/accept_returned.py C56-row7shared3fence
python3 .runs/conv/sep13ae-checks/freeze_returned.py C56-row7shared3fence
```

submit须显式--go且无job.json；先排他open('x')预约，再传输/提交。不确定或失败保留预约/日志，禁止重投，只对账原ID。status/fetch不自动轮询；外层间隔至少45秒，每次stdout/stderr/exit独立保存。fetch只在真terminal后返回文本/.s，拒绝覆盖异字节；不传对象。

accept保留原prepared；拒绝覆盖final validation。解析问题另存timestamped acceptance-failure，不捏造算子FAIL；--failed仅处理原调度/wrapper/stage真实失败，未知实际次数为null。普通validation记录44328完整六配置、19stage/全部退出、实际argv/源/assembly，performance_measured=false，无自动性能提交。

freeze仅在共享workflow锁内核对既有接受结果/原父比较/实际fence字段，复制原件到`sve-correctness-sep13ae`，附三工具及本接口；原.s同字节生成.assembly.txt，原子rename完成。已有target/staging一律拒绝覆盖，失败现场保留；不执行accept、算子、性能、包、晋级或发布。Yfalse/Sfalse与C6历史保持。额度达到40%停止，不用重置卡。
