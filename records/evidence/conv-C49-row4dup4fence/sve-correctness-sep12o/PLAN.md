# C49 O 单包计划

状态 prepared，仅候选 C49-row4dup4fence，源父 C45-row4dup4。无计算授权，不创建 job、不运行包装或解析验收。

依次计划：分配与GCC检查 → 五文件源清单 → 未插桩生产 guard 六配置 → 单独入口 smoke 六配置 → 未插桩完整汇编。固定121560专项、0runner，19stage与三GCC命令。矩阵、缺口和严格数值检查见 README；没有 kh5 动态覆盖，不借C45的通过记录。

核心问题是三道 +w packed 输出依赖及16acc输入能否让 GCC10.3.1 缩短跨q DUP/input生存期，并改变 C45 的185指令/6load+6store spill安排。空asm不承诺减少spill；memory约束也可能减少有利加载重叠。必须实际接受、正确性通过并完成七阶段/四二一余数/完整栈/dispatch和C45比较，才能让根代理决定是否做性能。准备阶段无结果、无晋级。
