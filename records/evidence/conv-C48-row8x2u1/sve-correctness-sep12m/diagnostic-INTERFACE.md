# M 轮 C48 专项接口（仅准备）

本轮只新增四个公共工具文件，依据已审 L 工具适配 Popper 冻结的 C48 包。没有导入或运行新工具，没有 SSH、作业、编译、测试、验收结果、性能或重置操作。根代理正在管理 H 性能 1579748；M 必须等根另行明确 GO。C40/C47 的通过记录不能替代 C48 的实际验证。

## 冻结来源与精确计数

候选 C48-row8x2u1，source_parent=C40-row6x3u1；生产 SHA 为 `8623781dc784547e31b07facd65507b56ff40f6b5da3e617c1ef53f4a4f7f7c3`。新 helper 为 `conv_sve_roweight`，八输出行 × 每行 2VL，共 16 个累加器。EXPECTED_ACC=2 只描述每行向量数，不表示四行/六行 helper，也不启用 CHECK_ROWQUAD 宏。五份 source、source-hashes.json、source-manifest.json、prepared.json、原 prepared validation 保持原样；工具不会刷新已冻结清单。

|路径|每配置|六配置|
|---|---:|---:|
|未插桩生产 full|5360|32160|
|独立分派插桩|1080|6480|
|直接调用防御回退|504|3024|
|合计|6944|41664|
|官方 runner|0|0|

六配置是 threads 1/4 × SVE bytes 16/32/64，每个 worker 的实际 VL/team 均须通过。每行 BLOCK_OUTPUTS 分别为 8/16/32 个 float，即 `sve_bytes/2`。它不是 L 的 `sve_bytes`，也不是八行累计输出数。

full 矩阵按冻结循环静态重算：core=6 宽度 ×3 kh×3 kw×20 高度×4 分配方式=4320；narrow=1×3×3×4×4=144；small=3×6×3×4×4=864；larger=4×2×4=32，总5360。实际日志必须出现 `FULL_MATRIX_COUNTS core=4320 narrow=144 small=864 larger=32` 和精确 full PASS。

宽度为 2VL/4VL ±1；核心 kh7/8/9、kw1/2/3；高度为1..17、24、25、32，覆盖八行分组的全部余数与四线程完整工作。小核 kh1..6、较大奇偶核及81×81另有矩阵；direct 防御路径明确覆盖 kh1..7，输出高度8/32，三种2VL邻域宽度、kw1/2/3及四分配方式。

分派共6×3×3×20=1080个case；新 helper 仅 kh>=8 且有整8行时进入，包含宽度不足主块而进入 helper 后回退的情况。高度的整组数之和22，6宽×2可达kh×3kw×22=792个实际入口。direct 共3×7×3×2×4=504个case，入口3×7×3×4×(1+4)=1260。每case对入口增量做校验，汇总 mask 1线程=1、4线程=15。原 prefix/tail/rowpair/rowtriple/rowquad 也必须各有非零实际入口。入口计数不等于每个算术阶段的动态分支计数，工具不声称后者。

## 后续接口与唯一提交

以下只给出恢复命令，当前不执行：

```text
python3 .runs/conv/sep12m-checks/driver.py C48-row8x2u1 config/conv-sep12.local.json gate
python3 .runs/conv/sep12m-checks/driver.py C48-row8x2u1 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep12m-checks/driver.py C48-row8x2u1 config/conv-sep12.local.json status
python3 .runs/conv/sep12m-checks/driver.py C48-row8x2u1 config/conv-sep12.local.json fetch
python3 .runs/conv/sep12m-checks/accept_returned.py C48-row8x2u1
python3 .runs/conv/sep12m-checks/freeze_returned.py C48-row8x2u1
```

submit 必须根代理明确 `--go`；在任何传输前以排他方式创建 job.json，同包已有 reservation 就拒绝重复提交。上传失败或提交身份不明也保留原文件，不清理或重提。status/fetch 只复用原 ID，不自动轮询或继续下一作业。准备工具本身不授予执行权。

串行门槛只对本任务当前已知 J1579660、K1579677、H1579748，H 两个诊断、I 两包、L C47、M C48 的已存在 job，以及 H/K 各成员与 C40-package 的已存在 cluster 元数据、H/I/J/K/L/M campaign 做去重后的有界实时调度查询；不全盘扫描历史或队友作业。H/J/K campaign 的 ID 必须与已知值相符。pending/running、查询失败、未知状态、缺整数 job/system 退出码均阻止；只有 prepared 包且没有 job 文件忽略。未提交非 H/J/K campaign 仅在 status=prepared/planned 且 submitted/submit_attempted 明确 false 时可忽略，其余无 ID reservation 阻止。终态失败仅说明已不运行，不等于数值通过；仍需根按实际失败决定后续。该门槛不是跨协调者的调度锁，只有根统一安排的唯一提交者可运行。

资源固定38CPU、24576MiB、一个 packed NUMA、1800秒。远端 wrapper 再查真实 Linux/AArch64、38 affinity CPUs 同属一个 NUMA、GCC10.3.1。不在登录节点编译，不执行官方 runner，不更改 reference、容差、计时区或系统设置。

fetch 仅保留单层普通文本/源码/.h/.s，拒绝符号链接、重复成员、超限文件及已有不同字节；配置和认证从不打包。包装没有保留独立 production.o，OBJECT_ARTIFACTS 为空，不声称有实际对象反汇编。

## 包装和验收要求

包装的19个阶段与算法的15个阶段不同。作业阶段顺序为 allocation、compiler、manifest、build-guard、六个 guard-vl16/32/64-t1/4、build-dispatch、六个 dispatch-vl16/32/64-t1/4、build-assembly、complete。每个 stage、wrapper、scheduler job/system 都必须为0；完整日志、唯一 ID 和终态必须对应。

实际三条 GCC argv 公共参数为：

```text
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=2
```

依次追加 `check_conv_guard.c conv2d.c -o check_conv_guard`、`-finstrument-functions check_sve_dispatch.c -o check_sve_dispatch`、`-S conv2d.c -o conv2d-sve.s`。生产候选和 scalar guard 是独立 TU，只有独立入口程序插桩；没有 tune/LTO/fast-math 或 CHECK_ROWQUAD 宏。验收从 probe 或对应 build log 中真实 `+ gcc -O3 ...` 行以 shlex 解析，重复副本必须一致并保持顺序；不执行日志，不依赖可能交错的 BUILD_COMMAND 展示字段。

返回日志要求每配置：

- `PASS: 5360 convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference`
- `PASS: 1080 dispatch cases; exact per-case roweight entries and bitwise scalar reference`
- `PASS: 504 direct fallback cases; kh1..7, readonly/guard/canary and bitwise scalar reference`
- `DISPATCH_ROWEIGHT_ACTUAL_ENTRIES=792 EXPECTED=792 WORKER_MASK=<1或15> EXPECTED_MASK=<相同>`
- `DIRECT_ROWEIGHT_ACTUAL_ENTRIES=1260 EXPECTED=1260 WORKER_MASK=<1或15> EXPECTED_MASK=<相同>`

所有原独立顺序 scalar bitwise、只读输入/权重、分配边缘 guard 和输出 poison/canary 保持。未运行 sanitizer，也没有每行独立保护页；不能扩大覆盖声明。

成功 validation 包括 candidate/job_id/status=passed/complete=true、scheduler/exit_code、19 stage_exits、compiler_version、实际build_commands、source_hashes_verified/source_manifest_remote_matches、source_hashes、allocation，以及 total_cases=41664/full_cases=32160/dispatch_cases=6480/direct_cases=3024/runner_cases=0。六个 configurations 各含 sve_bytes/threads/lanes/block_outputs_per_row/full_cases/dispatch_cases/direct_cases/helper_entries/dispatch_entries/direct_entries/dispatch_worker_mask/direct_worker_mask/passed。

原 prepared validation 按原字节保存为 prepared-validation.json 后才写真实终态；已有终态拒绝覆盖。解析拒绝另存 acceptance-failure，不能伪装成算子失败。只有真实 scheduler/wrapper/stage 非零失败可使用 accept/freezer 的 `--failed`，保留 reason、实际阶段与未知数值计数 null，缺失日志或 .s 不补造，计划数不是已执行数。

## 实际 assembly-review.json

只在生产产物返回后填写，不预填 PASS。身份为 candidate/job_id/source_sha256/compiler_version=10.3.1/assembly_sha256。须真实确认 review_complete/production_uninstrumented/whole_helper_stack_reviewed/all_stages_and_transitions_reviewed/abi_saves_distinguished/dispatch_reviewed。whole_source_fma_count=0，扫描所有 fused families；spill 是观察结果而非自动正确性失败。

shape 为 rows_per_group8/vectors_per_row2/accumulators16，whole_machine_code_identical_claimed=false。helpers 列出实际 `conv_sve_roweight` 及全部 clone，完整 label到.size 行界、stack_frame_description、spill_notes、vector_spill_loads/stores、transition_spill_review、tail_and_fallback_review、arithmetic_and_load_review。

每个 helper 的十五 stages 按 input_0..6、shared、trailing_0..6 排序，记录真实不重叠行界、kernel_columns_per_iteration、source_mapping、spill_notes、vector_spill_loads/stores。当前单列源码要求归一化工作量1；若目标编译器实际改变展开，应保留真实产物由根复核，不能伪造范围以通过。工具从实际范围推导 FMUL普通/indexed、FADD、LD1W/LD1RW/LD1RQW、DUP/indexed MOV、EXT/MOVPRFX 和总指令，不强迫旧七/九/十一阶段或任何固定指令数。

审查八行2VL输入/系数映射与各输出kh/kw累加顺序，七段首尾参与行、全部转场、间接栈地址、kh<8直接回退和横向不足2VL的两个quad回退。D寄存器 ABI、标量状态、向量 accumulator/product/input spill 要区分，16累加器预算不能替代实际机器码。dispatch_functions 覆盖全部 conv2d/conv2d.* 实际完整范围，含 control_flow_notes/stack_notes，并解释余1..7行独占输出及旧helper回退。生产对象未保留，记录 production_object_disassembly_available=false，不借其它版本的对象结论。

成功或真实失败分别按原字段冻结至 `.runs/conv/C48-row8x2u1/sve-correctness-sep12m/`。freezer 在公共 workflow lock 下完整copy source/raw/prepared/manifests，并附四工具；实际.s同字节导出.assembly.txt，一次摘要记录来源，再原子rename。已有归档/临时树一律拒绝，不删除失败证据。当前仅 prepared，没有进行任何实际验收、冻结、性能提交、打包、晋级或发布。
