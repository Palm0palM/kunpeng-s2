# C34 静态审查

相对 C30-colchunks，唯一源码差异是两行任务解码：group 从 work/column_chunks 改为 work%groups，column 从 (work%column_chunks)*256 改为 (work/groups)*256。没有其它源码增删。

用g=work%G、c=work/G和逆映射work=c*G+g核对双射；G/C均正，g<G、c<C。因此每个旧任务恰好保留一次，矩形输出区域不变，原全局ow行距和局部列宽保持。新顺序没有修改任何输入/kernel/output地址表达式的集合，且每个输出仅写一次。

G=1或C=1时与旧顺序相同；最后1..3行和不足256列的任务继续由原helpers处理。所有解码使用size_t；最大任务乘积不超过2^52，row<oh、column<ow，减法不下溢。旧kernel helpers、严格浮点运算顺序、非SVE、runner/benchmark/README均由父快照原样保留。

静态审查不代表编译或正确性通过。实际多线程执行、VL边界、保护页、性能和缓存行为尚未测量；状态仅prepared。
