# C45-row4dup4 独立诊断包（prepared）

本目录只准备文件，尚无 job、编译、专项 PASS 或性能结论。源父版本为 C26-row4loads；候选源码原字节复制自已 checkpoint 的 C45-row4dup4。正式最佳仍为 C6。本包不执行原 benchmark/runner，runner_cases=0；不使用重置卡。

## 实际矩阵及计数

两份检查器原字节来自 C32-row4lane4staged/sve-correctness-sep12c/source。逐一核对真实数组，而非仅复用历史总数：

- 原基础 full：43 个输出宽度 × 19 个 kernel/输出高组合 × 2 个输入/kernel pad × 2 个前后保护页位置 = 3268。
- 四列扩展 full：24 个输出宽度 × 16 个 kernel 形状 × 11 个输出高 × 4 个保护页/对齐组合 = 16896。
- 每配置 full=20164；另行插桩 smoke 为 3 个输出宽度（1/193/385）× kh1..4 × kw3/4 × 4 个保护页/对齐组合 = 96。
- 请求 VL16/32/64 字节，各 threads1/4：6 配置，生产 full 共120984，插桩 smoke 共576，合计121560。两类分别验收，禁止把插桩代码当作生产对象。

四列扩展实际 kernel 集为 (1,1)/(1,2)/(1,3)/(2,1)/(2,2)/(2,3)/(3,2)/(3,3)/(4,7)/(7,4)/(7,8)/(8,7)/(4,4)/(7,7)/(4,5)/(4,6)。kh4 下 kw4/5/6/7 覆盖新四列循环后余0/1/2/3；kh7、kw8 覆盖两个完整四列迭代。该复用矩阵没有 kh5，不声称覆盖所有 kernel 形状。输出高为1/2/3/4/5/6/7/8/9/12/16，保留剩余1..3行及多组调度；宽度覆盖4VL完整块前后及尾列。

## 数值与实际执行入口

生产 guard 使用独立标量参考、严格 memcmp，输入/kernel mprotect只读，前后PROT_NONE保护页、输出 poison/canary。主线程设置并读取实际VL；OMP预检查每个worker的svcntw、实际team等于请求的1/4线程。包装限定Linux/AArch64、38个已分配CPU且同一NUMA，目标GCC10.3.1；申请38CPU/24GiB/单NUMA的动作由后续负责人执行，不在此包中发生。

单独插桩程序保留真实 prefix/tail/rowpair/rowtriple/rowquad 入口计数，原判定要求 pair/triple/quad非零；没有伪造 worker_mask 或新循环的独立入口计数。full与smoke的实际VL/team、各阶段退出码、最终wrapper及scheduler两退出均需验收。

## 汇编审查要求

必须读取实际未插桩 conv2d-sve.s：完整quad七阶段、所有转场/栈/输出存储/退化路径，以及dispatch；共享中段新增四列循环、原两列余数、单列余数逐一对应源码。记录 LD1RQ/LD1RW、DUP、普通与indexed FMUL、FADD、EXT、MOVPRFX，区分ABI保存和真正acc/input/product spill；扫描整个源的FMA，不以源码形式代替机器码事实。

四列循环源级有4 LD1RQ、16显式DUP、16输入窗口、64独立mul/add，但GCC可能折回indexed或重排；这些只是待核对期望，不是观测值。与C29/C32按实际每列/输出工作量归一化比较，不能把不同allocation的旧速度当作本版收益。若与C29/C32没有新的可解释机器安排，不自动做性能测试。即便正确性全过，性能组也须根代理另行决定。

## 预期产物与失败留痕

source内五文件对应source-hashes.json，远端source-sha256.txt应逐项匹配；这是首次自动传输身份清单，无额外大范围人工哈希审计。预期保存probe.log、compiler-version.txt、stage-exits.txt、三个build日志、六guard日志、六dispatch日志、conv2d-sve.s、exit-code.txt及实际调度记录。全部19个阶段依次完成才允许PROBE_COMPLETE=1；编译/校验/tee失败立即退出并保留已有日志，缺失后续日志不补造PASS。

本目录没有job.json、validation.json、RESULT.md或实际汇编，不能将计划字段当成已通过证据。未本机编译、测试、SSH或提交。
