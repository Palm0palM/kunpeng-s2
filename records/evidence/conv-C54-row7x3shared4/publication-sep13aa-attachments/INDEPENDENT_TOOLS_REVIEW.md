# AA 工具独立静态审查

结论：最终提交子集、接受器与冻结器未发现静态阻碍。Aquinas 已分别确认提交子集和全部工具/接口 final-ready、STOP；本报告对应其最终字节。审查仅为文本读取、字节/哈希核对与矩阵推导，没有导入或执行 AA 工具、SSH、编译/运行算子、提交作业、接受或冻结，也不作为实际 AA 数值或机器码通过结论。

审查覆盖成熟 T 三工具全文、AA driver/freezer 全文、接受器完整 T→AA 差异和原未改正文、两 C checker 全文及完整差异、remote_job.sh/candidate.env、最终 SUBMISSION_INTERFACE/INTERFACE/STATIC_REVIEW/PREPARATION_COMMANDS、prepared 与两份五文件清单。C54 生产源码另有已经完成的 INDEPENDENT_SOURCE_REVIEW；本次再次确认传输 conv2d.c 与该最终生产源逐字相同。只新增本报告，不改其他协作者文件。

| 最终工具 | 字节数 | SHA256 |
|---|---:|---|
| driver.py | 18442 | `6a6acf8d84b5ef87125da2ec14931343dc2301f07472c7826096a379a05f1b5a` |
| accept_returned.py | 27100 | `106baeda7e595b95a91f875d38d2d92710afe4f90458edf54ac34fd284575b33` |
| freeze_returned.py | 17124 | `4a68452496680a9677d4e3ba1bfd8189627b8238a1499a497a1a5f312551f548` |

上述身份及完整接口、准备说明、T-to-AA.patch 均与 PREPARED_FILES.json 相符。prepared SHA为 `72d575caff5790237623cf6233e7990f568f783590cd6e5adbe450489a81a82f`；生产源固定 `fa0f5b43fc7901e9853dbe189385653ea4ae8bf697fa3b67af7f288063a4fb88`，父为 C52-row7x3shared2。首五文件 bytes/SHA 与实际文件全部一致；prepared 保持 compiled/executed/verified=false，不预填实际 job、PC、spill 或 PASS。

矩阵确实增加了 C 循环中的 one_case/checked_entry_case 调用，并非只修改输出字符串：

| 路径 | 每配置独立推导 | 每配置 | 六配置 |
|---|---|---:|---:|
| full 原部分 | 3888+144+720+32 | 4784 | 28704 |
| full 新部分 | 6宽×2kh×5kw×4oh×4分配 | 960 | 5760 |
| dispatch 原部分 | 6宽×3kh×3kw×18oh | 972 | 5832 |
| dispatch 新部分 | 6宽×2kh×5kw×4oh | 240 | 1440 |
| direct | 3宽×6kh×3kw×2oh×4分配 | 432 | 2592 |

因此 full5744/dispatch1212/direct432，每配置7388，六配置44328。新网格为3L/6L±1、kh7/8、kw4..8、oh7/8/14/28；full四分配，dispatch固定pad1/leading0。新增入口为6×2×5×(1+1+2+4)=480，原756+480=1236；direct为3×6×3×4×(1+4)=1080。每case精确 delta 检查仍在，dispatch 快照在 direct 前保存，direct mask 重置且前一线程组已经结束，套级 mask 仍为1/15。

新增 kw4/5/6/7 分别涵盖一轮四列后的0/1/2/3余数，kw8涵盖主回边；kh7/8为一次/两次shared外层，6L宽和oh28提供tile/分组重置。3L−1不进入主向量块，必须与其它五个足宽形状区分。入口计数证明 helper 调用，未声称测得内部 quad 或余数动态次数。direct仍只验证kh1..6防御；legacy helper非零与worker mask为套级累计。原参考、只读input/kernel、分配两端guard、页内外围canary、output poison与memcmp均未变；没有逐行guard、sanitizer、非法参数或禁用SVE的全面覆盖承诺。

提交、状态与取回的关键不变量保留：

- 固定原 Y1582410/W1582256/S1582067/T1582134/X1582372，以及现存 P/AA job.json；按ID去重实时查询。缺失/换号、真实预约未有明确ID、查询失败、非终态或缺少整数退出字段均阻塞。该门禁判断计算是否结束，不把某个父作业的终态当作 C54 通过。
- 仅显式 root --go 且不存在 job.json 才进入提交；先完成来源检查，再 open('x') 预约，之后上传与一次提交。上传失败、提交不确定或未解析出唯一ID均保留预约与日志，不自动重投。这不是跨全部协作者的分布式锁，仍依赖 root 唯一提交协调。
- status/fetch恢复原ID；查询失败单存证据并保留上次成功状态。fetch要求真实终态和两项退出码，只接收普通、单层、限大小的文本/.s成员；先检查全部返回文件再写入，异字节或symlink拒绝覆盖。完整历史仍由调用者保存每次外层stdout/stderr/exit，接口已明确至少45秒状态间隔。
- SUBMISSION_INTERFACE 的示例使用config/cluster.local.json；root已明确本次实际采用已验证的config/conv-sep12.local.json并单独留痕。driver参数允许该配置且会核对相同38CPU/24576MiB/单packed NUMA/1800秒资源；没有改动冻结接口文件。

remote wrapper相对T只改身份、源摘要、矩阵和入口常量。十九有序阶段、Linux/AArch64/38CPU单NUMA检查、GCC10.3.1、源清单、pipefail/tee与退出处理保持。实际三条编译argv仍严格使用-fno-fast-math、-ffp-contract=off、-mcpu=generic等原flags；full候选与参考分开翻译单元，只有独立dispatch插桩，生产.s由未插桩conv2d.c生成。接受器读取真实xtrace而不是仅信BUILD_COMMAND展示行。

接受器必须同时满足原job/保存scheduler文本及两项退出、wrapper0、十九有序stage全0、六组VL/线程头、精确full/dispatch家族与计数、入口/mask、五份返回源字节/SHA和编译argv，才进入完整汇编验收。实际`.type`枚举出的所有rowseven helper/clone与全部conv2d/outlined worker都必须有标签至.size的唯一范围及完整人工说明；全.s FMA重新计数须为0。父T实际源码和.s摘要只用于比较，没有继承父机器码相同或本版PASS。

新`aa-shared4-paths-v1`契约静态一致：13个语义stage仍固定有序，其它12stage为u1；shared的quad_main/u1_remainder可各有多个真实块，每块可由多个不重叠的实际闭区间组成。quad工作量为4，u1回边为1，u1直线聚合可为1..3。接受器从所列真实文本重新累计每块FMUL/FADD并核对21×work，而不采用预填计数；要求至少一个实际quad回边。remainder_paths覆盖0..3，每条有唯一ID、真实条件/顺序、按执行次数累计的完整工作量，所有余数块均须解释；直线块不能虚报重复执行。范围数量从实际ranges派生，未固定为14。

该schema支持分散机器区间和不同余数分支，不会自动证明控制流文字正确；人工仍需完整阅读实际.s，确认每个聚合区间在同一路径执行，不能相加互斥分支以凑84/84。地址/标量间接栈、t/tile重置、边界、ABI D保存与Z/Q/谓词spill、全部转场、21stores、尾部和防御均有必填人工审查项。若实际lowering无法真实映射，应保存首次结果停交root，不调整数值门槛或伪造PC。源码调用数、区间统计和余数路径模型都不是性能或动态计数证据。

冻结器独立核对已有validation的真实终态、来源、44328矩阵、13语义阶段、quad/u1工作量、0..3路径和派生范围数。在共享锁内原样复制，保留初始prepared及原source/raw，附三工具/完整接口，实际.s另写同字节文本副本，最后原子rename；已有target或staging拒绝覆盖且错误后不自动删除。它不会调用accept、联网、测量或打比赛包。接受器禁止覆盖最终validation；解析失败单独留acceptance-failure，只有真实scheduler/wrapper/stage失败才允许--failed，缺失检查数保留null而不是伪造算子FAIL或PASS。

本报告未读取或审查本轮实际dispatch汇编，也未执行accept/freeze；实际AA运行验收由另行授权的审查负责。Yfalse/Sfalse和所有原样本保持，C6最佳不由本报告改变。提交子集先行阶段结论已单独交root；最终工具审查完成后STOP。账户已用仍低于40%停止线，未使用重置卡。
