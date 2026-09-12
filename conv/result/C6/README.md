# CONV C6 提交包

下载 [conv.zip](conv.zip)，选择比赛 CONV 题目后原样上传，无需重新压缩版本目录。

当前最佳 **C6 = C26-r1**，源码方案 **C26-row4loads**：四行共享方案采用直接加载移位窗口，调整输入加载与寄存器使用。每个输出保持原 kernel 行、列顺序及独立乘法和加法，小核、尾部与剩余输出行沿用回退路径。

同一 38 核单 NUMA 分配内，C5 控制 **C21-r9** 的 **502.35 ms** 降至 **452.62 ms**，耗时减少 **9.90%**。数据为三轮完整套件的四项中位数合计，是内部比较指标，**不是官方分数或排名**。

最终原 ZIP 已在计算节点作业 **1576103** 解压并独立运行三轮完整套件，12/12 PASS、最大误差 0，四项中位数合计 **452.66 ms**。包验证与其他分配的耗时不直接比较。

ZIP 恰含 conv/README.md、conv/bench_conv.c、conv/conv2d.c、conv/run.sh；runner 保留执行权限。benchmark、runner 和源码 README 均保持原内容。本机只整理文件，未编译或运行题目。

- ZIP SHA-256：`6d6368d555eb46b24d13d0732189ab0bff422f3f1930fda0fa48b60d74e8e5fb`
- 算子 SHA-256：`0f71c88fb8898ff71bc4067abfd86ebbf29edd254e36ec57daf8924bd1727a21`
- [逐文件清单](package.json) · [校验值](SHA256SUMS) · [完整逐次耗时与反馈](metadata.json)
- [完整报告](../../../docs/CONV_SEP11C.md) · [逐版本记录](../../../docs/CONV_SEP11C_ROUND_RECORDS.md)

正式比赛由队友手动提交。请反馈 C6、分数、提交时间、是否通过与错误信息；metadata.json 的 competition_feedback 尚为空。
