# R submit 前半独立静态审查

2026-09-13，审查范围仅 `.runs/conv/sep13r-submit-performance.py` 第 1–284 行的常量、`old_c40_decisions`、`verify_settings`、`previous_gate`、`query_job`、`serial_gate`、`diagnostic_gate`。作者明确 final-ready 后逐段阅读；当时文件 SHA256 为 `52d80cba970accfb2de6345466214b540f442de6911b641fa8479258d4ae48a3`。main 后半、record 和 compare 由 root 独立负责，本报告不重复审查。

结论：在当前真实 G、N、Q 冻结/登记 schema 下，未发现本范围内需要修复的阻断问题。此结论是静态门槛审查，不是执行门槛所得 PASS，也不是 R 提交授权。仅使用本地文本读取、搜索和一次审查文件指纹；未导入或执行 R/Q/N 工具，未编译、测试、SSH、创建 R 预约、成员或作业。没有修改 R 代码或任何历史记录。

| 契约 | 实际对照与结论 |
|---|---|
| 历史 C40 决策（42–64） | G `qualified_for_confirmation=false` 且两端比较均不合格；J 为 true；K record/campaign 的 `confirmation_passed=false`。G/J/K 源清单一致。N 的 C40-r3 必须来自原 job 1581459、同源、`reference_only=true`、`promotion_allowed=false`、`qualified_for_confirmation=false`，并且不在 N confirmation_pending 中。返回保留的决策，没有将参考样本重新转为候选。 |
| N 必须完整结束（73–110） | 对照真实 `.runs/conv/sep12n-campaign.json`、八份实验记录、八份 cluster.json 和 exit-code.txt：原组 `kp-conv-group-fc59912bef61`，job 1581459，八成员顺序固定，真实 scheduler SUCCEEDED/job+system 0、八 wrapper 0。门槛逐成员要求 passed/verified、四 case 各三样本、同 machine/settings/environment/reference、全部 checks 为真、source/manifest/当前快照一致以及 group/index/order 一致，最后要求精确 96 样本。不能遗漏失败或慢成员、挑一个较好 trial 替代完整 N；当前 N 八项资格均为 false、confirmation_pending 为空。 |
| strict 设置（67–70、83–104、217–225） | 三套原始 benchmark、OMP 38/FALSE/close/cores、CPU_TARGET generic、38 CPU/24576 MiB/单 NUMA pack/1800 秒与真实 N 一致。诊断三条 argv 精确比较，包含 GCC 10.3.1、`-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3`；只有 dispatch build 加 `-finstrument-functions`，生产汇编为单独 `-S conv2d.c`。R 主流程的当前 benchmark/run.sh 保持检查属于 root 范围。 |
| 串行门槛（113–177） | 汇集固定 H/J/K/N 身份及原 H/I/L/M/O、可选 P、Q 诊断和 G/Q 冻结 job、既有相关成员 cluster 与 campaign。已有预留无数字 job ID、已知身份改变、查询失败/超时、无法解析、非终态、缺失整数 job/system 退出码都会使 clear=false。只忽略明确 prepared/planned 且 submitted/submit_attempted 均 false 的未提交 campaign，不忽略未对账的 R 预留。终态失败可证明资源已经结束；它不被当作数值成功，G/Q/N 的成功由各自门槛另行严格要求。本审查没有运行未来的远程串行查询。 |
| C40-r4 仅复用 G（180–239） | 路径固定为原 C40-row6x3u1 的 `sve-correctness-sep12g`，实际 job 1579597、源 `cb471782329b01b9bf72d6e992941edde1361d19ced2bb69a576ec5fa8ee69e7`、26112=6×(3560 full+432 dispatch+360 direct)，11 个 helper 阶段、FMA=0。历史 G 的 build_commands 是直接 argv 列表、assembly 阶段位于顶层；分支按此真实旧 schema 读取，不要求不存在的 Q helpers 格式或补造 G 的 19 阶段记录。源需与当前参考快照及原 raw/conv2d.c 一致，不能借 G 给 C51 通过。 |
| C51 必须自己的真实 Q（180–284） | 实际已冻结 `.runs/conv/C51-row7x3u1/sve-correctness-sep13q`，job 1581822、passed/complete，37128=28704 full+5832 dispatch+2592 direct，runner=0。六组 VL16/32/64 bytes×threads1/4 各 4784/972/432；lanes=4/8/16、每行 block=12/24/48，dispatch/direct rowseven entries=756/1080，mask=1/15，五个旧 helper 累计入口均非零。代码同时要求原 scheduler.log 解析一致、job/system/wrapper 0、19 个精确有序 raw stage-exits 全零及对应 validation 字段，不以总计或单个 PASS 代替这些条件。 |
| Q 来源、汇编与冻结（240–284） | 候选和固定 C51 源 SHA `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff` 绑定；原 source-hashes/prepared/job/validation 和 manifest 的五文件集合一致。实际 Q assembly 的 helpers、dispatch_functions、shape=7/3/21、13 个 input_0..5/shared/trailing_0..5、derived_counts.fmul/fadd 字段与门槛相符；要求全部阶段、转场、helper 栈、ABI、tail/fallback、dispatch 完整审阅及全源 FMA=0，逐阶段范围和单 kernel 列约束存在。实际已接受 Q 验收器另核对返回 `.s` 的全部真实 helper/clone 和 dispatch 符号；R 检查该冻结审阅及 `.s`/同字节 `.assembly.txt` 身份。spill 可存在，R 未把零 spill 当作通过前提。 |

实际 `freeze-source.json` 为 candidate C51、job 1581822、mode=passed、assembly_available=true，original_metadata/source/raw/source_manifest_preserved 均 true，validation_rewritten/operator_executed 均 false，吻合 R 所读字段。Q 的 19 个作业阶段与 13 个 helper 算术阶段分别检查；不会把 C51 原建议的 40368 项当作实际 37128 项。Q 数值/汇编来源与 C40/G 明确分离，保留不自动性能提交、无既有测速、须 root review 等诊断范围。

所有具体对接检查已反馈作者和 root；没有需要作者修订的条目。审查任务完成并 STOP。后续 R 是否获准提交，以及提交时实时串行门槛是否 clear，由 root 和执行责任人处理。
