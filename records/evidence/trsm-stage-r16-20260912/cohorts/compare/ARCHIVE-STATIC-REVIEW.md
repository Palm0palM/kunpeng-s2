# r16 归档准备核对

root 核对了三成员来源、A/B 各自 r15 job1579788 prior、C 新候选文档、两晋级/一机理比较、A/B general、C 专用三 JSON 与 B/C 各自 CT64 wide32 路径。纠正 root 审查文档实际文件名，并在 prepare 后按实际冻结输入建立 prepared-repeat-readiness.json。此文件名沿用旧格式，但内容明确包含两个 repeat 和新 T19。

全部三成员五源码及当前执行输入与本地 payload 字节一致；没有计算或验证哈希。未执行归档；必须待取回实际结果、登记与结果审查完成后执行一次。失败或缺失不得补造通过，也不得用未取回的完成状态发布晋级。

Archive entry-point first invocation was rejected by Python source encoding detection on the long UTF-8 README literal; direct strict UTF-8 decode and AST parsing succeeded, and the destination remained absent. Added an explicit UTF-8 source declaration before retrying. No evidence destination or partial archive had been created.
