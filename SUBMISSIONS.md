# 三题当前最佳提交包

下载对应 ZIP 原样提交，不要重新压缩版本目录。当前提交清单只保留每题已验证的最佳版本；历史候选、退化策略和原始测量字段继续保留在 records/ 与 Git 历史中。

| 题目 | 当前版本与实验 | 可直接提交的包 | 说明与反馈 |
| --- | --- | --- | --- |
| CONV | C6 / C26-r1（来源 C26-row4loads） | [conv.zip](conv/result/C6/conv.zip) | [版本说明](conv/result/C6/README.md) · [元数据](conv/result/C6/metadata.json) |
| ZGEMM | Z1 / Z1-control2（来源 Z1-pack） | [zgemm.zip](zgemm/result/Z1/zgemm.zip) | [版本说明](zgemm/result/Z1/README.md) · [元数据](zgemm/result/Z1/metadata.json) |
| TRSM | T8 / T8-svepanel16 | [trsm.zip](trsm/result/T8/trsm.zip) | [版本说明](trsm/result/T8/README.md) · [元数据](trsm/result/T8/metadata.json) |

CONV C6 的最终 ZIP 三轮复验 12/12 PASS、最大误差 0，合计中位耗时 452.66 ms；ZGEMM Z1 保留已验证的原包。

TRSM T8 直接复制 main 已验证的原 ZIP，保持 11,740 bytes；作业 1576076 在计算节点解压后使用 **KML 25.1.0 + GCC 12.3.1** 完成三轮包验证，**9/9 PASS**，最大误差 **1.11e-15**，合计中位耗时 **450.75 ms**。同分配作业 1576028 的 T7 对照为 **508.56 → 447.59 ms，降低 11.99%**；包级复验不另计算收益，也不与历史 OpenBLAS/GCC10 结果混算。指定官方 **KML 25.2.0 复验仍未完成**，哈希按用户要求未计算或验证，本次仅原样复制已发布包并保留上述验证范围。[T8 最终交付](docs/trsm-final-20260912-r5.md) · [T7 历史包与说明](https://github.com/Palm0palM/kunpeng-s2/tree/e0bf061987e729dfdca7ff537fd128a2c9889e6c/trsm/result/T7)。

上述包的运行证据、逐版本速度与优化策略见各版本说明。耗时是内部比较指标，不是官方分数或排名。正式比赛平台由队友手动提交，三题的分数、提交时间与平台通过状态均待实际反馈，不填估算值。

提交后请提供题目、版本、平台分数、提交时间、是否通过以及错误信息，补入对应 metadata.json：CONV/TRSM 使用 competition_feedback，ZGEMM 使用原有 official_score、submission_date、platform_feedback 字段。
