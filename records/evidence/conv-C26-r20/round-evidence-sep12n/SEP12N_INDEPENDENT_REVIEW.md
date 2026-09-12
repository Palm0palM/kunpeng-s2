# N 测量流程独立审查

根代理已只读完整 submit-performance、record-group、compare 三文件，以及最终补入的 O/C46/G 归档结构适配。此审查没有导入或执行工具、建立新 control/reference/campaign、SSH、编译或运行题目。

固定八成员顺序为 C26-r20 / C45 / C49 / C46 / C40-r3 / C47 / C48 / C26-r21，各三套原 benchmark，合计 96 个 case 样本。前后均是未改动 C6。候选必须引用各自已冻结的实际诊断，实际编译器、退出码、矩阵计数、源文件、汇编阶段及具体 asm 证据均与保存结构对接。

C40-r3 明确只作同源参考：reference_only=true、promotion_allowed=false、不进入 confirmation_pending。原 G/J/K 分别未通过/通过/未通过的记录不会被覆盖。C47/C48 对 C40 的形状比较、C49 对 C45 的整个编译调度比较单独保存，不宣称测出纯 spill 成本。

O 的数值通过与实际代码生成资格分别检查；C49 若无新机器安排，固定 N 计划会停下由根代理重新判断，不静默删掉候选。空 asm 允许无法独立定位，不要求硬件指令或 PC。C46 核对五块完整活跃累加器和 scratch 不覆盖输入；旧 G 记录使用其真实字段，不假填新格式。

提交需显式 --go，先有界检查已知实际 H/I/L/M/O/J/K/N 任务与 reservation。保存 N campaign 在写成员之前，保留未知提交身份；没有自动重试。登记要求所有原 job/system/wrapper 退出码和正式 PASS；再用同机同资源、逐用例中位数与所有慢样本比较两端 C6。初筛通过只产生候选确认清单，不自动晋级或生成 ZIP。

没有发现静态执行阻碍。O 实际诊断及其完整冻结仍是未到齐的前置条件；本审查本身不是当前 N GO。当前最佳仍为 C6。
