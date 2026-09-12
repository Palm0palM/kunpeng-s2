# C46-row5x5asmfix：GCC10 SVE asm 操作数打印兼容修正

- parent / source_parent：`C42-row5x5asm`。仅新候选，不修改C42失败源、诊断日志或已冻结记录。
- 状态：prepared。仅轻量源码/记录编辑；没有编译、测试、SSH、作业提交、诊断wrapper或重置卡操作。

## 已发生的失败

C42唯一诊断1579627在第一条构建命令失败，GCC10.3.1对五处asm共150次报告`invalid operand prefix '%Z'`；job exit1、system exit10001、wrapper exit1，实际数值检查0项。证据为`../C42-row5x5asm/sve-correctness-sep12g/RESULT.md`及其raw/build-guard.log。没有实际C42生产汇编可供判断寄存器分配、spill或FMA，也没有性能结果。保留该失败，不重提原版本。

## GCC10一手证据与选择

[GCC官方源码镜像 releases/gcc-10，aarch64.c](https://raw.githubusercontent.com/gcc-mirror/gcc/releases/gcc-10/gcc/config/aarch64/aarch64.c) 的`aarch64_print_operand`：

- 9827行为无modifier的`case 0`；9835–9839行对REG且`aarch64_sve_data_mode_p(GET_MODE(x))`、单个register时直接用`z%d`打印寄存器。多register SVE tuple另走范围格式，本候选所有操作数为单个`svfloat32_t`，不是tuple。
- 该函数9601–10042的modifier switch没有`case 'Z'`；10038–10040的default报告invalid operand prefix，与C42目标失败对应。9750–9761的S/T/U/V另有tuple-register用途，无需改用它们。
- [GCC Extended Asm命名操作数规则](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html) 用`%[name]`引用声明的named operand，额外modifier是另加的。因此`%[a].s`使用默认SVE打印得到`zN.s`；`.s`仍由模板显式提供。

这是已核实的GCC10后端实现路径，不是从当前GCC15的%Z文档类推，也没有用本机试编译猜答案。本次未取得超算安装头文件/后端二进制源码快照，目标GCC10.3.1实际接受性仍待独立编译；不把文档推理标为PASS。

## 唯一变化

五段asm的50条FMUL/FADD模板行中，150个`%Z[name]`全部替换成`%[name]`，保留`.s`、命名操作数和完整指令顺序：

```c
"fmul %[t].s, %[v].s, %[ka].s\n\t"
"fadd %[a].s, %[a].s, %[t].s\n\t"
```

以上两行展示格式变化，其余命名按原模板替换。五个acc输出`+&w`、scratch输出`=&w`、六输入`w`、volatile与memory clobber均逐字保留。声明、输入加载表达式、五输入向量scope、每scope五次独立FMUL/FADD、其它八阶段、尾列、分派、benchmark/runner/README和flags完全不改。

这只修复编译器操作数显示语法，不更改算子优化假设或数值顺序。C42原25acc+5系数+1input+1scratch共32个源级SVE值的寄存器压力仍存在，不能声称兼容修正会消除spill或提速。memory只保持原编译器屏障，不新增硬件同步。

## 后续验证仍待根代理安排

先确认目标GCC10.3.1能够打印并汇编全部50条指令；若继续失败，保存真实错误，不能改成弱约束、固定寄存器或本机替代测试。成功后审查实际五scope的concrete operands，scratch与系数/input/acc不意外重叠，单独FMUL/FADD顺序、完整quint九阶段与过渡、栈spill/ABI保存和全源码FMA；再独立跑原C42计划的六配置边界/逐位/只读/guard/canary/实际入口检查。C42执行0项，因此没有可复用的PASS。

只有实际正确性与同环境性能证据才能支持进一步选择。此候选尚无编译、正确性或性能结论；原C6正式最佳不变。
