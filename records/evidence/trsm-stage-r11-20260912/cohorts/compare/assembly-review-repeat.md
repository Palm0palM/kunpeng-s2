# r11 同源码目标汇编核对

本轮作业1579600实际取回的 `diagnostics/preflight-wide32-results/T13-sve4x32-repeat-r11/trsm-wide4x32.s` 在计算节点由原候选源码生成，独立预检的插桩副本不用于此命令。只做本机文本读取和指令计数，没有重新编译、运行题目或计算哈希。

实际 `update4x32_sve` 的 `.L25` 热循环仍为34条指令：1次ld1rd、3次标量ldr和3次mov广播组成四个L系数，4次X向量ld1d、16次fmla、4次add、1次ptrue与cmp/bne。新核整个函数未发现sp访问或bl/blr内部调用。行号和计数保存在assembly-review-counts.json。

这与r10报告的微核结构一致，仍是零基递增k FMA后一次C−sum；完整加载、回写和等128输出载荷分析见r10的assembly-review-wide4x32.md。本轮没有重做其所有指令语义推导，也没有额外声明两份汇编或benchmark二进制的字节身份相同。实际正确性与本轮性能以独立三套正式日志和登记比较为准。
