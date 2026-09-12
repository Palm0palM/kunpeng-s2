# Z：C52 原 ZIP 条件验证，仅准备

本次只写 `sep13z-submit-package.py` 与本说明。准备前只读确认 C52-package 的 run 和 record 均不存在；首次检查 Y 尚无 campaign/job，所以没有预填 Y ID 或 PASS。没有导入或执行 U/Z 或其前置工具，没有 SSH、new/checkpoint、创建包版本、campaign、ZIP、预约、job、record、晋级或发布。工具只是待 root 全文/diff 审查的条件入口；未来只有 root 明确 GO 后唯一提交。

```text
python3 .runs/conv/sep13z-submit-package.py --go
```

固定包版本为 **C52-package**，原实现为 **C52-row7x3shared2**，确认版为 **C52-r1**。包从确认版 source 建立快照，但四文件必须与原实现完全一致；metadata 分别写 source_parent=C52-r1、source_origin=C52-row7x3shared2、diagnostic_source_version=C52-row7x3shared2。conv2d.c 固定 SHA `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。README、官方 benchmark、原 runner、编译 flags、线程/NUMA设置均不改。

入口先要求原唯一 Y campaign 已 performance_complete 且 confirmation_passed=true；缺失、运行中、失败或 confirmation_passed=false 都在任何 new/ZIP/SSH 之前阻止建包。失败 Y 不允许用新确认、换 ID、换样本或本包测试补救。root 后续唯一提交 Y 后，本任务只读确认原 campaign 与三个 cluster manifest 都为真实 job1582410 / group kp-conv-group-643f10609c47；当时状态仍 performance_running，未有确认结论。工具据此固定 CONFIRMATION_JOB=1582410，不接受换号；没有伪填 PASS，仍须真实最终记录/调度原文全部一致。

W1582256 固定顺序 C26-r26 / C52-row7x3shared2 / C51-r2 / C26-r27，完整48原样本，必须仍为初筛 qualified=true、待确认仅原C52且两端C6比较为true。Y固定 C26-r28 / C52-r1 / C26-r29，完整36原样本，必须有独立 job/group，campaign和C52-r1均 confirmation_passed=true，确认队列空、qualified=false、未混合初筛样本、失败重试禁止。Y必须指向原W1582256，不能借用S或C51结果。

参照未执行 U 的已审通用文本结构，Z自行保留逐记录验证和 strict_gate 定义；**不会导入或执行 U**。每轮每个成员重读原 benchmark/environment/source清单/exit/scheduler，正常核对取回产物身份、原source/current/manifest一致、真实passed/verified、6项checks、job/group/order/index、fetch完成和scheduler/job/system/wrapper0。原 parser 再核三个完整套件、四固定case各3样本、全部PASS及原数组/中位数/spread等；同一轮机器一致，aarch64/GCC10.3.1/generic/38线程/38唯一CPU和NUMA有效。W与Y各自保留实际分配，不跨轮混样。

W、Y各自对本轮前后C6单独重算标准比较；两端均要求总中位数收益 **严格大于 max(1%, 两版本所有case spread)**，并且 **每case（含第一组）退化≤1%**。saved comparison 的数组、原因、收益及门槛必须与标准重算一致。W好样本不能替代Y，C51辅助比较不替代C6；不会筛掉任一慢样本。任一门槛不满足即停止，不打包或重测。

当前最佳必须仍是相同 **C6=C26-r1**：outputs最佳、records/best、题目主源码、C26-row4loads和所有W/Y控制字节一致。W/Y/当前C6 settings一致，并且候选与配置effective_settings一致。固定三套、38 CPU/线程、24576 MiB、1 packed NUMA、1800秒、OMP38/FALSE/close/cores、generic/GCC10.3.1。总中位数是内部指标，不是官方评分。

实际诊断复用已审 W 的 C52 自身 T gate，要求 `.runs/conv/C52-row7x3shared2/sve-correctness-sep13t` 的 T1582134、37128完整PASS、19stage及全部退出0、六VL/线程配置、真实编译/源清单/分配、13语义阶段/14真实区域、独立shared两列与奇数余列审查及原样冻结。Z不重新诊断、不accept/freeze，也不用Q/C51提供C52 PASS。S1582067 confirmation=false、W的C51-r2 reference_only=true/promotion_allowed=false/qualified=false和旧结论只读保持。

实时serial只覆盖固定 W1582256、T1582134、S1582067、已知原X1582372、原Y实际campaign和三member，以及现存P job与Z明确reservation。P路径为 `.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json`；X为 `.runs/conv/sep13x-checks/C53-row7cursors/job.json`；Z检查 `.runs/conv/sep13z-campaign.json` 和 C52-package/cluster.json。本工具不创建独立Z campaign；包目录/record就是标准实验预约。固定ID缺失/变化、现存预留无ID、非terminal、查询失败或缺整数退出码均阻止；W/T/S/Y还须SUCCEEDED且job/system0。没有P job不阻塞，已知X身份不可消失或换号；X状态只信实际查询。按ID去重，每次查询最多45秒，不扫描队友或取消作业。

root是唯一计算协调者。门禁通过后，在共享workflow lock内再次核完整上下文未变化、当前C6和固定包ID未占用，再标准new(parent=C52-r1)/checkpoint。metadata标明 reference_only=true、promotion_allowed=false、package_validation_only=true，保存W/Y四个严格比较、T身份、历史结论与实时gate。已有package run/record或Z campaign立即拒绝；不明状态保存原件，不重建预约。

随后仅以 `python -B` 子进程调用一次已审 `.runs/conv/sep12-submit-package.py`，不导入其顶层提交代码。该传输工具从私有source快照生成并保存唯一 `conv.zip` 和成员/ZIP清单，上传同一字节流，并在首次传输前排他预约cluster.json。Z独立保存精确argv、完整stdout/stderr和返回退出码，任何失败/不明保留包和预约，不重跑submit。

ZIP只在调度分配计算节点的remote_job.sh中核对原ZIP及成员身份、解压成source，然后用包内原runner执行三个完整套件；所有编译/正确性/性能均在计算节点，本机只允许未来获GO后的轻量打包/传输。应有 **3套×4case=12 PASS**。submit成功只表示已提交；Z不轮询、取回、record或把包判为通过，也不执行U finalize。

后续 root 必须只接管这个唯一包job，检查真实terminal、所有退出、PACKAGE_SHA256_VERIFIED、完整12 PASS和原ZIP身份后决定交付。已验证的 **同一conv.zip原字节就是最终交付包**，不可验证后重新压缩；Z提交返回也核对本地ZIP SHA与上传package manifest一致。没有自动晋级、ZIP后续制作、公开发布或比赛平台提交。额度达到用户40%停止线时保存现有状态并STOP，不用重置卡。

准备完成后 STOP，供 root 审查；这份说明不授予新作业权限。
