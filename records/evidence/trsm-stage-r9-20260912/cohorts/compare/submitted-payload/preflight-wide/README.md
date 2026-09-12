# R8 TRSM 8×16 更新核补充预检

本目录仅用于 T11 `update8x16_sve` 的正确性与实际入口检查。父 wrapper 在调度分配的 Linux aarch64 计算节点、38 CPU 单 NUMA 绑定下调用：

```bash
TRSM_SCHEDULER_JOB_ID="$JOB_ID" CC=gcc bash preflight-wide/run.sh /absolute/T11-sve8x16/source/ /absolute/preflight-wide-results/
```

`guard.py` 原样复用 r7：要求真实调度器作业 ID、恰好 38 个允许 CPU、单 NUMA。设置作业 ID 变量不能代替调度分配与绑定。支持环境已有的 `SLURM_JOB_ID`、`LSB_JOBID`、`CCS_JOB_ID` 或 `JOB_ID`。输出目录不能已有 `summary.tsv` 或 `completion.txt`；失败重试用新目录。

父 wrapper 负责选择与 r8 cohort 相同的 GCC12 和运行库。编译统一使用 `-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic`；测试目标另加 `-finstrument-functions` 和指向传入候选的 `TRSM_SOURCE`。构建正常、`TEST_NO_SVE`、`TEST_SHARED_ALLOC_FAIL` 三个目标，不链接 BLAS、不修改候选文件。`trsm-wide8x16.s` 是不加 instrumentation 的目标汇编。入口计数测试不用于性能测量。

| label | threads | CLI | whole cases |
| --- | ---: | --- | ---: |
| micro-t1 | 1 | micro | 0（28 组直接核） |
| normal-t1 | 1 | full | 2 |
| normal-t4 | 4 | full | 2 |
| normal-t38 | 38 | smoke | 1 |
| shared-fail-t4 | 4 | smoke | 1 |
| no-sve-t4 | 4 | smoke | 1 |
| narrow-vl-t4 | 4 | --narrow-vl smoke | 1 |

直接核使用 count=0/1/2/7/31/255/256、lda=count+3/count+11、packed/strided 两种 X 布局，共 28 组。对应 C ldc=23/27；strided X ldx=31/33。用独立一般非 dyadic L/X 数据、递增 k 的显式 FMA 顺序参考逐位检查 C，核对完整 L/X、padding 与前后 guards 不变，每组新核入口恰好一次。

`full` 包含 4105×25、4111×31，`smoke` 仅 4105×25；分别覆盖完整 16 列更新、8 列与窄列尾部，以及 8 行、4 行和更窄行尾。实际 L 为稠密结构下三角，独立 lda=m+3、ldb=n+7；以 long-double 前缀和构造已知解右端项并检查残差，降低补充大尺寸 fixture 的准备成本。逐例检查解误差和残差均为有限值且不超过 1e-12，L 和 B padding 保持。

每个进程记录所有 worker 的实际 `DISPATCH`。正常与共享 packed 分配失败要求 HWCAP SVE 且所有 worker 的 VL=64 bytes；屏蔽 SVE 要求有效注入 hwcap_sve=0、所有 worker 的真实 VL=64 bytes、新核零入口。窄 VL 在 OpenMP worker 启动前通过 Linux `PR_SVE_SET_VL` 实际设置 16 bytes，要求 `NARROW_VL_PASS requested=16 actual=16`、所有 worker 均为 16 bytes、新核零入口；不支持时失败，不 skip。共享 packed 分配失败必须另有 `SHARED_ALLOC_PASS calls=1 injected=1`，并仍从原 B 的 strided X 进入新核。

`run.sh` 的最终解析独立按每个 KB=256 块后完整 8 行与完整 16 列的数量求和：`sum(floor((m-min(kk+256,m))/8)*floor(n/16))`。它逐例比对声明的预期入口和实际入口；同时核对精确用例身份、线程数、28 组直接核覆盖、每个汇总、DISPATCH、注入与窄 VL 证据及所有步骤的退出码。仅全部满足时生成：

```text
TRSM_WIDE_PREFLIGHT_COMPLETE=1 MICRO_CASES=28 WHOLE_CASES=8 SHARED_FAIL_CASES=1 NO_SVE_CASES=1 NARROW_VL_CASES=1
```

每步日志单独保存，`summary.tsv` 保存 label/exit_code/elapsed_seconds，`commands.txt` 保存 shell 转义后的实际命令，`guard.json` 保存资源检查结果。最后的 `verify-results.log` 保存解析结论；任一步失败立即停止并保留此前日志，不能把编译成功、退出 0 或缺失记录当作正确性通过。

父 cohort 仍需另行完整执行既有 r7 一般非 dyadic 边界预检、原官方 benchmark warm-up 及三套计时 AB/BA/AB；本结构化大尺寸检查不能替代它们。部署时携带本目录 `check-wide.c`、`guard.py`、`run.sh`、`README.md` 四个文件。准备阶段仅进行文本编辑及 Bash/Python 语法检查，未在本机编译或运行题目，未联网、提交作业或计算/验证哈希。
