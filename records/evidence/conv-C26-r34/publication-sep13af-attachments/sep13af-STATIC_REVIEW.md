# AF 作者静态差异说明

模板为最终且已实际完成 AD1582956 的三工具。此次只写 sep13af-*，按文本核对 AE 最终 INTERFACE 与三工具契约，没有导入、执行、AST/py_compile/dry-run、SSH、版本/作业/记录变更；静态阅读不等于运行验证。

|部分|AD→AF 必要变化|保持内容|
|---|---|---|
|身份|C26-r34/C56-row7shared3fence/C55-r1/C26-r35，C56源6c48…224c、参考原C55 cc6b…8138|四版三套48原样本、原C6、资源与runner|
|前史|仅最新 AD1582956/48 全量核对，C55两端false和C52-r3参考限制保持|已审 record/machine/manifest/comparison 定义；旧 decision 只读，不扩展递归旧数组审查|
|诊断|候选自身 AE1583102/44328；参考调用原 AD 的 C55/AC1582860 gate|数值/19stage/六配置/资源/argv/源清单/freeze/全部helper与dispatch审查|
|fence schema|ae-shared3-fence-paths-v1，完整 column_fence_review，父代码比较改原C55/AC|13semantic、main3/u1余0..2、多ranges/path accounting；实际效果 bool 可false，不添零spill条件|
|参考限制|C55-r1 永久 reference_only/promotionfalse/qualifiedfalse，prior_initial 明确原AD初筛失败|Y/Sfalse保持，不虚构 C55 失败确认，不自动重试|
|串行|增加原AE/AD，保留AC/AB/AA/Y/X/T和明确P/AF预约|未知/非终态阻塞、不扫描、排他预留、失联只恢复原ID|
|创建关联|首次关联前保存原字节 creation-experiment.json，并记录SHA；已有C56快照不覆盖|标准 new/checkpoint，原创建hash不刷新，prepared/current/submitted一致，e.record 内存适配|
|比较|C56对两端C6及独立C55父参考|原R比较包装、每case≤1%退化、总收益严格越过全部spread、全部48、no auto|

准备时新 C26-r34、C55-r1、C26-r35 run/record 和 AF campaign 均不存在。C56 已有 creation-experiment.json，静态 cmp 确认与其当前 experiment.json 原字节相同（退出0）；仅核对，未改候选快照、源码或记录。source_parent 缺省标准 parent 的兼容仅用于首次候选身份读取。未来关联 experiment.json 仍保留创建 source_hashes；独立快照验证和标准 checkpoint 不引入新记录迁移机制。

静态差异复核修正了一处参考来源的旧占位映射：AF 的 C55-r1 必须对应 AD records[contract.SOURCE_VERSION] 即原 C55-row7x3shared3，不能引用不存在的 C55-r2。这是准备文本修正，未执行或触碰实测记录。参考历史字段由 prior_confirmation 改为实际 prior_initial，避免把 AD 初筛失败误写为确认失败。

AE 的 fence 字段与最终 INTERFACE 精确对接：三列×21只读输入、0输出、memory/empty true；三个边界证据及四段实际解释必需。schedule_tightened 和每边界的 readiness 是实际 bool，false 不阻止一个已完成真实审查且数值通过的候选进入性能初筛。没有硬编码190指令、5/5 spill或推断速度。root 完成原 AE1583102 首次 accept/freeze 后，本任务只读实际 validation：passed/complete44328、13语义阶段/14实际区域、三边界和 schedule 实际 true、parent=C55/AC1582860，字段与门禁吻合；未执行验收或工具，没有预填 PASS。

previous_gate 只复算最新 AD 四成员的原48数组及 C55 的前/后/父参考三个比较，复用成熟 AD 验证函数；未调用会递归核对旧 campaign 数组的 AD verify_plan。历史 decision 读取仍保留既有 Y/Sfalse 和参考资格限制；不修改历史样本。record/compare 无提交路径、无最佳/ZIP/发布动作。

sep13af-from-ad.patch 包含 submit、record-group、compare、README、STATIC_REVIEW 全量 unified diff；文件SHA及字节数列于 sep13af-PREPARED_FILES.json。完成后 FINAL/STOP，供 root 与独立全文审查，不试运行工具。
