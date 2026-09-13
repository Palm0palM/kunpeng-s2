# AC：C55 独立诊断及 shared3 真实汇编接口

仅适用于 `C55-row7x3shared3`，source parent=`C52-row7x3shared2`。最终生产源 SHA256 `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`，与作者最终原件逐字节相同。父冻结为 T1582134；AA 只是三个工具及两个 C checker 的模板，不是 C55 通过证据。首次五文件 manifest/prepared 和提交规则见 `SUBMISSION_INTERFACE.md`。本次仅准备和轻量文本比较，没有导入或运行新工具、SSH、预约、编译、数值、接受或冻结。

## 数值合同与范围

两个 C checker 完整复用 AA 最终字节。`quad_boundary` 家族名、C54/four-column 注释是继承网格及来源名称；C55 shared 主循环实际是三列，不能把该名称当四列执行证据。SVE_BYTES={16,32,64}×线程={1,4}，共六配置，worker 实际 VL/team 必须匹配。

| 数量 | full | dispatch | direct | 合计 |
|---|---:|---:|---:|---:|
| 每配置 | 5744 | 1212 | 432 | 7388 |
| 六配置 | 34464 | 7272 | 2592 | 44328 |

full 家族独立推导：core=六宽×kh6..8×kw1..3×18个oh×四分配=3888；narrow=ow1×kh6..8×kw1..3×oh1/7/13/28×四分配=144；small=三个ow×kh1..5×kw1..3×四oh×四分配=720；larger=四kernel×两oh×四分配=32；继承 quad_boundary=六宽×kh7/8×kw4..8×oh7/8/14/28×四分配=960。六宽为3L−1/3L/3L+1/6L−1/6L/6L+1，L=SVE_BYTES/4。larger 保留10×7、9×8、15×15、81×81；small 三宽为1/3L−1/3L+1，direct 三宽为3L−1/3L/3L+1，direct没有ow1。

dispatch 原core972+继承网格240=1212；网格与full同维度但固定pad1/leading0。rowseven 入口原756+新增六宽×两kh×五kw×(1+1+2+4)=1236。direct=三个宽×kh1..6×kw1..3×oh7/28×四分配=432，其入口=3×6×3×4×(1+4)=1080。逐case rowseven 入口增量保持；线程1/4两套worker mask应为1/15，旧prefix/tail/pair/triple/quad套内非零。这些入口和mask不是 shared 内部阶段的动态计数。

完整日志必须有精确 `FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32 quad_boundary=960` 和 `DISPATCH_MATRIX_COUNTS core=972 quad_boundary=240`，以及5744/1212/432各自的PASS总结；不能只匹配一个总PASS。原18个oh为1..15、21、22、28，覆盖oh余1..6。kw1/2跳main，kw3一轮main，kw4/5一轮后余1/2，kw6/7/8两轮后余0/1/2，kw15/81多轮；kh7/8覆盖shared跨t，六宽与oh28覆盖多tile及多组重置。未增加作者可选kw79/80。

保留独立 scalar 参考、逐位memcmp、input/kernel只读、分配两端PROT_NONE、页内外围canary、output poison。没有逐行guard/sanitizer/官方runner，也没有补direct ow1或L/2L±1网格。direct kh1..6验证防御fallback，不进入shared。旧helper非零和worker mask均为suite累计，不是逐case尾helper路线证明。

要求原scheduler SUCCEEDED且job/system均0、wrapper0、19个stage-exits精确有序全0；实际GCC10.3.1、38CPU单NUMA、三条实际shell xtrace编译argv、五返回源字节/SHA与完整六配置日志都要匹配。生产full与scalar参考为分开translation unit，独立dispatch才插桩；严格flags和原checker未改。打印BUILD_COMMAND不能替代实际argv。无对象传输，只接收本版未插桩生产 `.s`。

prepared永远保留初始prepared/compiled=false/executed=false/verified=false。expected_checks为{full_per_configuration:5744,dispatch_per_configuration:1212,direct_per_configuration:432,configurations:6,total:44328}；expected_rowseven_entries为{dispatch_per_configuration:1236,direct_per_configuration:1080}。源形状rows_per_group=7/vectors_per_row=3/accumulators=21，expected_acc=3指vectors。expected_semantic_stage_count=13、shared_kernel_columns_per_iteration=3、shared_remainder_source_columns_per_iteration=1、shared_remainder_max_columns=2、other_stage_kernel_columns_per_iteration=1；assembly_review_schema=`ac-shared3-paths-v1`。这些是源工作合同，不是测得的机器数量。

## 真实 assembly-review.json

准备阶段不创建带PASS/PC/行号/计数/spill的review。原作业 `.s` 返回后，审查人从完整实际函数填证据，接受器从同一原件重新派生机器计数。schema=`ac-shared3-paths-v1`；candidate/job_id/source_sha256/compiler_version/assembly_sha256必须绑定本版原件。compiler_version为10.3.1。review_complete、production_uninstrumented、whole_helper_stack_reviewed、all_stages_and_transitions_reviewed、abi_saves_distinguished、dispatch_reviewed、shared_triple_and_remainder_reviewed只有实际审完才能true；whole_source_fma_count必须实际全.s扫描为0，whole_machine_code_identical_claimed=false。

shape={rows_per_group:7,vectors_per_row:3,accumulators:21}；shared_unroll={main_columns:3,remainder_source_columns:1,remainder_max_columns:2,other_stage_columns:1}。不得照搬AA quad_main或T paired/odd结构，也不能固定14或其它region数量。

helpers精确列全部实际conv_sve_rowseven及clone，symbol/line_start/line_end覆盖实际label到.size。每个helper须有非空stack_frame_description、spill_notes、transition_spill_review、tail_and_fallback_review、arithmetic_and_load_review、shared_index_reset_review、input_kernel_bounds_review、scalar_address_stack_review，以及实际非负整数vector_spill_loads/stores。完整审ABI低64位D保存、Z/Q/谓词与GPR/标量及间接栈、阶段转换、21 stores、横向尾和kh<7防御。源码局部作用域与21acc不能证明零spill。

stages精确顺序input_0..5/shared/trailing_0..5，共13语义阶段。其他12阶段保留单实际区间字段stage/line_start/line_end、kernel_columns_per_iteration=1、source_mapping、spill_notes、vector_spill_loads/stores。各范围在helper内部且不能交叠。如果实际lowering无法忠实映射，原件停交root，不挑区间补成预期。

shared字段如下：

- 非空source_mapping、control_flow_notes、accumulator_order_review、triple_to_remainder_review、transition_spill_review、t_and_tile_reset_review，解释ik→ik+1→ik+2逐acc次序、三列循环与余数转场、kh7/8跨t和每tile重置。
- blocks非空且数量不固定，block_id唯一。role集合恰为triple_main/u1_remainder；region_kind为loop或straight_line。kernel_columns_per_iteration为一次实际块完整源列工作：triple_main=3，余数loop=1，余数straight_line可为1或2（只是编译器机器聚合，不是新增源码paired层）。至少存在一个真实triple_main loop。
- 每block的ranges为一或多个{line_start,line_end}真实闭区间，须在helper内、和全部其他block/stage不交叠。不同区间可表示同一路径上分散的算术/地址控制，但不能加总互斥分支来凑工作量。block的source_mapping、spill_notes、entry_exit_notes、column_order_review、control_flow_evidence必填，以实际标号/分支支持；vector_spill_loads/stores为真实观察。
- remainder_paths非空且path_id唯一。remainder_columns为整数，覆盖集合{0,1,2}，同一余数可存在多条真实路径。每path有非空path_condition/execution_order_review和按顺序的sequence；sequence项{block_id,executions}只引用u1_remainder，executions为1或2，straight_line只可1。总executions×work必须等于余数列数，余0是[]；每个实际余数block都须被至少一条路径引用。不得把静态block个数称为动态执行次数。

接受器对每block的真实ranges累计derived_counts：instructions/fmul/fmul_ordinary/fmul_indexed/fadd/ld1w/ld1rw/ld1rqw/dup/indexed_mov/ext/movprfx，并逐项除work产生derived_counts_per_kernel_column。源映射要求完整三列实际对应63 FMUL/63 FADD、每余数工作列21/21；这些是验收工作关系，不是准备时填写的机器结果。载入数、地址数、总指令、栈/spill都不预设。区间可包含无算术的控制部分，完整block必须能解释所声明工作。若进一步展开等形态不满足当前schema，保留首次原件停止并审schema，不伪造PC/借父范围/改变数值阈值。

shared.actual_arithmetic_region_count为实际ranges数量之和；helper.actual_arithmetic_region_count为其他12范围加shared实际数量；顶层arithmetic_region_counts为symbol→实际数量。均由接受器派生，不能固定。语义阶段数仍13。

dispatch_functions精确列全部实际conv2d及outlined worker，每项symbol/line_start/line_end/control_flow_notes/stack_notes，实际label到.size完整审。parent_codegen_comparison仍是原C52-row7x3shared2/T1582134、父源SHA `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`、父实际assembly_sha256、shared_work_and_schedule_review、stack_and_spill_review。父.s哈希从原冻结T核对；比较工作归一化、地址/分支、活跃期与栈，不继承父PASS或声称速度。

## 接受、冻结和串行边界

driver串行门禁固定AA1582656/Y1582410/X1582372/T1582134，加现存P/AC和明确AB campaign/四member预约；详见SUBMISSION_INTERFACE。未知ID、ID冲突、查询失败、非terminal或缺实际退出均阻塞。root独立GO唯一提交，网络不确定只对账原预约。prepared P/AC没有job不占用；不扫描其它队友。

root全文审查完成并授权实际返回的审查后，才对原作业调用accept_returned.py C55-row7x3shared3，随后freeze_returned.py C55-row7x3shared3。准备未调用。成功validation保存原job/scheduler/exit、total44328/full34464/dispatch7272/direct2592、六config及family/entries/mask、源身份、19stage_exits和实际assembly。assembly含stage_count=13、fma_count=0、transitions_reviewed=true和真实多区间/路径，production_object_disassembly_available=false。每config还保存sve_bytes/threads/lanes/block_outputs_per_row=3×lanes。无性能资格自动计算。

首次prepared原件不变。accept拒绝覆盖已final validation；若原为prepared先原字节保存prepared-validation.json，解析异常另存timestamped acceptance-failure。--failed只接受实际scheduler/wrapper/stage失败，未知实际检查数为null；准备/解析问题不当算子FAIL。

freeze在共享workflow lock下检查原身份/终态/已接受schema并复制原件，附三工具/本接口；原.s同字节另存.assembly.txt，目标`.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac`以原子rename完成。已有target/staging拒绝覆盖，保留失败现场；freeze-source标记实际passed/failed及原job。不运行accept、不改源码record/best、不压比赛包。

C55当前仅准备。数值与汇编审查不等于速度，真实spill不自动等同数值失败。C6最佳保持；Yfalse/Sfalse不改写、不重测失败确认。主额度达到40%停止，不用重置卡。工具全部完成交root审查后STOP。
