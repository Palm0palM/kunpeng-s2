# AJ 提交工具独立静态审查

2026-09-13，审查者 `/root/c59_diag_review`。全文阅读 driver（最终391行）和 acceptor（76行）；仅修改 driver/README，本报告为新增归档说明。未改 C59 源码、record、checker、wrapper、acceptor 或初始清单，未导入工具、执行算子、SSH 或提交。

## 最终差异

- `AK_JOB_ID` 从 `None` 改为原确认作业 `'1583680'`。
- 新增 `AL_JOB_ID = '1589186'`；将 `.runs/conv/C58-package/cluster.json` 的 `job_id` 加入已有串行 required 集合。读取该原件实际为1589186，保存的终态 SUCCEEDED、job/system均0；原 AK campaign 实际为1583680、performance_complete、confirmation_passed=true。上述读取用于绑定身份，不替代提交时的实时查询。
- 门禁说明/README 更新为 AH/AI/AK/AL 加明确 P/AJ。现有统一条件会要求 AL 身份完全匹配、查询退出0、解析成功、实际匹配 jobId、终态及整数双退出；运行中/查询失败/未知预约均阻止 AJ。未改变终态集合或数值接受条件。
- 初始 `PREPARED_FILES.json`、`AH-to-AJ.patch` 保持准备时原件，本报告记录本次后续差异，未刷新为“初始证据”。

## 接口结论与边界

源身份核对仍要求 C59 自身prepared记录、四份生产文件、五份运输文件、原C58/AH冻结源一致；矩阵仍为44328、19阶段，未继承父版PASS。排他 `job.json` 在上传前保留，提交不确定不得重复；status/fetch复用原ID；fetch不覆盖不同raw。接受器重新读原日志和实际编译命令，要求全部通过、退出0、实际FMA0及目标汇编/root返回审查，然后一次归档，不自行测性能或晋级。

提交前没有新的静态阻断项；实际GO仍由root执行，并需新鲜主额度低于40%。串行门禁只证明已有作业结束，不判断其成功或替代完整结果审查；也不是覆盖其他进程的全局锁，root须保持唯一提交者。若旧作业被调度器清理而查询失败，门禁会停止，不能自动忽略。

接受器归档需要 `BASE/ROOT_REVIEW.md` 和本 `INDEPENDENT_TOOLS_REVIEW.md`：本报告补齐后者，前者待root阅读本次最终差异后写入。真实AJ返回后还需 `AJ_SUMMARY.json`、`TARGETED_ASSEMBLY_REVIEW.md` 和 `ROOT_RETURNED_REVIEW.md`；这些目前缺失是未执行状态，不能预填。acceptor的ID排除列表仅列旧AH/AI，但同时要求新AJ job/summary/scheduler三方同ID、当前C59源及返回字节一致；root应传真实新AJ ID，不改为AK/AL身份。

另有既有留痕限制：fetch捕获异常只保存 `str(exc)`，可能不含异常对象的stdout/stderr；正常失败保存stderr。调用者应保留外层 argv、UTC、stdout、stderr、退出码；本次按职责没有改fetch或扩大协议。

## 已执行静态命令

通过 usage 工具在开始及修改前读取主额度，均35%，未用reset。使用 `sed`/`cat` 全文读取driver、acceptor、README和项目规则；`git status --short`只读检查工作区；读取固定AK campaign、AL cluster身份。使用 `apply_patch` 完成上述两文件变更。

最后用 Python `ast.parse(path.read_text(), filename=...)` 对 driver 和 acceptor 作文本语法解析，未import/执行其内容：两文件均通过。同一轻量命令打印最终身份/串行段，确认 AJ job.json 仍不存在、ROOT_REVIEW.md 尚待root写入。没有进行本机编译、正确性、sanitizer或性能测试。

供root后续一次执行的原接口保持：

```text
python3 .runs/conv/sep13aj-checks/driver.py C59-row7boundaryu2nofive config/conv-sep12.local.json submit --go
```

本审查完成后停止，等待root；不自动执行该命令或启动其他工作。
