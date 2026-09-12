# TRSM r9 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/compare 保存本轮唯一 cohort 的控制脚本、计划、提交元数据、finish_records.py、通用预检、preflight-wide 宽核预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。preflight-wide 的 guard、runner、check-wide.c 和 README 分别保留当前准备版与冻结提交版；实际 preflight-wide-results、目标汇编及已存在的 assembly review 从结果/diagnostics 或 assembly-review 目录另行收录。members 保留 T8-control12-repeat-r9、T11-sve8x16-repeat-r9 与 T12-forwardbarrier 三个运行目录。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

T11 重复运行若没有独立的 PREPARATION、STATIC-REVIEW 或 VALIDATION-PLAN，相应文件从原 .runs/trsm/T11-sve8x16 目录收录到该 member 的 candidate-preparation 下，来源逐项记录于 candidate_preparation_origins 及文件清单。它们说明既有候选，不能作为 r9 运行通过验证的证据。T12 的自身 PREPARATION 和本轮 STATIC-CONTROLLER-REVIEW 另行保留，不假定重复 run 会重新撰写候选文档。

warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 下的 warmup 和原 run 结果分别保留。预热证据不作为额外计时轮次。static-readiness.json、STATIC-CONTROLLER-REVIEW 和候选静态/验证计划均为准备材料，不是编译、测试或运行验证结果。准备目录、submitted-payload、warmup 和实际取回的 diagnostics 分别保存，清单记录每份副本的来源路径；冻结快照或所需准备文件缺失会列入清单，不由当前文件补写。tools/records-kml.py 与 records-kml-NOTES.md 保存本轮登记 helper 及其作者记录的静态审查/纯元数据检查说明；没有独立保存的检查输出不会补造。

本轮 T8 与 T11 的 prior-record.json 各自保存在对应的 r9 member 下，分别关联 r8 公开档的 [T8 记录](../trsm-stage-r8-20260912/records/latest/T8-control12.json)和 [T11 记录](../trsm-stage-r8-20260912/records/latest/T11-sve8x16.json)。两份原记录及对应 run 的作业 ID 应为 1579444；关联结果见 ARCHIVE.json 的 prior_record_origins。关联失败会明确列为缺失/待核对事项，不借版本名认定。更早 T8 repeat/history 由 [r8 公开档](../trsm-stage-r8-20260912/README.md)继续引用；[原始 T8 初测](../trsm-stage-r6-20260912/members/T8-control12/)实际保存在 r6 公开档。r9 不重建或覆盖旧运行。records/latest 保存归档时的 T8-control12、T11-sve8x16 和 T12-forwardbarrier 台账，不能把不同作业的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
