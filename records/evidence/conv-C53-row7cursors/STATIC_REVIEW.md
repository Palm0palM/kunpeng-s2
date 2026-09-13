# C53 源码静态复核

本报告是源码准备者的文本复核，root 独立审查尚待进行。当前 `conv2d.c` SHA256 为 `d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`；未编译、运行、测量，没有 C53 correctness PASS。

实际 `candidate.patch` 为一个 shared 段补丁。已复读该补丁、helper 入口和主 tile 循环、修改后 shared 及相邻阶段。生成器在共同锁内确认父冻结 Q 源、初始候选源和父记录哈希一致，且初始记录为 planned；修改后已 checkpoint 为 prepared、verified=false。`experiment.json.source_hashes` 保留标准 new 的创建快照，prepared record 与 source-audit 保存当前源哈希，两者用途不同。

`conv_sve_rowseven` 的 kh<7 防御在1244行，进入新 shared 之前返回旧 quad/triple；1254行开始的完整列 tile 循环每次都会执行新的局部作用域及七个初始化。因此 i 跨一个或多个3VL tile 前进时，ka..kg 重新从 kernel 的6、5、4、3、2、1、0行起步；不同输出行组重新调用 helper 时同样重置，游标不会沿用上个 tile 的终点。完整 tile 与尾部条件未变。

对输出行 r（0..6），在 shared 的 `(t, ik)` 解引用前，游标为：

`kernel + (6-r)*kw + (t-6)*kw + ik = kernel + (t-r)*kw + ik`。

这正是父版的行首加 ik 地址。每个 `svdup_n_f32(*kr++)` 先读取旧位置，随后把该独立游标推进一个 float；同一完整表达式中没有第二次读写该游标。一个 t 完成恰好 kw 次推进，下一 t 的首个地址自动接到下一 kernel 行，不需要在 t 内重设行首。七个游标都保持 `const float *`，未增加写内存或别名假设。

kh=7 时 shared 只有 t=6；ka 从第6行读 kw 个有效元素，最后递增到 `kernel + 7*kw`，形成整体对象一过末端指针后立即结束该 shared 作用域，不再解引用。kh=8 时 t=6 完成后 ka 位于第7行首，t=7 再读完整一行；最终 ka 为 `kernel + 8*kw`，同样不读一过末端。一般 kh>=7 的最后有效读取为 `(kh-1-r)*kw + (kw-1)`，结束游标为 `(kh-r)*kw`：只有 r=0 达到整个 kernel 的一过末端，其余仍在对象内。kw=1/2/3 及更长 kw 都按同一关系推进；没有偶数假设、二列展开或跨行额外读取。

公开入口1769行起仍拒绝非正 kh/kw 和 kernel 大于输入的尺寸。kh<7 的内部防御保持，未扩展内部 helper 的调用契约；kw=0 的原 ik 循环仍不进入。上述地址证明针对原接口要求的有效缓冲区和合法尺寸，不声称添加了长度检查或消除了原有 size_t/存储前提。

shared 原三个 `svld1(pg, row + ik + {0,1,2} * lanes)` 与所有21条 `svadd_f32_x(... svmul_f32_x(...))` 完整语句及顺序仅增加作用域缩进，生成时逐行比对一致。`row = base + (size_t)t * stride + i`、t/ik 循环界限和递增不变，输入窗口覆盖证明不受系数寻址表示影响。对每个累加器，kernel 行/列的乘后加次序仍相同；源层没有 FMA、partial sum、重关联或额外输入加载。机器指令仍须未来独立核对。

生成时按实际 shared 边界检查前缀、后缀字节相等，因此其它十二阶段、存储、剩余宽度路径、全部 helper、旧非 SVE 路径和 dispatch 均来自父冻结源。另三文件 README.md、bench_conv.c、run.sh 哈希与创建快照相同。source-audit 记录每列7广播、3输入加载、21乘和21加，以及上述逐字检查；这些是源级断言，不是编译器结果。

后续 actual codegen 必须重新审全部 helper/clone、13阶段、转场/尾部、dispatch、FMA 和标量/向量栈访问。重点观察独立 LSL、每列七个地址 ADD、外层七个 kw 步进是否改变，以及 GPR 活跃期、固定栈大小和 spill 是否增加。新源与父 Q 的栈/指令数不能预先相等。当前静态阅读未见源语义阻塞；待 root 独立审查，保持无 compute GO。STOP。
