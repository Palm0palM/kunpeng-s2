# T2-unroll：本机准备完成

2026-09-08。父版本 T0，从其原始源码快照创建。单一假设：大工作集 NEON `update4x8` 的 k 点积循环显式展开两步，减少循环分支和地址计算，并给编译器更多加载/FMA 调度机会。

每轮先执行原来的 k 步，再执行同样的 k+1 步；每个累加器的 k 顺序完全保持，未分裂或重组归约。末尾 `if(k<count)` 处理奇数尾项。没有预取，没有改动小工作集路径、KB=256/CT=64、4×8 微核形状、线程、精度、runner 或官方 benchmark。完整差异在 `source-vs-T0.diff`。

| 源码 | SHA-256 |
|---|---|
| T0 trsm.c | `6b66766196b2a6024fcbbeac45ff1b4189e19cc8ac8d75d001e4ddfea004abac` |
| T2-unroll trsm.c | `bff1a285b4e454d26fecdc548409d424ae2fe18e042620319db026105149910c` |

## 环境和检查

本机 Apple ARM64，macOS 26.5 (25F71)，Apple clang 17.0.0 (clang-1700.6.3.2)，target arm64-apple-darwin25.5.0，Homebrew libomp 22.1.8。纯 UBSan 编译：`-O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined`，启用 OpenMP。运行设置 `OMP_NUM_THREADS=1/4`、`OMP_DYNAMIC=FALSE`、`UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1`。

复用上一轮未修改的 `check-final.c`、`check-packed.c` 和 `fail-alloc.c`。`check-final` 链接未改 Z0 只是满足现成检查程序依赖。完整构建/运行命令、工作目录、环境变量、开始/结束时间和退出码保存在 `commands-results.json` 及相应 `.log`，可用 `validate.py` 复现。日志中墙钟时间是检查耗时，不是性能测量。

| 检查 | 线程 | 结果 | TRSM 最大绝对误差 |
|---|---:|---|---:|
| 原始已知解/padding/L 不变性 7 组 | 1 | PASS，退出 0 | 2.776e-16 |
| 原始已知解/padding/L 不变性 7 组 | 4 | PASS，退出 0 | 2.776e-16 |
| 阈值/块边界/尾部 4 组 | 1 | PASS，退出 0 | 3.886e-16 |
| 阈值/块边界/尾部 4 组 | 4 | PASS，退出 0 | 3.886e-16 |
| 强制分配失败版本，原始 7 组 | 4 | PASS，退出 0 | 2.776e-16 |
| 强制分配失败版本，扩展 4 组 | 4 | PASS，退出 0 | 3.886e-16 |
| 微核 0/1/偶数/奇数 count 和不同步长 55 组 | 单次直接调用 | PASS，退出 0 | 与有序标量 FMA 逐位一致 |

正常路径共 22 次 TRSM 检查；分配失败版本共 11 次整算子检查，其中 7 次走小工作集分配失败后的回退路径，另外 4 次走不分配临时面板的大工作集路径。这轮基于 T0，不能将后 4 次描述为共享 RHS 面板分配失败回退。复用测试的名字仍为 `check-packed`，但它在本候选只表示这组既有阈值与尾部测试。

原始尺寸：1×1、3×19、33×17、129×53、513×65、4095×3、4097×3。扩展尺寸：4095×9、4096×8、4097×9、4355×65。所有整算子检查保持 1e-12 容差、B padding 和 L 逐字节不变。附带的 Z0 270 组在两个正常线程设置及一次分配失败版本下均 PASS，最大误差 1.814e-14；没有改动或优化 ZGEMM。

`check-update.c` 直接调用本候选静态微核，组合 count `{0,1,2,3,7,31,63,127,255,256,257}` 与 ldb `{8,9,17,65,512}`，共 55 组。参考实现逐输出按 k 顺序调用标准 `fma`，结果、输出 padding 和只读输入均逐字节检查。这样直接覆盖两步展开的奇数尾部：在当前 KB=256 的整算子流程中，末尾不满块的对角块之后没有待更新行，通常不会实际调用更新微核的奇数 count 路径。此测试不修改官方 benchmark。

所有 6 个构建和 7 个运行均退出 0，未发现 UBSan 诊断、编译警告或测试 FAIL。未运行 ASan。

## 证据与状态

- `source-hashes.json`：候选、基线与测试依赖的 SHA-256。
- `validation-sha256.json`：本机检查源码、二进制、命令、日志与报告的 SHA-256。
- `prepare.log`、`checkpoint.log`：实验创建与准备登记的完整命令和退出码。
- 源码仅 `update4x8` 改变；其余候选源文件与 T0 逐字节相同。

仅完成本机已知解和微核参考检查，没有 BLAS 参考库参与。尚未运行鲲鹏官方 benchmark、服务器 sanitizer 或官方 KML 25.2.0 校验，没有远程性能结论；继承的实验设置含 OpenBLAS 静态库，不能称为官方 KML 复验。未访问远程服务器、提交或取消作业，未正式提交比赛，未晋级。交由主 Agent 完成同环境测量与比较，当前最佳仍为 T0。
