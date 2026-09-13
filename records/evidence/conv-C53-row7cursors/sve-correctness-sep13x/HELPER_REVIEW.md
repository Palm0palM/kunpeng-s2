# X / C53 实际 rowseven helper 审阅

原作业1582372真实SUCCEEDED，job/system均0；本代理仅恢复其status/fetch，未提交或重试作业。首次status因沙箱SSH权限失败，原始exit255及外层exit1均保留；间隔超过45秒后第二次status成功，随即通知root终态，原fetch一次exit0。外层stdout/stderr/exit/events和root提交来源摘要均在本包lifecycle文件中。

原六配置VL16/32/64字节×线程1/4逐个读取：full4784、dispatch972、direct432，总37128；入口756/1080，mask1/15，旧helper非零；19个有序stage退出0、wrapper0、GCC10.3.1与三条实际编译xtrace齐全。未调用accept/freeze；这些是原件观察，完整验收由root完成。

实际未插桩conv2d-sve.s SHA256：`19caa0d23ad506423a1f2709778cb9f92afd330e10854183a2cedc6ac03d2f63`。source SHA为`d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`。仅一个rowseven符号，没有clone；完整范围5705..6878逐行读完，含1037条静态指令。

## 游标假设的实际结果

目标地址指令没有消除。shared .L4076253..6316仍63条/列：21普通FMUL、21独立FADD、3LD1W、7LD1RW、1LSL、8ADD、CMP、BGT。实际Q父shared6243..6306的对应数量相同。LSL6254、七个系数地址ADD6256/6264/6271/6280/6287/6296/6298仍在，另外6291的ADD只递增ik。外层6317..6323仍逐个将七个行首加kw*4；没有推定流水或时间收益。

编译器将源连续游标规范为行首+ik；外层七个ADD被放在.L406标签之前，因此kw<=0跳过它们。寄存器分配、准备代码及控制流位置存在真实变化，不声称整份机器码相同。只可得出本单一假设预期的LSL/地址ADD删除没有发生。

Actual setup5749..5769 saves immutable kernel row1 atsp400,row2 at408,row5 at416,row3 at424,row4 at432,row6 at440; x20 retains kernel row0. On every tile .L3946230,6238 initializes x11=x20 and6239..6242 reload x10=row1,x9=row2,x6=row5,x8=row3,x7=row4,x5=row6. x22 is output-column byte offset and .L4215946 is reached after incrementing it by x21=3*L*4. Kernel initialization slots are not advanced in the tile-update path, so every tile, including the second full tile at ow>=6L, resets seven shared bases correctly. .L408 itself never resets them between t values.

GCC canonicalizes source *ka++..*kg++ back to row-base plus ik. For positive kw, x13 formed5817/5907 equals4*kw. w18 starts6 at6240; x1 starts0 at6251, increments1 at6291, and cmp/bgt6315..6316 reads exactlykw columns. Each effective coefficient is base_r+4*ik. On row completion6317..6323 add x13 to seven bases, then6325 increments t;6328 compares against kh inw15. Thus base_r at(t,ik) is kernel+4*((6-r)*kw+(t-6)*kw+ik)=kernel+4*((t-r)*kw+ik). The machine uses seven row-step ADDs, not seven emitted per-element cursor ADDs.

kh7 executes onlyt6, kh8 executes t6/t7, and longerkh repeats until incremented t==kh at6328. Each row reads ik0..kw-1; final output0 coefficient address is kernel+4*(kh*kw-1), then final6317 advances x5 to kernel+4*kh*kw but6329 does not branch back, so that one-past base is never dereferenced. Other six endpoints stay within the kernel object. Trailing setup overwrites x5/x6 with input pointers and uses separate precomputed coefficient bases. kh<7 and insufficient-width paths avoid shared entirely. kw<=0 takes6250 directly to .L406 and skips arithmetic and seven row-base advances; public positive-size restrictions remain the normal call contract. No broader invalid-size runtime coverage is claimed.

输入x12/x3/x4分别是rowt的第0/1/2向量基址（x12=x3−4L），仍通过ik缩放索引读取；x22=i*4、x21=3L*4、x23=stride*4。kernel行首槽不会随tile更新，下一tile重新加载，跨t则只推进行首。最终ka一过末端没有读取；trailing阶段使用独立原地址。

## 全部十三个实际u1阶段

| 阶段 | 实际label | 包含行范围 | 指令数/列 | 普通FMUL/FADD对 | LD1W/LD1RW |
| --- | --- | --- | ---: | ---: | --- |
| input_0 | .L395 | 5960..5974 | 14 | 3 | 3/1 |
| input_1 | .L397 | 5984..6007 | 23 | 6 | 3/2 |
| input_2 | .L399 | 6018..6049 | 31 | 9 | 3/3 |
| input_3 | .L401 | 6061..6100 | 39 | 12 | 3/4 |
| input_4 | .L403 | 6113..6160 | 47 | 15 | 3/5 |
| input_5 | .L405 | 6174..6229 | 55 | 18 | 3/6 |
| shared | .L407 | 6253..6316 | 63 | 21 | 3/7 |
| trailing_0 | .L410 | 6339..6394 | 55 | 18 | 3/6 |
| trailing_1 | .L412 | 6400..6447 | 47 | 15 | 3/5 |
| trailing_2 | .L414 | 6453..6492 | 39 | 12 | 3/4 |
| trailing_3 | .L416 | 6498..6529 | 31 | 9 | 3/3 |
| trailing_4 | .L418 | 6534..6557 | 23 | 6 | 3/2 |
| trailing_5 | .L420 | 6562..6576 | 14 | 3 | 3/1 |

All13 actual u1 ranges read in order. Their ordinary FMUL/FADD pairs are3/6/9/12/15/18/21/18/15/12/9/6/3; every range has3 LD1W and1/2/3/4/5/6/7/6/5/4/3/2/1 LD1RW. No indexed FMUL, FMA, packed LD1RQ, EXT, lane-copy or MOVPRFX occurs in these ranges. Accumulator mapping is a=(z21,z22,z7), b=(z19,z20,z6), c=(z23,z24,z16), d=(z25,z26,z17), e=(z27,z28,z18), f=(z29,z30,z4), g=(z31,z8,z5). Input loads stay within each original full3VL window and every individual accumulation retains kernel row/column order.

全源FMA词法扫描0。上述区域均work=1、互不重叠，没有T paired/odd schema；每区域源映射和spill解释已写入片段，接受器仍应自行从实际.s派生数量。

## 栈、转换、存储和返回

Actual5708 allocates fixed656 bytes; x29=sp16. Integer ABI x29/x30 at16 and x19..x28 at32..96; D8/D9 at112 and D10/D11 at128 are two ABI save/restore pairs, not hot SVE spills. Caller-stack arguments at old sp+0/8/16/24/32 are read as currentsp656..688. Outgoing fallback slots are currentsp0/8; tail calls store outgoing width at currentsp656 before restoring sp. Persistent scalar/input/kernel/output/loop state occupies frame144..648, including shared save pair312/320. Conditional save paths and normal, no-tile, kh<7 and tail-call exits were fully read.

No Z/Q/predicate load/store spills anywhere in the complete helper, including setup, all13 phases, transitions, stores and fallback paths. All21 ST1W sites6586..6635 address seven output rows, not stack. The only floating register stack operations are ABI D8..D11 saves/restores. Scalar address storage is real and nonzero; x18=sp496 at5835 gives indirect STP sites5848 and5851 (sp496/504 andsp632/640). Those four saved values are scalar addresses, not vectors.

The source cursors do not eliminate actual scalar address work: shared contains one standalone LSL, seven coefficient-address ADDs plus ik ADD, and seven outerkw-byte ADDs remain. Per tile .L394 saves/restores scalarx27/x15 and reloads kernel bases from immutable frame slots. Frame remains656 bytes and contains extensive scalar pointer caching. Whole-helper static stack instruction counts (all ABI, incoming/outgoing arguments and alternate exits included; not dynamic costs) are LDR95,LDRSW1,STR87,LDP28,STP14, including two indirect STP atsp496/632 and two D ABI save/restore pairs. None of these whole-helper counts imply a speed gain or zero scalar spill cost.

Read all gaps around thirteen regions. Leading phases initialize newly active row accumulators, load scalar row pointers and reset ik. .L3946230 saves x27/x15 atsp312/320, initializes g0..2 and reloads all seven kernel bases afresh. Shared rows iterate .L408..L406 and restore x27/x15 at6331 before trailing phases. Trailing setup uses independent precomputed kernel rows and input pointer slots, not the expired shared cursors. After21 output stores,6636..6693 advance cached input addresses and vector offsets by the3VL byte step;6696 returns to .L421, therefore every later tile executes .L394 reloads. No vectors are stored between phases; address stack traffic and two ABI D pairs are recorded separately.

kh<=6 branches5738 to .L3916827: passes full ow to rowquad for outputs0..3, then restores frame and tail-calls rowtriple at6860 for inputs+4*stride and outputs4..6. kh>=7 with ow<3L branches5747 to .L4516861, sets i=0 and enters common width-tail dispatch. After full tiles, .L3936706 compares ow/i; .L4526766 calls rowquad for remaining columns on first4 rows, preserves remaining width atsp144, then tail-calls rowtriple6826 on rows4..6 with byte-offset i applied once. Normal return6728 and all conditional saves/restores were read. No helper clones exist in this .s.

实际五文件源manifest与准备清单的固定C53身份一致；不借Q/T正确性或机器码结果作为C53 PASS。完整helper的观察为Z/Q/谓词spill0，标量地址栈非零；没有把ABI D保存算作热循环spill，也没有把固定656B或63条指令直接换算成性能。数值矩阵仍无sanitizer、逐行guard或内部阶段动态计数，suite入口/mask不能证明每个汇编阶段的动态次数。

本片段helper_review_complete=true，但review_complete=false、dispatch_review_pending=true。root另行读dispatch并合并/accept/freeze；本代理不合并、不验收、不冻结、不更新source/record，不进行性能、ZIP或晋级。所有已取得原件保留；账户达到用户40%限制时必须停止所属工作且不使用重置卡。当前有界helper职责完成，STOP。
