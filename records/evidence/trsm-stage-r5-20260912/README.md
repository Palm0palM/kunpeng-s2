# TRSM r5 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/baseline 与 cohorts/compare 分别保存控制脚本、计划、提交元数据、预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。members 保留四个运行目录的源码、原始结果副本与无哈希登记快照。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

T7-control11 原运行不会被新版台账覆盖：旧 raw run、T7-control11-repeat-r5 的 prior-record.json（存在时）、record-for-original-run.json（能按作业 ID 关联时），以及 records/latest 中归档时的台账分别保存。不要把不同作业或环境的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
