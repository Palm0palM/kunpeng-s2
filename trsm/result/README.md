# TRSM 当前最佳提交包

当前只提供 **T8 = T8-svepanel16**：[下载 T8/trsm.zip](T8/trsm.zip) · [版本说明](T8/README.md)。下载后原样提交，不要重新压缩版本目录。T7 及更早版本通过 Git 历史查阅，原实验和失败证据继续保留。

| 提交版本 | 来源实现 | 最终包验证作业 | 合计中位耗时 ms | 正确性 |
| --- | --- | --- | ---: | --- |
| [T8](T8/README.md) | T8-svepanel16 | 1576076 | 450.75 | KML25.1/GCC12 环境三轮完整套件，9/9 PASS，最大误差 1.11e-15 |

ZIP 从 main 的 `outputs/trsm-best.zip` 原样复制，大小 **11,740 bytes**，没有修改算法或重新压缩。上游最终包已在超算计算节点解压复跑，实际环境为 **Huawei KML 25.1.0 + GCC 12.3.1**、38 线程单 NUMA，三套件均确认真实 KML 与私有 GCC12 libgomp，未使用 OpenBLAS。

表中指标为三个用例在三轮独立完整套件中的中位耗时之和，每个打印样本为 `TEST_RUNS=3` 的平均值；不是官方分数。策略收益来自此前同分配 T7 对照 **508.56 → 447.59 ms，降低 11.99%**，不使用最终包复跑或历史 OpenBLAS/GCC10 的结果另算提速。

**指定官方 KML 25.2.0 复验仍未完成。哈希按用户要求未计算或验证。** 本次整理只复制原包并保留上游元数据，没有新增哈希审计，也没有在本机编译或运行题目；不将本地字节复制称作远端源码身份或传输完整性验证。

[T8/metadata.json](T8/metadata.json) 保存已测条件、完整样本和平台反馈字段。[最终交付报告](../../docs/trsm-final-20260912-r5.md) · [同分配优化与全部候选记录](../../docs/trsm-stage-r5-20260912.md)

## 历史记录

[T7 历史包与说明](https://github.com/Palm0palM/kunpeng-s2/tree/e0bf061987e729dfdca7ff537fd128a2c9889e6c/trsm/result/T7) · [T5 Git 历史](https://github.com/Palm0palM/kunpeng-s2/tree/6aa18ee1021fb9eb0bbf50a9e3be5e1a16ae3f63/trsm/result/T5) · [T4 Git 历史](https://github.com/Palm0palM/kunpeng-s2/tree/156cff4026360699b6ba6afb8a16ad99ca12a392/trsm/result/T4)。[evidence/](evidence/manifest.json) 中 T0、T1、T2 的实验及失败记录保持原样。

`MANIFEST.json` 登记当前交付路径和字节数，不计算新哈希；旧证据中的历史哈希按原样保留，未重新计算或验证。队友提交后请反馈“TRSM T8 + 分数 + 提交时间 + 是否通过 + 平台记录编号”，再补入真实结果。
