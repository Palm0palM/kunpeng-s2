# Sep12b 独立正确性诊断

本轮已获根代理明确GO：C6的性能确认与最终ZIP作业均已结束，诊断按序执行；后续性能组等待全部诊断完成。配置沿用 config/conv-sep12.local.json，不降低主机校验。诊断按候选定稿顺序串行执行，下一轮正式性能组等待全部诊断终止。

| 候选 | 主 helper | 每行向量 | 输出行数 | 总累加器 | 当前状态 |
| --- | --- | ---: | ---: | ---: | --- |
| C28-row4x6u1 | conv_sve_rowquad | 6 | 4 | 24 | 已快照，按序执行 |
| C29-row4lane4 | conv_sve_rowquad | 4 | 4 | 16 | 已快照，按序执行 |
| C30-colchunks | conv_sve_rowquad | 4 | 4 | 16 | 已快照，按序执行 |

C28 的 EXPECTED_ACC=6，C29/C30为4。BLOCK_OUTPUTS只报告候选主quad每行块宽；不表示所有辅助函数的块宽相同。原rowpair/rowtriple仍为4VL，原prefix主块为8VL并含更小尾处理，诊断没有写死quad4VL。三候选均要求可达pair/triple/quad入口非零，prefix/tail记录实际次数。

复用 sep12/sep11c 的相同 guard、smoke 和远端 wrapper。C28每个full配置18,052项：原3,268项，加24宽度×14 kernel形状×11输出高度×4对齐/保护页组合。C29仅在其独立guard快照中额外增加kernel形状(4,5)/(4,6)，每配置增加24×2×11×4=2,112项，full为20,164项；共享模板与C28快照不变。高度1/2/3/4/5/6/7/8/9/12/16覆盖分组余数与四线程quad工作；宽度覆盖128/256/512位下4VL/6VL/8VL/12VL边界。每配置smoke96项（宽度1/193/385、kh1..4、kw3/4、oh5、两种pad和两端放置）；kw4可进入C29新的四系数路径；full中kw5、kw6、kw7分别覆盖四步主体后余1、余2、余3，kw4/8覆盖整除路径。新增形状的kh=4保证进入quad主体，避免只测到小核回退。

C30只在其独立guard快照中追加输出宽度255/256/257/511/512/513，扩展宽度共30，kernel仍原14种、高度11种，full=3,268+30×14×11×4=21,748项/配置。验证256列调度切块的完整/局部尾块、global ow输出行距、local chunk_width，以及4线程团队内同一rowgroup的并行列块。

1/4线程×SVE16/32/64字节，共六配置：**C28为108,312 full + 576 smoke = 108,888项；C29为120,984 full + 576 smoke = 121,560项；C30为130,488 full + 576 smoke = 131,064项**。输入/kernel只读、两端保护页、输出NaN预填与canary、逐位有序scalar参考及各worker实际VL检查不变。编译使用-fno-fast-math -ffp-contract=off，全部算子编译执行仅在调度计算节点。本机不编译或运行测试；不运行sanitizer，日志记录NOT_RUN。

## 执行与验收

```text
python3 .runs/conv/sep12b-checks/driver.py C28-row4x6u1 config/conv-sep12.local.json submit
python3 .runs/conv/sep12b-checks/driver.py C28-row4x6u1 config/conv-sep12.local.json status
python3 .runs/conv/sep12b-checks/driver.py C28-row4x6u1 config/conv-sep12.local.json fetch
```

其余候选替换版本名。沿用38CPU单NUMA和1800秒上限；30–45秒轮询一次，提交后保存并回报唯一job ID，禁止重复提交。不与performance作业重叠。

验收要求：调度job ID匹配、SUCCEEDED及job/system退出0；wrapper退出0、PROBE_COMPLETE；六组C28恰18,052 full、C29恰20,164 full、C30恰21,748 full，各配置smoke仍恰96项，实际线程/VL/每行主块正确，可达入口计数非零；沿用自动传输manifest身份核验，不额外重复人工哈希审计。汇编报告按实际单列/双列/四列主循环注明工作量，区分向量spill与外层标量/ABI保存，并记录FMA、movprfx/ext/dup、输入加载与广播/replicate-load和总指令数。不将静态指令数直接当作提速证据。

完整通过才能标validation.complete=true。失败保留日志，不修改源码/容差/原始证据。仪器需修订时先报告根代理，并在新目录重跑。旧sep12证据保持原样。
