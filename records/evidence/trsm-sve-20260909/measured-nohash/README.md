# TRSM 无哈希编排

用户明确要求所有后续步骤都不计算或验证哈希，包括原工具内置校验。因此本轮使用实验专属编排与登记器，公共工具文件不变。保留完整源码快照、真实调度ID、逐用例原始日志、严格正确性与线程限制，明确记录 no-hash 策略，不将未执行的校验记为通过。

T1-control6、T3-svepanel-r3、T3-sveupdate-r3 分别来自原 T1-panel-r2、T3-svepanel、T3-sveupdate 源码。所有benchmark与runner直接复制，没有编辑。设置显式包含 OpenBLAS 静态路径、TEST_RUNS=3、38线程、单NUMA。所有编译和测试只在超算执行。

旧1492070在计时前因KBLAS_LIB缺失自行失败。收到no-hash指令后尝试仅停止该自有任务时，调度器确认它已FAILED；未取消任何其他作业。前期完成的SVE预检查证据保留，零官方计时成绩不混入本轮。
