# C60 输入复用的静态边界说明

令 L=svcntw()，输出宽 ow=W−kw+1。rowseven 完整块条件 `ow-i>=3*L`，共享两列条件 `kw-ik>=2`，故 `i+ik+3*L <= ow+kw−2 = W−1`。tail 的基址是本行内最后一个第二列窗口所需的末元素，未超过该行范围。`svwhilelt_b32((uint64_t)0,(uint64_t)1)` 只激活第一个 float；`svld1` 对其余非活动 lane 不访问内存。没有在 tail 基址读取完整 VL。

对于 n=0,1，v[n] 与 v[n+1] 拼接左移一个 float 后，lane j 恰为 row[ik+n*L+j+1]。对于 n=2，j<L−1 来自 v2 的下一 lane，j=L−1 仅来自 tail[0]；tail 其余 lane 不被 EXT 结果使用。因此三次 EXT 与父版本第二列的三个完整窗口逐 lane 相同。L 在受支持 SVE 向量长度下至少为 4，固定偏移 1 有效。

API 用法与父源码现存 `svext_f32(v0,v1,1)` 及 uint64_t 参数的 `svwhilelt_b32`/predicated `svld1` 一致；这里未声称已编译新组合。共享行 t 从 6 至 kh−1，行基址及所有输出/dispatch 边界不变。

准备脚本只定位 rowseven 共享两列片段，添加四个输入定义并替换该片段六条 v 初始化；将这六条替换和新增定义精确逆向还原后，片段字节与父版相同。其余源码前后段原样拼接，README.md、bench_conv.c、run.sh 逐字节相同，12 处边界 pragma 保留。算术行、权重、余列循环均未编辑。

这是一段静态证明，不是数值或性能通过结论。下一步仍须独立诊断覆盖不同 VL/线程/边界，然后同资源性能测量。
