# 本轮可复核执行入口

公共工具未修改。两份实验专属编排先 prepare 冻结私有源码/配置，再 submit；每份仅提交一次。每个成员 cluster.json 保留同一真实 job ID 与自己的真实远端路径，status/fetch/record 均使用现有工具。

```bash
python3 .runs/trsm/continuation-20260908/submit_cohort.py prepare
python3 .runs/trsm/continuation-20260908/submit_cohort.py submit
python3 .runs/trsm/confirmation-20260908/submit_cohort.py prepare
python3 .runs/trsm/confirmation-20260908/submit_cohort.py submit
```

上述目录已有提交及完成状态，不能重复执行 submit。后续复测需新建唯一实验目录。各成员分别实际执行 `python3 tools/cluster.py status .runs/trsm/<ID>`、`fetch`；完整 dsub 命令与资源见每个编排的 cohort-submission.json。实际 record/compare 参数与退出码在各编排的 record-compare-commands.json；晋级命令及输出在 confirmation/promotion-commands.json。本机编译和运行命令在两候选 local-validation/commands-results.json，完整本机二进制及快照保留在 .runs/。

确认顺序：第一作业 T0-r2/T2-k128/T2-unroll → T2-k128/T2-unroll/T0-r2 → T2-unroll/T0-r2/T2-k128；第二作业 T0-r3/T1-panel-r2 → T1-panel-r2/T0-r3 → T0-r3/T1-panel-r2。每次执行均为全部三组官方用例，TEST_RUNS=3。

准备期语法编译曾因 macOS 默认字节码缓存位于沙箱外失败，没有运行 prepare/提交；随后用不写缓存的 AST 语法检查通过，再进行 prepare。此失败仅为本机辅助检查，未作为算子或性能结果。没有重试任何已提交或不确定提交的作业。
