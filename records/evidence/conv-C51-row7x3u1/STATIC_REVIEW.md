# C51 静态审查（作者审查，根代理另有独立说明）

仅复核生成源码、完整差异、范围及哈希。prepared 不代表编译、正确性或性能通过；本轮没有运行算子、编译器、sanitizer 或诊断程序。

## 修改范围

父版为冻结的 C40-row6x3u1，原 G 诊断 job 1579597。`source-audit.json` 保存父版冻结/当前字节身份、候选完整哈希、阶段源行范围及不变区域哈希。只替换 `conv_sve_rowsix` 所在专用 helper 段和 `conv2d` 中最先出现的六行 dispatcher。新符号为 `conv_sve_rowseven`，系数指针 ka..kg 不遮蔽 kh/kw/stride。所有旧 helper、公共尺寸检查与非专用后续实现保持相同文本。README.md、bench_conv.c、run.sh 保持父版字节，生成器/文档不进入提交 source。

## 13 阶段和舍入顺序

七个输出 r=0..6 各有三个 acc，初始化为正零。每个输入行 t 对输出 r 使用 kernel 行 t-r，活跃范围恰为 r≤t≤r+kh−1。

- 起始 t=0..5：输出 r=0..t，kernel 行 t-r 从 t 递减至 0。
- 共享 t=6..kh−1：输出 r=0..6，kernel 行 t-r；kh=7 时共享循环恰有一次。
- 收尾 t=kh+q，q=0..5：输出 r=q+1..6，kernel 行 kh−(r−q)，在 kh≥7 下最小 kh−6≥1，最大 kh−1。

对固定 r，阶段恰好枚举输入行 r..r+kh−1，映射 kernel 行 0..kh−1，每行内 ik 从 0 至 kw−1。每个输出标量依次执行一次 `svmul_f32_x` 和一次 `svadd_f32_x`，不拆分部分和。不同输出之间的计算交错不会改变各自累加顺序。runner 原有 `-fno-fast-math -ffp-contract=off` 保留；未来仍须查看实际构建命令和汇编，不能把源码普通乘加当作已经验证的机器指令事实。

静态语法展开为 21 个 acc 初始化、21 个存储、13 个逐列循环；13 阶段合计 39 个源码加载点、49 个系数广播点、147 个乘法/147 个加法调用。这是源码站点数量，循环共享阶段会重复执行，不能当作运行指令总数。

## 边界与全局 stride

入口先排除 kh/kw≤0 或大于输入尺寸，之后 oh/ow 为正数。专用入口要求 kh≥7 且 oh≥7。组数用 size_t 的 `oh/7+(oh%7!=0)`，避免 oh+6；每个有效 group 满足 group×7≤oh−1。remaining≥7 时最大输出行 first_row+6≤oh−1，最大输入行 first_row+kh+5=(first_row+6)+kh−1≤inputHeight−1。收尾先转 size_t 再加 q，未引入 int 的 kh+5。

设 L=svcntw()，block=3L。主循环 `ow-i>=block` 确保 i+3L≤ow。每次第三个输入向量最多访问 i+3L+kw−2≤ow+kw−2=inputWidth−1；前两个向量更早。地址由指针按 row+ik+n×L 推进，未新增可能溢出的 int 表达式 i+ik。64 位目标上合法 int32 尺寸的行跨度乘积由 size_t 计算；调用者仍须提供有效且可表示的实际存储，不将不可分配的极值视为动态覆盖。

主块结束后 0<ow−i<3L 时，quad 处理输出行 0..3，triple 处理行 4..6，均传递同一尾列 i 和原输入 stride。目的指针来自原 dst0..dst6 加 i，没有用尾宽重算跨行间距。小 kh 直接调用防御回退也用 quad+triple，直接调用合同要求具备完整七行输出及其输入。公共 kh<7 或 oh<7 直接走保留的原 SVE 路径。

|最后一组 remaining|分解及全局行偏移|
|---|---|
|≥7|rowseven 行 0..6|
|6|quad 行 0..3；pair 从 input+4×stride、output+4×ow 开始|
|5|quad 行 0..3；prefix 从第 4 行开始|
|4 / 3 / 2 / 1|原 quad / triple / pair / prefix|

各 OpenMP 静态组只写自己的行集合，没有跨组重叠或 reduction。非 SVE、无效尺寸检查及完整旧 dispatcher 均由父版保留。原 flags、线程及资源设置未改。

## 后续验收边界

`BOUNDARY_MATRIX.md` 是建议而非已建立的诊断包。根代理已另写 `INDEPENDENT_REVIEW.md`，后续诊断流程仍须独立审查。届时所有编译、guard/dispatch/direct 检查、汇编与性能测量只能在调度器分配的计算节点执行。需明确验证真实 13 阶段、所有转换、spill/ABI 保存区别及整个 helper/dispatcher，而非仅凭共享阶段计数判断。
