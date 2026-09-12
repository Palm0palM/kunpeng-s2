# TRSM KML 25.1 / GCC 12.3.1 无哈希登记工具

`records-kml.py` 是本轮 TRSM 专用工具，复制并扩展同目录 `records.py`。原文件和公共 `tools/` 均未修改。只复用 `tools/experiment.py` 的纯日志解析、机器信息解析、调度器成功判断、工作流锁和 JSON 写入函数，不调用其计算或验证哈希的命令。

它专门接受真实 KML 25.1.0 头文件、默认 `-lkblas` 链接、私有 GCC 12.3.1/libgomp 的新测量。OpenBLAS 历史记录继续使用原工具；不能与本轮跨环境比较，也不能把本轮记录称为官方 KML 25.2.0 复验。

## 输入与运行时环境

每个独立实验目录保留 `experiment.json`、`source/`，以及以下六份取回的原始证据：

- `benchmark.log`
- `environment.log`
- `exit-code.txt`
- `scheduler-status.txt`
- `cluster.json`
- `linkage.log`

取回后 `cluster.json.settings` 使用计算节点实际环境记录，不能只保留提交前白名单过滤后的配置。`settings.bench_repeats` 必须为 3；`settings.environment` 的值按字符串审计。

固定设置为 `KBLAS_LIB=""`、`TEST_RUNS=3`、`OMP_NUM_THREADS=38`、`OMP_DYNAMIC=FALSE`、`OMP_PROC_BIND=close`、`OMP_PLACES=cores`、`CPU_TARGET=generic`。`CC` 可为 `gcc` 或 `COMPILER_ROOT/bin/gcc` 的绝对路径。

必须额外记录下列非空环境键，并在 `environment.log` 中逐行输出实际 `KEY=value`。固定设置也需如此输出；相同键重复出现时只能有相同值。

| 键 | 约定 |
| --- | --- |
| `KML251_ROOT` | 绝对路径，目录名 `KunpengHPCKit-kml.25.1.0` |
| `KML251_ARCH` | `sme`、`sve` 或 `neon` |
| `KML251_LIBDIR` | `KML251_ROOT/gcclib/KML251_ARCH/kblas/multi` |
| `COMPILER_ROOT` | 私有编译器绝对路径；路径包含 `compiler-private` 目录，末级目录含 `12.3.1` |
| `GOMP_LIBRARY` | `COMPILER_ROOT/lib64/libgomp.so.1.0.0` 的真实绝对路径 |
| `CPATH` | 首项为 `KML251_ROOT/include`，确保默认分支可找到实际头文件 |
| `LIBRARY_PATH` | 包含所选 `KML251_LIBDIR` 和 `COMPILER_ROOT/lib64`；不含 OpenBLAS 路径 |
| `LD_LIBRARY_PATH` | 同上，完整值记录并参与比较 |
| `COMPILER_VERSION` | 实际 `gcc --version` 首行，包含独立版本号 `12.3.1` |

路径以计算节点路径为准，在本机仅做文本检查，不用本机 `resolve()` 解释远程路径，也不计算文件摘要。每套件原 runner 打印的 `Compiler:` 必须等于 `COMPILER_VERSION`，`CPUs=... NUMA=... threads=38` 必须与机器证据一致，且走 `Reference BLAS: official kblas` 默认分支。这里保留的是原 runner 的原文，结构化记录另明确实际为 KML 25.1.0。

## linkage.log 精确格式

由计算节点在每套件完成后对该成员本次生成的 `trsm_test` 运行 `ldd`，并立即在同一节点解析所加载路径的 `realpath`。日志恰好有三个按 1、2、3 排列的块，块外只允许空白。每块内列出的元数据键只能出现一次。

```text
LINKAGE_REPEAT 1/3 BEGIN
JOB_ID=实际调度器数字ID
BINARY=/实际成员目录/source/trsm_test
LDD_EXIT_CODE=0
这里逐字保存完整 ldd 标准输出和标准错误
KML251_LINKED_LIBRARY=/实际KML251_LIBDIR/libkblas.so.25.1.0
GOMP_LINKED_LIBRARY=/实际COMPILER_ROOT/lib64/libgomp.so.1.0.0
KML251_DEPENDENCY_AUDIT_PASS=1
LINKAGE_REPEAT 1/3 END
```

其余两块使用 `2/3` 和 `3/3`。上述中文与占位路径只说明格式，不能写入测量证据。`JOB_ID` 要与 `cluster.json` 和成功调度器状态中的数字一致，三个块的 `BINARY` 必须为同一路径。

原始 `ldd` 每块需恰好一条 `libkblas.so.25.1.0 => 路径 (0x地址)` 和一条 `libgomp.so.1 => 路径 (0x地址)` 映射。前者原始加载路径须在所选 `KML251_LIBDIR`；后者须在 `COMPILER_ROOT/lib64`。原始路径允许对应 SONAME 符号链接或真实版本文件名；目标节点 `realpath` 结果必须精确匹配实际 KML 25.1 和私有 libgomp 的约定路径。拒绝 OpenBLAS、`not found`、非零 `ldd` 退出码、重复映射、缺块和不同作业的日志。

每个 `benchmark.log` 仍保留原 cohort 标记：

```text
BENCH_REPEAT 1/3 BEGIN COHORT=实际ID MEMBER=实际版本
原 runner 的完整原始输出
BENCH_REPEAT 1/3 END
```

同样必须有 2/3 与 3/3；每块恰好一套完整官方尺寸及 PASS 行。计时、输入、精度和 benchmark 均不能调整。

## 登记、比较和晋级

命令形式与原 TRSM 无哈希工具一致：

```bash
python3 .runs/trsm/nohash-tools/records-kml.py record .runs/trsm/版本 --environment '实际共同环境描述' --reference 'KML 25.1.0，真实头文件与默认 -lkblas，尚未完成官方 KML 25.2.0 复验'
python3 .runs/trsm/nohash-tools/records-kml.py compare 基线版本 候选版本
python3 .runs/trsm/nohash-tools/records-kml.py promote 通过判定的版本
```

登记保存六份证据和四份必要源码的 `nohash-recorded-evidence/` 快照，使用直接字节比较检查本地快照与输入未变化。它不验证远程源码身份、传输完整性或任何历史哈希。原 benchmark 和 runner 的本地字节必须与当前 `trsm/` 一致。

只有调度器、wrapper、三轮全部 9 个官方用例、精度不超过 `1e-12`、单节点 38 CPU/38 线程设置、真实依赖和运行时环境审计都通过，才可标记 `verified=true`。记录固定保留 `official_kml252_revalidated=false`；依赖证据不足时不填写已验证的实际参考版本。

比较必须是相同机器、环境描述、参考库描述、全部原设置及上述 KML/编译器键；逐用例取三套件报告均值的中位数，总耗时改善须严格超过 `max(1%, 基线及候选全部用例的跨度百分比)`，且没有用例退化超过 1%。只允许晋级不同实现。

无 parent 的新基线必须与当前 `trsm/trsm.c` 直接字节相同。子候选的 parent 必须是当前 TRSM best，当前内核必须与该父版本快照一致，且同环境比较通过。晋级只复制 `trsm.c`、更新 `records/best.json` 的 `trsm` 项及该 TRSM 记录，保留其他题目状态。

准备阶段只编辑了本工具并做 Python AST 静态语法检查，没有运行题目编译、正确性测试或 benchmark，没有联网、登记、比较或晋级任何测量。
