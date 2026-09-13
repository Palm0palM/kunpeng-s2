# AB 作者静态差异说明

本轮仅编辑 sep13ab-submit-performance.py、sep13ab-record-group.py、sep13ab-compare.py、sep13ab-README.md 和本说明/完整差异；未导入或执行任一性能/诊断工具，未 SSH、new/checkpoint、创建 AB campaign/job 或修改候选/record/best。文本编辑和只读 JSON/源码检查不运行算子。

`sep13ab-from-w.patch` 是四个交付文件相对于对应成熟 W 文件的完整 unified diff，包括 README，未省略共同段之间的改动；W 原文件保持。

|部分|相对 W 的必要变化|保持的规则|
|---|---|---|
|身份|C26-r30/C54-row7x3shared4/C52-r2/C26-r31；C54 父源 C52，参考 C52 原字节|四成员顺序、每成员3套、共48样本、原 C6 与生产环境|
|历史入口|复用已审 Y record 定义，核对原 Y1582410/36样本/false；其通用依赖继续保留 W/S/R 与参考历史|原数组、来源、退出、机器及 comparison 不改；无跨组拼接|
|参考角色|C52-r2 关联自身原 C52/T1582134，记录 prior Y1582410 false|reference_only=true、promotion_allowed=false、qualified_for_confirmation=false；不得进入确认队列|
|诊断|C54 自身 AA44328，独立 source/freeze/manifest/raw；C52-r2 直接调用原 W 的 T37128 gate|源码、真实编译 argv、19stage、6配置、调度/系统/wrapper退出、完整汇编身份与审查|
|AA 汇编|aa-shared4-paths-v1，多实际范围、四列 main、u1余数0..3有序路径、动态区域计数|全 helper/clone、13语义阶段、全部转场、ABI、分派、spill解释、真实FMA0；不宣称零spill|
|预约与串行|仅固定 Y1582410/X1582372/T1582134/AA1582656 与明确 P/AB reservation|先全部门禁，公共锁内唯一预约；未知/非终态阻塞，断线保留原 ID，绝不重投|
|record|只更新 AB 名称、来源/诊断/历史映射；继续 W 的实现|actual prepared/current/submitted 身份一致，creation hash仅内存适配；已录跳过、失败不覆盖|
|compare|改候选/参考身份与归因文字|复用同一 R comparison 包装；全部48样本、两端严格原阈值、独立辅助比较，无自动确认/ZIP/晋级|

AA 最终准备接口的对接依据为 `sep13aa-checks/accept_returned.py` 和 `sep13aa-checks/C54-row7x3shared4/prepared.json` 的实际文本，未运行它们。每配置 full5744、dispatch1212、direct432；总34464/7272/2592=44328；entries1236/1080，mask1/15。保留矩阵家族及 kw4..8 的 quad_boundary 计划身份，防止沿用父 T 37128 或只在旧 kw1..3 路径通过。

AA `assembly.schema` 为 aa-shared4-paths-v1，`shared_unroll` 为 main_columns4/remainder_source_columns1/remainder_max_columns3/other_stage_columns1，要求 shared_quad_and_remainder_reviewed=true。每个 shared block 的 derived_counts 为其所有实际 ranges 汇总，按实际工作列数归一化；不能把 aggregate 误当每个区间各有一次完整算术。u1路径允许单列 loop 重复1..3次或直线1..3列，但每条路径的工作量必须等于指定余数，所有 remainder block 均需被实际路径解释。阶段及 helper 的 actual_arithmetic_region_count 和顶层 arithmetic_region_counts 必须等于实际不重叠区间数量，没有固定14区域断言。

AA 原 ID 在准备初期未伪填；root 唯一提交后，只读真实 job.json 确认1582656和 C54 源 SHA，再固定 AA_JOB_ID。此时仍不推断其最终数值或汇编通过。GO 时缺 validation/freeze、出现失败或未完成均阻止 AB；没有 AA PASS 继承或 fabricated status。

两端 C6 比较保留同一严格规则：总中位数收益 > max(1%, 所比较两版本所有 case spread)，且各 case 退化 ≤1%。参考 C52-r2 的结果和辅助 eligible 无法让参考版获得确认资格，也不能替代任何 C6 gate。新 C54 源假设不改 Y/S failed confirmation，不自动重试失败确认。

提交动作由 explicit --go main 入口控制。函数定义复用有 main guard；本次没有通过 import、exec、AST、py_compile 或 dry-run 执行/校验工具。静态审查范围为文本与既有接口，不声称运行验证通过；最终仍交 root 全文/diff 审查后由 root 唯一 GO。
