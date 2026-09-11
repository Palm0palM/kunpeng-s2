# T3-sveupdate：实现与本机检查

2026-09-09。候选只改 `../source/trsm.c`。没有登记、晋级、计算新哈希、修改主源码或执行远程操作。

## 单一假设与实现

只把大工作集路径的完整 4×8 更新微核增加为 512-bit SVE 分派：每个 k 用一次 8-double RHS 向量加载和四次向量 FMA，替代原 NEON 的四次 RHS 加载和十六次向量 FMA。每个输出仍从 +0 按 k 递增执行 FMA，最后单独执行一次 C-sum 减法。

SVE 代码只在 Linux、AArch64、非 Clang、GCC 10 及以上编译，使用 `target("arch=armv8-a+sve")` 与 `noinline` 隔离。`solve_blocked` 先读取 `HWCAP_SVE`；每个 OpenMP worker 仅在 HWCAP 允许后调用目标函数 `trsm_sve_has_eight_doubles()`，只有当前线程 `svcntd()==8` 才调用 `update4x8_sve`。其他平台、编译器、硬件或向量宽度继续执行原 NEON/标量路径。未更改系统或线程的 SVE 向量长度。

RHS=8、ROWS=4、KB=256、CT=64、64 MiB 算法切换阈值、面板布局与打包屏障均不变。只有 rows=4 且 cols=8 进入新微核；尾行尾列仍用原逻辑。SVE 保留独立的 ldx/ldc，因此打包成功 ldx=8 和分配失败 ldx=ldb 都有效，且没有增加分配。

字节比较确认 `run.sh`、`bench_trsm.c`、README、兼容头、小路径和原 NEON update4x8 均保持一致，结果见 [static-invariants.txt](static-invariants.txt)。源码差异见 [source-vs-T1-panel.diff](source-vs-T1-panel.diff)。该检查未计算哈希。

## 已完成检查

平台为 Darwin arm64、Apple Clang 17.0.0，编译使用 `-O2 -std=c11 -fno-fast-math -ffp-contract=off`、UBSan 和 Homebrew libomp。全部构建及测试退出码为 0，无 UBSan 诊断；环境、完整 argv、线程环境覆盖和日志名保存在 [commands-results.json](commands-results.json)。这次本机唯一测试进程在用户要求停止本机测试的指令到达前已经退出，此后未启动新的本机编译或测试；没有待终止的本机测试，也没有中断后被当作通过的测试。

|检查|实际结果|
|---|---|
|[直接 NEON 微核](check-update.log)|275 组 PASS，与按 k 顺序 scalar fma 逐位相同；count=0/1/2/3/7/31/63/127/255/256/257，ldx 和 ldc 分别独立遍历 8/9/17/65/512，输入与输出 padding 不变|
|[TRSM 1 线程](check-trsm-t1.log)|10 组已知解及 4 个 no-op 边界 PASS，最大绝对误差 4.441e-16；L 与 padding 不变|
|[TRSM 4 线程](check-trsm-t4.log)|相同 14 组 PASS，最大绝对误差 4.441e-16|
|[强制分配失败、4 线程](check-trsm-fail-alloc-t4.log)|相同 14 组 PASS，最大绝对误差 4.441e-16；同时覆盖小路径与大路径回退|
|SVE 微核|实际执行 0 组；尚未在 Linux GCC 编译或实机执行|

已知解尺寸为 1×1、3×7、4×8、5×9、65×17、257×1、4095×9、4096×8、4097×9、4355×65；另含 m/n 为 0 或 -1 的四个直接返回检查。已知解测试不链接 BLAS 或 ZGEMM，生成 B 后以预先确定的 X 检查结果。测试源码为 [check-trsm.c](check-trsm.c)，可直接在 Linux GCC 编译。SVE 未执行，所以这些结果只说明本机 NEON 回退与候选分派被编译排除时的行为；它们不能证明 SVE 正确性、官方 benchmark 通过或鲲鹏提速。

## 服务器待执行

以下为保留的待执行命令，没有在本机或超算执行。工作目录为此 `local/`；运行时须处于调度器实际分配内并由上层编排固定 CPU/NUMA 和线程数。用户已要求后续编译与测试均在超算运行。

```sh
gcc -O3 -std=c11 -D_POSIX_C_SOURCE=200112L -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check-update.c -lm -o check-update-linux
./check-update-linux
gcc -O3 -std=c11 -D_POSIX_C_SOURCE=200112L -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check-trsm.c ../source/trsm.c -lm -o check-trsm-linux
OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE ./check-trsm-linux
gcc -O3 -std=c11 -D_POSIX_C_SOURCE=200112L -Dposix_memalign=trsm_test_alloc_fail -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -c ../source/trsm.c -o trsm-fail-alloc-linux.o
gcc -O3 -std=c11 -D_POSIX_C_SOURCE=200112L -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check-trsm.c fail-alloc.c trsm-fail-alloc-linux.o -lm -o check-trsm-fail-alloc-linux
OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE ./check-trsm-fail-alloc-linux
```

直接微核测试会明确打印 SVE 实际执行组数；非 512-bit SVE 或没有 SVE 时打印 0，不能记为 SVE 验证通过。还需 Linux GCC 构建、实际目标函数入口与线程宽度检查、SVE 对 NEON 有序 FMA 对照、已知解及分配失败检查，以及官方 benchmark 三轮完整同环境比较。官方参考库条件由主任务如实记录；本候选没有进行 KML 或 OpenBLAS 官方套件复验。

## 静态风险与边界

新微核保留每个输出的原 FMA 依赖顺序，没有 k 展开、跨 k reduction、乘减融合或 fast-math。完整八列才能加载/写回一个 SVE 向量，且分派已检查当前 worker 宽度；代码本身不会修改线程向量长度。头文件和目标属性在本机被编译护栏排除，Linux GCC 10 的实际兼容性仍待超算构建确认。

性能收益尚无实测。新微核只有四条 SVE 累加链，原 NEON 有十六条链；若机器的向量 FMA 延迟或吞吐需要更多独立指令，新写法可能不能充分隐藏依赖延迟。目标函数调用与运行时分派也有成本，打包、对角块求解和 barrier 的时间不会减少。本轮保持这些因素不变，以同环境完整用例测量决定是否采用。
