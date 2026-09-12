# TRSM r6 可恢复比较

本轮只负责 TRSM。当前已发布实现 T8-svepanel16；最终 ZIP 已在 r5 作业 1576076 独立跑过三套件。两个 T9 当前只完成准备，未晋级。

## 顺序与状态

1. r6 基线 T8-control12（T8 原样）作业 1579357，目录 `../optimization-20260912-r6/`。旧上传认证失败记录保存在 `upload-attempt-auth-failed/`；恢复会话后确认远端目录不存在才重试上传。已保存唯一 job ID，无重复提交。
2. 调度成功后 collect，检查全部三套件的 9 个 PASS、exit=0、真实 KML25.1/private libgomp 链接和预检完成；通过 TRSM nohash-tools/records-kml.py record、promote 建立本轮基线。
3. 本目录 plan.json 指定 T8-control12-repeat-r6、T9-neondirect、T9-lhistpack。基线晋级前不能执行 prepare；之后 prepare 固化源码和预检，submit 只执行一次，保存 job ID。三轮顺序 ABC/BCA/CAB，各成员均完整三套件、TEST_RUNS=3。
4. 同一分配先运行全部 general preflight，再做 T7/T9-neondirect 的 105 组数值逐位对照。T7 仅为数值参考，不纳入性能成员。正常、尾部、非正尺寸、不同 leading dimension、L/padding 保护、SVE 宽度/能力回退、全部分配失败均覆盖；packed-L 另有新微核与仅共享分配失败检查。
5. collect 完整证据，先用 record --repeat-existing 给当前 T8-control12 增加新的交错 run，保留先前记录，再分别登记 T9。两份 compare 使用共同环境和参考描述。总改善必须超过逐用例波动门槛，各例不能退步超过 1%；性能不明确保留 T8。
6. 查看 GCC12 实际汇编：T9 NEON 历史递增 FMA 与内部独立乘加、临时数组/栈访存；packed-L 历史循环的地址指令与 spill。任何理论判断与实际测量分开记录。
7. 确认稳定胜出后才晋级、创建新的唯一提交包并在计算节点独立验证该包；通过后仅发布 TRSM 内容到用户指定 GitHub。若没有胜出，继续保留当前已验证 T8 包。

## 不变约束

38 CPU / 单 NUMA / 24 GiB / 1800 秒；GCC12.3.1，原 run.sh 浮点 flags，官方尺寸和 1e-12 容差不变。KML25.1 真实头文件与动态链接留证，不等同指定 KML25.2.0 复验；历史 OpenBLAS/GCC10 不参与本轮提速比较。所有编译/测试/汇编生成仅在调度分配节点；本机只编辑、传输和整理日志。不计算或验证哈希，不使用重置卡，不关机，不取消别人的作业，不正式提交比赛。公共工具和其他题目不改。

## 恢复命令（在 kunpeng-s2 根目录）

```bash
python3 tools/cluster.py --config .runs/trsm/optimization-20260912-r6/cluster.local.json doctor
python3 .runs/trsm/optimization-20260912-r6/job_control.py status
# 仅 scheduler SUCCEEDED 后：
python3 .runs/trsm/optimization-20260912-r6/job_control.py collect
# 登记参数从真实环境日志获取，先人工核对所有预检与逐用例结果。
# 完成本轮基线 record 和 promote 后才：
python3 .runs/trsm/optimization-20260912-r6-compare/job_control.py prepare
python3 .runs/trsm/optimization-20260912-r6-compare/job_control.py submit
```

如果连接再次中断，查询已存 job ID；不能直接再次 submit。仅源文件准备或编译成功都不代表正确性与性能通过。所有命令执行与退出码继续写入本轮记录。
