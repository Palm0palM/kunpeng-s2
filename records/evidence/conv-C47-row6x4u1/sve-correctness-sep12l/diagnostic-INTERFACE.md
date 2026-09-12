# L 轮 C47 专项接口（仅准备）

本目录的四个工具由已审 I 接口适配，仅供根代理明确 GO 后使用。本次没有执行或导入它们，没有编译、运行算子、测试、SSH、提交作业、写实际验收结果或重置用量。C47 源码、五份包装源码、原 manifest/prepared/validation 保持原样。先前 C40 的通过结果不等于 C47 通过；当前正式最佳及 G/J/K 记录均由根代理另行管理。

```text
python3 .runs/conv/sep12l-checks/driver.py C47-row6x4u1 config/conv-sep12.local.json gate
python3 .runs/conv/sep12l-checks/driver.py C47-row6x4u1 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep12l-checks/driver.py C47-row6x4u1 config/conv-sep12.local.json status
python3 .runs/conv/sep12l-checks/driver.py C47-row6x4u1 config/conv-sep12.local.json fetch
python3 .runs/conv/sep12l-checks/accept_returned.py C47-row6x4u1
python3 .runs/conv/sep12l-checks/freeze_returned.py C47-row6x4u1
```

这些是接口示例，不会自动运行。`gate` 只查询并保存证据，不授权提交。`submit` 必须显式 `--go`，先查询实际前序状态，再以排他 `job.json` reservation 保留唯一提交身份。存在 reservation 就拒绝再次提交，包括上传失败、提交返回不明、尚无 job ID 的情形；由根代理核实后恢复原身份，不删除重试。status/fetch 始终使用已保存的原 job ID。配置只读取，绝不打包。

## 串行与传输门槛

资源固定 38 CPU、24576 MiB、单 NUMA pack、1800 秒。提交前对去重的实际作业各做一次有界状态查询：已知 J1579660/K1579677；K 各成员和 C40-package 的现有 cluster.json；H C43/C44、I C45/C46、L C47 的现有 job.json；H/I/J/K/L 现有性能 campaign。所有查询必须可解析、标识相符、状态为终态并具备整数 job/system 退出码，才可能放行。终态失败不会被改成通过；此门槛只证明没有该已知作业仍占计算资源。

只有 prepared 目录且没有 job.json 的包直接忽略。不含实际 ID、同时明确 status=prepared/planned 且 submitted=false、submit_attempted=false 的未提交非 J/K campaign 可忽略，并记录其路径；其他不明 reservation 一律阻止。不会查询无关队友作业，也不是跨多个协调者的全局互斥锁，仍由根代理串行安排唯一 `--go`。

上传仅包含 `conv2d.c/check_conv_guard.c/check_sve_dispatch.c/candidate.env/remote_job.sh` 五文件；提交前核对原简单 SHA manifest、bytes/SHA manifest、prepared 的来源和形状以及 candidate checkpoint，不刷新清单。源父是 C40-row6x3u1，生产源是 C47-row6x4u1，形状为六行 × 四向量、24 累加器。这里的 EXPECTED_ACC=4 是每行向量数，不能据此启用四行 helper 宏。

fetch 只接收单层普通文本/源码/.h/.s 文件，限定每文件大小，拒绝重复成员与符号链接，不覆盖任何已有不同 raw 字节；该 wrapper 没有保留对象文件，因此对象允许名单为空。失败或不明传输保留日志及已有 raw。fetch 本身既不验收，也不运行任何性能测试。

## 已冻结包装、计数与真实日志

阶段严格为 19 项：allocation、compiler、manifest、build-guard、按 VL16/32/64 与 threads1/4 顺序的六个 guard、build-dispatch、同序六个 dispatch、build-assembly、complete。包装实际检查 Linux/AArch64、38 CPU、一个 NUMA、GCC10.3.1；stage/pipefail/EXIT trap 保留编译、guard、tee 的真实退出。要求 job/system/wrapper 及 19 个阶段全部零，不能只凭最后的完成文字。

三个实际 GCC argv 的公共参数为 `-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=4`。依次追加：

1. `check_conv_guard.c conv2d.c -o check_conv_guard`，未插桩生产 TU 与独立 scalar guard。
2. `-finstrument-functions check_sve_dispatch.c -o check_sve_dispatch`，仅这个独立入口计数程序插桩。
3. `-S conv2d.c -o conv2d-sve.s`，未插桩候选汇编。

不添加 CHECK_ROWTRIPLE/CHECK_ROWQUAD、LTO、tune、fast-math 或官方 benchmark。guard 与 dispatch 都只接收一个 VL 字节参数，没有 smoke 参数。`BUILD_COMMAND:` 可能与 shell xtrace 交错；验收采用真实 `+ gcc -O3 ...`，用 shlex 解析 argv，允许位于 probe 或相应 build log，重复副本必须一致且顺序正确，不执行日志中的命令。无真实 L 返回日志时，不能声称已动态验证解析器。

|路径|每配置|六配置|实际标记|
|---|---:|---:|---|
|生产 full|3560|21360|FULL_MATRIX_COUNTS core=2808 narrow=144 small=576 larger=32|
|分派|432|2592|PASS: 432 dispatch cases；rowsix entries 432|
|direct 防御回退|360|2160|PASS: 360 direct fallback cases；kh1..5；rowsix entries 900|
|总计|4352|26112|六份互异 VL/thread 配置|

六配置是 SVE bytes16/32/64 × threads1/4，实际每行 block outputs 分别16/32/64（四个 float 向量）；每个 OMP worker 都核对真实 VL 和 team。分派和 direct 各自要求逐 case 入口增量正确，汇总 worker mask 为 1 或15；prefix/tail/pair/triple/quad 旧 helper 也必须各有真实入口。核对矩阵覆盖 4VL/8VL 邻域、kh5/6/7、kw1及奇偶、oh1..12与24、余1..5行、direct kh1..5。原逐位有序 reference、只读输入/权重、分配边缘 guard 和输出 poison/canary 原样保留；没有每行独立 guard，没有 sanitizer。

## 实际验收与失败归档

`job.json` 字段沿 I：version/job_id/submitted/submit_attempted/explicit_go/resources/source_hashes/scheduler_status，expected_checks={full_per_configuration:3560,dispatch_per_configuration:432,direct_per_configuration:360,configurations:6,total:26112}。成功 validation 只有在实际全部门槛通过后生成 `status=passed,complete=true`；total_cases=26112，full_cases=21360，dispatch_cases=2592，direct_cases=2160，runner_cases=0。六个 configurations 各含 sve_bytes/threads/lanes/block_outputs_per_row/full_cases/dispatch_cases/direct_cases/helper_entries/dispatch_entries/direct_entries/dispatch_worker_mask/direct_worker_mask/passed。

`validation.json` 原 prepared 内容在实际验收时按原字节另存 prepared-validation.json；已有任何终态拒绝覆盖。普通解析失败只写独立 acceptance-failure 时间戳证据，不把解析失败伪装成算子失败。真实 scheduler/wrapper/stage 失败可显式 `accept_returned.py C47-row6x4u1 --failed` 后 `freeze_returned.py C47-row6x4u1 --failed`。缺失的数值日志或 .s 不补造，计划数绝不当执行数；失败 total_cases=null 表示实际已运行数未确认。

归档目的地为候选 `sve-correctness-sep12l/`；公共 workflow lock 内检查原身份/真实终态后完整复制 source/raw/原 metadata 并附四工具，生成同字节 .assembly.txt 与一次摘要来源说明，再原子 rename。拒绝已有归档或残留 staging；失败保留中间证据，不清理覆盖，也不自动重新验收、提交、打包、晋级或发布。

## assembly-review.json：必须等实际产物

以下仅定义证据结构，不是预填通过结论。身份 candidate/job_id/source_sha256/compiler_version/assembly_sha256 要指向本作业实际未插桩 .s。必须实际确认 review_complete/production_uninstrumented/whole_helper_stack_reviewed/all_stages_and_transitions_reviewed/abi_saves_distinguished/dispatch_reviewed=true；whole_source_fma_count=0。工具扫描全部 fused families，包括 fmla/fmls/fmad/fmsb/fnm、fmadd/fmsub/fnmadd/fnmsub、fmlal/fmlsl 与 fmmla。shape={rows_per_group:6,vectors_per_row:4,accumulators:24}；whole_machine_code_identical_claimed=false。旧 C40 或其他 helper 的源级形状和通过记录不能代替新产物。

helpers 必须覆盖实际 conv_sve_rowsix 及全部 clone，每项 symbol/line_start/line_end 精确对应函数标签至 .size；另有 stack_frame_description/spill_notes/vector_spill_loads/vector_spill_stores/transition_spill_review/tail_and_fallback_review/arithmetic_and_load_review。十一 stages 依次 input_0..4/shared/trailing_0..4，各有 stage/line_start/line_end/kernel_columns_per_iteration/source_mapping/spill_notes/vector_spill_loads/vector_spill_stores；当前单列源码期望每次工作量为1，真实编译若产生不同展开，先保留结果并由根代理审查调整解释，不能假造符合的范围。阶段范围必须真实、互不重叠。

必须检查完整六行 × 4VL 主块、每输出 kernel 行/列顺序、五段首尾的参与行、kh<6 和横向尾部回退、所有转换和间接栈地址。arithmetic_and_load_review 解释实际普通或 indexed FMUL、独立 FADD、input/coeff load 及寄存器生存期，不拿24累加器理论预算当作零 spill 证明；D 寄存器 ABI 保存、Z/Q/input/product/accumulator spill 分开记录。工具从实际范围推导全部指令、普通/indexed FMUL、FADD、LD1W/LD1RW/LD1RQW、DUP/indexed MOV、EXT/MOVPRFX；不强制 C40 的固定条数或五行 helper 规则。真实 spill 不会自动导致正确性失败。

dispatch_functions 覆盖全部 conv2d 和 conv2d.* 函数，精确 symbol/line_start/line_end 及 control_flow_notes/stack_notes；包括六行组最后1..5行的独占输出与旧 helper 回退。这里只要求 C47 纯 C 实际汇编，不需 C46 的五段显式 asm 操作数证明。当前 wrapper 没有 production .o，成功记录明确 production_object_disassembly_available=false，不宣称审过对象反汇编。

本轮没有运行上述工具或产生新的计算结果；所有性能资格、独立确认与最终交付决定均留给根代理。
