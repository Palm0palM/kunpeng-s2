# R14 共享历史预算与分配回退预检

本目录从 r13 的 packed-L-aware preflight 复制，保留全部直接微核、一般非 dyadic 整算子、no-op、4095/4097 分派边界与两类分配失败检查，增加 4 MiB 预算边界的实际分配观察。仅在调度分配的 Linux aarch64、38 CPU、单 NUMA 计算节点执行：

```bash
TRSM_SCHEDULER_JOB_ID="$JOB_ID" CC=gcc bash preflight/run.sh /absolute/candidate/source/ /absolute/new-output/
```

接口仍为两个绝对路径参数。guard.py 原样复用 r13；父 wrapper 负责真实调度与绑定。输出目录不得已有 summary.tsv，失败重试使用新目录。所有编译与测试均在 guard 通过后。测试 flags 为 `-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic -finstrument-functions`；构建 normal、no-SVE、全部分配失败、仅 worker X 失败四个目标，packed-L 源码另构建仅共享历史失败目标。原源码不修改，目标汇编不加 instrumentation；这些预检不提供性能结论。

runner 从源码检测 solve16x8_panel_sve、solve16x8_panel_packedL_sve、TRSM_PACKED_HISTORY_BUDGET_BYTES。带预算源码在 include 后静态断言真实常量为 4 MiB；预算必须同时有 packed-L 和旧核。每个进程输出一条 SOURCE_FEATURES_PASS，parser 精确核对。

JSON 的 source_features 包含 has_panel16、has_packed_history、has_history_budget 三个布尔字段；history_budget_bytes 对 T8 无 packed 为 null，对 T10 无预算为 0（unlimited），对 T17/T18 为 4194304。预算只限制 packed_history，不改变原 64 MiB 算法分派阈值。

实际 history bytes=`1024*b*(b-1)`，b=floor(m/16)。最大预算内 b=64，m=1039 仍允许，m=1040 起禁止；不足16行尾部不增加共享历史。新增 fixture 仍采用独立一般非 dyadic L、long-double RHS、原 1e-12 精度和 L/B padding 检查。

| 新增 label | 线程 | 尺寸 | 注入 |
| --- | ---: | --- | --- |
| budget-t1 | 1 | m=1023/1024/1039/1040/1041，n=9 | 无 |
| budget-t4 | 4 | 同上 | 无 |
| budget-t38 | 38 | 1039×313、1040×313 | 无 |
| budget-x-fail-t4 | 4 | 五个 m，n=9 | 所有 worker X 失败 |
| budget-no-sve-t4 | 4 | 五个 m，n=9 | 屏蔽 HWCAP SVE |
| budget-narrow-vl-t4 | 4 | 五个 m，n=9 | 实际 VL=16 bytes |
| budget-shared-fail-t4（仅 packed） | 4 | 五个 m，n=9 | 实际发生的共享历史分配失败 |

38 线程两例各有40个 RHS 面板，覆盖门槛两侧。每个整算子进程仍追加原4个 no-op。T8 新增27个 whole；packed 成员新增32个。原 shared-fail-t1/t4 各40例、m=32..257 保留。预算 shared-fail 对 T10 五例各注入一次，对 T17/T18 仅前三例注入；后两例必须证明 history 调用零次且所有 X 成功。

分配 wrapper 只在 include 候选期间宏替换 posix_memalign，随后 undef，fixture 和真实分配器不受递归包装。所有候选分配都观察调用数、请求字节总和、成功/失败与 omp_get_level。用独立原 64 MiB 三角工作集条件判别路径后，level0 在小路径归 shared history，在大路径归 RHS KB；level1 归 worker X。检查 alignment=64、精确 bytes/层级，并逐 worker 要求 X 恰好一次；1线程 serialized parallel region 的 level 仍为1。

每例 ALLOC_PASS 保存 m/n、small、history_expected；history/x/kb 各自的 calls/bytes/success/fail/level；total、injected、shape_bad=0、x_each_worker_once=1。bytes 是所有实际调用的请求字节总和，不等于成功分配量。无调用的 level=-1，history/KB 实际 level=0，X=1。parser 独立重算完整字段字典并比对实际核入口；预算外必须 history_calls/history_bytes=0、history_level=-1，不能仅以 packed 入口零次冒充未分配。4095×9 的预算成员要求 packed_entries=0、old_entries=510；4097×9 的根层级分配归 KB RHS，不能误记 history。

窄 VL 只关闭 SVE 核，源码 history 分配仍仅受 HWCAP 与预算限制；所以预算内 narrow-VL 和仅 X 失败仍有共享分配成功，但新旧 SVE 核入口为0。no-SVE 才关闭共享分配。全部分配失败保持全部注入；仅 history 失败保持 X 正常，超预算时注入0次。所有原微核用例保持不变。

| 特征 | micro | whole/ALLOCATION_CASES | no-op | SHARED_FAIL_CASES | BUDGET_CASES | BUDGET_SHARED_INJECTIONS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| T8，无 packed | 14 | 433 | 52 | 0 | 27 | 0 |
| T10，packed unlimited | 28 | 518 | 64 | 85 | 32 | 5 |
| T17/T18，packed 4 MiB | 28 | 518 | 64 | 83 | 32 | 3 |

SHARED_FAIL_CASES 仅统计 shared-only 目标中实际注入的一例一次失败，不含全部分配失败目标。completion.txt 字段顺序固定：

```text
TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES=... WHOLE_CASES=... NOOP_CASES=... OLD_MICRO_CASES=14 PACKED_MICRO_CASES=... SHARED_FAIL_CASES=... ALLOCATION_CASES=... BUDGET_CASES=... BUDGET_SHARED_INJECTIONS=...
```

summary.json schema 为 trsm-r14-preflight-v1，字段为 complete、source_features、micro_cases、old_micro_cases、packed_micro_cases、whole_cases、noop_cases、shared_fail_cases、allocation_checked_cases、budget_cases、budget_shared_injections、process_count、max_error、processes。process_count 含 micro 进程（T8=14，packed=18）。processes 仅列 whole 进程，每项保存 label、threads、whole_cases、noop_cases、allocation_checked_cases、budget_cases、shared_fail_cases、max_error。

budget-summary.json schema 为 trsm-packed-history-budget-v1，字段为 complete、source_features、budget_cases、budget_processes（T8=6，packed=7）、budget_shared_injections、budget_x_fail_cases=5、budget_no_sve_cases=5、budget_narrow_vl_cases=5、allocation_rows。allocation_rows 依顺序保存全部新增 ALLOC_PASS 字段，再加 label、threads、injection（none/x/no-sve/shared）、narrow_vl、old_entries、packed_entries。

summary.tsv 保存每步退出码/耗时，commands.txt 保存精确命令，各日志独立。最终 verify-results 核对所有预期步骤退出0、每个源码feature与MODE/线程、完整逐例身份、实际分配、新旧核入口、micro汇总、有限且≤1e-12误差、no-op及精确合计后，才创建两个 JSON 和 completion.txt。成功时 summary.tsv 共22行步骤（T8）或27行（packed），不含表头；最终一行是 verify-results。

准备阶段仅轻量编辑、Bash/Python 语法检查与整数推导；未本机编译或运行候选、SSH、prepare/submit、计算/验证哈希。T18 大路径新宽核由父任务独立 wide32 模块验证。
