# O：C49 独立诊断接口（仅 prepared）

四工具只准备文本，未执行、导入、编译、测试、SSH、提交或使用重置卡。C49 单包 source/wrapper 已冻结，准备工具没有改写它们。当前唯一compute负责人先顺序处理L/M；O只有根代理另行明确GO后才可运行。以下是将来手动调用接口，不是调度请求：

```text
python3 .runs/conv/sep12o-checks/driver.py C49-row4dup4fence config/conv-sep12.local.json submit --go
python3 .runs/conv/sep12o-checks/driver.py C49-row4dup4fence config/conv-sep12.local.json status
python3 .runs/conv/sep12o-checks/driver.py C49-row4dup4fence config/conv-sep12.local.json fetch
python3 .runs/conv/sep12o-checks/accept_returned.py C49-row4dup4fence
python3 .runs/conv/sep12o-checks/freeze_returned.py C49-row4dup4fence
```

真实失败才用验收及归档的 `--failed`；状态查询/取回只复用保存的唯一job。submit必须显式 `--go`，先独占创建job.json保留任何不确定上传/提交，再接受唯一数字ID；同包第二次submit拒绝，不自动修复、重试、轮询或继续性能。

## 调度、源与实际执行

只针对本任务当前有界I/L/M/O/N序列查询实际job：I1579762/1579795、已存在的L/C47与M/C48及O/C49 job.json、N实际performance_job；无job的prepared包与明确未提交prepared/planned campaign不视为活跃。既有预约缺失ID或当次调度查询失败则停止；不全盘扫描历史、不检查队友TRSM/ZGEMM，不取消别人作业。这不是全局调度锁，唯一负责人仍须按根代理GO顺序运行。

配置固定38CPU、24576MiB、1 NUMA pack、1800秒。wrapper在任何编译前检查Linux/AArch64、实际38CPU和单NUMA，GCC版本精确10.3.1；源文件严格匹配C49 checkpoint与两份首次传输manifest，不刷新既有摘要。

固定6配置：VL16/32/64字节×threads1/4。full/配置20164、smoke/配置96、direct0；合计full120984、dispatch576、total121560、runner0。与I/C45相同43×19×4+24×16×11×4及3×4×2×4矩阵，不扩测试，**没有kh5动态覆盖**。真实worker VL/team、bitwise scalar reference、readonly input/kernel、guard页和output canary原样。没有worker_mask/new-loop entry字段；smoke仅要求原pair/triple/quad入口非零，不把独立插桩算作生产对象。

19个按序stage：allocation/compiler/manifest/build-guard、6guard、build-dispatch、6dispatch、build-assembly/complete。每条真实退出0、wrapper退出0和scheduler job/system退出0且SUCCEEDED才可接受完成。set-e/pipefail/EXIT等待tee保留编译、数值或日志失败；即使打印过PROBE_COMPLETE，最终非零仍不能通过。

实际三gcc argv公共flags：`-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=4 -DCHECK_ROWTRIPLE=1 -DCHECK_ROWQUAD=1`。依次编译独立TU guard+candidate、带 `-finstrument-functions` 的独立dispatch、未插桩 `-S conv2d.c`。从probe或对应build日志解析真实 `+ gcc -O3 ...` xtrace，三条命令必须逐一匹配、probe顺序不能重复/变序，不执行日志字符串。没有runner/benchmark/LTO/tune或生产.o返回，因此不能声称object反汇编审查。

## 数值成功与性能代码生成资格分别保存

job schema沿I：version/job_id/submitted/submit_attempted/explicit_go/resources/source_hashes/scheduler_status；expected_checks为full_per_configuration20164、dispatch_per_configuration96、direct_per_configuration0、configurations6、total121560。

成功 `validation.json` 需要 `status=passed, complete=true, candidate=C49-row4dup4fence`、真实job/scheduler/exit_code0，full_cases120984、dispatch_cases576、direct_cases0、total_cases121560、runner_cases0。六 configurations 每项包括sve_bytes/threads/lanes/block_outputs_per_row、full_cases20164/dispatch_cases96/direct_cases0、helper_entries、passed。source_hashes为五文件简单map，source_hashes_verified/source_manifest_remote_matches=true；保留三build argv、19stage、实际CPU/NUMA和assembly。

以下字段为 **N 接入的固定接口**：

- `validation.performance_codegen_eligible`：由实际 `assembly.codegen_comparison.distinct_from_prior_machine_arrangements` 布尔派生，同时写入 `assembly.performance_codegen_eligible`。
- 数学可 `passed/complete=true` 而此值false；该结果正常冻结，不能作为故障丢弃，但 **N必须拒绝C49测速**。true也只表示形成新的可解释机器安排，仍需根代理GO，不表示提速或晋级。
- `automatic_performance_submission=false`、`performance_measured=false`、`performance_requires_root_review=true`、`kh5_dynamic_coverage=false`始终保留。
- N除该布尔外仍须校验冻结candidate/job/source/完整6配置/121560/真实成功及下列assembly/fence证据；不能仅凭一个手写bool放行。

## 实际 assembly-review.json

共同身份为candidate/job_id/source_sha256/compiler_version10.3.1/assembly_sha256。必须实际确认review_complete、production_uninstrumented、whole_helper_stack_reviewed、all_stages_and_transitions_reviewed、abi_saves_distinguished、dispatch_reviewed。完整源FMA系列计数必须0；spill本身不等于数值失败。

helpers精确覆盖所有实际conv_sve_rowquad及clone label→.size。每项symbol/line_start/line_end、stack_frame_description/spill_notes/vector_spill_loads/vector_spill_stores/transition_spill_review/tail_and_fallback_review完整，追踪间接栈地址并区别ABI D保存、tile物化与Z/Q/predicate spill。

stages按input_0/input_1/input_2/shared/trailing_0/trailing_1/trailing_2排列；shared工作量4列，其余2列。每阶段line_start/end、kernel_columns_per_iteration、source_mapping/spill_notes及spill loads/stores；shared_remainders按remainder2/remainder1分别2/1列、范围与阶段不重叠。nonshared_remainder_review说明其它单列余数。工具由真实范围计算ordinary/indexed FMUL、FADD、LD1W/LD1RW/LD1RQW、DUP、indexed MOV、EXT、MOVPRFX和指令数。

dispatch_functions覆盖全部conv2d及conv2d.*实际函数，精确symbol/line_start/end、control_flow_notes/stack_notes。当前只有.s，没有production object；不能扩成对象审查。全程序栈与helper热点spill分开。

### 三个空 compiler fence 的真实证明

`fence_review` 必含：review_complete/compiler_accepted/source_contract_reviewed/empty_templates_emit_no_instruction/does_not_claim_hardware_fence=true，source_fence_count=3。目标实际gcc成功、源身份和自动逐段源码契约核对共同证明三段约束被接受；不能借C45的编译接受。原3段依次在q0/q1/q2之后，源码当前行1010/1054/1098（工具从取回源重新定位），每段严格4个packed `+w`、16个a/b/c/d累加器 `w`、memory clobber、空template。

`observations`恰3项，after_kernel_lane依次0/1/2，各含：

- source_asm_line；mapping_status取 `reconstructed` 或 `not_separately_identifiable`；instruction_address_claimed必须false。
- evidence_ranges：实际共享循环内的周边汇编line_start/line_end列表；可以因调度交织而重叠，这些不是虚构的asm指令范围。
- packed_value_notes、accumulator_readiness_notes、scheduling_notes、register_and_spill_notes：按真实寄存器/加载/移动/栈槽说明可恢复的数据依赖与限制，不从源级预算推断结果。

空template本来不发指令，GCC可能连#APP/#NO_APP也不输出；已有C27实际.s就是这种情况。因此不强制三条虚构PC/边界，不在工具中插入新的marker或修改冻结源码。不可定位必须明确写not_separately_identifiable。memory是编译器约束，不是硬件fence；实际调度变化仍需独立机器比较。

### 对C45实际安排的比较

`codegen_comparison`含review_complete=true、distinct_from_prior_machine_arrangements为真实bool、prior_versions恰为 `[C45-row4dup4]`、normalization/notes/spill_and_schedule_difference_notes。prior_identity恰包含candidate/job_id/source_sha256/assembly_sha256，来自C45冻结I validation，真实job1579762；不能写C29/C32作为本版直接control。

`prior_shared`为各实际C45共享循环的列表，每项symbol/line_start/line_end/kernel_columns_per_iteration4、counts、vector_spill_loads/vector_spill_stores。工具与已冻结C45实际.s和validation自动核对；当前唯一范围conv_sve_rowquad4734..4919，counts为instructions185、fmul64、fmul_ordinary64、fmul_indexed0、fadd64、ld1w16、ld1rw0、ld1rqw4、dup16、indexed_mov0、ext0、movprfx0，spill loads6/stores6。该值属于C45，不是C49计划或观测。

C49 actual counts来自其真实helpers/stages，不预填。比较按同四列×16acc工作量，需说明实际调度/栈/指令差异，不能只由源文本变了推断distinct，更不能由不同allocation旧速度归因。本工具接受真实distinct=false并生成禁止N字段。

## 失败与原子归档

成功或真实失败均归档到 `.runs/conv/C49-row4dup4fence/sve-correctness-sep12o/`。保留原source/raw/prepared/two manifests及全部已有metadata；附driver/accept/freezer/INTERFACE，写同字节conv2d-sve.assembly.txt和一次摘要来源说明。目标或staging已存在一律拒绝，不删除、不覆盖。

`--failed`只接受实际scheduler/wrapper/stage失败，status=failed/complete=false/reason；total_cases=null表示真实执行量未确认，不把121560计划冒充完成量；允许缺.s。普通解析/汇编审阅不全只保存独立acceptance-failure文件，不能伪造远端失败。现有final validation不覆盖；若有原prepared validation则先保留原字节。归档程序不自动执行验收或题目。

本次静态审查已覆盖单候选身份、19stage/三flags、矩阵、独占预约/失败传播、受限取回、source/参考artifact一致、数学与codegen双状态及不覆盖归档。没有执行/导入这些工具，没有本机语法测试或算子运行；等待根代理独立审查和之后明确O执行授权。
