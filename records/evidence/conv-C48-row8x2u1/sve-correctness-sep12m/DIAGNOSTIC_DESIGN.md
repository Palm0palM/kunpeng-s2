# C48 八行 × 2VL 的独立诊断设计

这是 prepared 计划与源级推导，未执行。C48 源已由作者 checkpoint 冻结，源父 C40-row6x3u1；实际 helper 是 `conv_sve_roweight(base,stride,kernel,kh,kw,dst0..dst7,ow)`，八行、每行两个 SVE 向量、16 累加器。没有沿用旧候选 PASS，没有新作业或性能值。

令 L=svcntw()。六配置固定 SVE bytes16/32/64（L=4/8/16）× threads1/4。所有 worker 都核对 VL 与 team。下述 full 与 direct 的 allocation 因子4为 pad0/1 × leading0/1；输入和 kernel 只读，输出 poison，分配边缘 guard 和外围 canary；每项与独立按 kernel 行/列递增的 scalar reference 逐位比较。不是逐输入行 guard，也没有 sanitizer。

## 生产 full：每配置5360

|族|宽度|kh / kw|oh|放置|推导|
|---|---|---|---|---:|---:|
|core|2L−1,2L,2L+1,4L−1,4L,4L+1|kh7/8/9；kw1/2/3|1..17,24,25,32，共20|4|6×3×3×20×4=4320|
|narrow|1|kh7/8/9；kw1/2/3|1,8,15,32|4|1×3×3×4×4=144|
|small|1,2L−1,2L+1|kh1..6；kw1/2/3|1,8,15,32|4|3×6×3×4×4=864|
|larger|2L+1|(kh,kw)=(10,7),(9,8),(15,15),(81,81)|8,15|4|1×4×2×4=32|

合计4320+144+864+32=5360；六配置32160。small 只补 core 未覆盖的小核，larger 有界覆盖大奇偶核，不扩展所有笛卡尔积。

2L−1 完整走横向 fallback；2L 为一个完整新块；2L+1 带一个尾输出；4L−1 是一个块加最大2L−1尾；4L 和4L+1分别两个块及两个块后尾1。kh7/8/9 分别覆盖不使用公共八行路径、共享阶段最短一次、共享阶段多次。kw1/2/3覆盖单列循环及奇偶。oh1..7走旧分派；8首次整组；9..15覆盖余1..7；16是两组，17是两组加尾1；24三组，25三组加尾1；32为四组，确保四线程都有完整 helper 工作。

## 插桩 public dispatch：每配置1080

用同6宽、kh7/8/9、kw1/2/3、同20个oh，只固定 pad=1/leading=0；full已覆盖四种放置，不重复该因子。总6×3×3×20=1080，六配置6480。

每次调用前后原子读取 `roweight_entries`，并在本次 OMP team join 后验增量：若 kh>=8 且 oh>=8，应为 floor(oh/8)，否则0。这个0项覆盖小核及所有不足8行情况，不能只检验总计。

高度入口权重为：1..7为0，8..15为8×1，16/17各2，24/25各3，32为4；和为22。只有两个kh激活新路径，故每配置 roweight 入口为6×2×3×22=792。总 worker mask 应为1或15；oh32提供四个完整 group，由静态调度分给四个worker。另记录 prefix/tail/pair/triple/quad 的真实非零入口。C48源中已用八行 helper替换六行专用 helper，不要求不存在的 rowsix 入口。

## 插桩 direct 防御回退：每配置504

公共 dispatcher 排除了 kh<8，因此用独立 diagnostic adapter 明确调用 roweight：宽2L−1/2L/2L+1、kh1..7、kw1/2/3、oh8/32、四放置。3×7×3×2×4=504，六配置3024。

adapter 每组恰有8个合法输出行，按 global ow 的 size_t output stride传入8个dst；输入从 group*8*input_stride 起。各线程输出区间互斥。每case helper入口应等于oh/8；入口总数3×7×3×4×(1+4)=1260。切换 adapter及mask重置只在前一case所有线程join后进行。direct重新核对mask1/15和逐位结果，不能将 public 的0入口当作已执行防御分支。

## 总数与证据边界

每配置5360+1080+504=6944；六配置41664。源级计数与 prepared/候选env/guard自检常量相符，但现在都是计划数。只有目标计算节点真实运行、job/system/wrapper退出、19阶段、6组完整日志、实际源身份、三条真实 GCC argv 和15阶段汇编审阅全部完成后，才有资格写实际 PASS。

生产guard的候选单独TU无插桩；入口证据来自独立包含未修改生产源的 `-finstrument-functions` 程序，不计性能。完整15阶段 input_0..6/shared/trailing_0..6、所有转场/旧helper回退、普通或indexed乘法与独立加法、实际输入/系数加载和Z/Q/间接栈 spill/ABI区别均待目标产物；不能用16acc预算或旧C40汇编推断结论。
