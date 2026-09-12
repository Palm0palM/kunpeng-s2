# X：C53 shared 权重游标独立诊断，仅准备

候选 `C53-row7cursors`，source parent `C51-row7x3u1`。固定最终源 SHA256 `d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`，已由作者及 root 独立审查。只改变 shared 七个权重游标：每个输出 tile 从 kernel 行6..0重置，逐列各自前进一步，跨 t 延续；13阶段仍全部u1，七行×3向量/21累加器、其它阶段/dispatch/fallback/提交文件保持。父Q及其它候选结果不提供C53 PASS。

当前仅有三个工具、五个传输源文件及首次清单/计划。没有X job.json、raw、assembly-review、validation或诊断冻结；未导入/执行工具、编译、测试、连接SSH或提交作业。只有root可在审查后明确一次 `submit --go`；本接口不授予compute GO。

## 数值矩阵与边界

两个C检查器逐字复制Q原文件：`check_conv_guard.c` SHA `b11bfe06a6d09228ad0d4dc6ae3d7581642fb534a1bd612f94c86574f41cc307`，`check_sve_dispatch.c` SHA `5751451998db3f2bee920afc78af05039d5b11949db5a4765aefe8553d4aacbc`。不改reference、guard、浮点设置、期望值或进入计数。

SVE字节16/32/64×线程1/4共六配置；L=float lanes=4/8/16，3L主块=12/24/48。每配置生产full4784、dispatch972、直接kh<7回退432，合计6188；六配置计划37128，官方runner0。

- full core3888：ow=3L−1/3L/3L+1/6L−1/6L/6L+1，kh6/7/8、kw1/2/3、oh1..15/21/22/28，pad0/1×leading0/1四分配。
- narrow144：ow1、kh6/7/8、kw1/2/3、oh1/7/13/28、四分配。small720：ow1/3L−1/3L+1、kh1..5、kw1/2/3、同四高/四分配。
- larger32：kernel10×7、9×8、15×15、81×81，ow3L+1，oh7/13、四分配。kw7/15/81和kw8覆盖较大奇偶列数。
- dispatch为core固定pad1/leading0，共972；每case新增rowseven入口精确检查：仅kh>=7且oh>=7时为floor(oh/7)，每配置累计756。
- direct为kh1..6、kw1/2/3、ow3L−1/3L/3L+1、oh7/28、四分配，共432，入口1080；它检查quad+triple防御，不能证明shared游标路径。

kh7仅一次shared t，kh8检查第一次跨t延续；较大kh检查更长游标序列。正常入口ow>=6L时至少两次完整输出tile，检查第二tile游标重置；6L−1/6L/6L+1覆盖该阈值和尾部。kw1/2/3均保持u1，不套T paired/odd矩阵解释。oh覆盖完整七行分组与余1..6。

数值参考仍为独立ky/kx scalar顺序并memcmp逐位比较；input/kernel只读，分配两端PROT_NONE、外围canary、输出poison。没有逐行guard、sanitizer、invalid-dimension、屏蔽SVE或NaN/Inf专项；不新增L/2L邻域864项，direct无ow1，未测9×7/8×8。五个旧helper非零和worker mask是套件累计，mask为1/15；rowseven逐case增量不能充当13阶段或游标动态步数。planned数不冒充actual数。

## 一次提交与原件

serial gate只读固定W campaign job1582256、T诊断job1582134、S campaign job1582067及已经存在的P/X job.json。固定W/T/S缺失、ID未知/不符、任何查询失败/非终态/缺少整数job与system退出码都阻止X。P/X没有job.json仅表示未预约；一旦存在而无可对账ID就阻止。不扫描队友，不取消任何作业；不声称是跨协调者调度锁。

提交前比对固定源、candidate checkpoint/原源、五文件source-hashes/source-manifest和prepared身份；计算节点manifest阶段再核对固定C53 SHA。首次上传前排他创建X job.json；提交不明保存原预留与日志，禁止重提。status/fetch只复用该ID，fetch保留已有原件，不同返回字节拒绝覆盖。

资源固定38 CPU、24576MiB、1 packed NUMA、1800秒。计算节点校验Linux/AArch64、38 affinity CPUs位于同NUMA、GCC10.3.1。Q原编译flags保持：`-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3`。full与生产源分TU；仅dispatch带`-finstrument-functions`；生产汇编为未插桩`-S conv2d.c`，没有对象反汇编。

未来接受器核对19有序stage全0、scheduler SUCCEEDED、job/system/wrapper全0、三条真实xtrace编译argv、源清单、配置/入口/mask与每配置full细分3888/144/720/32。失败、缺失或解析问题保存原件；真实失败才用`--failed`，解析问题不改成算子FAIL，不修样本或重测。

```text
python3 .runs/conv/sep13x-checks/driver.py C53-row7cursors config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13x-checks/driver.py C53-row7cursors config/conv-sep12.local.json status
python3 .runs/conv/sep13x-checks/driver.py C53-row7cursors config/conv-sep12.local.json fetch
python3 .runs/conv/sep13x-checks/accept_returned.py C53-row7cursors
python3 .runs/conv/sep13x-checks/freeze_returned.py C53-row7cursors
```

## 实际汇编审查契约

未来`assembly-review.json`绑定自身candidate/job/source SHA、GCC10.3.1、实际返回assembly SHA。全部真实rowseven helper/clone从label到.size完整读；全部conv2d/outlined dispatch也完整审，不预填PC/行号/指令数/栈大小/spill/PASS。Q63指令只是历史背景，不要求C53复现Q范围。

沿用Q的13个`stages`：input_0..5/shared/trailing_0..5；每个单一真实范围、`kernel_columns_per_iteration=1`，不接受T的`blocks`。接受器从真实.s统计普通/indexed FMUL、FADD、加载等字段，算术工作量依次为3/6/9/12/15/18/21/18/15/12/9/6/3对。shared还派生区域全部`lsl/add/sub/ldr/str/ldp/stp`词法数量；这些不是专门kernel地址ADD或spill计数，必须人工分类。

原Q完整helper/ABI/spill/转换/tail/fallback/dispatch字段保持。额外要求顶层`cursor_addressing_reviewed=true`，每helper四个非空实际解释：

- `cursor_initialization_and_tile_reset_review`：七初始kernel行6..0，完整tile内重置及下一tile，真实地址计算位置。
- `cursor_step_and_cross_t_review`：每列+1元素、经过kw列后跨t继续，或编译器等价归纳形式；对每r证明地址为kernel+(t-r)*kw+ik。
- `cursor_bound_and_one_past_review`：kh7/8/较大kh、最后可解引用位置，ka可到whole-kernel one-past但不再读取，kh<7/宽度不足的避开路径。
- `scalar_addressing_and_stack_review`：GPR地址存活、真实标量栈/间接栈、ABI D保存与Z/Q/谓词spill的区别。

shared阶段另有`address_generation_review`：明确Q中共享LSL和七个kernel地址ADD在C53实际产物是否存在、移动、折叠或改变；解释外层t步进、输入地址和权重游标，不能假定源码游标消除了ADD。完整审13阶段转换、21stores、横向尾部和防御路径。若实际lowering不能如实对应13个u1范围、算术工作量变化或游标表示无法解释，保留原件、先交root审，不套父范围、伪造计数或自行改schema。不同地址形态本身须如实报告，无零spill/提速预判。

成功validation记录stage_count=13、arithmetic_region_count_per_helper=13、shared_coefficient_representation=seven_cross_t_cursors及实际结果；无自动性能/晋级。freezer只在共享锁下原样归档到`.runs/conv/C53-row7cursors/sve-correctness-sep13x`，同时保留工具/接口/本次静态审查/patch/inventory，拒绝已有目标或staging，不创建不存在的.s。源码/record和W/T保持原状；没有使用重置卡。
