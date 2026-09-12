# 调度终态等待

作业1579479的三个成员在2026-09-12T09:45:50Z写入BENCH_JOB_END，cohort-exit-code为0。稍后的djob -ll仍显示RUNNING，一次collect按原规则拒绝，原日志保存在collect-before-scheduler-terminal.log；当时没有登记或晋级。

为保留已经完成的计算证据，只读取到新的private preterminal-diagnostics目录，未重新执行任何题目。后续按djob帮助查询-D完成列表，取得SUCCEEDED和两项退出0，再次正常collect的djob -ll也已返回SUCCEEDED。调度记录endTime为17:50:52，jobWallclockDuration为235秒；不把二者差异解释成确定的调度器内部原因。

正式登记与比较只使用最终成功收集的diagnostics/及各member日志。公共归档保留先前collect拒绝、最终调度器记录和完成/step查询；重复的preterminal文本仅保留本地原件。该等待没有导致重复提交、取消作业、删除样本或更改验证门槛。
