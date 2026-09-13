# AJ 静态准备说明

只作文本准备；没有导入/运行 driver、接受器、AST/py_compile、编译/算子、SSH、new/checkpoint、预约或接受归档。所有源码、原记录、AH 冻结及队友文件未改。

- 来源严格为最终 AH driver/wrapper/两checker/简接受器。五文件首次复制前只读核对 C59/父 C58 当前生产四文件和原 AH 冻结 conv；把删除的33字节 pragma 插回1445行，完整恢复父字节。
- 两 checker 没有任何差异。wrapper 只有身份/SHA 两处差异，env 只有身份差异；原44328/19stage/flags/resources/位比较不改。额外 memcmp/FMA0 是当前实验路线，不解释为题目全面禁止 FMA。
- driver 只改本版/父身份与 AH44328、11提示/input_5 排除字段，串行缩为 AI/AH/P/AJ 加优先 AK；只读检查 AI 完整36记录，保留原结论。`AK_JOB_ID=None` 有意阻止提交，未来只允许真实 ID 的 root 审核绑定。
- 接受器保持 AH 数值解析，未来 ID 改为显式参数并核对原记录；另检查 scheduler jobId、摘要19stage一致、实际五文件SHA。依赖原生命周期摘要提供真实资源/manifest关联，依赖独立/root目标审查，不能把占位说明当实际结果。
- prepared/source清单仅描述已准备字节和未来期望；未填 AJ job/PASS/spill/速度。接受归档目录不存在且没有 job/raw/validation，当前状态始终 prepared only。

`AH-to-AJ.patch` 提供全部对应文本差异；`PREPARED_FILES.json` 是最终准备文件身份清单（排除自身）。quota由root真实读取并在40%停止，禁止reset。完成后停写供独立审查。
