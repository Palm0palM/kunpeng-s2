# C39-tunehip11 静态审查

- 算子、benchmark 和源码 README 保持 C26 快照；候选 runner 与 C38 的差异仅为 kernel 对象编译行的一个 `-mtune=hip11` 参数。
- benchmark 的完整 argv 模板、BUILD_FLAGS、链接 argv、库和对象次序均与 C38 相同；tune 不进入 benchmark 或链接命令。命令/输出全部记录在原 build.log。
- 保留原 strict FP、宏、默认 generic ISA、SVE target 属性、编译器选择、OMP flags、38线程上限、NUMA/OMP绑定、输入与官方每case验收，无 LTO、FMA开关、额外候选算法或尺寸特判。
- 两个对象与测试程序仅输出到原独立 RUN_DIR，不增加 source 内产物或跨运行缓存；源码文件未被 runner 改写。
- 真实执行仍为 `"$@"`，%q 日志没有 eval；kernel 构建失败由原 errexit/pipefail终止，不能继续链接/跑分，也没有自动降级到 generic tune 的分支。没有接触认证信息。
- 现有 native-target 查询只能证明旧 GCC 构建识别 hip11，当前显式参数与 helper 属性的组合尚未目标编译；无需据此改写任何“已通过”字段。

静态结论：未发现修改 benchmark 编译参数、遗漏原 flags、扩大资源或绕过正确性校验。分对象布局与 C38 相同，可以在真实同资源验证后用于单变量比较；当前不具备数值通过或提速结论，停在 prepared。

独立复核（conv_pipe12_sep11）：未发现静态阻碍。公共严格FP/ARCH/OMP/宏和链接顺序、LINK_FLAGS均保留；set -euo pipefail和直接执行argv使构建及tee失败传播。C39与C38唯一runner差异为conv对象的-mtune=hip11，benchmark及链接不含此选项、没有静默fallback。计时区/四个官方case/验收条件和线程绑定保持原样。拆分构建不保证产物相同，显式tune及函数target属性组合仍待计算节点验证。
