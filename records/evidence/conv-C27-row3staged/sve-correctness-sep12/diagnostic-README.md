# Sep12 独立正确性诊断

根代理已确认新的 SSH 主机身份并恢复认证，本轮已获明确 GO。使用根代理指定的 config/conv-sep12.local.json，不降低主机校验。诊断按 C26 → C27 串行执行，正式性能组等待全部诊断终止。

| 候选 | 主 helper | 每行向量 | 输出行数 | 总累加器 | 可达入口要求 |
| --- | --- | ---: | ---: | ---: | --- |
| C26-row4loads | conv_sve_rowquad | 4 | 4 | 16 | pair/triple/quad 非零 |
| C27-row3staged | conv_sve_rowtriple | 6 | 3 | 18 | pair/triple 非零；quad 不适用 |

复用 sep11c 已通过的 guard、smoke 和远端 wrapper，不修改源码、官方 benchmark、容差或原记录。每个 full 配置 18,052 项：原 3,268 项，加 24 宽度 × 14 kernel 形状 × 11 输出高度 × 4 对齐/保护页组合。高度 1/2/3/4/5/6/7/8/9/12/16 覆盖分组余数与四线程 quad 工作；宽度覆盖所有 128/256/512 位下 4VL/6VL/8VL/12VL 边界。每配置 smoke 96 项（宽度1/193/385，kh1..4，kw3/4，oh5，两种pad和两端放置）。

1/4 线程 × SVE16/32/64字节，共 **108,312 full + 576 smoke = 108,888 项/候选**。输入/kernel只读页面、两端保护页、输出NaN预填与canary、逐位有序scalar参考和实际worker VL检查保持原样。编译使用 -fno-fast-math -ffp-contract=off；只在调度分配计算节点编译执行。本机不编译或运行测试。不运行sanitizer，日志记录NOT_RUN。

## 执行与验收

```text
python3 .runs/conv/sep12-checks/driver.py C26-row4loads VERIFIED_CONFIG submit
python3 .runs/conv/sep12-checks/driver.py C26-row4loads VERIFIED_CONFIG status
python3 .runs/conv/sep12-checks/driver.py C26-row4loads VERIFIED_CONFIG fetch
```

第二候选替换版本名。沿用38CPU单NUMA分配与1800秒上限；每30–45秒查一次，提交后立即保存并回报唯一job ID，禁止重复提交。不与正式performance作业重叠。

完整验收包括：调度job ID匹配、SUCCEEDED及job/system退出0；wrapper退出0、PROBE_COMPLETE；六组恰18,052 full及96 smoke、实际线程/VL/每行block正确、可达入口计数非零；保留现有自动传输/manifest身份核验。按用户要求不额外重复人工哈希审计。准确区分主循环向量spill、阶段间保存与外层标量地址/ABI保存；报告FMA、movprfx、ext、加载与指令数，汇编不能替代性能结论。

只有完整通过才能标validation.complete=true。错误或失败保留日志，不改容差或证据；仪器需修订时先报根代理并在新目录重跑。旧sep11c证据不改。若认证仍不可用，保持prepared，不以本机执行替代。
