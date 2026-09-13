# 已执行的轻量准备操作

1. 读取experiment new/checkpoint/lock语义、Q冻结父源与身份，确认唯一ID未占用。
2. 运行标准创建命令（其内部持公共workflow lock）：

```text
python3 tools/experiment.py new conv C52-row7x3shared2 --parent C51-row7x3u1 --strategy 'Unroll only rowseven shared-stage kernel-column loop by2, with separate per-column scopes and original u1 odd remainder; preserve per-accumulator ik then ik+1 order,7rows x3VL/21acc, other12 phases and all fallback/dispatch bytes. Hypothesis: amortize shared loop/address overhead, with unmeasured liveness/code-size risk. Source preparation only.'
```

3. 写入并运行一次性source编辑器：

```text
python3 .runs/conv/C52-row7x3shared2/prepare-source.py
```

它只做文本生成、diff、来源关联和`e.locked()`内的`e.checkpoint`，不编译或运行算子。准备后再调用会因已prepared而拒绝，不能用于覆盖已测候选。

4. 完整读patch发现两处结束括号缩进，作纯空白整理，并同步编辑器输出格式；再次在`e.locked()`内调用checkpoint，更新source-audit和完整candidate.patch。算法与其它源码文件不变。具体说明见STATIC_REVIEW.md。
5. 写入计划、静态审查与未来边界建议，source停止修改等待根独立审查。

未使用编译器、SSH、调度器、诊断或benchmark；没有性能数据、ZIP、晋级、发布或重置操作。
