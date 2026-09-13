# C33 五行分组专项结果

原作业1579312已 SUCCEEDED，job/system/wrapper退出均0，没有重提。六配置1/4线程×SVE128/256/512位各40,804 full+864 smoke，总250,008项全部通过。实际VL、线程、每行4VL主块，保护页/只读输入与kernel、输出NaN/canary及有序scalar逐位参考均通过；自动传输manifest与远端wrapper SHA记录匹配，没有额外重复人工哈希审计。

每组smoke真实入口：pair768、triple1776、quad1632、quint432，prefix/tail各7920。扩展覆盖kh4/5/6、五行组及余1..4行，oh20包含四worker五行工作；宽度保留多个VL下主块与尾列边界。完整检查计划和所有实际计数保存在README与validation.json，complete=true。

实际quint共享单列循环 .L417 为58条指令，20 FMUL、20独立FADD、4输入LD1W、5 kernel广播LD1RW。九个单列内循环指令数17/28/38/48/58/48/38/28/17，全无向量spill、EXT/MOVPRFX/dup。整个quint未见Z/Q的ldr/str/ldp/stp；固定528B栈帧没有额外VL空间，d8–d11为ABI保存。全源码FMA=0。.L418属于外层共享输入行循环，不作为另一列阶段统计。单列工作量不能直接用原始指令数与双列/四列候选比较，也不能据此推断提速。

全部算子编译与执行在超算调度计算节点完成，本机只整理源码快照与取回文本。未提交性能作业，未修改候选源码或正式C6，未使用重置卡。性能比较由根代理后续安排。
