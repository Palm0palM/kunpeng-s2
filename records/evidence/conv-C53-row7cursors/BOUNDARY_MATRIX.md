# C53 未来诊断边界计划（未准备或执行诊断）

本文件仅记录源码假设需要覆盖的边界，没有新 checker、driver、manifest、reservation 或 job。任何后续诊断均需新的明确 GO，绑定 C53 当前源和自己的真实作业；不得使用父 Q PASS、R/S 结果或 C52/T 验证代替。

建议复用已经独立审查且实际执行的 Q 有界矩阵：VL16/32/64字节分别使用1/4线程，共六配置。每配置 full4784、dispatch972、direct432，合计6188；六配置应为37128（full28704、dispatch5832、direct2592），runner0。数值参考需保留独立逐位算法、只读 input/kernel、边界 guard/canary，检查真实 helper 入口计数与 worker mask，不能由 C53 实现生成预期值。

| 边界 | 沿用 Q 的实际范围 | C53 要独立证明的行为 |
| --- | --- | --- |
| kh 分界 | 核心 kh6/7/8，kw1/2/3 | kh6 不执行新 shared；kh7 单个 shared t；kh8 首次跨两个 shared t，七个游标连续接行 |
| 输出列 tile | ow 为3L、6L及各自±1，L=VL字节数/4 | 多个完整 tile 每次重置游标；不足 tile 和尾部路径保持；不读取前一个 tile 的游标终点 |
| 输出行组/尾部 | oh1..15、21、22、28 | 多个七行组及全部余数1..6的分派；新 helper 每次调用重置 |
| 更长奇偶 kernel | 10×7、9×8、15×15、81×81；oh7/13、ow3L+1 | 长 kw 连续推进恰好 kw 次；跨多个 t 后仅最终 ka 达到整体一过末端，不能读取该位置 |
| 小 kernel 和窄宽度 | full 小 kh1..5；full 窄 ow1 | 原 fallback、防御、窄宽度路径保持；不能将这些例子称为新 shared 动态覆盖 |
| 直接 helper 防御 | direct kh1..6、kw1..3、ow3L±1、oh7/28、四分配方式 | kh<7 的 rowseven 入口及 quad/triple 回退保持；这些 direct 例子不进入新 shared |

full 构成为 core3888+narrow144+small720+larger32。每配置 dispatch 的 rowseven 入口756、direct 入口1080；每例入口增量精确检查。线程1/4的 suite worker mask 分别1/15，prefix/tail/pair/triple/quad 入口非零检查也是 suite 累计。保持该真实统计层级，不声称每阶段或每例独立线程覆盖。

此有界矩阵仍省略曾讨论的低 L/2L±1 的864 full 例；direct 没有 ow1，普通 full ow1 不能代替 direct ow1；larger 实际为10×7/9×8而非9×7/8×8。矩阵没有内部阶段动态计数、每行独立 guard 或 sanitizer，不能声称穷尽尺寸或所有机器重排情况。

若后续准备流程，仍须检查原 Q 同样的19个 wrapper 阶段、编译及各配置退出码、真实 terminal job/system/wrapper 状态和完整日志。编译成功不等于数值通过，37128 也不是正式 runner 测试数。此处只说明未来要求，没有填入 C53 的状态、PC、计数或结果。

实际汇编须核对十三个 u1 语义阶段（本候选没有 C52 的 shared paired/odd 两块拆分），全源 FMA0，以及 shared 每个源列21普通 FMUL/21 FADD、3输入 LD1W 和7系数广播。实际范围、循环形式及 normalized work 要从 C53 的 .s 读取；若编译器改变结构，先记录真实结构并由 root 判断，不能套父 Q 固定 PC。

完整阅读全部 helper/clone、转换/尾部/dispatch 与 ABI；同时比较 Z/Q/谓词 spill、GPR 保存/恢复、固定栈大小和标量栈访问。与 Q 实际 shared63指令及656字节 helper 栈对照时，重点分开记录独立 LSL、七个内层地址 ADD、七个外层 kw 步进和输入缩放索引。指令变化不直接等于性能变化；无差异须原样保留。任何性能组另由 root 决定，不修改原 R/S 样本或门槛。STOP。
