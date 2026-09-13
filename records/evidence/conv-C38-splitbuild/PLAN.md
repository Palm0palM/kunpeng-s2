# C38-splitbuild：分对象构建归因对照

父版本与算子源码来源均为 **C26-row4loads（正式 C6）**。本实验是 **只用于归因的 reference，禁止晋级或进入提交包**；记录含 `experiment_role=attribution-only build reference` 和 `promotion_allowed=false`，这些是审阅约束，不宣称公共 promote 工具新增了自动拦截。当前仅 prepared，未编译或测量。

目的：为下一候选的“只给算子编译单元增加调优参数”建立相同构建布局。把分对象构建本身与具体调优参数的影响分开，不将构建布局造成的偶然计时差归因于调优选项。

## 唯一改动：source/run.sh 的构建段

原 runner 用一次 GCC driver 调用编译 `bench_conv.c conv2d.c` 并链接。现在使用三个按顺序执行的命令：

1. 原公共编译参数 + `-c bench_conv.c -o "$RUN_DIR/bench_conv.o"`。
2. 同一公共编译参数 + `-c conv2d.c -o "$RUN_DIR/conv2d.o"`。
3. 原公共参数 + 两个对象，按 benchmark 在前、kernel 在后链接到原 `"$RUN_DIR/conv2d_test"`，末尾保留原 `LINK_FLAGS`。

公共参数原样收进 `BUILD_FLAGS`：`-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off`、原 `ARCH_FLAGS`、原 `OMP_FLAGS`、原 `CONV_BLOCK/CONV_KERNEL_UNROLL` 两个宏。没有新调优选项、LTO、优化级别、精度或链接库变更。`LINK_FLAGS` 仍交给链接阶段；其中的 `-lm`、平台 OpenMP 链接选项没有成为 benchmark 或 kernel 的新代码生成参数。

所有显式目标都位于原本独立的 `results/RUN_DIR`：两个 `.o` 和同名测试程序；不在源码目录生成额外对象或缓存。源文件、`README.md`、benchmark 字节和算子运算完全不变。CPU_TARGET 仍默认 generic，原编译器选择、SVE helper 属性、38线程上限、OMP/NUMA绑定、case 输入与逐case PASS 验收原样保留。

## 命令留痕与失败行为

`run_build_command` 用 Bash `printf '%q'` 按实际 argv 输出 `BUILD_COMMAND:`，然后执行同一 `"$@"`，不做 eval 或字符串重组。第一条命令和输出写入原 build.log，后两条追加；编译错误与链接错误均进入该日志。只记录编译器、构建参数、源码和目标路径，没有读取或添加任何认证配置、密码、令牌或 SSH 命令。

原 `set -euo pipefail` 保持，函数返回实际编译器状态，每条命令仍通过 tee 管道留痕。任一编译器/链接器或 tee 返回失败，整个管道失败并终止脚本，不执行下一构建阶段或 case 验收。唯一 RUN_DIR 中的部分对象仅作失败现场，不会作为下次运行缓存。日志目录创建、环境输出、run_case、官方 PASS/FAIL 检查与 summary 原文不变。

## 后续对照

只在根代理安排的计算节点验证构建和完整正确性。未来同资源分组应包含原 C6 runner、C38 分对象对照和 C39 kernel-only tuning；先比较 C6/C38 是否存在构建布局差异，再用 C38/C39 归因于唯一 tune 选项。两份参考都保留，不将未验证或未测结果写为通过；若要晋级 C39，还须在正式 C6 旁重现收益并复验实际包。

本次只轻量文本编辑、静态审查及 experiment new/checkpoint，使用工作流锁。未 SSH、编译、运行测试、提交作业、推送或使用重置卡，停在 prepared。
