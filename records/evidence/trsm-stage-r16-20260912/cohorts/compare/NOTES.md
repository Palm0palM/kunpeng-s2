# r16：超预算小路径 8×16 前代比较

仅准备输入，尚未执行 prepare、submit 或登记。控制器保留 `PREPARE_REVIEW_PENDING=True`；root 完成独立审查后才能解除。r15 作业 1579788 是两个 repeat 的唯一预声明前序记录，T8-control12 仍为当前父基线，T18 未晋级。

| 成员 | run | version / 复制来源 | parent | 登记方式 |
| --- | --- | --- | --- | --- |
| A | T8-control12-repeat-r16 | T8-control12 | null | repeat-existing |
| B | T18-budgetwide-repeat-r16 | T18-budgetwide | T8-control12 | repeat-existing |
| C | T19-panel8x16budget | T19-panel8x16budget | T8-control12 | new |

只有 A/B 读取并保留 prior job1579788、source_*、created、strategy 和历史；prepare 使用原私有 helper 的 preserve/validate，冻结末尾再次核对记录与五文件源码。C 的已准备 source 目录可以存在，但不得已有 experiment.json、cluster.json、已登记证据或版本 record；prepare 排他建立其 prepared 元数据。没有修改或重写 T19 源码，原官方 runner/benchmark/compat 逐字节检查继续保留。

预声明协议：各一套完整预热 A/B/C，正式 ABC / BCA / CAB 三个独立完整套件，每次原 runner 的 TEST_RUNS=3。预期 27 formal PASS、9 warm PASS。全部正式样本保留；预热单独保存，不用于比较，不合并其他作业结果。

## 预热前与登记前的同一门禁

- A/B：原 `preflight/run.sh SOURCE OUTPUT` 和 `preflight_audit.audit_general(OUTPUT, SOURCE/trsm.c, RUN_NAME)`。完整 r14 预算覆盖保留，A whole=433、B whole=518，旧 schema 保持 trsm-r14-preflight-v1。T19 不交给旧审计器。
- C：`preflight-panel8x16/run.sh SOURCE OUTPUT` 和该目录内 `audit_panel8x16.audit_panel8x16(OUTPUT, SOURCE/trsm.c)`。最终契约为 micro=46（旧14、packed14、新18）、whole=615、noop=96、shared_fail=89、27 测试过程、37 步骤、633 参数案例。新增 1047×33 的 38 线程案例覆盖新八行核之后七行尾。
- B/C：各运行 `preflight-wide32/run.sh SOURCE OUTPUT 64`，原完整 CT64/KB256 契约每成员保持 micro=28、whole=28、argument cases=56、tile processes=7，使用原 audit_wide。

C 审计返回 completion、summary、budget_summary、parameters_summary、guard。对应三 JSON 为 summary.json、budget-summary.json、panel8x16-summary.json，schema 分别为 trsm-panel8x16-preflight-v1、trsm-packed-history-budget-panel8x16-v1、trsm-panel8x16-arguments-v1。controller driver 和 finish 均额外要求 `guard.scheduler_job_id` 精确等于本 cohort 已确认 job。实际 wrapper/新旧核入口、history/X/KB 分配、双面板参数、guards、失败注入/无 SVE/实际窄 VL 由专用审计器完整核对。

运行结果目录分别为 preflight-results/A或B、preflight-panel8x16-results/C、preflight-wide32-results/B或C，均放在目标 payload 根下。cohort_driver 在全部预检和审计完成后才开始预热；全部预热完成后才打开正式日志。

payload 必须包含 cohort-config、三成员五文件源码、cohort_driver.py、remote_job.sh、preflight_audit.py、reference 和三个完整预检输入目录。专用 audit_panel8x16.py 与其目录一起冻结上传。收集保留所有文本/JSON/汇编和 instrumented-trsm.c；正式计时和目标汇编仍用原源码，预检插桩副本仅作观测。

## 收集、登记与比较

submit 先建立排他 submit-attempt.txt，持久化 uploading/submit_unknown/submitted 状态；未知提交不得重试，已知 job 只可单独重试 confirm-job。collect 必须有成功调度终态和与所存 job 一致的状态，原计算节点 guard、38 CPU 单 NUMA、24576 MiB/1800 秒、GCC12.3.1/KML25.1 和真实依赖检查不变。

finish 先排他写 finish-attempt.json，失败后不得直接重跑。它在任何 record 前审核三成员正式原始日志、预热原始日志、冻结配置/源码和全部预检，严格要求 27/9。仅索引 0/1 验证 prior 并加 --repeat-existing；C 只接受本轮尚未登记的 prepared record。三成员审核完后按 A/B/C 登记；保存部分失败现场，不重放已完成登记。

晋级比较仅 T8→T18 和 T8→T19。另有 T18→T19 机理比较，明确 `promotion_authorization=false`。result.json 与 finish-complete.json 不自动 promote；T19 的计划父版本始终是 T8，不能以机理比较或候选来源替代晋级判断。

这轮实际环境不是指定 KML25.2 复验。所有编译、预检、汇编生成和 benchmark 只在调度计算节点。本机仅文本准备、AST/Bash 语法检查及元数据/字节核对，无哈希、SSH、prepare/submit、record、题目编译测试或比赛提交。
