# T19 panel8x16 专用预检

状态：准备输入，尚未执行。详见 PLAN.md 的固定覆盖及运行前追加 1047×33 的原因。此模块只用于 T19；T8/T18 仍使用原通用预检，T18/T19 大路径的 CT64 wide32 检查由 cohort 另外调度。所有题目编译与测试只允许在超算计算节点执行。

冻结输入共六个文件：PLAN.md、README.md、check-panel.c、guard.py、run.sh、audit_panel8x16.py。run.sh 内嵌唯一参数观察源码生成器；没有未列出的依赖脚本。

计算节点调用约定：`bash preflight-panel8x16/run.sh /absolute/source-dir /absolute/preflight-panel8x16-results/T19-panel8x16budget`。输出目录不得已有 summary.tsv。guard 先验证 Linux aarch64、数字调度作业号、38 个允许 CPU 和单 NUMA，才查询编译器、生成副本、编译和测试。cohort 外层仍负责将真实已提交 job ID 与调度分配对应。

`run.sh` 使用 `-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic`，测试目标另加 `-finstrument-functions`。分配包装仅在 include 候选期间有效，fixture 分配不被注入；无 SVE 用测试目标的 getauxval 包装，真实 SVE/VL 由 main 独立核查。正常、no-SVE、all-alloc-fail、X-only、shared-only 共五个构建；窄 VL 在正常目标中设置并逐 worker 验证。

参数生成器要求原文件恰好一个声明的 8×16 核，仅在其函数体开头增加 `trsm_test_wide_arguments(start,lda,L,x0,x1)`，保存为 instrumented-trsm.c。实际 allocator 返回的当前 worker scratch 基址、两面板 m×8 间距、L 行首、lda、start 范围均由 hook 检查；入口计数独立由编译器函数插桩观察。原候选不改。`trsm-panel8x16.s` 单独从原 source/trsm.c 生成，未加测试插桩；只供目标汇编审查，不能把测试目标的生成代码当作正式源码汇编。

观测期望由实际形状独立推导：

- 预算内仍为单 RHS8 X、原 16×8 与 packed-history 核；请求字节安全超过 4 MiB 且有效 HWCAP_SVE 时，wrapper 恰好进入一次，worker X 变为 m×128 字节。
- 窄 VL 仍可进入预算外 wrapper 并分配双面板，但旧/新 SVE 核均零入口；no-SVE 不进入 wrapper，仍分配 m×64 字节原 X。X/all 失败同样不进入 SVE 核，实际分配失败仍按 worker 精确记录。
- 预算外完整 16 列的新核入口为 floor(n/16)×floor(m/8)；不足 16 列原核为 ceil((n%16)/8)×floor(m/16)。packed 核为零，预算外 shared-only 注入实际为零。1039 行预算内 shared-only 仍注入历史分配失败并回到旧核。

固定完成覆盖为 615 个整算子/ALLOC、96 个 no-op、46 个直接核（旧14、packed14、新18），27 个测试过程（24 整算子、3 微核）。预算组保持32例、实际共享注入3例；总 shared-only 标记89例。新参数检查633例（615整算子，包括零入口模式，加18直接新核），调用观察总数从各精确入口公式汇总。正常新网格是1039/1040×15/16/17/31/32/33，在1/4/38线程完整覆盖；38线程过程另有1047×33，覆盖新核后的7行尾和列尾1。

所有整算子沿用独立 long double RHS、1e-12、非有限误差拒绝、B padding与L只读检查。直接新核使用两独立面板的递增 k 零基 fma 参考、单次减法和除法，要求 bitwise 相同，检查源L、各面板前缀和外侧哨兵；不能用误差统计替代其 bitwise 要求。

`audit_panel8x16.py` 的导入没有文件读写、子进程或题目执行副作用。root 可按如下接口调用：

```python
from audit_panel8x16 import audit_panel8x16
evidence = audit_panel8x16(output_directory, frozen_source_trsm_c)
```

接口只读，返回可 JSON 序列化 dict：completion、summary、budget_summary、parameters_summary、guard。它从全部原日志重新推导每个字段、形状和计数，核对37个成功步骤、三份实际 JSON 与完成标记；缺失、重复、错误字段、错误数字、FAIL/阻塞、非有限或超限误差均拒绝。还核查插桩副本与所提供冻结原源码仅相差声明的单个 hook，要求原源码汇编存在、含目标核且不含测试 hook/函数插桩符号。该关系检查是直接文本比较，不计算摘要。

run.sh 最后一个受记录步骤调用显式 `audit_panel8x16.py finalize OUTPUT ORIGINAL_SOURCE`，使用同一解析逻辑创建三份 JSON 和 completion。此 CLI 是远端预检流程的一部分；只读 import 接口不会生成结果。若 finalize 失败或 run.sh 尚未退出成功，不能仅凭已出现的部分 JSON 判为完成。

应保留的实际输出：

- summary.json（`trsm-panel8x16-preflight-v1`）、budget-summary.json（`trsm-packed-history-budget-panel8x16-v1`）、panel8x16-summary.json（`trsm-panel8x16-arguments-v1`）、completion.txt、summary.tsv、commands.txt、guard.json。
- instrumented-trsm.c（真实测试副本）、trsm-panel8x16.s（原源码目标汇编）。三份 JSON 均保留原始数字及逐行观察，归档不可重建缺失结果。
- 37 个步骤各自原 `.log`：guard/compiler/instrument-source，五个 build，assembly，三个 micro，全部继承16个整算子过程、八个新增 wide 过程、verify-results。精确顺序与名称由 run.sh 和 audit 模块共同固定。

完成标记以 `TRSM_PANEL8X16_PREFLIGHT_COMPLETE=1` 开头，包括 MICRO/WHOLE/NOOP、OLD/PACKED/WIDE_MICRO、SHARED_FAIL、ALLOCATION/BUDGET/BUDGET_SHARED_INJECTIONS、ARGUMENT_CHECKED_CASES/ARGUMENT_OBSERVATIONS/WRAPPER_CALLS。检查二进制无需公开归档。不存在的日志、汇编或成功标记不得补造；本地只做编辑与静态语法检查，不运行预检。
