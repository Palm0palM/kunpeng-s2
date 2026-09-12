# C38-splitbuild 诊断包（仅 prepared）

只在超算调度计算节点执行，当前没有提交，不创建 job.json；不本机编译、测试、SSH、运行 runner 或使用重置卡。原 candidate 的四个源码文件原字节复制且 runner 不改。首次 source-hashes.json 对应 source/ 的全部八个文件与远端 source-sha256.txt；无认证配置或私密凭据。

## 精确计数与对象边界

六配置为 1/4 线程 × SVE 16/32/64 字节。专项计数：96 production-object guard smoke × 6 = 576; no instrumented dispatch run。原 runner 另外完整执行四个官方 case 一次，仅作为实际 runner/对象验收，4 个结果不混入专项计数、三套件性能或晋级证据。

C38 guard 保留完整旧程序，调用只传 smoke，运行原96矩阵；不执行未计数的 full 或 dispatch。

先验证 Linux/aarch64、38获分配CPU和单NUMA，再直接 source 原 run.sh，继承其 CC/BUILD_FLAGS/RUN_DIR；构建三个命令和四case全部真实执行。没有条件包装 source，没有忽略错误或重新去除 tune 编译。每阶段写 stage-exits.txt；失败由 set -euo pipefail 和 EXIT trap 保留阶段/退出码，不会输出 PROBE_COMPLETE。

runner 原 build.log、environment.log、case-1..4.log、summary.log 复制到诊断根层 runner-* 文件，失败时也尽量保留。真实 RUN_DIR/conv2d.o 链接独立未tune严格guard对象；绝不重新编译算子替代该对象。对象另复制 production-conv2d.o，实际 objdump 保存 production-conv2d-objdump.log。target-query.log 用同公开 flags 不加 tune；生产 .s 使用原 kernel flags，不加诊断宏或插桩。查询只说明目标设置，不证明所有函数属性继承。

C38 不运行插桩 dispatch；保留标准文件只为诊断包身份一致，不声称入口插桩已验证。 Guard、原reference顺序、保护页/只读/输出NaN及canary、workerVL和逐位比较均保留；EXPECTED_ACC=4、CHECK_ROWTRIPLE=1、CHECK_ROWQUAD=1。原 runner benchmark flags/宏/OMP/对象链接顺序与 LINK_FLAGS 不改，C39 tune 仅在原 runner 算子对象编译行。

## 接手验收

提交者应扩展共享 driver 的版本/计数/runner四case与root日志规则；只读此README不代表它已支持本包。首次manifest须匹配所有八源码，包括 README.md；fetch应保留根层 .log/.txt/.s及所需源码，真实对象可额外归档。C38要求6×96 guard，C39要求6×7108 guard及6×96 dispatch入口；每配置实际线程/VL、退出、PASS数量和自动源码身份须一致。只有 scheduler、wrapper及全部stage退出0、四官方case PASS和对应矩阵全部完成才可冻结。没有 sanitizer 或算子PMU profile，不借用旧probe得出通过/速度结论。

A nonfatal task-only perf record /bin/true probe was added before submission under root authorization. It omits -C and -a, changes no permissions, records exact command/exit/stdout/stderr, and does not gate numerical validation. Zero samples are allowed; this only probes event-open/record support. It is not an operator metric.
