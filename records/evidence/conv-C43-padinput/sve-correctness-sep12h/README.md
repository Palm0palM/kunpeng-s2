# C43-padinput 内存布局诊断包（prepared）

没有编译、执行guard/算子、SSH或提交作业；不创建job.json、不使用重置卡。仅候选目录的四个冻结提交文件原字节复制，生产源不插桩、不修改benchmark/run.sh。当前没有PASS或性能结果。后续提交、fetch、验收和冻结由根/Avicenna统一管理，本包不含公共driver或acceptance工具。

## 精确矩阵

六配置：SVE 16/32/64字节 × 1/4线程；remote_job在任何编译/计算前检查Linux/AArch64、38获分配CPU、单NUMA，使用原严格GCC flags、generic、CONV_BLOCK32/UNROLL2和OpenMP。实际编译命令、compiler、分配和各阶段退出保留。原runner不执行，所以runner_cases=0，不能将本包作为三个独立官方性能套件。

1. **生产对象逐位guard：24100项/配置。** 原C26标准full18052项原样保留（43宽×19核×4放置基础3268，加24边界宽×14核×11输出高度×4放置14784）；再加下述真实输入宽度gate矩阵6048项。
2. **独立插桩，成功模式：6048项/配置。** 仅gate矩阵，候选malloc真实分配并将未复制空间毒化；核对门槛、分配量、每行复制地址/字节数、实际stride、释放次数及释放前完整输出。
3. **独立插桩，强制NULL模式：6048项/配置。** 相同gate矩阵，只有候选自己的malloc被强制返回NULL；未影响guard/reference/libc分配。每个结果仍须与原有序逐位scalar相等，不新建快路径或改调用参数。

Gate矩阵：实际inputWidth=63/64/65/79/80/81/95/96/97/127/128/129，kh=3/4/5，oh=3/4/5/7/8/9，kw=1/2/3/7/16/31/63，原4种placement（pad0/1×leading0/1）。全部kw<=inputWidth，ow=inputWidth-kw+1为正；12×3×6×7×4=6048。基线矩阵另含oh6等，保留1..3余行与满/尾向量覆盖；gate矩阵故意包含不启用的width63、width80不改stride、kh3及oh3。

每版计划 **(24100+6048+6048)×6=217176项**：生产对象144600、成功模式36288、失败模式36288。两版合计计划434352。默认生产guard不运行旧smoke96分支，也不执行额外finstrument函数入口检查；不能把未运行内容加入计数。

## 每配置内存路径预期

| 模式 | 总case | 触发门槛 | 不触发 | malloc尝试 | 成功malloc | 强制NULL | memcpy行调用 | free调用 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| success | 6048 | 2800 | 3248 | 2800 | 2800 | 0 | 28280 | 2800 |
| failure | 6048 | 2800 | 3248 | 2800 | 0 | 2800 | 0 | 0 |

触发条件：10个inputWidth（排除63/80）×2个kh（4/5）×5个oh（4/5/7/8/9）×7kw×4placements=2800。成功模式复制行总数：10×7×4×[sum(oh+3)+sum(oh+4)]=280×(48+53)=28280。所有6配置的成功分配/释放各16800、成功复制行169680；NULL模式另有16800次失败尝试，零复制/释放。

C43期望实际stride为奇数16float行距，C44期望实际stride为原width；两者都须分配同一个padded_stride×height×sizeof(float)容量。探针在小域用独立递增到奇数16float倍数的方法计算期望，而非复制生产的位运算公式。最大gate高度13、宽129、padded_stride144，单次探针分配最多7488字节。

## 生产对象与插桩对象隔离

生产conv2d.c以原kernel flags单独编译为production-conv2d.o，再和未插桩的check_conv_guard.o链接。原scalar计算、memcmp逐位、guard页、只读input/kernel、output NaN/canary、线程及worker VL保留。对象反汇编和同生产flags的.s分别保存，不能将插桩代码当生产机器码。

instrumented_candidate.c预先包含所有候选标准/平台头，再仅用局部宏将该TU源码内malloc/free/memcpy映射到candidate_*；随后包含原conv2d.c。guard、copy_probe.c和运行库分别编译，不受宏影响，也不使用LD_PRELOAD或全进程malloc拦截。没有-finstrument-functions，没有更改helper。内存路径入口靠三个候选调用hook证明，不宣称有本包helper函数插桩入口结果。

成功分配初始化整个副本为NaN位模式0x7fc12345，复制hook核对每个目标行偏移/源行/长度并原子记录row_seen。free hook要求每行恰复制一次，payload仍逐位等于原input，padding或C44末尾闲置区未写，并在真实free之前memcmp完整输出与guard已计算的reference。之后候选返回时再次核对分配/复制/free总数，原guard也照常比较输出。这检验释放前计算结果已完成，线程结束顺序另由源码隐式屏障静态证明。

NaN padding帮助发现padding被算入结果，不是对任意未使用读取的硬件追踪证明；不据此声称所有潜在读取被监测。底层真实malloc意外失败也视为诊断失败，保留日志；强制NULL仅作用于明确定义的failure模式。

## 只做静态证明的范围

512MiB上限、SIZE_MAX乘加拒绝及极端int输入不做超大分配/巨量计算或非法buffer调用。它们只依据冻结候选的先检查后运算、容量上界和有效调用存储契约作静态证明，尚无端到端PASS；不能用小矩阵数量掩盖此范围。没有sanitizer、官方runner或性能测量结论。原C43/C44的分配/复制/free本来就位于conv2d计时内，不修改benchmark来扣除开销。

## 文件与后续验收

source内10文件：四原提交文件，加check_conv_guard.c/copy_probe.h/copy_probe.c/instrumented_candidate.c/candidate.env/remote_job.sh。source-hashes.json与remote source-sha256.txt覆盖相同10文件。根层还存prepared.json和本静态说明；无job.json。

原始root日志为probe.log、stage-exits.txt、exit-code.txt、environment.log、source-sha256.txt；生产build-production.log/build-guard.log/build-assembly.log、production-conv2d-objdump.log、conv2d-sve.s、production-object-sha256.txt；六份guard-vl*-t*.log；build-copy-probe.log及12份copy-success/failure-vl*-t*.log。完整返回、job/system/wrapper/各stage退出0、自动源身份、全部VL/线程、24100/6048/6048精确计数和各COPY_PROBE summary、实际生产汇编独立审查完成后，才能冻结。fetch工具应保留.h/.md/.c/.sh/.env及文本/汇编，不默认公布原二进制或私有路径。
