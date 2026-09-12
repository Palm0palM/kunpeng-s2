# C33 五行分组独立诊断

已获根代理 GO；仅调度计算节点编译执行，配置 config/conv-sep12.local.json，不重复提交且不与性能并发。本机仅编辑、传输、取日志，不用重置卡。

复用 C32 的全部原检查，扩展 kernel 为23种（新增5×1..6、6×5），输出高度17种：1..12中保留1..12，另14/15/16/19/20；实际数组为1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,19,20。24扩展宽度保留4VL/6VL/8VL/12VL边界。full=3268+24×23×17×4=40804/配置。smoke宽度1/193/385，kh1..6，kw3/4，oh5/6/7/8/9/20，pad两种和保护页两端，共864/配置。六配置1/4线程×SVE128/256/512位，总250008项。20输出行覆盖四worker五行组；余1..4分别由oh6..9及其它full高度覆盖；kh4/5/6覆盖quint回退和真实主块。

新增conv_sve_rowquint实际函数入口计数，六组要求pair/triple/quad/quint均非零。源码对应kh>=5且ow>=4VL时执行五行×4VL主块，共20累加器，EXPECTED_ACC=4；入口计数与smoke参数共同证明主块可达。输入/kernel只读、保护页、输出NaN/canary、有序scalar逐位对照、worker实际VL、strict FP编译选项保持原样，sanitizer未运行。

命令：python3 .runs/conv/sep12d-checks/driver.py C33-row5x4u1 config/conv-sep12.local.json submit|status|fetch（分别执行）。提交立即记录job ID，每约60秒查询一次。验收调度SUCCEEDED、job/system/wrapper退出0、PROBE_COMPLETE、六组40804full+864smoke、VL/线程/入口、自动manifest与远端SHA一致。实读quint单列九阶段汇编，记录FMA/向量spill/指令数/加载，不据此假设提速。全部通过才complete=true并冻结到候选sve-correctness-sep12d。失败保留证据，未完成保留job ID可恢复；不得重新提交旧job。
