# C49 静态审查（没有运行验证）

只读C45实际.L342及C32已有屏障方案后，在新快照内作4处const删除、3处empty asm插入。标准experiment new/checkpoint与.workflow.lock用于创建/冻结；候选补丁记录全部改动，不改已测C45、其它helpers、bench/run/README或正式C6。

## 空模板与寄存器合同

四个packed svfloat32_t先由原LD1RQ初始化，随后作为+w读写lvalue；每个asm的16个acc输入也已由初始+0及当前q原运算定义。空模板没有指令、输出改写或新增内存读写，输入位模式通过同一寄存器保留。+w只对编译器建立未知新定义，未来constant-lane DUP依赖新定义；没有引用%Z等目标打印modifier，也无固定寄存器/多指令early-clobber风险。

4个读写operand按GCC算8个，再加16输入共24<=30；memory clobber不增加此操作数计数。物理活跃值基本集合为4packed+16acc，不能把上限或源级值当无spill证明。模板没有实际改输入，满足输入-only不变约定；不使用&因为无早写。编译器可在每个q内部重新安排，或为强制live状态插入spill/搬移；memory只是编译器限制，不能替代运行时线程屏障。

## 严格浮点及边界

所有原svmul_f32_x及svadd_f32_x表达式、排列、constant lane0..3和输入/kernel地址原样。每输出的kernel行t-r仍从0..kh-1，每行q/ik严格递增；屏障只约束不同输出间调度，不新建部分和、reduction或FMA。空模板不触碰浮点控制状态或产生额外算术，因此保留原独立mul/add两次舍入；实际编译后仍须查FMA与逐位结果。

四列仍仅在kw-ik>=4时进入，故ik+3<=kw-1；水平完整块仍ow-i>=4VL，最后输入列i+4VL-1+kw-1<=inputWidth-1。所有原行地址和t/kh条件不变，最后四行输入边界沿用C45。kw不足4不执行任何新asm；四列后的原两列/一列余数及kh小核回退、横向尾部、余1..3行、非SVE/invalid保持字节不变。没有新增索引/整数乘加、分配或指针，故没有新增整数溢出或释放路径。

## 实际证据和限制

C45 shared185指令、6load/6store真实spill是尝试的依据，不是C49已验证结果；C32 indexed单屏障与本方案的q屏障/packed readwrite不同。PLAN列明GCC官方原始URL和获取版本。全部本轮编辑只是轻量文本，没有编译、测试、解析器测试、SSH、超算提交、诊断包或重置操作。后续必须根独立审查、目标编译/全部数值与机器码验证，不以理论寄存器预算晋级。
