# C48 M 单包执行与留痕计划

当前仅 prepared，未编译/测试/SSH/提交；无需本机计算。仅冻结五文件 `source/` 和两种manifest，保留 [矩阵设计](DIAGNOSTIC_DESIGN.md) 与 [静态审阅](STATIC_REVIEW.md)。源父是 C40-row6x3u1，独立生产源 C48-row8x2u1 的初次复制 SHA 为 `8623781dc784547e31b07facd65507b56ff40f6b5da3e617c1ef53f4a4f7f7c3`。没有改候选源或其他版本。

源/包装沿已审 guard模式，仅实际 C48 身份、8行2VL接口、矩阵和计数改动。19阶段依次 allocation/compiler/manifest/build-guard、六个guard、build-dispatch、六个dispatch、build-assembly/complete。资源要求38CPU、24GiB、单NUMA；后续公共driver负责固定1800秒、实时串行门槛和唯一job。当前包不含driver/acceptance，不授权新compute。

包装要求 GCC10.3.1；公共 flags为 `-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=2`。三条实际构建依次为guard+conv2d.c、独立 `-finstrument-functions` dispatch、未插桩conv2d.c的 `-S`。EXPECTED_ACC是每行向量数；无四行宏、FMA、fast-math、LTO、tune、bench或runner。两检查程序仅一个VL字节argv。

后续记录策略：实际 `job.json` 必须先唯一reservation，不明提交不得重提；原source/prepared/manifest不刷新。保存编译版本和三个实际GCC xtrace、逐阶段退出、全部6组guard/dispatch/direct日志、原生产.s、job/system/wrapper退出。成功计划为41664项；失败只记真实已知结果，不补阶段/速度/PASS。普通解析失败单独留痕，不改原日志或假称算子失败。旧C40/C47记录不提供本候选验证。

待真实目标产物后逐15阶段及完整分派审查，允许如实记录spill；数值通过不等同提速。任何性能对照、独立确认、原ZIP验证和晋级由根代理另行授权；本包只prepared，不自动延续任务，也不消耗重置卡。
