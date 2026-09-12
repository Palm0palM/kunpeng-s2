# r12：大路径分块大小比较准备

r11已完成并合并PR19；T13合计改善2.7439%仍未超过3.0751%门槛，T8-control12保持当前最佳，T8提交ZIP不变。本目录仅准备，尚未执行prepare、submit、collect或登记，也没有生成payload、cohort状态或作业ID。

四成员固定为A=T8-control12-repeat-r12、B=T13-sve4x32-repeat-r12、C=T15-svetile128、D=T16-svetile32。A/B按原版本新增run，使用repeat-existing并保留所有prior；C/D各从T13只改变CT128/32一个常量，晋级父基线仍为实际最佳T8-control12。T13与CT候选的同作业差值可用于判断CT的增量影响，但晋级比较仍针对T8。

每成员完整官方预热一次，随后各三套正式用例，预先固定顺序A/B/C/D、B/C/D/A、C/D/A/B。它是三次循环移位，不声称覆盖四个位置的完整均衡设计。所有正式样本均保留，预热另存；TEST_RUNS=3、原benchmark/runner/1e-12/计时区、38线程单NUMA、24GiB、1800秒不变。实际KML25.1/GCC12不等同指定KML25.2复验。

四成员都执行原通用14直接核/406整算子/28空操作预检。B/C/D分别以expected_CT=64/128/32执行新的wide32预检；其四个输入文件由worker完成并独立静态审查，Root核对控制器调用和最终字段一致。保留28直接核与原9个完整维度，增加4111×127/128/129，12完整例分别1/4线程，另4种smoke，共28整算子、56参数检查。七个进程明确检查KB256和预期CT；原源码汇编仍不插桩。

Root准备了job_control/cohort_driver/finish_records和plan，Python AST通过；暂未执行控制器。下一步先doctor，逐项静态复核prepare对两份repeat与两份新候选分支及wide32字段，然后prepare，验证两份repeat前置条件，最后仅提交一个作业。新候选源码快照、完整命令、真实日志和逐例比较都必须保留；完成前不要晋级或更新ZIP。

无本机题目编译或运行、无哈希、无公共工具或其他题目改动。T14共享L生产循环候选及仅针对T13的条件打包脚本另行保留未执行；若未来晋级不同版本，不能直接运行硬编码T13的打包脚本。
