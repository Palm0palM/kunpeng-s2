# C30-colchunks：四行组再按统一 256 输出列划分任务

- parent / source_parent：C26-row4loads。候选由 experiment new 创建；若根代理后来改用新的性能控制，源码来源仍保留 C26-row4loads。
- 状态：prepared，尚未编译、做正确性检查或跑分；所有验证只能在超算调度分配的计算节点进行。
- 假设：仅按四行组向 38 线程静态分配时，末尾不均衡可能留下一些尾部等待；把每个四行组进一步按 256 列划成更多工作单元，有机会缩小这种等待。统一常量 256 用于所有合法输入，不识别官方尺寸。

## 唯一实现改动

只改 conv2d 的 `if (use_sve)` 分支。采用单个 `size_t work` OpenMP 循环，仍为 `schedule(static)`：

- groups = oh/4 + (oh%4 != 0)，column_chunks = ow/256 + (ow%256 != 0)。均先转换为 size_t，不使用 oh+3 或 ow+255。
- tasks = groups * column_chunks。work / column_chunks 得到四行组，work % column_chunks 得到列块；column = 列块编号 * 256，row = 四行组编号 * 4。
- 局部宽度为 min(256, ow-column)，使用 `ow-column`，不计算可能越界的 column+256。
- base = input + row*input_stride + column，dst = output + row*全局ow + column。
- 根据剩余输出行数调用原 quad/triple/pair/prefix，并把局部 chunk_width 传作各 helper 的处理宽度。**所有相邻输出行指针仍按全局 ow 偏移，输入 stride 仍为 inputWidth。**

所有 kernel helpers、非 SVE 路径、getauxval 分派、精度/benchmark/runner/源码 README 均不改。generic conv2d 函数不增加任何 svcntw 或 SVE intrinsic 调用。

## 每输出唯一写入与边界

合法尺寸检查保证 oh>=1、ow>=1，所以 groups、column_chunks 都非零，除法和取余的分母有效。每个 work 唯一对应 (group, column_chunk)；反之每对合法编号恰有一个 work。

不同 group 的输出行区间 `[4g, min(4g+4,oh))` 不重叠；不同列块的输出列区间 `[256c, min(256c+256,ow))` 不重叠。这两个划分的笛卡尔积恰好覆盖全部输出。因此每个输出只由一个线程任务、一个原 helper 路径写入，不需要原子操作或 reduction。

最大 row 为 4*(groups-1)<oh。最大 column 为 256*(column_chunks-1)<ow，所以 `oh-row` 与 `ow-column` 不下溢；chunk_width 在 1..256，可安全转 int。数学上 column+chunk_width<=ow。任务内最后一个输入列不超过 column+chunk_width+kernelWidth-2<=inputWidth-1；每个 helper 的原输入行上界证明沿用，最后有效输出行加 kernelHeight-1 不超过 inputHeight-1。

row、column、tasks 与行偏移运算均为 size_t。在当前 AArch64 的 64 位 size_t、32 位 int 尺寸接口下，groups<=2^29、column_chunks<=2^23，tasks<=2^52，不会产生 32 位任务乘法溢出。更一般地，对于接口要求的有效完整数组，groups<=oh、column_chunks<=ow，任务数不超过可表示的输出元素总数；输入/输出指针位移仍须满足原接口“缓冲区有效且足够大”的前提。

## 小宽度、余行与退化风险

ow<=256 时 column_chunks=1，每个四行组调用一次相同原 helper，局部宽度等于全局 ow，地址与 C26 相同。ow=257 等情况产生一个256列块和一个短尾块；末块由原 helper 的尾部/小宽路径覆盖。oh 模4产生的1/2/3余行仍调用原 prefix/pair/triple。256不必对所有实际 SVE VL 的 helper 块宽整除，新增块边界上的回退仍应正确，但可能带来额外成本。

更多任务可能改善按行组分配的尾部等待，也会增加 helper 调用、除法/取余、地址重建、kernel 重复遍历以及块边界回退。最后的短列块与不足四行的末组本身权重不均，静态任务数平衡也不等于实际耗时完全平衡；相邻列块由不同线程处理时还可能增加缓存行共享。不能根据任务数理论判断提速。

## 静态审查与待验证

只替换原 SVE OMP 分配区域，helper 定义与非 SVE 后半段按原字节保留。原浮点累加过程由同一 helpers 完成，每个输出仍以原 kernel 行/列顺序、独立 mul/add 计算，没有跨线程部分和或 FMA。

根代理安排远程构建、逐位正确性和真实 helper 入口诊断。列边界至少包含1/255/256/257/511/512/513，以及原helper VL块宽附近；输出高度至少覆盖1..9、非整四行和足够多任务的情况；运行1/4线程及多个SVE VL。随后在同环境、同资源、相同输入/重复次数下比较，记录逐项中位数与波动。性能仅是待验证假设，不预填分数。

源码身份由 checkpoint 自动登记。本机只做轻量文本编辑与审查，未编译或运行题目，不额外重复人工哈希审计。
