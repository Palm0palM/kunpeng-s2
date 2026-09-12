# r15：T8 与 T18 同源码确认

此目录只保存静态准备输入。r14 作业 1579730 已收集登记，两成员均 verified；T18 尚未晋级，当前最佳仍为 T8-control12（实现 T8-svepanel16）。r14 的波动未支持晋级，本轮预先固定同源码确认协议，不修改任何候选源码。

| 成员 | run | version / source_from | parent | repeat |
| --- | --- | --- | --- | --- |
| A | T8-control12-repeat-r15 | T8-control12 | null | true |
| B | T18-budgetwide-repeat-r15 | T18-budgetwide | T8-control12 | true |

两成员的 prior job 必须保持 1579730。plan 中 source_from 指复制目录；登记身份中的 source_*、strategy、created_at、parent 和历史由现有私有 repeat helper 保留。例如 T8 原记录 source_from 仍为 T8-svepanel16，不会被复制目录名改写。prepare 复核已验证 prior、原四源码测量快照、五文件复制、既往 run 目录隔离与有效当前父基线，并在冻结末尾重新核对记录和源码字节。不会新建实现版本。

协议在新性能数据出现前固定：预热 A/B 各一套，正式 AB / BA / AB 三个独立完整套件；每次原 runner 的 TEST_RUNS=3。预期 18 条正式 PASS、6 条预热 PASS。预热与正式日志分开，所有正式样本保留，不删除慢样本，不合并其他作业成绩；同一分配、KML25.1/GCC12.3.1、38 CPU 单 NUMA、24576 MiB、1800 秒以及原 benchmark/runner/精度保持不变。不得称为 KML25.2 复验。

通用预算预检完整复制 r14 执行输入，schema 继续使用 trsm-r14-preflight-v1 / trsm-packed-history-budget-v1。audit helper 仅把合法成员映射缩小为本轮两个新 run 名，逻辑不变。

| 通用门禁 | A：T8 | B：T18 |
| --- | ---: | ---: |
| micro / old / packed | 14 / 14 / 0 | 28 / 14 / 14 |
| whole / allocation_checked | 433 / 433 | 518 / 518 |
| noop | 52 | 64 |
| shared_fail | 0 | 83 |
| budget cases / actual shared injections | 27 / 0 | 32 / 3 |
| process_count / whole processes | 14 / 13 | 18 / 16 |
| budget processes | 6 | 7 |

真实 history/X/KB 分配观察、预算边界、失败回退、无 SVE、实际窄 VL 与入口公式全部保留。`preflight_audit.py` 同时用于计算节点预热前和本地登记前，严格检查 completion、summary.json、budget-summary.json 及每一预算行。

调用接口：`bash preflight/run.sh SOURCE_DIR OUTPUT_DIR`。wide32 仅 B：`bash preflight-wide32/run.sh SOURCE_DIR OUTPUT_DIR 64`；完整 28 micro / 28 whole、56 参数案例、7 个 tile 观察进程和 CT64/KB256 门禁保持不变。wide32 与通用计数分开。

`job_control.py` 的 `PREPARE_REVIEW_PENDING=True` 是明确阻断，root 完成独立审查后才能解除。prepare/submit/collect 入口沿用，提交先排他建立 submit-attempt.txt；uploading 或 submit_unknown 不得重提，已知 job 仅可重试 confirm-job。collect 要求成功调度终态与准确 job ID。

`finish_records.py` 在任何解压/登记前排他建立 finish-attempt.json，失败后不能直接重跑。它先复核两个原记录身份、冻结配置/源码、正式原始日志、预热原始日志、完整预算 JSON 与 T18 wide32，再检查 18/6 计数。两个 record 命令都带 --repeat-existing；随后只 compare T8-control12→T18-budgetwide，写 result.json / finish-complete.json，均不自动 promote。部分登记失败时保留全部记录和日志，由 root 检查；不重放已经完成的登记。

仅复制干净输入：controller、driver、finish、plan、audit helper、remote/reference、两个预检目录及私有配置。没有复制 r14 payload、提交状态、诊断、日志或运行产物。这里只进行了文本准备、AST/Bash 语法检查和元数据/字节比较；未执行 prepare、submit、SSH、record、题目编译测试或哈希。
