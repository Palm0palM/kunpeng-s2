# C8-sve128 正确性准备记录

C8 与 C7 是并行候选，共同父版本为 C0-r3。以冻结的 C7 实现为模板，把 SVE 独立累加器由4个增为8个，每块覆盖8*svcntw()输出。假设增加独立指令并行、分摊循环开销；可能增加寄存器及缓存压力。运行时特性检查、逐输出严格累加顺序、回退逻辑、run.sh、官方 benchmark 均保留。

本机命令：`bash .runs/conv/C8-sve128/local/run_checks.sh`。Apple Clang 17 / Darwin ARM64，严格浮点、UBSan，1/4线程各通过616个带保护页用例，输出与标量参考逐位相同；本机只走fallback。

远程命令：`python3 .runs/conv/C8-sve128/sve-correctness/driver.py submit`，随后对同一job执行status/fetch。诊断作业1485355申请38核、单NUMA、300秒上限，调度器SUCCEEDED，job/system退出码均0，wrapper退出0。GCC10.3.1 generic strict FP，1/4线程各616保护页用例及4线程instrumented616用例均逐位通过。实际SVE lanes=16、block=128，helper实际进入1848次。包含127/128/129、255/256/257列及39/41/55/81方核。远程未启用UBSan，不把本机sanitizer检查当作实机sanitizer通过。

远程driver、原始jobid/状态/日志/下载源码和汇编在 ../sve-correctness/；上传与下载哈希已验证一致，细节在 validation.json。该诊断不测正式性能；正式三轮同环境性能测量待协调者执行，未晋级。
