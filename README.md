# 鲲鹏 S2：三题协作与实验记录

项目仓库：[Palm0palM/kunpeng-s2](https://github.com/Palm0palM/kunpeng-s2)；个人协作镜像：[abuyabislital987-afk/kunpeng-s2](https://github.com/abuyabislital987-afk/kunpeng-s2)。目标是让 Agent 完成“提出方案 → 修改候选 → 超算测试 → 留存结果”，两人从共同基线尝试不同方法；比赛平台的正式提交由本人负责。

`conv/`、`zgemm/`、`trsm/` 保存当前晋级版本。现有版本的验证范围与环境见 [基线说明](docs/BASELINES.md)，不要把历史测试直接当作当前排行榜成绩。

TRSM 最新提交包：**T19 = T19-panel8x16budget**，队友在 KML25.1/GCC12 同分配三轮较 T8 合计耗时减少 **29.58%**；最终原 ZIP 独立解压三轮 **9/9 PASS**，合计中位耗时 **317.01 ms**。[直接提交 T19/trsm.zip](trsm/result/T19/trsm.zip) · [最终交付与 KML 状态](docs/trsm-final-20260912-r16.md)。指定官方 KML25.2.0 复验仍未完成。

**提交入口：[三题当前最佳提交包](SUBMISSIONS.md)。** 当前仅提供 CONV C6、ZGEMM Z1、TRSM T19；各题 result 目录保留版本说明、验证范围与平台反馈字段。

CONV 七行方案 C51 在独立确认中合计耗时减少 **2.96%**，36/36 校验通过；结束 C6 对照的一项波动为 **5.35%**，未通过确认门槛，当前继续提供 C6。所有慢样本保留，没有生成 C7 包。[独立确认完整记录](docs/CONV_SEP13S.md) · [此前初筛](docs/CONV_SEP13R.md)。

CONV 新候选 C52 仅将七行内核的共享列循环展开两列，专项37128/37128通过；独立 W 初测48/48通过，对两端C6耗时减少 **3.54% / 3.45%**，达到初筛门槛，下一步独立确认。对C51参考版的0.51%改善未过1%门槛，暂不归因于展开收益；仍提供C6。[专项记录](docs/CONV_SEP13T.md) · [48个完整样本与门槛](docs/CONV_SEP13W.md)。

## 先把环境跑通

1. 安装 Python 3，并确保本机可以使用 Git、SSH。本机配置位于 `config/cluster.local.json`；服务器主机密钥已按用户确认更新到 `config/known_hosts.local`。不要把密码、私钥、令牌写进仓库。
2. 本轮已恢复 SSH 认证并建立约一小时的复用会话，Agent 可以直接检查连接、提交与取回作业，无需用户操作终端：
   ```bash
   python3 tools/cluster.py --config config/cluster.local.json doctor
   ```
   目标服务器为 `CLUSTER_HOST`，本次登录节点为 LOGIN_NODE_1。会话失效时先检查 VPN，再按用户授权的认证方式恢复，不把密码写入仓库。`tools/connect.py` 是可选的交互登录辅助工具。
3. 给 Agent 使用 [启动提示词](prompts/optimize.md)。最新分工为本任务负责 CONV，用户另开任务负责 [ZGEMM](prompts/zgemm.md) 和 [TRSM](prompts/trsm.md)；每题使用独立实验目录与作业 ID，禁止取消他人作业。

本地工作分支为 `setup/agent-workflow`；`origin` 保留上游仓库，`personal` 指向当前账号的仓库。个人仓库用于保存协作镜像，项目成果通过 Pull Request 提交到项目仓库。

CONV 最新最佳版本、父子关系和耗时见 [晋级台账](records/conv-lineage.json) 与 [本轮逐版本记录](docs/CONV_ROUND_RECORDS.md)；本轮已确认显式 SVE 优化产生稳定提速。候选失败与退化也完整留档，[此前实验](docs/CONV_RESULTS.md) 保留作历史对照。提交包对应的源码校验见 [包清单](outputs/conv-best.json)，记录及公开导出方式见 [记录说明](docs/CONV_RECORDING.md)。

2026-09-12 最新 CONV 为 **C6 = C26-r1**（来源 C26-row4loads）：四行共享方案采用直接加载移位窗口，调整输入加载与寄存器使用。同资源 C5 对照从 **502.35 ms 降至 452.62 ms（减少 9.90%）**。最终 ZIP 在超算解压并完成三轮独立复验，12/12 PASS、最大误差为零，包验证合计 **452.66 ms**。

**直接提交 [conv/result/C6/conv.zip](conv/result/C6/conv.zip)**，无需重新压缩。当前仅保留最佳提交包，此前测量与策略继续保留。[本轮完整报告](docs/CONV_SEP11C.md) · [逐版本记录](docs/CONV_SEP11C_ROUND_RECORDS.md) · [C5 历史报告](docs/CONV_SEP11B.md)。以上是内部指标，正式平台分数待队友手动提交后反馈。

## 先重测当前基线

历史 C0/Z0/T0 仅作起点，必须先在当下机器完成三轮测量。第一次创建 C0 **不加 `--parent`**，保持源码不变：

以下是新环境示例，已有目录应直接恢复。当前 CONV 首次运行 C0 因运行器解析空 CPU 列表失败，已修复并保留失败记录，重试编号为 C0-r1；候选 C1-block 基于这次重试比较。

```bash
python3 tools/experiment.py new conv C0 --strategy "当前代码基线复测"
python3 tools/cluster.py --config config/cluster.local.json submit .runs/conv/C0
python3 tools/cluster.py --config config/cluster.local.json status .runs/conv/C0
python3 tools/cluster.py --config config/cluster.local.json fetch .runs/conv/C0
```

`status` 每次查询一次，可中断后用已有作业 ID 恢复查询；成功完成后再 `fetch`。不要因为等待或断线重复提交。wrapper 独立执行三轮完整用例，`--repeats 3` 指这三轮，**不等于 benchmark 内部的 `TEST_RUNS`**。

登记固定的下载日志并建立当下机器基线。下面的环境 ID 仅适用于实际记录确为该节点和编译配置的情况，否则如实替换：

```bash
python3 tools/experiment.py record conv C0 --log .runs/conv/C0/benchmark.log --environment COMPUTE_NODE_1-gcc10-generic-38 --reference "官方内置参考" --repeats 3
python3 tools/experiment.py promote conv C0
```

ZGEMM 的 Z0、TRSM 的 T0 同理；参考库必须填写实际版本，尤其不能把 OpenBLAS 写成官方 KML。

## 再开始优化候选

```bash
git switch -c conv/c1-alice
python3 tools/experiment.py new conv C1-alice --parent C0 --strategy "调整分块尺寸，减少工作集占用；其余条件保持与 C0 一致"
```

只改 `.runs/conv/C1-alice/source/`，然后按基线相同流程对该目录执行 `submit`、`status`、`fetch`，完成三轮后登记与比较：

超算计算节点正确性检查完成后，可执行 `python3 tools/experiment.py checkpoint conv C1-alice --note "校验结果与待测事项"` 保存待测候选；创建时记录 planned，准备完成记录 prepared，失败也保留。

```bash
python3 tools/experiment.py record conv C1-alice --log .runs/conv/C1-alice/benchmark.log --environment COMPUTE_NODE_1-gcc10-generic-38 --reference "官方内置参考" --repeats 3
python3 tools/experiment.py compare conv C0 C1-alice
python3 tools/experiment.py report
```

所有用例正确且同环境复测确认提速后，再执行 `python3 tools/experiment.py promote conv C1-alice`。晋级保留候选来源；下一轮两人共同从该版本出发。正式编号与协作约定见流程文档。

## 文件放在哪里

| 位置 | 内容 |
| --- | --- |
| 三个题目目录 | 当前已晋级的题解与运行文件 |
| `.runs/题目/版本/source/` | 本地候选源码；实验完成后保留快照，不纳入 Git |
| `.runs/题目/版本/` | 作业信息、下载日志与临时产物；不纳入 Git |
| `records/history.json` | 版本关系与实验索引 |
| `records/experiments/` | 每个版本的策略、环境、测量与判定 |
| `AGENTS.md` | Agent 必须遵守的优化与记录规则 |

GFLOPS、耗时和正确性来自测量；官方评分与排名算法待确认。总毫秒数仅作内部比较，不标成官方分数。

## 公开记录说明

此副本已替换个人目录、计算账号、内网地址与内部节点名。公开日志不再是原始字节证据；保留的原始哈希仅用于核对本地原件，详见 [公开说明](PUBLICATION.md)。不要将这些脱敏日志直接用于原件完整性校验或重新晋级。


CONV 2026-09-12：C28/C29/C30 三候选完成361,512项专项及60/60性能用例；均未达到晋级门槛，正式提交仍用C6。C30约1.04%的初步改善低于对照2.02%的波动，全部样本保留，见[本轮记录](docs/CONV_SEP12B.md)。


CONV 2026-09-12 后续复测：C30-r1与C32同资源12套件48/48 PASS；C30-r1仅减少0.97%，C32增加10.62%，均不晋级，正式提交继续用C6。完整样本及C32的121,560项专项见[后续记录](docs/CONV_SEP12C.md)。


CONV 五行共享 C33：250,008项专项及同资源9套件36/36性能用例全部通过，但467.13ms比C6的452.38ms增加3.26%，不晋级，仍交付C6。全部样本见[本轮记录](docs/CONV_SEP12D.md)。

CONV 访问与调度三方案：419,076项专项和18套件72/72性能用例全部通过。C34比同轮C6慢4.66%，C35/C36差异不足0.1%，均未晋级；C30-r2仅作归因对照。正式提交仍为C6，[全部样本与结论](docs/CONV_SEP12E.md)。

CONV 单列循环与编译调优：同资源15套件60/60 PASS；C37/C39比C6慢1.58%/1.62%，C38拆分构建仅作对照，无确认收益。另有152,688项专项及原runner的8个用例通过，继续交付C6。[完整记录](docs/CONV_SEP12F.md)。

CONV 六行/五行分块：同资源12套件48/48 PASS，专项共53,520项通过。C40比C6快1.78%，仍低于前后对照的波动门槛；C41慢4.22%，C42因GCC10不接受汇编操作数格式而编译失败、零项数值执行。继续交付C6，完整样本与2,666个quad热点样本见[本轮记录](docs/CONV_SEP12G.md)。

## CONV J/K 独立确认

CONV 六行方案追加两组独立测量，共18套件72/72 PASS、误差为零。J 轮比 C6 快1.737%，达到复测门槛；K 轮快1.763%，但候选自身波动2.738%，未通过独立确认。全部样本保留，继续交付 C6；没有生成 C7 提交包。[完整记录](docs/CONV_SEP12K.md)。

## CONV 输入复制与行距对照

CONV 输入复制与行距对照完成：434,352项专项检查及12套件48/48性能用例全部通过，但C43调整行距比C6慢4.10%，C44只复制输入慢4.29%；C43/C44差异也未达到行距收益门槛。全部样本和退化策略已留档，继续交付C6。[完整记录](docs/CONV_SEP12H.md)。
