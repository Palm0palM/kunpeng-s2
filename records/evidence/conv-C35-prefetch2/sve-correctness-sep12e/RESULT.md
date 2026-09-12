# C35 验收

原作业1579388 SUCCEEDED，job/system/wrapper退出0；六配置29668 full+168 smoke+18分支proof，总179124项全部通过，validation.complete=true。每配置18项预取次数逐项精确符合4×满块数×四行组数×max(kh-5,0)，合计120次：kh5关闭、kh6首次、kh7多次，4VL前不触发、满4VL及尾列保留原行为。原始guard/只读input与kernel/输出canary/NaN/有序逐位参考、worker VL和自动manifest核验均通过。

未插桩生产汇编包含4个PLDL1KEEP。w20=kh-t，cmp w20,2 / bls跳过不满足条件者；[sp256]=kh+2减w20形成t+2，结合stride、i和base形成四个向量起点。提示在共享输入行.L346，ik内层.L343回边不重新经过提示。主配对循环仍93指令、32mul+32add、8输入load+8广播，无向量spill和FMA。固定800B栈帧含额外标量地址保存；d8–d11属于ABI。独立只读复核一致。

PMU元数据探测实际成功：/usr/bin/perf，perf_event_paranoid=2，perf stat -x, -e cycles,instructions -- /bin/true退出0，返回525449 cycles:u和154116 instructions:u，运行比例均100%。这仅表明本计算节点本次允许该用户态事件探测，数值来自/bin/true，不是算子性能数据；其它事件仍未验证。

完整证据已保留；没有本机编译测试、重置卡、性能提交或候选源码修改。性能收益仍待根代理正式比较。
