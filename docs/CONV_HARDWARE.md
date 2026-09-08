# CONV 硬件与汇编诊断（2026-09-08）

诊断作业 `1485312` 经调度器申请 38 CPU、单 NUMA 资源，状态为 `SUCCEEDED`，脚本完成。诊断在计算资源内执行，没有在登录节点运行算子或性能测试。当前 CONV 源码未改动，SHA-256 为 `78a336ca08eb6a47b02a452ae0bea5ff1c2e516c4b9a5dbd33f428bf41e2933e`。

本次只检查硬件能力、编译可用性及生成指令，**没有完整 CONV 正确性或性能结果，因此不产生新最佳版本，也不能据此宣称提速**。

## 已确认的事实

| 检查项 | 实际结果 |
| --- | --- |
| 编译器 | `/usr/bin/gcc`，版本 10.3.1 |
| `-mcpu=native` | 编译成功；识别 `hip11`、`-mtune=hip11`、`armv8.5-a` |
| `-mcpu=generic+sve` | 最小 SVE 程序与当前 CONV 汇编均编译成功 |
| 当前 SVE 向量长度 | 64 字节，即 512 bit、16 个 float lane；`svcntb()` 与 `PR_SVE_GET_VL` 一致 |
| SVE 指令执行 | 反汇编确认 `ld1w`、`fmul`、`fadd`、`st1w`；执行退出码 0，16 个 lane 逐项校验错误数 0 |
| BiSheng / Clang | PATH 中未发现；配置中的 HPCKit module 根目录不存在，已列出的模块中也没有相应编译器。未穷举整个文件系统，不能断言系统完全未安装 |

最小 SVE 程序输出为：`SVE_BYTES=64 SVE_FLOAT_LANES=16 PR_SVE_GET_VL=64 ERRORS=0 FIRST=8 LAST=68`。这证明当前进程能够执行所测 SVE 指令，不代表全套 CONV 已经使用或通过 SVE。

## 当前源码生成的主循环

所有汇编采用 `-O3 -std=c11 -fno-fast-math -ffp-contract=off -fopenmp -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2`，只分别选择 `generic`、`native` 和 `generic+sve`。三份汇编均未出现 FMA 或其他融合浮点乘加指令。

| 目标 | 主循环观察 | 解释 |
| --- | --- | --- |
| `generic` | 主 `.L69` 循环 108 条指令，32 次 NEON `fmul`、32 次 NEON `fadd`；循环内没有栈访问 | 编译器在源码双步展开之外进一步处理 4 个 kernel 元素；主要累加器驻留向量寄存器 |
| `native` | 对应 `.L69` 循环 114 条指令，仍为 32 次 NEON `fmul`、32 次 NEON `fadd`；增加 2 次 `stp q`、4 次 `ldr q` | 循环内有 64 字节临时向量值写回并读回栈；启用 native 并不会自动保证更快或采用 SVE |
| `generic+sve` | 生成 SVE `ld1w/fmul/fadd/st1w`，但 32 元素的 acc 数组仍位于栈上 | `.L74` 通过 `x6 = sp + 176`、`x5 = x6` 访问 acc，每轮反复加载/存储；仅切编译目标存在额外访存成本 |

指令数是静态汇编计数，不是周期数；各版本循环结构不同，不能直接用条数比较速度。上述栈访问结论由主循环及其地址初始化共同确认，未把函数序言中保存被调用者寄存器算作热点 spill。

## 下一轮可检验假设

优先测试显式 SVE 累加器：每个向量 lane 对应独立输出，按官方顺序逐 kernel 元素执行分离乘法和加法，保持 acc 跨整个 kernel 在寄存器内。先用全套官方校验确认，再在相同分配资源上与基线交错比较；不能把 512 bit 向量宽度直接换算成四倍性能。

`native` 可以作为独立编译候选，但汇编已暴露额外 spill，应单独记录实测，不能直接替换最佳 runner。BiSheng 路线需要先找到真实可用编译器。

本地原始日志、完整命令、调度器状态、探针源码与完整汇编保存在被 Git 忽略的诊断目录；公开版本仅发布脱敏结论和无敏感信息的汇编片段。
