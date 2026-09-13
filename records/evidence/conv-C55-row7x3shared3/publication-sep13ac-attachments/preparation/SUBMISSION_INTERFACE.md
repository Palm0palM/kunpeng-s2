# AC 提交子集：final，准备不等于 GO

2026-09-13。本文件、driver.py、C55-row7x3shared3/source/ 五文件和首次 source-hashes.json/source-manifest.json/prepared.json 已完成准备并停止编辑。接受器/冻结器及完整汇编接口另行完成审查。没有导入或运行 AC 工具，没有 SSH、预约、编译、数值运行、接受或冻结。

候选仅 `C55-row7x3shared3`；生产 source parent=`C52-row7x3shared2`，父独立冻结 T1582134。作者 final/STOP 由 root 确认，root 独立源审查已保存。实际生产源 SHA256 为 `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`。AA 是工具与网格模板，不是 C55 的源码父版或通过证据。

严格五文件为 conv2d.c、check_conv_guard.c、check_sve_dispatch.c、candidate.env、remote_job.sh。两个 C checker 与最终 AA 原字节相同；其 C54/four-column 注释和 `quad_boundary` 家族名保留为历史来源/网格名称，不表示 C55 做四列工作。wrapper 仅候选名和源哈希变化，生产、参考、插桩范围和 flags 不变。没有传 benchmark/runner、旧 raw 或假 job。首清单的字节数/SHA 由实际副本生成，后续不自动刷新。

唯一预约位置 `.runs/conv/sep13ac-checks/C55-row7x3shared3/job.json`。root 审查完提交子集并另外明确 GO 后，可用下列入口；准备者未执行：

```text
python3 .runs/conv/sep13ac-checks/driver.py C55-row7x3shared3 config/conv-sep12.local.json submit --go
```

配置须为 38 CPU、24576 MiB、1 packed NUMA、1800 秒。串行门禁只看固定原 AA1582656/Y1582410/X1582372/T1582134，现存 P/AC job.json，以及现存 AB campaign 和 C26-r30/C54-row7x3shared4/C52-r2/C26-r31 四个 cluster.json。实际 AB 预约无数字 job ID 则阻塞；已有 ID 则查询真实终态，campaign/member 不同 ID 也阻塞。固定来源缺失/不符、查询失败、非 terminal、job/system 退出字段缺失均阻塞；无 job.json 的 prepared P/AC 不阻塞。不扫描队友，不取消任务；门禁不替代 root 唯一提交协调，AC 不能与 AB 性能并跑。

submit 要求显式 --go 且无 job.json；核对源集合/实际字节/大小、prepared、生产 checkpoint 后，先 open('x') 预约，再上传/提交。失败或不确定仍保留预约，禁止第二次 submit。status/fetch 只恢复原 ID；fetch 要真实 terminal 和两个实际退出码，只取文本/.s，拒绝覆盖异字节 raw。生命周期负责人保存每次外层 stdout/stderr/exit；status 间隔至少45秒，不自动轮询。

六配置为 SVE_BYTES={16,32,64}×线程={1,4}；实际 worker VL/team 必须匹配。

| 数量 | full | dispatch | direct | 合计 |
|---|---:|---:|---:|---:|
| 每配置 | 5744 | 1212 | 432 | 7388 |
| 六配置 | 34464 | 7272 | 2592 | 44328 |

full=core3888+narrow144+small720+larger32+quad_boundary960；dispatch=core972+quad_boundary240。原 AA 网格六宽 3L/6L±1×kh7/8×kw4..8×oh7/8/14/28，full 四分配、dispatch 固定 pad1/leading0。dispatch rowseven 入口1236、direct1080，worker mask 为1/15；逐 case 入口增量检查保留。详细推导和范围限制将写入 INTERFACE.md。

kw1/2 跳过 main；kw3 一轮三列；kw4/5 为一轮后余1/2；kw6/7/8 为两轮后余0/1/2；kw15/81 长循环保留。kh7/8 跨 t、多个横向 tile/oh28 重置保留。未加入作者可选 kw79/80。direct kh1..6 仅验证防御路径，不证明 shared 内部执行次数；旧 helper 非零和 worker mask 为 suite 累计。

独立 scalar 参考、逐位 memcmp、只读 input/kernel、分配两端 PROT_NONE、页内外围 canary 和 output poison 保持。无逐行 guard/sanitizer/官方 runner，也未增加 direct ow1 或 L/2L±1 范围。

remote wrapper 保留19阶段和退出原件：allocation/compiler/manifest/build-guard、六 guard、build-dispatch、六 dispatch、build-assembly/complete。要求实际 GCC10.3.1、完整原严格 argv（含 -fno-fast-math -ffp-contract=off -mcpu=generic）；full 生产源与参考分开 translation unit，只有独立 dispatch 插桩。生产汇编仅 -S，不声称对象反汇编。

源契约为13语义阶段、shared main3/u1 remainder0..2、其余12阶段u1，schema=`ac-shared3-paths-v1`。不固定机器 PC、计数、spill 或 region 数；待本版真实数值和全 helper/dispatch 汇编独立审查。T/AA PASS 不继承。提交子集 STOP；不授权性能、包、晋级或失败确认重试。Yfalse/Sfalse及原样本保持；用量40%停止，不用重置卡。
