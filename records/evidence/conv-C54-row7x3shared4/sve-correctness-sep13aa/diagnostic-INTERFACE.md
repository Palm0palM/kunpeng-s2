# AA：C54 独立诊断与真实 shared4 汇编接口

本流程仅属于 `C54-row7x3shared4`，source parent=`C52-row7x3shared2`。最终生产源 SHA256 固定为 `fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88`。五文件传输源已首清单冻结；driver/prepared/提交规则见 `SUBMISSION_INTERFACE.md`。父 T1582134 的37128 PASS和汇编只属于C52，不是AA结果。准备者没有运行或导入新工具，未执行SSH/编译/数值/接受/冻结。

## 数值与提交身份

六配置是SVE_BYTES={16,32,64}×线程={1,4}，每worker实际VL和线程数必须匹配。每配置 full5744、dispatch1212、direct432，共7388；六配置分别34464/7272/2592，总44328，runner0。full必须精确返回 `FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32 quad_boundary=960`；dispatch必须返回 `DISPATCH_MATRIX_COUNTS core=972 quad_boundary=240`。dispatch实际rowseven入口1236、direct1080；两套mask线程1为1、线程4为15，旧prefix/tail/pair/triple/quad套内非零。

原T矩阵全保留；新增六宽3L/6L±1×kh7/8×kw4..8×oh7/8/14/28，full四分配、dispatch固定pad1/leading0。详见批准的 `../sep13aa-diagnostic-plan.md`。kw4/5/6/7覆盖quad后余数0/1/2/3，kw8覆盖第二轮，原kw15/81保留长循环。kh7/8覆盖一个/两个shared输入行，宽6L/6L+1覆盖tile重置，oh28覆盖四worker。direct仍kh1..6×kw1..3，验证防御而非shared。入口/mask不是内部quad阶段计数。

scalar参考、逐位memcmp、只读input/kernel、分配边界PROT_NONE、页内外围canary及output poison保持；无逐行guard、sanitizer、官方runner、direct ow1或L/2L±1新增范围。十九stage-exits必须精确有序全0、wrapper0，原scheduler必须SUCCEEDED且job/system均0。真实GCC10.3.1、三条实际xtrace编译argv、38CPU单NUMA、五返回源字节/SHA、完整六配置日志全部绑定；打印BUILD_COMMAND不能替代实际argv。

初始 `prepared.json` 永久保留prepared/compiled=false/executed=false/verified=false，不是运行结果；`expected_checks={full_per_configuration:5744,dispatch_per_configuration:1212,direct_per_configuration:432,configurations:6,total:44328}`；`expected_rowseven_entries={dispatch_per_configuration:1236,direct_per_configuration:1080}`；`full_matrix_counts`和`dispatch_matrix_counts`同上述家族。形状字段为rows_per_group=7/vectors_per_row=3/accumulators=21。

阶段契约字段为 `expected_semantic_stage_count=13`、`shared_kernel_columns_per_iteration=4`、`shared_remainder_source_columns_per_iteration=1`、`shared_remainder_max_columns=3`、`other_stage_kernel_columns_per_iteration=1`、`assembly_review_schema="aa-shared4-paths-v1"`。这些是源契约，不是实际PC或机器统计。

唯一实际job路径为 `C54-row7x3shared4/job.json`，预约前无该文件；完整冻结目标为 `.runs/conv/C54-row7x3shared4/sve-correctness-sep13aa`，原件live目录为本目录的候选子目录。driver串行门禁固定Y1582410/W1582256/S1582067/T1582134/X1582372和现存P/AA预约，不扫描队友。固定job缺失/变更、预约未知、查询失败/非terminal均阻塞；prepared无job不占用。唯一root --go才可提交；不确定提交只对账原件，不重试。

## 待返回的 assembly-review.json

不得在准备阶段创建填有PASS、PC、行号或spill数字的review模板。实际生产未插桩 `.s` 返回后，审查人填写以下字段；接受器重新从实际文本计算机器数量。没有 `.o`，不声称对象反汇编。

顶层精确身份：`schema="aa-shared4-paths-v1"`、candidate、job_id、source_sha256、compiler_version="10.3.1"、assembly_sha256。以下布尔均需实际审完才true：review_complete、production_uninstrumented、whole_helper_stack_reviewed、all_stages_and_transitions_reviewed、abi_saves_distinguished、dispatch_reviewed、shared_quad_and_remainder_reviewed。`whole_source_fma_count=0`须由全.s扫描验证；`whole_machine_code_identical_claimed=false`表示未用父机器码替代本版。

`shape={rows_per_group:7,vectors_per_row:3,accumulators:21}`；`shared_unroll={main_columns:4,remainder_source_columns:1,remainder_max_columns:3,other_stage_columns:1}`。不使用T的shared_pair_and_remainder_reviewed、paired_columns、odd_remainder_columns或固定arithmetic_region_count_per_helper=14。

`helpers`必须精确列出实际`.type ... %function`中全部conv_sve_rowseven及其clone，每个symbol的line_start/line_end覆盖标签到.size的实际全函数。必填非空说明：stack_frame_description、spill_notes、transition_spill_review、tail_and_fallback_review、arithmetic_and_load_review、shared_index_reset_review、input_kernel_bounds_review、scalar_address_stack_review；vector_spill_loads/stores为实际非负整数。完整审ABI D保存与Z/Q/谓词spill、GPR/标量及间接栈、所有转换、21 stores、横向尾与kh<7防御，不只看主回边。

每helper的`stages`精确顺序为input_0..5/shared/trailing_0..5，共13个语义阶段。其他12stage维持T字段：stage、line_start、line_end、kernel_columns_per_iteration=1、source_mapping、spill_notes、vector_spill_loads、vector_spill_stores；实际范围不能相互重叠。编译器若改变这些u1阶段而不能如实映射，保存产物停交root审查。

shared不用虚构一个聚合PC，改填：

- source_mapping、control_flow_notes、accumulator_order_review、quad_to_remainder_review、transition_spill_review、t_and_tile_reset_review：全部非空真实说明。
- `blocks`：非空、数量不固定。每块有唯一block_id；role为`quad_main`或`u1_remainder`；region_kind为`loop`或`straight_line`；kernel_columns_per_iteration表示该实际块一次执行对应的完整源列数。quad_main为4；u1_remainder回边为1，连续直线u1序列可为1..3（只是机器聚合，不是新增源paired层）。至少一个实际quad_main loop；两种role均必须有实际证据。
- 每块`ranges`为一个或多个 `{line_start,line_end}` 实际闭区间；区间可描述同一工作单元散布在不同基本块的指令。全部范围必须在helper内、与其它块/阶段不重叠；必须是同一执行路径上的完整声明工作量，不能把互斥分支的算术相加凑数。block的source_mapping、spill_notes、entry_exit_notes、column_order_review、control_flow_evidence均必填，并据实际标号/分支解释回边或直线条件；vector_spill_loads/stores为整个block实际观察。
- `remainder_paths`：非空列表，path_id唯一。每条填整数remainder_columns、path_condition、execution_order_review及`sequence`；所有path覆盖余数集合{0,1,2,3}，允许同一余数存在多个真实控制路径。sequence按实际顺序列 `{block_id,executions}`，只引用u1_remainder块，executions为1..3；直线块只能1。所有调用的executions×work之和必须等该path的remainder_columns，余0为[]；每个实际余列块都必须至少出现在一条path。禁止用静态块数量冒充动态余列次数。

接受器对每块所有实际ranges累计 `derived_counts`，包含instructions/fmul/fmul_ordinary/fmul_indexed/fadd/ld1w/ld1rw/ld1rqw/dup/indexed_mov/ext/movprfx；`derived_counts_per_kernel_column`逐项除以声明work。每quad work4应实际84 FMUL/84 FADD；每u1工作列21/21。计数从全返回字节读取，不能预填；载入数、地址数、总指令数及spill不预设。真实范围可以含地址/控制而无算术，但整个block必须映射完整工作量。若机器再次展开成不同work、算术跨互斥路径且当前schema无法忠实描述，保留首次实际证据并停止审查schema；不能挑子范围凑84/84、改数值门槛或伪造PC。

接受器产生shared.actual_arithmetic_region_count=实际ranges数量之和；helper.actual_arithmetic_region_count=12个非shared范围+上述数量；顶层`arithmetic_region_counts`为symbol→真实范围数量映射。它们是派生变量，无固定14的要求。源仍13语义阶段；一个语义阶段可以有多个真实机器区间。

`dispatch_functions`必须精确覆盖实际conv2d及全部outlined worker，字段symbol/line_start/line_end/control_flow_notes/stack_notes，完整读原件。`parent_codegen_comparison`必填candidate="C52-row7x3shared2"、job_id="1582134"、父source_sha256=`8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`、父实际assembly_sha256、shared_work_and_schedule_review、stack_and_spill_review；接受器对实际冻结T `.s`核对哈希。比较主/余列归一化工作、地址/分支、活跃期和栈；不把源码作用域或21acc预算当零spill证明，不声称速度。

## 接受与冻结

在两工具final且root审查完成后，才可对原返回证据调用 `accept_returned.py C54-row7x3shared4`，随后 `freeze_returned.py C54-row7x3shared4`。这两个动作不包含SSH或计算。本轮准备没有运行它们。accept成功写validation.status="passed"/complete=true，实际job/scheduler/exit、total44328、full34464/dispatch7272/direct2592、六config及其family/entries/mask、source核对、19stage_exits、实际assembly全部保存。assembly包含schema、上述工作契约和真实多区间/路径、stage_count=13、fma_count=0、transitions_reviewed=true；不生成自动性能资格或提交。

每个config保存sve_bytes/threads/lanes/block_outputs_per_row=3×lanes，full_cases5744/dispatch_cases1212/direct_cases432，两个family字典，dispatch_entries1236/direct_entries1080，dispatch_worker_mask/direct_worker_mask及旧helper_entries。prepared保持首次原件；若初始validation为prepared则先原样存prepared-validation.json，禁止覆盖已最终validation。解析失败另存timestamped acceptance-failure，不伪装成算子数值FAIL。

`--failed`只接受真实scheduler/wrapper/stage失败；未知实际检查数为null，不补造汇编。freeze在共享`.runs/.workflow.lock`下审已有validation身份/实际终态与完整schema后复制原件，附三工具/接口，原.s同字节另存.assembly.txt，最后原子rename。已有target或staging拒绝覆盖；freeze-source.json记录mode=passed/failed及原job，不重写validation、不执行accept、不压比赛包。

数值通过与实际代码审查不是速度证据；真实spill不自动算数值失败。Yfalse/Sfalse保持、所有历史样本保留，不重试失败确认，不晋级。账户主用量>=40%立即停止，不用重置卡。工具准备最终交root，compute只由独立明确GO授权。
