# T2-k128：本机验证与单参数变更

从 T0 源码建立，仅将 `enum { KB = 256, CT = 64 }` 改为 `KB = 128`。不改变 CT、4×8 微核、小工作集求解、线程分工、官方 benchmark 或 run.sh。假设是更小的 k 块减少活动输入工作集和对角求解成本；代价是更多同步和 B 写回，且浮点分组变化，必须测量验证。

为在同一真实资源分配中测量，提交前将父测量记录刷新为 T0-r2；它与 T0 算子及全部源码逐字节相同。原准备元数据保存在本轮编排目录的 T2-k128-before-cohort.json。此处未把未测候选晋级。

复用上轮本机验证脚本与测试：Apple ARM64 / Apple clang 17 / Homebrew libomp，纯 UBSan、禁止 fast-math、ffp-contract=off。正常 1/4 线程各检查原 7 组和扩展 4 组，共 22 次 TRSM 用例；全部 PASS，UBSan 无诊断。强制 posix_memalign 失败的 4 线程构建另有 4 组 PASS，其中 4095×9 实际触发 solve_panel 分配失败回退；另外三组运行无分配的 solve_blocked，不能称为共享面板分配回退覆盖。所有构建和执行退出 0，B padding 与 L 不变性均通过。

源码 SHA-256：`6e78257dd61e581ad4fe3720dc91e25c63ab91e81efa3bf972617d6165407790`。

完整命令、时间戳、环境、退出码见 commands-results.json；测试输出、编译器和 libomp 版本日志保存在本目录。本机运行时间不作为鲲鹏性能。服务器 sanitizer 与官方 KML 复验未在这里执行。
