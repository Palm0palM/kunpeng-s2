# C29-row4lane4：四行共享中段的四系数 lane 展开

- parent / source_parent：`C26-row4loads`。
- 单一假设：保留 C26 的四输出行 × 四 SVE 向量 tile 和直接输入窗口加载，仅把四行全部参与的中段横向系数从两步展开改为四步。每行一次 `svld1rq_f32` 载入四个连续系数，通过 `svmul_lane_f32` 的立即数 lane 0、1、2、3 依次使用，减少系数加载指令与循环控制开销。
- C26 是源码来源；创建时其记录仍为 prepared、verified=false。该来源身份不表示 C26 或 C29 已通过性能验证，后续由主代理指定同资源测量对照。

## 精确改动范围

只向 `source/conv2d.c` 的 `conv_sve_rowquad`、`t=3..kh-1` 四行共享中段插入一个 `kw-ik>=4` 循环。原两系数循环与单系数循环逐字保留，处理 0–3 个剩余系数。其余六个首尾阶段、旧 triple/pair/prefix/tail helpers、kh<4 回退、四行分组 OMP 调度、非 SVE 路径均不改变。README、benchmark、runner 三个文件原样复制，不更改容差、编译 flags、FMA 设置或官方尺寸分支。

新循环显式保留十六个累加器，不建立 sizeless SVE 数组。每次加载四个系数向量 ak4/bk4/ck4/dk4；对输出向量位置 n=0..3，按 q=0→1→2→3 加载一个 `p+n*VL+q` 输入窗口，依次更新 a[n]、b[n]、c[n]、d[n]，再进入下一窗口。每个窗口有独立局部作用域，但不使用 inline asm 强制调度。乘法为 `svmul_lane_f32(x, rk4, q)`，加法为单独的 `svadd_f32_x`。

## Arm / GCC 一级来源

- [Arm ACLE](https://arm-software.github.io/acle/main/acle.html)：SVE `svld1rq` 对应 LD1RQW，`svmul_lane` 对应 indexed FMUL；使用原 SVE helper 的 all-true b32 predicate。
- [Arm A64 ISA，LD1RQW 页 2862、FMUL indexed 页 2682](https://documentation-service.arm.com/static/67e40f3398aa3c3b6eea6a85)：LD1RQW 只读取四个连续 32 位元素，再把这 128 位内容复制到所有向量分段；只使用前四个 predicate 元素。f32 indexed FMUL 每个 128 位分段选择相同位置，第二源限制为 Z0–Z7，立即数 lane 范围为 0–3。四个系数向量占用其中四个寄存器；目的和普通输入源没有此低 Z 限制。
- [Arm SVE / Neon 示例说明](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/102131_0100_01_SVE_and_Neon_coding_compared.pdf?revision=feaaf72e-a941-461c-bd92-0d960d0f8615)：展示用 `svld1rq_f32` 复制四系数，供按 128 位分段索引的 lane 算术使用。此候选使用分开的乘法、加法，不采用示例中的融合累加。
- [GCC 10 发布说明](https://gcc.gnu.org/gcc-10/changes.html)：支持 `arm_sve.h` 的 SVE ACLE 类型与 intrinsics。
- [GCC releases/gcc-10 官方源码](https://raw.githubusercontent.com/gcc-mirror/gcc/releases/gcc-10/gcc/config/aarch64/aarch64-sve-builtins-base.def)：注册 `svld1rq/load_replicate/all_data` 与 `svmul_lane/binary_lane/all_float`。该代码支持 API 存在性判断；超算实际 GCC 10.3.1 编译及汇编仍需验证，未以文档代替编译成功。

## 顺序与边界推导

1. 原中段 t 从 3 递增到 kh−1；四输出分别使用 kernel 行 t、t−1、t−2、t−3，行映射不变。每个累加器都先完成 ik+0，再 ik+1、ik+2、ik+3，再进入下个 ik；无横向求和、重关联、FMA 或跨行归约。
2. 函数已要求 kw>0，且始终 0<=ik<=kw。条件 `kw-ik>=4` 避免计算 ik+3 或 ik+4 作为循环条件，成立时 ik+4<=kw，步进不溢出 int。剩余 0/1/2/3 个系数由原两步、一步循环依次完成；kw=1/2/3 不进入四步块。
3. 每个 `svld1rq_f32(pg, kr+ik)` 最大读取系数 ik+3<=kw−1，不跨 kernel 行。它只读 16 字节，不是一个 VL 字节宽的普通系数向量读取，因而随 VL 增大也不扩展读取边界。
4. 设 VL=svcntw()，已有满块保证 i+4×VL<=ow。最后输入加载起点是 `p+3×VL+3`，其末列为 i+ik+4×VL+2。因为 ik<=kw−4，末列 <=ow+kw−2=inputWidth−1；从不加载额外完整 v4。所有 q=0..3 窗口都在同一合法输入行内。
5. 最大输入行沿用原 quad 边界 `j+kh+2<=inputHeight−1`。新块只位于中段，实际 t<=kh−1，未增加行读取范围。输出与线程独占范围完全不变。
6. LD1RQ 的四元素模式复制到每个 128 位分段，而 lane 算术逐分段索引，故无需固定 VL。只作用于原有满向量路径；掩码输出尾部仍由原 helpers 处理。

## 预期收益和风险

每四系数、每个四行 × 四向量满块，预期仍有 16 次完整输入窗口加载、64 次 FMUL、64 次 FADD。系数加载从原两次双步循环共 16 次 LD1RW，变为 4 次 LD1RQW；少 12 条系数加载指令，系数实际读取字节量仍为 64 字节。四步循环控制次数约为双步的一半。以上仅为代码层面的指令假设，不是性能成绩。

理想活跃集合约为 16 个累加器 + 4 个系数向量 + 1 个输入窗口 + 1 个乘积，即 22 个 Z 寄存器。四个低 Z 系数约束理论上可满足，但 GCC 可能提前加载输入、保留多个乘积，或为低 Z 约束添加搬移/溢出；局部作用域不保证实际调度。LD1RQW 和 indexed FMUL 在目标 CPU 上的吞吐也可能抵消静态指令收益，必须实测。

## 待超算验证

主代理统一在调度计算节点执行，不在本机编译或测试。先检查实际 GCC 10.3.1 是否接受两种 intrinsic、共享四步热点是否生成四次 LD1RQW/64 次 indexed FMUL/64 次独立 FADD，是否出现多余系数广播、低 Z 搬移、栈向量 load/store 或 FMA。再做严格标量参考、保护页及实际 helper 入口检查，重点包含 kw=1..8 及四步余数 0/1/2/3、末 kernel 行和最后输入窗口，沿用多 VL/线程与输出高度、宽度边界覆盖。全部通过后才进入同资源前后控制的三套件比较；原两步和一步尾循环也必须实际进入。

当前状态：仅准备源码与静态检查；未编译、未运行正确性/性能/sanitizer，未 SSH，未晋级或提交比赛。
