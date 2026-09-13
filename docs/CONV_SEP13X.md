# CONV Sep13 X：C53 shared 权重游标诊断

C53-row7cursors 的原作业 **1582372** 已完成：**37128 项数值检查 PASS、19 个有序阶段退出全0、scheduler/job/system/wrapper全0**，root 用未改验收工具执行一次接受、退出0，再执行一次原样冻结、退出0。该结果验证了本次有界数值和实际汇编证据；**未测性能、未晋级、未生成提交包**。本文写作时只读当前最佳仍为 **C6（C26-r1 / C26-row4loads）**，不推断 Y 或其他并行实验的结果。

原来源为 C51-row7x3u1；C53只将 shared 的七个权重行访问写成跨 t 延续的游标，每个输出 tile 重置，保持7行×3 SVE向量、21累加器、13个u1阶段及原尾部/回退。源码SHA为 `d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`。自身 X 冻结证据位于 `.runs/conv/C53-row7cursors/sve-correctness-sep13x`，父Q或T的PASS不充当C53结果。

## 实际执行和失败留痕

| 环节 | 实际结果 | 原件 |
|---|---|---|
| root唯一提交 | 原job1582372，提交返回0 | lifecycle-submit-source.json、submit.log、job.json |
| 首次status | SSH查询255，外层driver1；沙箱权限禁止连接，未取得调度状态 | lifecycle-status-1.*、status-failed-20260912T173851537655Z.json |
| 后续同job status | 返回0，原1582372为SUCCEEDED，job/system0 | lifecycle-status-2.*、scheduler.log |
| 原job fetch | 一次返回0 | lifecycle-fetch-1.*、raw/ |
| root acceptance | 原工具一次，返回0 | acceptance-exit.json、acceptance-output.log、acceptance-stderr.log、root-acceptance-decision.md |
| root freeze | 原工具一次，返回0；passed目录原子冻结 | freeze-source.json，外层sep13x-freeze-output.log / sep13x-freeze-stderr.log |

首次SSH的 `Operation not permitted` 是本机沙箱连接失败，**不是算子FAIL，也不是计算节点退出255**。保留原失败、之后的成功输出及同一job ID，没有重复提交或用本机测试替代。root提交来源文件明确是完成工具输出的来源摘要；不把它冒充本报告作者的提交原始输出。freeze退出0依据root此次完成调用及现有输出/冻结目录，未补造独立freeze-exit文件。

所有算子编译和运行都在调度计算节点；分配38 CPU（76–113）、24576 MiB、一个packed NUMA（实际node2）、1800秒。实际编译器GCC10.3.1，三条编译命令的xtrace保留在probe.log；共同flags为 `-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3`。full与生产源分TU，只有dispatch带`-finstrument-functions`，生产汇编使用未插桩`-S conv2d.c`。没有对象反汇编或sanitizer。

## 六个配置和实际数值矩阵

L为float lanes，每行完整主块3L。每个配置full4784、dispatch972、direct432，合计6188；六配置分别累计full28704、dispatch5832、direct2592，总计37128。官方runner案例数为0，这不是48/36样本性能测量。

| SVE字节 | 线程 | L | 主块输出/行 | full | dispatch | direct | dispatch/direct入口 | 两路径worker mask | 结果 |
|---:|---:|---:|---:|---:|---:|---:|---|---|---|
| 16 | 1 | 4 | 12 | 4784 | 972 | 432 | 756 / 1080 | 1 / 1 | PASS |
| 16 | 4 | 4 | 12 | 4784 | 972 | 432 | 756 / 1080 | 15 / 15 | PASS |
| 32 | 1 | 8 | 24 | 4784 | 972 | 432 | 756 / 1080 | 1 / 1 | PASS |
| 32 | 4 | 8 | 24 | 4784 | 972 | 432 | 756 / 1080 | 15 / 15 | PASS |
| 64 | 1 | 16 | 48 | 4784 | 972 | 432 | 756 / 1080 | 1 / 1 | PASS |
| 64 | 4 | 16 | 48 | 4784 | 972 | 432 | 756 / 1080 | 15 / 15 | PASS |

每个配置旧helper实际累计入口相同：prefix8550、tail8550、rowpair234、rowtriple2106、rowquad1458，均非零。dispatch/direct分别核对入口756/1080，1线程mask1、4线程mask15。计数和mask是套件累计信息；rowseven的逐case增量不等于13阶段或游标步进的内部动态计数。

| 矩阵部分 | 每配置实际数 | 覆盖 |
|---|---:|---|
| full core | 3888 | ow=3L−1/3L/3L+1/6L−1/6L/6L+1；kh6/7/8；kw1/2/3；oh1..15、21、22、28；pad0/1×leading0/1 |
| full narrow | 144 | ow1；kh6/7/8；kw1/2/3；oh1/7/13/28；四分配 |
| full small | 720 | ow1/3L−1/3L+1；kh1..5；kw1/2/3；同四高/四分配 |
| full larger | 32 | kernel10×7、9×8、15×15、81×81；ow3L+1；oh7/13；四分配 |
| dispatch | 972 | core固定pad1/leading0；仅kh≥7且oh≥7时逐case rowseven入口=floor(oh/7) |
| direct防御回退 | 432 | kh1..6、kw1/2/3、ow3L−1/3L/3L+1、oh7/28、四分配；调用quad+triple，不执行shared游标 |

独立reference按ky/kx标量顺序产生结果，以memcmp逐位比较。input/kernel只读，分配两端PROT_NONE、页内外围canary、输出poison。kh7验证一次shared t，kh8验证跨t；较大kh验证更长序列。ow≥6L覆盖至少第二个完整tile重置；6L邻域覆盖阈值及尾部。七行分组的余1..6均在oh矩阵内。kw1/2/3仍是u1检查，不能套用T的paired/odd动态解释。

边界不足保留：没有逐行独立guard、sanitizer、invalid-dimension、屏蔽SVE或NaN/Inf专项；没有补加L/2L邻域864项；direct没有ow1；未测9×7/8×8。正常ow1路径不能代替direct ow1。static fallback审查与这些runtime缺口分别记录，不能扩大覆盖结论。

## 全部19个真实作业阶段

以下顺序与raw/stage-exits.txt一致；最终raw/exit-code.txt为0，完整probe结束标记存在。

| 顺序 | 阶段 | 退出码 |
|---:|---|---:|
| 1 | allocation | 0 |
| 2 | compiler | 0 |
| 3 | manifest | 0 |
| 4 | build-guard | 0 |
| 5 | guard-vl16-t1 | 0 |
| 6 | guard-vl16-t4 | 0 |
| 7 | guard-vl32-t1 | 0 |
| 8 | guard-vl32-t4 | 0 |
| 9 | guard-vl64-t1 | 0 |
| 10 | guard-vl64-t4 | 0 |
| 11 | build-dispatch | 0 |
| 12 | dispatch-vl16-t1 | 0 |
| 13 | dispatch-vl16-t4 | 0 |
| 14 | dispatch-vl32-t1 | 0 |
| 15 | dispatch-vl32-t4 | 0 |
| 16 | dispatch-vl64-t1 | 0 |
| 17 | dispatch-vl64-t4 | 0 |
| 18 | build-assembly | 0 |
| 19 | complete | 0 |

## shared游标假设的实际结果

未插桩生产汇编SHA为 `19caa0d23ad506423a1f2709778cb9f92afd330e10854183a2cedc6ac03d2f63`。实际仅一个 `conv_sve_rowseven`，没有clone；完整label到.size为5705–6878，共1037条静态指令。root已合并helper与dispatch独立片段后验收；最初helper片段中的review_complete=false只表示它当时不负责dispatch，最终validation的review_complete/dispatch_reviewed均true。

**目标地址指令未消除。** shared `.L407` 的6253–6316仍为每列63条：21普通FMUL、21独立FADD、3 LD1W、7 LD1RW、1 LSL、8 ADD、CMP、BGT。8 ADD中7个形成系数地址，另1个递增ik；6317–6323的7个外层ADD继续将各行首推进kw×4。父Q对应shared数量同为63，但准备代码、寄存器分配和控制位置有变化，不能声称整份机器码相同，更不能从同一指令数推断运行时间。

实际LSL在6254；7个系数地址ADD在6256/6264/6271/6280/6287/6296/6298，ik ADD在6291。编译器将源码连续游标规范回“行首+ik”，跨t仍用7个行步进ADD。外层步进位于.L406之前，kw≤0分支会跳过它们；这条静态分支观察不补充invalid-size的运行覆盖。

每tile的.L394重新从不可变槽载入kernel行0..6，各向量主块后返回.L421，第二tile重置成立；跨t不重置行首。对输出行r，以字节地址表示，实际系数地址为 `kernel_base + 4*((t-r)*kw+ik)`，ik遍历0..kw−1。最终输出0读取kernel最后一个合法元素后，行首可到整个kernel一过末端，但循环已退出、不解引用；trailing使用独立预计算地址。kh<7或宽度不足避开shared。

## 十三个实际u1算术区域

所有区域work=1，互不重叠；X为13语义阶段/13区域，没有T的shared双block。接受器从本次实际.s派生数量，各区域没有indexed FMUL、FMA、LD1RQW、DUP/indexed MOV、EXT或MOVPRFX；全源FMA计数0。

| 阶段 | label | 实际行范围 | 指令/列 | 普通FMUL / FADD | LD1W / LD1RW |
|---|---|---|---:|---|---|
| input_0 | .L395 | 5960–5974 | 14 | 3 / 3 | 3 / 1 |
| input_1 | .L397 | 5984–6007 | 23 | 6 / 6 | 3 / 2 |
| input_2 | .L399 | 6018–6049 | 31 | 9 / 9 | 3 / 3 |
| input_3 | .L401 | 6061–6100 | 39 | 12 / 12 | 3 / 4 |
| input_4 | .L403 | 6113–6160 | 47 | 15 / 15 | 3 / 5 |
| input_5 | .L405 | 6174–6229 | 55 | 18 / 18 | 3 / 6 |
| shared | .L407 | 6253–6316 | 63 | 21 / 21 | 3 / 7 |
| trailing_0 | .L410 | 6339–6394 | 55 | 18 / 18 | 3 / 6 |
| trailing_1 | .L412 | 6400–6447 | 47 | 15 / 15 | 3 / 5 |
| trailing_2 | .L414 | 6453–6492 | 39 | 12 / 12 | 3 / 4 |
| trailing_3 | .L416 | 6498–6529 | 31 | 9 / 9 | 3 / 3 |
| trailing_4 | .L418 | 6534–6557 | 23 | 6 / 6 | 3 / 2 |
| trailing_5 | .L420 | 6562–6576 | 14 | 3 / 3 | 3 / 1 |

## 栈和完整dispatch的范围

rowseven固定frame656字节。D8/D9和D10/D11在112/128处形成两对ABI保存/恢复，不能算作SVE热累加器spill。整个helper的setup、13阶段、转换、21输出stores、尾部及防御路径均已审，Z/Q/谓词spill为0；21个ST1W写七行输出，不写栈。

标量栈访问仍真实非零：whole-helper静态栈指令位置计数LDR95、LDRSW1、STR87、LDP28、STP14，含ABI、入/出参、替代返回路径及间接STP；不是动态执行次数或纯spill成本。x18=sp496引出的两个间接STP保存标量地址。固定frame与零向量spill不能被写成“零栈访问”或速度收益。

root核对四个完整dispatch函数文本均与已审Q逐行相同（含labels/directives，无归一化），另直接读完三个SVE/public函数；legacy `.omp_fn.2`保留完整Q/C47审阅及此次全函数相等证据。这个相等范围仅是四个函数文本，**whole_machine_code_identical_claimed=false**。

| 实际函数 | 行范围 | frame | 范围说明 |
|---|---|---:|---|
| conv2d._omp_fn.2 | 662–2269 | 368 B | 原按输出行分派；non-SVE/NEON路径有14个Q栈tile-store位置，属于真实tile存储，不是rowseven SVE spill |
| conv2d._omp_fn.1 | 6883–7062 | 160 B | 原四行SVE分派与4/3/2/1余数组合，无向量/谓词栈访问 |
| conv2d._omp_fn.0 | 7066–7382 | 240 B | ceil(oh/7)分组；余6 quad+pair、5 quad+prefix、4quad、3triple、2pair、1prefix，保留global stride |
| conv2d | 7387–7558 | 160 B | 正尺寸/越界kernel早退、HWCAP SVE分支、kh≥7且oh≥7新分派，其余SVE与non-SVE原回退 |

因此“Z/Q/谓词spill为0”明确指完整rowseven helper的审查结论，不抹掉legacy worker的实际Q栈tile存储，也不抹掉标量地址缓存。

## 冻结与结论

原source、raw、首次清单、沙箱失败、恢复status/fetch、helper/dispatch片段、合并审查和接受输出均保留。freeze-source的acceptance_executed=false表示冻结器没有再次运行接受；与之前root一次accept退出0不矛盾。raw/conv2d-sve.assembly.txt是原.s同字节文本导出，不是重新编译。

主要证据：冻结目录中的validation.json、root-acceptance-decision.md、HELPER_REVIEW.md、assembly-helper-review.json、assembly-dispatch-review.json、assembly-review.json、raw六对guard/dispatch日志、raw/stage-exits.txt、scheduler.log、acceptance-exit.json、freeze-source.json及lifecycle文件；冻结外层输出为 `.runs/conv/sep13x-freeze-output.log` 和 `sep13x-freeze-stderr.log`。

本轮得到C53自身的数值PASS和实际代码生成说明，游标预期消除的地址指令没有消除。没有C53性能样本或两端C6性能比较结果，也未开展确认、ZIP或晋级；本文不把静态指令或spill计数换算为时间，也不推断并行Y结果。写作历史时点最佳保持C6，后续决策由root另行审查。
