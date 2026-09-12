# T17-lhistbudget4：共享三角历史副本的4MiB预算

2026-09-12从未晋级T10-lhistbarrier的source复制原五文件，只修改trsm.c。性能parent计划仍为当时当前最佳T8-control12；T10是同期机理控制，不是已晋级来源。r13表明T14的循环生产调度未改善，本候选保持T10原schedule(static)，不合并T14。

## 单一假设与精确改动

仅限制共享packed_history副本的工作集范围，检验小副本是否能保留打包收益，而较大副本自然回到原T8系数加载。预算是预先固定的实现选择，不是硬件缓存容量，也不包含原L、worker X、B或其它存储。

在原SVE编译保护中、solve_panel之前新增命名常量 `TRSM_PACKED_HISTORY_BUDGET_BYTES = 4 * 1024 * 1024`（trsm.c:561）；在已有两个SIZE_MAX检查和安全bytes计算之后（:578），仅在bytes<=常量时调用原posix_memalign。没有修改producer、consumer、核、算术、布局、分配形状、VL/HWCAP、omp调度或已有64MiB整算法分派预算。

定义b=floor(m/16)，共享副本字节数为128*b*(b-1)*sizeof(double)=1024*b*(b-1)。4MiB为4,194,304 bytes；b64需要4,128,768 bytes，b65需要4,259,840 bytes。因此有共享历史的m=32..1039可尝试分配，1040起跳过；不足16行尾不进入该布局。此口径不是完整三角L字节预算，后者4MiB会在m1024处停止，不能混用两个阈值。

超预算保持初值NULL，所有线程一致跳过共享producer及其barrier；原consumer条件在完整行块调用原T8 solve16x8_panel_sve，尾部和X失败回退不变。预算内分配失败仍是同一NULL回退。保留full_blocks>=2和两道整数溢出保护，不引入新的乘法或线程私有分派；非SVE分支不会引用新增常量。

## 静态准备审查

新增恒量与分配门禁是对T10唯一代码差异。KB256/CT64 enum之后的整个大路径后缀与T10逐字节相同；另四个文件bench_trsm.c/run.sh/compat/kblas.h/README.md与T10逐字节相同。预处理条件嵌套平衡，forward SVE宽度helper的声明和后缀定义仍各一次。直接字节比较不计算哈希。

旧通用预检不能原样保留入口期望：4095×9仍在原小路径，但预算后packed入口为0、旧核入口510；4097×9仍在大路径、这两个panel核均0。原m≤257矩阵、原80次仅共享历史分配失败和两套14组直接核不变。新增预算两侧和分配观察见VALIDATION-PLAN.md。

本轮只做本机轻量源码/文档编辑、直接字节与文本比较、整数推导及准备脚本的AST/bash-n；没有本机编译或执行题目、SSH、prepare/submit、登记/晋级、哈希计算或验证、比赛提交。源码尚未在目标节点编译或测试。所有实际检查必须在调度分配的计算节点运行，实际GCC12.3.1/KML25.1不等同指定KML25.2复验。
