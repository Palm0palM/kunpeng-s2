# C56 准备命令与退出原件

2026-09-13。只进行本机轻量文件操作和标准实验留痕，没有编译或运行CONV、诊断、benchmark，也没有SSH或新作业。

创建前两次检查确认 `.runs/conv/C56-row7shared3fence` 和对应record不存在；实际C55生产源SHA与冻结AC1582860 source匹配。标准工具内部共享 `.runs/.workflow.lock`，new再次检查占用与父记录/四文件源哈希。

| 操作 | 实际工具/外层结果 | 原件 |
|---|---|---|
| 标准new，parent=C55-row7x3shared3 | exit0，chunkdfd65c | commands-new-command.txt、commands-new.argv.json、commands-new.stdout.txt/stderr.txt/exit.txt、commands-new-tool-result.json |
| 一次性轻量源码插入 | exit0，chunk04e787 | prepare-source.py；commands-prepare-command.txt、commands-prepare.argv.json、commands-prepare.stdout.txt/stderr.txt/exit.txt、commands-prepare-tool-result.json |
| 标准checkpoint | exit0，chunk721a7b | commands-checkpoint-command.txt、commands-checkpoint.argv.json、commands-checkpoint.stdout.txt/stderr.txt/exit.txt、commands-checkpoint-tool-result.json |

以上-command.txt保存实际执行的完整外层命令，argv.json保存实际子进程参数；stdout/stderr按原始字节写入，三个stderr为空文件，exit分别是原始0换行。没有重跑new、生成器或checkpoint。

标准new后的experiment.json原件与creation-experiment.json/creation-record.json字节一致，SHA均 `ecf3a299a5618a1ff55472a9ab4e96118d780185381258823621649a148dc7c8`；保留最初planned和父源SHA，不事后改为当前源。标准checkpoint只更新本候选对应record，状态prepared、verified=false、source_hashes为当前四文件。

prepare-source.py只导入Python标准库，持有共享workflow锁，读取固定候选和父冻结源、按三处固定边界插入文本、生成SHA/diff/audit；没有调用编译器或诊断。它要求初始planned/父精确SHA和未存在source-audit，完成后不能再次使用来覆盖候选。完整candidate.patch已人工逐hunk读取，source-audit.json说明删除插入即可恢复所有父字节；三个未改生产文件另有独立cmp均0。

hypothesis-source.md是N final假设的原字节副本，原路径和SHA在source-audit.json。PLAN/STATIC_REVIEW/BOUNDARY_MATRIX记录意义、风险和下一检查；未生成任何C56实际PASS、汇编范围或机器性能。最终源码SHA `6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`，112355字节。

只修改本C56目录与对应新record；原C55/AC冻结树、best、包和其他题目/实验没有写入。最终交root独立审查，未经另外GO不启动计算。FINAL/STOP。
