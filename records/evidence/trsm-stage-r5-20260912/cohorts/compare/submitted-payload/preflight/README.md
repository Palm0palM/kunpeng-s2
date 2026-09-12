# T8 远程预检（未在本机编译或运行）

父 wrapper 在调度分配的 Linux aarch64 计算节点，以恰好 38 CPU、单 NUMA 绑定运行：

```bash
TRSM_SCHEDULER_JOB_ID="$JOB_ID" CC=gcc bash preflight/run.sh /absolute/T8-svepanel16/source/ /absolute/preflight-results/
```

`TRSM_SCHEDULER_JOB_ID` 可替换为调度器真实 ID；已有 `SLURM_JOB_ID`、`LSB_JOBID`、`CCS_JOB_ID` 或 `JOB_ID` 时可不显式传入。不能以此变量伪造分配；父 wrapper 负责实际提交与绑定。输出目录可以事先存在，但不能包含本脚本创建过的 summary.tsv；失败重试应使用新目录。测试不链接 BLAS，继承父 wrapper 已选择的 GCC12 和运行库，不修改官方 benchmark、runner 或候选源码。

- 直接 SVE 核：7 个 start × 2 个 lda padding，共 14 组；递增顺序显式 fma 参考逐字节比较，检查前缀、边界保护、L 不变和恰好一次实际入口。
- 整算子 full：16 个 m × 5 个 n，共 80 组非 dyadic 输入；long-double 构造右端项，原 1e-12 绝对误差，L 不变及 B padding。正常 1/4 线程、屏蔽 SVE 4 线程、分配失败 4 线程、实际 16-byte VL 4 线程，共 400 组。
- 正常 38 线程 smoke：4 组，含 40 个 RHS 面板，让每个 worker 有任务。
- 算法分派：正常 1 线程，4095×9 与 4097×9，共 2 组。未改变的大路径只在此做少量覆盖，不对失败/屏蔽 SVE 重复大型检查。
- 每次整算子进程另做 4 组非正维度 no-op；7 次进程共 28 组。

所有整算子用例都记录新核的实际与预期入口数，包括应为零的回退和小于 16 行输入。非 8-double 检查通过 Linux PR_SVE_SET_VL 在启动 OpenMP worker 前将 VL 设置为 16 bytes，再核对每个 worker 的实际 guard；无法设置或 worker 宽度不一致会以退出 2 阻止通过。14 + 406 + 28 是完成全部步骤后才能声称的实际预期数量。每步退出码和耗时写入 summary.tsv，精确命令写入 commands.txt，输出独立日志。目标汇编单独保存，不加 instrumentation；测试目标加 instrumentation，仅用于证明代码路径，不用于测量性能。

同一个接口兼容保留原 T7 小核的对照/outline 源码。脚本读取源码中 `static void solve16x8_panel_sve(` 的声明，只有存在该核时才构建其入口计数引用、运行 14 组直接微核检查；不存在时 MICRO_CASES=0，整算子原精度/尾部/回退检查仍完整运行，新核预期入口数为零。实际源码采用同一 T7 派生的 HWCAP/VL helper；本预检不声称对无关实现通用。

需要拷贝本目录 4 个文件：check-panel.c、guard.py、run.sh、README.md。预计每份源码构建与小测试几十秒，两个 m≈4096 用例另有约 270 MiB 峰值矩阵存储；这只是执行成本估计，实际耗时由 summary.tsv 给出。
