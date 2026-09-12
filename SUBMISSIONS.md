# 三题当前最佳提交包

下载对应 ZIP 原样提交，不要重新压缩版本目录。当前提交清单只保留每题已验证的最佳版本；历史候选、退化策略和原始测量字段继续保留在 records/ 与 Git 历史中。

| 题目 | 当前版本与实验 | 可直接提交的包 | 说明与反馈 |
| --- | --- | --- | --- |
| CONV | C6 / C26-r1（来源 C26-row4loads） | [conv.zip](conv/result/C6/conv.zip) | [版本说明](conv/result/C6/README.md) · [元数据](conv/result/C6/metadata.json) |
| ZGEMM | Z1 / Z1-control2（来源 Z1-pack） | [zgemm.zip](zgemm/result/Z1/zgemm.zip) | [版本说明](zgemm/result/Z1/README.md) · [元数据](zgemm/result/Z1/metadata.json) |
| TRSM | T7 / T7-diagpanel | [trsm.zip](trsm/result/T7/trsm.zip) | [版本说明](trsm/result/T7/README.md) · [元数据](trsm/result/T7/metadata.json) |

CONV C6 的最终 ZIP 三轮复验 12/12 PASS、最大误差 0，合计中位耗时 452.66 ms；ZGEMM Z1 保留已验证的原包；TRSM T7 复用 main 已发布的原包，OpenBLAS 0.3.28 环境计算节点三轮包验证 9/9 PASS，最大误差 1.11e-15，合计中位耗时 467.47 ms。同一 T7 包另经 KML 25.1.0 + GCC 12.3.1 独立三轮验证，9/9 PASS；比赛指定的 KML 25.2.0 复验仍未完成，不跨环境计算提速。TRSM 原流程按用户要求未执行远端哈希验证，本次仅复制原包并登记本地分发文件身份，不改变历史验证结论。[T5 历史包与说明](https://github.com/Palm0palM/kunpeng-s2/tree/6aa18ee1021fb9eb0bbf50a9e3be5e1a16ae3f63/trsm/result/T5)。

上述包的运行证据、逐版本速度与优化策略见各版本说明。耗时是内部比较指标，不是官方分数或排名。正式比赛平台由队友手动提交，三题的分数、提交时间与平台通过状态均待实际反馈，不填估算值。

提交后请提供题目、版本、平台分数、提交时间、是否通过以及错误信息，补入对应 metadata.json：CONV/TRSM 使用 competition_feedback，ZGEMM 使用原有 official_score、submission_date、platform_feedback 字段。
