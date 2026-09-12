# R11：T8 / T13 同版本新 run 复测准备

2026-09-12，仅完成本机轻量文本准备和静态检查。没有执行 `job_control.py` 的 prepare/submit/status/collect/confirm-job，没有运行 `finish_records.py`、登记、晋级、SSH、哈希、题目编译或测试。本目录等待 root 在上一轮收集登记完成后冻结并执行。

从 r10 仅复制六份根级干净输入：`job_control.py`、`cohort_driver.py`、`finish_records.py`、`remote_job.sh`、`cluster.local.json`、`plan.json`。另复制 `reference/`、`preflight/`、`preflight-wide32/` 各四个准备文件；三个目录和 cfg 均与 r10 原样逐字节一致。不复制 payload、压缩包、state、cohort-config、任何日志、诊断或旧审查结果。预检 README 中的 r10 字样标识其复制来源，实际调用路径由本轮 driver 明确指定。

| 角色 | 新 run 目录 | 原实现 version | parent | source_from | repeat_existing |
| --- | --- | --- | --- | --- | --- |
| A | T8-control12-repeat-r11 | T8-control12 | null | T8-control12 | true |
| B | T13-sve4x32-repeat-r11 | T13-sve4x32 | T8-control12 | T13-sve4x32 | true |

plan 的原 version、parent、strategy、source_implementation_id 保持 r10 身份，不建立新实现版本。未来 prepare 要求前次版本记录已 passed/verified，计划身份与原记录相同；A 仍是晋级 best，B 仍未晋级且 parent 为当前有效晋级基线。原 version 源码必须等于其原测量快照，新 run 源码也必须等于 source_from。prepare 对两个成员都不会创建或覆盖实现记录。

每成员先执行通用预检；B 另执行全部 28 直接核和22整算子 wide32 预检。driver 调用：

```text
preflight-wide32/run.sh <remote-root>/T13-sve4x32-repeat-r11/source <remote-root>/preflight-wide32-results/T13-sve4x32-repeat-r11
```

参考探针、官方 runner/benchmark、KML25.1/GCC12、38线程单NUMA、资源上限和预检覆盖均沿用 r10。每成员恰好一套原官方 warm-up，顺序 A/B，保留全部日志但不计入正式比较。随后固定三套正式顺序 **A/B、B/A、A/B**，保留全部三套，不丢弃慢样本。新协议 ID 为 `trsm-r11-one-official-warmup-v1`，由 prepare 在新数据产生前写入冻结配置，driver 再核对固定名单、version、repeat 标记和完整协议。

未来成功收集后，`finish_records.py` 对两个新 run 都调用私有 `records-kml.py record ... --repeat-existing`；由该工具完整保留原版本身份、创建原记录的 prior-record 快照并追加 run 历史。比较命令仍为 `compare T8-control12 T13-sve4x32`。finish 从新的 `preflight-wide32-results/T13-sve4x32-repeat-r11/` 路径核对完成标记和参数观察 summary；预期正式18例 PASS、warm-up 6例 PASS。不会自动晋级。

静态验证已通过：6个 Python 文件 AST、5段内嵌 Python AST、5个 Shell 文件 `bash -n`；JSON 计划身份与原值保持，cfg 和三个参考/预检目录原样保持；本轮目录尚无生成 state、payload 或日志。这些检查未执行任何 controller、parser、编译器或题目程序，不是新的目标节点验证结果。
