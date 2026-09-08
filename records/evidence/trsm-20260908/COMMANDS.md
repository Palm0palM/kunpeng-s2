# TRSM 本轮实际测量命令

此清单是已执行步骤的可复核重放说明；现有 cluster.json 禁止重复提交同一目录。复测使用新的独立 run ID，不能覆盖原日志。

```bash
python3 tools/cluster.py doctor
python3 tools/cluster.py submit .runs/trsm/T0
python3 tools/cluster.py status .runs/trsm/T0
python3 tools/cluster.py fetch .runs/trsm/T0
python3 tools/experiment.py record trsm T0 --log .runs/trsm/T0/benchmark.log --environment COMPUTE_NODE_1-gcc10.3.1-generic-38-openmp --reference 'OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0' --repeats 3
python3 tools/experiment.py promote trsm T0
python3 tools/cluster.py submit .runs/trsm/T1-panel
python3 tools/cluster.py status .runs/trsm/T1-panel
python3 tools/cluster.py fetch .runs/trsm/T1-panel
python3 tools/experiment.py record trsm T1-panel --log .runs/trsm/T1-panel/benchmark.log --environment COMPUTE_NODE_1-gcc10.3.1-generic-38-openmp --reference 'OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0' --repeats 3
python3 tools/cluster.py submit .runs/trsm/T0-r1
python3 tools/cluster.py status .runs/trsm/T0-r1
python3 tools/cluster.py fetch .runs/trsm/T0-r1
python3 tools/experiment.py record trsm T0-r1 --log .runs/trsm/T0-r1/benchmark.log --environment COMPUTE_NODE_1-gcc10.3.1-generic-38-openmp --reference 'OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0' --repeats 3
python3 tools/cluster.py submit .runs/trsm/T1-panel-r1
python3 tools/cluster.py status .runs/trsm/T1-panel-r1
python3 tools/cluster.py fetch .runs/trsm/T1-panel-r1
python3 tools/experiment.py record trsm T1-panel-r1 --log .runs/trsm/T1-panel-r1/benchmark.log --environment COMPUTE_NODE_1-gcc10.3.1-generic-38-openmp --reference 'OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0' --repeats 3
python3 tools/cluster.py submit .runs/trsm/T1-colreuse
python3 tools/cluster.py status .runs/trsm/T1-colreuse
python3 tools/cluster.py fetch .runs/trsm/T1-colreuse
python3 tools/experiment.py record trsm T1-colreuse --log .runs/trsm/T1-colreuse/benchmark.log --environment COMPUTE_NODE_1-gcc10.3.1-generic-38-openmp --reference 'OpenBLAS 0.3.28 static; USE_OPENMP ARMV8; SHA256=c1bb71567c95b7cdff011ecd65b1d10de9001d373a5e87ac6468d7b9755c0ed0; not official KML 25.2.0' --repeats 3
python3 tools/experiment.py compare trsm T0 T1-panel
python3 tools/experiment.py compare trsm T0-r1 T1-panel-r1
python3 tools/experiment.py compare trsm T0 T1-panel-r1
python3 tools/experiment.py compare trsm T0 T1-colreuse
python3 tools/experiment.py compare trsm T1-panel T1-colreuse
```

完整远端 dsub 参数、资源、目录与 job ID 见 benchmark-command-replay.json；参考环境脚本及专用作业、实际链接与 wrapper 身份见本目录其他证据。

准备阶段将两原实验的 TEST_RUNS 从未指定（runner 默认 1）统一显式设为 3；bench_repeats 保持 3。修改前元数据保存在 T0-experiment-before.json 和 T1-panel-experiment-before.json，实际设置在各作业 cluster.json。源码和 run.sh 未改变。

最初本地准备检查把非源码文件也计入目录比较而触发断言；随后按 experiment.py 的 source_files 集合逐字节复核，确认 T0 与当前 trsm/ 完全相同，T1-panel 仅 trsm.c 不同。未因此改动源码或测试条件。

首次未提权 doctor 因本机沙箱限制不能访问控制套接字，随后授权网络执行成功；未发生认证失败。直接只读探测 COMPUTE_NODE_1 因登录节点无法解析该主机名失败，已保留日志，随后用受调度作业 1485185 完成计算节点环境检查。
