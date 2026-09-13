# AB 根静态审查

Root 已阅读 AB 三工具全部正文（被截断的 submit 中段另行补读）、README、作者静态说明，并已阅读成熟 W 对应流程。作者明确 final/STOP，当前不执行工具、不创建新控制或参考版本、不建立 AB campaign。

固定 C26-r30 / C54-row7x3shared4 / C52-r2 / C26-r31；四成员各三完整套件，全部48测量保留。C52-r2 只复用原 C52/T 自己的诊断，reference_only、promotion_allowed=false 和 Yfalse 历史明确，无法进入确认队列。C54 必须有自己的 AA1582656、44328检查及真实汇编的完成验证与冻结。

AA gate 使用最终 aa-shared4-paths-v1、多真实 ranges、余数0..3有序路径和实际派生范围数，原固定14不沿用。所有返回数值/家族/入口/mask、十九阶段、来源、环境、退出与冻结身份仍须满足；C52 参考使用原 W 的 T 门禁。当前 AA 尚未接受与冻结，不能开始性能提交。

提交先只读核对历史Y/S失败和C6，再有界查询固定 Y/X/T/AA 与显式 P/AB 预约，未知或非终态阻止。在共享锁内复核后才保存排他 campaign、建立三新版本并 checkpoint；任何后续中断保留原预约，不能重投。控制源码和官方 runner/benchmark/settings 保持；creation metadata 源快照不重写。

record 依照真实原组ID、完整源/环境/退出和三套日志登记；只在内存中适配 metadata 源视图，失败原件不覆盖。compare 仅使用该组48样本，分别要求 C54 对两端 C6 超过原波动门槛且单case退化不超过1%；辅助父源比较单独保存，不替代两端门槛。只有初筛资格标志，不自动确认/晋级/打包/发布。当前静态未见阻碍，仍待独立AB审查和实际AA完成后才由root唯一GO。
