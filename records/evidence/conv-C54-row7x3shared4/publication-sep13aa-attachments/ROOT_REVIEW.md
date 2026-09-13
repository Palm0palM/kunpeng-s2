# AA 根审查

本文件目前记录提交子集静态审查；不是数值或汇编接受，也尚不是 compute GO。

Root 完整阅读 T driver/accept、两 C 检查器和 remote_job，随后阅读 AA driver 完整差异、两检查器完整差异及 wrapper/env 完整差异。生产 C54 源已单独完成作者和独立审查。

新增 full 6×2×5×4×4=960 位于原四家族后；独立计数 quad_boundary 与总数同时断言。dispatch 新 240 项仍逐例调用 checked_entry_case，位于入口、worker 和旧 helper 快照前；新增家族另计数并断言。1236=756+480；direct 在更新后快照基础上扣除，1080 不变。新增使用原独立 scalar/只读/guard/canary/poison 比较，参考代码和配置检查未改。full5744+dispatch1212+direct432 的六配置总数是44328。

wrapper 只改候选身份和预期计数；实际三条 gcc argv、严格浮点、独立 TU 和诊断插桩边界、十九阶段、资源检查和退出留痕保持。无本机算子执行。

driver 固定自身 C54 检查点和首次传输清单，核对当前候选副本。只检查固定 Y/W/S/T/X 及 P/AA 已存在预约；缺失/未对账 ID、非终态或查询失败均阻止。上传前独占建立 job.json，上传/提交不明保留原件，status/fetch 复用已有 ID。返回只取有界单层普通文本/源/汇编，预检所有同名字节后写入，拒绝覆盖不同原件。配置和凭据不入传输清单。

待作者确认提交子集停写、root 核对首次 prepared/源清单/接口，以及独立审查确认后，root 才会记录唯一提交决定。accept/freezer 的实际共享四列 schema 仍待完整定稿审查；任何真实诊断通过均须自己的日志、实际汇编、退出与冻结证据，不继承 T。当前 C6 不变。

作者现已确认提交子集 final/STOP。Root 已完整阅读 SUBMISSION_INTERFACE 和首次 prepared，核对五文件传输清单/大小与候选原字节、作者最终 driver/prepared 身份；当前无 job.json。接口中的 config/cluster.local.json 是通用示例，本任务实际执行使用已验证的 config/conv-sep12.local.json；资源相同、连接严格身份校验不变。源与检查器不再改写。独立提交审查确认后，root 按此最终子集唯一提交，accept/freezer 必须另审后才能执行。

后续：root 已唯一提交 job1582656，submit/status/fetch 各一次 exit0，原件保存候选目录。调度器 SUCCEEDED、job/system/wrapper 全0，十九阶段全0，全部六配置 full5744/dispatch1212/direct432 及家族/入口/mask 实际相符，共44328数值检查通过。没有再次提交。

accept/freezer/完整 INTERFACE 已作者 final/STOP；root 已读成熟 T 全文及 AA 全部差异，包含多 blocks/ranges、余数0..3路径和独立家族核对，未见静态阻碍。Q 的最终 INDEPENDENT_TOOLS_REVIEW 已完整阅读且无阻碍。此时仍不能执行 accept/freeze：必须先完成实际 helper 审查并与 root 已完整阅读的四个实际 dispatch 函数报告合并。实际机器码已出现 scalable spill，如实记录，不把 spill 视为数值失败，也不据数据修改接受门槛。
