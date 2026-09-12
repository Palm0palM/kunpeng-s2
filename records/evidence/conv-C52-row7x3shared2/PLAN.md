# C52：仅 shared kernel 列循环展开两列

当前状态：prepared，未编译、未运行、未诊断、未测量。source parent=C51-row7x3u1，生产父源取自已冻结Q作业1581822的实际source/conv2d.c；父Q的37128 PASS和机器码只证明父版，不证明C52。

C51 shared实际循环63条指令，处理一个kernel列。本候选只把该shared阶段内部循环变为每次两列，希望摊薄回边和部分地址计算；展开可能增加实际活跃寄存器、spill或代码体积，效果尚未测量。R作业1581911由根代理管理，准备C52时不推断其最终结果，也不以理论代替C52未来实测。

七输出行×3VL、21独立accumulator和十三个语义阶段保持。其余十二阶段仍为一列，全部21输出store、横向尾部、kh<7防御、所有dispatch和其他提交文件保持父版原字节。唯一变更为原父源码1487–1526处shared内部列循环，对应新源码1487–1612。

成对循环使用 `kw - ik >= 2`，每次 `ik += 2`；第一个局部作用域完整处理column=ik，第二个处理column=ik+1。每个作用域的7coefficient和3input加载仅用于该列；每个accumulator仍先加ik，再加ik+1。作用域不保证GCC的实际live range局限于该作用域，不能因此宣称零spill。剩余列由原先单列body逐字保留的u1循环处理；没有partialsum、重关联、FMA intrinsic、asm、prefetch或额外分配。

实际源码身份和其他提交文件身份见source-audit.json；完整差异见candidate.patch，可复核的一次性生成器为prepare-source.py。通过tools/experiment.py new/checkpoint及公共workflow lock保存。创建元数据的source_hashes按工具语义保留原创建身份；最终prepared record和source-audit.json保存当前候选身份，不应将创建身份误当最终源码。

准备后只允许根独立静态审查。是否建立诊断，由根在R实际结果返回后决定；本任务没有提交新作业、创建性能工具、ZIP、晋级或发布，也没有使用重置卡。
