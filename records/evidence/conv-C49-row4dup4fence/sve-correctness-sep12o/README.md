# C49-row4dup4fence O 独立诊断包（prepared）

本目录只准备文件。C49 尚无本包 job、编译、专项 PASS 或性能结论；正式最佳仍是 C6。C45 的真实 PASS 不属于 C49。源父 C45-row4dup4，候选源码原字节来自 C49 已 checkpoint 快照。本包不执行原 runner/benchmark，runner_cases=0；无 driver、验收工具或自动启动。

## 固定矩阵与覆盖限制

两份检查器原字节复制 I/C45 的 source，追溯到 C32 四列边界矩阵。已读实际数组，不扩充矩阵：

- 基础 full：43 个输出宽度 × 19 个 kernel/输出高组合 × 2 个 pad × 2 个保护页方向 = 3268。
- 扩展 full：24 个输出宽度 × 16 个 kernel 形状 × 11 个输出高 × 4 个 pad/保护页方向 = 16896。
- 每配置生产 full=20164；独立插桩 smoke=3 个宽度（1/193/385）× kh1..4 × kw3/4 × 4 个 pad/方向=96。
- VL16/32/64 字节，各 threads1/4，共6配置。生产 full120984 + 插桩 smoke576 =121560；direct=0，runner=0。

扩展 kernel 为 (1,1)/(1,2)/(1,3)/(2,1)/(2,2)/(2,3)/(3,2)/(3,3)/(4,7)/(7,4)/(7,8)/(8,7)/(4,4)/(7,7)/(4,5)/(4,6)。kh4、kw4/5/6/7覆盖新四列循环后0/1/2/3余列，kh7/kw8覆盖两次四列循环；高度1/2/3/4/5/6/7/8/9/12/16覆盖余行和多个四行组。宽度包含各VL下4VL前后及尾列。**本矩阵没有 kh5 动态覆盖**，不声称所有 kernel 形状都被测试。

## 生产数值与独立入口诊断

生产 guard 与候选是分别编译的 translation units，保持严格标量参考和 memcmp，input/kernel 只读 mprotect、两端 PROT_NONE、output poison/canary。读取 PR_SVE_GET_VL，并在实际 OMP worker 检查 svcntw、team 与请求的1/4线程相符。

smoke 单独编译，只有它带 -finstrument-functions。原 prefix/tail/pair/triple/quad 入口计数格式保持，成功要求 pair/triple/quad 非零。没有新 shared 循环的入口计数，也没有 worker_mask；不得把这些不存在字段补作通过证明，不把插桩程序称为生产对象。

wrapper 固定 Linux/AArch64、38个实际分配CPU且单NUMA，GCC10.3.1，无编译器 fallback；后续调度者须申请38CPU/24GiB/单NUMA。保留三条实际 GCC argv：生产 guard、独立插桩、未插桩完整 .s。flags 保持 -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp，原 benchmark/计时区不在本包中。

## C49 必需的实际汇编审查

C49 仅在 shared 四列循环 q0/q1/q2 后加三道空 volatile asm：4个 packed 系数 +w、16acc w输入和 memory clobber；其它七阶段、原2/1余数、helper/分派保持。必须由目标 GCC10.3.1 实际接受约束，不能从源码或C45编译成功推出C49接受。

未来须读取 C49 未插桩 conv2d-sve.s 的完整 quad 七阶段、转场、输出存储、尾列/小kernel回退及全部 conv2d/OMP 分派。shared 四列及原两列/单列余数分别圈定真实范围；追踪三道空 asm 前后 packed/acc 活跃范围和调度，区分 LD1RQW/LD1RW、DUP、普通/indexed FMUL、FADD、EXT、MOVPRFX、ABI D 保存与实际 Z/Q/predicate spill、间接栈地址。扫描完整源输出的 FMA 系列，不以源级寄存器预算声明无spill。

已知比较依据只属于 C45 诊断1579762：shared 185条/四列，4LD1RQW、16DUP、16LD1W、64普通FMUL、0indexed FMUL、64FADD，每迭代6向量spill load+6store，helper帧784B+6VL，ABI另计。C49 当前没有对应观测。与该安排比较必须按相同四列/16acc工作量和真实寄存器/栈路径；不拿不同 allocation 的速度作因果结论。没有新可解释机器安排时不自动测速；诊断成功也须根代理独立决定性能组。

## 原始产物与失败留痕

source 五文件对应 source-hashes.json（简单 map）和 source-manifest.json（bytes/sha256），远端 source-sha256.txt 应逐项匹配；这是首次自动传输清单。prepared.json 全部成绩字段只表示计划，actual_job_id=null、compiled/executed/verified=false。

保留 probe.log、compiler-version.txt、stage-exits.txt、三build日志、六guard日志、六dispatch日志、conv2d-sve.s、exit-code.txt及未来真实调度记录。共19阶段：allocation/compiler/manifest/build-guard、6guard、build-dispatch、6dispatch、build-assembly/complete；只有最后阶段输出 PROBE_COMPLETE。编译、数值、tee或包装失败立即保存真实退出和已有日志，后续缺失不补造 PASS。仅 .s 可提供时不声称 production object 反汇编审查；sanitizer 未安排。

准备时没有 raw/job.json/validation.json/RESULT.md/实际汇编。未在本机编译、测试、执行题目、SSH、提交作业或使用重置卡。
