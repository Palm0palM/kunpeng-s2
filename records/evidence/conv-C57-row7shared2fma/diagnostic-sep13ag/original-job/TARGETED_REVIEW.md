# AG C57 原作业：数值可行性失败（FINAL/STOP）

原作业 **1583276** 的 12 次原始检查全部 `FAIL`，没有性能计时。官方容差为 `1e-5`。全部日志、误差样例、进程退出与失败终态保留在 `raw/`；逐次结果和原件 SHA-256 见 `AG_SUMMARY.json`。

| 原例（H×W / kh×kw） | suite 1 最大误差 | suite 2 | suite 3 | 三次结果 / 进程退出 |
|---|---:|---:|---:|---|
| A 4096×6144 / 39×39 | 1.53e-04 | 1.53e-04 | 1.53e-04 | FAIL / 0 |
| B 6144×4096 / 41×41 | 1.83e-04 | 1.83e-04 | 1.83e-04 | FAIL / 0 |
| C 4256×6390 / 55×55 | 3.66e-04 | 3.66e-04 | 3.66e-04 | FAIL / 0 |
| D 6390×4256 / 81×81 | 6.10e-04 | 6.10e-04 | 6.10e-04 | FAIL / 0 |

误差是原日志按 `%.2e` 打印的最大绝对误差，不补造更高精度；每次原日志另保留前 10 个超差位置。三套使用未修改 benchmark 的同一组固定种子；它们不是三个独立随机数据集。官方程序数值失败仍返回 0，因此 `case-exits.txt` 的 12 个 0 不代表 PASS。包装器的 12 个 `PASS_CHECK=1` 正确识别全部 FAIL。失败分支在 warmup/计时前返回，12 行 Time/GFLOPS 均为 `/`。

## 原件与实际编译

- 候选 `C57-row7shared2fma`；源父 `C52-row7x3shared2`（自身 T1582134），没有继承父数值结论。实际 `conv2d.c` SHA-256：`3cc03ec4d13422238b1e461dd7213876cc50283a7433132ee94b41c4724ec6c5`。
- 五个返回源文件与首次 prepared/原 job/远端 source-sha256 逐字节哈希全部一致；prepared 的未执行字段保持历史快照原样。
- 实际 GCC 10.3.1；原 `probe.log` 第 60/78/89 行分别记录 executable / candidate `.s` / reference `.s` 的真实 argv，公共 flags 均为 `-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2`，未开启 fast-math 或全局 contraction。
- 候选 `.s` SHA-256：`fc59d9cdae4461036b6cd95b5e103de2200071cbe7114c66f7d1648209e0fe71`；参考 `.s`：`5a9f06d62832668b1be1305cb89714f1fe8ac92f490899bb652748ea4625178e`。二者由同一原作业、同字节源和同 flags 单独 `-S` 生成；未声称检查 executable 的反汇编。
- 原包装器实际检查 HWCAP_SVE **bit 22**，probe 返回 1；分配 CPU 0..37 共 **38** 个，单 `node0`；OMP 为 38/FALSE/close/cores。

## 目标汇编证据

`conv_sve_rowseven` 实际范围 5890..7163。完整阅读本次 shared 主循环、余列与周围进入/回边；仅做本任务要求的融合定位，不扩展为完整 helper 栈审查。

- 源 1489..1572 的两列 shared 展开对应 `.L421`，实际指令 6451..6531：**42 条 `FMLA`**，21 个不同累加器各更新 2 次；列索引 `x0 += 2`、权重字节偏移 `x2 += 8`，6531 回到 `.L421`。例如 6460 `fmla z19.s, p0/m, z1.s, z11.s`。
- 源 1573..1612 的单列余项对应 `.L423`，6536..6578（中间含 `.L468` 标签）：**21 条 `FMLA`**，同 21 个累加器各 1 次；6547 `x1 += 1`，6577/6578 比较回边。全部四例 kw 为奇数，源路径具有单列余项。
- 全候选 `.s` 的融合乘加/减 opcode 扫描共 **63 条，全部为上述 `FMLA`**，没有其它位置的融合指令。显式 `svmla_f32_x` 在 strict flags 下确实生成融合操作。
- 原参考 outlined 函数 `reference_conv2d._omp_fn.0` 101..199 已完整读：内层 `.L17` 在 **163 `fmul s0,s0,s2` → 164 `fadd s1,s1,s0` → 165 store**，167 回边；全 `bench-reference.s` 融合 opcode 数 **0**。benchmark 的实际 `test_performance` 在 687/688 装载该 outlined 函数，694 调用 `GOMP_parallel`，之后才调用候选 `conv2d`（702）。参考仍为分别舍入的乘法/加法。

这些原件证明本次显式 FMA 方案发生了目标融合，并且没有通过未修改官方参考的容差；不据此宣称提速或一般性的 FMA 可接受性。

## 生命周期

根唯一 submit 的 argv/stdout/stderr/exit 原件为 `.runs/conv/sep13ag-root-submit.*`，root 通知 chunk `2512eb`；command record exit 0，原 ID 1583276。此子任务未提交。

`sep13ag-status-001.*` 保存首次本地 sandbox SSH 权限失败（driver 1 / query 255）；这不是作业结果。77.196263 秒后 `status-002` 外层 exit 0，得到实际 **FAILED / jobExitCode 1 / systemExitCode 10001**。随后 `fetch-001` 首次抓取 exit 0。三次操作的 argv、stdout、stderr、exit、event 原件均保留。

原 stage 顺序为 allocation/compiler/manifest/build/assembly-candidate/assembly-reference 全 0，`numerical-check=1`；wrapper exit **1**。预定第 8 项 `complete` 因数值失败没有出现，实际仅 7 项，不补填完整成功。全部 12 次结果收集完毕；未重跑、accept/freeze、修改 record/best 或晋级。**FINAL/STOP**。
