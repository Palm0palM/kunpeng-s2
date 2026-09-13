# C53-row7cursors：shared 权重连续游标

状态为 `prepared`、`verified=false`，仅完成源码和文本留痕，等待 root 独立源码审查；没有 compute GO。源父版为 C51-row7x3u1，实际修改以其冻结 Q 作业1581822的 `source/conv2d.c` 字节为输入。父 SHA 为 `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`；C53 当前 SHA 为 `d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`。父 Q 的通过和 R/S 的性能不构成 C53 的通过或性能证据。

唯一假设：保持七行×3VL、21个累加器、13阶段和单列 ik 循环，只把 shared 七个权重地址改成每个输出列 tile 初始化一次、跨 shared t 连续前进的七个游标。原 `ka[ik]` 等七个广播操作数改为 `*ka++` 等；其它十二阶段、输入地址、21条更新顺序、存储、尾部、dispatch、fallback 和另外三个提交文件不变。实际补丁仅位于父1477–1527行，对应候选1477–1529行。

实际 Q shared `.L407` 为63条指令/列，其中21 FMUL、21 FADD、3 LD1W、7 LD1RW、1 LSL、8 ADD、CMP、BGT。独立 LSL 在6244行，只服务七个系数地址构造；输入加载已有缩放索引。外层6309–6315行另外含七个 kw*4 权重行首推进。连续游标可能改变这一地址工作，但七次内层地址 ADD 也可能仅变成七次游标 ADD，或被 GCC 规范化回原指令；不能将这些指令直接换算为耗时或承诺提速。

这不是 C52 的 shared 两列展开，也不重复 C40/47/48 的形状、C45/49 的 packed 系数、C43/44 的复制或 C35 的预取。本候选直接取 C51 源，不合入 C52、asm 屏障、输入游标、倒计数、restrict、编译设置或任务分派变化。

主要风险是七个指针跨 t 活跃导致 GPR 保存/栈访问和调度压力增加，或使其它阶段的编译结果变化。父 Q helper 固定656字节栈且存在标量地址保存，不能只检查向量 spill。未来若获准诊断，需绑定 C53 自己的源和原作业，按 BOUNDARY_MATRIX.md 逐位检查并读实际全部 helper/clone、十三阶段、转场/尾部/dispatch 和栈行为。若实际代码无区别，应如实记录，不以新编号安排性能作业。

R 的父 C51 对结束 C6 总收益2.9473%，S 为2.9585%；S confirmation=false，结束控制 A 的 spread5.3502% 超过总收益。两组全部样本和原结论保留，当前最佳仍 C6。C53 不继承这些收益，也不触发重测 S、ZIP、晋级或发布。

本次交付仅 PLAN、STATIC_REVIEW、BOUNDARY_MATRIX、candidate.patch、一次性 prepare-source.py、PREPARATION_COMMANDS、source-audit 和标准实验记录。没有新诊断目录、诊断工具、编译、题目运行、benchmark、SSH 或作业。STOP。
