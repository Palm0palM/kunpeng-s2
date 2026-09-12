# r16 root 最终集成审核

源码与专用预检已分别静态审查；本次完整核对冻结的 controller、driver、finish 与 plan。

- A/B 唯一前序为 r15 job1579788，保留原版本/父版本/策略/来源和完整历史；C 为 T19 新候选，已有 source 但不得有已登记记录。
- 三成员五文件来源冻结，官方 runner/benchmark/compat 不变，T8 对应当前最佳；冻结末尾再次检查并发变化。
- A/B 旧 general、C 专用 615 whole / 96 noop / 46 micro / 633 arguments，并核对专用 guard 的真实 job ID；B/C 各自 CT64 wide32 完整检查。
- ABC/BCA/CAB，1 套预热与 3 套正式分离，预期 27 formal / 9 warm。所有原始结果、依赖和预检在登记前全部审核。只有 A/B repeat，C new。
- 两份 T8 晋级比较；T18→T19 仅机理比较，无晋级授权。finish 不执行 promote。
- 排他 prepare/submit/finish；先存 job ID，再发 identity marker；不重提未知作业。仅调度计算节点编译、测试、汇编生成，38 CPU 单 NUMA、24576 MiB、1800 秒。

结论：静态准备可执行。解除 PREPARE_REVIEW_PENDING；这不是目标编译或正确性通过。参考为真实 KML25.1/GCC12，尚非指定 KML25.2.0 复验。不计算或验证哈希。
