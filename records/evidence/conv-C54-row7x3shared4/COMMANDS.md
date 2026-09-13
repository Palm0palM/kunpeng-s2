# C54 准备命令与实际结果

工作目录：`LOCAL_USER_HOME/Downloads/conv/kunpeng-conv-next`；分支 conv/next-measured。开始时已查看工作区，保留其他协作者已有变更。本文件记录已执行的轻量文本/登记操作，不是待执行算子命令。

来源检查通过后，在一次 `python3 - <<'PY'` 本地 Python 调用中，使用 `sys.dont_write_bytecode=True`、导入 tools/experiment.py，并在 `with e.locked():` 内调用以下完整登记接口：

```python
e.new(argparse.Namespace(
    problem='conv', version='C54-row7x3shared4', parent='C52-row7x3shared2',
    strategy='Source-only shared unroll2 to unroll4: kw-ik>=4 and ik+=4; four sequential complete 21 mul/add column scopes; retain original u1 remainder for 0..3 columns. All other stages,dispatch,tail,fallback and submission files unchanged. Future own correctness/codegen/performance required; prior Y/S failed confirmations preserved.'))
```

同一锁内先断言新 run/record 均不存在，检查 T1582134 实际 status=passed/complete/37128、source_hashes_verified、assembly.review_complete 和 freeze mode=passed，检查父生产四文件等于其 record，再检查 conv2d.c 同冻结 T 源的 SHA 8cf5dc…12bf7。实际 new 仅成功一次，exit0，工具 chunk4f11bb；输出原文见 commands-new.stdout.txt，stderr 为空，结构化来源见 commands-new-result.json。

在 new 前有两次准备检查错误，均 exit1 且没有创建 run/record。首次访问 T schema 不存在的 performance_codegen_eligible；第二次把生产四文件字典与包含诊断 harness 的冻结清单作全字典比较。完整实际 traceback 与上下文保留在 commands-preflight-first-failure.txt、commands-preflight-second-failure.txt。最终分别核对生产四文件身份和冻结 kernel 身份；未改任何历史验证数据。这些是来源检查错误，不是算子失败。

通过 apply_patch 写入本目录 prepare-source.py 后，仅执行一次文本生成器：

```sh
python3 .runs/conv/C54-row7x3shared4/prepare-source.py
```

实际调用由本地 Python subprocess.run(argv, text=True, capture_output=True) 包裹，写入 commands-prepare.stdout.txt、commands-prepare.stderr.txt、commands-prepare-result.json。生成器自身在共享锁内验证 planned 状态、生产/冻结源身份、原两个列 body 一致性，写候选和 candidate.patch，然后调用标准 checkpoint。实际 exit0，chunkcead76；stderr 为空。没有再次运行这个一次性生成器。

最终只读审查 `candidate.patch`、source-audit.json、prepared record、源行范围，以及读取当前 best 和 S/Y campaign：best conv=C26-r1（正式 C6），S/Y confirmation_passed=false。文档通过 apply_patch 写入；未运行编译、算子测试、SSH、scheduler、record 测量、ZIP、promote 或 publication。
