# C49 O 包静态复核

仅文件复制/编辑和原文阅读；不是执行测试或实际通过。

- 使用共享 .runs/.workflow.lock，拒绝已有目标目录；只创建本包，不改C49/C45冻结源、I/H公共工具或队友文件。
- 五 source 来自真实I/C45模板；conv2d.c换为C49 immutable源码，candidate.env和wrapper仅替换硬编码候选名；guard/dispatch逐字节保留。首次自动SHA与C49 prepared record匹配。
- 已读guard全部矩阵：43×19×4 +24×16×11×4=20164 full；smoke3×4×2×4=96；六配置121560。direct0、runner0。没有kh5，不新增隐含matrix或helper-entry字段。
- 标量jk/ik参考、memcmp、保护页、只读输入/kernel、输出poison/canary原样。主线程/实际OMP团队VL检查、1/4team检查、独立smoke pair/triple/quad非零要求原样；不把插桩对象当生产。
- 包装先Linux/AArch64、38CPU单NUMA分配检查再编译；GCC精确10.3.1。后续调度者负责24GiB和唯一job；本包无提交驱动。
- stage保存每条命令真实退出；set -e与pipefail传递gcc、guard和tee失败；build_logged末命令为gcc，run末命令为guard|tee。finish等待probe.log的tee并保留失败。三gcc命令与19stage未改，编译或检查失败不会被最后printf覆盖。当前未运行这些程序。
- source-manifest与source-hashes两格式同一次数据摘要产生，不从C45复制任何通过/作业/原始日志。全部prepared标记无执行。
- 后续必须查三个empty asm约束接受及实际pack依赖/acc生存期；实际wholehelper七阶段、shared4/2/1、dispatch、spill/ABI/FMA及对C45185条6spill的差异尚未知。不能从20个列出的源级值、24个GCC operand或空template推断无spill/提速。
