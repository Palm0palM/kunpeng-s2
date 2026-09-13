# CONV：仅 shared 两列展开的 C52 独立诊断

**C52-row7x3shared2 的 T 作业 1582134 已独立通过 37128/37128 项诊断并冻结。**本轮没有运行原 benchmark 或测量性能；生成本报告时，当前最佳仍为 **C6（C26-r1）**。

C52 以已冻结 Q/C51-row7x3u1 为源码父版本，仅把 `conv_sve_rowseven` 的 shared 阶段 kernel 列循环展开为两列。安全条件为 `kw - ik >= 2`，每个累加器仍先加列 ik、再加列 ik+1，余列沿用原单列循环。七输出行×每行3个SVE向量、21累加器、13个语义阶段保持；其余12阶段、fallback、dispatch、benchmark、runner及其他提交文件保持父版本字节。使用普通独立乘法/加法，没有加入FMA、asm、prefetch或分段累加。

## 实际运行与矩阵

scheduler SUCCEEDED，job/system/wrapper退出均为0，19个作业阶段实际全部退出0。GCC10.3.1、generic、原浮点设置；调度分配38 CPU、24576MiB、单NUMA，诊断团队分别使用1/4线程。编译、执行全部在超算计算节点完成。

| 路径 | 每配置实际通过 | 六配置实际通过 |
| --- | ---: | ---: |
| 未插桩生产 full | 4784 | 28704 |
| 插桩 dispatch | 972 | 5832 |
| 直接 kh<7 防御回退 | 432 | 2592 |
| 合计 | 6188 | 37128 |

| SVE字节 | lanes / 每行主块输出 | 线程 | dispatch入口 / mask | direct入口 / mask |
| ---: | --- | ---: | --- | --- |
| 16 | 4 / 12 | 1 | 756 / 1 | 1080 / 1 |
| 16 | 4 / 12 | 4 | 756 / 15 | 1080 / 15 |
| 32 | 8 / 24 | 1 | 756 / 1 | 1080 / 1 |
| 32 | 8 / 24 | 4 | 756 / 15 | 1080 / 15 |
| 64 | 16 / 48 | 1 | 756 / 1 | 1080 / 1 |
| 64 | 16 / 48 | 4 | 756 / 15 | 1080 / 15 |

L为float lanes。四种分配组合为pad0/1×leading0/1。每配置full的实际细分是3888+144+720+32=4784：

- core 3888：ow取3L−1/3L/3L+1/6L−1/6L/6L+1，kh6/7/8、kw1/2/3、oh1..15/21/22/28、四种分配。
- narrow 144：ow1，kh6/7/8、kw1/2/3、oh1/7/13/28、四种分配。
- small 720：ow1/3L−1/3L+1，kh1..5、kw1/2/3、同四个oh及四种分配。
- larger 32：kernel10×7、9×8、15×15、81×81，ow3L+1、oh7/13、四种分配。

dispatch使用core的972个几何组合，固定pad1/leading0；逐case检查rowseven入口增量，仅kh>=7且oh>=7时为floor(oh/7)，每配置累计756。direct为kh1..6、kw1/2/3、ow3L−1/3L/3L+1、oh7/28、四种分配，共432项、1080次rowseven入口；它进入quad+triple防御路径，不执行shared算术。

kw1跳过paired、只走余列；kw2执行一对、无余列；kw3执行一对加余列。较大kernel另外覆盖kw7/15/81的多对加余列和kw8的多对无余列。正常入口中kh7/8、oh>=7、ow>=3L的子集可进入shared；kh6、窄宽和直接回退检查其边界。两个C检查器保留Q原字节，但这里的PASS来自T自己的作业和原日志。

数值参考是独立ky/kx顺序的scalar实现，以memcmp逐位比较；input/kernel只读、分配两端PROT_NONE、外围canary和输出poison全部通过。没有逐行guard、sanitizer、invalid-dimension、屏蔽SVE或NaN/Inf专项。没有新增L/2L邻域864项，没有direct的ow1，也未覆盖建议中的9×7/8×8组合。五个旧helper的非零入口与worker mask为套件累计证据；没有对13阶段或paired/odd内部做动态计数，入口计数不代表每阶段动态覆盖次数。

## 真实汇编：13语义阶段、14算术区域

完整唯一 `conv_sve_rowseven` 从实际文本行5705读至.size行7053，所有转换、尾部和回退均已检查。shared在实际汇编中形成paired和odd两个loop；odd的条件/回边位于.L454，没有虚构直线块或机器PC。

| 阶段/区域 | label | 实际.s行 | 每轮kernel列数 | 指令 | FMUL/FADD | LD1W/LD1RW | 指令/列 |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| input_0 | .L395 | 5970–5984 | 1 | 14 | 3/3 | 3/1 | 14 |
| input_1 | .L397 | 5993–6016 | 1 | 23 | 6/6 | 3/2 | 23 |
| input_2 | .L399 | 6027–6058 | 1 | 31 | 9/9 | 3/3 | 31 |
| input_3 | .L401 | 6070–6109 | 1 | 39 | 12/12 | 3/4 | 39 |
| input_4 | .L403 | 6122–6169 | 1 | 47 | 15/15 | 3/5 | 47 |
| input_5 | .L405 | 6182–6237 | 1 | 55 | 18/18 | 3/6 | 55 |
| shared/paired | .L407 | 6270–6393 | 2 | 123 | 42/42 | 6/14 | 61.5 |
| shared/odd_remainder | .L409 | 6397–6461 | 1 | 63 | 21/21 | 3/7 | 63 |
| trailing_0 | .L412 | 6482–6537 | 1 | 55 | 18/18 | 3/6 | 55 |
| trailing_1 | .L414 | 6544–6591 | 1 | 47 | 15/15 | 3/5 | 47 |
| trailing_2 | .L416 | 6598–6637 | 1 | 39 | 12/12 | 3/4 | 39 |
| trailing_3 | .L418 | 6644–6675 | 1 | 31 | 9/9 | 3/3 | 31 |
| trailing_4 | .L420 | 6681–6704 | 1 | 23 | 6/6 | 3/2 | 23 |
| trailing_5 | .L422 | 6710–6724 | 1 | 14 | 3/3 | 3/1 | 14 |

paired的123/2=61.5条/列，对照[Q原shared](CONV_SEP13Q.md)的63条/列；odd仍为63条/列。这是静态指令归一化，不是提速、动态指令量或单独回边成本测量。更高地址状态、寄存器活跃期、ABI保存和代码体积都可能影响最终性能。

实际两列的输入/系数确实交错调度并同时存活，局部花括号不能保证编译器分开活跃期。已逐个追踪21累加器的ik→ik+1 FADD；g1在6383行临时由z5转入z2，再于6390行读z2写回z5，仍是同一连续累加链。完整21项顺序表保存在helper片段。14区域均使用普通FMUL/FADD，没有indexed FMUL、LD1RQW、DUP、indexed MOV、EXT或MOVPRFX；整份返回汇编FMA词法计数为0。

完整helper固定栈帧 **720字节**，没有Z/Q/谓词spill。实际保存D8/D9、D10/D11、D12/D13和D14，共 **7个低64位ABI寄存器**，均对应恢复；这些不等同于SVE累加器spill。sp+664的间接地址只访问标量X指针槽，其他栈槽为标量状态/出栈参数。13阶段转换、pair→odd→下一输入行、21个ST1W、每次i+=3L、横向quad+triple尾部、kh<7防御路径与early-return恢复均按实际产物核对。

## 完整dispatch审查

| 实际函数 | 实际.s行 | 固定栈帧 | 路由/栈要点 |
| --- | --- | ---: | --- |
| conv2d._omp_fn.2 | 662–2269 | 368字节 | 原非SVE逐输出行worker；局部32-float tile有14个STR Q写栈点，属于实际tile物化，区别于SVE累加器spill。 |
| conv2d._omp_fn.1 | 7058–7237 | 160字节 | 四行worker；余3/2/1分别triple/pair/prefix，无向量/谓词栈访问。 |
| conv2d._omp_fn.0 | 7241–7557 | 240字节 | 七行worker；余6为quad+pair，余5为quad+prefix，余4/3/2/1走旧helper；无向量/谓词栈访问。 |
| conv2d | 7562–7733 | 160字节 | 公共入口检查有效尺寸与HWCAP；SVE且kh>=7、oh>=7走七行，否则SVE四行或原非SVE；无向量/谓词栈访问。 |

root完整读取三个改变布局的实际dispatch函数。非SVE .omp_fn.2的全部文本逐字等于Q原件，包括标签、指令和汇编指示符，因此保留Q已有完整审查（Q同时保存其与独立审过C47全文相同的依据）；没有用局部相似性替代完整函数证据。该非SVE函数没有Z/谓词栈访问，但明确保留上述NEON tile写栈，不声称全源没有向量栈流量。

## 原件、身份与当前结论

- C52源码SHA256：`8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。
- 本次生产汇编SHA256：`e42a1f618c0007479b282f963829b654b6d1b5a8dc8301c702f296586f8df220`。
- 源码父版本为已冻结Q/C51；T独立运行、审查与冻结自身产物，Q的PASS不代替T。
- 冻结目录：`.runs/conv/C52-row7x3shared2/sve-correctness-sep13t/`，保留原源码、原日志、scheduler、19阶段退出、首次清单、helper/dispatch片段、完整validation及工具文本。
- 原生产.s与.assembly.txt逐字相同；没有生产.o，不宣称对象反汇编一致。

冻结保留首次prepared README/INTERFACE和source checkpoint的原始历史语义，未把它们改写成运行结果；本轮最终状态以passed validation、root acceptance decision和freeze-source为准。接受/冻结是本机文本整理，接受器与冻结器各执行一次成功，无schema修改。

诊断通过及零spill不提供性能晋级资格。C52尚无本轮原benchmark速度、官方分数、排名或新提交包；当前最佳仍是C6。[S作业1582067对C51的独立确认失败](CONV_SEP13S.md)保持原判，不重写、不重跑该失败确认，也不借它的样本证明C52。后续性能测量需root独立审查后另行安排。

本报告生成器只读取已完成原件并写本页，不改源码、record、包或发布副本，没有创建/运行任何作业，没有在本机运行算子，也没有使用重置卡。

后续记录：本页保持 T 诊断完成时的状态；C52 后来在 [W 作业1582256](CONV_SEP13W.md) 完成48个原benchmark样本并通过两端C6初筛。W的性能数据单独保存，不回填或混入T诊断。
