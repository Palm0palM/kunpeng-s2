# r9 控制脚本独立静态审查

2026-09-12。只读核对 r9 plan、controller、driver、README 相对 r8 的适配，并快速比较 T12 与 T8 源码。未执行 prepare/submit、编译、测试、SSH 或哈希；未审查正在由另一任务扩展的 records-kml.py。

**在本次控制器审查范围内未发现阻碍冻结/提交的具体问题。**

|成员|run_name|version|parent|repeat_existing|
|---|---|---|---|---|
|A|T8-control12-repeat-r9|T8-control12|null|true|
|B|T11-sve8x16-repeat-r9|T11-sve8x16|T8-control12|true|
|C|T12-forwardbarrier|T12-forwardbarrier|T8-control12|未设，按 false 处理|

- **版本关系保留**：controller 36 行固定上述三个 run 名；plan 保留 T11 的原 version、parent 和源码来源，没有把候选复测改成新版本或无 parent 基线。43–48 行仍检查有 parent 的 B/C 都以当前已晋级 T8 为父。85–88 行对 A/B 跳过覆写现有版本记录，并在 cohort-config 保存 repeat_existing；C 建立独立记录。后续 prior-record 的登记实现不在本次审查范围。
- **预先固定协议**：controller 99–109 行固定 A/B/C 各一套原 run.sh warmup、TEST_RUNS=3，正式顺序通过三次轮转生成 ABC、BCA、CAB。driver 181–193 行检查精确成员顺序、三轮顺序及 warmup 协议。每个成员恰有一轮预热和三轮正式套件，对应 9 个预热、27 个正式逐用例结果，与 README 一致。
- **T11 宽核 gate 路径正确**：driver 220–225 行的 source、结果目录、completion 文件全部改为 `T11-sve8x16-repeat-r9`。它在三成员通用预检后执行；非零退出或完成标记缺失都会中止。243–244 行才运行 warmup，246 行后才打开正式日志，252 行后才计时，因此 gate 不会被放到性能阶段之后。
- **冻结与来源**：controller 89–92 行复制三个新 run 的五份 source，111–115 行冻结 config、driver、remote_job、通用 preflight、preflight-wide 及 reference，再创建 payload tar。新 T11 run 从既有 T11 source 复制，后续远程 gate 使用冻结目录。源 benchmark、runner、兼容头仍按 73–75 行与主目录字节比较。
- **资源和 benchmark 未改变**：r9/r8 的 remote_job.sh 与私有资源配置逐字节一致；沿用 38 CPU、单 NUMA pack、24576 MiB、1800 秒。FIXED 环境、实际分配 guard、KML/GCC 检查、warmup 验收、原 benchmark 调用和独立 linkage 日志都沿用 r8。此次差异没有加入哈希调用或改变计时区。
- **T12 是独立的三处 asm 改动**：相对 `.runs/trsm/T8-svepanel16/source/trsm.c`，源码 diff 只有块内 q=3、7、11 的 a15 FMA 后各新增 `__asm__ __volatile__("" : "+w"(a15) : : "memory");`。原算术表达式、递增 k/q 顺序、历史循环、布局/分配/分派及大路径均未改，也未叠加 T11 宽核。约束的实际目标编译与调度效果仍须由超算结果确认。

这份记录确认静态接线和协议一致性，不表示预检或性能已通过，也不替代候选同版本复测登记扩展的独立审查。实际冻结后仍应保留唯一 job ID、冻结 payload 和所有原始结果，不复用 r8 的样本作为 r9 结果。
