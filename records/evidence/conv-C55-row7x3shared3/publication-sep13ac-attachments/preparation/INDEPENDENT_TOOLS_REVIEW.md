# AC 独立工具静态审查

2026-09-13，审查者 `conv_o_accept_sep12`。结论：在本次限定范围内未发现阻碍。完整读取最终三工具、INTERFACE.md、SUBMISSION_INTERFACE.md、STATIC_REVIEW.md 和 AA-to-AC.patch，并核对 prepared、首次五文件清单及最终文件身份。本报告只表示静态审查完成，不是 AC GO、实际数值通过或汇编通过。

只使用文本读取、`cmp -s` 和 SHA256 计算；没有导入或执行 AC 工具，没有 SSH、预约、编译、算子测试、accept 或 freeze。只新增本文件，未修改作者文件、源、记录或其他实验。

## 最终字节与范围

实际重新计算的 16 个准备文件 SHA256 全部与 PREPARED_FILES.json 一致。三工具和主接口身份如下：

| 文件 | SHA256 |
|---|---|
| driver.py | `89ca93a8131c743571930e2ec1967d328381d9772a2d9e891cb927e321fe1df6` |
| accept_returned.py | `0cdaa18a7b576f1644c9d2a918ba0af407c7f72ae4b7ec5de2e2e6ad0c97a580` |
| freeze_returned.py | `5af23982c0771d17c8d509df06924ae76ec5da2c3036425ac3eae9c97d390b2a` |
| INTERFACE.md | `d03c9b0e50614c0c203ede490213e0c391117f9214848617eb3f78d8136a8ee8` |
| AA-to-AC.patch | `1c47863902d04ccdc0ccf3b4f0e8cf150e2444c59dc7c8400ea74618d275940d` |

唯一候选为 C55-row7x3shared3，生产父版仍为 C52-row7x3shared2/T1582134；AA 仅提供工具和检查矩阵。传输 conv2d.c 与 C55 当前 source 经 cmp 返回 0，实际 SHA256 为 `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`。两个 C checker 分别与最终 AA 原件 cmp 返回 0，实际 SHA256 为 `ccbba2637255b5d2733dfbfdddd88afd0d09815d5759ca86c9e8c498475990d5` 和 `fa47796ed01ca2a7d925176b25a6b18d6d124385bf21c1e452a3c2f9afc0f81d`。

相对 AA 的生产源差异是 shared 主循环四列改三列并删除第四列更新；工具差异绑定 C55 身份、shared3 schema/工作量/余数界限，以及本轮串行来源。wrapper/env 仅调整候选身份和源 SHA；严格编译参数、19 阶段、六种 VL/线程组合、独立参考及插桩范围保持。清单仅包含五个传输文件，不继承父 raw、job、PASS 或代码生成结论。

## 数值与覆盖契约

每配置 full5744=3888+144+720+32+960，dispatch1212=972+240，direct432，合计7388；VL16/32/64 × 线程1/4 总44328。dispatch rowseven 入口1236、direct1080、worker mask1/15和逐 case 入口增量检查未改变。full 六配置34464、dispatch7272、direct2592与 prepared/接受器一致。

沿用的 kw1/2 跳过三列 main，kw3 覆盖一轮，kw4/5 覆盖一轮后余1/2，kw6/7/8 覆盖两轮后余0/1/2；kw15/81 保留多轮覆盖。kh7/8、3L/6L 阈值和多横向 tile/多输出行组覆盖保持。`quad_boundary` 和原 C54/four-column 注释是保留原字节的网格名称/来源说明，接口已明确不代表 C55 的四列计算。

独立 scalar 逐位参考、只读 input/kernel、分配两端保护、页内 canary 和输出 poison 均由原 checker 保持。旧 helper 非零与 worker mask 是 suite 累计；direct kh1..6 验证防御路径，不提供 shared 内部执行次数证据。未加入 kw79/80、direct ow1 或额外 L/2L±1 范围，也不声称逐行 guard、sanitizer 或官方 runner 覆盖。

## 实际汇编接受与冻结

接受器使用 `assembly.schema=ac-shared3-paths-v1`，要求13语义阶段、21累加器和 `shared_triple_and_remainder_reviewed=true`，shared_unroll 为 main3、source remainder1、最大 remainder2、其余阶段1。parent_codegen_comparison 继续绑定 C52/T1582134 的实际源及实际 .s SHA，不借 AA 的 quad 代码生成。

shared blocks 的角色为 `triple_main`/`u1_remainder`，每块允许多个真实不重叠范围。triple main work 必须为3且至少识别一个实际 main backedge；u1 loop work1，直线 remainder 块可表示实际合并的一或两列。每块真实范围之和须产生21×work 的 FMUL/FADD；每列派生计数和动态 arithmetic region 数从实际范围计算，不固定14个机器区域。

remainder_paths 必须覆盖0/1/2，路径 ID 唯一并有条件及执行顺序说明；只能引用 u1 块，正执行次数最多2，直线块不能声称重复，按执行次数×work累计须等于该路径余数，零余数为空路径，所有 u1 块均被真实路径引用。这允许多块或多个替代路径，同时防止将它们误加为每次全部执行。无法映射的实际 lowering 应保留原件并停止接受，不通过预填行号、PC 或放宽计数解决。

全 helper/clone 符号与边界、所有阶段/转换/尾路径、地址与标量栈、ABI 保存和向量/谓词 spill、所有 dispatch 及全源 FMA 检查仍是独立实际审查要求。spill 观察必须如实记录，不预填零，也不直接产生性能结论。实际编译器、严格 argv、源清单、19阶段、六配置数值日志和全部 scheduler/job/system/wrapper 退出证据必须同一 AC 原作业。parser 错误与真实执行失败仍分开保存。

冻结器按相同 triple3/u1 路径工作量和动态区域字段检查已接受原件；维持共享锁、拒绝已有目标、原始 .s 同字节保存及原子发布。它不运行接受器，也不自动产生性能、包或晋级授权。

## 唯一提交与 AB 串行门禁

唯一 AC 预约为 `C55-row7x3shared3/job.json`；显式 `submit --go`、拒绝已有预约、先排他创建预约后上传提交的顺序保持，失败或未知 ID 保留原预约。status/fetch 仅恢复原 ID，fetch 要真实 terminal 及两个整数退出字段并拒绝异字节覆盖。

固定 AA1582656/Y1582410/X1582372/T1582134 原件缺失或 ID 不符会阻塞；现存 P/AC 预约无可核对 ID 也阻塞。AB 只读取本轮 campaign 的 performance_job 与 C26-r30/C54-row7x3shared4/C52-r2/C26-r31 四个 cluster.json 的 job_id；已存在但未知、冲突或非终态均阻塞，缺席的未预约文件不误阻塞。去重后每个实际 ID 查询一次，查询失败或缺少真实终态/退出字段不能放行，不扫描队友范围。

只读核对时 AB campaign 实际为 performance_running，performance_job=`1582814`，四成员 job_id 同为1582814，字段名与门禁匹配；这是本地记录快照，没有进行状态查询。AC 未来提交仍须由该门禁取得 AB 的真实终态证据并由 root 协调唯一 GO，当前报告不授权并跑。

独立审查完成，未发现需要作者修改的实质阻碍。STOP；Sfalse/Yfalse和全部历史样本保持，用量40%停止、禁用重置卡。
