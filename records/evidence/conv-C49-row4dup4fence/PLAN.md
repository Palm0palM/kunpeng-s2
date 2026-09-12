# C49-row4dup4fence：四列 DUP 之间建立 packed 系数依赖

状态：source-only prepared；parent/source_parent=C45-row4dup4，正式最好仍C6。未编译、未诊断、未测性能，没有新诊断包/作业、SSH或重置卡。其它候选/冻结证据/正式source不改。

## 实际依据与不同之处

已读C45诊断1579762返回的未插桩conv2d-sve.s共享.L342（4734–4919）：四列185条指令，4LD1RQW、16DUP、16输入LD1W、64普通FMUL、0indexed FMUL和64FADD。真实每迭代6条向量spill load+6store，经x15=sp+784访问6VL槽，保存c1/d0/a1/d1/d2/d3。helper帧为784B+6VL，ABI的d8..d15保存单独计；没有生产对象反汇编，不能扩称对象审查或性能结论。

源码按q0→q1→q2→q3推进所有16acc；实际GCC却较多按输出行完成四列，保留输入/DUP与部分acc，出现上述spill。因此尝试显式限制跨q的系数DUP提前计算。这不同于C32：C32源父C29，使用indexed svmul_lane，n=0/1全部四列之后仅一道8acc输入屏障；C49保留C45普通mul+显式DUP，按每列q完成16acc，且packed系数是read/write输出，产生后续DUP依赖。

## 唯一变更

只将共享四列循环的ak4/bk4/ck4/dk4去掉const，使其成为合法可写lvalue；在q0、q1、q2完整scope之后各加同一道空模板：

```c
__asm__ __volatile__(""
    : "+w"(ak4), "+w"(bk4), "+w"(ck4), "+w"(dk4)
    : "w"(a0), "w"(a1), "w"(a2), "w"(a3),
      "w"(b0), "w"(b1), "w"(b2), "w"(b3),
      "w"(c0), "w"(c1), "w"(c2), "w"(c3),
      "w"(d0), "w"(d1), "w"(d2), "w"(d3)
    : "memory");
```

不改q3之后的循环、LD1RQ地址/数量、constant lane、input地址、任何mul/add表达式、kernel顺序、七阶段其它部分、原2/1列余数、尾列/余行、所有其它helpers/OMP/非SVE或其它3个提交文件。不添加early-clobber、固定寄存器、实际汇编运算或硬件fence。

## 约束依据与语义

[GCC10.3 Extended Asm](https://gcc.gnu.org/onlinedocs/gcc-10.3.0/gcc/Extended-Asm.html)的Output Operands说明`+`为读写且每项计两个operand；因此4×2+16=24，低于30上限。volatile只保留asm，单独并不能保证周边计算顺序；数据依赖仍必要。memory约束影响编译器内存排序，不提供处理器屏障，并可能产生保存/重载。[GCC10.2 AArch64 Machine Constraints](https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/Machine-Constraints.html)明确w包括SVE向量寄存器；10.3页面本次获取失败，使用可读的GCC10系列官方文档，不冒称已读取目标安装后端。

以下是本候选的语义推论而非已验证机器安排：空模板不执行指令，所以四个packed寄存器的实际位模式保持，输入acc也不变。`+w`使旧值与新值绑定于同一寄存器；后续lane DUP读取asm的新输出，编译器不能把它当旧packed值提前计算。16个acc作为输入要求当前q全部更新在该asm之前可用。无需`&`，因为模板没有在消费输入前写任何寄存器；同值输入合并也不会被实际修改。memory额外约束普通内存读取移动；别把它称为所有指令绝对固定或CPU同步。

单道asm列出20个源级SVE值（4packed+16acc），GCC计数24不代表24个物理寄存器。带入/带出值、四个当前DUP、input/product、谓词、ABI及调度临时状态可能扩大活跃集合；同值合并也可能减少实际寄存器数。强迫16acc同时可用可能减少原跨q存活，也可能需要更多spill/搬移，不能从20或24宣称无spill。memory还可能抑制有利加载重叠，三道边界可能增加依赖等待。

## 后续只在超算验证

根独立审查后决定诊断，当前未准备wrapper。目标GCC10.3.1必须实际接受全部+w/w scalable约束；需逐位guard、VL16/32/64各1/4线程、kw<4及4/5/6/7/8边界、完整块/尾列/余行和旧helper入口。实际汇编审查应对照C45全部七阶段、shared4及2/1余数、三asm处pack依赖、ordinary/indexed/DUP数量、真实spill/mov/ABI/FMA。无新有效机器差异时不自动测速；即使spill消除也需根决定同allocation带C6/C45的完整重复性能，记录退化/失败/全部慢样本。当前不提供速度或晋级结论。
