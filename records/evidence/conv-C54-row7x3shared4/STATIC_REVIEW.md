# C54 作者静态审查

本说明基于实际文本、完整 candidate.patch 和生成器的身份断言，不是编译或运行结果；需根代理独立审查。

|检查|实际源码结论|
|---|---|
|来源|生产四文件同 C52 parent record；conv2d.c 额外同 T1582134 冻结源 SHA 8cf5dc…12bf7|
|差异范围|只替换 shared 主循环注释/循环头，并增加两个完整列作用域；替换区外整个 prefix/suffix 原字节一致|
|算术顺序|四作用域依次 ik、ik+1、ik+2、ik+3；每个作用域与父第一列 body 完全相同，仅 column 声明不同|
|每列语句|7 个 coefficient broadcast、3 个 input load、21 个 svmul_f32_x、21 个 svadd_f32_x|
|主循环每轮语句|28 个 broadcast、12 个 load、84 个 mul、84 个 add；这是源码计数|
|余项|原 `for (; ik < kw; ++ik)` 和完整 body 逐字保留，至多三次；无 paired2 层|
|固定形状|7rows、3VL、21acc、13 语义阶段；其它12阶段和横向 store/tail 不变|
|分派与 fallback|完整函数区在未改 suffix/prefix 内；kh>=7/oh>=7 路径、余行分派、小 kernel 防御、non-SVE 与 invalid fallback 原字节保留|
|提交环境|README.md、bench_conv.c、run.sh 哈希不变；未改 flags/runner/线程/绑定或参考计算|

对每个 accumulator，列更新序列仍是 0,1,…,kw−1。四列之间没有局部 partial sum 或合并加法；新的第二/第三/第四作用域只用自身 column 的系数和输入。生成器核对父两列 body 仅 column 声明有别，再复制原完整 body，未调整向量内运算或 coefficient 映射。词法作用域可复用变量名，但不能证明 GCC 会限制活跃区间或保持源级加载位置。

循环整数安全依赖原合法维度路径的 `0 <= ik <= kw <= INT_MAX`。进入四列循环的条件 `kw - ik >= 4` 在该不变量下不溢出，并推出 `ik+3 <= kw−1`、`ik+4 <= kw`，因此四次 column 构造和更新 ik+=4 均可表示；不能用 ik+3<kw 替代这个安全条件。循环结束有 `0 <= kw−ik < 4`，原 u1 循环恰好处理这些列，最后一次 ++ik 到 kw 仍可表示。

新循环沿用父 row、ka..kg 和 global stride。每列不超过 kw−1，三个完整向量的最右输入索引为 `i + column + 3L − 1`；父完整块条件 `i + 3L <= ow` 推出该索引至多 `ow + kw − 2 = w−1`。没有增加新窗口、游标或越过末列的预读。这里是对改动部分的静态边界推导，并不替代 guard/canary 数值诊断，也不重新证明未改的完整入口前提。

实际 C54 汇编、栈帧、D ABI 保存、Z/Q/谓词 spill、FMA 数量、主循环指令数和性能均未知。父 T 的机器码不能作为本版结论；未来应独立检查四列 main、原 u1 remainder、另外十二阶段及分派。静态作者审查未发现超出授权范围的源码变化。
