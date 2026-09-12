# TRSM r12 公开实验归档

此目录为已脱敏的公开派生副本；未脱敏原件保留在本地 .runs/trsm。个人路径、账号、内网地址及节点名已替换，不能把公开文本用作原始字节身份依据或重新晋级输入。没有计算或验证哈希，也没有通过归档过程运行任何编译、测试、benchmark、登记或晋级。

cohorts/compare 保存本轮唯一 cohort 的控制脚本、计划、提交元数据、finish_records.py、通用预检、preflight-wide32 宽核预检、KML 探针、实际取回日志，以及 submitted-payload 中的上传源码/脚本快照。preflight-wide32 的 guard.py、run.sh、check-wide32.c 和 README.md 分别保留当前准备版与冻结提交版。参数观察生成脚本和严格结果 parser 均完整内嵌在 run.sh 的 Python heredoc 中；没有独立脚本文件。实际 preflight-wide32-results、目标汇编及已存在的 assembly review 从结果/diagnostics 或 assembly-review 目录另行收录。members 保留 T8-control12-repeat-r12、T13-sve4x32-repeat-r12、T15-svetile128 和 T16-svetile32 四个运行目录。失败时只归档已经取回的日志；缺失项和各运行的已登记/未验证状态列在 ARCHIVE.json。

宽核结果中的 instrumented-trsm.c 是仅供参数观察的预检副本，不能当作实际 benchmark 源码；trsm-wide4x32.s 则由原候选源码生成。实际已有的 summary.tsv、summary.json、completion.txt、commands.txt、guard.json，以及 guard、compiler、instrument-source、build-normal、build-no-sve、build-fail-shared、assembly、micro-t1、normal-t1、normal-t4、normal-t38、shared-fail-t4、no-sve-t4、narrow-vl-t4、verify-results 日志按原结果目录收录。三个宽核成员 T13-sve4x32-repeat-r12、T15-svetile128、T16-svetile32 分别保留自己的结果子目录，不能以其中一个成员的日志代替另一个。微核和整算子日志中的 TILE_CONFIG_PASS KB=256 CT=32/64/128，以及 summary.json 的 expected_CT、KB 和 tile_config_processes 字段按原文保留；它们记录各测试进程对实际候选 CT 的观察。参数观察仍由 ARGUMENTS_PASS 及汇总字段单独保存。检查程序二进制不归档，缺失的运行结果不生成。

T13 重复运行若没有独立 PREPARATION 或 VALIDATION-PLAN，相应文件从原 .runs/trsm/T13-sve4x32 目录收录到该 member 的 candidate-preparation 下，来源逐项记录于 candidate_preparation_origins 及文件清单；STATIC-REVIEW 仅在当前重复目录或原候选目录已有文件时收录，不补写不存在的审查报告。它们说明既有候选，不能作为 r12 运行通过验证的证据。新候选 T15-svetile128 与 T16-svetile32 各自的 PREPARATION.md 和五个源码文件均为所需材料，已有 VALIDATION-PLAN、STATIC-REVIEW 也分别保留；准备文档不作为运行验证结果。本轮 STATIC-CONTROLLER-REVIEW 另行保留，不假定重复 run 会重新撰写候选文档。

warmup.log、warmup-linkage.log、warmup/summary.json 及 diagnostics 下的 warmup 和原 run 结果分别保留。预热证据不作为额外计时轮次。static-readiness.json、STATIC-CONTROLLER-REVIEW 和候选静态/验证计划均为准备材料，不是编译、测试或运行验证结果。准备目录、submitted-payload、warmup 和实际取回的 diagnostics 分别保存，清单记录每份副本的来源路径；冻结快照或所需准备文件缺失会列入清单，不由当前文件补写。tools/records-kml.py 与 records-kml-NOTES.md 保存本轮登记 helper 及其作者记录的静态审查/纯元数据检查说明；没有独立保存的检查输出不会补造。

本轮 T8 与 T13 的 prior-record.json 分别保存在 T8-control12-repeat-r12 与 T13-sve4x32-repeat-r12 member 下，关联 r11 公开档的 [T8 记录](../trsm-stage-r11-20260912/records/latest/T8-control12.json)与 [T13 记录](../trsm-stage-r11-20260912/records/latest/T13-sve4x32.json)，以及对应的 [T8-control12-repeat-r11 运行](../trsm-stage-r11-20260912/members/T8-control12-repeat-r11/cluster.json)和 [T13-sve4x32-repeat-r11 运行](../trsm-stage-r11-20260912/members/T13-sve4x32-repeat-r11/cluster.json)。两份原记录及对应 run 的作业 ID 都应为 1579600；逐份关联结果见 ARCHIVE.json 的 prior_record_origins。关联失败会明确列为缺失/待核对事项，不借版本名认定。更早 T8 repeat/history 由 [r11 公开档](../trsm-stage-r11-20260912/README.md)继续引用；[原始 T8 初测](../trsm-stage-r6-20260912/members/T8-control12/)实际保存在 r6 公开档。r12 不重建或覆盖旧运行。records/latest 保存归档时的 T8-control12、T13-sve4x32、T15-svetile128 和 T16-svetile32 台账，仅按本轮 job ID 关联已有声明，不预判重复比较或晋级结论，也不把不同作业的样本合并为一次比较。

本轮实际参考环境应以各作业证据为准；KML 25.1.0 + 私有 GCC12 不等同指定的 KML 25.2.0 复验。ARCHIVE.json 的 verified 字段只是原台账按作业 ID 匹配后的声明，没有在脱敏副本上重新验证成绩或远程源码身份。SOURCE 清单给出相对路径、原件字节数和公开副本字节数，不包含摘要。

私有集群配置、.ssh 目录、SSH config、known_hosts、钥匙串/认证/重连/doctor 文件、二进制、编译器、tar、ZIP 和 Git 目录均未归档。公共工具和其他题目未改动。
