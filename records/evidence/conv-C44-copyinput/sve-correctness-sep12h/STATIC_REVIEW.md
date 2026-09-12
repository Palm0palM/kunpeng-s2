# H诊断包静态自审

仅读取、轻量文本生成与矩阵算术，未编译/执行或提交。

- 生产guard继承C36/C26已有reference/guard实现，原baseline full循环及smoke原文保留；新增真实inputWidth矩阵。COPY_PATH_PROBE之外的构建不包含任何hook调用或状态。生产对象由冻结conv2d.c和原kernel flags编译，reference与对象分开链接，运行不包含benchmark改写或候选runner计时结果。
- 原始四源字节复制，未改候选目录。十源清单和remote sha命令一致；没有认证配置或job文件。run.sh虽归档但不会被remote_job运行。
- 每个gate case的ow=width-kw+1>=1，height=oh+kh-1<=13；所有缓冲区由原guard合法分配、保护，未用非法buffer模拟尺寸上限。24,100是18,052+6,048；两种probe各6,048，六配置217,176。计数的2800/28280由独立矩阵范围推导。
- memcpy hook可并发：row_seen和全局/每调用copy计数用原子累加。状态在进入候选前串行重置，候选copy/compute两阶段的原隐式屏障后才free检查；只有此诊断使用全局状态，生产源没有新增状态。guard按case串行运行。
- 仅instrumented_candidate.c局部宏拦截三个候选调用，标准/平台头在宏前加载；probe/guard TU均没有这些宏，NULL注入不能误伤它们的分配。目标/源偏移检查先验证整数地址范围与行整除，再访问合法行；gate最大分配7488字节。
- free hook先核对每行payload/未用区、计数及完整output/reference，再释放真实buffer；返回后再核对唯一释放。失败模式应有一次候选malloc尝试且0成功/复制/释放，guard原输出逐位检查仍执行。异常遗漏释放由诊断标错并清理，不能被判为PASS。
- padding毒化只属于插桩对象，生产副本不初始化padding。探针仅能检测padding导致的输出/写入错误，不证明每条未影响输出的读取；源级范围证明仍需要独立审查。大尺寸/512MiB拒绝路径只作静态证明，未尝试超大内存或无效buffer。
- remote_job先拒绝非Linux/AArch64或非38CPU单NUMA，再编译/运行。set-euo-pipefail、每阶段日志及EXIT trap保留失败状态；instrumented和production分别构建，没有fallback重编译或忽略正确性错误。调度成功与PROBE_COMPLETE仍须结合退出及精确日志审核，prepared.json不是通过证据。

## Independent root package review

Static inspection only, no compilation or operator execution. Standard headers are included before candidate-only malloc/free/memcpy macros; the separate probe and guard retain libc calls, so forced failure cannot affect reference allocation. Production links its uninstrumented object separately. The small-domain stride oracle uses incremental search, while per-row source/destination/length checks and row counters cover actual copies. Threaded copy counters use atomic operations; copy and compute implicit barriers precede the single-threaded free check. Success mode checks complete output/reference equality before real free plus payload/padding preservation; forced-null mode requires zero copies/frees and still runs ordered reference checks. All errors persist across cases and cause nonzero diagnostic exit.

The focused matrix has12widths*3kh*6oh*7kw*4placements=6048 calls.10 changed-stride eligible widths*2kh*5oh*7kw*4placements=2800 eligible calls. Sum of eligible input heights is101 across kh/oh, hence101*10*7*4=28280 copies. Production adds6048 to18052; success/failure each add6048, yielding217176 per candidate over six configurations. Actual compiler acceptance, execution, counts and exit status remain unverified. Large-capacity/size_t extremes remain static-only as stated; no runtime coverage is inferred.
