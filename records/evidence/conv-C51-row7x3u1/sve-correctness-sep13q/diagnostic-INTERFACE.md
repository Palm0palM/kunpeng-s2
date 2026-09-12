# Q：C51 七输出行 × 3VL 独立诊断（prepared，未运行）

候选 `C51-row7x3u1`，source parent `C40-row6x3u1`，helper `conv_sve_rowseven`，21 个独立累加器。源作者宣布最终停止修改、根代理完成独立源码审查后，才复制实际源码并生成第一次五文件传输清单。实际生产 SHA 为 `5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff`。源码/benchmark/runner 未由本工具修改。

本轮复用 M 的 guard/readonly/bitwise 和传输/验收结构，重新推导 C51 的矩阵与七行参数；不引用 C40、C47、C48 的数值 PASS 或机器码作为 C51 验证。工具准备、普通文本读取和文件清单不构成编译或运行。当前没有 SSH、job、产物、实际验证、性能、包或晋级，也没有使用重置卡。

## 矩阵与数量

VL 为字节数16/32/64，lanes=VL/4，每行主块 `3*lanes`，故 BLOCK_OUTPUTS=12/24/48。线程为1/4；每个 worker 的实际VL、实际team都要确认，禁止把 EXPECTED_ACC=3 解释成三行 helper。

|层|每配置|六配置|
|---|---:|---:|
|未插桩生产 full|4784|28704|
|独立分派插桩 dispatch|972|5832|
|直接调用 kh<7 防御回退|432|2592|
|合计|6188|37128|
|官方 runner|0|0|

- 核心 full：6宽 × kh6/7/8 × kw1/2/3 × 18高 × 4分配方式 = 3888。宽度为3VL/6VL±1，高度为1..15、21、22、28，覆盖七行分组全部余数、正好整组、两组和四worker整组。
- narrow：ow1 × 3kh × 3kw × oh1/7/13/28 × 4分配方式 = 144。
- small：ow1、3VL−1、3VL+1 × kh1..5 × 3kw × oh1/7/13/28 × 4分配方式 = 720。kh6已在核心/narrow中覆盖。
- larger：kernel(10,7)/(9,8)/(15,15)/(81,81) × oh7/13 × 4分配方式，ow3VL+1 = 32。
- 四种分配方式为pad0/1 × leading0/1。输入/权重只读；所有分配前后有PROT_NONE，页内外围canary，输出poison；memcmp对独立逐项顺序scalar reference做逐位检查。没有每行独立guard，也没有 sanitizer，不能扩大覆盖声明。
- dispatch 使用核心矩阵但每case只用pad1/leading0，6×3×3×18=972；每个case检查新增 `rowseven` 入口数。只有kh>=7且oh>=7时入口为floor(oh/7)，与主块是否够宽无关（不足块仍会进入helper再回退）。18个高度的floor(oh/7)之和为21，故总入口6×2×3×21=756。
- direct 显式调用七行helper的kh1..6防御分支：3种3VL邻域宽度 × 6kh × 3kw × oh7/28 × 4分配方式 = 432；独占各七行输出组，入口3×6×3×4×(1+4)=1080。每case入口增量准确检查，不从全局计数推断各case。
- dispatch和direct各自mask在线程1时=1，线程4时=15；direct重置mask必须在前面全部team join后发生。旧prefix/tail/pair/triple/quad各需非零实际入口。入口证据不等于十三算术阶段的逐case动态分支计数，本轮没有插桩那些阶段。

与源作者 `C51/BOUNDARY_MATRIX.md` 的建议矩阵不同：本轮围绕新增七行分组和3VL/6VL主块边界采用自己的有界矩阵，没有纳入额外低向量L/2L±1的864个full case；原低向量尾处理helper源码保持不变，但本轮不声称重新覆盖这些建议组合。direct宽度为3L−1/3L/3L+1，包含精确主块边界，未单列建议ow1；ow1只在正常入口full的narrow/small中覆盖，不能当作direct ow1已测。较大kernel采用既有M模板的10×7、9×8、15×15、81×81，覆盖大于七行阈值的奇偶核与最大所选核；未声称测试原建议9×7和8×8。旧helper入口非零和worker mask是整套累计指标；只有新rowseven入口增量逐case精确校验，未逐case验证每条旧helper尾部分支路线。矩阵范围是本轮实际计划，不能写成原建议全部覆盖。

返回每配置必须有精确full family行 `FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32`，full4784/dispatch972/direct432三条PASS，dispatch756/direct1080实际入口和匹配mask。计划数保持planned；实际结果只有返回并验收后才填写。

## 资源、包装与接口

以下命令仅说明恢复接口，本轮准备阶段不执行：

```text
python3 .runs/conv/sep13q-checks/driver.py C51-row7x3u1 config/conv-sep12.local.json gate
python3 .runs/conv/sep13q-checks/driver.py C51-row7x3u1 config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13q-checks/driver.py C51-row7x3u1 config/conv-sep12.local.json status
python3 .runs/conv/sep13q-checks/driver.py C51-row7x3u1 config/conv-sep12.local.json fetch
python3 .runs/conv/sep13q-checks/accept_returned.py C51-row7x3u1
python3 .runs/conv/sep13q-checks/freeze_returned.py C51-row7x3u1
```

唯一提交者是根协调者，须先独立审查再给予compute GO。`--go`不是准备脚本自授权限。driver只对最新N1581459及已存在P/Q job做有界实时查询；P/Q只有prepared文件且没有job.json时忽略，已有无ID reservation、未知/非终态、查询失败、job/system退出码缺失均阻止。N须对应已知1581459。门槛不扫描队友作业，不取消任何任务，也不是跨协调者调度锁。

submit在首次传输前用排他方式创建job.json。传输失败、提交不明或中断保留reservation和日志，不删除或重提；status/fetch复用已保存ID，不自动轮询、不继续别的作业。fetch仅保留安全单层普通文本/源码/.s，拒绝重名/已有不同字节，不打包配置或认证。无独立.o产物，不能声称有对象反汇编。

资源固定38CPU、24576MiB、一个packed NUMA、1800秒。包装在分配后核对Linux/AArch64、38个affinity CPU同属一个NUMA、GCC10.3.1。所有编译与运行只允许超算调度分配计算节点，不使用登录节点或本机代替。

三条真实gcc argv共享：

```text
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3
```

顺序追加 `check_conv_guard.c conv2d.c -o check_conv_guard`、`-finstrument-functions check_sve_dispatch.c -o check_sve_dispatch`、`-S conv2d.c -o conv2d-sve.s`。生产与scalar guard独立TU；只有独立dispatch程序插桩。无tune/LTO/fast-math或CHECK_ROWQUAD。验收从probe/各build log真实xtrace按shlex解析，不执行日志；重复trace必须一致且顺序正确。

19个作业阶段不同于helper十三算术阶段：allocation、compiler、manifest、build-guard、六个guard-vl16/32/64-t1/4、build-dispatch、六个dispatch-vl16/32/64-t1/4、build-assembly、complete。要求完整精确有序stage-exits每项0、wrapper0、真实scheduler SUCCEEDED且job/system均0，全部原日志和源码清单对应实际作业。数字PASS不能替代调度器/包装退出检查。

## 返回后的独立机器码审查与验收

`assembly-review.json`只在实际生产`.s`返回后填写。必须绑定candidate/job_id/source_sha256/compiler_version10.3.1/assembly_sha256，不预填PASS或机器码数字。检查完整helper及所有clone，从实际label到.size全范围，记录固定/动态栈帧、ABI saves、Z/Q/谓词spill load/store、间接栈地址、全部转场、尾列和kh<7回退。21acc预算不证明零spill，spill观察也不自动等于数值失败。

每个helper十三阶段按 `input_0..5, shared, trailing_0..5` 排序，实际范围不重叠，kernel_columns_per_iteration=1，有source_mapping、spill_notes和实际spill计数。逐项记录实际普通/indexed FMUL、FADD、LD1W/LD1RW/LD1RQW、DUP/indexed MOV、EXT/MOVPRFX和总指令。编译器若改变展开，保留实际产物供根复核，不能编造范围以通过固定门槛。

审查每输出r只按kernel行0..kh−1、每行kw列顺序累加：input t0..5仅参与r<=t，shared t6..kh−1参与七行，trailing t=kh+q/q0..5仅参与r>q；确认三个vector列边界、全部21store、横向尾部quad+triple和kh<7直接quad+triple。检查完整conv2d和所有conv2d.*实际函数范围：SVE能力位、kh>=7/oh>=7分派，size_t分组，余6=quad+pair、5=quad+prefix、4/3/2/1旧helper，各组独占输出；检查完整旧SVE和非SVE路径，而非只看入口符号。

review需要review_complete/production_uninstrumented/whole_helper_stack_reviewed/all_stages_and_transitions_reviewed/abi_saves_distinguished/dispatch_reviewed均true，whole_source_fma_count=0（扫描全部fused families），shape={rows_per_group:7,vectors_per_row:3,accumulators:21}，whole_machine_code_identical_claimed=false。没有当前.o，因此production_object_disassembly_available=false。

成功validation为passed/complete，含唯一job、真实scheduler/wrapper退出、19stage_exits、actual build_commands、allocation、源清单验证、六配置实际数量/入口/mask和actual assembly review；不测性能、不自动晋级。初始prepared validation原字节先保存为prepared-validation.json，已有终态拒绝覆盖。解析错误独立保留acceptance-failure；不能把解析错误伪装成算子失败。只有真实调度器/包装/阶段非零才可用 `--failed`，未知实际case数为null，不用计划数冒充执行数，不造缺失.s。

freezer在共享workflow lock下原样复制当前诊断树和三个工具/本接口，实际.s同字节保存.assembly.txt后原子rename到 `.runs/conv/C51-row7x3u1/sve-correctness-sep13q/`。已有目标或staging一律拒绝，不删除失败证据；原metadata/source/raw不修改。准备时未执行freezer，也未写C51候选目录或record。
