# C9-sve256 正确性准备记录

以 C8 冻结实现为模板，把 SVE 独立累加器由8增为16，每块覆盖16*svcntw()输出；当前登记父版本 C7-r1（C1源码），尚未正式测量前由协调者按C8结果选择共同基线。假设更多独立指令、分摊循环开销；取舍为更大的工作集和寄存器压力。运行时检查、逐输出严格累加顺序、回退逻辑、run.sh和官方benchmark保持不变。

本机命令：`bash .runs/conv/C9-sve256/local/run_checks.sh`。Apple Clang17 / Darwin ARM64，严格浮点、UBSan，1/4线程各通过682带保护页用例，输出逐位相同；本机只走fallback。新增511/512/513列，保留127/128/129、255/256/257，39/41/55/81方核与输入偏移，覆盖两个256块与tail。

远程命令：`python3 .runs/conv/C9-sve256/sve-correctness/driver.py submit` 后复用job编号status/fetch。诊断作业1485371申请38核、单NUMA、300秒上限，SUCCEEDED，job/system/wrapper退出均0。GCC10.3.1 generic strict FP，1/4线程各682保护页例及4线程instrumented682例均逐位PASS。实际SVE lanes16、block256，helper实际进入2046次。远程未启用UBSan。

汇编事实：GCC10.3.1生成的两kernel元素热循环 `.L5` 内存在向量栈spill：`add x14, sp, 672`、`ldr z31, [x14]`、`str z23, [x14]`，每次循环一对向量reload/store，当前SVE向量64字节；也有标量地址栈加载。未发现FMA指令。保存完整汇编及hot-loop.s、assembly-observations.json。不据此预判总速度，正式性能待同环境测量。

所有jobid、环境、原始日志、上传下载源码hash与汇编保存在 ../sve-correctness/；validation.json确认候选/上传/下载源码一致。未测正式性能、未晋级。
