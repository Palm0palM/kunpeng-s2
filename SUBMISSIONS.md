# 三题当前最佳提交包

下载对应 ZIP 原样提交，不要重新压缩版本目录。当前提交清单只保留每题已验证的最佳版本；历史候选、退化策略和原始测量字段继续保留在 records/ 与 Git 历史中。

| 题目 | 当前版本与实验 | 可直接提交的包 | 说明与反馈 |
| --- | --- | --- | --- |
| CONV | C6 / C26-r1（来源 C26-row4loads） | [conv.zip](conv/result/C6/conv.zip) | [版本说明](conv/result/C6/README.md) · [元数据](conv/result/C6/metadata.json) |
| ZGEMM | Z1 / Z1-control2（来源 Z1-pack） | [zgemm.zip](zgemm/result/Z1/zgemm.zip) | [版本说明](zgemm/result/Z1/README.md) · [元数据](zgemm/result/Z1/metadata.json) |
| TRSM | T19 / T19-panel8x16budget | [trsm.zip](trsm/result/T19/trsm.zip) | [版本说明](trsm/result/T19/README.md) · [元数据](trsm/result/T19/metadata.json) |

CONV C6 的最终 ZIP 三轮复验 12/12 PASS、最大误差 0，合计中位耗时 452.66 ms；ZGEMM Z1 保留已验证的原包。

TRSM T19 原样复制队友 main 已验证的 ZIP，保持 **15,593 bytes**。作业 **1581516** 在计算节点解压后使用 **KML25.1/GCC12.3.1** 完成三轮，**9/9 PASS**，最大误差 **1.11e-15**，合计中位耗时 **317.01 ms**。优化收益来自独立的同分配作业1579861：T8→T19 **444.75→313.20 ms，减少29.58%**；不与最终包复验混算。指定官方 **KML25.2.0 复验仍未完成**；此次同步不重新压缩、不计算新哈希或运行题目。[T19最终交付](docs/trsm-final-20260912-r16.md) · [T8历史包](https://github.com/Palm0palM/kunpeng-s2/tree/ce44a3d0187ad316906107a4b00937ce95e0ba18/trsm/result/T8)。

上述包的运行证据、逐版本速度与优化策略见各版本说明。耗时是内部比较指标，不是官方分数或排名。正式比赛平台由队友手动提交，三题的分数、提交时间与平台通过状态均待实际反馈，不填估算值。

提交后请提供题目、版本、平台分数、提交时间、是否通过以及错误信息，补入对应 metadata.json：CONV/TRSM 使用 competition_feedback，ZGEMM 使用原有 official_score、submission_date、platform_feedback 字段。
