# C55 作者静态审查

本说明检查实际源码文本、生成器、完整 patch、哈希与标准 prepared record；不是编译或运行结论。独立源码审查由根代理另行安排。

|检查项|实际静态结果|
|---|---|
|来源|四个生产文件等于原 C52 record；conv2d.c 额外等于 T1582134 冻结 kernel|
|改动范围|shared main 循环头/注释改为三列，增加一个完整列作用域；替换范围外整个 prefix/suffix 原字节一致|
|三列顺序|ik、ik+1、ik+2，每个完整作用域仅 column 声明不同，body 同父第一列|
|每列源码语句|7 coefficient broadcast、3 input load、21 svmul_f32_x、21 svadd_f32_x|
|每轮三列源码语句|21 broadcast、9 load、63 mul、63 add；不是机器指令计数|
|余项|原 `for (; ik < kw; ++ik)` 及 body 逐字保留，至多两次，无额外 paired2 层|
|形状与其它阶段|7rows/3VL/21acc、13语义阶段；其它12阶段保持|
|分派/存储/环境|所有 store/tail/fallback/global stride、README/官方 benchmark/run.sh 字节保持|

每个 accumulator 的更新顺序仍为列0,1,…,kw−1。三个完整列 body 依次执行，跨列不引入局部求和或重新组合加法；同列的系数/输入映射和21个独立 accumulator 更新同父源。生成器先确认父两列 body 只差 column 声明，再复制原完整 body，因此差异没有隐藏的输入窗口、系数偏移或运算树调整。

合法原路径满足 `0 <= ik <= kw <= INT_MAX`。`kw - ik >= 3` 不溢出，并推出 `ik+2 <= kw−1` 与 `ik+3 <= kw`，故三个 column 及 ik+=3 可表示。退出 main 时 `0 <= kw−ik < 3`，原 u1 循环恰好处理0..2列，最后 ++ik 到 kw 仍可表示；没有采用可能先溢出的 ik+2<kw 判断。

输入沿用父 row 和 global stride。每列 column<=kw−1，完整向量块满足 i+3L<=ow，所以三个向量最右输入索引 `i+column+3L−1 <= ow+kw−2 = w−1`。kernel 的 ka..kg、shared外层 t、输入行/输出组推进均在未改范围。该推导只审核新增列展开对原有效维度前提的影响，不替代后续真实 guard/canary 检查。

三个词法作用域不能保证 GCC 限制 live range 或无 spill。C54 的进行中实际 scalable spill 观察说明需审最终机器码；它既不能证明 C55 有同样 spill，也不能证明三列可消除 spill。C55 的全 helper/clone、实际 frame、ABI、Z/Q/谓词和 scalar/address 栈、所有转场、FMA、分派及性能目前未知。

作者静态审查未发现超出授权的源码变化。未改原 C52/C54、AA/AB 工具、旧 record、best 或输出包；没有本机算子执行。
