# C55：shared 主循环展开三列

状态为 source prepared，未编译、未运行、未诊断、未测性能；标准 record 为 prepared / verified=false。当前正式最佳仍为 C6（records/best.json 的 conv=C26-r1），S/C51 与 Y/C52 的失败确认保留，不重测失败确认或修改历史样本。

生产 source parent 固定原 C52-row7x3shared2。四个生产文件先与其 record 分别核对，conv2d.c 再与实际 T1582134 冻结源核对；父 kernel SHA256 为 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。诊断清单包含 harness，不能与生产四文件清单作全字典等同。T 的37128及机器码只证明 C52，不能继承为 C55 PASS。

根代理提供的本轮背景是 C54/AA 已有实际44328数值通过，而 Aquinas 的进行中汇编审查发现 scalable spill 与 frame816+30VL；父 T/C52 为720B frame、无 Z spill。这里按当时审查进度记录动机，不把尚在审查的 AA 当 C55 证据。C55 从原 C52 出发采用适度的三列展开，观察循环/地址成本和实际调度之间的取舍；不承诺消除 spill、降低栈或提速。

唯一改动：shared 主循环由 `kw - ik >= 2; ik += 2` 变为 `kw - ik >= 3; ik += 3`，三个作用域按 column=ik、ik+1、ik+2 顺序完整执行原每列21个独立 mul/add。原 u1 remainder 逐字保留，处理0..2列；没有新增 paired2 余项层、partial sum、重关联、FMA intrinsic、asm、prefetch、分配或输入游标。

7rows×3VL/21acc 和13个语义阶段保持；其它12阶段、输出 store、横向尾部、global stride、kh<7防御、全部分派/non-SVE/非法尺寸 fallback，以及 README.md、bench_conv.c、run.sh 原字节保持。改变父源行1488–1572，对应候选行1488–1613；完整 patch 与来源审计在同目录。

候选 conv2d.c SHA256 为 `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`。标准 new 和 checkpoint 各成功一次，共享 workflow lock；experiment.json 的创建时 source_hashes 保留父源快照，prepared record/source-audit 保存实际新源。生成器仅做文本处理与登记，拒绝重复覆盖已 prepared 的源。

本任务到根代理独立源码审查为止，未 SSH、创建诊断/性能 job、ZIP、晋级或发布。后续必须基于 C55 自己的数值与实际机器码决定是否继续。
