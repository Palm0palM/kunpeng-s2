# C58 作者静态审查

父生产四文件分别与原 C52 record 的 source_hashes 核对；conv2d.c 另与 T 冻结 source/raw 逐字一致。创建前本版 run/record 不存在。标准 new 和 checkpoint 各执行一次，均使用既有 workflow lock；创建时 experiment/record 原字节分别另存 creation-experiment.json / creation-record.json。

十二个目标为 rowseven 内六个 Input row 和六个 Trailing input row 的唯一 `for (int ik = 0; ik < kw; ++ik)`。原行号依次为1280/1302/1329/1361/1398/1440和1623/1668/1708/1743/1773/1798。source-audit.json 列出每个新 pragma 与原/新循环行号。

candidate.patch 仅12个单行插入，0删除，全部是紧邻对应 for 的 `#pragma GCC unroll 2`。移除这12行完整还原父字节，另直接核对 shared 两列及余项原块不变；其他三个生产文件 SHA 不变。未手动展开、融合、改括号、加 asm/预取/input cursor 或改 flags。

新 conv2d.c 为108874字节，SHA `c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751`。experiment.json 保持原创建数据，source_hashes 仍为父；标准 checkpoint 仅把当前新源 SHA 写入本版 prepared record，verified=false。没有借用父 PASS 或刷新创建快照。

以上是轻量文本/字节审查，不是编译或正确性结果。源码循环与边界未改；编译器如何复制循环、处理奇数 kw、安排实际加载及使用寄存器仍需 C58 自身计算节点证据。没有零 spill 或提速结论。作者 FINAL/STOP，供 root 独立审查。
