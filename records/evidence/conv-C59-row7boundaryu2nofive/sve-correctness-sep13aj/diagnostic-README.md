# AJ：C59 自身诊断模板，prepared only

唯一候选 `C59-row7boundaryu2nofive`，source parent 为 `C58-row7boundaryu2` / 原 AH1583350。C59 只删除父源 input_5 前一行 `#pragma GCC unroll 2`，其余11条提示、shared2/u1、算术、dispatch 与三份生产配套文件原字节保留。最终 conv2d.c 为108841字节，SHA `17e39de400213c6143450ca51436eecb780ee5806b8375fd38f0b6694b2f4be9`。O 已 FINAL/STOP，root 独立源审通过后才首次复制本目录五文件和创建清单；不修改候选源码或记录。

两份 checker 与 AH/原 AE 完全相同；remote_job.sh 仅替换候选身份与源 SHA，candidate.env 仅替换身份。原19阶段、GCC10.3.1/generic、38CPU/24576MiB/单 packed NUMA/1800秒、`-fno-fast-math -ffp-contract=off`、OpenMP绑定保持。完整44328矩阵为 VL16/32/64字节 × 线程1/4，各 full5744/dispatch1212/direct432，总34464/7272/2592，runner0；entries1236/1080、worker masks1/15。checker 的 `quad_boundary` 是既有网格名，不是候选展开因子。

`prepared.json` 的 compiled/executed/verified/complete 为 false，actual_job_id 为 null；source-hashes/source-manifest 为首次五文件身份。driver 只读核对当前生产四文件、标准 `source_parent` 优先/`parent` 后备、原 C58/AH 的真实冻结源与本轮清单，绝不刷新 creation 元数据。AH 的 PASS 不等于 C59 的 PASS。

提交串行范围只有原 AI1583408、AH1583350、AK1583680、AL1589186，以及明确 P/AJ job.json。AK 绑定其原 campaign 的 performance_job；AL 绑定 `.runs/conv/C58-package/cluster.json` 的 job_id。两者已由 root 完成确认/原 ZIP 验证并晋级 C7，本次仅固定实际身份，不改既有记录。提交前检查原 AI campaign 已 complete、三个成员完整36样本和已记录退出校验；不重算或改其选优结论。门禁会实时查询全部上述已预约作业，AK 和 AL 均必须返回匹配 ID 的真实终态且有整数 job/system 退出；AL 运行中会阻止 AJ。串行门禁只判定作业结束，不代替 root 对成功、完整结果或晋级的判断。未知预约、身份变化、查询失败或非终态均阻止，不扫描队友历史。root 是唯一提交者，须避免门禁查询后又发起其他作业。root 在 GO 前、完成后读取真实主额度；达到40%立即停止、不用 reset。脚本不自行访问账户额度，`--go` 不能替代该检查。

driver 仅显式 root `submit --go` 预约一次，先排他写 job.json，再上传和提交。任何失败/失联保留原预约及输出，恢复原 ID，绝不重复提交。status/fetch 复用该 ID；fetch 只在真实终态且 job/system 退出齐全时取回原件，包括真实失败。已存在 raw 只能与返回字节相同，不能覆盖不同证据。gate/status/fetch 均含网络，当前准备期间未执行。

`accept_and_freeze.py` 复用 AH 的简洁数值日志/归档逻辑，必须显式提供未来真实 `--job-id`，并与 AJ 原 job/summary/scheduler 三方一致；当前没有假填 AJ ID。它重新读原19有序 stage、六配置/44328、无 FAIL/ERROR、实际三编译 argv、资源/源关联、wrapper/job/system全0与实际整份 `.s` FMA0。先由独立审查者和 root 完成实际目标说明，再允许一次接受归档；验证失败保留原件，不能放宽数值条件。

未来 `AJ_SUMMARY.json` 沿用 AH 生命周期摘要接口：candidate/job_id、wrapper_exit/issues、19个 `{stage,exit_code}`、actual_compile_argv、compiler_version、allowed_cpus、requested_resources、scheduler_resources，以及 source_files 的 name/sha256/all_manifests_and_transport_bytes_equal。摘要必须从该原作业返回日志产生，不能从 prepared 期望值填 PASS。接受器仍直接重读各原日志，不以摘要计数替代数值核对。

目标汇编审查只需实际 input_5 循环和 spill、shared2/u1 是否有新 spill、全 helper 帧/明显 Z/Q/predicate 栈及 ABI、全源 FMA0，与原 AH 返回汇编比较。无需建立13阶段逐 binary-block 巨型 schema；不预填实际展开、PC、零spill或提速。需要 `TARGETED_ASSEMBLY_REVIEW.md` 与 root 的 `ROOT_RETURNED_REVIEW.md`；两者只能在实际返回后生成。原11条提示可能改变 GCC 全局调度，删一提示不保证消除所有栈流量。

将来仅供 root 审查并授权后使用，本次未执行：

```text
python3 .runs/conv/sep13aj-checks/driver.py C59-row7boundaryu2nofive config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13aj-checks/driver.py C59-row7boundaryu2nofive config/conv-sep12.local.json status
python3 .runs/conv/sep13aj-checks/driver.py C59-row7boundaryu2nofive config/conv-sep12.local.json fetch
python3 .runs/conv/sep13aj-checks/accept_and_freeze.py --job-id <实际原AJ_ID>
```

未来 archive 为 `.runs/conv/C59-row7boundaryu2nofive/sve-correctness-sep13aj`；不存在/不能覆盖 validation 或冻结目录，先写独立临时目录再原子 rename。归档原source/raw、摘要、目标及root说明、工具/README/独立review，`.assembly.txt` 与原 `.s` 字节一致。未测性能，不自动创建性能组、确认、包、晋级或发布。

本次 driver/README 最终身份与串行差异见 `INDEPENDENT_TOOLS_REVIEW.md`。初始 `PREPARED_FILES.json` 和 `AH-to-AJ.patch` 保留模板准备时的原件，不伪装成修改后的清单。接受器复制前另需 root 完成 `ROOT_REVIEW.md`，不能用静态审查冒充实际返回后的 `ROOT_RETURNED_REVIEW.md`。
