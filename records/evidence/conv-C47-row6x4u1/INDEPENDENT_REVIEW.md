# C47 六行×4VL 独立源级审查

未发现阻止建立独立诊断包的源级问题。只读 C40/C47 全文件差异及 rowsix/dispatch 上下文；本报告不代表编译、正确性或性能通过。没有修改源文件、benchmark、runner、其它实验或正式版。

实际 diff 仅在 `conv_sve_rowsix`：block 从3L改为4L，六行各新增索引3累加器，十一阶段各新增一个 `row + ik + 3*lanes` 输入scope，末尾六个索引3store。原 n0/1/2 更新、每阶段的系数/行指针、所有循环及 helper 前后文本未改。新增 n3 的活动输出依次为a；ab；abc；abcd；abcde；abcdef；bcdef；cdef；def；ef；f，与同阶段 n2 映射一致。

| 阶段 | 输入行 t | 活动输出 r | 对应 kernel 行 |
| --- | --- | --- | --- |
| 五个 leading | 0..4 | 0..t | t−r |
| shared | 5..kh−1 | 0..5 | t−r |
| 五个 trailing，p=0..4 | kh+p | p+1..5 | kh+p−r |

每个输出 r 正好依次消费输入行r..kh+r−1，kernel行0..kh−1各一次；同一行内 `ik=0..kw−1` 单列递增。n3是另一组独立输出列，没有拆分或重排既有输出的累加链。每更新保持 `svmul_f32_x(input,coef)` 后 `svadd_f32_x(acc,product)`；未加入FMA、lane、asm、预取或fast-math。

设 L 为实际正的SVE float lane数。满块使用 `ow-i>=4L`，因此 `i+4L<=ow`；最后输入lane为 `i+ik+4L−1<=ow+kw−2=inputWidth−1`，最后store为 `i+4L−1<=ow−1`，没有读取第五完整向量。`i+=4L`保持 i≤ow，循环判断没有先形成可能溢出的 `i+block`。合法SVE长度使4L可表示为int。有效输入/输出数组可寻址契约沿用原接口。

完整六行组首行j满足j+5≤oh−1。最大输入行仍为j+kh+4≤inputHeight−1；相关行offset在加偏移/乘stride前采用size_t，新增n3没有引入行乘积。kh=6时shared有一次t=5，首尾阶段均有效；kw=1及奇偶列数都走同一单列循环。直接调用kh<6仍先quad+pair后return，不形成六行主块指针。

满块写区间 `[i,i+4L)`；余数 `[i,ow)`仍由原quad+pair处理，原input stride和六个全局dst行起点不变。ow<4L、恰等4L、多个完整块与余0..4L−1都无重复或漏写。六行OMP分组及末余1..5行的quad/prefix/triple/pair组合原样保留，组间输出不相交。其它helpers、非SVE和invalid入口不变。

24累加器增加了寄存器压力。源级单input/六coef/乘积预算约32个向量值，但GCC可重排；这既不能证明无spill，也不能证明提速。必须重新审查目标GCC10.3.1的十一阶段、转场、整个helper的直接/间接栈访问与ABI保存及全源码FMA。C40的26112个历史PASS不能替代C47新增4VL边界验证。

准备身份转录自checkpoint：`e974915cb4e5e522526070bfdcff42b08dd7866412dbde11c76a07fac1b86d0a`。当前只准备独立L诊断包；未本机编译/测试，未SSH/提交/使用重置卡。
