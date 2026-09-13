# Y 独立只读审查

结论：当前最终四文件未发现本次范围内的静态阻碍，可以交root决定后续唯一GO；此报告不授予提交权限，不表示Y已运行或通过。作者已final-ready并STOP，root确认工具未再变化。审查只读取文本及关键复用定义，未导入/执行任何工具、SSH、编译、测试、创建作业或改原文件。

| 最终文件 | 行数 | SHA256 |
| --- | ---: | --- |
| sep13y-submit-performance.py | 228 | `20f754a5b1c60d02426022d079090013c34eef1723c2150f6152806b0802b307` |
| sep13y-record-group.py | 157 | `a3879b88987627c0650a2d113f28d3f63ea113c8d12465d0f988bd00bab70b97` |
| sep13y-compare.py | 86 | `e9ec8863a71eebea7fa3a79e4b69dd71cdf31726b107d48ffeaf0308c650c1d1` |
| sep13y-README.md | 39 | `8d559175e862d101b139b76a6bcee2ab4bdc32c3be764413a21043a1c0dda6cb` |

固定顺序C26-r28 / C52-r1 / C26-r29，三成员各3套、共36样本。submit在任何new/campaign/SSH前要求显式--go及三个新ID/campaign未占用；共享锁内复核来源和旧记录，先保留唯一campaign预约，再创建/检查三成员，仅调用一次group submit。任何已有预留或提交不明都阻止重复提交。定义复用模块均通过main guard分开执行入口，本次审查没有运行这些import。

W资格来自固定1582256的完整四成员48条已验证记录与campaign数组、同组machine、原源码/设置、成员index/order、source manifest和scheduler/job/system/wrapper。C52必须qualified_for_confirmation=true，前后C6标准experiment.comparison重算均eligible=true，且原候选没有failed confirmation。Y只把这些作为初筛资格，新的36样本来自新组，不把W数组带入Y comparison。该门禁复核既有verified记录/数组及生命周期，未声称每次门禁重新执行benchmark或重新解析全部历史日志。

C52-r1仅复制原C52全部源码，conv2d.c固定8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7；source_parent与diagnostic_source_version分别存储。已追读复用W diagnostic_gate：只接受自身T1582134原冻结passed/complete37128，19阶段/退出、六配置/入口/mask、源与实际生产汇编身份、13语义/14区域、paired2/odd1及完整review/freeze关联，不借Q证明C52。benchmark/runner/README与两C6保持一致，GCC10.3.1、generic、38线程/CPU、24576MiB、单NUMA及完整settings均严格保持。

record的creation metadata保持原文件字节；prepared record、当前源与实际上传manifest先一致，才用dict(metadata, source_hashes=source)作内存关联检查。通用experiment.record从当前源和真实日志生成结果，保存原日志及哈希，核对完整PASS数量、实际环境/上传和返回源清单、wrapper与fetched artifacts。已经passed的记录核对后跳过，失败记录不覆盖；不把旧creation source_hashes误当最终提交源。Y compare还要求三成员全部passed/verified、同一group/machine与退出0，精确36样本。

已追读W→R comparison包装及experiment.comparison：每个对照分别要求总中位数改善严格大于max(1%,双方全部case spread)，任何case（包括A）改善不得小于−1%；相等阈值不通过。两端AND才confirmation_passed=true，完整保存两端原因、各case三样本/median/spread，任何false均保留失败结论。compare只写三Y记录和Y campaign；三个qualified_for_confirmation=false，confirmation_pending为空，automatic_confirmation/promotion/packaging及failed_confirmation_retry_allowed均false。没有ZIP/promote/retry调用路径；promotion_allowed=true仍是候选身份字段，不是这四工具自动发布授权，后续root发布流程必须另行检查实际confirmation与两端结论。

serial只包含固定W1582256/T1582134/S1582067、存在的P/X诊断job.json、Y campaign和本组三成员cluster.json。固定文件缺失/ID变化、未知预约、查询失败、非terminal或缺少整数job/system退出码都阻止，ID去重后有界查询；没有队友扫描或取消。X只准备时无job不阻塞，一旦存在实际X job则必须等它终态。root仍是唯一提交协调者，不把此门禁描述为跨协调者调度锁。

old_decisions及W复用检查只读保留S1582067 confirmation=false、C51-r2 reference_only=true/promotion_allowed=false/qualified=false与旧C40结论；C51不进入Y，Y不是S的重试。未来实际调度ID、36条原样本和执行退出仍必须由root按生命周期取回验收，本次静态审查未填入预测结果、官方分数、通过或速度。只新增本报告，未改四工具、source、record、公开副本或提交包；未使用重置卡。STOP。
