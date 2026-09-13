# AM 独立静态审查

最终结论：下述初审创建元数据阻断已由root修复，本审查者已读取最终代码确认。已有creation原件仅核对 problem/version/created_at/source_hashes 四个固定字段（与已读实际C59文件一致），用 `pre-am-experiment.json` 的排他 `xb` 保存AM前当前meta完整字节，再修改AM关联，creation原件保留。当前未发现其他实际运行或判断阻断；仍需实际AJ接受完成及root额度门禁后GO。以下保留初审问题及接口结论，问题描述不表示最终代码仍有该缺陷。

2026-09-13，`/root/c59_diag_review` 全文只读审查 `sep13am-performance.py` 和 README，并读标准 `experiment.new/checkpoint/record/comparison` 与 `cluster_group.submit_group` 实际接口。未 import、执行该脚本或改候选/记录，主额度36%，未用reset。

发现一项当前版本的确定阻断：submit循环把已存在的 `creation-experiment.json` 与当前 `experiment.json` 逐字节比较。实际 C59 的 creation 原件仍为标准new输出，当前meta已在准备阶段追加source_parent、父诊断路径、own_diagnostic_pass、compiled/executed等字段，两者不相同。因而现代码会先保存AM campaign并创建两个对照，然后必然报 `Original creation metadata intact`。GO前必须改为保留既有creation原件，并另存AM前当前meta快照，或核对creation的固定身份/created_at而不要求与已扩展meta完全相同。不能覆盖creation原件或失败后重建同一实验。

除上述阻断，实际接口匹配：当前C7最佳指针与测量源检查；C59自身AJ1589289接受44328、冻结源和实际目标/root汇编说明；C58-r2/C59/C58-r3顺序；标准new两个未改C7对照、checkpoint、统一三套settings和一个group；C59 source_parent原C58、比较parent结束C58-r3；原job、settings、machine、源、wrapper0和全部36样本重解析；标准record及两个独立e.comparison，只有两边eligible才等待独立确认，不自动晋级/包。group字段和函数签名与实际工具一致。

失败处理边界：record-compare要求group SUCCEEDED才fetch，因此真正FAILED组会停在状态检查，尚不会自动取回原失败日志或标准record失败。届时root需对原ID另行fetch并保存失败说明，不能重提交或将未登记误写为通过。这不造成错误提速判断，也不需要本次扩展工具协议。网络异常由外层完整命令记录保留，不可因断线重复提交。

已执行只读命令包括全文cat、标准接口rg/sed，以及Python json/path读取C59两份meta并打印相等结果False；没有测试或导入算子。root修复确定阻断后只需复核该差异，不需重新扩展审计。
