# C47-row6x4u1 静态审查

仅源编辑、文本对应和轻量自动身份登记；没有编译、运行测试/算子、SSH或提交。本审查不等于正确性通过。

## 改动范围

标准new以C40原快照为parent创建，后续仅在.workflow.lock内编辑新版本。唯一改动是rowsix block3→4、六个索引3声明、十一阶段各一个索引3输入scope、六个索引3store。逐个移除新插入并把block改回3后，整个helper逐字恢复父版；helper前后全文件文本也直接保留。原三提交文件字节不变。candidate.patch供独立复核，没有任何既有候选/正式conv/runner编辑。

新增十一输入scope活动输出数依次1/2/3/4/5/6/5/4/3/2/1，正好复制父版n2各scope的行集合，只改向量号为3。每个新scope只有一次svld1，活动输出各一次svmul_f32_x+svadd_f32_x。原n0/1/2代码、系数声明、ik/t循环、余数helper调用逐字保留。

## 数值顺序与行边界

输出r=0..5在输入t=r..kh+r-1上依序消费kernel行t-r=0..kh-1；五leading、shared t=5..kh-1、五trailing映射不变。每个t的ik仍0..kw-1，独立乘后加。新增n3是另一个独立输出列向量，未改其它输出自身的累加链或跨行/列顺序，沿用禁止fast-math/contract的原runner。

kh>=6新路径最大输入行仍j+kh+4；完整组六行保证j+5<=oh-1，因此不越inputHeight-1。所有kernel行界/size_t行offset与父版相同，无新增行乘法或尺寸求和。kh<6直接helper仍先quad+pair并return；主调度kh<6/oh<6仍原C6路径。六行静态OMP分组及剩余1..5行分派完整保留。

## 列边界、整数及唯一写

设L=svcntw()。合法SVE长度给有限L，4L可表示为int。满块条件ow-i>=4L保证i+4L<=ow；每阶段ik<=kw-1。新增n3最后一lane的输入列为i+ik+4L-1<=ow+kw-2=inputWidth-1，起点非负。新增store最后列i+4L-1<=ow-1，无第五向量读取。步进i+=4L保持i<=ow，不依赖可能溢出的i+block循环条件。

若ow<4L则不进入新满块，完整交给原quad+pair横向fallback；ow=4L恰好一个块无尾；更宽时余列0..4L-1交给原helpers，base/dst偏移i，传ow-i但input stride及各独立dst行距不变。满块与尾列为不相交区间，组间写不同输出行；新n3与n0/1/2写四个相邻L列区间，不重复、不遗漏。4L阈值改变了处理归属，但fallback代码本身没有改动。

原接口仍要求有效且足够大的数组，32/64位size_t完整数组可寻址契约不变。本次没有新增分配、size_t乘积、全局状态、并行区或额外线程。非SVE/invalid与已有helpers保持字节原样。

## 尚待实证

24acc较父版增加6个，单input+六coeff的源级理想值约32Z；编译器若改为四input/逐coef可约30Z，但本版未强制此调度，不能据预算宣称无spill/更快。必须审查实际十一阶段、循环转场、stack与ABI保存、FMA零及4VL新增边界。C40历史G444.40ms且噪声资格false保留；C47没有运行结果，也不与不同形状C41作因果百分比比较。

准备源码SHA256：`e974915cb4e5e522526070bfdcff42b08dd7866412dbde11c76a07fac1b86d0a`。标准checkpoint record为身份依据。
