# AH：C58 边界 unroll2 自身数值诊断（仅准备）

唯一候选 C58-row7boundaryu2，source parent 为原 C52-row7x3shared2/T1582134；生产 conv2d.c 为108874字节，SHA `c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751`。root 已独立读12个 pragma hunks，并删除12行完整还原父字节、核对其他三文件。收到该审结论后才首次复制五文件及生成清单。本轮仅准备运输 driver、源码副本/清单/prepared、本说明和完整相对 AE 差异；没有导入或运行 driver、SSH、new/checkpoint、预约、数值或汇编执行。

原 AE 两个 checker 完全不改：check_conv_guard.c SHA `ccbba2637255b5d2733dfbfdddd88afd0d09815d5759ca86c9e8c498475990d5`，check_sve_dispatch.c SHA `fa47796ed01ca2a7d925176b25a6b18d6d124385bf21c1e452a3c2f9afc0f81d`，另与 AE 冻结 source/raw 逐字核对。remote_job.sh 只把 C56 身份改 C58、源 SHA 改本版；candidate.env 只改身份。原19阶段、编译命令、FMA0路线、guard位比较、容差和计数不变；不把额外位比较/FMA0解释为官方题目的全面禁令。

完整44328矩阵不变：VL16/32/64字节×线程1/4共六配置，各 full5744/dispatch1212/direct432，总34464/7272/2592，runner0；rowseven entries1236/1080，worker masks1/15。full家族 core3888/narrow144/small720/larger32/quad_boundary960，dispatch core972/quad_boundary240。quad_boundary 是原 checker 网格名，不能解释为本候选四列展开。原网格包含 kw1/2/3 与 kw4/5/6/7/8边界及长宽15/81；十二条 pragma 的真实偶数展开/奇数余项和寄存器影响仍未知。

资源保持38CPU、24576MiB、单 packed NUMA、1800秒、GCC10.3.1/generic，原 `-fno-fast-math -ffp-contract=off` 与 OpenMP绑定不变。wrapper先核对Linux/aarch64、实际affinity38和同一NUMA，再运行原stage序列；算子只在调度分配节点执行。生产 README/bench_conv/run.sh 与父四源/原record一致，driver另外核对新record的当前四文件；标准parent缺省兼容不改record或creation。

source-hashes.json、source-manifest.json 是首次五文件SHA/字节清单，prepared.json 关联本版源与原父T，compiled/executed/verified/complete仍false、actual_job_id=null。driver核对原五文件、当前四源、父C52/T身份、六配置/44328/19stage/资源预期；任何差异不能静默刷新清单。父T37128仅证明父字节，不提供本版PASS。

串行范围只有原 `.runs/conv/sep13ag-fma/C57-row7shared2fma/job.json` 的 AG1583276、sep13af-campaign.json 的 AF1583230，以及明确的 P/AH job.json。缺失固定证据、固定ID变化、未知预约身份/不明ID、查询失败、非终态或缺整数job/system退出码阻止。实际 FAILED 也能清除串行占用，不能把前一候选数值失败当资源仍占用；root另行要求原结果完整登记后才GO。不扫描队友，不查询旧AD/AC等历史链。

仅显式 root --go 可提交一次，先排他创建 AH job.json 再上传/提交；任何中断或不明返回都保留预留，恢复原ID，禁止重投。status只读原ID并保留查询失败，fetch要求真实终态与两个退出字段，含失败作业；返回原件只能首次落盘或确认原字节相同，不能覆盖不同raw。无自动轮询、接受、冻结、性能、确认、ZIP、晋级或发布。

**未来验收边界**：自己的原job/源清单/raw身份、完整六配置与44328各类计数、19有序stage、实际argv/资源、scheduler/job/system/wrapper全0仍必须核对；全源实际FMA0仍必需。该仅pragma改变采用简洁的实际边界展开/余项/栈审查，不预先要求13stage×binary-block的庞大schema。源码仍有13语义阶段、shared2/u1余0..1，边界源循环单列加unroll2提示；实际展开、PC/区域数、spill或速度不能预填。没有复制 AE accept_returned.py、freeze_returned.py，也没有 C56 fence 合同或 AE assembly_review_schema。数值/运输成功均不自动等于接受或性能通过。

未来仅供 root 审后授权使用，本次未执行：

```text
python3 .runs/conv/sep13ah-checks/driver.py C58-row7boundaryu2 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13ah-checks/driver.py C58-row7boundaryu2 config/conv-sep12.local.json status
python3 .runs/conv/sep13ah-checks/driver.py C58-row7boundaryu2 config/conv-sep12.local.json fetch
```

准备来源：driver纯文本草稿chunk ed3260/0；root源审只读chunk dc4759/0；首次五文件复制/清单chunk4115eb/0。首次只读查找误用 sep13ag-checks 路径，chunk6e578b/1原输出 `rg: .runs/conv/sep13ag-checks: IO error for operation on .runs/conv/sep13ag-checks: No such file or directory (os error 2)`；root给出实际 sep13ag-fma 路径后仅修正门禁文本，未查询/重试作业。driver完整相对AE diff只读chunk5d1ec6/1是预期差异，不是执行失败。

AE-to-AH.patch 完整列出 driver、README、五文件、三个metadata的对应文本差异；两个checker无diff。原文件、冻结证据、candidate source/record/best和其他队友目录不改。主额度达到40%停止、不用重置卡；准备完成FINAL/STOP供root审查。
