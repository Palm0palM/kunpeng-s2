# r10 调度终态同步记录

作业1579585的计算节点预检、预热和正式测量日志已经推进时，djob -ll 仍显示 PENDING；对应原查询保存在 scheduler-pending-during-preflight.txt。两成员 BENCH_JOB_END 为2026-09-12T10:13:22Z，cohort-exit-code 为0；当时 djob -D 尚返回 no matches。只将已完成日志读到独立 preterminal-diagnostics 供分析，没有重复提交或重新运行题目，也未提前登记。

之后 djob -J -ll 返回 SUCCEEDED，随后正常 collect 的 djob -ll 同样返回 SUCCEEDED，jobExitCode/systemExitCode均为0。调度器最终记录 startTime 与 endTime 均为18:17:12，jobWallclockDuration为173秒。这里只保留这些观测，不把调度器时间戳差异解释为已经查明的内部原因。

正式登记只使用最终正常collect下载的日志与diagnostics；没有发生失败的collect尝试，没有降低终态门槛。原PENDING、completed-list、step、JSON状态及最终文本状态均留档。preterminal-diagnostics的重复文本保留在本地，不混入正式样本或覆盖原证据。
