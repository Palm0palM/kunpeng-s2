# G 轮独立静态审查与回收验收

当前仅准备；没有提交 G 作业，没有本机编译、测试或算子执行。C40/C41/C42 和 profile r2 继续等待 F 性能结束及根代理的新 GO。以下计数均为计划，不能当作已通过结果。

## C42 检查包审查

只读比较确认：C42 的 `check_conv_guard.c`、`check_sve_dispatch.c`、`candidate.env`、`remote_job.sh` 与 C41 模板逐字节相同。候选源码仅五行 helper 的 shared middle 不同，之前和之后的全部源码相同。新区域恰有五个 asm 块，每块五个独立 FMUL/FADD 对；共 25 FMUL、25 FADD 源模板指令。未修改候选或模板文件，也没有重复计算源码哈希。

五个块分别处理输入向量 0..4，并按 a/b/c/d/e 更新相应输出行。每个输出仍按增加的 kernel row/column 累加。五个 `+&w` 累加器、一个 `=&w` scratch 和六个 `w` 输入都具备明确的数据依赖；约束意图是 scratch 和 early-clobber 输出不覆盖尚需读取的输入。25 个活跃累加器、5 个系数、1 个输入和 1 个 scratch 恰好占 32 个向量寄存器，只是源级预算。GCC10.3.1 是否接受 `%Z` 模板、是否产生 spill、实际具体寄存器是否符合约束，都必须等目标编译与真实汇编审查。`memory` clobber 是编译器约束，不是硬件 fence。

`kh=5/6`、`kw=1/2/3`、`oh>=5` 且 `ow>=5L` 的生产测试形状使 shared middle 的五个 asm 块都可达。`kh=5` 走一次共享输入行，`kh=6` 走两次；较大矩形与 81×81 核继续覆盖重复执行。入口插桩记录的是函数入口，结合这些形状及冻结源码的 `ow-i >= 5L` 条件确认完整块可达；它不是新增的 asm basic-block 计数器。

宽度 `4L/4L+1/5L-1`、`5L/5L+1`、`10L-1/10L/10L+1` 覆盖无 quint 完整块、完整块、多个完整块和 quad/prefix 余列。高度 1..10 和 20 覆盖五行组及余 1..4 行；20 行使四个 worker 都获得完整组。`kh=4` 走公开回退；单独 direct helper 检查强制覆盖公开分派不可达的 `kh=1..4` 防御分支。

生产 full 计数：3168 core + 144 narrow + 432 small-kernel + 32 larger = 3776。分派：8 宽 × 3 kh × 3 kw × 7 高 = 504；实际入口计划 8 × 2 active kh × 3 kw × (5×1+2+4) = 528。direct：3 宽 × 4 kh × 3 kw × 2 高 × 4 allocation modes = 288；入口计划 3×4×3×4×(1+4) = 720。总计 `(3776+504+288)×6 = 27408`。

每个阶段分别检查 worker mask：单线程 1，四线程 15。入口差值在 `one_case` 完成及 OMP join 后读取，direct target 与 mask 仅在阶段间更换。每个 case 仍使用只读 input/kernel、两端 guard pages、逻辑数组之外的 canary、被 poison 的 output，以及独立 strict scalar 逐位比较。guard 是整个分配的边界，不能声称每行都有独立 guard page。

静态结论：没有发现矩阵计数、五 asm 覆盖或 direct 接口阻碍；实际编译接受、数值正确性与 spill 均未验证。

## 验收脚本接口

只在唯一作业终止并取回之后执行轻量日志解析：

```text
python3 .runs/conv/sep12g-checks/accept_returned.py C40-row6x3u1
python3 .runs/conv/sep12g-checks/accept_returned.py C41-row5x5u1
python3 .runs/conv/sep12g-checks/accept_returned.py C42-row5x5asm
```

脚本不连接超算、不编译、不执行算子，也不提交任务。必要输入在各候选检查目录：`job.json`、`source-manifest.json`、`raw/` 和人工审查后的 `assembly-review.json`。提交/取回 driver 由根代理另行集成，不属于这份脚本。

`job.json` 至少需要 `version`、`job_id`、`scheduler_status`、`expected_checks`。`expected_checks` 精确使用 prepared validation 的五个字段：`full_per_configuration`、`dispatch_per_configuration`、`direct_per_configuration`、`configurations`、`total`。

| 候选 | full/config | dispatch/config | direct/config | total | 入口 dispatch/direct | 新 helper 阶段数 |
|---|---:|---:|---:|---:|---:|---:|
| C40 | 3560 | 432 | 360 | 26112 | 432 / 900 | 11 |
| C41 | 3776 | 504 | 288 | 27408 | 528 / 720 | 9 |
| C42 | 3776 | 504 | 288 | 27408 | 528 / 720 | 9 |

六配置固定为 SVE bytes 16/32/64 × threads 1/4。脚本要求调度 SUCCEEDED、job/system/wrapper exit 均 0、实际 GCC10.3.1、38 核/单 NUMA 输出、五个传输源条目相符、三条真实 GCC xtrace argv，以及全部 full family、PASS、入口、worker mask、legacy helper 入口与最终完成标记。只比较原自动 manifest 与远端 SHA 输出，不增加重复字节哈希审计。

任何缺失或不匹配都产生独立时间戳 `acceptance-failure-*.json` 并退出失败，原始日志和 prepared validation 保留。只有全部 gate 通过才写 `validation.json` 的 `complete=true`；不能覆盖已 accepted 的 validation。

## 实际汇编人工审查输入

`assembly-review.json` 必须来自返回的无插桩 `raw/conv2d-sve.s`，不能从源模板或插桩 binary 推测。要求：

- `review_complete`、`production_uninstrumented`、`all_stages_and_transitions_reviewed`、`whole_helper_stack_reviewed`、`abi_saves_distinguished` 均为 true；`compiler_version` 为 `10.3.1`，`helper` 是 `conv_sve_rowsix` 或 `conv_sve_rowquint`，`whole_source_fma_count` 为实际观测值 0。
- `stages` 逐一对应 source 阶段。C40：`input_0`..`input_4`、`shared`、`trailing_0`..`trailing_4`；C41/C42：`input_0`..`input_3`、`shared`、`trailing_0`..`trailing_3`。每项给实际一基 `line_start/line_end`、`kernel_columns_per_iteration`、`source_mapping`、`vector_spill_loads`、`vector_spill_stores`、`spill_notes`。范围应选所归属阶段的真实内循环，并说明源阶段与机器块的对应关系。
- `transition_spill_review` 和 `stack_frame_description` 必须说明阶段之间、helper 外围以及固定/可伸缩栈帧，区分 ABI 的 D 寄存器保存、标量地址保存和真正向量 spill。间接通过地址寄存器访问栈也需追踪，不能只搜索 `[sp]`。
- C42 另需 `explicit_asm_review`：`compiler_accepted`、`concrete_operands_reviewed`、`scratch_disjoint_from_inputs_and_accumulators`、`accumulator_order_reviewed` 为 true，`blocks_per_shared_iteration=5`，并以 `notes` 说明实际具体寄存器与模板接受证据。

脚本依据实际阶段范围生成 `derived_stage_counts`，统计指令、FMUL/FADD、LD1W/LD1RW、EXT/MOVPRFX；没有 C6 七阶段固定条数或“必须零 spill”的 gate。存在 spill 应如实记录，正确性仍可通过。输出还派生 `stage_count`、`fma_count`、`transitions_reviewed` 供后续性能脚本严格校验。

最终公共 schema：`total_cases` 仅为本专项，另有 `full_cases`、`dispatch_cases`、`direct_cases`（各六配置总和）；每个 `configurations` 项含对应三项单配置计数、`dispatch_entries/direct_entries`、`dispatch_worker_mask/direct_worker_mask`、`helper_entries`、`passed`。`source_hashes` 是 filename→SHA；`source_hashes_verified` 和 `source_manifest_remote_matches` 仅在实际匹配后为 true。预定冻结目录为各候选实验的 `sve-correctness-sep12g/`，本准备步骤未创建它们。
