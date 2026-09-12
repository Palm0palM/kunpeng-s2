# R16 条件性 T19 最终包流程（仅准备）

本目录从已审查的 r15/T18 私有包流程适配，包含冻结 submitted-payload 证据修复。当前只准备脚本和说明，**不代表 T19 已通过、晋级或可以执行打包**。只有 `T19-panel8x16budget` 本身已实际验证并晋级、仍为 records/best.json 中 TRSM best，且当前 trsm 四源码等于其有效测量快照时，才可开始后续流程。来源 T18 的成绩不能代替这个条件。

package_rules.py 的 validated_record/validate_private 保留 current best、problem/version、passed、verified、promoted_at、nohash helper 原测量证据审计，以及 trsm.c、bench_trsm.c、run.sh、compat/kblas.h 四文件直接字节一致性门禁。私有 source-record.json 必须持续与有效晋级台账一致；ZIP、stage、元数据和当前源码在 prepare、submit、collect、finalize 时继续核对。

## 算法与派生范围

交付说明描述T19完整实现：仅在原HWCAP条件、两道安全字节计算且共享历史副本超过4MiB时，完整16列任务使用8×16 SVE历史前代核和两份连续RHS8 scratch。预算内共享分配失败、无SVE、窄VL、短列任务、尾行和线程scratch失败保留各自旧核/NEON/标量回退。NULL不是新路径条件。原64MiB整算法选择保持。

KB256/CT64起的大路径完整保留T18，最初来自T13-sve4x32。T18在T19准备时未晋级，最终必须以T19自己的有效晋级记录证明可交付。builder从有效record读取实际源码测量job、各用例中位数/误差和合计；finalizer从真实ZIP复跑日志读取独立包成绩，没有预估性能或硬编码作业ID。

## 满足条件后的顺序（本次未执行）

```bash
python3 .runs/trsm/build-final-package-r16.py
python3 .runs/trsm/package-check-20260912-r16/job_control.py prepare
python3 .runs/trsm/package-check-20260912-r16/job_control.py submit
python3 .runs/trsm/package-check-20260912-r16/job_control.py status
python3 .runs/trsm/package-check-20260912-r16/job_control.py collect
python3 .runs/trsm/finalize-r16.py
```

builder只在门禁通过后排他创建 `.runs/trsm/final-package-20260912-r16/`，输出私有五文件 trsm.zip、stage、source-record.json 和 metadata.json。prepare唯一输入为该私有ZIP和metadata，不拿 outputs 中旧公开包替代。连接配置仅指向root已有的 `.runs/trsm/optimization-20260912-r16-compare/cluster.local.json`，不会复制进payload或公开证据。此准备阶段没有创建上述私有包、payload、submission/state或outputs。

prepare排他创建submission.json和payload目录，冻结真实私有ZIP、package-metadata.json及六脚本；生成上传tar后直接比较全部成员。submit先排他创建submit-attempt.txt，持久化uploading/submit_unknown，唯一新远端目录只提交一次。不要调用submit来试探晋级门禁，因为attempt文件会先创建。失败/不确定状态保留原件，不重复提交或重建同名尝试；已取得job但marker发送失败时，只能用 `confirm-job` 修复已有job marker。

## 计算节点与精确 ZIP 验证

target-environment.sh在编译器解压、源码解包、编译或测试前要求Linux aarch64、确认的数字作业ID、恰好38个CPU且属于单NUMA。作业ID来自控制器已取得的真实调度ID；marker最多等180秒，现有调度器环境变量若有必须一致。其KML探测与资源门禁继承r11已审查实现，使用同一私有GCC12.3.1、真实KML25.1头文件/默认-lkblas、38线程close/cores绑定、generic target、TEST_RUNS=3。不能把KML25.1称为指定KML25.2复验。

监督进程在内存中保留收到的完整ZIP及五个普通成员，检查恰好README.md、bench_trsm.c、compat/kblas.h、run.sh、trsm.c。解包后和运行结束后分别检查五文件与原ZIP的直接字节一致性，同时确认ZIP/metadata未改变；失败不得形成成功证据。run-three-suites.sh从此ZIP解压目录连续调用原run.sh三套，要求9个有序官方PASS、有限正耗时/GFLOPS和原1e-12精度，每套单独审计实际生成trsm_test的KML/私有gomp动态依赖。probe另外核对真实头文件、符号、38线程与依赖。

collect先独立核对调度成功及job ID，再取回原ZIP、metadata、五源码、原benchmark/environment/linkage/probe/ldd/compiler/wrapper日志与ZIP审计；nohash helper完整audit及原parse_log形成result。只有全部通过后submission.state变为collected。失败或不确定提交不重提；collect拒绝失败作业时应先由root只读取回已有失败日志另行诊断，不能把失败状态写成成功。

## 条件性交付与冻结来源

finalize-r16.py先调用audit_collected并在写入前再次复核，只有成功收集的同一私有ZIP通过全部门禁后，才备份并替换 outputs/trsm-best.zip、outputs/trsm-best.json 与 trsm/README.md，并创建 docs/trsm-final-20260912-r16.md、records/evidence/trsm-finalpackage-20260912-r16。已有最终化目录/文档/marker阻止重复使用，写入期间若失败保留备份并尝试按实际字节条件回滚。它不创建GitHub release、不上传或正式提交比赛；未来release tag仅在通过后写入元数据为 `trsm-t19-panel8x16budget-20260912-r16`，实际GitHub发布另由root处理。

公开证据的submitted-payload仅从prepare时payload读取六份冻结脚本：remote_job.sh、run-three-suites.sh、probe.sh、target-environment.sh、required-symbols.c、audit-dependencies.py，以及原package-metadata.json。它们必须与payload.tar.gz成员逐字节一致，缺失或不一致在公开写入前失败；不能以当前脚本替代。公开文件先脱敏，ARCHIVE.json.provenance逐项区分准备上传快照与当前本地控制/审计脚本。顶层package-metadata.json是含最终发布字段的元数据，submitted-payload中的仍是原prepare版本；不额外声称验证了远端脚本字节身份。

准备阶段仅做编辑、Python AST（包含Shell内嵌Python）和bash -n语法检查；不运行任何流程入口、不导入控制器、不创建包或运行状态、不SSH、不编译/执行题目、不计算或验证哈希。尚无本流程的新运行证据。
