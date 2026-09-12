# I 轮工具接口与独立静态审查

本轮只准备工具，没有执行 driver、验收器、编译、算子、测试或 SSH；没有创建 I 作业。J/K 性能与确认由根代理管理，H 暂停；I 必须等待新的根代理 GO。下列命令是可恢复接口，不是自动执行计划。

```text
python3 .runs/conv/sep12i-checks/driver.py C45-row4dup4 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep12i-checks/driver.py C45-row4dup4 config/conv-sep12.local.json status
python3 .runs/conv/sep12i-checks/driver.py C45-row4dup4 config/conv-sep12.local.json fetch
python3 .runs/conv/sep12i-checks/accept_returned.py C45-row4dup4
python3 .runs/conv/sep12i-checks/freeze_returned.py C45-row4dup4
```

C46 替换版本名。实际远端失败可用 `accept_returned.py VERSION --failed` 保留失败记录，再用 `freeze_returned.py VERSION --failed` 冻结。仅解析失败不能冒充真实计算失败：验收器的普通拒绝保存独立时间戳 `acceptance-failure-*.json`。不修改候选或重提原作业。若 C46 原先已有 prepared `validation.json`，成功解析后先原字节另存 `prepared-validation.json`，再写实际终态；已经通过或失败的 validation 均不能覆盖。

## 实际包装与计数核对

两份 frozen wrapper 都是 19 个按序阶段：allocation、compiler、manifest、build-guard、六个 guard、build-dispatch、六个 dispatch、build-assembly、complete。`stage` 保存真实返回值；编译和 guard 管道失败会终止后续步骤。`pipefail` 保留 guard/tee 失败；EXIT trap 等待 probe 的 tee 并把其失败反映到 wrapper exit。即使已出现完成文字，最终退出非零也不能通过。

三个实际 GCC argv 的公共参数是 `-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp`。C45 加 `EXPECTED_ACC=4/CHECK_ROWTRIPLE=1/CHECK_ROWQUAD=1`；C46 仅加 `EXPECTED_ACC=5`。依次构建未插桩的 guard+candidate、独立 `-finstrument-functions` dispatch、未插桩候选的 `-S`。没有 LTO、tune、官方 runner 或 benchmark 执行。生产 guard 与 candidate 是不同 TU；当前 wrapper 不保存生产 `.o` 反汇编，不能声称检查过它。

`BUILD_COMMAND:` 由多次 printf 拼成，可能与 set-x 交错。验收只解析真实 `+ gcc -O3 ...` argv，不执行日志文本；允许命令 trace 出现在 probe 或对应构建日志，重复副本必须完全一致，probe 中顺序不可变，每条实际 argv 必须存在。没有真实返回日志时不宣称此解析流程已动态验证。

|候选|full/配置|dispatch/配置|direct/配置|六配置总数|
|---|---:|---:|---:|---:|
|C45|20164|96 smoke|0|121560|
|C46|3776|504|288|27408|

共同六配置是 SVE bytes 16/32/64 × threads 1/4。包装在编译前检查 Linux/AArch64、实际 38 CPU、一个 NUMA 和 GCC10.3.1。guard 对每个 OMP worker 检查 VL 和 team；原输入/kernel 只读、整块分配边缘 guard、输出 poison/canary、独立有序标量逐位比较均保留。这里没有每行独立 guard，也没有 sanitizer。

C45 full 为 43×19×4=3268 加 24×16×11×4=16896。扩展核中的 kh4/kw4、5、6、7 覆盖四列块的余 0、1、2、3；kh7/kw8 覆盖两轮四列块。smoke 为宽 1/193/385、kh1..4、kw3/4、四种放置，总 96；它只证明原 C32 范围的 pair/triple/quad 非零入口，不能生成不存在的 worker_mask 或新四列循环计数。没有 kh5 的动态检查，不声称全核形状覆盖。

C46 full=3168+144+432+32=3776。504 分派与 288 direct 相互独立计数，预期 quint entries 分别 528/720；各阶段 worker mask 是 1 或 15。宽 4VL/5VL/10VL 邻域、五行组与余 1..4 行、kh4/5/6 和 direct kh1..4 覆盖保持。源码修正了旧 C42 不被支持的 `%Z`，但新的默认操作数仍需目标 GCC 实际接受；旧 C42 失败不提供任何本候选 PASS。

两包共同必需 `source-hashes.json` 五项简单映射；C45 原包没有 `source-manifest.json`，不补造它。C46 的 bytes/SHA manifest 若存在必须与简单映射吻合。源码、wrapper、原计划不变；远端清单与取回字节属于自动传输验证，不做额外大范围人工哈希审计。

## 成功 schema

`job.json` 使用 `version/job_id/submitted/submit_attempted/explicit_go/resources/source_hashes/scheduler_status`，`expected_checks` 统一为 `full_per_configuration/dispatch_per_configuration/direct_per_configuration/configurations/total`。C45 的 direct 明确为 0。

验收要求真实 scheduler 文本与字段匹配、SUCCEEDED、job/system/wrapper 全零、19 阶段全零、源身份、三条实际 GCC argv、六组完整计数和实际汇编审阅。成功 `validation.json` 为 `status=passed, complete=true`，保留实际 `total_cases/full_cases/dispatch_cases/direct_cases`，以及 `runner_cases=0`；`configurations` 每项包含 `sve_bytes/threads/lanes/block_outputs_per_row/full_cases/dispatch_cases/direct_cases/helper_entries/passed`。C46 另有分派/direct entries 与 worker mask；C45 没有 mask。

失败只保留实际终态与已存在证据，缺失的阶段或汇编不补造。`total_cases=null` 表示失败过程真实执行总数未确认，不能拿计划数当完成数。成功/真实失败均可归档到对应候选 `sve-correctness-sep12i/`；保留 source/raw/prepared/原清单，生成同字节 `.assembly.txt` 和一次摘要来源说明，原子 rename，拒绝覆盖旧归档或残留 staging。

## assembly-review.json 规格

以下仅定义未来证据结构，不是预填 PASS。身份字段为 `candidate/job_id/source_sha256/compiler_version/assembly_sha256`；必须逐项实际确认 `review_complete/production_uninstrumented/whole_helper_stack_reviewed/all_stages_and_transitions_reviewed/abi_saves_distinguished/dispatch_reviewed=true`，完整源 FMA 系列计数为 0。FMA 不限于 fmla，也检查 fmad/fmsb/fnm 系列。允许记录真实 spill，不以零 spill 代替正确性或性能。

`helpers` 覆盖实际目标函数及 clone：C45 `conv_sve_rowquad`，C46 `conv_sve_rowquint`。每项 `symbol/line_start/line_end` 精确对应完整函数标签至 `.size`，以及 `stack_frame_description/spill_notes/vector_spill_loads/vector_spill_stores/transition_spill_review/tail_and_fallback_review`。必须追踪间接栈地址，区分 D 寄存器 ABI 保存与 Z/Q/input/product/accumulator spill。

每项 `stages` 按 input_0..2/shared/trailing_0..2（C45 七阶段）或 input_0..3/shared/trailing_0..3（C46 九阶段）排列。每阶段包含 `stage/line_start/line_end/kernel_columns_per_iteration/source_mapping/spill_notes/vector_spill_loads/vector_spill_stores`。C45 主共享范围按四列工作量，其余阶段主循环按两列；另需 `shared_remainders`，依次 `loop=remainder2/remainder1` 的真实、不重叠范围及同类字段，工作量 2/1。`nonshared_remainder_review` 说明其余阶段单列余数。C46 各阶段按一列。工具从实际范围统计普通/indexed FMUL、FADD、LD1W/LD1RW/LD1RQW、DUP、indexed MOV、EXT、MOVPRFX，不填固定性能推论。

`dispatch_functions` 覆盖实际所有 conv2d/conv2d.*：`symbol/line_start/line_end/control_flow_notes/stack_notes`。C45 另需 `codegen_comparison`：`review_complete=true`、实际 `distinct_from_prior_machine_arrangements` 布尔、`prior_versions=[C29-row4lane4,C32-row4lane4staged]`、`normalization/notes`。若未形成新的可解释机器安排，数值可以通过，但不自动开展性能；任何性能提交都仍由根代理决定。

C46 另需 `explicit_asm_review` 的 `compiler_accepted/concrete_operands_reviewed/scratch_disjoint_from_inputs_and_accumulators/accumulator_order_reviewed=true` 与说明。`blocks` 为五个实际 source asm 范围，`input_vector=0..4`，每项记录 `line_start/line_end/scratch_register/input_register/accumulator_registers[5]/coefficient_registers[5]/live_accumulator_registers/liveness_and_spill_notes`。记录形如 z0 的真实寄存器；工具核对每块正好五个 FMUL/FADD 对、实际操作数与相加顺序、scratch 不覆盖输入/系数/活跃累加器、early-clobber 累加器与输入不重叠。活跃但已 spill 的值需在文字里解释，不用 32 寄存器的源级预算冒充实际证明。

最终自动性能提交始终为 false；当前工具准备不改变正式最佳或任何 G/J/K 结果。
