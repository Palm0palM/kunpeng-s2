# TRSM 提交压缩包：T4-sve8rows

[下载 trsm-best.zip](../outputs/trsm-best.zip)。包内顶层目录为 `trsm/`，含 `trsm.c`、未改动的 `bench_trsm.c`、`run.sh`、`compat/kblas.h` 和中文 README；不包含二进制、参考库、实验候选、账号或连接配置。

该包采用已晋级的 **T4-sve8rows**。同分配三轮对照相较此前最佳 T3，合计耗时减少 **3.51%**，大用例减少 **6.97%**，详见[优化记录](trsm-sve8rows-20260911.md)。

## 最终 ZIP 解压复跑

作业 **1507701** 将最终 ZIP 上传至独立目录，在调度分配的计算节点解压，直接使用包内 `run.sh` 编译并运行三轮完整官方套件；9/9 PASS，最大误差 1.11e-15，调度状态 SUCCEEDED，jobExitCode、systemExitCode 与 wrapper 退出码均为 0。

|M×N|三轮耗时 ms|中位数 ms|最大误差|
|---|---|---:|---:|
|512×19968|22.39 / 22.59 / 22.77|22.59|1.67e-16|
|2432×17024|253.97 / 259.59 / 253.08|253.97|2.22e-16|
|17024×512|244.39 / 243.14 / 243.71|243.71|1.11e-15|

每个样本是 TEST_RUNS=3 的平均值，独立三轮后再取中位数。合计 520.27 ms；该单版本复跑用于验证交付包，不以它取代同分配 A/B 对照成绩，也不将合计称为官方分数。

环境：同一鲲鹏计算节点、NUMA 3、CPU 114–151、38 线程、GCC 10.3.1，`-O3 -ffp-contract=off -fopenmp -mcpu=generic`，OMP_DYNAMIC=FALSE、close/cores 绑定。参考库为 **OpenBLAS 0.3.28 静态库**，实际查询 38 线程。官方模块根目录、kblas.h 和 -lkblas 检查仍未成功，**这不是官方 KML 25.2.0 复验**。

## 使用

解压 ZIP，在申请好的 38 核单 NUMA 鲲鹏计算节点进入 `trsm/`。官方 KML 环境按下列命令执行；不要在本机或登录节点运行测试：

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

只在明确使用兼容参考库的复现环境中设置 `KBLAS_LIB=/absolute/path/to/libopenblas.a`，不能把这类结果记为官方 KML 验证。正式比赛平台的上传由用户完成，本任务只将交付文件发布到 GitHub。

清单及状态见 [trsm-best.json](../outputs/trsm-best.json)，原始复跑日志、环境、调度状态、运行脚本的公开脱敏副本见 `records/evidence/trsm-package-20260911/`；未脱敏原件本地保留。此次没有额外计算或验证哈希，没有执行本机编译或测试。上传复跑后压缩包内容未再改变。
