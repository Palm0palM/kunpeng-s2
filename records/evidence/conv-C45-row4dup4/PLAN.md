# C45-row4dup4：四系数加载与显式 lane 广播

- parent / source_parent：`C26-row4loads`，正式C6的源码来源。
- 状态：仅prepared；尚未编译、验证或测量。本轮不创建诊断wrapper、不SSH、不提交、不用重置卡。源码之外只有本候选计划、静态审查、补丁和experiment记录。
- 设计依据：`../sep12-c45-design.md`；Arm/GCC一手API、边界、r2采样限制和旧C29/C32结果均保留在该文件。

## 单一可检验假设

只在quad四行共享中段`for(t=3;t<kh;++t)`内、原两列循环之前加入四列循环。每个kernel行用一次`svld1rq_f32`取四个相邻系数，共四个pack；显式q=0、1、2、3各自scope用`svdup_lane_f32`把当前系数广播，然后按n=0..3加载输入窗口、用普通`svmul_f32_x`与独立`svadd_f32_x`更新a/b/c/d。每q只声明四个当前广播，每输入窗口单独scope；保留原16个累加器，不加asm或固定寄存器。

目标是用寄存器广播替代部分系数内存加载，并保持16条独立累加链的q优先交错。每四列仍为16次输入加载、64次FMUL、64次FADD；系数加载期望16LD1RW→4LD1RQW，但新增16DUP，因此系数加载加广播核心操作从16变20，系数字节仍64，不预称净减少12指令、带宽降低或提速。理想源级16acc+4pack+4broadcast+1input+1product=26Z只是预算，不能推导无spill。

## 与已有版本的区别

C29已经实现四LD1RQ加直接`svmul_lane_f32`，n优先，每n完成lane0..3；实际有d0/d1 spill且同轮退化8.22%。C32在C29前后半块之间加屏障，实际无spill仍同轮退化10.62%。本版是显式DUP+普通FMUL以及q优先交错，不沿用C29直接indexed调用或C32屏障。两份旧成绩来自不同allocation，不能直接比较出屏障因果百分比。

GCC可能将DUP再折为indexed FMUL，或把q优先源码排回其它顺序。局部scope不是屏障，可能增加输入提前加载、多个乘积、movprfx或spill。即使无spill也可能退化。如果未来实际汇编与既有方案没有可解释的新差异，停止该假设并留痕，**不自动进入性能测试**。

## 保留项与数值约束

原双列循环与单列循环逐字保留，余0/1/2/3列按原顺序完成。quad其余六阶段、所有原helpers、尾列、剩余输出行、OMP调度、非SVE与invalid路径不改；benchmark、runner、README、flags、资源和容差均原样。没有官方尺寸特判、分配或跨调用状态。

每输出依次完成kernel行原顺序，每行内ik+0→1→2→3，再下块及原2/1余数；仅不同输出之间交错变化。保留单独乘法和加法、原禁止fast-math和contract flags，不使用融合累加或部分和重关联。

## 后续根代理统一验证

先独立源码审查，再目标GCC10.3.1编译与完整七阶段/dispatch汇编，记录实际LD1RQ、DUP、普通/indexed FMUL、FADD、movprfx、spill、ABI保存与FMA。所有循环按四列/两列/一列实际工作量归一化。沿用C29四列边界矩阵作为诊断来源，但单独创建本版源码身份与实际PASS记录；VL16/32/64字节×threads1/4、保护页/只读input和kernel/output canary/逐位reference，重点kw1..8及余数0..3、kh3/4/5、满四向量块及尾列、剩余1..3输出行。不得借C29的PASS。

仅当实际机器安排构成有区分度的假设且独立正确性通过，根再决定是否同分配前后C6控制三套件测速；无预测成绩或晋级结论。
