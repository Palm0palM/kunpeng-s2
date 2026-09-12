# r8 控制脚本独立静态审查

2026-09-12。只读核对 `job_control.py`、`cohort_driver.py`、`plan.json`、`README.md`、`remote_job.sh` 的 r7→r8 适配；辅助核对被调用的公共函数以及 r7/r8 资源配置是否一致。未执行控制器、编译、测试、SSH、哈希或登记；没有审查仍在编写的 preflight-wide C 测试。

**未发现当前适配中的实质问题。**

- **版本与父关系**：plan 中 A 为 `T8-control12-repeat-r8`，版本仍是 `T8-control12`，`parent=null`、`repeat_existing=true`；B 为 `T11-sve8x16`，parent 为 `T8-control12`。prepare 检查候选 parent 等于当前已晋级 best 且父记录已验证。T8 源码要求与当前主 TRSM 相同；重复基线不会在 prepare 时覆盖已有最新版本记录。`repeat_existing` 保留到 cohort-config，后续仍须用既定 `record --repeat-existing` 流程保存 prior-record；此控制器本身不登记。
- **冻结载荷**：job_control.py 的 payload 包含两成员五份源文件、cohort-config、driver、remote_job，以及 `preflight`、`preflight-wide`、`reference` 三个目录。先复制成 payload，再生成 tar 并置 prepared；远程 driver 从这个 ROOT 调用 `preflight-wide/run.sh` 和 T11 的冻结 source，不读取本地后续编辑。
- **宽核 gate 的位置**：cohort_driver.py 208–217 行完成 KML 探针和两成员通用预检；219–227 行运行宽核预检，要求退出零且 completion.txt 含 `TRSM_WIDE_PREFLIGHT_COMPLETE=1`。缺文件、失败或缺标记均在任何 warmup 之前抛错。之后 243–244 行才进行 warmup，246–251 行才创建正式 benchmark 日志，252–265 行才执行正式轮次。这里确认 gate 接线与顺序，未判断 C 测试覆盖是否充分。
- **预先固定协议**：prepare 固定 warmup_order=A/B、每成员一套原 run.sh、`TEST_RUNS=3`，随后 formal order 为 AB/BA/AB。driver 181–193 行检查成员、精确轮序和协议字段，禁止更换预热次数或慢样本排除策略。每个 warmup 的退出码、三组官方 PASS/精度、资源和 KML/OpenMP 链接先验收，两个成员全部完成后才开始正式测量。
- **留痕与收集**：warmup.log、warmup-linkage.log、warmup/summary.json 与正式 benchmark/linkage 日志分开。collect 要求成功调度状态及逐成员完成的 warmup 协议关联；全部远程文本诊断（含宽核结果、completion 和 `.s`）仍经独立 diagnostics 包保留。它不会将预热加入正式三轮记录，也不自行晋级。
- **资源与工具路径**：r7/r8 的 remote_job.sh 和资源配置逐字节一致。配置仍为 q_kunpeng、38 CPU、24576 MiB、单 NUMA pack、1800 秒；driver 验证 Linux/aarch64、实际 38 CPU 单 NUMA 和已确认 job ID，FIXED flags/线程/绑定未改。remote_job 在编译器解包/编译前先 source 原 target-environment guard。
- **无哈希执行路径**：控制器调用的公共 `load_config`、JSON/时间辅助、`effective_settings`、`submit_command`、`remote` 和 `scheduler_ok` 不计算摘要。它没有调用公共 submit/fetch/new/record 等内置哈希流程；已有 `hashlib` 模块导入本身不执行摘要计算。源码比较使用字节比较，载荷复制与诊断打包没有新增摘要步骤。

本次只能确认控制器适配。`preflight-wide` 目录仍在编写，必须待作者完成 runner、guard、测试及完成标记约定后再冻结 payload；copytree 本身不证明目录内容齐备或覆盖正确。静态审查不等同目标编译、预检或性能验证通过。
