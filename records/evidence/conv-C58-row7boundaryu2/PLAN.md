# C58：rowseven 边界阶段循环展开提示

原字节来源为 C52-row7x3shared2 / T1582134 冻结源，conv2d.c SHA `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。唯一假设是在 rowseven 六个 input 和六个 trailing 的 kernel-column for 循环前各加 `#pragma GCC unroll 2`，观察边界阶段循环控制是否减少及实际调度如何变化。

只增加12条 pragma，不复制或重排算术；shared 两列主循环及原 u1 余项、其他 helper、dispatch、tail/fallback 和 README.md/bench_conv.c/run.sh 原字节不变，flags不变。仍为7行×3VL、21 accumulator，源级每个 accumulator 的 kernel-row/column 顺序及独立 FMUL/FADD 表达式不变。

这是新源码假设。原 C52/T 数值通过只覆盖父字节，不能替代 C58 自身诊断。没有本机编译/测试、SSH、作业、性能、包、晋级或发布；C56/C57/AF/AG 与 best 不改，Y/S 既有失败确认不重试。

GCC 可能增加代码体积、寄存器压力、spill、余项分支或编译器生成的循环，也可能不产生预期展开。边界阶段收益可能不足，不能按 pragma 数量或循环次数预判提速。下一步仅供 root 独立源码审查；未来实际编译需检查13阶段及完整 helper/stack/ABI、动态主循环和余项路径，再由独立授权决定数值与性能。
