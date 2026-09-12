# AB 性能工具独立静态审查

结论：最终三工具及 README 未发现静态阻碍。Galileo 已明确 final-ready/STOP；独立读取的最终字节与其公布身份相符。本报告只评估工具是否遵守来源、记录和比较契约，不确认 AA 已完成验收/冻结，也不授权或执行 AB。仅新增本报告；未导入或执行新工具、SSH、算子、作业、记录、包或晋级，未修改源码、历史或其他人的文件。

审查覆盖三工具与 README 共728行全部内容、作者静态说明，及实际复用的 W diagnostic_gate、R comparison/资源验证、experiment.comparison 和 cluster_group.submit_group。AA 三工具及多区间接口已由本代理另行完成独立审查；没有重复阅读 root 负责的实际 dispatch 汇编。

| 最终文件 | 字节数 | SHA256 |
|---|---:|---|
| sep13ab-submit-performance.py | 29334 | `f432ab971c42c56fe6ad4977234fb1fd287c5000c0313676a7d0e6390b137779` |
| sep13ab-record-group.py | 9053 | `d91349aa03b3adccf257813456e87595abb8a91545352409a185396b4fba481a` |
| sep13ab-compare.py | 6413 | `a01929d96ed061c46935d1453d918c754b1daa02c5992c1bec36e2b2c2142879` |
| sep13ab-README.md | 6648 | `c8d62b1dc605a72baa6a27d493e2a4af87cf5f129659d7243cf07ba02c4bdf3a` |

固定测量顺序为 C26-r30 / C54-row7x3shared4 / C52-r2 / C26-r31，唯一候选 C54，C52-r2 为参考。每成员3套×4例，总48个原样本；两端均与当前 C6/C26-row4loads 源一致。README、bench_conv.c、run.sh 在候选、参考和两端控制中保持一致，设置绑定同一组的 GCC10.3.1/generic、38CPU/线程、24576MiB、1 packed NUMA、1800秒及 OMP FALSE/close/cores。没有改变官方尺寸、参考、runner/flags 或计时逻辑的入口。

C54 的诊断门禁要求自身 AA1582656，而不是父 T：固定 fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88，实际 live job 与冻结 job、validation、scheduler 原文、raw source/.s/.assembly.txt、prepared/两 manifest 相互绑定；须 passed/complete、44328（full34464/dispatch7272/direct2592/runner0）、十九stage全0、scheduler/job/system/wrapper全0。六配置5744/1212/432、家族960/240新增部分、入口1236/1080、mask1/15、实际三条编译argv和38CPU单NUMA均明确检查。缺少 validation/freeze 或任何身份/结果不符会在创建 AB 预约前阻止。

AA `aa-shared4-paths-v1` 已正确对接：13语义阶段，shared角色quad_main/u1_remainder；每块多个实际ranges按完整工作量聚合，而非把每段误认为完整84/84。quad work4、u1 loop work1、直线u1 work1..3；各块21×work的FMUL/FADD及归一化值、实际不重叠范围、0..3余数路径顺序/执行次数和全部余数块使用均核对。helper和顶层范围数从真实ranges数量检查，未固定14。完整helper/clone、ABI/转场/边界/标量及向量栈说明和FMA0必须来自已验收实际AA；父T源码/.s仅作独立背景比较，不提供本版零spill或机器码相同结论。AB门禁使用已冻结AA的人工审查与派生计数，不重新制造PC或运行接受器。

C52-r2 则明确使用原 C52 的8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7，并以原版本名调用 W 已审 T1582134 gate，核对原37128及其paired2/odd1实际证据。这里的固定14区域仅属于真实父 T schema，没有套到 C54。参考版始终 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false，保存 prior_confirmation_version=C52-r1、Y1582410/false；辅助比较结果无法改变这些字段或进入确认队列。

历史入口读取完整 Y36及 false，逐成员绑定原数组、来源、机器、设置、调度与wrapper、两端比较；继续调用已审 Y/W/S/R 历史定义。Yfalse/Sfalse及旧参考身份在比较前后复核，不写原Y/S/W记录。新48样本仅来自AB，未包含历史数组或删除慢样本的分支。

预约与提交只在 explicit --go 后发生：先检查未占用的新成员/campaign、当前C6、原历史、来源与完整诊断，再实时查询固定 Y/X/T/AA 和明确 P/AB reservation。缺失/换号、未知预约、查询失败、非终态或退出字段不完整均阻止；存在但未固定对账的 P 也保守阻止，不扫描队友。公共锁内再次复核后先保存campaign，再new/checkpoint三名新成员并登记四成员。复用的 cluster_group 在任何网络操作前用open('x')预留全部member manifest；随后原顺序运行，任一member失败会使group失败。保存后的预约、上传/提交未知结果不会被删除或自动重投。该流程依赖 root 唯一提交协调，不是全系统分布式调度锁。

creation metadata 的 source_hashes 快照不会被替换。提交阶段更新本轮设置和关联字段后 checkpoint记录当前源；record要求 prepared/current/submitted 三者一致，检查 metadata 时仅用 `dict(metadata, source_hashes=source)` 内存视图，保留创建时快照。原记录为passed时只在完整验证匹配后跳过；失败状态拒绝覆盖。记录只对保存的同组原ID执行status/fetch，要求真实SUCCEEDED、两退出0及随后全部checks；逐版本预期尺寸四例、每例三样本、机器和来源均校验。首次record/解析失败的外层stdout/stderr/exit仍须由执行者保留并停交root，不据错误重测或放宽schema。

比较必须先取得全部48 PASS、同一实际group/machine/settings、所有wrapper与调度退出0。它复用原 R 包装和 experiment.comparison：C54 对前、后 C6 分别要求总中位数收益严格大于 max(1%, 两版本所有case spread)，并要求每一例收益>=−1%，第一例没有豁免。只有两端 eligible 同时为true才标初筛 qualified_for_confirmation。reference_only 分支始终保持false资格；C54 对 C52-r2 的整体辅助比较单独保存，不替代任何 C6 gate，也不将整体差异解释成孤立循环控制成本。

四份本轮record与AB campaign保存完整48数组、中位数、spread、两端及辅助比较、理由和角色；final_selection保持null，自动确认/包/晋级全部false。初筛资格只是交root决定下一步的标记，不能改变当前最佳C6或重试Y/S失败确认。官方分数保持未知，耗时总中位数是内部指标。

没有发现必须修改最终工具的静态问题；未做导入/语法执行或本机测试，实际返回后的记录与验收仍须按原证据处理。完整差异文件最终SHA为 `debfa8912d46754415f03e5c895b5c6166d0596e574c14ca8e6dd72260954a5b`。审查结束用量实读低于40%停止线，未使用重置卡。报告完成后STOP，AB是否执行只由root独立GO决定。
