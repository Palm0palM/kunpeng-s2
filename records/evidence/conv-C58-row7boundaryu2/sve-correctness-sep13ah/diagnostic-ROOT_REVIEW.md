# AH root 静态复核

已完整阅读 driver.py 和 remote_job.sh；复核 AE→AH 差异中的身份、串行门禁、源码/record关联、五文件清单和 matrix/prepared 改动。source C58 的12条pragma独立审查见原候选 INDEPENDENT_SOURCE_REVIEW.md；其余三个生产文件不变。两checker复用原AE字节，原44328/六配置/19stage不变；不复制C56 fence接受schema。实际汇编/数值仍待本版超算作业。

AG原1583276已12FAIL、官方误差超1e-5，原始日志完整，并由 tools/experiment.py record 一次登记失败（665bb8/0）；AF原1583230全部48PASS但C56资格false，已登记比较。仅这两原ID及P/AH预约串行检查；失败终态且有job/system整数退出码可释放占用。唯一root提交前重新读主额度，达到40停止，不使用reset。

上传前排他job预约；不明提交保留并恢复，不重投。status/fetch只使用原ID，raw不覆盖异字节。计算仅在调度分配38CPU/24576MiB/单NUMA节点。验收仍需本版数值和简洁实际unroll/stack/FMA0证据。静态复核不等于数值通过，不晋级或打包。
