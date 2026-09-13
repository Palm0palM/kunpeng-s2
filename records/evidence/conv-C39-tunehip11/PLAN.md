# C39-tunehip11：只调优 CONV 算子对象

父版本和算子来源均为 **C26-row4loads（正式 C6）**。runner 采用 [C38-splitbuild](../C38-splitbuild/PLAN.md) 的分对象构建布局；与 C38 的**唯一 runner 差异**是在 `conv2d.o` 的编译命令中追加固定 `-mtune=hip11`。当前仅 prepared/verified=false，不称为已获收益。

## 本地证据与单一假设

已有[硬件诊断](../../diagnostics/conv-hardware/REPORT.public.md)及[目标查询](../../diagnostics/conv-hardware/raw/native-target.txt)表明：作业1485312的 `/usr/bin/gcc` 10.3.1 用 native 成功生成旧 C0 汇编，并报告 tune=hip11。它支持当时该 GCC 构建识别 hip11 调优模型的判断，**不等于已经验证当前 C6 的显式 -mtune=hip11、SVE target 属性继承或性能**，也不推广为所有 GCC10 构建都可用。

假设是让目标处理器的调度/代价模型改善当前显式 SVE 算子的代码安排。保留 `-mcpu=generic` 默认和既有 helper 的 `arch=armv8-a+sve` 属性，不借此开启全局 native ISA。实际编译可能不接受该选项、属性可能影响调优继承、机器指令可能不变或出现新 spill，最终也可能更慢；没有硬件吞吐或缓存数据可预先保证收益。

## 精确参数边界

与 C38 相同的 `BUILD_FLAGS`、benchmark 编译命令、链接命令、命令日志函数和其它所有 runner 文本保持原文。唯一一行变化为：

```bash
    -mtune=hip11 -c conv2d.c -o "$RUN_DIR/conv2d.o" \
```

因此 benchmark 的编译参数与 C38 完全一致，链接阶段不增加 tune 参数。两个对象仍在原 `RUN_DIR`，实际 argv 与编译输出保存到原 build.log。`-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off`、ARCH_FLAGS、OMP_FLAGS、两个 CONV 宏及 LINK_FLAGS 不变；原38线程上限、NUMA/OMP绑定、CPU_TARGET generic默认、四个官方case、每case计时次数和PASS文本验收均不改变。

固定参数写入候选 runner，而非只在临时远端环境生效；未来提交包可按同一 runner 复现。没有修改算子、benchmark、参考计算、容差、输入、宏默认或任何其它候选源码；不叠加 C35/C36/C37 的改动。

## 失败行为与后续对照

若 kernel 编译拒绝 hip11，第二条命令经 pipefail 失败，保留 benchmark 对象和错误日志，随后停止，不运行链接或任何case；不静默去掉选项重试。失败结果必须登记，不能标记通过。其它编译/链接失败与 C38 相同，不绕过验收。

后续全部在调度计算节点：先确认真实 GCC 版本、三条完整命令、benchmark 参数一致、kernel 参数唯一差异及目标属性实际效果；检查 FMA、热点 spill 和主循环顺序，再做严格正确性/多VL与线程/边界检查。未来将 C6 原构建、C38 split reference 和 C39 放在同资源分配交错测量，C38不晋级；以 C38/C39 隔离 tune 作用，并检查相对正式 C6 的实际价值。不删除退化样本，不跨 allocation 把旧时间作为控制，不以旧 native 探针代替新候选验证。

原 build.log 仅新增实际构建 argv 记录，不读取或打印认证文件、密码、令牌。当前只执行轻量编辑与实验工具 new/checkpoint，未 SSH、编译、运行脚本或测试、提交作业、推送、晋级或使用重置卡。
