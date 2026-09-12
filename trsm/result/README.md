# TRSM 当前最佳提交包

当前只提供 **T7**：[下载 T7/trsm.zip](T7/trsm.zip) · [版本说明](T7/README.md)。T5 已退出当前提交入口，历史源码与测量证据保留在 records/ 和 Git 历史。

| 提交版本 | 来源实现 | 最终包验证作业 | 合计中位耗时 ms | 正确性 |
| --- | --- | --- | ---: | --- |
| [T7](T7/README.md) | T7-diagpanel | 1524188 | 467.47 | OpenBLAS 环境三轮完整套件，9/9 PASS，最大误差 1.11e-15 |

包从 main 的 outputs/trsm-best.zip 原字节复制，已在超算计算节点解压复跑。表中耗时是三个用例中位数之和，每项样本是 TEST_RUNS=3 的平均值；不是官方分数。该最终包验证参考库为 **OpenBLAS 0.3.28 静态库**，另有同包 **KML 25.1.0 + GCC 12.3.1 独立三轮 9/9 PASS**（作业 1528027），**官方 KML 25.2.0 复验仍未完成**。两种环境的耗时不能直接用于策略提速比较。

[T7/metadata.json](T7/metadata.json) 保存已测条件、完整样本、包级结果和反馈字段；[T7/SHA256SUMS](T7/SHA256SUMS) 仅标识本次本地分发包。历史远端流程“按用户要求未执行哈希验证”的状态原样保留，本次复制与分发记录不改变该结论。没有在本机编译或运行题目。

[最终交付报告](../../docs/trsm-final-20260911-r4.md) · [晋级记录](../../docs/trsm-stage-r4-20260911.md) · [KML 25.1 独立验证](../../docs/trsm-kml251-20260911.md)

## 历史记录

[evidence/](evidence/manifest.json) 中 T0、T1、T2 的实验及失败记录保持原样；旧提交包可从 [T5 Git 历史](https://github.com/Palm0palM/kunpeng-s2/tree/6aa18ee1021fb9eb0bbf50a9e3be5e1a16ae3f63/trsm/result/T5) 和 [T4 Git 历史](https://github.com/Palm0palM/kunpeng-s2/tree/156cff4026360699b6ba6afb8a16ad99ca12a392/trsm/result/T4) 获取，不再列作当前提交包。

MANIFEST.json 登记当前 result 分发文件的哈希，历史证据条目原样保留。队友提交后请反馈“TRSM T7 + 分数 + 提交时间 + 是否通过 + 平台记录编号”，再补入真实结果。
