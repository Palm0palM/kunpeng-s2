# AN：C60 自身诊断，prepared only

候选 `C60-row7shared2ext`，source parent 为已确认 C7/C58-r1。自身源为109197字节，`10df62b8d43c59a6164de7d23c1b59ab954bbaaebc330d57662e8f5d6b7f2168`。共享两列循环用三次EXT重用第一列窗口，第二列尾部只读一个float；实际指令和spill待本轮原作业返回后审查，不预填提速。

两份checker逐字节复用AJ；wrapper只替换候选身份和源SHA，candidate.env只替换身份。仍为六配置VL16/32/64字节×线程1/4，各full5744/dispatch1212/direct432，总44328，19阶段。GCC10.3.1、generic、strict/关闭FP融合、38CPU/24576MiB/单packed NUMA/1800秒不变。无本机算子运行，无sanitizer、官方runner或性能。

driver仅核对当前C60四份生产源/record、五份运输源/初始清单，以及确认父C7源相同。保留原 `creation-experiment-original.json`，只核对身份和created_at，不要求扩展meta与creation原件相等；不继承C59 input_5约定，不递归AI/AH。

串行门禁只检查原AM1589364已完整记录36样本并实时终态（job/system为整数），以及本AN预约。未知ID、查询失败、非终态均阻止。它不代替root对结果的判断，也不是全局锁；root为唯一提交者，GO前/每阶段须读取主额度，达到40%停止且不使用reset。

唯一submit先以排他job.json预约再上传/提交；失败/断线保留原件，不重提交。status/fetch复用真实ID，真实终态包括失败才fetch。raw仅可新增或核对相同字节，不覆盖不同返回证据。所有调用用sep13-run-logged.py保留argv/UTC/stdout/stderr/exit。准备期间以下命令均未执行：

```text
python3 .runs/conv/sep13an-checks/driver.py C60-row7shared2ext config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13an-checks/driver.py C60-row7shared2ext config/conv-sep12.local.json status
python3 .runs/conv/sep13an-checks/driver.py C60-row7shared2ext config/conv-sep12.local.json fetch
python3 .runs/conv/sep13an-checks/accept_and_freeze.py --job-id <实际原AN_ID>
```

接受器要求真实 `AN_SUMMARY.json` 与原job/参数/调度器一致，重读19阶段和六配置原日志、三条实际gcc argv、源/资源关联、全退出0和全源FMA0。摘要沿用AJ字段：candidate/job_id、wrapper_exit/issues、stages（stage/exit_code）、actual_compile_argv、compiler_version、allowed_cpus、requested_resources、scheduler_resources、source_files（name/sha256/all_manifests_and_transport_bytes_equal）。只能从本AN日志解析，不能抄父版PASS。

实际目标审查只需共享两列输入load/EXT数量、单lane尾pred、spill、helper帧和全源FMA；保存TARGETED_ASSEMBLY_REVIEW.md及root的ROOT_RETURNED_REVIEW.md。接受前还需BASE/ROOT_REVIEW.md与本次INDEPENDENT_TOOLS_REVIEW.md供归档。接受一次到C60的sve-correctness-sep13an目录，不自动确认、晋级或打包。
