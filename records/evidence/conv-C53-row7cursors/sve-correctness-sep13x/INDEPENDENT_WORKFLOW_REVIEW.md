# X / C53 独立工作流静态审查

结论：在本次有界静态审查范围内，未发现阻止 root 独立决定唯一 X GO 的问题。该结论不是提交授权、诊断 PASS、实际 serial gate 通过或性能结论。审查时 X 仍只有准备文件，未见 job.json、raw、assembly-review.json 或 validation.json。

完整读取 Q-to-X.patch、INTERFACE.md、作者 STATIC_REVIEW.md、driver.py、accept_returned.py、freeze_returned.py、五文件 source-hashes/source-manifest、prepared.json、PREPARED_FILES.json，以及实际 wrapper/env。对两个 C checker 与原 Q、传输 conv2d.c 与已审 C53 作逐字比较，均无差异。仅做本地文本读取、diff、字节数/摘要核对；没有导入或执行三份诊断工具，没有 SSH、编译、算子、测试、作业、accept 或 freeze。唯一新增文件为本报告，不修改原工具、源、清单、record 或队友文件。

## 源身份与准备状态

driver.py:24、accept_returned.py:20、freeze_returned.py:21 仅允许 C53-row7cursors，并各自固定 SHA256 `d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0`。source parent 为 C51-row7x3u1；候选源、checkpoint、准备副本、两份清单和 prepared 身份由 driver.py:130–190 关联，传输集合严格为五文件。实际固定 SHA 也在计算节点 wrapper 的 manifest 阶段再次核对。没有从 Q/T 借用 job 或 validation 的路径。

本次实际五文件字节数和摘要均与两份源清单及 prepared 一致：

| 文件 | 字节 | SHA256 |
| --- | ---: | --- |
| candidate.env | 200 | e7569ca6cacecbeb86c0d27d29f7de800106c07d1aeaf7d3b63bcb2d7573ac4d |
| check_conv_guard.c | 8097 | b11bfe06a6d09228ad0d4dc6ae3d7581642fb534a1bd612f94c86574f41cc307 |
| check_sve_dispatch.c | 6764 | 5751451998db3f2bee920afc78af05039d5b11949db5a4765aefe8553d4aacbc |
| conv2d.c | 103310 | d83d535334dfd55925426a515a0fd5843c090fff4c56d44f870fd2460a4d5cd0 |
| remote_job.sh | 3936 | 35d0a2f54a782e3db290d172ed17cb9ac5c70f1c59937db73263e3b3975cb693 |

三工具实际摘要与 PREPARED_FILES 相同：driver `bdd00447137904bdd2941022789014bdb6a35703b93446b1dccd37b5e4ee4fc6`；accept `d7bfa10dee7f813f4589966cdc156970ed793452597e3c694e1e9eafc982c4f5`；freeze `18384ba1e061c80dba4b290ca25a99fbdd0eda2651ae3feb494a7019886f8d5f`。原清单不包含后来新增的本独立报告，本审查不重写初始清单。

prepared 的 status=prepared、complete=false、actual_job_id=null、compiled/executed/verified=false，与无原件结果的实际文件树一致。28704/5832/2592 和37128出现在计划字段，不是预填 actual PASS。

## 数值与真实返回要求

两个 C checker 已在 Q 独立逐行审查，本次逐字相同，因此复用该具体审查结论。VL16/32/64字节×线程1/4，六配置各 full4784+dispatch972+direct432=6188，总37128，runner0。full 的3888/144/720/32构成、kh6/7/8、kw1/2/3、oh七行分组与余1..6、3L/6L邻域和较大奇偶 kernel 保持。kh7检查单次 shared t，kh8及更大 kh 检查跨 t；6L及6L+1检查至少第二完整 tile 的游标重置。direct kh1..6仍仅证明 helper 防御回退，不代表 shared 游标的动态覆盖。

独立 scalar 逐位参考、readonly/guard/canary/poison 和真实入口检查均来自原 Q 字节；dispatch/direct 的756/1080入口、线程mask1/15、旧五helper非零仍由接受器核对。保留 Q 已明确的范围限制：未增加低 L/2L邻域864例、direct无ow1、larger采用10×7/9×8、无sanitizer/每行guard/invalid-size或NaN专项。旧helper非零与worker mask是suite累计，不能称为每case或内部13阶段覆盖。

wrapper保留19个有序阶段与退出记录，pipefail及最终tee退出处理保持。原浮点 flags、GCC10.3.1、generic、38CPU/24GiB/单NUMA限制不变；仅dispatch可插桩，生产汇编仍是独立未插桩 `-S conv2d.c`，不取对象文件。accept_returned.py:206–260 要求真实自身 terminal scheduler、job/system/wrapper全0、19stage全0、源manifest/返回字节一致、三条实际xtrace编译argv、每配置PASS及入口/mask，之后才产生成功记录。缺失、解析错误和实际执行失败分别处理，不把解析错误改成数值FAIL，也不覆盖既有最终validation。

## 游标和全部实际汇编解释

accept_returned.py:148–203 绑定自身candidate/job/source、GCC和实际.s SHA；发现全部真实 rowseven helper/clone 及 conv2d/outlined functions，并核对从函数label到.size的完整范围。全部helper的栈、spill、转换、尾部/防御、算术和加载解释仍必需，dispatch逐函数保留控制流/栈说明。

新增要求完整覆盖本候选风险：`cursor_initialization_and_tile_reset_review`、`cursor_step_and_cross_t_review`、`cursor_bound_and_one_past_review`、`scalar_addressing_and_stack_review`；shared另需 `address_generation_review`。INTERFACE 明确每tile七初始行6..0、每列一元素及跨kw列继续、地址恒等式、kh7/8/长kh与最终ka一过末端不读、输入地址保持，以及GPR/标量或间接栈、ABI D与Z/Q/谓词spill的区别。非空字段是要求提交真实解释，不是已经完成机器证明。

13阶段严格按 input_0..5/shared/trailing_0..5 排序，每个非重叠范围 work=1，明确拒绝 T 的 `blocks` paired/odd schema。接受器从实际.s派生指令数，并要求每阶段FMUL/FADD对数为3/6/9/12/15/18/21/18/15/12/9/6/3，全源FMA0。shared的LSL/ADD/SUB/LDR/STR/LDP/STP只是全区域词法计数；kernel地址ADD、外层推进、输入寻址和实际栈流量必须人工分类。没有预填Q的63指令、固定PC、固定栈大小或零spill，也没有把地址表示变化自动解释成提速。

若实际编译器不能对应13个u1范围、工作量变化或游标地址无法解释，当前代码会停止接受并保留原件，交root判断；不得为通过而套父范围或伪造计数。即便数值通过，也必须如实报告地址假设是否形成实际不同代码，性能仍需root另行决定。

## 串行、唯一提交和归档

driver.py:80–127 的集合仅为固定 W campaign1582256、T原诊断job1582134、S campaign1582067，另加已存在的P/X job.json。实际本地文件中三固定身份一致，W/S为performance_complete，T保存SUCCEEDED/job+system0；本审查未查询调度器，未来提交仍要执行实时查询。P/X当前无job.json不阻塞；一旦存在而无数字ID就阻塞。固定文件缺失、ID不符、查询失败、非terminal或缺整数job/system退出均使clear=false；按job ID去重，不扫描其他队友。串行只证明作业结束，不把终态失败当数值通过，也不冒充跨协调者锁。

submit路径明确要求--go、拒绝现有job.json，在任何上传前排他预约；上传/提交不明时保留预约和日志，status/fetch只能复用已知ID。fetch只收普通白名单文本/.s，并在写入前检查所有既有字节，拒绝覆盖不同原件。

freezer在共同workflow锁内校验已有接受结果及自身source/job、37128与游标/13阶段字段，然后将原件复制到staging并原子改名为C53自己的sve-correctness-sep13x。已有目标/staging不删除、不覆盖；失败只能凭真实执行失败归档；不创建缺失.s、不重新accept、不更新候选record。工具/接口/作者静态说明/patch/inventory按实际附件保存。

未发现需作者修改的静态阻碍。实际X提交、返回汇编解释、接受和冻结均尚未发生；保留所有原准备文件，交root决定下一步。STOP。
