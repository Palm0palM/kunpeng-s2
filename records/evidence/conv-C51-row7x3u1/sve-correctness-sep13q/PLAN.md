# C51 Q 独立数值诊断计划

source parent C40-row6x3u1；C51七输出行×3VL/21acc/十三阶段。生产源在作者最终STOP并经根源码审查后才复制。源/配置/检查器/包装五文件的初始身份见source-hashes.json和source-manifest.json；计划和未执行状态见prepared.json，实际结果尚无。

每配置full4784、dispatch972、direct432，六配置共37128；线程1/4×SVE字节16/32/64。正常分派kh>=7/oh>=7，3VL/6VL±1和全部余1..6；直接kh1..6防御回退。逐位scalar、readonly输入/权重、边缘guard/canary/输出poison。真实运行必须同时满足19阶段/包装/调度器退出和准确PASS；产物返回后独立审查整个helper、13阶段、所有分派和实际栈/FMA。

精确矩阵、接口、源关联和审查清单见../INTERFACE.md。没有官方runner、性能、包或晋级。当前prepared，未提交job；root独立审查后才授compute GO。
