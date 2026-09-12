# TRSM 当前最佳提交包

当前只提供 **T19 = T19-panel8x16budget**：[下载 T19/trsm.zip](T19/trsm.zip) · [版本说明](T19/README.md)。请原样提交ZIP，不要重新压缩版本目录。

| 提交版本 | 来源实现 | 最终包验证作业 | 合计中位耗时 ms | 正确性 |
| --- | --- | --- | ---: | --- |
| [T19](T19/README.md) | T19-panel8x16budget | 1581516 | 317.01 | KML25.1/GCC12环境三个完整套件，9/9 PASS，最大误差1.11e-15 |

本次同步队友已验证并晋级的成果：从main的 `outputs/trsm-best.zip` 原字节复制，大小 **15,593 bytes**，没有新增测速、修改算法或重新压缩。已有最终ZIP在超算计算节点解压验证，实际环境为 **Huawei KML25.1.0 / GCC12.3.1**、38线程单NUMA，真实KML头文件、默认 `-lkblas` 和每套KML/私有libgomp依赖已由上游确认。

每个样本为 `TEST_RUNS=3` 的均值，再取三个完整套件的逐用例中位数并求和；317.01ms是内部耗时指标，不是官方得分。此包验证不与此前作业混算增益，也不代替同分配优化比较。完整样本及来源保留在[T19/metadata.json](T19/metadata.json)和[最终交付报告](../../docs/trsm-final-20260912-r16.md)。

**指定官方KML25.2.0复验尚未完成。哈希按用户要求未计算或验证。** 本次只比较本地原包/副本字节及ZIP成员结构；没有新远端验证、编译或运行题目。`MANIFEST.json`登记当前交付路径和字节数，旧evidence条目和历史哈希原样保留，不重新计算或验证。

## 历史与平台反馈

[T8历史包与说明（ce44a3d）](https://github.com/Palm0palM/kunpeng-s2/tree/ce44a3d0187ad316906107a4b00937ce95e0ba18/trsm/result/T8)保存在Git历史。当前目录移除T8三个交付文件，只保留T19最佳包；[evidence/](evidence/manifest.json)中的旧实验和失败记录保持原样。

队友提交后请反馈“**TRSM T19 + 分数 + 提交时间 + 是否通过 + 平台记录编号**”，再补入真实结果。此整理未提交比赛，未填写估算分数或排名。
