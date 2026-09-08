# C5-b48 本地正确性检查

父版本：C0-r3（源码与 C0-r2 一致）。单一改动：`source/run.sh` 中 `CONV_BLOCK` 默认值 32 → 48。算子、官方 benchmark、双步展开和严格浮点选项均未变。

执行命令：`bash .runs/conv/C5-b48/local/run_checks.sh`。完整编译命令在 `build.log`，编译器/平台在 `environment.log`；测试源、执行脚本及结果哈希在此目录保存。

Apple Clang 17.0.0 / Darwin arm64：1 线程和 4 线程分别通过 UBSan 418 用例及带输入/输出保护页的 UBSan 418 用例；所有结果与顺序标量 float 参考逐位一致，退出码均为 0。`bash -n source/run.sh` 通过。

本机检查只验证正确性，未采集或声称鲲鹏性能结果。超算测试由协调者按相同设置排队；三轮官方用例和同环境比较完成后才能决定是否晋级。
