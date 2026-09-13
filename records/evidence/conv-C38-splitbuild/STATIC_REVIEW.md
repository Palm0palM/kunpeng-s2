# C38-splitbuild 静态审查

- 仅新候选的 `source/run.sh` 构建段改变；源码、benchmark、源码 README 逐字节保持 C26 快照，不改正式题目和公共 tools。
- 原有六个基础 flags、ARCH_FLAGS、OMP_FLAGS 和两个宏的值与次序不变，两次 `-c` 共用同一数组。无额外 kernel 或 benchmark 优化选项。
- 链接仍使用同一 CC、公共参数和 LINK_FLAGS，对象顺序对应原 `bench_conv.c conv2d.c` 顺序；没有 LTO 或新增库。分离 compile/link 命令本身属于待测构建差异，不能宣称二进制已相同。
- 三个显式输出均为原 RUN_DIR 下的对象或原测试程序；唯一 RUN_DIR、脚本所在目录切换、官方每case输入/计时重复/PASS解析、线程上限和绑定完全保留。
- 实际命令用 `%q` 记录，执行仍用 `"$@"`，无 eval；`set -euo pipefail` 与每条 tee 管道保留，失败不会继续链接或进入 benchmark。此为脚本语义审查，未通过本机执行来测试失败路径。
- 本实验明确是只归因的 reference，`promotion_allowed=false` 为记录约束；没有修改公共晋级实现，禁止将其当作优化赢家。

未发现静态参数丢失、链接库变化或验收旁路。目标编译、对象生成、链接、实际环境和正确性仍待计算节点验证；本次没有运行 shell 脚本、编译器或算子测试。

独立复核（conv_pipe12_sep11）：未发现静态阻碍。公共严格FP/ARCH/OMP/宏和链接顺序、LINK_FLAGS均保留；set -euo pipefail和直接执行argv使构建及tee失败传播。C39与C38唯一runner差异为conv对象的-mtune=hip11，benchmark及链接不含此选项、没有静默fallback。计时区/四个官方case/验收条件和线程绑定保持原样。拆分构建不保证产物相同，显式tune及函数target属性组合仍待计算节点验证。
