# S 独立静态复核

2026-09-13。完整阅读 S submit、record、compare、README 四文件，及它们实际复用的 R 记录/来源/比较定义、标准 experiment.comparison 与 new/checkpoint 语义。作者确认四文件 final-ready 且停写。结论：当前真实 R/Q schema 与 S 接口之间未发现实际阻断问题，无需修改 S 代码。

仅做本地文本读取、搜索、四文件指纹和本报告编辑；未导入或执行 S/R 工具，未 SSH、预约、提交、查询远程状态、编译或测试。审查过程中 root 已亲自唯一提交 S，本文不会将静态审查当作 S 运行通过。

| 被审文件 | SHA256 |
|---|---|
| sep13s-submit-performance.py | 5d81d135714df6c33e4ad0df9a422100dc22f9aad1a95ea8469f57830c4f036e |
| sep13s-record-group.py | 1982306f23144aa241e978dde2adbbdfd3d0cca72f4dd12a9545be58d332d930 |
| sep13s-compare.py | 4a286374d8f1b6fd2f592f68c3bade38ce46663b946ea025f66076f17134bcc1 |
| sep13s-README.md | cc657ff20ebc393c873da83dccb37b2bb7e065ea539c97215ed097d4b4e32e6d |

R48→S36：previous_gate 固定 R 原 job1581911、四成员 C26-r22/C51-row7x3u1/C40-r4/C26-r23，要求四份 passed/verified、4个固定尺寸各3样本、共48样本、原 group/index/order/source/settings/machine、真实终态及 wrapper0。实际四份 cluster 都属于 `kp-conv-group-6d54aff1252c`、SUCCEEDED/job+system0，四 wrapper 均0。真实 R campaign 为 performance_complete，仅 C51 在 confirmation_pending。S 同时检查保存的两端 verdict 和用原完整 R 数组重新计算的标准规则，不只信任 qualified 标记。实际 C51 438.95000000000005 ms 对结束控制452.28 ms 收益2.947289%，阈值1%；对开头452.32 ms 收益2.955872%，阈值1.339358%。A case 对两端分别退步0.894942%/0.914575%，都在原1%上限内。辅助 C40 比较不是 S 资格条件。

S 固定 C26-r24/C51-r1/C26-r25，3成员×4case×3样本=36。record 可恢复指定未重复的成员，但 compare 必须取得全部三份完整记录并核对精确36样本，不能通过只登记较好成员绕过总组门槛。S setting 必须与 R 相同，实际机器、编译器、线程/CPU与两个新控制由 S 本身记录证明。R 数值只用于初筛前置，不进入 S 的 times_ms 或 median；compare 直接使用 S 三记录，没有拼接、筛选或复用 R 样本的代码路径。

源码和 Q 映射：`SOURCE_PARENTS['C51-r1']='C51-row7x3u1'` 表示原字节来源；独立 `DIAGNOSTIC_SOURCE_VERSIONS` 同值表示原候选自己的 Q 身份。S 的 diagnostic_gate 先要求完整四文件源清单等于 R 的 C51 记录，再调用 R 已审的 C51/Q 门槛，保留 fixed source `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`、真实 Q1581822/37128、13阶段/7×3VL/21acc、全退出/编译/汇编/冻结证据。S 创建 C51-r1 后把比较 parent 指向结束控制 C26-r25，source_parent 仍为 C51；source与diagnostic来源不会误指向 C40。R 原候选的 `reused_identical_source_diagnostic=false` 与 S 同源复测的 true 分别使用各自验证器，未混用旧断言。实际已生成的 C51-r1 prepared record 正是 source_parent/diagnostic_source_version=C51、diagnostic_job_id1581822、initial_performance_job1581911。

两端同门槛：S compare 复用 R comparison，后者以标准 experiment.comparison 为唯一资格判定。总case中位数收益必须严格大于 max(1%, 双方全部case spread)，每一组 gain 不得小于−1%；包含 A，无排除或权重修改。完整4个 DIMS 和各3样本已由 verify_record 要求，避免标准 zip 比较忽略缺失尾组。只有两个 S C6 verdict 都 eligible 才写 confirmation_passed=true；全部样本、spread、门槛、逐case结果和拒绝原因保留。无 R/S 混样、自动确认、晋级、ZIP，失败同样保留为最终结果，failed_confirmation_retry_allowed=false。

唯一作业与原件：submit 要求显式 root --go，已有 S campaign、任一成员目录或记录立即拒绝。完整前置后在公共 lock 内重读原资格/源，先保存 campaign 预留，再标准 new/checkpoint，最后只有一次 group submit；未知提交不清预留，不自动重新运行。串行检测沿用已知原 R/前轮清单并增加实际存在 T job及S自身路径，无T文件不阻塞、已有无ID预留必须阻塞。record 只恢复保存 job/group，真实 SUCCEEDED/job+system0 后才抓取并标准登记；已 passed 的记录验证后跳过，failed 不自动重写。compare 再核对同作业/组/源/机器、三个 wrapper0，只有 S 三record与campaign被写。旧 Gfalse/Jtrue/Kfalse、N/R 的 C40 reference_only/promotion禁止和不合格标记保持。

本次只读已看到 S campaign `performance_running`、submitted/submit_attempted=true、原 job1582067、group `kp-conv-group-04e926400780`；三 cluster 均同一 job/group，index0/1/2。它们说明唯一提交身份已保存，不证明 S 完成或36项PASS；原作业后续终态、日志登记和确认结论仍由执行责任人处理，不重提。

没有需作者修复的条目。T 继续仅准备且无 GO；其有界 serial_gate 已包含现在实际存在的 S campaign/三member manifests，S 非终态或未对账时不能放行。T 后续仍需 C52 自己的37,128项数值和真实 paired2/odd1 汇编、完整转换/栈/dispatch，不从 S/C51继承 PASS。只读复核完成，STOP。
