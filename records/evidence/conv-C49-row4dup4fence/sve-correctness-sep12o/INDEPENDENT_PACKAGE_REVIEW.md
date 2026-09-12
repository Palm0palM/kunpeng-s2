# O/C49 包装独立审查

根代理已直接比较 I/C45 与 O/C49 的 remote_job.sh：唯一差异是候选身份 C45-row4dup4 → C49-row4dup4fence。已读实际 wrapper、guard 矩阵与入口插桩代码，19 阶段、3 个 GCC 调用、资源检查、pipefail/EXIT 日志保留与原 I 一致。生产 guard 单独编译未插桩 conv2d.c，分派程序单独插桩，生产汇编单独生成；没有官方 benchmark 或性能运行。

固定每配置 20164 full 加 96 smoke，六个 VL/thread 组合共 121560。smoke 是 3 宽度 × 4 核高 × 2 核宽 × 2 padding × 2 placement；full 覆盖 kw=4/5/6/7/8 以及多个输出块边缘和行组余数。guard 未增加 kh=5，不能宣称该核高已动态覆盖。入口检查是旧 helper 汇总而非新四列循环逐 case 计数，无 direct 测试或 worker mask。该范围与 prepared.json 声明相符。

C49 的三段空 asm 不要求在返回 .s 中出现三条指令或 #APP 标记。实际成功目标编译结合冻结生产源码，才能证明 GCC 接受约束；后续应从数据依赖和调度解释实际四列循环是否变化。若无法分开定位各空 asm，应如实记录，不能制造 PC 范围。整个 helper 的 spill、七阶段及转换、旧回退和分派仍需实际检查。

本次只做轻量文本审查，没有运行或导入工具、编译、SSH 或提交计算作业。O 尚未 GO。
