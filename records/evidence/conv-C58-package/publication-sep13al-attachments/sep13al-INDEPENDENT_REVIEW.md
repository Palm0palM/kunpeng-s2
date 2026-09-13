# AL 原 ZIP 入口独立静态审查

结论：纠正一次查询失败留痕缺口后，当前最终文本未见阻碍。只读审查 `.runs/conv/sep13al-submit-package.py`、已审 `sep12-submit-package.py` 运输流程，以及必要的 `experiment.new/comparison`、`cluster.submit/parse_scheduler_status` 和 AK 记录字段。没有 import、执行、AST/pycompile、SSH、作业或本机算子；未修改任何工具/源码/记录。

最终 AL：7,683 bytes，SHA-256 `8b0221d8d068dd044fca1bad9af6c5e502b0d1505cdff6004e447ae574673fbb`。审查时 AK campaign 实际不存在，`C58-package` 也不存在；本结论不能当 AK 确认通过或包验证通过，仍须未来真实完整 AK 数据及 root 明确 `--go`。

入口固定 AI 原1583408、AI顺序 C26-r36/C58-row7boundaryu2/C26-r37，AK顺序 C26-r38/C58-r1/C26-r39；两个campaign均performance_complete，AK campaign与C58-r1 record均confirmation_passed=true，AI候选qualified=true且两作业不同。两个36样本轮次各自检查记录passed/verified/repeats3/checks、总样本量、同组job/settings/machine、两端当前C6全source；两端保存eligible并重新调用原experiment.comparison，保留收益严格超过max(1%,所有spread)、单例退化不超过1%的规则，不混算AI/AK样本。

C58及C58-r1全source相同，固定实现 `c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751`；C6当前best label/记录/source及包effective settings均需一致。该轻量入口承接既有AI/AK标准记录器的完整证据检查，没有递归重做旧诊断schema或原件全面哈希审核；实际AK不存在时读取立即失败，不能用默认值填通过。

必须先成功解析对应真实AK job的现场SUCCEEDED/job0/system0，解析器本身核对返回jobId。AJ/P已有reservation阻止；prepared目录本身不阻止。包run与record第一次检查后在共享workflow lock内再核对，以标准new创建唯一C58-package并保存creation原字节，metadata明确reference_only=true、promotion_allowed=false、package_validation_only=true。后续原运输器对conv.zip/cluster.json已有文件拒绝覆盖，cluster排他预约并先记录submit_unknown；未知结果不重投，不自动晋级。

运输器只在本机制作一次确定成员/权限的ZIP，上传的ZIP与本地待交付ZIP是同一字节流；节点先核ZIP SHA、成员集合及每个文件SHA后解压，再运行原measurement wrapper三套官方四例（12项）。本机没有编译或测试；正式包是否通过必须由后续原job结果判定，入口只输出validation_pending=true。包job需独立于AI/AH/AK。

原草稿的live AK query仅在成功门槛后保存scheduler原文，失败/不可解析时原返回会丢失。本审查已反馈，root只修改该段：现在每次query在need之前写唯一UTC gate文件，保存command/query_exit/raw_status/parsed scheduler；Timeout/OSError/ClusterError保留异常类型及已有stdout/stderr后重抛。已只读复核该纠正，未运行工具。没有其余未解决发现。

FINAL/STOP；主额度末次实读30%，40%停止与禁用重置卡规则保持。
