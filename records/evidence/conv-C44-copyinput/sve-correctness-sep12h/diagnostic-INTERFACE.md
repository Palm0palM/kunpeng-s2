# H 诊断运输与验收接口（仅 prepared，尚未执行）

本文件和两个公共 Python 工具只完成轻量代码准备与静态审查。没有在本机运行编译、题目、测试或新解析器，没有 SSH、作业提交或重置卡操作。候选包 source 已冻结；工具不修改它们。H 尚未获准执行，只有根代理可以在当前 CONV 作业序列结束后决定显式提交。

## 调用顺序

在仓库根目录使用现有已核实配置（不会将配置、密码或认证文件上传）：

```text
python3 .runs/conv/sep12h-checks/diagnostic-driver.py C43-padinput config/conv-sep12.local.json gate
python3 .runs/conv/sep12h-checks/diagnostic-driver.py C43-padinput config/conv-sep12.local.json submit --go
python3 .runs/conv/sep12h-checks/diagnostic-driver.py C43-padinput config/conv-sep12.local.json status
python3 .runs/conv/sep12h-checks/diagnostic-driver.py C43-padinput config/conv-sep12.local.json fetch
python3 .runs/conv/sep12h-checks/accept_returned.py C43-padinput
```

C44 替换版本名使用同一接口；每次 submit 都需新的显式 `--go`。这些是供根代理后续调用的命令，不是自动执行计划。gate/status/fetch 调用会连接超算；acceptance 仅解析已返回的文本，不执行算子。

- 配置严格要求 38 CPU、24576 MiB、一个 packed NUMA、1800 秒。wrapper 在计算节点再检查实际 affinity 为 38 CPU 且属于单个 NUMA；诊断每次仅用 1 或 4 线程。不会运行原 `run.sh`、benchmark 或设置新的计时区。
- gate 只对本任务当前明确的 F 1579528、profile r2 1579588、G C40 1579597，以及 G C41/C42、G 性能和两个 H 包后续保存的真实 job ID 做当次只读调度查询。准备后从未提交、无 job 的包不视为活跃；已尝试提交但 ID 不明则停止等待人工/根代理核实。没有全盘历史扫描，也不检查 TRSM/ZGEMM。
- 查询返回 pending/running、未知状态、失败查询或缺少两退出值时不提交。终止失败允许留痕取回，不会伪装成正确性通过。所有 gate 查询文本和解释保存到版本目录 `gate-<timestamp>.json`。这份有界检查不能发现未登记的作业；协调者必须确认本任务没有其他活跃计算，才可输入 `--go`。gate 本身不会授予执行权限。
- submit 在任何上传前用独占方式建立 `job.json`。同包再 submit 一律拒绝；上传失败、提交结果不明确也保留该文件，不自动重试、删除或分配新 ID。提交成功马上保存唯一 ID，后续只查/取这个 ID。尚未提交的源码只接受既有 `source-hashes.json` 和 experiment checkpoint，不静默重新生成身份。
- status 失败/无法解析会保存返回文本并保留上一份真实状态。fetch 允许已知终止失败作业，保留编译失败等证据；不接受正在运行的作业。再次 fetch 不覆盖内容不同的 raw 文件。所有传输和取回均按普通文件白名单，`.h` 被包括；配置、认证、可执行程序不加入源包。实际生产 `.o` 可保存在本地 raw 供对照，不作为发布源码。

## 六配置与精确计数

SVE bytes 为 16、32、64，每个分别 threads 1、4。每份包共：

|路径|每配置|六配置|
|---|---:|---:|
|未插桩生产对象 strict guard|24100|144600|
|单独插桩 copy-success|6048|36288|
|单独插桩 copy-failure|6048|36288|
|专项合计|36196|217176|
|原 runner|0|0|

`copy-success` 每配置必须报告：cases 6048、eligible 2800、disabled 3248、malloc attempts/successes/free 各 2800、forced failures 0、memcpy 28280、errors 0。六配置累计 malloc success/free 各 16800，memcpy 169680。

`copy-failure` 每配置必须报告：cases 6048、eligible 2800、disabled 3248、malloc attempts/forced failures 各 2800，success/copy/free/errors 均 0。六配置 forced failures 累计 16800。C43 的 `STRIDE_MODE=padded`，C44 为 `original`。

这只证明候选 malloc/free/memcpy 路径；没有 helper-entry 插桩、worker-mask 字段或入口计数结论。实际线程及 VL 由 guard 的逐 worker 检查及唯一配置头确认。原生产对象与单独插桩对象分开编译链接；后者只能证明注入条件下的路径，不替代前者的逐位验证。

512 MiB 上限、size_t 极值及大尺寸分配不做端到端动态测试，仅保留静态证明。不能给它们填动态 PASS，也不分配超大内存或传入非法 buffer。未运行 sanitizer。详细矩阵、成功时每行复制/释放前输出校验、失败回退及 padding 范围见各包 README / STATIC_REVIEW。

## 返回与失败保留

验收输入包括：

- `job.json`、真实 `scheduler.log`、原 `source-hashes.json` 及 experiment checkpoint。
- raw 中十个源文件与 `source-sha256.txt`；`probe.log`、`stage-exits.txt`、`exit-code.txt`、`environment.log`。
- `build-production.log`、`build-guard.log`、`build-assembly.log`、`build-copy-probe.log`；生产 `conv2d-sve.s`、`production-conv2d-objdump.log`、`production-object-sha256.txt`（取回了生产 `.o` 时也核对其身份）。
- 六份 `guard-vl{16,32,64}-t{1,4}.log`，十二份 `copy-{success,failure}-vl{16,32,64}-t{1,4}.log`。
- 对当前未插桩生产对象的 `assembly-review.json`，由审查者在真实产物回收后填写，不能提前杜撰。

wrapper 必须出现 26 个按序的 stage exit=0：allocation、source-manifest、production-kernel、production-guard、production-assembly、六个 production guard、instrumented-kernel、instrumented-guard、十二个 copy probe、complete。scheduler 的真实 ID、SUCCEEDED、job/system 两退出 0、wrapper 退出 0 缺一不可。

实际执行 argv 从各 build 日志中 `+ gcc ...` 的 xtrace 行逐条解析，使用 shlex 而不是执行日志。wrapper 的逐段 `BUILD_COMMAND:` printf 可能与 set-x 输出交错，因此不依赖该展示标记的单行格式。八条编译/链接/汇编命令必须与冻结 wrapper 严格匹配：生产对象由 `conv2d.c` 单独编译；guard 为单独未 tune/未 wrap TU；插桩对象由 `instrumented_candidate.c` 编译，probe/guard 各自为独立 TU；原 benchmark/runner没有执行。当前声明环境要求 GCC 10.3.1，返回版本不同会保留证据并阻止这份验收。

验收失败只新增 `acceptance-failure-<timestamp>.json`，不覆盖 raw/source/prepared 或任何已存在 validation。成功后以独占创建写入 `validation.json`。编译失败或缺日志不会产生 PASS，也不会自动修补 frozen source 或再次提交。

## assembly-review.json 必需结构

以下为字段规格，不是通过结果，也不提供填好的 PASS 模板：

- 身份：`candidate`、`job_id`、`source_sha256`、`compiler_version`、`production_object_sha256`、`assembly_sha256`。hash 来自当前真实返回产物的自动身份校验，不需要重复人工大范围审计。
- 必须由真实审查确认的布尔字段：`review_complete`、`production_uninstrumented`、`production_object_disassembly_reviewed`、`whole_source_fma_reviewed`、`whole_quad_and_dispatch_reviewed`、`all_stages_and_transitions_reviewed`、`abi_saves_distinguished`。
- `whole_source_fma_count` 和 `production_object_fma_count`：验收器分别从完整 `.s` 和实际 `.o` 反汇编推导，必须为 0；spill 是观察项，不是正确性失败。
- `whole_machine_code_identical_claimed=false`。`c6_background={source_version:"C26-row4loads",quad_phases:7,notes:"..."}` 仅说明背景，当前汇编必须单独检查。
- `quad_helpers`：覆盖 `.s` 中全部 `conv_sve_rowquad` 及其实际 clone。每项 `symbol`、`line_start`/`line_end` 要精确对应完整函数标签至 `.size` 行，另含 `stack_frame_description`、`spill_notes`、`vector_spill_loads/stores`、`transition_spill_review`。
- 每个 quad 项的 `stages` 必须按 `input_0,input_1,input_2,shared,trailing_0,trailing_1,trailing_2` 排列。各 stage 需真实、不重叠的 `line_start`/`line_end`、`kernel_columns_per_iteration`、`source_mapping`、`spill_notes`、`vector_spill_loads/stores`。验收器推导实际 FMUL/FADD、加载、movprfx、ext 和总指令数量；审查者区分热点 spill、阶段转换 spill 与 ABI 保存。
- `dispatch_functions`：覆盖 `.s` 中全部 `conv2d`、`conv2d.*` 函数（包括 copy/compute 的 OMP worker）。每项完整范围与上述全函数栈/spill字段，另需 `role`、`copy_path_notes`、`control_flow_notes`。仅检查 quad 不足以覆盖新增内存路径。
- `copy_path_review` 需有实际解释：`eligibility_and_overflow`、`malloc_and_null_fallback`、`row_memcpy_and_stride`、`compute_and_free_order`、`noncopy_and_non_sve_fallback`。逐函数说明与完整生产反汇编配合，不能把内联源码相同当作完整机器码相同。

这份验收仅产生专项正确性结论，`performance_measured=false`、`promotion_decision=none`。C44 永远是 reference-only。性能对比、独立确认、原 ZIP 验证与正式晋级仍由根代理另行安排；目前 C6 不变。
