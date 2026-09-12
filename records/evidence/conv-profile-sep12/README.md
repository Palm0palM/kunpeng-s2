# C6 单次热点采样包（prepared，未执行）

所有文件仅本目录。来源当前正式C6=C26-r1的不可变conv2d.c、bench_conv.c和run.sh；没有修改benchmark/reference。provenance.json保存既有实验身份/环境，source-hashes.json为初次自动传输manifest，不做额外重复人工哈希审计。当前没有job.json或远端作业，必须等待根代理在无其它性能作业时明确GO。

## 构建与采样范围

source/build_c6.sh直接截取原run.sh从开头至run_case定义之前的字节，仅保留设置和原编译命令，不运行原四用例尾部。remote_job在38CPU、24GiB、单NUMA调度节点先检查Linux/AArch64和实际CPU分配，再source构建脚本；保持gcc、generic、CONV_BLOCK=32、UNROLL=2、38线程/close/cores、原strict FP及链接flags。实际展开的编译命令保存在build.stdout.log（set -x），编译器/环境/build日志也独立保留。若实际编译器不是已记录GCC10.3.1，则标inconclusive并不采样。没有添加-g、frame-pointer、LTO、mtune或任何算子插桩。

先构建，再以perf record仅包已编译ELF的原官方第四用例6390 4256 81 81 1；编译进程不进入采样。事件只用cycles:u，99Hz、128 mmap pages，保留timestamp/period并限制在本次38个已分配CPU；保留线程继承，不开启全系统采样、调用栈、SPE或其它未验证事件。原NUMA/OMP绑定继续应用。记录perf真实命令、工具版本、paranoid和每阶段退出码。

采样包含benchmark内部的参考、初始化，以及校验/预热/计时三次conv调用。按DSO/symbol和采样IP将quad与reference_conv2d、random_fmatrix、libgomp等分开；symbols.report为全体，quad.report显式保留全体分母的absolute百分比，quad.annotate使用quad内部local-period百分比。没有输出或推断整个算子的CPI，不把/bin/true或全进程计数当作算子指标。

ELF未strip，quad已有noinline；先要求nm找到唯一conv_sve_rowquad，保存ELF/build-id/原反汇编。perf.annotate无-g仍可标注实际汇编。源行、调用栈和精确指令延迟不在本方案范围。cycles采样可能有skid，观察循环区段，不能据单条样本占比断言指令延迟、cache miss或瓶颈因果。

## 明确GO后的命令（目前禁止执行submit）

从仓库根目录运行：

```text
python3 .runs/diagnostics/conv-profile-sep12/driver.py config/conv-sep12.local.json submit --go
python3 .runs/diagnostics/conv-profile-sep12/driver.py config/conv-sep12.local.json status
python3 .runs/diagnostics/conv-profile-sep12/driver.py config/conv-sep12.local.json fetch
```

提交先保存job.json，再上传/调度，拿到唯一ID立即保存。每约60秒查同一ID；job.json存在时拒绝再次submit。断线后先status，终止后fetch。若提交输出不确定，不删除job.json、不重提，先用submit.log与调度状态协调确定ID。查询失败另存timestamp日志，保留上次成功状态。仅fetch失败可重试fetch，不重新运行算子。512MiB以上二进制/32MiB以上单文本保留远端并在retrieval.json标明不完整，不静默丢失。

## 产物与验收

raw中保留probe/编译/benchmark/perf原日志、环境/分配、源码manifest、精确ELF、perf.data、build-id、符号、quad反汇编、整体/quad报告、逐指令annotate和各退出码。二进制及原始perf.data只作私有证据；发布前需脱敏文本，不能直接公开原data中的地址/路径/主机元信息。config和认证资料不上传或复制进包。

调度成功不代表诊断成功。始终核对job/system/wrapper退出码及profile-status.json：

- unsupported：perf缺失或采样被权限/事件拒绝；保留错误，不降级成全进程计数。
- inconclusive：编译器与C6不同、符号/工具失败、解析不了quad样本、少于1000quad样本或反汇编含未知指令。
- failed：构建/分配等异常，或官方benchmark未恰好1PASS且0FAIL。
- ready_for_review：已获得可归因样本，仍须人工核对丢样/限频警告、ELF/符号、样本量/分母与IP位置。complete始终先为false，不能自动当作验证完成或晋级依据。

unsupported/inconclusive可正常结束wrapper，但profile状态保持非通过；每个实际tool退出码和原日志仍保留。采样期间benchmark打印时间仅诊断，绝不写入正式性能记录/比较/晋级。单次单用例结论不能推广到全部四项。1000样本只是接受区段观察的工作门槛，不是统计显著性证明。

本机只做文件准备、SSH传输和日志整理，所有编译/算子/性能采样仅在调度计算节点。当前未执行任何脚本或提交任何作业，不用重置卡。
