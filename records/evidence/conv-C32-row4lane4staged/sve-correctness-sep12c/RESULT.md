# C32 专项验收结果

作业1579286已 SUCCEEDED，job/system/wrapper退出均0。1/4线程×SVE128/256/512位六配置，各20,164 full+96 smoke，总121,560项全部通过；实际VL、每行主块、pair/triple/quad入口、只读输入/kernel、保护页、输出预填/canary和有序scalar逐位对照均通过。自动传输manifest与远端wrapper记录一致；未额外重复人工哈希审计。validation.complete=true。

实际quad四系数热点 .L342 为159指令：64 indexed FMUL、64独立FADD、16输入LD1W、4 LD1RQW、3普通向量MOV、6 ADD、CMP/BNE各1。系数indexed寄存器z5=16/z4=19/z3=16/z2=13，全在低z0–z7；四个lane各16次。LD1RQW目的为z5/z4/z3/z29，dk从z29经普通MOV用于低Z索引。

C29每四列迭代的2个向量spill读取和2个写入已实际消除，主循环与所列其余二列内循环均无向量spill；整个quad无ldr/str/ldp/stp Z/Q，固定栈帧784B、不再有额外2VL。ABI的d8–d14保存及外层标量/输出指针表不计为spill。全源码FMA=0；EXT/MOVPRFX/dup在主循环均为0。静态汇编结果经过独立只读复核，尚不能推断性能提升。

源码及所有原始日志保留。准备期README/COVERAGE_EXTENSION描述的是提交前状态；最终状态以本文件和validation.json为准。全部编译/算子执行发生在超算调度计算节点，本机只做文件和日志整理；没有使用重置卡。根代理可在本诊断终止后另行开展同环境性能比较。
