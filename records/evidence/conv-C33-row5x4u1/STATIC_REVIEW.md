# C33 静态范围与边界审查

## 文本范围

新增且仅新增两个源码区域：旧 helpers 之后的 `conv_sve_rowquint` 定义，以及 generic conv2d 中原 `if(use_sve)` 之前的 `use_sve && kernelHeight>=5 && oh>=5` 分支。生成时将这两个新增区域移除，所得文本与 C26-row4loads 父源码完全一致；没有重写旧 helpers、原四行分派或非 SVE 代码。

quint 中显式声明20个累加器：a/b/c/d/e各0..3；均初始化0，末尾分别写到dst0..dst4的0..3向量偏移。各阶段按PLAN中的九行映射生成：前四个固定输入行、t=4..kh-1共享中段、末四个固定输入行。每阶段各输出kernel指针只生成一次，每个ik广播活跃系数后依次处理四个输入窗口；源码中不建立 sizeless SVE 数组，也不加入空asm。

## 人工静态推导

逐阶段核对每输出kernel行：a由0..3再4..kh-1；b由0..2再3..kh-2再kh-1；c由0..1再2..kh-3再kh-2..kh-1；d由0再1..kh-4再kh-3..kh-1；e由0..kh-5再kh-4..kh-1。最小kh=5时共享中段恰有t=4，各输出仍完整覆盖0..4；每行ik严格递增且保留独立乘/加。

满块最大输入列与原4VL相同；第五输出增加的最大输入行为row+kh+3，但quint只在剩余输出至少5行时调用，故合法。kh+1/2/3先扩为size_t；group、row、remaining和output_stride均为size_t，使用除法/余数避免oh+4，使用remaining避免row+4边界判定。小kh和oh<5完整保留原C6分派，最后1..4行通过原helper并保持全局ow间距。

本文件属于源码和文本静态审查，不代表编译成功、正确性通过或性能改善。未运行本机编译、sanitizer、benchmark或测试；实际编译调度、spill、保护页及逐位验证均待根代理安排超算。
