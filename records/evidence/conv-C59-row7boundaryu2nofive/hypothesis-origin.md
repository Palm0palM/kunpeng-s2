# C58 后续单一假设：只撤掉 input_5 的 unroll2 提示

建议若 C58 当前性能结果值得继续追踪，以 C58 为源父，仅删除 `.runs/conv/C58-row7boundaryu2/source/conv2d.c:1445` 的一行 `#pragma GCC unroll 2`。定位上下文是 `/* Input row 5: start output 5 and advance earlier outputs. */`、六个 `ka..kf` 权重指针，以及随后的 `for (int ik = 0; ik < kw; ++ik)`。其它11条边界 pragma、shared 两列主循环/u1余项、算术、输入索引、dispatch、其他三生产文件全部保持。这是一个待检验假设；本备忘录没有创建候选或修改源码。

## 实际依据与预期边界

依据 AH1583350 的 `TARGETED_ASSEMBLY_REVIEW.{md,json}` 和返回 `.s`，并读取 C52/C58 对应源码与12处 pragma 补丁。C58 源 SHA 为 `c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751`，AH `.s` 为 `337724743825be9e4b51c86d0041726cf42e19c20f584647b14911c789e442b5`；父为 C52/T1582134。

input_5 是前置 input 阶段中更新输出最多的一段：每列更新六行×三VL共18条累加链。AH 将它展开为两列（6734..6851），36 FMUL/36 FADD、6 LD1W、12 LD1RW，共117条指令；父单列段6182..6237为55条、无Z spill。两列让更多输入/权重/乘积同时活跃；实际出现以下可直接归因于本段调度的临时乘积栈往返：

LOCAL_USER 实际位置 LOCAL_USER 本版静态读/写 LOCAL_USER 单点撤提示可检验的目标 LOCAL_USER
LOCAL_USER---LOCAL_USER---:LOCAL_USER---LOCAL_USER
LOCAL_USER input_5 成对循环：store6752/6764/6791，load6778/6781/6792；sp+720别名、VL槽0/1/2 LOCAL_USER 3 / 3 LOCAL_USER 撤掉提示后编译器若回到较短单列调度，减少或消除这三组往返及相关地址指令 LOCAL_USER
LOCAL_USER trailing_0/1/2 成对段外的 z6/z1 保存/恢复，以及8134/8135、8143/8145、8157/8158等互斥入口 LOCAL_USER 6 / 12 LOCAL_USER 保留对应pragma；没有局部理由承诺这些转场往返消失，先按可能保留处理 LOCAL_USER
LOCAL_USER shared 两列6886..7009与u1余项7013..7077 LOCAL_USER 0 / 0 LOCAL_USER 源码工作量保持；实际寄存器/调度仍需重新核对，防止spill转移至更长的shared阶段 LOCAL_USER

9/15是全helper静态出现数，不是每次调用的动态流量。input_5实际先做首列，偶数kw再前置一列，之后每个成对迭代均发生3读3写；在该路径上每个完整7行×3VL tile的这部分为 `3*floor((kw-1)/2)` 次读和同数写。相比仅在阶段边界出现的转场存取，这提供了优先只撤此提示的依据。117与两次父55只是等工作量静态指令比较，不是周期或速度模型。

只删除 pragma 恢复的是该源循环的默认编译策略，并不强制 GCC 一定生成u1。其余阶段仍有11处展开提示，因此不会在源码层面退回整个 C52；也没有改 shared 三/四列展开、显式FMA或空asm策略。标量栈、D8..15的ABI保存及trailing spill都可能继续存在。3VL帧中的最高槽目前用于input_5，但不能预填帧缩为2VL、更不能承诺回到父720B或全函数0 spill；全函数寄存器分配可能连带改变。

## 后续只需验证什么

若 root 在读完 C58 实测后决定使用，先做候选自身诊断：保留原44328矩阵、六VL/线程配置、19阶段和strict flags，独立确认正确性、guards/入口计数/退出；重点保留 kw1/2/3/4/5/7/8及长kw15/81、kh6防御与7/8边界、3L/6L附近宽度和跨tile覆盖，不能借用AH PASS。

实际汇编只针对假设补充核对：input_5默认lowering的真实循环/前置列路径与3组Z往返是否减少；其余11阶段是否仍展开；shared是否仍无新增spill；全helper9/15、转场、标量/ABI栈及帧的实际变化。行号/寄存器以新返回文件为准，不复制本版范围、不预填0 spill。单列可能损失调度重叠、增加分支，或让spill转移；只有同条件实际性能才能判断净效果，即使spill减少也不声称提速。

本备忘录只保留这一单点方案，等待正在进行的 C58 性能结果再决定是否采用；不改变 C52 的Y失败、C51的S失败或C57的官方精度失败。仅本地文本阅读/记录，无源码、record、job、SSH或算子执行。FINAL/STOP。
