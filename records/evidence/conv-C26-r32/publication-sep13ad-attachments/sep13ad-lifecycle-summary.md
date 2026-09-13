# AD 原1582956生命周期结果

原作业SUCCEEDED，四成员job/system/wrapper全0；status四次、record-group一次和compare一次均退出0，stderr均空。全部48逐例PASS、max_error=0，12份套件总结各4PASS。没有首次生命周期失败、重投或重测。

C55初筛两端false，C6保留。C55总中位466.81ms，对前/后C6为负收益；A/C/D中位均退化超过1%，并非仅因D慢样本波动未过门槛。C55 D的275.28/238.56/238.72全部保留。C52-r3数值比较虽eligible，仍仅参考、qualified=false，Y/S失败及AB C54false不改写。

实际GCC10.3.1/generic，38线程、24576MiB、1 packed NUMA；COMPUTE_NODE_1/NUMA2/CPUs76–113，四成员机器一致。完整设置、来源AC1582860/T1582134及真实退出见JSON。没有本机算子、确认、新包或晋级。

|版本|A 三样本 ms|B 三样本 ms|C 三样本 ms|D 三样本 ms|总中位 ms|最大spread %|
|---|---|---|---|---|---:|---:|
|C26-r32|51.45 / 51.45 / 51.39|61.88 / 61.94 / 62.12|107.30 / 107.30 / 107.38|231.66 / 231.72 / 231.78|452.41|0.387471747|
|C55-row7x3shared3|55.36 / 55.47 / 55.47|60.97 / 60.95 / 60.96|111.68 / 111.64 / 111.66|275.28 / 238.56 / 238.72|466.81|15.382037534|
|C52-r3|51.74 / 51.70 / 51.78|58.42 / 58.49 / 58.42|103.86 / 103.98 / 103.92|222.73 / 223.12 / 222.77|436.85|0.175068456|
|C26-r33|51.50 / 51.45 / 51.39|61.98 / 61.95 / 61.86|107.39 / 107.32 / 107.38|231.64 / 231.97 / 231.88|452.66|0.213799806|

A=4096×6144,k39×39；B=6144×4096,k41×41；C=4256×6390,k55×55；D=6390×4256,k81×81。样本顺序为原套件顺序。

|比较|总收益 %|门槛 %|各case收益 % A/B/C/D|eligible|
|---|---:|---:|---|---|
|C55-row7x3shared3 vs C26-r32|-3.182953516|15.382037534|-7.813411079 / 1.582176300 / -4.063373719 / -3.020887278|false|
|C55-row7x3shared3 vs C26-r33|-3.125966509|15.382037534|-7.813411079 / 1.598062954 / -3.985844664 / -2.949801622|false|
|C55-row7x3shared3 vs C52-r3|-6.858189310|15.382037534|-7.209122536 / -4.347826087 / -7.448036952 / -7.159850967|false|
|C52-r3 vs C26-r32|3.439358104|1.000000000|-0.563654033 / 5.682918954 / 3.150046598 / 3.862420162|true|
|C52-r3 vs C26-r33|3.492687668|1.000000000|-0.563654033 / 5.698143664 / 3.222201527 / 3.928756253|true|

两端门槛严格为gain>max(1%,双方全部case spread)，任何case退化≤1%。本报告只复制原record/compare结果，未修改门槛或样本。完整各case中位/min/max/spread/GFLOPS及真实原PASS行均保存JSON。

外层文件（含本JSON/MD）：

- `.runs/conv/sep13ad-lifecycle-compare.json`
- `.runs/conv/sep13ad-lifecycle-compare.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-compare.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-record.json`
- `.runs/conv/sep13ad-lifecycle-record.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-record.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-status-001.json`
- `.runs/conv/sep13ad-lifecycle-status-001.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-status-001.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-status-002.json`
- `.runs/conv/sep13ad-lifecycle-status-002.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-status-002.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-status-003.json`
- `.runs/conv/sep13ad-lifecycle-status-003.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-status-003.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-status-004.json`
- `.runs/conv/sep13ad-lifecycle-status-004.stderr.txt`
- `.runs/conv/sep13ad-lifecycle-status-004.stdout.txt`
- `.runs/conv/sep13ad-lifecycle-submit-origin.json`
- `.runs/conv/sep13ad-lifecycle-summary.json`
- `.runs/conv/sep13ad-lifecycle-summary.md`

标准record内部status/fetch日志：

- `.runs/conv/C26-r32/status-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C26-r32/fetch-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C55-row7x3shared3/status-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C55-row7x3shared3/fetch-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C52-r3/status-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C52-r3/fetch-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C26-r33/status-driver-sep13ad-20260912T190902235183Z.log`
- `.runs/conv/C26-r33/fetch-driver-sep13ad-20260912T190902235183Z.log`

JSON另列root原submit三输出、campaign、四record及243份成员实际文件完整路径；原源码目录不在该成员文件清单内，源码身份保留于record/manifest。

生命周期整理完成STOP。未使用重置卡；达到40%用量停止。
