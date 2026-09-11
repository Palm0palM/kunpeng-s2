# 首次公开快照与证据说明

本副本从已提交的实验快照导出，供向项目仓库 Palm0palM/kunpeng-s2 提交协作改动。个人 fork 是协作镜像。

为保护计算环境与个人信息，文档和记录中的实际内网地址、计算账号、个人目录和内部节点名已替换为明显的占位符。主机占位符在记录中保持一致，但不构成公开验证真实主机身份的凭据。性能数值、正确性结果、用例、编译配置与源码 SHA 保留。

**公开日志经过脱敏，不再与超算下载的原始日志逐字节相同。原始证据保存在本地工作区。** 现有 `artifacts_sha256`、证据 manifest 中的 SHA、源码清单 SHA 以及其他原始哈希字段均保留其原始意义，不应当作脱敏文件的校验和。`records/publication.json` 单独记录每个改动文件的原始 SHA-256 与公开副本 SHA-256；其中不包含实际账号或个人目录。

不得用脱敏日志冒充原件通过自动验证，也不得以公开日志的哈希不匹配为由改写源实验判定。需要复核时应使用本地原始证据，或在授权环境中重新运行实验。示例命令和记录中的 `CLUSTER_HOST`、`REDACTED_USER`、`LOCAL_USER_HOME`、`CLUSTER_USER_HOME`、`COMPUTE_NODE_1` 与 `LOGIN_NODE_1` 需要按实际授权环境配置，不能直接连接。

首次脱敏导出时，核心源码、官方 benchmark、运行脚本与工具逻辑均保持原字节；测试中 4 处主机名 fixture 改为合成名称 `compute-node-1`，测试逻辑保持不变。此公开副本不包含实际认证配置、密码、令牌或私钥。

`records/publication.json` 对应首次公开快照；后续代码与文档修改由 Git 历史保存。本轮 CONV 新实验的公开文件校验和见 `records/conv-publication.json`，说明见 `PUBLICATION-CONV.md`；首次快照的旧校验和不用于验证后续编辑后的文件。

## 本轮 TRSM 发布

T1-panel-r2 的源码和完整测量结论来自本地已验证记录；GitHub 只保存公开脱敏副本。本轮按用户要求不追加计算哈希，已有原始哈希保留原始含义。`records/publication.json` 的 `trsm_update` 列出本轮公开文件；`files` 中仅保留此前未被本轮修改的公开文件校验记录。详见 [TRSM 证据说明](records/evidence/trsm-continuation-20260908/PUBLICATION-NOTES.md)。

## 2026-09-09 TRSM SVE 发布

当前 TRSM 更新至 T3-sveupdate-r3。源码、测量和脱敏证据的范围见 [本轮发布说明](PUBLICATION-TRSM-SVE.md)；本轮按用户要求完全不计算或验证哈希，文件列表见 `records/trsm-sve-publication.json`。此前快照的校验记录仍仅适用于其历史快照。
