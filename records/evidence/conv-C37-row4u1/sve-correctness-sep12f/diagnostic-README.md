# Sep12f C37 单列共享循环诊断（prepared）

当前仅轻量准备，必须等根代理确认sep12e性能组结束并明确GO后才能提交。不与性能并行，不重复提交，无本机编译/测试/重置卡。

候选C37-row4u1保持quad四行×4VL，仅共享中段每次处理一kernel列；原六个首尾阶段仍配对。标准矩阵每配置18052 full+96 smoke，六配置1/4线程×SVE128/256/512位，共108888。所有旧只读输入/kernel、保护页、输出NaN/canary、strict有序scalar逐位参考与workerVL检查保持不变；真实pair/triple/quad入口均要求非零。kh>=4/奇偶kw/满4VL前后与尾行覆盖共享单列路径，kh<4保持回退。

源快照与首次传输manifest已保存。wrapper沿用38CPU单NUMA校验与非致命perf元数据探测，全部计算仅在调度节点。实际汇编应分别报告共享单列主循环与六个配对阶段的工作量、加载/乘加、spill/FMA，不能按源码假定机器顺序或收益。

GO后命令：python3 .runs/conv/sep12f-checks/driver.py C37-row4u1 config/conv-sep12.local.json submit|status|fetch（分次执行）。保存唯一job ID并约60秒查询，全部日志/调度/退出/实际计数/VL/入口与自动manifest验收才可complete=true，冻结至sve-correctness-sep12f。当前未提交。

## C38 / C39 actual runner validation

C38: production-object guard smoke 96 x 6 = 576; original runner four PASS separate (combined 580). C39: production-object strict guard 7108 x 6 + independent instrumented dispatch 96 x 6 = 43224; original runner four PASS separate (combined 43228). Six configurations: 1/4 threads x 128/256/512-bit SVE.

Run original run.sh first, then link its actual conv2d.o to an untuned strict-reference guard. C39 tunes only the production conv2d.o to hip11; benchmark/link remain untuned. Unsupported target query fails, with no fallback. Preserve production object, disassembly and actual build argv.

validation total_cases counts specialized checks only; runner_cases=4 and combined_validation_cases adds both. runner fields: passed, case_count, cases, build_commands, production_object_tested, benchmark_flags_untuned, kernel_tune. complete=true requires all six configurations, scheduler/exit, transport manifest, runner checks and actual assembly review.
