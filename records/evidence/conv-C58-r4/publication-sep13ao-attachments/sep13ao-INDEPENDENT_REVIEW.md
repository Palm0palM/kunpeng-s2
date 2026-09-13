# AO 性能脚本独立静态审查

只读 `sep13ao-performance.py` 全文及其相对已完成 AM1589364 脚本的 diff；未 import、执行、提交或修改工具/源码/实验记录。当前额度37%。

主体适配成立：顺序 C58-r4 / C60-row7shared2ext / C58-r5；当前最佳要求 C7/C58-r1，并核对当前 conv 源与已测 C58-r1。候选要求 prepared、无既有 cluster，两个 control 要求唯一；AN own 44328、候选身份、固定 C60 源 10df62b8d43c59a6164de7d23c1b59ab954bbaaebc330d57662e8f5d6b7f2168、实际汇编/根验收文件均有门控。AN_JOB_ID=None 在 diagnostic 起始阻止 GO，绑定真实原 AN job 后仍须根复核，不能用猜测 job。

标准 new 使用无 parent 的当前 C7 control，再统一 C7 settings；candidate 比较 parent 为 closing C58-r5，source_parent 保留 C58-r1，与源码来源 C7 一致。标准 checkpoint/record 参数接口匹配；record-compare 复用原 campaign job，核对同 job/settings/machine、36 条原始样本与逐用例误差0，分别用 opening/closing e.comparison，只有两者 eligible 才进入 confirmation_pending。没有自动确认、晋级或 ZIP。

初审发现并已由根任务修复的留痕适配项：

1. `pre-am-experiment.json`、`am-status-`、`am-fetch-` 三处名称残留，应改 AO 以准确标注轮次。
2. C60 已有标准 new 的准确原件 `creation-experiment-original.json`；当前 experiment 比该原件额外增加七个准备/来源字段，其旧字段未改变。AO 只识别 `creation-experiment.json`，会在 else 将当前已加字段的 metadata 写入这个名称。虽然不会破坏现有准确原件，但该新文件不再是原创建字节。建议优先复用并核对 `creation-experiment-original.json`，将执行前 metadata 单独记作 `pre-ao-experiment.json`；control 标准 new 后首次保存则仍是真实原件。

复核根修订（工具输出9208d3）：三个残留名称已全部改为 AO；已有准确 creation-experiment-original.json 在无 creation-experiment.json 时优先选用，核对四个固定身份字段，并将当前扩展 metadata 单独保存 pre-ao-experiment.json，不改写创建原件。当前 C60 的四个身份字段与原件相同。上述发现已解决，本有界静态审查无剩余阻碍。AN_JOB_ID 仍为 None，未 GO。本结论不是 AN 验收、代码执行成功或性能通过证据；真实 AN job 绑定后仍由根任务复核。
