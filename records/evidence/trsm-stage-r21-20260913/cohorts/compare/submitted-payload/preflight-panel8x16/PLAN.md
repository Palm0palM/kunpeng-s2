# T19 专用预检计划

状态：仅准备，尚未编译或执行。所有题目编译、直接核、整算子与汇编生成必须在调度分配的 Linux aarch64、38 CPU、单 NUMA 计算节点通过 guard 后进行。本目录不触发 prepare/submit/record/promote；root 负责 cohort 整合。

采用 r14 的通用预检作为基础，完整保留原 normal、smoke、boundary、预算、no-SVE、窄 VL、全部分配失败、X-only 与 shared-only 模式。T19 不能交给未修改的 r14 audit_general：预算外的 scratch 字节数与核入口公式都已改变。专用模块输出独立 schema 和完成标记，由 root 按成员区分审计。

已与候选作者确认的接口：

- `solve8x16_panel_sve(int start,int lda,const double *L,double *x0,double *x1)`；L 是当前 8 行首行的原列 0，x0/x1 是各面板全局行 0，RHS 保持 8，x1=x0+m*8。
- 安全计算的 history bytes 超过 4 MiB 且有 SVE 才进入 `solve_panel_wide8x16`；窄 VL 仍进入 wrapper，但每 worker 的 VL8 门禁禁止新 SVE 核。无 SVE 继续原路径。
- wrapper 每 worker 在 OpenMP level 1 只分配一次 `m*16*sizeof(double)`、64 字节对齐的 scratch，布局 `[2][m][8]`。失败仅处理该 worker 的任务并直接回退，不再次分配另一份 X。
- 每完整 16 列任务每 8 行调用新核；不足 16 列按 RHS8 面板使用原 16 行核及 4 行/标量尾；完整 16 列的 m%8 尾逐面板使用原尾处理。窄 VL 不执行两种 SVE 核。

独立观测契约：每个整算子 case 同时记录 wrapper 次数、旧 16×8、packed 16×8、新 8×16 次数，以及 history/X/KB 的请求次数、字节、成功/失败、OpenMP 层级、每 worker X 次数。预算外正常完整列的新核期望为 `floor(n/16)*floor(m/8)`；余列旧核期望为 `ceil((n%16)/8)*floor(m/16)`；预算内保持既有旧/packed 公式。no-SVE、窄 VL、X/all 失败按实际门禁分别推导，不能把零核入口解释为零分配。

仅预检副本 `instrumented-trsm.c` 在新核首行调用参数观察 hook，核对当前 worker 的真实 scratch 基址、x1-x0=m*8、L 当前行首、lda 与 start 范围。原候选不改；`trsm-panel8x16.s` 从原候选源码生成，不带分配/参数/入口插桩。直接微核 fixture 使用同一双面板布局，按递增 k 的零基 FMA、单次减法和除法独立构造 bitwise 参考，并检查前缀、尾部、L 不变。

最小新增覆盖固定如下，不增加无关测试：

1. 保留原 518 个整算子、64 个 no-op、32 个预算组、28 个旧/packed 直接核。
2. 新直接核 start=0/1/7/8/9/15/16/255/256，各 lda padding=1/7，共 18 例。
3. m=1039/1040 × n=15/16/17/31/32/33 共 12 个形状；1/4/38 线程正常各一遍，4 线程 no-SVE、窄 VL、shared-only、X-only、all-alloc-fail 各一遍，共 8 过程、96 例。所有过程仍检查原 1e-12、padding、L 只读与真实精确入口。
4. 运行前核对最终实现发现：继承的 1041×9/4095×9 都是不足 16 列，不能覆盖新核后的行尾，而 1040 整除 8。root 已批准只在同一 wide-normal-t38 过程追加 1047×33 一例，覆盖完整新核后的 7 行尾（NEON4+scalar3）和列尾 1；不增加进程、不改官方 benchmark，其余固定覆盖不变。

因此计划总计整算子/ALLOC 615、no-op 96、微核 46；测试过程 27（24 整算子、3 直接核），预算组仍 32。shared-only 实际失败标记预计原 83 加上新网格预算内 6 例，共 89；原预算组实际共享失败注入仍为 3。参数检查为 615 整算子加 18 直接新核，共 633 例；实际调用观察数按精确入口公式逐例汇总，不能预填结果。

计划输入为本 PLAN、check-panel.c、guard.py、run.sh、严格 parser 和 README。完成态摘要、逐原始日志、commands、TSV、guard、插桩副本与原源码汇编全部保留；缺步骤、重复标记、错误字段、错误总数、失败/阻塞或非有限误差一律不能生成成功完成态。最终文件名、字段与步骤清单将在输入冻结时交 root。
