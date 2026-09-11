# TRSM r4：24 行更新与紧凑对角块

2026-09-11 从已发布 T5-sve16rows 出发。新测量对照 T5-control10（无 parent、源码不变），两个独立子候选 T7-sve24rows 与 T7-diagpanel，不混合策略。所有候选源码保留在独立 .runs/trsm/<id>/source；不改 CONV、ZGEMM、公共工具。

复用已存在的 SSH ControlMaster，cluster.py doctor 已成功识别登录节点及 dsub/djob。唯一作业 1522032 已保存于 cohort-submission.json；后续仅恢复查询，禁止重交。38 核、单 NUMA、24 GiB、1800 秒，三成员按 ABC/BCA/CAB 轮换，各三轮完整官方套件，每样本 TEST_RUNS=3。OpenBLAS 静态库与线程/绑定/编译环境明确记录；所有计算在调度分配节点执行。

预检覆盖实际 SVE24 入口和 30 个 count/stride 组合×1/4线程；两个候选各29个已知解/leading dimension/列尾/行尾用例×正常1/4/38线程、强制分配失败4线程、禁用SVE4线程，总共290次已知解和40次空尺寸调用。对角面板另有50个非二进制精确输入的直接blocked路径测试×1/4线程，以long double构造右端项，验证FMA舍入后精度与padding。直接blocked单元检查不改变提交版本的64 MiB入口预算。

KML探测扩大到 /opt、/usr/local、/usr/lib64、/usr/include、/home/HPC 以及可见的应用/软件共享目录；每个现存目录搜索深度8、限时15秒。记录模块/头文件/链接实际结果，不能将未找到某些路径推断成全超算未安装。若仍不可用，本轮明确为OpenBLAS环境，不冒充官方KML复验。

本轮不计算或验证哈希；使用现有experiment.py纯解析器、调度状态判定与TRSM专用无哈希登记/比较流程，不调用其内置摘要例程。源码与日志原件仅以本地字节快照保留，不声称远端源码或传输完整性经过校验。只有完整成功且同环境提速超过观测波动、没有用例退步超过1%，才晋级；否则保留当前T5及已有发布包。
