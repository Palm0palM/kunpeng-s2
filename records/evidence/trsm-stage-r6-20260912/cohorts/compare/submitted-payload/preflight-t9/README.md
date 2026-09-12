# T9 小路径与 T7 数值对照预检

本目录只准备了远程测试源码与脚本，未在本机编译或运行。复制的 `guard.py` 来自 r5 预检；本机仅可做编辑和静态检查。

接口：

```bash
TRSM_SCHEDULER_JOB_ID="$JOB_ID" CC=gcc bash preflight-t9/run.sh /absolute/T7/source /absolute/T9/source /absolute/output
```

`TRSM_SCHEDULER_JOB_ID` 必须是已分配作业的真实 ID，不能为空；仅设置变量不代表已获得分配。脚本先检查 Linux aarch64、恰好 38 个允许 CPU、单 NUMA，再在该分配中以一个实际 OpenMP worker 运行数值对照。编译器与运行库继承父 wrapper 的 GCC 12.3.1 环境；不链接 BLAS，不修改官方 benchmark、runner 或候选源码。输出可使用现有目录，但发现 `summary.tsv` 会拒绝重跑；失败重试请另用新目录。

将两份源文件分别通过 `-Dl_trsm=trsm_t7_reference` 与 `-Dl_trsm=trsm_t9_candidate` 编译到独立对象，再与同一测试程序链接。T7 是 T9 设计与数值舍入的参考，性能晋级仍必须对照当前最佳 T8-svepanel16，本测试不提供性能结论。

完整对照共 15 个 m × 7 个 n = **105 组**：

- m 为 1–9、15、16、17、255、256、257。
- n 为 1、7、8、9、15、16、17。
- 每组 lda=m+3、ldb=n+7，L 上三角及 padding、B padding 均填有限哨兵。非 dyadic 的三角矩阵与已知解通过 long double 累加构造右端项；两实现获得独立的 L 和 B 副本。
- 每组检查所有输出是有限值，并逐元素做数值相等及原始 double 字节相等检查；105 组共比较 **62853 个输出位置**，调用求解 **210 次**。逐位差异独立于容差记录，任何差异都会失败，不预先声称已相同。
- 每个实现分别核对已知解绝对误差以及 `|L×output−input|` 的 long-double 绝对残差，阈值均为 **1e-12**；完整 L（包括 padding）及 B padding 必须逐字节保持。没有放宽官方容差，也不替代完整官方 benchmark。

不在这里重复 r5 一般边界、分配失败、非 SVE、窄 VL 或多线程预检；父 wrapper 另行覆盖这些集成路径。本测试没有使用 sanitizer。

每组打印 `CASE_PASS` 或 `CASE_FAIL`、尺寸、比较数量、数值/逐位差异数、两实现误差/残差、padding 和 L 状态。对照程序只有在完整 105 组、62853 个输出检查全部通过后才返回 0 并打印完整标记；脚本还核验该标记，不把编译成功当作检查通过。各步骤的精确命令保存到 `commands.txt`，逐步退出码与实际秒数保存到 `summary.tsv`，程序输出保存到 `numeric-t1.log`，最终脚本退出码保存到 `exit-code.txt`；`completion.txt` 仅在运行及完整标记检查成功后创建。guard、编译、环境和失败日志也保存。

`trsm-t9.s` 使用同样的 `-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=${CPU_TARGET:-generic}` 输出，不添加 instrumentation。后续人工结合 `panel_solve4x8_neon` 或内联后的 `solve_panel` OpenMP worker 汇编检查：历史递增 k 的 16 条累加链继续使用 `fmla`；四行内部的 q 贡献保持独立 `fmul` 后 `fadd`；最后执行减法和除法；关注是否仍有 sums 数组写出/重读、热循环 spill 或额外寄存器保存。脚本不会用简单指令数量自动宣称舍入顺序正确，也不会把生成汇编当作汇编审查通过；成功结束仍明确留下 `assembly-review-required.txt`。

需要传输本目录四个文件：`guard.py`、`check-t7-t9.c`、`run.sh`、`README.md`。没有新算或验证任何源码哈希。
