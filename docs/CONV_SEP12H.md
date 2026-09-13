# CONV SEP12H：输入复制与行距对照（已完成，保留 C6）

当前最佳保持 **C6**。H性能作业1579748已完成：12套、48/48用例PASS，最大误差0，SUCCEEDED且job/system/wrapper退出均为0。C43-padinput合计470.98ms，比主关闭C6的452.43ms慢4.100082%；C44-copyinput合计471.85ms，慢4.292377%。C43对C44仅改善0.184381%，未超过11.792871%的实测波动门槛，且用例C退步1.239854%；本轮不支持padding收益归因。复制整体策略在该组实测退化，没有候选进入确认、提交包验证或C7晋级。

此前C43专项1579692与C44专项1579729各217176项、合计434352项全部通过并冻结，六配置和各26阶段退出均合格。正确性通过保留，性能退化同样完整留痕。所有编译和执行均在超算调度计算节点进行；本机只作轻量编辑和日志整理，没有使用重置卡。

## 假设与对照

两版source_parent均为C26-row4loads。C43在算子内部复制完整输入有效元素，将内部行距设为 `(((width+15)/16)|1)*16` 个float，即按64字节一组向上取整到奇数组；64字节是本方案参数。C44使用**完全相同的启用条件、分配容量和有效复制元素总量**，但复制和计算都保持原行距，作为reference-only对照，不允许晋级。C44实际数据连续存于较大分配的前部；未使用的容量不参与计算。

只有SVE、kh>=4、oh>=4、width>=64、目标行距不同于原值、所需分配不超过512MiB且size_t计算安全时才尝试复制。malloc失败则使用原input/stride继续计算；其它门槛未满足也走原路径。输出布局、全部原卷积helpers、benchmark、runner和严格乘加顺序保持；input/kernel只读。

分配、逐行memcpy、两个OMP区域和free都位于原conv2d调用内，本轮原benchmark计时完整包含这些开销，没有跨调用缓存。输入行距可能影响缓存行为是提出实验时的假设；本轮C43/C44对照没有给出可确认的padding贡献。

C40诊断在一个真实分配节点读到 L1D=32KiB、64字节缓存线、64 sets、8 ways，L2=768KiB、12 ways；默认SVE长度64字节。这是该节点的 sysfs 元数据，不是cache-miss证据，也不由处理器型号推断。以下仅为结合这些数据的地址步长算术，不保证硬件索引机制或性能因果。

|用例输入 H×W|原行距 floats|C43 内部行距 floats|每行额外容量 floats|缓存线单位的原/新行步长|
|---|---:|---:|---:|---|
|4096×6144|6144|6160|16|384 / 385|
|6144×4096|4096|4112|16|256 / 257|
|4256×6390|6390|6416|26|399.375 / 401|
|6390×4256|4256|4272|16|266 / 267|

提出实验时，简单64-set索引模型提示奇数缓存线行距可能减少集合冲突；这是地址算术假设。本轮完整调用实测没有支持策略收益，也没有据此验证硬件索引或缓存冲突机制。采样 r2 的第一条 LD1RW 占比不能证明这里存在缓存冲突或广播瓶颈。

## 专项诊断终态

依据各版冻结的validation.json和真实返回产物，两个作业均为GCC10.3.1、generic、38CPU单NUMA/24GiB分配。诊断每次使用1或4线程，与16/32/64字节SVE长度组合成六配置；实际VL和线程团队均由guard检查。生产对象实际编译参数为 `-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2`；八条真实编译/链接argv和冻结源码身份均已核对。

| 版本 / 作业 | 未插桩生产guard | copy-success | forced-NULL | 实际合计 | 状态 |
| --- | ---: | ---: | ---: | ---: | --- |
| C43-padinput / 1579692 | 144600 | 36288 | 36288 | 217176 | passed / complete，26阶段exit0 |
| C44-copyinput / 1579729 | 144600 | 36288 | 36288 | 217176 | passed / complete，26阶段exit0 |
| 两版总计 | 289200 | 72576 | 72576 | 434352 | 全部通过 |

每版六配置 `(VL bytes,threads)=(16,1),(16,4),(32,1),(32,4),(64,1),(64,4)` 实际均为：生产24100、成功6048、强制NULL6048，共36196项/配置，全部passed。原runner执行数为0；没有把旧smoke分支、helper-entry插桩或sanitizer加入此计数。

生产24100项由原18052项边界guard加6048项复制门槛矩阵构成。前者包含43宽×19核×4放置=3268，以及24边界宽×14核×11输出高度×4放置=14784；后者为实际width63/64/65/79/80/81/95/96/97/127/128/129，kh3/4/5，oh3/4/5/7/8/9，kw1/2/3/7/16/31/63，pad0/1×leading0/1共四放置，合计12×3×6×7×4=6048。这样覆盖width63、width80行距不变、kh3、oh3等禁用情况，以及完整SVE块、尾列和剩余1..3输出行。

### 生产正确性与独立内存路径证明

生产conv2d.c单独编译为未插桩对象，与独立guard对象链接；每项使用原有序scalar逐位参考，检查只读input/kernel、guard页、输出canary及实际VL/team。独立插桩对象只包装候选的malloc/free/memcpy，guard和参考自身分配仍使用真实libc，不能把探针结果当生产对象的替代证据。

| 每版每配置实际计数 | 成功模式 | 强制NULL模式 |
| --- | ---: | ---: |
| cases / eligible / disabled | 6048 / 2800 / 3248 | 6048 / 2800 / 3248 |
| malloc attempts | 2800 | 2800 |
| malloc successes / forced failures | 2800 / 0 | 0 / 2800 |
| memcpy calls / free calls | 28280 / 2800 | 0 / 0 |
| ERROR_COUNT | 0 | 0 |

每版成功模式六配置合计16800次实际分配和释放、169680次逐行memcpy，全部ERROR_COUNT=0；失败模式合计16800次仅候选malloc被强制返回NULL，零memcpy、零free，结果仍逐位正确。探针核对分配大小、每行地址和字节数、C43 padded/C44 original行距，并在实际free之前校验完整输出；未复制区域被毒化，避免意外读入未初始化容量被掩盖。

源身份来自冻结记录：C43 `a805f1a60d22fd8ed88ac079c030be8186fa0e1048e39e38430880f49f5a59fa`；C44 `8618bd699656a750a378bd008a863178ab738093a783dfda9619ec035945fb6d`。只做已有自动身份校验，没有另行大量人工哈希审计。

### 实际汇编与复制生命周期

两份实际生产.s及production对象反汇编都完成独立审查。quad七阶段（前三输入行、shared、后三输入行）、所有转场、两列与一列余数、横向尾部及fallback均已覆盖；整个返回.s和对象反汇编的FMA计数均为0。

| quad每阶段主循环 | 指令数 | 独立FMUL / FADD | input LD1W / kernel LD1RW | vector spill load / store |
| --- | ---: | ---: | ---: | ---: |
| input_0 / trailing_2 | 32 / 32 | 各8 / 8 | 各5 / 2 | 0 / 0 |
| input_1 / trailing_1 | 55 / 55 | 各16 / 16 | 各5 / 4 | 0 / 0 |
| input_2 / trailing_0 | 75 / 75 | 各24 / 24 | 各5 / 6 | 0 / 0 |
| shared | 93 | 32 / 32 | 8 / 8 | 0 / 0 |

这些是实际静态循环计数，不是采样权重或性能结果。两份quad完整实际文本与对应对象指令一致；完整对象不同，不能称整程序机器码相同。quad有752字节固定栈帧、标量地址/循环状态保存，以及d8..d11低64位ABI保存；零向量累加器spill不等于没有栈访问。

每份还审查了全部四个实际dispatch函数：公共conv2d、copy worker、SVE compute worker和旧非SVE worker。公共入口保持原尺寸检查/HWCAP门槛；malloc为NULL时没有复制，也不改变原input/stride。copy区域返回后才进入compute区域，compute返回后才free；同步依据是OMP区域join，不虚构额外屏障指令。C43将复制和计算行距切换为padded值；C44两处均保留原stride且仍按padded容量分配。全局输出行距始终ow。

公共入口/copy/SVE compute worker分别有176/64/160字节标量栈帧。旧非SVE worker有368字节帧，d8..d15使用4对STP/LDP作ABI保存；另有**14条静态STR Q**把已完成32/16/8列tile物化到局部数组，随后通过GPR LDP/STP拷至最终输出。这是真实栈流量，区别于热点累加器spill/reload；未见该worker的非ABI向量栈reload。不能将quad零spill推广成全程序无栈。本轮六配置都在SVE硬件执行，非SVE分支仅新增实际机器码静态审查，没有声称强制动态nonSVE覆盖。

512MiB上限和size_t极值只有源/机器码边界证明，没有超大分配或非法buffer端到端测试。未运行sanitizer；未执行原runner/benchmark的专项计数不能写成官方用例PASS。完整原始日志、26阶段退出、八条构建argv、逐配置计数与两份汇编片段均保留在各版冻结`sve-correctness-sep12h/`。

## 性能作业1579748终态

提交前固定顺序为 `C26-r14 → C44-copyinput → C43-padinput → C26-r15`，每成员三套完整原benchmark，共12套、48个用例结果。四份正式record均status=passed、verified=true、repeats=3、job_id=1579748，scheduler/fetched_log/benchmark/wrapper/source_hashes/machine六项检查均为true，所有用例最大误差0。使用同allocation、38线程单NUMA/24GiB、aarch64、GCC10.3.1/generic、原benchmark及官方内置参考，OMP close/cores绑定一致。

总毫秒数为四个用例各自三套件中位数之和；spread=(max-min)/median×100%。单个打印值仍是原benchmark既定计时方式产生的样本，不重新解释成原始硬件周期。这些内部指标不是官方分数。下表正gain表示更快，负gain表示更慢。

| 顺序 / 版本 | 角色 | 总中位数 ms | 最大用例spread | 对主关闭C6 gain | 结论 |
| --- | --- | ---: | ---: | ---: | --- |
| 1. C26-r14 | 开场C6控制 | 452.40 | 0.381928% | +0.006631% | 不晋级的控制 |
| 2. C44-copyinput | 复制参照，reference-only | 471.85 | 3.078796% | -4.292377% | reference-only，不确认/晋级 |
| 3. C43-padinput | padding候选，未合格 | 470.98 | 11.792871% | -4.100082% | 两端比较均false，不确认 |
| 4. C26-r15 | 预定主关闭C6控制 | 452.43 | 0.242209% | +0.000000% | 不晋级的控制 |

### 两端比较和同作业内的行距归因

预先规则要求候选同时超过两个不变C6：总中位数gain须大于max(1%,两版最大实测spread)，且任一用例退化不超过1%。C44始终只是参照。实际资格如下；两控制本身也不是新候选。

| 比较 | 总gain | 门槛 | eligible |
| --- | ---: | ---: | --- |
| C43-padinput 对 C26-r14 | -4.106985% | 11.792871% | false |
| C43-padinput 对 C26-r15 | -4.100082% | 11.792871% | false |
| C44-copyinput 对 C26-r14 | -4.299293% | 3.078796% | false |
| C44-copyinput 对 C26-r15 | -4.292377% | 3.078796% | false |
| C43-padinput 对 C44-copyinput | +0.184381% | 11.792871% | false |

C43和C44在四个用例上均比主关闭C6慢。C43比C44的合计中位数少0.87ms（0.1843806%），但其用例A三样本55.93..62.58ms形成11.792871%的spread，且用例C从112.11ms变为113.50ms、退步1.2398537%。`copy_reference_comparison.eligible=false`、`padding_contribution_supported_in_initial_group=false`；不能把这一点合计差异当作padding已有效。

| 用例 | C43 对主关闭C6 gain | C44 对主关闭C6 gain | C43 对C44 gain |
| --- | ---: | ---: | ---: |
| A | -9.580257% | -11.717839% | +1.913376% |
| B | -6.555789% | -7.153238% | +0.557565% |
| C | -5.709230% | -4.414641% | -1.239854% |
| D | -1.480554% | -1.821557% | +0.334902% |

这是包含malloc、逐行复制、额外OMP区域、地址布局及free在内的整体策略对照。不能把相对C6的全部耗时差直接解释为memcpy的纯耗时，也不能据这组结果拆出缓存、分配或调度的独立因果成本。没有剔除慢值，没有变更容差、计时区或官方尺寸。

### 全部48个原始样本与逐用例统计

A=4096×6144 / 39×39；B=6144×4096 / 41×41；C=4256×6390 / 55×55；D=6390×4256 / 81×81。下表每格单位ms，套件1/2/3按实际执行顺序原样保留，16行×3样本=48项；所有项PASS且max_error=0。

| 版本 | 用例 | 套件1 ms | 套件2 ms | 套件3 ms | 中位数 ms | spread |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| C26-r14 | A | 51.46 | 51.40 | 51.48 | 51.46 | 0.155461% |
| C26-r14 | B | 61.99 | 61.90 | 61.92 | 61.92 | 0.145349% |
| C26-r14 | C | 107.35 | 107.34 | 107.75 | 107.35 | 0.381928% |
| C26-r14 | D | 231.64 | 231.67 | 231.90 | 231.67 | 0.112229% |
| C44-copyinput | A | 57.49 | 56.77 | 58.54 | 57.49 | 3.078796% |
| C44-copyinput | B | 66.36 | 67.64 | 65.93 | 66.36 | 2.576854% |
| C44-copyinput | C | 112.11 | 111.91 | 113.70 | 112.11 | 1.596646% |
| C44-copyinput | D | 235.78 | 235.94 | 235.89 | 235.89 | 0.067828% |
| C43-padinput | A | 56.39 | 55.93 | 62.58 | 56.39 | 11.792871% |
| C43-padinput | B | 67.83 | 65.99 | 65.59 | 65.99 | 3.394454% |
| C43-padinput | C | 113.47 | 113.50 | 114.25 | 113.50 | 0.687225% |
| C43-padinput | D | 234.98 | 235.14 | 235.10 | 235.10 | 0.068056% |
| C26-r15 | A | 51.46 | 51.44 | 51.49 | 51.46 | 0.097163% |
| C26-r15 | B | 61.88 | 62.03 | 61.93 | 61.93 | 0.242209% |
| C26-r15 | C | 107.37 | 107.31 | 107.40 | 107.37 | 0.083822% |
| C26-r15 | D | 231.67 | 231.63 | 231.79 | 231.67 | 0.069064% |

C43用例A的62.58ms、用例B的67.83ms、C44用例A的58.54ms及其余慢样本均保留；不删离群值、不用较快两次替换三样本中位数或spread。

### 决策与证据

H campaign已为performance_complete，final_selection=null、confirmation_pending=[]，全部成员qualified_for_confirmation=false。没有创建或执行H独立确认、候选原ZIP验证或C7晋级；正式最佳继续是已验证C6。两份成功诊断和本次退化性能记录均保留，避免重复同一无收益策略。

| 版本 | 完整benchmark | 正式实验记录 |
| --- | --- | --- |
| C26-r14 | [benchmark.log](../records/evidence/conv-C26-r14/benchmark.log) | [record](../records/experiments/conv/C26-r14.json) |
| C44-copyinput | [benchmark.log](../records/evidence/conv-C44-copyinput/benchmark.log) | [record](../records/experiments/conv/C44-copyinput.json) |
| C43-padinput | [benchmark.log](../records/evidence/conv-C43-padinput/benchmark.log) | [record](../records/experiments/conv/C43-padinput.json) |
| C26-r15 | [benchmark.log](../records/evidence/conv-C26-r15/benchmark.log) | [record](../records/experiments/conv/C26-r15.json) |

专项冻结证据：[C43 validation](../records/evidence/conv-C43-padinput/sve-correctness-sep12h/validation.json)、[C43实际汇编审查](../records/evidence/conv-C43-padinput/sve-correctness-sep12h/assembly-review.json)、[C44 validation](../records/evidence/conv-C44-copyinput/sve-correctness-sep12h/validation.json)、[C44实际汇编审查](../records/evidence/conv-C44-copyinput/sve-correctness-sep12h/assembly-review.json)。公开副本由完整本地原件脱敏导出；未改写原始测量。

逐版本汇总见[记录表](CONV_SEP12H_ROUND_RECORDS.md)，公开范围与脱敏规则见[公开证据说明](../PUBLICATION-CONV-SEP12H.md)。
