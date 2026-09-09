# T3-svepanel：SVE 候选已实现，本机回退验证通过

2026-09-09。只修改候选 `source/trsm.c`，新增小工作集 `panel_sums` 的 4×8 SVE 实现与运行时选择。父记录和策略由主 Agent 创建；本子任务没有登记、晋级或计算哈希。

## 实现与护栏

编译条件严格为 Linux、AArch64、GCC >= 10 且非 Clang；其他条件下不包含 SVE 头文件或函数。两个 SVE 函数使用 `target("arch=armv8-a+sve"), noinline`，写法参考已发布 CONV 源码快照 `.runs/trsm/github-upstream-20260908/conv/conv2d.c`，保持翻译单元其余部分的原编译选项。

在 `solve_panel` 的 OpenMP 并行区内，每个线程先检查 `getauxval(AT_HWCAP) & HWCAP_SVE`，短路条件成立后才调用带 SVE target 的向量宽度函数；只有该线程 `svcntd()==8` 时选择 SVE 微核。向量宽度为线程状态，因此没有仅在主线程查询后将结果套用到所有工作线程。

新增微核每行使用一个八 lane double 向量，共四个累加器。每个 k 载入原打包 RHS 的八个 double，按原顺序调用四次 `svmla_n_f64_x`，随后写出四行。每个输出从 +0 开始按 k 递增做融合乘加，保持原 NEON `vfmaq_n_f64` 的逐元素累计顺序和语义。`svptrue_b64()` 只在已确认八个 double lane 后使用。

原 NEON `panel_sums` 完整保留；不支持 SVE、宽度不是八个 double、其他编译器/平台均走原路径。RHS=8、ROWS=4、列尾补零、`h<4` 行尾、小工作集分配失败回退、线程调度和其他算法均未修改。直接按字节比较确认，从 `enum { KB = 256, CT = 64 };` 开始的大工作集实现完全不变；benchmark、runner、README 和兼容头与 T1-control3 源码完全相同。未计算哈希。

## 本机测试范围

本机 Apple ARM64 / macOS 26.5 (25F71)、Apple clang 17.0.0、Homebrew libomp 22.1.8。此平台编译护栏为 0，因此此次构建和执行只验证原 NEON/标量回退，没有编译或执行新增 SVE 分支。Linux GCC 10 构建、HWCAP 不支持时的运行时回退、非八 lane 的运行时回退，以及八 lane SVE 数值正确性和性能都仍待目标环境验证。

检查代码只依赖 TRSM，没有链接、修改或测试 ZGEMM。`check-packed.c` 和 `fail-alloc.c` 直接复用 T1-panel 专属检查；`check-trsm.c` 沿用相同的已知解、padding、L 不变性检查逻辑，选择原 TRSM 尺寸并补充行列尾部。精度仍为 1e-12，没有修改官方 benchmark。

编译使用 `-O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined` 和 OpenMP。运行设置 `OMP_NUM_THREADS=1/4`、`OMP_DYNAMIC=FALSE`、`UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1`。五个构建与六次运行均退出 0，未出现 UBSan 诊断、编译警告或 FAIL。

| 检查 | 线程 | 结果 | 最大绝对误差 |
|---|---:|---|---:|
| 正常路径与行列尾部 12 组 | 1 | PASS | 2.776e-16 |
| 正常路径与行列尾部 12 组 | 4 | PASS | 2.776e-16 |
| 阈值/打包/块尾部 4 组 | 1 | PASS | 3.886e-16 |
| 阈值/打包/块尾部 4 组 | 4 | PASS | 3.886e-16 |
| 强制分配失败，正常/尾部 12 组 | 4 | PASS | 2.776e-16 |
| 强制分配失败，阈值/打包 4 组 | 4 | PASS | 3.886e-16 |

合计 32 次正常检查和 16 次强制分配失败检查。后者包括 12 次小工作集面板分配回退与 4 次大工作集共享 RHS 面板分配回退。所有检查保持 B padding 与 L 逐字节不变。

12 组正常/尾部尺寸为 1×1、3×19、33×17、129×53、513×65、4095×3、4097×3、4×7、4×8、5×9、31×15、32×16；四组扩展尺寸为 4095×9、4096×8、4097×9、4355×65。

## 证据与待测

- `validate-local.py`：完整本机检查入口；不计算哈希。
- `commands-results.json` 和对应 `.log`：完整命令、环境变量、工作目录、时间戳、退出码及原始输出。墙钟时间只是本机检查运行时间，不是性能结果。
- `source-before.c`、`source-vs-T1-panel.diff`：修改前副本和全部源码变化。
- `static-review.txt`：独立只读审查，确认编译护栏、短路顺序、线程局部向量宽度、每元素 FMA 顺序，以及未修改其他路径；静态审查不能替代 SVE 运行。

此次没有远程访问或提交/取消作业。没有官方 KML 或 BLAS 参考库参与本机检查，不能称为官方 KML 复验。SVE 分支必须由主 Agent 在 Linux GCC 和实际 SVE 环境完成构建、宽度/分派取证、数值及完整官方用例性能验证后再判断；当前没有提速或晋级结论。
