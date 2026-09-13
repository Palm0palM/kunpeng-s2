# C45 I 诊断计划

唯一验证对象为已冻结C45-row4dup4，源码不编辑。使用C32实际四列边界模板原始guard/dispatch，计划121560专项、0 runner；完整计数及覆盖缺口见README。

先检查调度分配和GCC10.3.1，再编译未插桩生产候选与独立guard，顺序运行六个full配置；再构建单独插桩smoke运行六配置；最后输出未插桩完整汇编。所有步骤仅待计算节点执行。本包不包含提交driver，不设置job或自动启动。

wrapper保留原严格算术flags、两个translation unit的生产编译方式和单独-finstrument-functions入口诊断，新增的候选身份、compiler-version、逐阶段exit和显式BUILD_COMMAND仅用于证据记录。没有改参考算法、容差、guard矩阵、正式benchmark或计时区。

验收后须独立审查quad七阶段/转场及shared四列/两列/单列机器码。诊断PASS不等于性能改善；若DUP折叠后与C29/C32无新机器码安排，保存此观察并停止自动性能分支。
