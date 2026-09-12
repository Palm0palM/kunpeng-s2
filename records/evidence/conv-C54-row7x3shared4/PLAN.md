# C54：shared 主循环展开四列

状态为 source prepared，未编译、未运行、未诊断、未测性能。标准 record 为 `prepared / verified=false`。当前正式最佳仍是 C6（records/best.json 的 conv=C26-r1）。S/C51 与 Y/C52 的独立确认均为 false，原始记录与慢样本保持；C54 是不同源码的新展开假设。

source parent 固定 C52-row7x3shared2。其原生产四文件与 parent record 一致，conv2d.c 同时与实际 T1582134 冻结源一致，父源 SHA256 为 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。T 的 passed/complete/37128 及汇编审查只证明父版，不能转写为 C54 PASS。

唯一假设是把 shared 主循环从每轮两列改成四列，分摊循环及地址控制成本，并观察 GCC 实际调度。新循环为 `for (; kw - ik >= 4; ik += 4)`，四个独立词法作用域依次完整处理 ik、ik+1、ik+2、ik+3；每列保留父版 21 个独立 mul/add。原 u1 余项循环逐字保留，处理 0..3 列，没有新增 paired2 余项层。

七行 × 3VL、21 个 accumulator、十三个语义阶段不变。其它十二阶段、全部输出 store、横向尾部、kh<7 防御、global stride、所有分派/无 SVE/非法尺寸 fallback，以及 README.md、bench_conv.c、run.sh 均保持父版字节。候选只改变 conv2d.c 的父行1488–1572，对应新行1488–1654；完整差异在 candidate.patch。

四个作用域不保证机器码 live range 受限，可能增加 spill、代码体积或耗时。没有引入 FMA intrinsic、asm、prefetch、partial sum、重关联、分配或输入游标；源码语句数量不构成机器码或提速承诺。C54 未来需自身 kw1/2/3/4/5/7/8/15/81 的实际边界与汇编证据，不能借父 T 主矩阵 kw1..3 的通过结果。

prepare-source.py 是一次性文本生成器，使用公共 `.runs/.workflow.lock` 和标准 experiment new/checkpoint。experiment.json 的 source_hashes 保留创建时父源快照，prepared record 与 source-audit.json 保存最终候选身份。最终 conv2d.c SHA256 为 `fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88`。

本任务止于根代理独立静态审查，不创建诊断/性能任务、ZIP、晋级或发布。没有本机算子执行或 SSH。
