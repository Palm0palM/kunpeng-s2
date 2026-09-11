# 三题当前最佳提交包

下载对应 ZIP 原样提交，不要重新压缩版本目录。当前提交清单只保留每题已验证的最佳版本；历史候选、退化策略和原始测量字段继续保留在 records/ 与 Git 历史中。

| 题目 | 当前版本与实验 | 可直接提交的包 | 说明与反馈 |
| --- | --- | --- | --- |
| CONV | C4 / C19-r2（来源 C19-sverow2） | [conv.zip](conv/result/C4/conv.zip) | [版本说明](conv/result/C4/README.md) · [元数据](conv/result/C4/metadata.json) |
| ZGEMM | Z1 / Z1-control2（来源 Z1-pack） | [zgemm.zip](zgemm/result/Z1/zgemm.zip) | [版本说明](zgemm/result/Z1/README.md) · [元数据](zgemm/result/Z1/metadata.json) |
| TRSM | T4 / T4-sve8rows | [trsm.zip](trsm/result/T4/trsm.zip) | [版本说明](trsm/result/T4/README.md) · [元数据](trsm/result/T4/metadata.json) |

CONV C4 的最终 ZIP 三轮复验 12/12 PASS、最大误差 0；ZGEMM Z1 保留已验证的原包；TRSM T4 复用 main 已发布的原包，其参考库为 OpenBLAS，官方 KML 复验仍待完成。TRSM 原记录明确未执行远端哈希验证，本次仅核对 Git 对象与复制后的本地包身份，不改变历史验证结论。

上述包的运行证据、逐版本速度与优化策略见各版本说明。耗时是内部比较指标，不是官方分数或排名。正式比赛平台由队友手动提交，三题的分数、提交时间与平台通过状态均待实际反馈，不填估算值。

提交后请提供题目、版本、平台分数、提交时间、是否通过以及错误信息，补入对应 metadata.json：CONV/TRSM 使用 competition_feedback，ZGEMM 使用原有 official_score、submission_date、platform_feedback 字段。
