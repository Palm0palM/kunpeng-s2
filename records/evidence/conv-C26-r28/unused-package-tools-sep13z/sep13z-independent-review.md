# Z 原 ZIP 与 C7 最终器：独立静态审查

结论：完整读取两工具和两份 README 后，未发现本有界范围内需要修订的实质静态问题。**实际 Y confirmation=false 已阻止 Z 与 apply，两个工具必须保留未执行。** 审查开始时读取的 Y 仍为performance_running；报告完成时root提供原Y1582410生命周期确认：record/compare各一次exit0，36/36 PASS，opening=true、closing=false。结束C6的A样本51.48/61.24/51.50ms产生18.951456% spread，超过总收益3.5089%。不能剔除慢样本、重试失败确认、通过包测试补救或创建C7；Sfalse和C51历史保持。

submit.preflight:160要求原Y的confirmation_passed严格为true，最终器复用同一条件，因此真实false应在任何new/ZIP/SSH/promote之前停止。本报告未为确认失败执行preflight或扩展检查，未改变四端门槛。

仅阅读实际文件、相关标准 promote 与原 ZIP transport 的调用边界，以及现有 Y/lineage schema；未导入或执行工具，未连接 SSH、编译、运行题目、提交作业、读写 ZIP 成员或修改数据。唯一新增文件为本报告。开始审查时实际读取账户主额度已用3%，低于用户40%停止线；没有调用重置卡。

本次最终文件身份：

| 文件 | 行数 | SHA256 |
| --- | ---: | --- |
| sep13z-submit-package.py | 296 | 38cb80f294db7b0294ec4239e8800df821c964841caa351024cab4b470a2da68 |
| sep13z-finalize.py | 180 | b638cdd1d8e69723dcabc6e64e57cbaab49e732201f6ac64a300829d741d8b2d |
| sep13z-README.md | 33 | 3d4e9bdf5ada00f4c258ae2b277bc0488637237ceea034d39382b9ee9cf6c875 |
| sep13z-finalizer-README.md | 24 | 3ffe8290b062f73049db62fe16407fea60f1a30965ee1e1734b10b7f54abd772 |

## W/Y 四端资格和自身 T

submit:154–199 固定原 W1582256和原 Y1582410；W顺序为C26-r26/C52-row7x3shared2/C51-r2/C26-r27，共48样本；Y为C26-r28/C52-r1/C26-r29，共36样本。逐记录核对真实 passed/verified、三套、四固定尺寸、完整数组/中位数、原日志解析、BEGIN/END、六checks、source/current/manifest/取回产物、实际同组机器、scheduler原文、job/system/wrapper全0和fetch完成。两轮各自保留机器和样本，不跨轮合并。

strict_gate:98–109 对各轮开头和结束 C6 分别重算标准 e.comparison，并核对存储数组、原因、总收益和门槛。收益必须严格大于max(1%,双方全部case spread)，每case（包括A）退化不超过1%。W必须保留原初筛资格；Y必须已有 confirmation_passed=true、确认队列空、qualified=false、无混样、禁止失败重试，且关联原W。缺失、运行中或false无法进入 new/ZIP，不能靠包装作业补救失败确认。

C52-r1 与原 C52 四文件一致，conv2d.c 固定 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`，另三提交文件与 C6 相同；来源parent和diagnostic source分开核对。调用已审 W 的自身 T gate，绑定T1582134、冻结37128、19stage、实际13语义阶段/14区域与shared两列/单列余项。该路径不拿Q或C51替代C52 PASS。现有Y record与Y compare写出的最终字段形状相符，未发现接口错配。

当前最佳要求C6/C26-r1，题目主源、outputs、记录、C26-row4loads及W/Y控制字节一致，settings保持。C51-r2只读要求reference_only=true、promotion_allowed=false、qualified=false、原Sfalse；old_decisions同样只读保持S/C51及早期历史。辅助C51比较不能替代任一C6门槛。

## 唯一提交与原 ZIP 边界

submit:202–238 实时串行集合限于固定W/T/S/X、原Y及三成员、现存P/Z。未知预约、固定ID变化、查询失败、非terminal、缺整数退出码阻止；W/T/S/Y额外要求SUCCEEDED/0。P缺失不阻塞，已知X1582372不能消失或换号。按ID去重，不扫描队友或取消作业。

submit:241–292 明确要求--go，拒绝已有C52-package run/record或Z campaign。在共同锁内重读上下文，才标准new(parent=C52-r1)/checkpoint；metadata固定package_validation_only、reference_only=true、promotion_allowed=false。只调用一次既有原ZIP transport的子进程，不导入其顶层提交逻辑；完整保存argv/stdout/stderr/exit，不明状态保留预约、不得重跑提交。标准transport排他保留cluster.json，保存本地conv.zip及manifest，上传相同字节；解压/源成员校验及三套原runner仅发生在分配的计算节点。成功提交只标validation_pending，不自行record、确认、晋级或发布。

finalize:26–100 要求未来包自己的独立job、passed/verified、三套12个PASS、原四尺寸各3值、max_error=0、全部checks、真实原scheduler/job/system/wrapper0、fetch完成、产物指纹及源manifest。包源与确认版/原C52一致；实际机器GCC10.3.1/generic/38线程、38唯一CPU和NUMA身份核对。它不要求包取得性能晋级资格，也不把包样本混入Y。

原conv.zip SHA必须匹配上传package manifest；wrapper必须有一次匹配的PACKAGE_SHA256_VERIFIED标记。ZIP在内存中读取，恰好四个普通文件成员、名字集合精确，每个成员与包source及确认版source逐字一致，run.sh有执行位。包提交外层exit0、保存argv、package-gates的W/Y四比较与T/来源/历史身份均核对。这些检查不重新压缩或执行包；原ZIP读取行为只存在于未来finalizer执行，本审查没有打开ZIP。

## C6 → C7 的写入范围

finalize默认只读，--apply前先完整preflight/verified_package，确认lineage当前C6/C26-r1且无C7，原C6源码与旧ZIP校验一致。当前实际lineage/records-best也仍为C6/C26-r1。锁内再次核对上下文、包record/manifest/全部ZIP字节和旧outputs/lineage不变，缺失、false、已有C7或当前最佳变化均在标准promote前阻止。

已核对标准 e.promote 实现与finalize:131–175：先promote无parent且同源的C26-r29刷新C6测量基线，再promote其子C52-r1。第二次仍由标准比较验证确认版对当前C26-r29的资格并复制测得源；没有promote C52-package。标准函数读取完整best字典，仅替换conv键，finalizer也保存并核对其它题键不变。允许写入的测量记录为C26-r29/C52-r1的标准promoted_at，以及C52-r1决策说明；未写W/S/C51/C40历史。

最终器直接copy2已验证原conv.zip到outputs/conv-best.zip，写其同一SHA并再次核对，没有重新压缩。C7主耗时来自Y确认版，W初筛、T诊断和独立包12项只作为各自证据保存；lineage只追加C7及更新三个current字段，原C0..C6条目保留。末尾检查package完整record仍相同，保持reference-only。没有Git、public clone、官方提交、自动重试或reset调用。

标准promote与outputs/lineage更新不是一个跨文件事务；已有说明要求异常后保留实际状态交root，不自动重试apply。本报告没有把它描述成原子晋级。正常路径的两次标准promote前置关系与C52-r1实际parent=C26-r29相符，未发现确定的中途门槛错配。

无待作者修复的静态问题。实际Y确认失败已关闭本轮Z/最终器路径，原ZIP验证不应安排；不造C7、不重试失败确认、不运行preflight。保留准备工具、全部Y样本和其它原件，审查职责完成。STOP。
