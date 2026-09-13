# C45-row4dup4 静态审查

仅源码生成、文本比较和自动身份登记；未本机编译、测试、执行算子、SSH或提交。

- 标准experiment new/checkpoint使用`.runs/.workflow.lock`；本次编辑/补丁/元数据也在同一锁内，仅新候选路径。没有覆盖父版或其它候选。
- 相对父版仅在唯一quad共享中段插入新循环；从新文本移走完整新增块可逐字恢复C26。其它helpers/dispatch/非SVE/invalid代码全部包含在这个恢复比较中。README、bench_conv.c、run.sh逐字节一致。补丁`candidate.patch`只含这个插入，不含其它文件。
- 新块静态包含4次`svld1rq_f32`、16次字面量`svdup_lane_f32`、16次`svld1`、64次`svmul_f32_x`和64次`svadd_f32_x`。q为0→1→2→3显式scope，每q内n0→1→2→3，每n按a/b/c/d更新；没有SVE数组、循环变量lane索引、indexed intrinsic、FMA、asm、prefetch或额外输出存储。
- 数值依赖：对任意r/n，每个t依次累加四个q，跨块仍ik递增4；原两列/单列处理余数。t映射a=t、b=t−1、c=t−2、d=t−3不变。每次仍先独立乘法舍入再加法；跨输出的执行交错不会重关联同一输出的累加链。
- 入口原kw>0，ik始终0..kw；`kw-ik>=4`成立保证ik+3<=kw−1及ik+4<=kw，所以条件与步进不溢出int。kw1/2/3跳过新增块。原2/1余数源码未改，四列退出时余数最多3。
- `svld1rq_f32(pg,kr+ik)`沿用all-true b32，只取当前行四个float即16B，不能越kernel行末；重复128位图样适用于任意合法SVE长度。`svdup_lane_f32(pack,q)`的全向量元素0..3在VL16/32/64及合法SVE最小长度均存在，无算术改变系数。
- 输入列：满块i+4L<=ow，最后n3/q3加载末列i+ik+4L+2；ik<=kw−4使其<=ow+kw−2=inputWidth−1。其它n/q界更小，均在原合法输入行内，不读完整第五向量。
- 输入行仍原共享t=3..kh−1；原首/尾六阶段没有变化，因此quad原最大读取行界、size_t行offset、global输出行距和每输出唯一写沿用父版。新块只增加合法行内指针偏移；不新增size_t乘法、分配或资源扩张。
- 理想26Z值不代表实际活跃集或无spill；DUP→indexed折叠和调度重排需目标汇编确认。若没有新机器码安排，不自动测速。r2的LD1RW采样集中不能归因为已证明的系数缓存瓶颈。

准备源码SHA256：`d428611f068b81befa4412a6bd11480468e3b7816906647d15cc0e9265c866a5`。最终prepared源身份以标准checkpoint record为准。本文件不是编译/正确性或性能通过证明。
