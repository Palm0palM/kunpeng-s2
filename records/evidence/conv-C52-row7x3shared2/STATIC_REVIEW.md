# C52 作者静态源码审查

创建时检查唯一C52 ID未占用；experiment new从C51当前四文件来源复制，生成前明确核对conv2d.c与Q已接受冻结生产源原字节一致，并绑定job1581822及source_parent。所有修改只在新C52树/自身record，未改C51/Q/R或其他协作者文件。

完整阅读最终paired/remainder块及fullpatch。每列作用域含7个svdup coefficient，按三段输入window各复用到七输出，共3次svld1、21次独立svmul+svadd。第一列全部运算结束后第二列才开始；每个a0..g2沿用单一累加链。没有将两列相加形成partial sum，也没有交错或更换每个输出的kernel行顺序。外层t仍是6..kh−1，其余十二阶段保持u1。

`ik`从0起，paired循环只在kw−ik>=2时执行，因此column=ik+1<=kw−1。正kw下ik不超过kw；成对增量和最后u1增量不会越过INT_MAX。kw1完全跳过paired只走一次原body；kw2走一对、无余列；kw3走一对再一余列；一般偶数为kw/2对，奇数为floor(kw/2)对和一余列。公开入口已检查有效kw；没有引入ik+1<kw形式潜在边界加法。

全block的每列合法边界仍由外层ow−i>=3VL保证，最大输入列为i+3VL−1+(kw−1)；展开第二列最多取kw−1。所有row地址、kernel[t−r]关系、dst指针和store字节没有改。paired body外的原前后字符串逐字保留，其他三个提交文件的身份一致。单列remainder body也逐字保留，只有for声明把ik移动到paired之前。

初次生成后，文本审查发现两个外层作用域结束括号由body尾部空格拼为28空格；在prepared阶段仅整理为16空格，同时修正生成器尾空格处理，并在公共lock内更新checkpoint/source-audit/fullpatch。该修正纯空白，不涉及表达式、控制流或源码来源；没有编译或数值重跑。最终生产SHA256为8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7。

这里只是源码层面的审查，没有目标GCC实际机器码、数值或性能结论。不能继承Q的zero-spill、63指令或37128 PASS为本候选结果。十三语义阶段中的shared现在包含paired主循环和u1余数；未来汇编审查必须分别记录二者真实范围与归一化工作量，不能只用旧13个u1循环的固定门槛接受。
