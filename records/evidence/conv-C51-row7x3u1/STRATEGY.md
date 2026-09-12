# C51-row7x3u1：七行、每行三向量

状态为 prepared，尚未编译、诊断或测量；根代理独立源码意见见 `INDEPENDENT_REVIEW.md`，后续诊断流程仍由根代理审查决定。

源父版为冻结的 C40-row6x3u1，G 诊断作业 1579597，源 SHA-256 为 `cb471782329b01b9bf72d6e992941edde1361d19ced2bb69a576ec5fa8ee69e7`。本候选与 C40 创建独立源码快照，仅将其专用六行组改为七行组，横向保持 3VL、kernel 列单步和普通乘后加；相应调整第一个专用 dispatcher。旧四行/三行/两行/单行 helper、剩余 SVE dispatcher、非 SVE 路径、尺寸检查与其他提交文件保持父版字节。

N 原作业 1581459 同分配测得 C40-r3 参考 444.44 ms、C47 450.63 ms、C48 448.13 ms。C51 用 7×3VL 探索输出间输入共享、系数广播摊销与累加器压力的取舍。这些数字只是选题背景，没有给未测 C51 填写耗时或收益。C40-r3 仍只作参考，原 G 未通过/J 通过/K 未通过判定不变，正式最佳为 C6。

|共享阶段每个 kernel 列的源码计数|C40 6×3VL|C51 7×3VL|
|---|---:|---:|
|独立累加器|18|21|
|输入向量加载|3|3|
|系数广播|6|7|
|向量乘法 / 加法|18 / 18|21 / 21|
|输出 float 数|18L|21L|

这里 L 是 `svcntw()`。仅按共享阶段源码计数，输入加载/输出从 1/(6L) 变为 1/(7L)，系数广播/输出均为 1/(3L)。计数不包括所有起始、收尾和回退成本，也不代表 GCC 最终指令、寄存器分配、spill、访存吞吐或性能。21 个 acc 加七个系数及输入/临时寄存器可能改变实际机器安排，必须查看计算节点原汇编与所有阶段转换。

约束：不加入 asm、预取、FMA、partial sum、重关联或跨线程 reduction；不改变 benchmark、计时区、精度容差、runner、CPU target 和资源限制。当前只运行轻量源码生成及文本/哈希审查，无本地或远程算子执行，无 SSH、作业、ZIP 或晋级。

准备命令为标准 `experiment.new`（在共享锁内，parent=C40-row6x3u1）和 `python3 .runs/conv/C51-row7x3u1/prepare-source.py`。生成器自身持锁，拒绝覆盖已准备/已测候选，写完整 `candidate.patch`，最后以标准 `experiment.checkpoint` 保存实际源码哈希。`experiment.json` 的 `source_hashes` 按现有工具语义保留创建时父版快照，prepared record 与 `source-audit.json` 保存新候选哈希。
