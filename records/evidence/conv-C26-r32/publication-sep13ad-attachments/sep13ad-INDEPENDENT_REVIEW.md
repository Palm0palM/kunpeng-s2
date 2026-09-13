# AD 独立静态审查

结论：最终三工具及完整AB→AD差异未发现静态阻碍。Root已转达N的FINAL/STOP；本报告对应下列实际最终文件。只读三工具全文、579行完整diff、README/STATIC、AC最终shared接口及原R/experiment比较定义，没有导入或执行AD/AC工具、SSH、new/checkpoint、记录、算子、accept/freezer或新job；只新增本报告。

| 工具 | 行/字节 | SHA256 |
|---|---:|---|
| sep13ad-submit-performance.py | 434 / 30107 | `96951189e1a4ef8bcac6799e52f545f1e8d4aaeb0664ba290374e55ce268a3f2` |
| sep13ad-record-group.py | 160 / 9054 | `de9386b5c64f10569f64da47c0517baaa505dbaa01541b9fc21af9cc424f29b8` |
| sep13ad-compare.py | 98 / 6414 | `0e5c6f9c058fd5e4de877c57802bd074e867d3fa4a5c2e9eafe6289d1a06aac4` |

README SHA `9b28fb6f7b821604ce3b691bb244c4efd585df0960663a0053a63951be561621`；from-ab.patch SHA `58b0bdb3da8774217d3c92c2ec4f4ef6b5c21635675dd8e0a450b6133d704b8a`；STATIC_REVIEW SHA `038f6ee1e960eb809ad9e0fa7b91a8e5524efc9797a3b67c70d1c033ee157a6d`。

固定顺序C26-r32 / C55-row7x3shared3 / C52-r3参考 / C26-r33。两控制必须是当前C6/C26-row4loads原字节；C55源固定cc6b5160…8138，source_parent仍原C52，diagnostic_source_version独立为C55。参考固定原C52的8cf5dc08…12bf7，复用原W的T1582134/37128 gate，只证明相同字节参考；reference_only=true、promotion_allowed=false、qualified_for_confirmation=false及原Y失败身份在创建、record和compare均保留。README/benchmark/run.sh、设置、资源和38线程条件保持；不将C52参考当新晋级候选。

历史入口改为完整原AB1582814的48样本。previous_gate复用AB检查，逐成员核对真实record/source/manifest/machine/settings/scheduler/job/system/wrapper、3套×4case、campaign数组和顺序；C54的前/后C6及C52-r2辅助比较按原规则核对，C54两端false、confirmation_pending空、所有成员qualified=false和参考限制不改写。ab.old_decisions继续保留Y/S false及更早受约束历史。AB数组只用于历史核对，不进入AD计时输入，也没有重跑C54或失败Y确认的路径。

C55性能入口必须有自身AC1582860完整passed/complete及freeze-source。gate绑定原AC job、冻结job/validation/prepared/五文件manifest、实际scheduler文本、19阶段全0、wrapper0、GCC10.3.1严格原三argv、38CPU单NUMA、六配置full5744/dispatch1212/direct432=44328、入口1236/1080和mask1/15。原T/AA数值或只存在AC raw不能替代完整验收冻结。

AC shared schema对接正确：ac-shared3-paths-v1、7×3VL/21acc、13语义阶段；shared_triple_and_remainder_reviewed、triple_to_remainder_review，main work3，u1 loop work1、直线work1..2，余数路径覆盖0..2。每block多实际ranges按整块derived_counts核对21×work及逐列归一化，不能重复对每个子区间套整块算术；所有范围非重叠且在helper内，真实region数量从ranges派生，没有固定14或机器指令总数。路径sequence按executions×work核对、直线不能虚报重复、全部余数块须映射。其余12阶段u1、全helper/clone及dispatch、ABI/栈/转换/reset/FMA审查字段和父T实际.s比较保持。quad_boundary保留为原checker家族，不误作四列执行证据。不要求零spill、不从静态数量预言速度。该gate消费已人工审查的实际冻结结果，不替代完整机器码人工审查。

串行范围只含固定AC1582860/AB1582814/AA1582656/Y1582410/X1582372/T1582134和明确P/AD预约。固定来源缺失、ID变更、查询失败、非terminal或缺整数退出码均阻塞；P无文件忽略，现存P未有固定ID对账也保守阻塞。任何AD campaign/四成员cluster预约均禁止再次提交，不扫描队友。单次查询最多45秒，仍依赖root唯一提交协调。

submit显式--go后才进门禁，在共享锁下复核历史/C6/source/ID未占用，先保存排他campaign，再new两控制和参考、checkpoint四成员，之后调用成熟group提交；不确定时保留预约、没有删除重投路径。creation metadata的source_hashes快照不重写，record只在内存视图适配当前源，并核对prepared/current/submitted三者相同。record只恢复原保存job，全退出和完整检查通过才写记录；已录且匹配则保留，既有失败不得覆盖。

compare要求本组全48原样本、真实同组同机器/设置/源身份和全部退出。仍调用原R包装的experiment.comparison：总收益严格大于max(1%,双方全部case spread)，每case退步不得超过1%，第一case没有例外。C55前后两端eligible相与才标初筛qualified；参考始终false。辅助C55/C52-r3比较单独保存，不能替代C6门槛或归因于单条指令成本。所有数组、中位数、spread、理由均保存；只写AD四record和campaign，自动确认/晋级/ZIP/发布均无路径。

静态审查完成STOP。是否启动由root在实际AC完整冻结后决定；本报告不是AD数值或性能结果。未改他人文件/源码/记录/最佳包，主额度低于40%停止线，未使用重置卡。
