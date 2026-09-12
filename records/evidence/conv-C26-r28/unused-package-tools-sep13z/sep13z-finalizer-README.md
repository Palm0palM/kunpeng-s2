# Z raw C7 最终器，仅准备

只新增 `sep13z-finalize.py` 与本说明；参照从未执行的 U finalizer 文本，未导入/执行 U、Z、前置工具或最终器，未改源码/records/outputs/ZIP，未 SSH、运行算子、提交、Git或public。需root全文与独立审查后明确唯一apply；额度达到40%保存工作STOP，不用重置卡。

固定当前 C6 → C7：source=C52-row7x3shared2、measure=C52-r1、package=C52-package；W1582256/Y1582410/T1582134。包job只从未来真实record/manifest/scheduler一致取得，不预填ID。Z.submit的preflight上下文 w/w_records/w_gates、y/y_records/y_gates、source/settings原样复用；不会调用其main或live_gate。

```text
python3 .runs/conv/sep13z-finalize.py
python3 .runs/conv/sep13z-finalize.py --apply
```

以上均是未来接口，本次未执行。默认仅只读preflight并打印明确摘要；缺失真实Y成功或原ZIP证据即报错，不造PASS、不创建包或补测。apply同样先完整只读检查，再共享lock内重读并要求全部上下文、原ZIP字节、当前C6输出和lineage完全未变化；已有C7或当前最佳已变化拒绝重复apply。

前置Z.preflight要求W原48和Y原36分别完整通过自身两端C6，所有case含首组退化≤1%，总收益严格大于max(1%,全部相关spread)，原样本不混合不筛选。Y必须原唯一1582410 confirmation_passed=true；Sfalse和C51-r2参考限制保持。自身T1582134 frozen37128与源8cf5dc...12bf7绑定，不重复诊断。

原ZIP验证要求C52-package passed/verified、三套12 PASS、四原固定尺寸各3样本且max_error=0、所有checks、真实scheduler/job/system/wrapper全0、fetch完成、原产物指纹/来源清单/机器和GCC10.3.1/generic38线程匹配。重新按原parser核对完整case数组/BEGIN-END；包job独立于W/Y/T/S/X。提交外层exit0和argv、package-gates中的W/Y四门槛及T/来源身份也须一致。

ZIP内容只在内存读取：manifest与实际conv.zip SHA一致，原wrapper恰好一个PACKAGE_SHA256_VERIFIED匹配标记，精确四个普通文件成员，每个成员与package source、确认版source字节相同，run.sh保留执行位。该检查不重新压缩或执行包。正式apply只复制这份已验证conv.zip原字节到outputs/conv-best.zip，并再核相同SHA。

apply只走标准e.promote：先C26-r29刷新同源未变C6测量基线，再C52-r1作为确认后的候选。标准流程复制测得source到raw conv/并只更新records/best.json的conv键；其他题键保留并核对。只为这两个测量记录增加标准promoted_at，C52-r1增加C7决策说明，不改原数组或比较。C52-package不promote，结束再次确认其完整record未变化；W/S/C51/C40历史不写。

随后只更新raw outputs/conv-best.json、原字节conv-best.zip及.sha256、records/conv-lineage.json的C7条目与current字段。C7主性能来自Y确认版，另存W初筛、T诊断及独立ZIP12项证明；不是混合样本或官方评分。lineage保留已有C0..C6条目，策略明确shared两列按序展开、奇数单列余数和其余12阶段u1。

不发Git、不改public、不生成另一份ZIP、不执行比赛提交；失败保存已有状态交root，不自动重试apply。准备完成STOP。
