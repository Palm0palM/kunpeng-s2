# T1-colreuse：本机验证完成，鲲鹏待测

2026-09-08。父版本为当前最佳 T0；实现派生自已测候选 T1-panel（`derived_from T1-panel`），未晋级。

相对 T1-panel 只修改 `solve_blocked` 更新区的一行：将 `for i … for j …` 换为 `for j … for i …`，让一个已解 256×8 RHS 面板在同一个 CT 块内连续供多个 4 行更新使用。单一待验证假设是这种访问顺序能提高打包面板复用。每个输出元素的点积累计次序、块尺寸、OpenMP 分工、同步和分配失败路径均保持原样。官方 benchmark、runner、兼容头与 T0/T1-panel 逐字节一致。

源码 SHA-256：

| 源码 | SHA-256 |
|---|---|
| T0 trsm.c | `6b66766196b2a6024fcbbeac45ff1b4189e19cc8ac8d75d001e4ddfea004abac` |
| T1-panel trsm.c | `fea6ee11cce8785ac3f13f641f9feb195a829493a27a9c902000a743545dbf73` |
| T1-colreuse trsm.c | `e0cee4d518144cfbc83e25cfffc55e64cfabc1687ef79ac449720fa84ed76d9f` |

## 本机环境与方法

Apple ARM64，macOS 26.5 (25F71)，Apple clang 17.0.0 (clang-1700.6.3.2)，target arm64-apple-darwin25.5.0；Homebrew libomp 22.1.8。编译为纯 UBSan：`-O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined`，启用 OpenMP。运行显式设置 `OMP_NUM_THREADS=1/4`、`OMP_DYNAMIC=FALSE`、`UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1`。

未修改地复制并复用 T1-panel 的 `check-packed.c`、`fail-alloc.c`，以及上层 `other-problems/tests/check-final.c`。`check-final` 链接未改 Z0 仅为了满足现成测试的依赖。正常与边界检查以已知解为参考，精度仍为 `1e-12`；未链接 BLAS，不是官方 benchmark 或 KML 校验。

所有编译与运行命令、工作目录、明确环境变量、时间戳、退出码及原始输出见 `commands-results.json` 和相应 `.log`；`validate.py` 是完整可复现入口。运行墙钟时间仅记录检查执行，不作为任何性能结果。

## 结果

| 检查 | 线程 | 结果 | TRSM 最大绝对误差 |
|---|---:|---|---:|
| 原始已知解、padding、L 不变性 7 组 | 1 | PASS，退出 0 | 2.776e-16 |
| 原始已知解、padding、L 不变性 7 组 | 4 | PASS，退出 0 | 2.776e-16 |
| 阈值/尾部/打包路径 4 组 | 1 | PASS，退出 0 | 3.886e-16 |
| 阈值/尾部/打包路径 4 组 | 4 | PASS，退出 0 | 3.886e-16 |
| 强制分配失败回退 4 组 | 4 | PASS，退出 0 | 3.886e-16 |

共 22 次正常 TRSM 检查和 4 次强制分配失败回退检查通过；所有构建退出码为 0，未出现 UBSan 诊断。扩展尺寸为 4095×9、4096×8、4097×9、4355×65，覆盖算法阈值两側、4×8 NEON 更新、8 列尾部、64 列边界和不足 256 行的末尾对角块。每组 B padding 均保留，L 均逐字节不变。

现成 `check-final` 附带的 Z0 270 组在两个线程设置下均通过，最大误差 1.814e-14；未修改 ZGEMM，也没有据此作 ZGEMM 优化结论。

## 证据和待测事项

- `source-vs-T1-panel.diff` 保存唯一的源码差异；`source-hashes.json` 保存所有候选源文件与测试依赖哈希。
- `validation-sha256.json` 保存本机日志、测试源码、检查二进制和报告的哈希。
- `prepare.log`、`checkpoint.log` 保存实验创建与准备登记命令和退出码。
- 未访问远程服务器、未提交或取消作业、未正式提交比赛。鲲鹏性能、服务器 sanitizer、官方 KML 25.2.0 校验均待完成。本机数值验证不能代替这些检查。
- 候选继承 T0 的现有实验设置，其中参考库为 OpenBLAS 静态库；这只表示待测配置，不能称为官方 KML 复验。

候选具备继续同环境完整官方用例测量的本机正确性条件。是否提速与晋级由主 Agent 根据鲲鹏测量决定，当前最佳仍为 T0。
