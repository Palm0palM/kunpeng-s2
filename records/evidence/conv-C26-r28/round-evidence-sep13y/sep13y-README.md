# CONV Y：C52 一次独立确认，仅准备

本次只准备 `sep13y-submit-performance.py`、`sep13y-record-group.py`、`sep13y-compare.py` 和本说明。准备前只读确认 C26-r28、C52-r1、C26-r29 的 run 和 record 均不存在；没有自行更换 ID。没有导入或执行三工具、SSH、创建版本、new/checkpoint、campaign、预约、job、record/compare、编译或测试。未来只有 root 全文/diff 审查后才能明确一次 GO，并由 root 唯一提交。

固定顺序 **C26-r28 / C52-r1 / C26-r29**。前后都是未变 C6，每成员三套原始完整官方 benchmark，各12样本，共36样本；第一 case 同样遵守退化≤1%，不能删慢样本、取最好套件、合并 W 与 Y 或调整计时/校验逻辑。GCC10.3.1、generic、38 CPU/线程、24576 MiB、单 packed NUMA、1800秒，OMP38/FALSE/close/cores 和完整 W settings/benchmark/runner 保持相同。总耗时是四 case 中位数之和，不是官方分数。

C52-r1 的 `source_parent=C52-row7x3shared2`，`diagnostic_source_version=C52-row7x3shared2` 分别表示原字节来源和实际诊断身份，独立存储。所有源文件原样复制原 C52；conv2d.c 固定 SHA `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`，其余 README/benchmark/runner 与 C6 相符。Y 不创建新的诊断结果，也不借用 Q/C51 证明 C52。

诊断入口直接复用已审并实际成功运行的 W C52 检查，要求自身 `.runs/conv/C52-row7x3shared2/sve-correctness-sep13t`：真实 T1582134、passed/complete、37128、19有序stage与所有退出0、六VL/线程配置、实际编译与源清单、allocation、13语义阶段/14实际区域、shared paired2列与odd1列独立证据和原样freeze。整个诊断检查只读；不会 accept/freeze 或产生新测试。

进入确认必须先核对原 **W1582256** 为 performance_complete，固定四成员完整48 PASS，原机器/源码/设置/上传manifest/调度器job与system/四wrapper全部有效，campaign 数组与各 record 一致。C52 初筛 qualified_for_confirmation=true，前 C26-r26 与后 C26-r27 两端 saved 与标准 `experiment.comparison` 重算都 eligible=true；原版不能已有 failed confirmation。W 原48样本仅用于资格证明，不进入 Y 性能数组。

Y 只读保留 S1582067 confirmation_passed=false，以及 W 的 C51-r2 reference_only=true、promotion_allowed=false、qualified_for_confirmation=false。C51-r2 不进入本组，Y 不是 C51/S 的重试。旧 C40 的 G/J/K/N/R 结论也通过已审定义只读核对；不修改 W/S/C51/C40 历史。

串行门禁只检查固定 W1582256、T1582134、S1582067，以及实际存在的以下预留：

- P：`.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json`。
- X：`.runs/conv/sep13x-checks/C53-row7cursors/job.json`。
- Y：`.runs/conv/sep13y-campaign.json` 与本组三个 member 的 `cluster.json`。

不扫描队友或复用早期广泛扫描。固定证据缺失/身份变化、现有预留缺少可对账 ID、查询失败、非terminal或缺少整数 job/system退出码均阻止提交。P/X 无 job.json 只表示未预约；存在但无 ID 不放行。ID 去重后每次查询最多45秒。root 是唯一提交协调者，门禁不宣称提供跨代理调度锁。

future GO 先检查全部新ID与campaign未占用、来源/current/prepared/diagnostic一致、当前最佳仍为相同C6；共享锁内复核后先预约campaign，再 new/checkpoint 三成员，最后只调用一次 group submit。任意已有预留、上传/提交不明都保留原件并恢复唯一原ID，不删除或重复提交。`--go` 只是工具参数，不能替代 root 的授权。

record 的通用机器、check集合、case维度与生命周期沿用已审 W/S，Y 只改变成员/来源/初筛映射。保留 experiment.json 的 creation source_hashes 快照，要求 prepared record、当前源、实际提交 manifest 一致，才在内存 metadata 视图适配；不把创建时旧hash强行当最终hash，不修改历史样本。status/fetch日志排他时间戳创建，已通过记录核对后跳过，失败记录不可覆盖。schema/解析失败保留第一次stdout/stderr/退出和原件，停止报root，不重测或放宽规则。

compare 必须等本组三成员全部36 PASS、同组实际环境及退出有效。直接复用 W/R 标准 comparison 定义，对两端C6各自要求 **总中位数收益严格大于 max(1%, 两版本所有case spread)**，且 **任意case退化≤1%**。只有两端都 eligible 才保存 confirmation_passed=true；任一false就保存false并保留每个慢样本，不打包、不晋级、不重复失败确认。工具对通过结果同样不自动打包或晋级，交 root 决定。

只写 Y 三 record 与 Y campaign，完整保存数组、中位数、spread、两端比较/失败原因与 confirmation_passed。三个版本 qualified_for_confirmation=false，confirmation_pending=[]，确认结束不自动触发下一轮。automatic_confirmation/automatic_promotion/automatic_packaging/failed_confirmation_retry_allowed 全false；不改 W 初筛，不混合36与48，不发布或生成ZIP。

以下仅为 root 审后未来接口，本次未执行：

```text
python3 .runs/conv/sep13y-submit-performance.py --go
python3 .runs/conv/sep13y-record-group.py
python3 .runs/conv/sep13y-compare.py
```

每次执行先独立保存真实 stdout/stderr 与退出码。只恢复保存的原job并等真实terminal，再record/compare。准备交付后 STOP，供 root 审查。
