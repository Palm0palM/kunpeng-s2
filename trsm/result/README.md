# TRSM 当前最佳提交包

当前只提供 **T5**：[下载 T5/trsm.zip](T5/trsm.zip) · [版本说明](T5/README.md)。T4 已退出当前提交入口，历史源码与测量证据保留在 records/ 和 Git 历史。

| 提交版本 | 来源实现 | 最终包验证作业 | 合计中位耗时 ms | 正确性 |
| --- | --- | --- | ---: | --- |
| [T5](T5/README.md) | T5-sve16rows | 1513942 | 508.93 | 三轮完整套件，9/9 PASS，最大误差 1.11e-15 |

包与 main 的 outputs/trsm-best.zip 原字节一致，已在超算计算节点解压复跑。耗时是三个用例中位数之和，每项样本是 TEST_RUNS=3 的平均值；不是官方分数。参考库为 **OpenBLAS 0.3.28 静态库**，**官方 KML 25.2.0 复验未完成**。

[T5/metadata.json](T5/metadata.json) 保存已测条件、包级结果和反馈字段；[T5/SHA256SUMS](T5/SHA256SUMS) 用于本次分发文件身份核对。历史远端流程“未执行哈希验证”的状态原样保留，本次本地文件检查不改变该结论。没有在本机编译或运行题目。

[最终交付报告](../../docs/trsm-final-20260911-r2.md) · [晋级记录](../../docs/trsm-stage-r2-20260911.md) · [后续未晋级尝试](../../docs/trsm-stage-r3-20260911.md)

## 历史记录

[evidence/](evidence/manifest.json) 中 T0、T1、T2 的实验及失败记录保持原样；T4 的包级证据仍位于 records/evidence/trsm-package-20260911/，原版本包可从 [Git 历史](https://github.com/Palm0palM/kunpeng-s2/tree/156cff4026360699b6ba6afb8a16ad99ca12a392/trsm/result/T4) 获取。

MANIFEST.json 登记当前 result 分发文件的哈希。队友提交后请反馈“TRSM T5 + 分数 + 提交时间 + 是否通过 + 平台记录编号”，再补入真实结果。
