# AI 静态准备说明

只生成本目录前缀 `sep13ai-*` 的工具与说明；没有 import/执行这些工具，没有 AST、py_compile、本机题目/测试、SSH、new/checkpoint、预约或提交。C58 source、prepared record 和 creation 文件没有修改。

逐段静态阅读 AF 三工具后保留其 campaign 排他预约、shared workflow lock、原 creation 快照、group 一次提交、实际 group/job/机器检查、标准 record/current source 内存适配与双端比较流程。查询函数、机器检查及 comparison 展示公式直接复制先前已审 R 的小函数，不 import 旧 R/AF/AD 模块。删除父参考/辅助比较和庞大历史诊断审核，将 4 成员/48 改成 3 成员/36；完整差异见 `sep13ai-from-af.patch`。

新增简短 AH 自身冻结门槛，与已真实落盘的 `validation.json`/`freeze-source.json` 字段逐项对照：candidate/job、passed/complete、44328=34464+7272+2592、六配置、19 stage 全0、生产源 hash、实际 scheduler0、fused_instructions0 和目标审查文件。该门槛不重新读汇编或预填 PC/静态区域/动态次数，不保证无 spill 或提速。已确认 root 的 AH 首次 accept/freeze 81701c/0。

静态计数：3 成员 × 3 套 × 4 原例=36；每例保存 3 个样本，候选同时比较两个原 C6 控制。`experiment.comparison` 源码的 `total_gain <= noise` 判拒、逐例 `< -1` 判拒原样复用；comparison wrapper 仅展示相同阈值。false 只写本 AI 记录的结论字段，不修改原失败或触发下一作业。

固定只查 AH1583350、AF1583230、AG1583276 和 P/AI reservation；未知/非终态停止。实际 AG FAILED/job1/system10001 是允许资源释放的真实终态，AF 初筛 false 与 AG12FAIL 登记原件必须保持。三新成员不可能借用这三个 ID。实际执行前由 root 独立审查并唯一 GO；本报告只陈述准备状态，无测试 PASS 声明。
