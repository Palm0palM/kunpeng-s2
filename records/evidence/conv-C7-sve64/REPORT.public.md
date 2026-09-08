# C7-sve64：四向量 SVE 候选准备记录

父版本：`C0-r5`（原版代码与 C0-r3 相同；为共享一次 38 核单 NUMA 分配比较而新建的复测基线）。候选源码 SHA-256：`c72163fe41fcd237aa70adda359d73a51731e64675394cc1ec1f93dc77b3ee8a`。仅修改候选 `conv2d.c`，`run.sh` 与官方 `bench_conv.c` 保持父版本原字节，当前最佳 `conv/` 未变。

## 假设与实现

前置硬件诊断确认实际 SVE 向量宽度为 512 bit（16 个 float lane），但直接自动向量化当前数组会反复访问栈。候选用四个显式 `svfloat32_t` 累加器覆盖 `4 * svcntw()` 个输出；当前机器对应 64 列。每个 lane 独立，严格保留 `jk` / `ik` 顺序及双步展开，使用分离的 `svmul`、`svadd`，不做 FMA 或 partial sum。

整个编译单元维持 `-mcpu=generic`。仅 SVE helper 使用 GCC `target("arch=armv8-a+sve")` 属性；Linux/AArch64 通过 `getauxval(AT_HWCAP) & HWCAP_SVE` 检查后调用。Mac 或非 SVE 机器走原通用实现。仅对完整四向量块使用全谓词加载，尾部交给原通用路径，不建立越界 inactive-lane 指针。

当前只准备四向量版本，没有增加八向量配置，以优先获得本轮实测。

## 已完成的检查

| 检查 | 结果 |
| --- | --- |
| `generic` 编译单元 + 单函数 SVE 属性（作业 `1485327`） | GCC 10.3.1 编译执行成功；16 lanes，错误数 0 |
| Mac 非 SVE fallback，UBSan + 保护页 | 1 线程及 4 线程各 616 组，逐 bit 等于标量参考 |
| 真实 SVE 环境，未插桩候选（作业 `1485344`） | GCC 10.3.1、generic TU，1 线程及 4 线程各 616 组，输入/输出保护页、逐 bit 等于参考 |
| SVE 真路径诊断（同一短作业，独立插桩二进制） | 4 线程 616 组通过；函数进入计数记录 `SVE_HELPER_ACTUAL_ENTRIES=1848` |
| SVE 汇编 | 主 `.L5` 循环 8 次 `fmul`、8 次 `fadd`，循环内无栈访问；累加器为 `z2/z3/z4/z0`，未发现融合浮点乘加 |

616 组由 28 个输出宽度 × 11 个方形 kernel × 2 个输入末尾偏移构成，输出高为 3。覆盖 63/64/65、95/96/97、127/128/129、191/192/193、255/256/257 等边界；kernel 包括 39、41、55、81；偏移为 0 或 1 个 float，输入/输出末尾受不可访问保护页约束。此前 418 组较小 kernel 高度的本机检查也通过。

远程检查编译命令为 `gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check_conv_guard.c conv2d.c`；目标属性探针维持相同浮点与 CPU 配置。用于进入计数的独立诊断另加 `-finstrument-functions`，未插桩候选已单独校验两次。完整脚本与哈希均保留在本地原始记录中。

两个远程诊断都是调度器独立短作业，申请 38 CPU、单 NUMA 资源，最终状态 `SUCCEEDED`，脚本退出文件为 0。服务器 sanitizer 未执行；UBSan 结果只属于本机 fallback。

**尚未完成：官方四组大尺寸完整校验、三轮性能与父版本同环境比较。当前不能宣称提速，也未晋级。** 官方测评由主协调任务统一排队。
