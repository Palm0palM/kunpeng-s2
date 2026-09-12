# AG：C57 显式 FMA 的最小官方数值可行性实验

准备完成，未运行。唯一候选 C57-row7shared2fma 来自原 C52/T1582134，仅 shared 主循环42处及余数21处改显式 svmla；其余源码与官方 bench/run.sh/README 未变。生产源码107407字节，SHA256 3cc03ec4d13422238b1e461dd7213876cc50283a7433132ee94b41c4724ec6c5。root 已全文读三段差异，并独立逆变换逐字节恢复父源。

这次只问该变体在固定非融合参考下能否满足原官方绝对误差1e-5。原四例按 A/B/C/D 顺序三套，共12次；原参数末尾test_runs=1。官方bench、参考、随机种子、容差、预热和计时区不改。外层诊断wrapper仅把生产run.sh遇FAIL就退出的行为改为收齐预定12次；每次原stdout/stderr、进程退出与文本PASS/FAIL分别保留，官方main返回0不等于PASS。任意超差都不能晋级，构建/进程/调度异常另列不完整；保留原ID不重投。三套固定种子不代表三个独立随机覆盖集。

资源固定38CPU/24576MiB/一个packed NUMA/1800秒。运行先确认Linux/aarch64、SVE能力、38个允许CPU同NUMA；OMP38/close/cores、GCC10.3.1。保留生产strict/generic及block32/unroll2 flags，只显式候选intrinsic可融合，不全局开fast-math/contraction。三条实际gcc命令及候选/官方参考两份.s返回，用于小范围核对融合确实发生、固定reference没有同时融合。任何额外memcmp/FMA0门槛不适用于此独立研究，原AE接受器保持原合同。

driver复用AE已审排他预约/SSH/tar文本传输/status/fetch流程。首次清单绑定五文件（四提交源和诊断wrapper），不含认证配置。新串行门禁要求AF原campaign已经performance_complete，四明确成员 C26-r34/C56/C55-r1/C26-r35 的原job/group一致；另核对AE1583102及现存P预约，实时查实际terminal与整数job/system退出。不扫描队友。没有AF完整原记录时禁止AG提交；root唯一GO且必须先检查主Codex额度<40%。不用重置卡。

未来入口（均未执行，需独立静态审查及root GO）：

```text
python3 .runs/conv/sep13ag-fma/driver.py C57-row7shared2fma config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13ag-fma/driver.py C57-row7shared2fma config/conv-sep12.local.json status
python3 .runs/conv/sep13ag-fma/driver.py C57-row7shared2fma config/conv-sep12.local.json fetch
```

status/fetch复用原job；每次外层argv/stdout/stderr/exit保存，重复轮询间隔至少45秒。数值失败时wrapper/job可以非零，仍可取回原件；fetch不判PASS。返回后先核对原件/源/12组参数及最大误差、实际退出、实际编译条件和targeted FMA evidence，再记录结论。尚无接受器、PASS、性能比较、冻结、包或晋级。即使12/12通过也只是此配置的数值初筛，不能替代完整边界/多VL诊断和同环境独立测速。

Preexecution revision1: independent review corrected the draft capability mask from bit8 (ATOMICS) to bit22 (SVE), verified against Linux UAPI hwcap.h. Original wrapper/manifests are preserved in preparation-revisions/r0-hwcap-bit8; no draft was run or uploaded. Four candidate source files are unchanged.

Final preexecution driver review also requires a nonempty kp-conv-group-hex AF group before comparing allfour members, preventing missing-group equality. Final driver is268lines; no tool was imported or executed. Author preparation FINAL/STOP, pending independent final review.
