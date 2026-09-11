# TRSM T5 提交包

下载 [trsm.zip](trsm.zip)，选择比赛 TRSM 题目后原样上传，无需重新压缩版本目录。

本包为当前已晋级 **T5 = T5-sve16rows**，大工作集 SVE 更新从八行扩大为十六行，保留 8/4/标量尾块、NEON 与分配失败回退。ZIP 从 main 已发布的 outputs/trsm-best.zip 原字节复制，未包含未晋级面板候选。

同分配三轮对照中，T4 → T5 的三项中位数合计 **518.01 → 506.21 ms**，耗时减少 **2.28%**；大用例减少 **5.52%**，中用例增加 0.71%，在项目逐用例退化上限以内。此为内部比较指标，不是官方分数。

最终 ZIP 在计算节点作业 **1513942** 解压并运行三轮完整官方套件，**9/9 PASS**，最大误差 **1.11e-15**。三项中位数为 **22.68、257.75、228.50 ms**，合计 **508.93 ms**；各样本是 TEST_RUNS=3 的平均值。调度器状态 SUCCEEDED，jobExitCode、systemExitCode 和 wrapper 退出码均为 0。独立包验证耗时不替代同分配 A/B 对照。

参考库为 **OpenBLAS 0.3.28 静态库**。**官方 KML 25.2.0 复验未完成**，原流程按用户要求未执行远端哈希验证。这里新增的 SHA-256 仅标识本次 Git 分发包，不把历史验证改写成远端哈希验证。未在本机运行题目。

ZIP 中恰有 trsm/README.md、trsm/bench_trsm.c、trsm/compat/kblas.h、trsm/run.sh、trsm/trsm.c；runner 保留执行权限。包不包含参考库二进制或账号配置。

[元数据与反馈](metadata.json) · [分发校验值](SHA256SUMS) · [最终交付报告](../../../docs/trsm-final-20260911-r2.md) · [晋级对照](../../../docs/trsm-stage-r2-20260911.md)

正式平台由队友手动提交。请反馈 **TRSM T5**、平台分数、提交时间、是否通过和错误信息，补入 metadata.json 的 competition_feedback。目前未填写估算的分数或排名。
