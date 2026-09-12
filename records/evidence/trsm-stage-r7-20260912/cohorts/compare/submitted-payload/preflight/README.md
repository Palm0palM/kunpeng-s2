# R6 TRSM 远程预检：原面板核、packed-L 历史与分配回退

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

所有整算子用例都记录原 SVE 核与新增 packed-L 核的合计入口数，并单独记录 packed-L 核的实际与预期入口数，包括应为零的回退和不足完整块的输入。非 8-double 检查通过 Linux PR_SVE_SET_VL 在启动 OpenMP worker 前将 VL 设置为 16 bytes，再核对每个 worker 的实际 guard；无法设置或 worker 宽度不一致会以退出 2 阻止通过。原 T8 的 14 + 406 + 28 计数保持，新 packed-L 检查的额外计数见下文。每步退出码和耗时写入 summary.tsv，精确命令写入 commands.txt，输出独立日志。目标汇编单独保存，不加 instrumentation；测试目标加 instrumentation，仅用于证明代码路径，不用于测量性能。

同一个接口兼容原 T8 和无该 SVE 小核的 T9-neondirect。脚本读取源码中 `static void solve16x8_panel_sve(` 和 `static void solve16x8_panel_packedL_sve(` 的声明，自动定义 TEST_HAS_PANEL16、TEST_HAS_PACKEDL16。原核存在时保留其 14 组直接检查，新 packed-L 核存在时额外运行其 14 组；不存在的函数不会被引用。packed-L 源码必须保留原核作为回退。两个核均不存在时 MICRO_CASES=0，整算子原精度/尾部/回退检查仍完整运行，SVE 小核预期入口数为零。实际源码采用同一 T7 派生的 HWCAP/VL helper；本预检不声称对无关实现通用。

需要拷贝本目录 4 个文件：check-panel.c、guard.py、run.sh、README.md。预计每份源码构建与小测试几十秒，两个 m≈4096 用例另有约 270 MiB 峰值矩阵存储；这只是执行成本估计，实际耗时由 summary.tsv 给出。

## packed-L 签名与入口证明

已与候选作者确认的新签名为：

```c
static void solve16x8_panel_packedL_sve(
    int start, int lda, const double *L, double *x,
    const double *packed_history);
```

`L` 指当前完整 16 行块首行及原列 0；`x` 以 RHS 面板行 0 为原点。历史 `k<start` 的系数是 `packed_history[k*16+r]`，块内项及对角仍来自原 L。`__cyg_profile_func_enter` 用原子计数记录新旧合计 `panel_entries`，并以 `packed_panel_entries` 单独记录新核。

正常 SVE8 小路径中，每个 RHS 面板合计入口为 `floor(m/16)`；完整块第 0 块始终使用旧核。共享历史分配成功且 m>=32 时，新核入口为每面板 `floor(m/16)-1`。窄 VL、屏蔽 SVE、X 分配失败、新核不存在或 m<32 时，检查新核入口为 0。共享历史失败但 X 成功时，检查全部完整块使用原 SVE 核。各调用前重置所有原子计数；no-op 也必须不进入微核或注入分配器。

新增的 14 组直接检查使用原有 7 个 start × 2 个 lda padding，在独立、带前后保护的数组中从原 L 构造 `history[k*16+r]`，然后直接调用新签名。参考仍从原 L 独立做递增 k 的显式 fma。逐字节检查整个 X（含已解前缀、前后保护）、整个 L、整个历史数组（含保护）不被意外修改，且合计入口恰好 1、新核入口恰好 1。start=0 时历史有效区为空，仍保留保护区。原核的 14 组另检查新核入口为 0；与顺序 FMA 参考逐位相同不代表与历史非融合块内运算逐位相同。

## 仅共享历史分配失败

仅含 packed-L 新核的源码构建 `TEST_SHARED_ALLOC_FAIL`，与原 `TEST_ALLOC_FAIL` 互斥；原全部分配失败目标保持原样运行。新包装器在候选每次 l_trsm 的首次 posix_memalign 注入一次 ENOMEM，其余调用转发真实分配器。测试 fixture 不受包装器影响。每次 l_trsm 前重置总分配调用、注入失败和后续成功的原子计数。

该目标只接受正常 SVE8 下的 `shared-fail` 模式，专用尺寸 m=32/33/63/64/65/255/256/257、n=1/7/8/9/17，共 40 组，分别用 1 和 4 线程执行。因此首个对齐分配确定是小路径的共享历史，避免误把 m<32 的 X 首分配称为共享分配。没有增加 4097 等大型边界重复。

每例都要求恰好一次注入失败，首次分配的 alignment=64、字节数为 `128*floor(m/16)*(floor(m/16)-1)*sizeof(double)`，且 `omp_get_level()==0`（进入 worker 分配前），共同证明失败的是共享历史；至少一次后续分配且全部成功，packed-L 新核入口为 0，旧 SVE 核入口等于完整预期合计。原 long-double 构造的非 dyadic RHS、1e-12 精度、L 不变和 B padding 检查同时保留。逐例 `SHARED_ALLOC_PASS` 保存总调用数、注入次数、shared_first 证明和后续 X 成功数。两进程共新增 80 组整算子和 8 组 no-op。

## 完成计数

run.sh 最后在计算节点解析每份真实 PASS 汇总、逐用例行数和注入证据后生成 completion.txt。任一步失败、记录缺失或数量不符均不生成成功标记；不单凭预设数量宣称完成。

| 源码能力 | 原直接微核 | packed 直接微核 | 整算子 | no-op | 其中仅共享分配失败 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 原 T8 SVE16 | 14 | 0 | 406 | 28 | 0 |
| T9 packed-L | 14 | 14 | 486 | 36 | 80 |
| 无上述 SVE 小核，例如 T9-neondirect | 0 | 0 | 406 | 28 | 0 |

MICRO_CASES 为两种直接微核数之和，另保存 OLD_MICRO_CASES、PACKED_MICRO_CASES、SHARED_FAIL_CASES。官方三套件 benchmark 仍由父 cohort 在别处原样执行。本次只修改本目录 check-panel.c、run.sh、README.md；guard.py、r5 和已冻结的 r6 baseline payload 不变。准备阶段未在本机编译或运行题目，未计算或验证哈希。
