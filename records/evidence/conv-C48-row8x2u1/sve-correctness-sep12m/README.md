# C48-row8x2u1：M 专项包（prepared）

这是八行 × 2VL 的独立待验证包，生产源已冻结，尚未编译、测试、SSH或提交。计划 SVE bytes16/32/64 ×threads1/4，六配置41664项：full5360、dispatch1080、direct504每配置；roweight入口预期792/1260，各自worker mask1/15。

[矩阵与逐项推导](DIAGNOSTIC_DESIGN.md)、[执行/留痕计划](PLAN.md)、[静态审阅](STATIC_REVIEW.md)、[初始元数据](prepared.json)。source五文件、source-hashes简单映射和source-manifest字节/摘要映射保持原样；validation当前complete=false。

实际源码有15阶段、16acc；GCC10.3.1真实codegen、全部阶段/转场/回退、FMA与spill仍待计算节点结果。未复用任何旧候选PASS。后续公共工具由根代理另行安排；没有自动提交、性能或晋级。本机仅完成轻量文件准备。
