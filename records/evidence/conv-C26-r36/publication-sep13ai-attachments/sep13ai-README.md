# AI：C58 首次三成员性能测量（准备完成，未执行）

固定顺序 `C26-r36 / C58-row7boundaryu2 / C26-r37`，每成员运行原官方四例的三套完整测试，合计 **36 个原始样本**。两端均为当前最佳 C6 原字节；本轮省略父参考，不能声称取得同作业的 C58 对 C52 归因测量。C58 是在原 `C52-row7x3shared2` 上仅增加 12 条边界循环 `GCC unroll 2` pragma 的新源码，不是重试 Y/S 失败确认。

C58 `conv2d.c`：`c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751`。自身原 AH **1583350** 已由 root 首次接受/冻结（工具输出 `81701c/0`）；工具只认 `.runs/conv/C58-row7boundaryu2/sve-correctness-sep13ah/validation.json` 和 `freeze-source.json` 的真实通过合同，包含 44,328、六配置、19 个零退出阶段、source/job/scheduler 身份、目标汇编审查关联。没有套用 AE fence schema，也不以 C52 的 T 证据代替 C58。AH 数值通过没有证明性能提高。

资源/环境固定为 `q_kunpeng`、38 CPU、24,576 MiB、单 NUMA pack、1,800 秒；`OMP_NUM_THREADS=38`、`OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`、`CPU_TARGET=generic`。要求真实 GCC 10.3.1、相同机器与所有设置。`README.md`、官方 `bench_conv.c`、`run.sh` 必须与 C6 完全一致；原输入、参考实现、1e-5 容差、计时与生产 flags 均不改。

仅查询最新原作业 AH1583350、AF1583230、AG1583276 的实际终态及整数 job/system 退出。AG 的原失败释放资源，仍然是失败，不能当数值 PASS。P 若只有 prepared 目录不会阻止；若已有未由 root 核实的 job reservation（即使带 ID）则停止。任何 AI campaign/成员预约都会阻止再次提交。只保存 AF48 完整初筛 false 与 AG12FAIL 已登记身份的少量原件哈希，不加载历史轮次工具、不递归审核旧数据、不扫描队友作业。

提交入口必须经 root 阅读本轮工具及独立审查后给出明确 GO。以下仅是待执行接口；本次准备没有执行它们：

```sh
python3 .runs/conv/sep13ai-submit-performance.py --go
python3 tools/cluster.py --config config/conv-sep12.local.json status .runs/conv/C26-r36
python3 .runs/conv/sep13ai-record-group.py
python3 .runs/conv/sep13ai-compare.py
```

执行器必须分别保存每次命令 argv/UTC/stdout/stderr/exit；status 间隔至少 45 秒，单次等待最多 45 秒。网络用已授权连接；严禁不明提交重投。新 campaign 在共享 workflow lock 内先排他预约，再标准 `experiment.new` 创建两个控制版；C58 现 prepared record 在本次准备中不修改。三成员初次 creation metadata 逐字节保存到 `creation-experiment.json`，已有 C58 快照只核对绝不刷新。实际提交时仅更新关联/settings，并标准 checkpoint；creation 中父源 hash 留原样，prepared/current hash 经独立字段核对。record 仅内存适配当前 source view，不能重写 creation。

原唯一 job 全部成功终态后，record 保留三个成员全部 36 个样本、逐例 PASS、调度器/系统/wrapper 退出、来源哈希、编译器和机器信息。标准记录器会保存 FAIL/不完整证据；首次 record/compare 失败应保存全部外层原输出并停报 root，不能改解析器、门槛或覆盖失败后重测。已登记 passed 记录只验证并保留。

比较继续调用 `experiment.comparison` 原规则：四例中位数之和的收益必须**严格大于** `max(1%, 两版本所有逐例 spread)`，且每例退化不得超过 1%。开头、结尾两个 C6 门槛皆过才能令 `qualified_for_confirmation=true`。保留慢样本，禁止剔除；这是初筛资格，不是确认通过、官方分数或晋级。任何结果都不会自动确认/重试、promote、ZIP 或修改 best。S/Y/AD/AB/AF/AG 历史保持原件；C6 继续保留到 root 另行决策。

本机只做轻量文本处理。主额度达到 40% 保存并停止；不使用重置卡。
