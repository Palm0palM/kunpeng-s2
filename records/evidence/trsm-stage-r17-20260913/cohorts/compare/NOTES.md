# r17 两步展开比较准备

A=T19-control13-repeat-r17，保留刚实测晋级的基线prior作业1581760；B=新T20-wideunroll2，父版本T19-control13。完整预热AB后，正式AB/BA/AB三轮，原TEST_RUNS3，18正式/6预热。全部样本保留。

两者在同一计算节点均运行原CT64 wide32完整预检28直接/28整算子/56参数/7进程，覆盖count0/1/奇偶、packed/strided、失败/窄VL/无SVE。T20只改大路径4×32核内k循环，小路径和分派直接关联原已验证T19源码；不把旧615案例声称为本轮执行。

controller从r16完整排他混合repeat/new流程适配；driver从刚验证r17 baseline流程适配，并插入两者的wide32门禁。finish继承r16的原始正式/预热/依赖/冻结源码检查，只有A使用repeat-existing，无机理比较，唯一比较为当前父T19-control13对T20。prepare仍受root最终审核阻断。
