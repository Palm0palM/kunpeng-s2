# T：C52 shared 双列展开独立诊断，仅准备

候选 `C52-row7x3shared2`，source parent `C51-row7x3u1`。根代理已审最终源；本包复制实际 C52 `source/conv2d.c`，固定 SHA256 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。七输出行×3VL、21 累加器与 helper `conv_sve_rowseven` 保持；仅 shared kernel 列循环展开两列，其余十二阶段仍 u1，shared 的奇数余列仍 u1。源码、record、benchmark、runner 和历史 Q/R 文件未由本任务修改。

T 的两个 C 检查器从已独立逐行审过的 Q 原文件逐字复制。父 Q job1581822 的 37128 PASS、零 spill 和 63 指令 shared 循环只证明 C51，不是 C52 的结果。R 原组 job1581911 已终态，root 报告 C51 初筛通过并优先安排 S 独立确认；T 只保留待审方案，不因此获得 compute GO、性能或晋级资格。

当前只有三个工具、五个传输源文件、首次 source-hashes/source-manifest/prepared 清单及文档。没有 T job.json、campaign、raw、assembly-review、validation 或冻结结果；未执行/导入工具、编译、测试或 SSH。下面的命令和数值均为未来接口与计划。

## 原样复用的矩阵

VL 字节数16/32/64，lanes=4/8/16，每行主块=3*lanes=12/24/48，线程1/4。六个配置逐个确认实际 worker VL/team。

| 路径 | 每配置 | 六配置 |
|---|---:|---:|
| 未插桩生产 full | 4784 | 28704 |
| 独立插桩 dispatch | 972 | 5832 |
| 直接 kh<7 防御回退 | 432 | 2592 |
| 合计 | 6188 | 37128 |
| 官方 runner | 0 | 0 |

- full core=3888：6 宽（3L/6L±1）×kh6/7/8×kw1/2/3×18 高（1..15、21、22、28）×4 分配方式。覆盖全部七行分组余数和主块边界。
- narrow=144：ow1×kh6/7/8×kw1/2/3×oh1/7/13/28×4。small=720：ow1、3L−1、3L+1×kh1..5×kw1/2/3×同四高×4。
- larger=32：kernel(10,7)/(9,8)/(15,15)/(81,81)×oh7/13×4，ow3L+1。kw7/15/81 为多对加一余列，kw8 为多对无余列。
- dispatch 为 core 去掉分配组合、固定 pad1/leading0，共972。每 case 精确核对新增 rowseven 入口：仅 kh>=7 且 oh>=7 时为 floor(oh/7)，全套756。
- direct：kh1..6、kw1/2/3、ow3L−1/3L/3L+1、oh7/28、四种分配方式，共432，累计1080 次 rowseven 入口。它验证 kh<7 的 quad+triple 防御回退，不执行 shared 算术。
- dispatch/direct 各自 worker mask 在1线程为1、4线程为15，五个旧 prefix/tail/pair/triple/quad 入口均须累计非零。direct 重置发生在既有 team 全部 join 后。未对十三阶段或 shared 两个块做动态插桩，helper 入口计数不能当作这些内部块的逐 case 入口计数。

kw1 跳过 paired，仅走单列余数；kw2 走一对且无余列；kw3 一对加一余列。full/dispatch 的 kh7/8 且宽度达到3L、oh达到7的子集能够经过新 shared，kh6、窄宽和 direct 则保留分派/回退边界检查。预期值始终由原独立 ky/kx 顺序 scalar reference 得出，没有从 C52 被测实现生成参考答案。

四种分配为 pad0/1×leading0/1，input/kernel 只读，分配两端 PROT_NONE、页内外围 canary、output poison，并 memcmp 逐位检查。没有每行独立 guard 或 sanitizer。保持 Q 已接受的有界范围：不新增建议的 L/2L±1 864 full；direct 无 ow1，正常入口 ow1 不能替代 direct ow1；不声称测试9×7/8×8。旧 helper 非零及 mask 为整套累计指标。实际必须返回精确 `FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32` 及各 PASS/入口/mask。

## 未来执行、原件与串行边界

```text
python3 .runs/conv/sep13t-checks/driver.py C52-row7x3shared2 config/conv-sep12.local.json gate
python3 .runs/conv/sep13t-checks/driver.py C52-row7x3shared2 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13t-checks/driver.py C52-row7x3shared2 config/conv-sep12.local.json status
python3 .runs/conv/sep13t-checks/driver.py C52-row7x3shared2 config/conv-sep12.local.json fetch
python3 .runs/conv/sep13t-checks/accept_returned.py C52-row7x3shared2
python3 .runs/conv/sep13t-checks/freeze_returned.py C52-row7x3shared2
```

唯一提交者为 root 协调者，必须先审工具并明确 GO，`--go` 不是脚本自行授权。S 优先。串行门槛只查询固定 R campaign 的实际 job1581911、已有 P job、自己的 T job，以及实际存在的 S campaign 和三个成员 C26-r24/C51-r1/C26-r25 的 cluster.json。S 尚无这些文件不阻塞；已有 S campaign 或任一 job/cluster 预留却无可对账 ID 必须阻塞，不因 prepared 字样放行。P/T 无 job.json 只代表未预约，不阻塞。ID 去重后逐个有界查询，查询失败、非终态、缺失整数 job/system 退出码或 R 身份变化均停止。不会扫描队友、取消作业或实现跨协调者调度锁。

提交前固定源 SHA、当前 candidate checkpoint、候选原源、五文件传输清单和 prepared 计划必须一致。首次上传前排他创建 T `job.json`；任何上传/提交不明保留预留与原日志，禁止删除后重提。status/fetch 只恢复已保存 ID，fetch 只取安全单层普通文本/源码/.s，已有不同字节拒绝覆盖。无独立 .o 产物、无对象反汇编。没有 T campaign 路径。

资源固定38 CPU、24576 MiB、一个 packed NUMA、1800 秒。包装在调度分配节点核对 Linux/AArch64、38 affinity CPU 同 NUMA、GCC10.3.1；manifest 阶段写实际五文件 SHA 并核对固定 C52 源。三条真实编译 argv 保留 Q 的 `gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3`，依次构建独立 TU full、唯一带 `-finstrument-functions` 的 dispatch、未插桩 `-S conv2d.c`。所有编译和运行仅在超算计算节点。

19 个作业阶段为 allocation/compiler/manifest/build-guard、六 guard、build-dispatch、六 dispatch、build-assembly/complete。验收要求精确有序 stage-exits 全0、wrapper0、真实 scheduler SUCCEEDED 且 job/system均0、真实 xtrace argv、编译版本、allocation、返回源清单和六配置实际日志全部一致。planned 数不冒充 actual 数。

## 返回后填写的汇编证据契约

本阶段不创建 assembly-review.json，不预填实际 PC、栈大小或机器计数。未来审阅实际返回 `.s`：绑定 candidate=C52、唯一自己的 job、固定 source_sha256、compiler_version=10.3.1、实际 assembly_sha256。全部真实 rowseven helper/clone 须从 label 到 .size 完整审，全部 conv2d/conv2d.* 实际函数也须完整审。源相同的尾部/dispatch 仍可能因编译布局改变，不能仅引用 Q 的结论。

每 helper 的 `stages` 仍精确为 input_0..5/shared/trailing_0..5。其余12阶段沿用 Q 的 line_start/line_end、kernel_columns_per_iteration=1、source_mapping、spill_notes、非负 vector_spill_loads/stores。shared 是一个语义阶段，改用以下字段，不提供伪造的 aggregate PC：

- shared 必须有 source_mapping、control_flow_notes、accumulator_order_review、pair_to_remainder_review、transition_spill_review。
- `blocks` 精确顺序为 paired、odd_remainder。每块有 block、line_start/line_end、region_kind、kernel_columns_per_iteration、source_mapping、spill_notes、vector_spill_loads/stores、entry_exit_notes。
- paired：region_kind=loop，工作量2；odd_remainder：region_kind=loop 或 straight_line，工作量1。后一种不要求虚构回边。entry_exit_notes 应说明真实条件、kw1/2/3和奇偶路径、跳过条件、指针/计数增量；accumulator_order_review 说明每个累加器仍按 ik 然后 ik+1 独立累加，没有 partial sum 或重关联。
- 12阶段与2个 shared 区域共14个实际不重叠范围，均在完整 helper 内。接受器直接从实际字节计算 derived_counts：总指令、普通/indexed FMUL、FADD、LD1W/LD1RW/LD1RQW、DUP/indexed MOV、EXT/MOVPRFX；另按工作量除出 derived_counts_per_kernel_column。paired 要求实际42 FMUL/42 FADD，余列21/21；这是工作量契约，其他机器数量不预设。

若编译器复制、合并、提升算术而不能如实提供上述独立范围，或出现不同展开、缺少可识别 paired/余列，则保留真实产物和 acceptance-failure，停止交 root 审查 schema，不画假范围来满足计数，也不把解析问题伪装为算子失败。直线余列是明确允许的预期形式，不构成这一阻断。

review 顶层须 review_complete/production_uninstrumented/whole_helper_stack_reviewed/all_stages_and_transitions_reviewed/abi_saves_distinguished/dispatch_reviewed/shared_pair_and_remainder_reviewed 全 true，shape={rows_per_group:7,vectors_per_row:3,accumulators:21}，shared_unroll={paired_columns:2,odd_remainder_columns:1,other_stage_columns:1}，whole_machine_code_identical_claimed=false，whole_source_fma_count=0。每 helper 保留 stack_frame_description、spill_notes、transition_spill_review、tail_and_fallback_review、arithmetic_and_load_review 和整个 helper spill 计数。完整审 ABI D 保存与 Z/Q/谓词 spill、间接栈地址、两列输入/系数活跃期、所有13阶段转换、pair→odd→下一输入行、21 stores、横向尾部、kh<7 回退及全部 dispatch。词法作用域与21acc预算均不证明零 spill；真实 spill 不自动构成数值失败。

与父 Q 的63指令/u1及其零 spill只能作明确归一化的静态背景比较；报告 T 自身 paired 每2列与 odd 每1列的实际指令、加载、栈访问和控制流。差值不等于纯回边/spill成本，更不是速度测量。T 不设自动性能资格或提交。

成功 validation 保留实际源/作业/退出、19 stage_exits、六配置/入口/mask及上述汇编，helper语义stage_count=13、arithmetic_region_count_per_helper=14，FMA=0；不测性能且要求root后续审查。数值日志不能单独完成验收。真实执行失败可 `--failed`，未知实际case数为null，缺失.s不补造。freezer 在共享锁下原样复制现有证据及工具/接口，实际.s同字节保存.assembly.txt，再原子 rename 到 `.runs/conv/C52-row7x3shared2/sve-correctness-sep13t`；已有目标/staging拒绝覆盖。准备时没有执行接受或冻结。
