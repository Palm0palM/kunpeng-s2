# R10 TRSM 4×32 更新核补充预检

从 r9 `preflight-wide` 的四个准备文件复制到本独立目录，仅用于 T13 `update4x32_sve` 的正确性、实际入口及调用参数验证。原 r9 文件、T13 源码、公共工具和 controller 均未修改。

## 调用与资源

由父 controller 在调度分配的 Linux aarch64 计算节点、38 CPU 单 NUMA 绑定内调用：

```bash
CC=/absolute/private-gcc/bin/gcc bash /absolute/preflight-wide32/run.sh /absolute/T13-sve4x32/source /absolute/preflight-wide32-results/T13-sve4x32
```

两个参数必须是绝对路径。父 controller 提供当轮实际 GCC12/KML25.1 环境及真实调度器作业 ID；guard 接受现有 `TRSM_SCHEDULER_JOB_ID`、`SLURM_JOB_ID`、`LSB_JOBID`、`CCS_JOB_ID` 或 `JOB_ID`，并检查真实 Linux aarch64、恰好 38 个允许 CPU、单 NUMA。设置作业 ID 变量不能代替调度分配。父 allocation 使用计划中的 24 GiB / 1800 秒上限。

输出必须使用新目录，已有 summary/completion 或生成副本会拒绝覆盖；失败重试使用新的目录。`guard.py` 原样复用 r9。runner 固定 `OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`；编译 flags 保持 `-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic`。

## 原源码与测试插桩边界

`run.sh` 的 `instrument-source` 步骤在输出目录创建 `instrumented-trsm.c`。生成器要求原源码中精确、唯一的八参数 `update4x32_sve` 声明，在函数体起点仅插入一行 `trsm_test_wide_arguments(ldx,panel_stride);`，并拒绝已经插桩的输入。输出使用排他新建，原候选文件只读，生成后直接字节确认输入未变化；没有哈希操作。

仅三个补充检查程序包含这个测试副本，并启用 `-finstrument-functions`。参数观察函数只读整数参数并累计原子计数，不更改 L/X/C、运算顺序或候选逻辑。独立的函数入口 hook 对 `update4x32_sve` 计数；每例要求参数观察次数等于实际入口次数，且所有观察的 ldx/panel_stride 与该例预期相同。

`assembly` 步骤始终从传入的原 `source/trsm.c` 生成无测试插桩的 `trsm-wide4x32.s`。父 controller 的官方 warm-up 和计时也必须使用原候选源码。插桩检查的代码生成、调用成本及耗时不能当作性能证据。

## 固定覆盖

直接检查 count=0/1/2/7/31/255/256、lda=count+3/count+11、packed/strided 两种 X 布局，共 28 组。L 只有四行；C 为四行×32列，ldc=39/43；strided X ldx=47/49。Packed 存四个 KB×8 面板，panel_stride=2048，ldx=8；strided 的 panel_stride=8。

L/X/C 使用一般非 dyadic 正常值。参考从完整保存的独立输入按列 j 推导 panel=j/8、lane=j%8，每输出由零开始按递增 k 执行 scalar fma，最后仅执行原 C 减 sum。整块 C 逐位对照，包括每行 padding 与前后 guards；完整 L/X 与其保存副本逐字节比较，含 padding、未使用的面板行及外部 guards。每组新核实际入口和参数观察均恰好一次。

整算子 `full` 的固定顺序为：

| m | n |
| ---: | --- |
| 4100 | 31、32、33 |
| 4105 | 63、64、65 |
| 4111 | 95、96、97 |

每例使用 lda=m+3、ldb=n+7，覆盖最后4行、8+1行、8+4+3行，以及32列边界、CT64边界、第二个CT内32列及列尾。稠密结构下三角 L 与已知解采用 r9 已验证的独立 long-double 前缀构造/残差公式，以降低 fixture 构造成本；所有解误差和残差须有限且不超过 1e-12，并保持 L 完整字节、B 每行 padding 和外部 guards。这个补充结构化参考不替代既有一般非 dyadic 通用预检或官方 benchmark。

| label | threads | mode | 整算子例数 |
| --- | ---: | --- | ---: |
| micro-t1 | 1 | micro | 0（28组直接核） |
| normal-t1 | 1 | full | 9 |
| normal-t4 | 4 | full | 9 |
| normal-t38 | 38 | smoke=4111×97 | 1 |
| shared-fail-t4 | 4 | smoke=4111×97 | 1 |
| no-sve-t4 | 4 | smoke=4111×97 | 1 |
| narrow-vl-t4 | 4 | --narrow-vl smoke=4111×97 | 1 |

合计 22 次整算子检查。C 与严格 parser 分别独立按 `sum_kk floor((m-min(kk+256,m))/4)*floor(n/32)` 核对实际入口；CT64 与 KB256 均整除4/32，不复用旧8×16公式。正常 n=31 应为零入口。

共享 packed 分配失败要求恰好一次 shape 正确的注入、实际入口仍等于非零预期、每次观察到 ldx=ldb=104 且 panel_stride=8。正常执行每次为 ldx=8/panel_stride=2048。No-SVE 使用只影响所包含候选的 HWCAP 注入，真实机器仍需具备 SVE/VL64；实际新核及参数观察均为零。窄 VL 在 worker 创建前真实设置为16 bytes，每个 worker 均核对 `PR_SVE_GET_VL` 和原 SVE 宽度 helper，实际新核及参数观察均为零；不支持时失败，不 skip。

## 日志与完成契约

`run.sh` 内嵌生成器和严格 parser，不另有 `.py` 文件。部署只需四个文件：`run.sh`、`check-wide32.c`、`guard.py`、本 `README.md`。

`summary.tsv` 字段为 `label / exit_code / elapsed_seconds`。顺序共15步：guard、compiler、instrument-source、build-normal、build-no-sve、build-fail-shared、assembly、micro-t1、normal-t1、normal-t4、normal-t38、shared-fail-t4、no-sve-t4、narrow-vl-t4、verify-results。每步有同名 `.log`；`commands.txt` 保存实际 shell 转义命令，`guard.json` 保存资源结果。

每例还输出 `ARGUMENTS_PASS calls=... bad=0 expected_ldx=... expected_panel_stride=...`。Parser 严格核对全部用例身份/顺序/数量、每步退出码、每个最终 PASS、DISPATCH、实际窄 VL、分配注入、解误差/残差和实际入口/参数计数；畸形、重复、缺失、失败标记或聚合覆盖不符均拒绝完成。

只有全部通过才生成 `summary.json`，schema 为 `trsm-wide32-preflight-v1`，包含 complete、micro_cases、whole_cases、shared_fail_cases、no_sve_cases、narrow_vl_cases、argument_checked_cases=50、argument_observations、kernel_argument_mismatches=0、test_copy_instrumented=true、original_candidate_modified=false。前述参数字段描述测试副本的实际观察；零入口案例没有调用参数样本。

随后排他新建 `completion.txt`，精确完整行如下：

```text
TRSM_WIDE32_PREFLIGHT_COMPLETE=1 MICRO_CASES=28 WHOLE_CASES=22 SHARED_FAIL_CASES=1 NO_SVE_CASES=1 NARROW_VL_CASES=1
```

父 controller 应要求 run.sh 退出0、精确完成标记和预期数量，保留全部日志、summary.json、instrumented-trsm.c 与原源码汇编。二进制 check-normal/check-no-sve/check-fail-shared 只用于计算节点检查，不必归档为文本证据。任一步失败保留已生成材料，不把编译成功或进程退出0单独当作正确性通过。

准备阶段只做文件复制/编辑、静态审查、Python AST 和 bash -n 语法检查；未在本机编译或运行题目，未联网、提交作业、计算或验证哈希。Root 独立静态审查未发现核心用例、四面板地址、入口公式或参数注入检查的具体问题；所有编译与运行结果仍待计算节点产生。
