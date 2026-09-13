# AA：C54 shared 四列展开的诊断矩阵建议

2026-09-13；状态为设计备忘录，未执行。仅提出一套推荐矩阵，不修改 C 检查器、工具、候选源码或实验记录。C54-row7x3shared4 的授权源改动是从 C52 出发，将 shared 主循环改为 `kw - ik >= 4`、`ik += 4`，严格按四列顺序更新；随后直接进入原 u1 余列循环，不增加 paired2 层；其他十二阶段保持。后续诊断必须绑定 C54 最终实际源清单及自己的唯一作业，不能继承 T 的 PASS。

## 推荐：原 T 全部保留，增加一组 quad_boundary

逐行读取的依据是 T 原件 `sep13t-checks/C52-row7x3shared2/source/check_conv_guard.c`（one_case 75..101、主矩阵128..174）、`check_sve_dispatch.c`（direct32..51、逐 case 入口核对53..64、矩阵66..117），以及 T 的生产 shared 源和 INTERFACE。以下都是从这些循环推导的 planned 数量。

令 L 为 float lane 数，六配置仍为 SVE_BYTES={16,32,64} × OMP线程={1,4}，即 L={4,8,16}。保留原矩阵的全部形状和分配方式，只在 full 与 dispatch 各增加下面同一组形状：

| 维度 | 新增值 | 个数 |
|---|---|---:|
| ow | 3L−1、3L、3L+1、6L−1、6L、6L+1 | 6 |
| kh | 7、8 | 2 |
| kw | 4、5、6、7、8 | 5 |
| oh | 7、8、14、28 | 4 |
| full 分配 | pad0/1 × leading0/1 | 4 |
| dispatch 分配 | 固定 pad1、leading0 | 1 |

新增 full = 6×2×5×4×4 = **960**；新增 dispatch = 6×2×5×4 = **240**。direct 原样保留：它强制 kh1..6 的 helper 防御回退，不进入本次修改的 shared 算术，扩展它的 kw 不能证明四列块。

推荐这一小组而不把全部主矩阵统一扩大到 kw1..5：kw4/5 仅覆盖四列块后的余数0/1，尚缺余数2。kw2 虽有两列余数，却没有执行过四列块，不能替代 kw6 的主循环→两列余数转换。

| kw | 四列主循环次数/每个 shared 输入行 | 随后 u1 列数 | 覆盖来源 |
|---:|---:|---:|---|
| 1、2、3 | 0 | 1、2、3 | 原 core/narrow/small/direct；shared 由原 kh7/8 core 覆盖 |
| 4、5、6、7 | 1 | 0、1、2、3 | 新 quad_boundary |
| 8 | 2 | 0 | 新 quad_boundary |
| 15 | 3 | 3 | 原 larger 的 kh15/kw15 |
| 81 | 20 | 1 | 原 larger 的 kh81/kw81 |

原 larger 的另两项 kh10/kw7 与 kh9/kw8 也完整保留，但它们仅在 ow=3L+1 附近测试，不能代替新增 kh7/8 与 6L 边界。kh7 有一个 shared 输入行 t=6；kh8 有 t=6、7，覆盖四列/余列结束后跨 t 再开始。新 oh7/8/14/28 分别覆盖一组、一组加一行尾、两组及四组；oh28 让四线程均有完整行组工作。原 oh1..15/21/22/28 保留全部 oh%7=1..6，原 larger 的 oh13 还覆盖实际四列工作后接六行尾。新增 grid 本身没有把每个新 kw 与全部行余数交叉，不作这种覆盖声明。

ow=3L−1 会进入 rowseven helper，但不执行其完整3VL tile；3L/3L+1 覆盖第一个 tile 与横向尾；6L−1 覆盖一个完整 tile 加长尾，6L/6L+1 覆盖两个完整 tile 及 tile 状态重置。对 L=4/8/16，六宽度互异，全部为正。新增 kh/kw/oh 各表内无重复；新增 kw>=4 与原 core 的 kw<=3 不重合，且 kh7/8 与原 larger 的 kh10/9/15/81 不重合。full 与 dispatch 是不同执行模式，故有意复用形状，分别计数。

## 精确 planned 数量与入口

| full 家族 | 实际循环因子 | 每配置 |
|---|---|---:|
| 原 core | 6宽×3kh×3kw×18oh×4分配 | 3888 |
| 原 narrow | ow1×3kh×3kw×4oh×4分配 | 144 |
| 原 small | 3宽×5kh×3kw×4oh×4分配 | 720 |
| 原 larger | 4核×2oh×4分配 | 32 |
| 新 quad_boundary | 6宽×2kh×5kw×4oh×4分配 | 960 |
| **full 合计** | 4784+960 | **5744** |

原 narrow 的 oh={1,7,13,28}；small 的 ow={1,3L−1,3L+1}、kh1..5、kw1..3、同四个 oh；larger 保持核集合 {(10,7),(9,8),(15,15),(81,81)}、ow=3L+1、oh={7,13}。

| 执行模式 | 每配置 | 六配置 |
|---|---:|---:|
| full | 5744 | 34464 |
| dispatch | 972+240=1212 | 7272 |
| direct | 432 | 2592 |
| **总检查数** | **7388** | **44328** |
| 官方 runner | 0 | 0 |

相对 T 的37128，新增7200项；这些是形状/分配/配置的执行次数，不是输出元素数，也不是已经通过的数目。

dispatch 仍逐 case 检查 `kh>=7 && oh>=7 ? floor(oh/7) : 0`。原18个 oh 的 floor 总和为21，原入口=6宽×2有效kh×3kw×21=756。新增四个 oh 的 floor 总和=1+1+2+4=8，新增入口=6×2×5×8=480。因此每配置 dispatch 入口应为 **1236**（六配置7416）。入口计算包括 ow=3L−1，不能因没有完整 tile 而把它扣除。

direct 保持3宽×6kh×3kw×2oh×4分配=432；每配置入口=3×6×3×4×(1+4)=**1080**（六配置6480）。dispatch 与 direct 各自的 worker mask 仍为线程1时1、线程4时15；prefix/tail/pair/triple/quad 非零仍是 dispatch 全套累计要求。它们不是内部四列块或每个形状的阶段计数。

未来实施位置应最小化：full 在最终计数检查前加 grid 和独立 `quad_boundary` 家族计数；dispatch 在读取 `dispatch_entries`/mask/旧 helper 快照之前加 grid，并继续调用 `checked_entry_case`。随后更新1212/1236的打印和断言；direct 以更新后的 dispatch 快照扣除，仍得到1080，并保留既有团队 join 后切换函数和 mask reset。未来 wrapper/接受器/清单需一致采用5744/1212/432及家族数量，不得只改 PASS 总数。若沿用 T 的可执行文件与执行结构，仍为原十九阶段，而不是因增加 case 另加程序阶段。

## 参考、保护和证据边界

保持 one_case 独立 scalar y/x/ky/kx 参考和逐位 memcmp；不从 C54 的四列实现生成预期值。input/kernel 填充后只读，分配两端 PROT_NONE、页内数据区域外 canary、output poison 与原边缘布局全部保持。六配置都实际检查主线程和 OpenMP worker 的 SVE VL/线程数，禁止把请求设置当实际设置。诊断编译必须保留原严格浮点契约和独立 scalar 参考编译设置。

本设计不新增逐行 guard、sanitizer、非法尺寸、NaN 输入、L/2L±1 网格或 direct ow1；普通 full ow1 不能代替 direct ow1。内存保护是分配边界保护，不能将其描述成每行越界读均必然触发。所有十九阶段退出、wrapper退出、原作业真实终态 job/system退出、真实编译命令、返回源及六组完整日志仍必须验证；不以调度器 SUCCEEDED 单独判通过。

## 实际汇编审查方案

保留十三个语义阶段 input_0..5/shared/trailing_0..5；其他十二阶段应分别核对 u1。shared 源契约为 quad main work=4，随后直接 u1 remainder、动态0..3列；不能套用 T 的 paired2/odd1 字段或固定十四个机器区间。

每列源语义为21次乘法和21次加法，故四列块的源工作量为84次乘法/84次加法，并有12条源级向量加载、28条源级权重广播语句。这些是映射依据，不是预填的实际机器数量。实际普通/indexed FMUL、FADD、LD1W/LD1RW、重排、地址计算和 spill 均从返回的未插桩生产 .s 逐一统计；严格契约下 FMA 必须实际为0，不能因父 T 为0而继承。

允许编译器把余列实现为一个 work1 回边（执行0..3次）、多个条件直线块或其他实际结构。必须分别记录每个真实区间、进入条件、回边及对应列工作量，覆盖 quad→remainder→下一 t→下一 tile 的全部转换。若主循环被再次展开或阶段被合并，按实际路径解释；不能切取局部指令凑84/84、伪造 PC/行号或假设只会有一个余列区间。无法完整映射时保存原件并停交 root 审查 schema，不拟造固定范围来通过接受器。

完整阅读 rowseven 所有实际 helper/clone、十三阶段及转换、21累加器的列顺序和输出 stores、横向尾部、kh<7 防御回退及所有 dispatch。特别核对每 t 的 ik 重置、每 tile 的 input/kernel 地址与累加器重置、四列主循环末次条件、0..3余列最后一次读写，以及 kh7/8 和长 kw 的跨行索引。区分 ABI D 寄存器保存与 Z/Q/谓词 spill，审计 GPR/标量栈、间接栈地址、所有路径，而不只统计主循环。

与 C52/T 实际汇编比较四列主循环及余列的归一化工作量、地址/分支开销、输入和权重活跃期及 stack/spill。更大展开可能减少循环控制，也可能增加寄存器压力或调度等待；零 spill、机器代码不同和提速均不能预填。数值通过、实际代码审查和后续性能资格应分别记录。

此备忘录不给 compute GO，不创建诊断目录、作业或接受结果。C52 的 Y confirmation=false、C51 的 S confirmation=false 及原样本保持，不复测失败确认，不晋级。账户主额度读取为已用6%，未用重置卡；达到40%即停止。文件完成后 STOP，交 root 选择是否实施。
