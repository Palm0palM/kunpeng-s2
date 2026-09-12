# Sep12c 独立正确性诊断

C32-row4lane4staged 已快照，状态为 **prepared，尚未提交**。必须等待根代理确认 C28/C29/C30 正式性能组结束并明确 GO 后，才可使用 config/conv-sep12.local.json 提交。不得与性能测试并行，不降低 SSH 主机校验。

候选从 C29 继承 quad 四行×每行4VL（16个总累加器），仅在四系数共享主循环的 n=1 lane3 后加入一道消费前八个累加器的空 asm memory clobber。EXPECTED_ACC=4 仅表示主 quad 每行向量数；pair/triple 为4VL，prefix 主块为8VL并有尾处理。CHECK_ROWTRIPLE=1、CHECK_ROWQUAD=1；六配置均要求可达 pair/triple/quad 入口非零，prefix/tail 记录实际计数。

完整复用已验收 C29 的独立扩展检查器，包含 kernel (4,5)/(4,6)，覆盖四系数主循环后余1/余2；kw7覆盖余3，kw4/8覆盖整除。每配置 full=3,268+24宽度×16 kernel形状×11高度×4放置组合=20,164，smoke96；1/4线程×SVE16/32/64字节，共 **120,984 full + 576 smoke = 121,560项**。高度1/2/3/4/5/6/7/8/9/12/16包含四行组全部余数，宽度保留多 VL 的4VL/6VL/8VL/12VL边界；smoke宽度1/193/385、kh1..4、kw3/4、oh5、两种pad与两端放置。

输入/kernel只读、两端保护页、输出NaN预填与canary、逐位有序scalar参考及每个worker实际VL检查保持原样。全部算子编译执行仅在调度分配的计算节点；本机只做轻量文件整理、传输和日志读取，不编译或运行测试。编译选项包含 -fno-fast-math -ffp-contract=off；不运行sanitizer，日志记录 NOT_RUN。

## 执行

以下命令须等待明确 GO。提交后立即保存/回报 job ID，复用已有 job.json，禁止重复提交；状态查询间隔30–45秒。

```text
python3 .runs/conv/sep12c-checks/driver.py C32-row4lane4staged config/conv-sep12.local.json submit
python3 .runs/conv/sep12c-checks/driver.py C32-row4lane4staged config/conv-sep12.local.json status
python3 .runs/conv/sep12c-checks/driver.py C32-row4lane4staged config/conv-sep12.local.json fetch
```

沿用38CPU单NUMA、24GiB及1800秒上限。wrapper在任何编译前检查Linux/AArch64及计算分配。fetch仅取回文本、源码、汇编；取回本身不表示通过。

## 验收与汇编

调度 ID 匹配、SUCCEEDED且job/system退出0，wrapper退出0和PROBE_COMPLETE；六配置恰20,164 full+96 smoke，线程/VL/每行主块正确，可达入口计数非零。沿用自动传输manifest与远端wrapper SHA匹配，不额外重复人工哈希审计。完整验收才将 validation.complete 置为 true；所有失败保留，不修改原始日志、容差或候选源码。

重点读真实四系数主循环：总指令、64 indexed FMUL和64独立FADD、4 LD1RQ、输入窗口加载、indexed系数寄存器低Z分布、各lane次数、movprfx/ext/dup、向量栈读取与写入、全源码FMA。检查单道编译器屏障是否实际消除C29的两个累加器spill；不能从源代码或asm为空直接假定消除。区分循环内向量spill、循环边界装载与外层标量/ABI保存；记录每迭代处理四个kernel列，不与单列/双列循环直接比较原始指令数。无spill不代表更快，有spill但正确性通过仍可交根代理正式测量。

通过后冻结本候选全部诊断到 .runs/conv/C32-row4lane4staged/sve-correctness-sep12c/，附 driver/README 及原 .s 的同字节 .assembly.txt 与复制来源说明；保留所有原始证据。当前没有为本包创建作业。
