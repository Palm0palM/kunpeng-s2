# AA 发布附件来源

本目录只补充不可变 `../sve-correctness-sep13aa/` 之外的 AA 原件。ORIGINS.json 逐文件记录来源、字节数和复制后逐字节相等核对；共9份原字节副本。没有重写冻结树、源码、record或公共文件，没有执行git、网络、编译、测试、打包或导出。

root-freeze.stdout/stderr/exit 三文件来自root首次freeze外层实际输出：stdout是冻结目标路径，stderr为空，exit为0。原冻结freeze-source.json记录job1582656、mode=passed；其validation.json为本轮实际44328通过证据。该目录内已有原accept外层stdout/stderr/exit、完整raw、实际helper/dispatch/合并review、source/prepared/job/manifest，故这里不重复复制。

ROOT_REVIEW、INDEPENDENT_TOOLS_REVIEW、SUBMISSION_INTERFACE、PREPARED_FILES、PREPARATION_COMMANDS及原diagnostic-plan完整原样保留。它们记录当时的准备/审查阶段：其中“待审”“尚未接受”不是最终状态，不能改写历史原文；本轮最终结论以原冻结validation、assembly-review、freeze-source及root-freeze实际退出为准。SUBMISSION_INTERFACE的通用config示例与root实际配置差异已在原ROOT_REVIEW说明。

这些附件仍是未脱敏本地原件，不能直接复制到GitHub。后续root应通过现有只读导出器创建独立公开副本，记录原件/公开SHA各自含义；本次未执行导出器。原始数字和历史状态不能因脱敏而重写。

AB1582814正在另一智能体负责的原生命周期内；本次没有复制或导出AB的未完成record，也没有借AA诊断推断AB性能。发布路径及待办见 `.runs/conv/sep13aa-ab-PUBLICATION_PLAN.md`。整理完成STOP；40%额度停止，禁用重置卡。
