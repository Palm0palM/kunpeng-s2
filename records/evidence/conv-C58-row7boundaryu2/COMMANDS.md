# C58 准备操作留痕

只进行本机轻量源码/记录/文档处理，没有算子编译、测试、SSH 或调度。原命令参数及实际 stdout/stderr/exit 分别保存在 new.*、prepare.*、checkpoint.*；三个入口各执行一次且退出0。

- 创建前只读定位12个循环并核对生产四文件/父record/T frozen source/raw，chunk e6a92c，退出0；新 ID 未占用。
- 标准 `python3 -B tools/experiment.py new conv C58-row7boundaryu2 --parent C52-row7x3shared2 ...`：chunk d837bd，退出0。立即排他保存 creation-experiment.json、creation-record.json 原字节。
- `python3 -B .runs/conv/C58-row7boundaryu2/prepare-source.py`：chunk7dd922，退出0；脚本仅在共享锁内做文本插入/字节核对及 patch/audit 写入，不调用编译器或 checkpoint。
- 标准 checkpoint 的完整 note 和参数在 checkpoint.command.json，实际原输出及退出在同名前缀文件中；更新仅此新候选 record。

首次参考读取 `cat .runs/conv/C55-row7x3shared3/prepare-source.py .runs/conv/C55-row7x3shared3/commands.json` 的 tool chunk6eafee 退出1：先返回既有 prepare-source.py 全文，stderr 原文为 `cat: .runs/conv/C55-row7x3shared3/commands.json: No such file or directory`。这是参考文件名不存在的只读操作，未执行旧准备脚本，也没有候选、编译或数值失败；随后直接读取标准 experiment.py 的实际 new/checkpoint/锁语义，不创建该缺失的旧文件。

未改 experiment.json 的原创建 hash；未覆盖旧版本、原始失败或实测样本。准备结束停止，等待独立源审查。
