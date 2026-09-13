# C48 M 单包静态审阅

仅对新模板做轻量文本检查，无本机编译、算子、测试、SSH、作业提交或重置。原始生产候选已独立审核；本文件不代替它，也不声称新模板已动态通过。

- 生产副本来自冻结 C48-row8x2u1，并在五文件初次manifest时与checkpoint的conv2d.c摘要关联。没有改写它；sourceparent保留C40-row6x3u1。
- 与L模板的full guard差异仅main里的width/height/kernel数组、循环范围和最终计数常量。main前的逐位reference、RNG、只读mprotect、guard/canary/poison、SVE worker/team检查原文保持。
- 实际core6宽×3kh×3kw×20oh×4放置=4320；narrow144、small864、larger32，总5360。1080分派与504direct分开计数，总41664为计划；不是运行结果。
- public逐case roweight增量严格符合实际源码 `kh>=8 && oh>=8` 与floor(oh/8)。height1..17/24/25/32覆盖不进入、整组、余1..7、2/3组后尾1和4worker；792总入口由独立权重22推导。
- direct adapter只接受oh8/32、kh1..7、kw>=1。row/group/output stride均先转size_t；每组传入8个global ow间隔的dst。最后dst+7*ow仍在该组合法最后行。输入最高访问row+7+kh−1<=height−1。各组写各自8行，没有重叠。
- direct强制防御kh<8的两次quad路径；504case和1260入口与循环一致。公共及direct各自mask1/15；计数用原子，加减发生在one_case返回（OMP join）后，adapter切换/重置不与worker并发。
- 实际候选只有roweight及旧quad/triple/pair/prefix/tail；插桩符号与其接口一致，无残留rowsix符号、六行直接调用或额外smoke参数。旧5helper的非零入口来自public矩阵；不凭源码推测动态计数通过。
- 包装候选/shape/六计数常量、19阶段顺序、三GCC命令与manifest文件集相符；EXPECTED_ACC=2仅影响diagnostic期望block。原严格浮点flags、38CPU单NUMA、OMP close/cores和退出保留逻辑未变。
- 尚未得到实际15阶段汇编、FMA/spill/ABI/dispatch检查，也没有生产.o（wrapper未保留）；不能把未插桩.s当作已执行验收，更不提供性能或晋级结论。
