# Sep11c 独立正确性诊断（准备中）

仅写入本目录，不更改 sep11b 或旧证据。等待根代理确认 C21-r3 基线已完成、候选 checkpoint/hash 已定稿，并明确 GO 后，依次提交三个诊断；诊断之间及正式性能作业不得互扰。当前使用已确认的 config/conv-sep11b.local.json；失效时等待恢复认证，不降低主机校验。

| 候选 | 主要 helper | 每行向量 | 行数 | 总累加器 |
| --- | --- | ---: | ---: | ---: |
| C23-row3loads | conv_sve_rowtriple | 4 | 3 | 12 |
| C24-row4x4 | conv_sve_rowquad | 4 | 4 | 16 |
| C25-row3x6 | conv_sve_rowtriple | 6 | 3 | 18 |

C24 作者已确认：kh<4 时 quad 调用原 triple+prefix，kh1/2 的 triple 再回退 pair+prefix；不足四行的余3/2/1分别调用 triple/pair/prefix。当前 smoke 因此可以要求 C24 的 pair、triple、quad 均非零；C23/C25 只要求 pair、triple，quad 标记 NOT_APPLICABLE。

## 用例与验收

原 43 输出宽度 × 19 kernel 形状 × 2 对齐偏移 × 2 保护页放置 = 3,268 项保持不变。
扩展套件为 24 宽度 × 14 奇偶 kernel 形状 × 11 输出高度 × 4 对齐/边界组合 = 14,784 项；高度为 1/2/3/4/5/6/7/8/9/12/16，覆盖四行组全部余数，16 行保证四个线程都有完整 quad 组。补入 (4,4)/(7,7) kernel，保证 kh>=4 的奇奇/偶偶组合也进入 quad 主体；原基础集的奇数方形 kernel 只有 oh3。宽度包含所有 128/256/512 位下 4VL/6VL/8VL/12VL 左右边界。

每个 full 配置 **18,052** 项。独立插桩 smoke 使用宽度 1/193/385、kh=1/2/3/4、kw=3/4、两种 pad 和两端放置，oh=5，共 **96** 项；kh=4 用于实际经过 quad 主路径。1/4 线程 × SVE 16/32/64 字节共六组，总计 **108,312 full + 576 smoke = 108,888** 项/候选。

输入与 kernel 页面只读，两端保护页、输出 NaN 预填、周围 canary、独立按行列顺序 scalar 逐位参考及每个 OpenMP worker 的实际 VL 检查全部复用已通过模板。编译关闭 fast-math 与 FMA contraction；插桩二进制不用于性能判断。不运行 sanitizer，原始日志明确标记 NOT_RUN。

必须核对：唯一 job ID 与调度返回一致，SUCCEEDED、job/system/wrapper 退出均 0、PROBE_COMPLETE=1；六组 full 恰 18,052、smoke 恰 96，实际线程/VL/每行 block 一致；仅要求候选存在且可达的 rowpair/rowtriple/rowquad 入口，原 prefix/tail 记录次数；上传前、远端、取回与当前候选源码哈希全部一致。完整静态审查远端编译汇编的热点循环，区分向量 spill 与外层标量地址保存，准确记录 FMA、movprfx、加载和指令数。

完成所有验收后才写 validation.json complete=true；失败保留原始证据并标 complete=false，不改源码、容差或日志。若仪器期望需修订，与根代理协商新目录重跑。

## 执行

所有编译与算子执行必须经 dsub 分配计算节点；本机只编辑、打包、哈希和整理日志。候选源码只能在收到明确 checkpoint/hash 后 staging。每次提交后立即保存并回报 job ID，后续仅复用，不重复提交。

```text
python3 .runs/conv/sep11c-checks/driver.py C23-row3loads config/conv-sep11b.local.json submit
python3 .runs/conv/sep11c-checks/driver.py C23-row3loads config/conv-sep11b.local.json status
python3 .runs/conv/sep11c-checks/driver.py C23-row3loads config/conv-sep11b.local.json fetch
```

其余候选替换版本名。配置为同一 NUMA 分配 38 CPUs、1800 秒；轮询每 30–45 秒一次。脚本、guard 和 smoke 只做静态核对，本机未编译或运行测试。
