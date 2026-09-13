# AC 发布附件来源

整理时间：2026-09-12 19:05:52 UTC。候选 C55-row7x3shared3，原诊断作业1582860。新增附件目录仅补充已冻结快照外的执行输出、提交准备和工具审查原件；冻结树 `.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac` 未回写。

共10份原件，62761字节。全部使用 `cp -p` 复制，十次 `cmp -s` 均返回0；原件与副本SHA256逐项一致。空stderr作为原件保留。以下源路径相对仓库根目录，附件路径相对此目录。

| 附件 | 原件路径 | 字节 | 原件与副本共同SHA256 |
|---|---|---:|---|
| freeze-execution/sep13ac-root-freeze.stdout.txt | `.runs/conv/sep13ac-root-freeze.stdout.txt` | 106 | `0af6fdc93f02078fcd902aec0aebd5ff0a0b0b356a0a635aa7027d0911e3b82b` |
| freeze-execution/sep13ac-root-freeze.stderr.txt | `.runs/conv/sep13ac-root-freeze.stderr.txt` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| freeze-execution/sep13ac-root-freeze.exit.txt | `.runs/conv/sep13ac-root-freeze.exit.txt` | 2 | `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa` |
| preparation/ROOT_REVIEW.md | `.runs/conv/sep13ac-checks/ROOT_REVIEW.md` | 1172 | `b3185270f378bd0c4d156232736ccc491d29237fb9cdb916272aed3894011d04` |
| preparation/INDEPENDENT_TOOLS_REVIEW.md | `.runs/conv/sep13ac-checks/INDEPENDENT_TOOLS_REVIEW.md` | 6510 | `f90a6fa4c392d01d6d781b6207f0357bb8774098511f581e2118c9916dd1fcb7` |
| preparation/SUBMISSION_INTERFACE.md | `.runs/conv/sep13ac-checks/SUBMISSION_INTERFACE.md` | 4528 | `7e9f096e9dbde267e98a8351cd499b91d4deb3a3bf06c7afc014edc44435c0db` |
| preparation/PREPARED_FILES.json | `.runs/conv/sep13ac-checks/PREPARED_FILES.json` | 2813 | `bbce1691271ddf49eb941ce2cb01e40e8ebc07c5f1abfab0d3f0b86ebc40c65f` |
| preparation/PREPARATION_COMMANDS.md | `.runs/conv/sep13ac-checks/PREPARATION_COMMANDS.md` | 1795 | `bcd31569e1d003523a236aebb343b4d04dd5da4306adb6a799d01b9521fa3ab4` |
| preparation/STATIC_REVIEW.md | `.runs/conv/sep13ac-checks/STATIC_REVIEW.md` | 2161 | `40221f83939b854c5c0344139b1e734e1e12d1cbe09f20e2ad526583f598ceac` |
| preparation/AA-to-AC.patch | `.runs/conv/sep13ac-checks/AA-to-AC.patch` | 43674 | `1c47863902d04ccdc0ccf3b4f0e8cf150e2444c59dc7c8400ea74618d275940d` |

root-freeze.stdout原样输出现有冻结目标，stderr原件为0字节，exit原件为 `0\n`。未把本次复制描述为重新执行freeze。

实际passed身份与数值结果仍以冻结树的freeze-source.json、validation.json、job.json及raw为准。helper/dispatch实际审查、来源清单、首次prepared、三个diagnostic工具及diagnostic-INTERFACE.md已在冻结树中；本次无需重复复制。完整引用清单和逐项来源/副本哈希见ORIGINS.json。

准备文档中的prepared、当时运行状态和相对路径保持原字节，属于历史准备记录；不修改成事后PASS，不用其替代本版真实验收。PREPARED_FILES.json仍是原准备目录的文件清单，其相对引用不被改写成附件目录引用。ORIGINS.md/ORIGINS.json为本次新写的来源说明，不计入10份复制原件。

只创建本附件目录；没有执行AC工具、重新accept/freeze、导出、网络、源码/record/docs/包/best/TRSM改动，也未干预AD1582956。当前主额度16%，40%停止、禁重置卡约束保持。附件整理完成，STOP。
