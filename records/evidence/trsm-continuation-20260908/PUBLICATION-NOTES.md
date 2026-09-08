# TRSM 公开证据说明

本目录及 trsm-20260908 保存公开脱敏副本。性能数值、PASS/FAIL、用例、编译配置和已有源码身份字段不变；内部节点、内网地址、账号与个人路径已统一替换。原始证据保持在本地工作区。

按用户要求，本次发布不追加计算哈希。原始 manifest、artifacts_sha256、log_sha256 与本机 validation-sha256.json 保留原始含义，不代表这些脱敏文件的字节校验。records/publication.json 记录本批文件清单及此限制。

本机验证清单包含未公开的检查二进制；二进制仍保留于本地 .runs。公开发布只包含源码、文本日志和说明。T2-unroll 的 static-review.txt 已补入文本证据。实验 JSON 的 log 字段保留本地原始执行路径，published_log 指向 GitHub 中的公开日志。
