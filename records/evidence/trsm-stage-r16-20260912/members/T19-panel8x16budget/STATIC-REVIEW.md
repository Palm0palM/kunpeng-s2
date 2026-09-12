# T19 静态自审

2026-09-12：源码准备完成，未发现当前静态自审中的具体缺陷；尚未编译或运行，不能据此宣称正确性通过。

- 直接文本还原确认：仅新增 solve8x16_panel_sve / solve_panel_wide8x16，以及 history_over_budget 声明、预算 else 置位和原 parallel 前调用三个编辑区域；去掉这些后精确恢复 T18。四份支持文件和整个 KB256/CT64 大路径后缀字节不变。
- 新核十六个零累加器，历史循环每 k 十六个显式 FMA 表达式；块内 q=0..7 有五十六个显式 FMA 表达式，十六次单独 subtract/divide/store。各输出历史和块内系数顺序递增；两面板的累加链没有交叉。
- 新分派只在原 HWCAP 条件、两道安全字节计算和 bytes>4MiB 的 else 中触发；NULL 不参与策略判断。旧预算内分配失败、无 SVE、溢出路径继续原 solve_panel。
- scratch 独立于 L/history；一次对齐分配包含两个 m×8 面板，x1 偏移 m*8。完整十六列使用新八行块，短列任务使用旧 RHS8 块；每面板尾部复用旧四行/不足四行代码，写回只覆盖有效 B 列。分配失败按本 worker 的任务边界 direct 求解。
- 每 worker 在使用 SVE 前重新核对 HWCAP 和现有 VL8 helper；整个新增区域由 TRSM_CAN_DISPATCH_SVE 保护。预处理条件、括号平衡检查通过；没有运行预处理器或编译器。

API 与任务/分配规则已同步 root 和负责专用预检的 wide_shape_followup。后续必须完成 VALIDATION-PLAN.md 中直接逐位检查、实际分派/分配观察、端到端/回退和目标汇编审查。静态准备没有性能结论或晋级动作。

独立审查者 panel_shape_explore 在源码冻结后逐段复核，结论 **READY，无阻塞源码问题**：历史系数和 q=0..6 的全部二十八个三角依赖对在两面板上对应正确；求解/存储顺序、完整/短列与窄 VL 的行尾起点、局部失败列区间、双面板边界、分配上界和任务整数范围均成立。它特别确认提前 return 前 packed_history 必为 NULL，预算内失败或无 SVE 不会误触发新分派。该结论仅为静态审查，尚无目标编译或精度结果。
