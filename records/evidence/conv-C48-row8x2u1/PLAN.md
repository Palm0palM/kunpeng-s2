# C48-row8x2u1：八行 × 两个 SVE 向量，单列推进

状态：仅 source-only prepared，未编译、未专项检查、未审实际汇编、未测性能，没有诊断包或新作业。parent/source_parent 为 C40-row6x3u1；正式当前仍 C6。C40 的 G 首轮噪声门槛未过，J 独立复测通过，两端 K 确认又因候选自身波动未过；不能把 C40 当正式晋级版本。

本次先只读搜索现有 CONV PLAN/STATIC、实验记录和报告中的八行/8×2VL/roweight 等描述，未找到等价历史候选。C40 是六行×3VL，C47 只把六行扩到4VL；此候选用新行数/宽度形状，不能和不同形状或不同分配的成绩归因到单一指令。

## 唯一假设与源码范围

把 C40 专用六行×3VL helper 和首个六行分派改为八行×2VL：16 个累加器，仍是 kernel 列单步独立 mul/add。新增 `conv_sve_roweight` 共15个输入行阶段：leading t=0..6；shared t=7..kh-1；trailing t=kh..kh+6。输出 r 仅在 0<=t-r<kh 时使用 kernel[t-r]，每个输出自己的 kernel 行/列顺序严格不变。

普通入口只有 SVE 且 kh>=8、oh>=8 才采用新八行分组；小核/少行完整走原 C6 分派。每组不足8行时按7=quad+triple、6=quad+pair、5=quad+prefix、4=quad、3=triple、2=pair、1=prefix分解。新helper横向不足2VL以及防御性kh<8入口均用两次旧quad覆盖八行。旧quad/triple/pair/prefix/tail的函数体、原 C6 fallback分派、invalid/非SVE路径和其它提交文件全部保留原字节。

没有 asm、prefetch、重关联、FMA、跨调用状态、输入打包、计时/校验/flags变化，也不识别官方尺寸。`prepare-source.py` 是保留的一次性轻量文本生成器，不执行题目；candidate.patch 展示全部源码变化。准备时静态审查发现自动命名第八个系数指针会与 int kh 同名，已在未测源及生成器中改名 krow_h，避免遮蔽维度；不涉及任何已测源码。

## 预期取舍，不能保证提速

以完整水平块、单个 kernel 列遍历整高的源级总量，归一化到每个输出向量：

| 指标 | C40 六行×3VL | C48 八行×2VL |
| --- | ---: | ---: |
| 输入向量 loads | (kh+5)/6 | (kh+7)/8 |
| 系数广播 | kh/3 | kh/2 |
| 输出累加器 | 18 | 16 |
| shared 每列输入 loads / broadcasts | 3 / 6 | 2 / 8 |
| shared 每列独立 mul / add | 18 / 18 | 16 / 16 |

宽核下，输入加载率下降；但系数广播摊销增加50%，循环回边摊给更少的水平向量，且组数减少可能影响38线程静态负载均衡。15阶段带来更大代码和不同尾部，均可能抵消收益。16acc+8coeff约24Z只是源级基本状态，另需输入/乘积、谓词、ABI及编译器调度状态；不据此宣称无spill或更快。不把真实缓存几何、PMU首条LD1RW占比或不同allocation百分比当作已知原因。

## 仅准备的后续验证要求

根代理先独立审查源码，再决定是否建立诊断。需使用目标 GCC10.3.1/原 flags、严格逐位参考、只读输入/kernel、guard/canary；1/4线程与VL16/32/64字节；宽度在2VL/4VL边界与窄列/尾列；kh小于8的直接helper防御分支、kh8/9和大奇偶核；oh1..17及24/25，覆盖全部1..7剩余行。需要实际15阶段/转场和分派汇编、FMA/spill记录；旧C40 26112项不能替代此候选。

性能授权后再用同allocation C6/C40/C48交错完整三套件、固定38CPU单NUMA/24GiB和原benchmark，保留全部失败/慢样本并按噪声门槛判断。此时没有C48速度、正确性PASS或晋级结论。所有计算只能在超算调度计算节点完成；当前没有编译、测试、SSH、提交或重置操作。
