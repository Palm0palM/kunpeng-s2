# C53 源码准备命令与边界

工作目录为 `LOCAL_USER_HOME/Downloads/conv/kunpeng-conv-next`。准备前已读取工作规则、实际冻结 Q 源和 V 假设，检查当前分支 `conv/next-measured`、既有工作区改动和 C53 标识未占用。所有既有改动及并行 W/T 文件保持；标准 new 也会拒绝已有候选。

实际执行的两个 Python 命令仅用于已授权的轻量实验记账和一次性文本生成，不是题目、测试或编译程序：

```sh
python3 tools/experiment.py new conv C53-row7cursors --parent C51-row7x3u1 --strategy 'Replace only the seven rowseven shared coefficient row-base plus ik expressions with per-tile cursors initialized at kernel rows6..0 and advanced once per coefficient across t; preserve one-column ik loops,all21 ordered updates,input indices,other12 stages,dispatch and submission settings. Test actual address induction only; no assumed codegen or speed gain.'
python3 .runs/conv/C53-row7cursors/prepare-source.py
```

第一条使用标准 experiment.new 的共享锁，创建源快照和 planned 记录。第二条已执行一次成功，使用同一个 `experiment.locked()`；在锁内核对 planned 状态、父 Q 作业1581822、冻结源 SHA、初始四文件和当前父记录，直接从冻结 Q 的 conv2d.c 字节构造新源，写 candidate.patch，保存来源说明并调用标准 `experiment.checkpoint()`。再次执行会因已 prepared 而停止，不能作为重跑入口。

生成完成的文本结果为：

```text
candidate: C53-row7cursors
status: prepared_source_only
source_sha256: d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0
changed_parent_lines: 1477..1527
changed_candidate_lines: 1477..1529
record.status: prepared
record.verified: false
```

随后用文本读取复核完整 candidate.patch、修改后 shared、helper 入口/tile 循环、公开尺寸防御、source-audit 和当前 record，补齐 PLAN、STATIC_REVIEW、BOUNDARY_MATRIX 与本文件。没有执行或导入测试、编译器、诊断或性能程序；没有 SSH、预约、提交、作业、ZIP、晋级或发布。

创建元数据 `experiment.json.source_hashes` 保持父源初快照；当前源哈希位于 prepared record `records/experiments/conv/C53-row7cursors.json` 和 `source-audit.json`。四提交文件中仅 conv2d.c 变化，另外三文件哈希未变。所有源码写入仅发生在 `.runs/conv/C53-row7cursors/source/conv2d.c`；标准记账写入新候选自身的元数据和记录。

未准备新诊断目录或工具，未给 C53 继承任何 PASS。交 root 独立源码审查后 STOP；任何后续 compute 需要新的明确 GO。
