# TRSM 提交包 — T19-panel8x16budget

解压后进入 `trsm/`，仅在调度分配的 Linux aarch64 鲲鹏计算节点运行，使用不超过38核的单NUMA分配。

```bash
unset KBLAS_LIB
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
export CPU_TARGET=generic TEST_RUNS=3
bash run.sh
```

需要 GCC/OpenMP、numactl 和 KML/kblas。原 runner 默认链接 `-lkblas`，使用 close/cores 绑定；其指定模块可用时按原配置加载。`TEST_RUNS=3` 是每用例内部计时次数，三个独立完整套件须在同一分配下执行三次原 run.sh。

小路径保留T18的4MiB共享历史副本预算与整数溢出保护。当原SVE条件成立、历史字节数安全可算且超过预算时，T19改用8行×16列SVE历史前代核；每个线程分配一个对齐缓冲区，容纳两个连续的m×8 RHS面板。完整16列任务使用新核，不完整列任务保留原RHS8核；尾行、无SVE、窄向量宽度和分配失败继续各自原NEON/标量路径。预算内共享分配失败仍走旧路径，不能以NULL指针代替超预算条件。4MiB是实现预算，不代表机器缓存容量。原64MiB整算法选择不变。

大路径完整继承T18原实现（最初来自T13）：KB256、CT64，完整32列处使用4×32 SVE更新核，保留尾部和分配失败回退。SVE要求Linux GCC支持、真实HWCAP与每个worker恰好八double向量宽度。保留lda/ldb、L只读、非正维度行为，不按官方精确尺寸分派；算子本身不调用BLAS。

T19准备时来源T18尚未晋级。来源关系不代表通过验证；本包只在T19-panel8x16budget本身已实际验证、晋级且仍为当前TRSM best时生成，不混入其它候选或不同作业成绩。

实际晋级源码验证作业为 **1579861**：三个独立完整官方套件9/9 PASS，原精度要求1e-12；结果从当前有效晋级记录读取。

| M×N | 三轮报告均值的中位数 ms | 最大误差 |
| --- | ---: | ---: |
| 512×19968 | 14.56 | 1.67e-16 |
| 2432×17024 | 118.82 | 2.22e-16 |
| 17024×512 | 179.82 | 1.11e-15 |

合计中位数为 **313.20 ms**，仅为内部耗时指标，不是官方分数或排名。该源码测量不能代替最终ZIP的独立解压复跑，也不把最终包测量用于重新计算策略增益。

实际已验证环境为 **Huawei KML25.1.0 / GCC12.3.1**，真实KML头文件、默认-lkblas及私有libgomp；**不等同指定官方KML25.2.0复验**。原benchmark、输入、计时区、1e-12容差和runner保持原样。兼容头仅供显式覆盖分支；包内没有参考库二进制。

最终ZIP独立计算节点复验和交付清单由仓库 `outputs/trsm-best.json`、`docs/trsm-final-20260912-r16.md` 单独记录。未正式提交比赛，未在本机运行题目，未计算或验证哈希。

最终ZIP独立计算节点复验：作业 **1581516**，三个完整套件9/9 PASS，中位数合计 **317.01 ms**；实际KML25.1/GCC12，非指定KML25.2复验。详见 [最终交付](../docs/trsm-final-20260912-r16.md)。
