# r13：共享 L 历史生产调度的单改动比较

2026-09-12，仅完成本地轻量准备。没有执行 job_control 的 prepare/submit，没有创建 payload、cohort-submission、实验台账或 T8/T10 新 run，也没有任何 r13 计算结果。当前 T8 仍为晋级基线；T10 和 T14 均不因准备而获得晋级。

## 成员与来源

|顺序|运行目录|实现版本|登记方式|性能 parent|
|---|---|---|---|---|
|A|T8-control12-repeat-r13|T8-control12|原晋级基线同版本复测|无 parent，仍须当前 best|
|B|T10-lhistbarrier-repeat-r13|T10-lhistbarrier|r7 未晋级候选同版本复测|T8-control12|
|C|T14-lhistcyclic|T14-lhistcyclic|新候选记录|T8-control12|

plan.json 中 A/B 的 version、parent、strategy 和 source_implementation_id 从各自现存台账逐字段保留。准备时 A 最近 run 为 r12、作业 1579645；B 为 r7、作业 1579401。prepare 再检查当前台账与计划身份一致、已通过真实 KML25.1/GCC12 测量，A 仍为 best 且已 promoted，B 仍未晋级，源文件与先前已测快照一致。后续 record --repeat-existing 分别保留各自 prior-record.json 和历史链，不能覆盖旧 run 目录。

T14 源码已经存在，来自 T10；只读文本比较确认唯一差异是 solve_panel 的 shared packed_history 生产循环第 588 行由 schedule(static) 改为 schedule(static,1)。消费者调度、空 asm、布局、算术、barrier、分配失败和大路径均不变。这是相对 T10 的单 pragma 实验；相对 T8 仍包含未晋级的共享 L 打包策略，来源不能省略。

## 固定测量协议与门禁

每成员先执行一套原官方 runner 作为独立预热，随后正式顺序固定为 ABC、BCA、CAB。每成员三套完整用例，每套 TEST_RUNS=3；正式预期 27 PASS，预热预期 9 PASS。全部样本保留，预热日志、依赖映射和 summary 单独保存，不纳入正式中位数或进行慢样本剔除。

job_control/cohort_driver 从 r12 控制器适配为三成员，保留已验证 repeat/new 身份检查、唯一远端目录、持久化 uploading/submit_unknown/submitted 状态和已知 job marker 恢复方式。SSH 配置直接复制当前 r12 私有配置；没有读出或复制密码/凭据到公共文件。远端 remote_job 与 reference 保留原 Linux aarch64、确认作业 marker、38 CPU 单 NUMA、GCC12.3.1、KML25.1 真实头文件与默认 -lkblas、私有 libgomp、原线程绑定和原 runner 门禁。资源保持 24 GiB、1800 秒，不与其他题目共享或取消作业。

prepare/submit 不可反复调用；不确定提交先查既有状态与 job ID，只有已知作业的 marker 传输可用 confirm-job 重试。status/collect 只针对已保存作业，collect 未确认调度成功时不会登记成绩。此目录尚未执行这些动作。

## 按源码特征的通用预检

preflight 四个输入文件从 r7 packed-L-aware 通用预检原样复制；reference 与 remote_job 从 r12 原样复制。没有加入 wide32 模块，因为三者都保持 T8 大路径。

|成员|原微核|packed-L 微核|整算子|no-op|共享历史分配失败|
|---|---:|---:|---:|---:|---:|
|A T8|14|0|406|28|0|
|B T10|14|14|486|36|80|
|C T14|14|14|486|36|80|

这些是既有预检的预计覆盖，不是 r13 测试结果。runner 按实际源码是否含原 panel16 和 packed-L 函数选择构建/测试；driver 在预热前核对该源特征及实际 completion，finish_records 再按冻结 payload 源特征核对取回的完整标记。不能把三个成员套成统一数量。

原预检保留普通/边界、1/4/38 线程、无 SVE、实际窄 VL、全部分配失败，以及 B/C 专属的 80 组“共享历史分配失败、后续 X 分配成功”检查。每成员生成原候选 trsm-panel16.s，原 -S 构建不附测试插桩 flags；可继续审查历史核 spill 与 packed-history 生产代码。目标汇编、commands.txt、summary.tsv、completion.txt、guard 和所有原日志按既有 diagnostics.tar.gz 路径取回，没有先生成或复制旧结果。

## 登记与比较

finish_records 仅在 collect 完成后安全展开新诊断目录，核对 cohort 退出零、三成员预检标记、正式 27 PASS 和预热 9 PASS。然后通过现有 TRSM no-hash helper 依次登记 A/B（--repeat-existing）和 C，新实际环境 ID 包含节点、NUMA、job ID；后续 helper 对有序原用例、精度、调度器、线程和实际 KML/libgomp 依赖作完整审计。

保存 T8→T10、T8→T14 两份父基线比较，以及单独的 T10→T14 机理比较。result.json 中机理比较标注 promotion_authorization=false；即使该对照改善，也不能据此晋级 T14。只有同轮 T8 比较符合原波动及逐用例退化门槛，才由协调者另行决定是否晋级。finish_records 本身不执行 promote，不改最佳源码或提交包。

所有实际编译、正确性、sanitizer、汇编生成和 benchmark 只能在调度计算节点。本目录仅允许准备阶段的 Python AST、Bash 语法及轻量文本检查；不计算/验证哈希，不使用重置卡，不关机，不正式提交比赛。KML25.1/GCC12 的结果不得称为指定 KML25.2.0 复验。
