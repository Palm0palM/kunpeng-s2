# AA 提交子集：final，准备不等于 GO

2026-09-13。本文件、driver.py、C54-row7x3shared4/source/ 的五个文件、source-hashes.json、source-manifest.json 和 prepared.json 已完成准备并停止编辑。接受器/冻结器及完整汇编接口另行完成与审查；提交子集不依赖它们运行。没有导入或执行 AA 工具，没有 SSH、预约、编译、算子运行、接受或冻结。

候选仅 C54-row7x3shared4，生产 source parent=C52-row7x3shared2；conv2d.c 是作者和独立审查最终字节的复制，SHA256 `fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88`。传输集合严格为 conv2d.c、check_conv_guard.c、check_sve_dispatch.c、candidate.env、remote_job.sh；没有 runner/benchmark、历史 raw 或假 job。第一次五文件 bytes/SHA 清单已经落盘，后续不自动刷新。

唯一候选目录 `.runs/conv/sep13aa-checks/C54-row7x3shared4`；未来唯一预约/作业路径为其 `job.json`。root 全量审清提交子集并另行明确 GO 后，唯一提交入口为：

```text
python3 .runs/conv/sep13aa-checks/driver.py C54-row7x3shared4 config/cluster.local.json submit --go
```

这只是供 root 审阅的命令，准备者未执行。driver 先验证配置为38 CPU、24576 MiB、1 packed NUMA、1800秒；先查固定原 Y1582410/W1582256/S1582067/T1582134/X1582372，以及现存 P/AA job.json。每个去重 job 查询一次；固定来源缺失/不符、实际预约没有数值 job ID、查询失败或状态非 terminal、job/system退出字段缺失均阻塞。prepared P/AA 无 job.json 不阻塞。不扫描其它队友；该有界门禁不替代 root 的唯一提交协调。

submit 必须带 --go 且当前无 job.json；源集合/实际字节/大小、prepared、生产 checkpoint 与源副本绑定后，以 open('x') 创建预约，再上传和提交。失败或不确定也保留预约，禁止第二次 submit。status 与 fetch 仅恢复原 ID，fetch 要真实终态及两个实际退出码；只取文本/.s，不取 .o 或执行文件，不覆盖异字节 raw。每次外层调用的 stdout/stderr/exit 应由生命周期负责人保存；status 间隔至少45秒，不自动轮询。

批准矩阵完整保留 T，增加 ow={3L−1,3L,3L+1,6L−1,6L,6L+1}×kh={7,8}×kw={4,5,6,7,8}×oh={7,8,14,28}。full 四分配新增960；dispatch 固定pad1/leading0新增240，逐 case 入口增量检查仍在；direct432原样。

| 每配置/六配置 | full | dispatch | direct | 合计 |
|---|---:|---:|---:|---:|
| VL16/32/64分别×线程1/4 | 5744 | 1212 | 432 | 7388 |
| 六配置 | 34464 | 7272 | 2592 | 44328 |

full 家族为 core3888/narrow144/small720/larger32/quad_boundary960；dispatch 家族为 core972/quad_boundary240。dispatch入口1236、direct入口1080；两套worker mask线程1为1、线程4为15。kw6明确覆盖quad后余2；原kw1/2/3与larger kw7/8/15/81保留。详细推导和覆盖局限见 `../sep13aa-diagnostic-plan.md`。

one_case 的独立 scalar 参考和逐位 memcmp、只读input/kernel、分配两端PROT_NONE、页内外围canary及output poison保持。没有每行guard/sanitizer/官方runner；direct kh1..6不进入shared。旧helper非零与mask为suite累计，不能称为内部quad执行计数。

remote_job.sh保留 T 十九阶段及完整退出留痕：allocation/compiler/manifest/build-guard、六guard、build-dispatch、六dispatch、build-assembly/complete。实际GCC10.3.1与严格 `-fno-fast-math -ffp-contract=off -mcpu=generic` 等完整argv保持；未插桩生产full与参考分开translation unit，独立dispatch才插桩。生产汇编仅 `-S conv2d.c`。父T PASS不能作为AA PASS；实际返回仍须独立数值与全汇编审查，接受/冻结工具必须另行final审查后才可调用。

提交子集 STOP。不授予性能/包/晋级；Yfalse和Sfalse及所有原样本保持，不重试失败确认；40%停止/no reset持续。
