# C28 轻量静态审查

2026-09-12；只比较源码文本和读取生成结果，没有编译、运行算子或执行测试。

- C24 与 C28 在 `conv_sve_rowquad` 之前、之后的完整文本均相同；调度、其它 helpers 和非 SVE 路径保持原字节。
- quad 内 kh<4 回退与尾列回退文本均相同。
- 新 quad 恰有 7 个 `for (int ik = 0; ik < kw; ++ik)` 阶段、24 个零初始化 accumulator、24 个输出 store；无 svext、无 inline asm。
- 各 stage 生成列表已按 PLAN 的七阶段表逐项审查。中段输入 t 对应 a:t、b:t-1、c:t-2、d:t-3；末三段分别结束 b、c、d。每个向量单独作用域中加载后逐行完成一次 mul/add。
- 源码 README、bench_conv.c、run.sh 与 C24 字节相同。
- 完整块最大输入列/行、写出范围与 i+=block 的边界推导见 PLAN；C28 实际代码生成、寄存器分配、正确性及速度仍等待超算验证。

生成脚本只写本候选 source/conv2d.c；它拒绝覆盖已测 C28 或其它非预期编辑。源码身份已由 checkpoint 自动登记，不额外重复手工哈希审计。
