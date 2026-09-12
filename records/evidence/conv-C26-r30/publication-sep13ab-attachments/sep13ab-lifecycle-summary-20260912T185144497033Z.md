# AB 原1582814生命周期结果

实际终态 SUCCEEDED；四成员 scheduler/job/system/wrapper 均0。record-group与compare各一次0。48 PASS，全部max_error=0；C54初筛两端false，C52-r2仅参考，C6/Sfalse/Yfalse保持。

|版本|A 三样本 ms|B 三样本 ms|C 三样本 ms|D 三样本 ms|总中位 ms|最大spread %|
|---|---|---|---|---|---:|---:|
|C26-r30|51.41 / 51.48 / 51.45|61.93 / 62.00 / 61.92|107.37 / 107.27 / 107.31|231.65 / 231.88 / 231.81|452.50|0.136054422|
|C54-row7x3shared4|80.92 / 80.90 / 80.89|88.52 / 88.41 / 88.46|168.38 / 168.27 / 168.31|369.32 / 371.96 / 369.30|706.99|0.720242608|
|C52-r2|51.83 / 51.70 / 51.77|58.42 / 58.46 / 58.46|103.87 / 103.89 / 103.88|222.79 / 222.80 / 222.75|436.90|0.251110682|
|C26-r31|51.41 / 51.46 / 51.37|61.99 / 61.97 / 61.89|107.27 / 107.39 / 107.36|231.92 / 231.70 / 231.68|452.44|0.175063217|

A=4096×6144,k39×39；B=6144×4096,k41×41；C=4256×6390,k55×55；D=6390×4256,k81×81。三样本按原套件顺序保存，包括C54 D的371.96 ms。

|比较|总收益 %|门槛 %|各case收益 % (A/B/C/D)|eligible|
|---|---:|---:|---|---|
|C54-row7x3shared4 vs C26-r30|-56.240883978|1.000000000|-57.240038873 / -42.838688842 / -56.844655670 / -59.320132867|false|
|C54-row7x3shared4 vs C26-r31|-56.261603749|1.000000000|-57.362380860 / -42.746490237 / -56.771609538 / -59.395770393|false|
|C54-row7x3shared4 vs C52-r2|-61.819638361|1.000000000|-56.268108943 / -51.317139925 / -62.023488641 / -65.770456484|false|
|C52-r2 vs C26-r30|3.447513812|1.000000000|-0.621963071 / 5.603100275 / 3.196347032 / 3.891117726|true|
|C52-r2 vs C26-r31|3.434709575|1.000000000|-0.700252869 / 5.664030983 / 3.241430700 / 3.845489858|true|

C52-r2的数值eligible不构成确认资格：reference_only=true/promotion_allowed=false/qualified_for_confirmation=false。C54四case均超过1%退化；没有下一确认、包或晋级。

所有外层证据文件：

- `.runs/conv/sep13ab-lifecycle-compare-20260912T184935561351Z.json`
- `.runs/conv/sep13ab-lifecycle-compare-20260912T184935561351Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-compare-20260912T184935561351Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-postread-note-20260912T185144497033Z.json`
- `.runs/conv/sep13ab-lifecycle-record-20260912T184902190742Z.json`
- `.runs/conv/sep13ab-lifecycle-record-20260912T184902190742Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-record-20260912T184902190742Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184353720920Z.json`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184353720920Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184353720920Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184559070600Z.json`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184559070600Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184559070600Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184709465597Z.json`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184709465597Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184709465597Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184813354501Z.json`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184813354501Z.stderr.txt`
- `.runs/conv/sep13ab-lifecycle-status-20260912T184813354501Z.stdout.txt`
- `.runs/conv/sep13ab-lifecycle-submit-origin-20260912T184431828732Z.json`
- `.runs/conv/sep13ab-lifecycle-summary-20260912T185144497033Z.json`
- `.runs/conv/sep13ab-lifecycle-summary-20260912T185144497033Z.md`

标准record内部status/fetch日志：

- `.runs/conv/C26-r30/status-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C26-r30/fetch-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C54-row7x3shared4/status-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C54-row7x3shared4/fetch-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C52-r2/status-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C52-r2/fetch-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C26-r31/status-driver-sep13ab-20260912T184902278345Z.log`
- `.runs/conv/C26-r31/fetch-driver-sep13ab-20260912T184902278345Z.log`

一次额外只读日志查看误用了未取回的wrapper.stdout.log路径；缺文件信息独立保留在postread-note，标准exit-code.txt已实际验证，未重跑任何生命周期工具。
