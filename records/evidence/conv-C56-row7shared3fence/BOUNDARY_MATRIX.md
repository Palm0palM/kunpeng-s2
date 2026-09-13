# C56 后续检查边界（计划，未执行）

三列算术和原边界代码不变；新的编译器约束要求本版重新验证。父AC1582860仅作为比较原件，不能覆盖新源。

| 边界 | 需要保留的行为与观察 |
|---|---|
| kh1..6 | 防御rowquad+rowtriple路线；本版shared asm应不执行 |
| kh7/8 | 分别一次/两次shared t行；每t重置ik和kernel/输入基址 |
| kw1/2 | 不进入triple，仅原u1；没有进入本版asm的动态证据 |
| kw3/6 | 一/两轮完整triple，余0；第三asm约束下一轮边界 |
| kw4/5/7/8 | 一/两轮triple后直接u1余1/2，21条链连续 |
| kw15/81与大奇偶kernel | 多次main、跨t；最终one-past列不读取，所有地址仍须符合父几何 |
| ow=3L/6L及各±1 | 完整tile和横向尾，下一tile的21累加器/ik/t重置 |
| oh1..15/21/22/28 | rowseven分派与oh余1..6，其他helper和组间重置 |

后续若采用成熟AC矩阵，应保持VL16/32/64×线程1/4，full5744、dispatch1212、direct432，每配置7388、总44328，rowseven入口1236/1080和mask1/15。保留独立scalar逐位参考、readonly input/kernel、分配边guard、canary和输出poison。这里仅列下一检查范围，没有创建/修改检查器或诊断目录，也没有填actual PASS。

实际生产汇编需审全部helper/clone、13语义阶段、triple3和u1余数0..2、所有转场/21输出/dispatch/尾部。每列21个累加结果与后列输入/权重读取的时间位置需要从真实文本及数据流解释；即使没有#APP或可单独识别空asm，也应如实报告，不能发明机器指令或固定PC/ranges。

比较原C55实际main5读5写、全helper30读45写、frame880+5VL；新源要独立统计热循环、三边界、转场、全函数Z/Q/谓词和标量栈，D8..15低64位ABI另列。数值正确与spill变化均不能直接推出性能；下一计算仍需root独立GO。
