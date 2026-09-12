# C55 实际准备命令与留痕

工作目录为 `LOCAL_USER_HOME/Downloads/conv/kunpeng-conv-next`，分支 conv/next-measured。开始只读查看现有变更并保留其它协作者工作；C55 run/record 均不存在。父生产四文件与原 C52 record 对照，T 冻结 kernel 独立对照；实际 T passed/complete/37128、assembly.review_complete 与 freeze passed 均读取真实字段。

标准 new 的完整实际 shell/Python 命令保存在 commands-new-command.txt。它先在共享 `.runs/.workflow.lock` 内重新核对 ID 未占用和来源，再调用 tools.experiment.new 一次；实际 exit0、chunk8cd31c。工具完整返回对象（包括命令输出和退出码）保存在 commands-new-result.json。

通过本地纯文本替换从 C54 已审生成器准备本版 prepare-source.py，输入源仍固定原 C52/T；未运行 C54 工具或修改 C54 文件。对生成器全文作静态阅读后，仅执行一次：

```text
python3 .runs/conv/C55-row7x3shared3/prepare-source.py
```

其完整实际 subprocess 包装命令保存在 commands-prepare-command.txt。生成器在共享锁内要求 planned 状态，校验父源、两个原列 body 身份与逐列语句数，写 shared3 源、patch、source-audit/来源 metadata，再调用标准 checkpoint 一次。实际 exit0、chunkbeffcc；stdout/stderr 分别保存在 commands-prepare.stdout.txt、commands-prepare.stderr.txt（空），argv/退出在 commands-prepare-result.json，完整外层工具结果在 commands-prepare-tool-result.json。

两次登记操作均一次成功，没有失败、重试或覆盖；生成器再次遇到 prepared 会拒绝。experiment.json 的 source_hashes 仍是 new 时的父源快照，prepared record 与当前 source/source-audit 保存本版新哈希；未把诊断 harness 清单当生产四文件清单。

后续仅只读 patch、来源哈希和 prepared 状态，写本目录策略/静态/边界说明。未 SSH、编译、运行算子、创建诊断/性能 job、record 性能、ZIP、promote 或 publication；S/Y false 和 C6 保持。额度读数随任务前后查询，无 reset。
