# TRSM r7 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/compare 保存本轮唯一 cohort 的控制脚本、计划、提交元数据、通用预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。members 只保留 T8-control12-repeat-r7 与 T10-lhistbarrier 两个运行目录；本轮不要求 baseline-only cohort、T7 numeric-reference 或 preflight-t9。实际目标汇编及已存在的 assembly review 文本照常收录。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 下的 warmup 和原 run 结果分别保留。预热证据不作为额外计时轮次。static-readiness.json 若存在则作为静态准备记录收录，不是编译、测试或运行验证结果。准备目录、submitted-payload、warmup 和实际取回的 diagnostics 分别保存，清单记录每份副本的来源路径。

本轮 T8 的 prior-record.json 保存在 members/T8-control12-repeat-r7，并以作业 ID 关联 [r6 repeat 的公开记录](../trsm-stage-r6-20260912/members/T8-control12-repeat-r6/cluster.json)。关联结果见 ARCHIVE.json 的 prior_record_origin；关联失败会明确列为缺失/待核对事项，不借版本名认定。原初测及更早 history 从[既有 r6 公开档](../trsm-stage-r6-20260912/README.md)引用，不要求 r7 重建或覆盖。records/latest 保存归档时的 T8-control12 和 T10-lhistbarrier 台账，不能把不同作业的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
