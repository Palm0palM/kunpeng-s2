# TRSM 当前最佳与候选记录

2026-09-13 完成第十六轮交付：**当前最佳 T19-panel8x16budget**。超预算小路径改用8×16 SVE双面板前代，同分配三轮中用例快 **48.85%**、合计快 **29.58%**，通过原波动与逐例门槛；27/27正式结果和完整预检通过，已晋级。最终ZIP独立三套9/9 PASS，15,593字节。[完整记录](trsm-stage-r16-20260912.md)；[最终交付](trsm-final-20260912-r16.md)。真实KML25.1/GCC12，尚非指定KML25.2复验。

2026-09-12 第十五轮：T18同源码确认小例快 **21.93%**、大例快 **6.76%**，合计快 **3.68%**，未超过 **11.86%** 波动门槛，仍不晋级。18/18正式、6/6预热及完整预检通过，保持T8提交包；继续考察中用例的小路径块形状。[完整记录](trsm-stage-r15-20260912.md)。

2026-09-12 第十四轮：4MiB共享历史预算使中例耗时回到基线附近，组合4×32更新的T18较T8合计快 **6.93%**，但未超过 **27.56%** 波动门槛，不晋级。36/36正式、12/12预热及预算/宽核预检通过，保持T8提交包；继续同源码确认。[完整记录](trsm-stage-r14-20260912.md)。

2026-09-12 第十三轮：T14共享L生产循环改为循环静态分配，中例仍比T8慢 **11.28%**、合计慢 **4.83%**；相对同期T10也无改善，未晋级。27/27正式、9/9预热及全部预检通过，保持T8提交包。下一步准备限制历史打包预算。[完整记录](trsm-stage-r13-20260912.md)。

2026-09-12 第十二轮：T13 CT64 大用例快 **7.15%**、合计快 **4.55%**，未超过 **5.26%** 波动门槛；CT128/CT32 大用例分别比T13慢 **4.75% / 2.22%**，均不晋级，保持T8及原提交包。36/36正式、12/12预热及全部预检通过。[完整记录](trsm-stage-r12-20260912.md)。

2026-09-12 第十一轮：T13同源码复测大用例快 **6.79%**、合计快 **2.74%**，仍略低于 **3.08%** 波动门槛，不晋级，保持T8。18/18正式、6/6预热及全部预检通过；下一步准备CT128/CT32分块候选。[完整记录](trsm-stage-r11-20260912.md)。

2026-09-12 第十轮：T13 的 4×32 大路径核同分配三轮大用例快 **6.49%**、合计快 **2.62%**，但未超过 **7.55%** 波动门槛，不晋级，保持 T8。18/18 正式、6/6 预热及宽核/回退预检通过；优先继续同源码确认。[完整记录](trsm-stage-r10-20260912.md)。

2026-09-12 第九轮：T11 同源码复测的大用例快 **2.07%**、合计快 **1.22%**，仍未超过 **4.73%** 波动门槛；T12 前代调度约束合计慢 **0.50%**，均不晋级，保持 T8。27/27 正式、9/9 预热及预检通过，两份 prior 记录完整保留。[完整记录](trsm-stage-r9-20260912.md)。

2026-09-12 第八轮：T11 的 8×16 大路径核在同分配三轮中大用例快 **3.57%**，但合计只快 **0.38%**，未超过 **11.52%** 波动门槛，暂不晋级，保持 T8。18/18 正式、6/6 预热及新核/回退预检全部通过；准备继续确认。[完整记录](trsm-stage-r8-20260912.md)。

2026-09-12 第七轮：T10 编译器约束消除了历史核的栈读写，但同分配三轮合计仍慢 **6.66%**、中用例慢 **14.27%**，未晋级，继续保留 T8。18/18计时用例及6/6独立预热用例通过。[完整记录](trsm-stage-r7-20260912.md)。

2026-09-12 第六轮：保持 **T8-svepanel16**。同分配三轮27/27官方结果PASS，但NEON直接前代合计慢12.12%、共享历史L打包合计慢4.97%，均未晋级；打包仅小用例快26.58%，中用例慢11.74%。[完整记录与汇编发现](trsm-stage-r6-20260912.md)。当前测量台账为T8-control12，内核与现有T8提交包不变。

此前最佳：**T8-svepanel16**。小工作集使用 16×8 SVE 历史点积与块内前代，大路径保持 T7；KML25.1/GCC12 同分配三轮合计由 508.56 降到 447.59 ms，耗时减少 **11.99%**，小/中用例分别减少 **21.46% / 18.88%**。27/27 官方结果通过，noinline 候选未晋级。真实 KML25.1 验证不等同指定 KML25.2.0 复验。[本轮记录](trsm-stage-r5-20260912.md)；[最终交付](trsm-final-20260912-r5.md)。

此前最佳 **T7-diagpanel** 将大工作集对角块改为在共享连续面板内求解，复用 4×8 NEON 前代并合并独立打包阶段；OpenBLAS/GCC10 同分配三轮合计较 T5 减少 **8.06%**，大用例减少 **15.88%**。24 行 SVE 候选未晋级。[历史记录](trsm-stage-r4-20260911.md)；[历史交付](trsm-final-20260911-r4.md)。不同参考库和编译器的结果分别保留，不混算提速。

此前 T5-sve16rows 的 16 行 SVE 更新继续保留；其同分配三轮较 T4 合计减少 2.28%，见[历史交付](trsm-final-20260911-r2.md)。

2026-09-09 历史晋级为 **T3-sveupdate-r3**：保留 T1-panel 打包，在大工作集更新中增加安全分派的 4×8 SVE 微核。同分配三轮官方用例全部通过；合计756.94→535.06 ms，改善29.31%，大用例改善46.06%。小工作集SVE候选退化未晋级。仍为OpenBLAS参考环境，未完成官方KML复验。详见[本轮完整记录](trsm-sve-20260909.md)。

2026-09-11 较早晋级为 **T4-sve8rows**：同分配三轮合计 545.31→526.19 ms，耗时减少 **3.51%**，大用例减少 **6.97%**，18/18 官方结果 PASS。详见[8 行 SVE 记录](trsm-sve8rows-20260911.md)和[提交包记录](trsm-package-20260911.md)。

本轮 16 行 SVE、双面板与工作集受限 2/4 面板均已完成测量，只有 16 行 SVE 晋级。见[第一轮](trsm-stage-r2-20260911.md)与[第二轮](trsm-stage-r3-20260911.md)。

后续编译/测试只在超算运行；不计算或验证任何哈希（包括工具内置），已有历史字段只保留。无哈希实验记录明确其验证范围，公共工具未改。

## 2026-09-08 T1-panel 历史记录


2026-09-08 建立。当前最佳 `trsm/trsm.c` 已晋级为 **T1-panel 实现**，当前测量与晋级记录 ID 为 **T1-panel-r2**，父测量为源码等同 T0 的 T0-r3。原候选源码仍保存在 `.runs/trsm/T1-panel/source/trsm.c`；确认快照在 `.runs/trsm/T1-panel-r2/source/`，两者源码逐字节相同。

**后续同分配确认与晋级：** 作业 1485286 将 T0-r3 和 T1-panel-r2 放入同一 COMPUTE_NODE、NUMA 6、CPU 228–265 分配交错执行三轮，18 个官方结果全部 PASS。合计中位数由 776.95 ms 降到 758.31 ms（改善 2.40%），大用例改善 3.71%；最大逐用例波动 2.26%，没有用例退步超过 1%，满足工具晋级门槛。已先建立等源码测量基线 T0-r3，再通过工具晋级 T1-panel-r2。参考库仍为 OpenBLAS，未完成官方 KML 复验，未正式提交比赛。另尝试的 KB=128 和两步循环展开未晋级。详见 [后续优化与晋级记录](trsm-continuation-20260908.md)。

**首轮鲲鹏测量（历史）：** 已用现有 T0、T1-panel 目录各完成三轮完整官方用例，每用例 `TEST_RUNS=3`。两作业在 COMPUTE_NODE、NUMA 6、CPU 228–265 使用相同 GCC 10.3.1 和 OpenBLAS 静态参考库，18 条结果全部 PASS。三组中位数合计由 781.24 ms 降至 761.41 ms（2.54%），大用例改善 4.02%；但小用例退步 2.16%，总体改善未超过 3.59% 波动门槛，当时未晋级。T0 当时通过工具建立为测量基线。首轮复测、T1-colreuse 实验和完整证据见 [首轮比较记录](trsm-comparison-20260908.md)。

计算节点检查确认当前官方模块路径缺失，`kblas.h` 和 `-lkblas` 不可用；本轮仅为 **OpenBLAS 参考环境下的官方用例验证，不是官方 KML 25.2.0 复验**。以下初始假设和本机检查保留为候选建立时的历史记录。

## 单一假设与实现

大工作集分块前代的更新阶段原来从 B 读取已解右端项，k 相邻两次读取间隔为 ldb 个 double。候选将每个已解 `KB×RHS = 256×8` 块打包成连续的窄面板，一次打包后供下方所有行块复用，期望降低大步长访问引起的缓存及地址转换开销。此判断是待验证假设，不是性能结论。

- 在 `solve_blocked` 进入并行区前分配共享打包区：`ceil(n/8)×256×8` 个 double；n=512 时约 1 MiB。
- 每轮对角块求解结束后，按 8 列面板分工打包，尾列补零；原有求解 barrier 保证输入就绪，新增打包 barrier 保证所有消费者可见。
- `update4x8` 分开传入 X 步长与 C 步长，X 步长从 ldb 变成 8；写回 B 的步长仍为 ldb。标量尾部使用相同打包输入。
- 分配失败时继续原来的大步长读取，分块循环和每个点积的累计次序不变。最终释放共享打包区。
- 小工作集 `solve_panel`、64 MiB 算法选择预算、256/64 分块和 4×8 内核形状均不改变；官方 benchmark、run.sh 和兼容头未修改。

可能的代价是每个对角块新增一次并行 barrier、复制量和共享区访问，实际收益必须由鲲鹏测量决定。此轮不同时调整块尺寸、调度策略或精度。

## 源码身份与创建命令

```text
T0 trsm.c SHA-256:
6b66766196b2a6024fcbbeac45ff1b4189e19cc8ac8d75d001e4ddfea004abac
T1-panel trsm.c SHA-256:
fea6ee11cce8785ac3f13f641f9feb195a829493a27a9c902000a743545dbf73
```

```bash
python3 tools/experiment.py new trsm T1-panel --parent T0 --strategy '大工作集分块前代每个已解256x8右端项块共享打包为连续面板，使所有下方4x8更新复用连续读取，降低跨行大步长访存；其余算法与分块不变'
```

创建时继承历史 T0，仅用于准备候选；此操作不代表已经建立当前机器基线或可以晋级。

## 本机正确性检查

环境：Apple ARM64，Apple clang 17.0.0，目标 arm64-apple-darwin25.5.0，Homebrew libomp；未计时，不输出鲲鹏性能判断。最初 ASan+UBSan 编译成功，但两个程序均无测试输出，经主 Agent 通知当前 macOS 的 ASan 初始化问题后中断，退出码均为 130。因此 ASan **未完成**；空日志分别保留为 `local/check-final-asan-incomplete.log` 和 `local/check-packed-asan-incomplete.log`，没有把它们记为通过。随后改用纯 UBSan，编译参数见下文。

复用上层现成 `check-final.c`，同时链接未改的 Z0 以满足该测试程序接口；另在候选 local 目录生成独立已知解扩展测试 `check-packed.c`，只复用现成 TRSM 测试逻辑，新增 `4095×9、4096×8、4097×9、4355×65`。覆盖阈值两侧、完整 NEON 更新、8 列尾部、64 列块边界、最后一个不足 256 行的对角块、padding 与 L 不变性。两者不修改官方测试或原 `check-final.c`。

```bash
mkdir -p .runs/trsm/T1-panel/local
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=address,undefined -fno-sanitize-recover=all -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -lomp /LOCAL_USER_HOME/Downloads/conv/other-problems/tests/check-final.c zgemm/zgemm.c .runs/trsm/T1-panel/source/trsm.c -o .runs/trsm/T1-panel/local/check-final
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=address,undefined -fno-sanitize-recover=all -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -lomp .runs/trsm/T1-panel/local/check-packed.c .runs/trsm/T1-panel/source/trsm.c -o .runs/trsm/T1-panel/local/check-packed
OMP_NUM_THREADS=1 .runs/trsm/T1-panel/local/check-final > .runs/trsm/T1-panel/local/check-final-t1.log 2>&1
OMP_NUM_THREADS=4 .runs/trsm/T1-panel/local/check-packed > .runs/trsm/T1-panel/local/check-packed-t4.log 2>&1
```

最初上面的 ASan+UBSan 两次运行被中断；以下是实际完成的 UBSan 编译与运行命令：

```bash
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -lomp /LOCAL_USER_HOME/Downloads/conv/other-problems/tests/check-final.c zgemm/zgemm.c .runs/trsm/T1-panel/source/trsm.c -o .runs/trsm/T1-panel/local/check-final-ubsan
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -lomp .runs/trsm/T1-panel/local/check-packed.c .runs/trsm/T1-panel/source/trsm.c -o .runs/trsm/T1-panel/local/check-packed-ubsan
OMP_NUM_THREADS=1 .runs/trsm/T1-panel/local/check-final-ubsan > .runs/trsm/T1-panel/local/check-final-t1.log 2>&1
OMP_NUM_THREADS=4 .runs/trsm/T1-panel/local/check-final-ubsan > .runs/trsm/T1-panel/local/check-final-t4.log 2>&1
OMP_NUM_THREADS=1 .runs/trsm/T1-panel/local/check-packed-ubsan > .runs/trsm/T1-panel/local/check-packed-t1.log 2>&1
OMP_NUM_THREADS=4 .runs/trsm/T1-panel/local/check-packed-ubsan > .runs/trsm/T1-panel/local/check-packed-t4.log 2>&1
```

|检查|线程|结果|TRSM 最大绝对误差|
|---|---:|---|---:|
|原始已知解、padding、L 不变性 7 组|1|PASS，退出 0；UBSan 无诊断|2.776e-16|
|原始已知解、padding、L 不变性 7 组|4|PASS，退出 0；UBSan 无诊断|2.776e-16|
|新增打包路径 4 组|1|PASS，退出 0；UBSan 无诊断|3.886e-16|
|新增打包路径 4 组|4|PASS，退出 0；UBSan 无诊断|3.886e-16|
|强制分配失败回退，新增 4 组|4|PASS，退出 0；UBSan 无诊断|3.886e-16|

原始检查程序附带的 270 组 ZGEMM 在 1/4 线程也均 PASS，最大误差 1.814e-14；这是链接未改 Z0 的附带检查，不代表该候选优化了 ZGEMM。正常候选共有 22 次 TRSM 用例检查，另有 4 次强制分配失败回退检查。所有检查保留 B padding，且 L 逐字节不变；精度判定仍为 1e-12。未运行服务器 sanitizer。

回退检查仅在本机编译单独测试目标，将候选的 `posix_memalign` 调用重定向到 `local/fail-alloc.c` 的测试符号；它忽略参数并返回 ENOMEM，不改候选源码。构建和运行命令：

```bash
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -Dposix_memalign=trsm_test_alloc_fail -c .runs/trsm/T1-panel/source/trsm.c -o .runs/trsm/T1-panel/local/trsm-fail-alloc.o
clang -O2 -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=undefined -L/opt/homebrew/opt/libomp/lib -lomp .runs/trsm/T1-panel/local/check-packed.c .runs/trsm/T1-panel/local/fail-alloc.c .runs/trsm/T1-panel/local/trsm-fail-alloc.o -o .runs/trsm/T1-panel/local/check-packed-fail-alloc
OMP_NUM_THREADS=4 .runs/trsm/T1-panel/local/check-packed-fail-alloc > .runs/trsm/T1-panel/local/check-packed-fail-alloc-t4.log 2>&1
```

结论：候选通过本机 UBSan 和上述数值/边界检查，具备继续鲲鹏评测的条件；没有测量或推断加速比。

## 建立候选时的鲲鹏待执行与晋级条件（历史）

以下是候选建立时的待执行计划。此次按用户指示，先核查 KML，再使用已配置且身份已确认的 OpenBLAS 静态库进行可比测量；KML 复验仍待该环境可用后另行进行。没有正式提交比赛或 Git 推送。

1. 在当前机器用不变源码建立 T0，并按仓库流程完成三轮完整官方用例；必须确认实际加载 KML 25.2.0。历史 T0 的 OpenBLAS 0.3.28、777.85 ms 不能替代这一步。
2. 候选与基线保持相同编译器、参数、CPU/NUMA、线程、参考库、TEST_RUNS 和 wrapper 重复次数。上传前保存候选实际哈希。
3. 运行 `cluster.py submit .runs/trsm/T1-panel`，保存唯一 job ID；通过 status 查询已有作业，完成后 fetch；不得因等待重复提交。
4. 核对调度成功、wrapper 退出 0、每轮全部三组 PASS，容差仍为 1e-12。保留原始环境、源码哈希与逐组日志。
5. 使用 `experiment.py record trsm T1-panel --log .runs/trsm/T1-panel/benchmark.log --environment <实际环境ID> --reference <实际KML版本及库身份> --repeats 3` 登记，再与同环境 T0 compare。按三轮逐组中位数、波动及退化决定是否晋级；结果不明确就保留 T0。

重点观察 `17024×512`，这是官方三组中使用修改路径的一组；前两组走未改的小工作集实现。不能把这一分流理解为按公开尺寸硬编码：选择仍完全基于三角矩阵工作集预算。
