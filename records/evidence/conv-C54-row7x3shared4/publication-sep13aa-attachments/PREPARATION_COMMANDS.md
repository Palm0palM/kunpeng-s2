# AA 轻量准备留痕

本轮只通过shell文件复制、Perl文本替换、apply_patch、rg/sed/cat静态读取、diff、shasum和wc准备文件；没有执行/导入driver、accept_returned、freeze_returned或任何题目程序，也没有建立Python准备器。本文件是操作说明，不是待执行自动脚本。

1. 阅读AGENTS/README/BASELINES/PLAYBOOK和共享git状态；读取T三工具及实际C checker循环、T INTERFACE、C54 source-audit和独立源码审查。
2. 用逐层mkdir新建本AA目录和唯一C54/source；复制T三工具、两个C checker/remote_job.sh/candidate.env；从C54/source复制最终conv2d.c。未复制T job/raw/validation/review。
3. 对AA副本轻量文本替换候选/父身份、最终source SHA、批次与矩阵常量；用apply_patch增加两个C矩阵和有界serial gate，按批准schema改接受/冻结工具。没有运行新工具做生成或检验。
4. 首次shasum/wc读取五传输文件，记录source-hashes.json和source-manifest.json；prepared.json用明确结构化planned值写入。首清单已保存并停止更新。生产字节与授权SHA一致；checker仅新增已批准网格。
5. 完成SUBMISSION_INTERFACE与driver/源/清单/prepared后先向root、Q发明确final/STOP及哈希。root随后独立唯一提交1582656；本任务没有执行该提交，也不修改这些已冻结子集。
6. 完成多真实ranges/remainder_paths接受契约、freezer、完整INTERFACE和STATIC_REVIEW，未读取返回汇编来改变门槛。用文本diff保存T→AA全部三个工具、五传输文件、prepared差异；用轻量哈希/字节数保存准备文件清单，排除他人后续原job/raw/review。

未来执行命令仅位于已冻结SUBMISSION_INTERFACE；任何status/fetch/accept/freeze均需对应另行授权、原job与审查。本轮无SSH、编译、测试、数值、性能、ZIP或晋级。所有候选/记录/历史和队友文件保留。
