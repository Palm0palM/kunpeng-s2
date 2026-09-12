# AI root 静态复核

已完整阅读 submit-performance（849cea/ca88ad）、record-group 与 compare（4e6e4d）。固定C26-r36 / C58-row7boundaryu2 / C26-r37，各三套，共36样本；不增加父参考。C58仅使用自己的AH1583350、44328/19stage/原件身份及实际目标审查，AH已首次验收归档81701c/0。

保留creation-experiment原字节，checkpoint记录当前源码，source_parent原C52与比较parent结束C6分别记录。每成员真实scheduler/wrapper/PASS/机器/编译器/全部样本一致后才能compare；两端门槛沿用experiment.comparison，保留全部慢样本，不自动确认、晋级或打包。AF/AG及旧确认结论不改写。候选性能失败也应保留原日志，不能以退化或异常波动重跑同ID。

串行只核最新AH/AF/AG与P/自身预约，唯一campaign在调度提交前保存。不明返回仅恢复原job。全算子运行在38CPU/24576MiB/单NUMA超算节点，原benchmark和runner不改。本地无编译或测试。最终提交需作者FINAL、独立审查完成及fresh主额度<40；无reset。
