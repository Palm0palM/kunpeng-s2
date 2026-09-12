# C45 I 包静态复核

仅文件编辑/复制与静态阅读，未运行编译、算子、测试、SSH或提交；不是远端通过结论。

- 新包在共享.workflow.lock内创建，拒绝已有目录；未改C45/C32冻结源、公共工具、H包或其他候选。
- conv2d.c原字节复制自C45候选，传输时首次自动digest对比prepared experiment record的conv2d.c身份；参考guard/dispatch原字节复制C32冻结source，未更改数值/矩阵/入口宏。
- 静态按真实数组计数：43×19×4 + 24×16×11×4 = 20164 full，smoke3×4×2×4=96；×6=121560。仅full未插桩，smoke独立-finstrument-functions程序；原helper计数格式不新增不存在的worker_mask。
- guard对每个合法矩阵输入分配完整input/kernel/output及reference；逐位比较和mprotect/canary路径原样保留。VL请求限16/32/64，读取PR_SVE_GET_VL，并在OMP实际worker中核对svcntw及team。输出高16可运行多个quad组；kw4/5/6/7在kh4可分别覆盖四列退出余0/1/2/3。
- wrapper首先只读检查Linux/AArch64、实际38CPU和单NUMA，再任何编译；GCC版本必须10.3.1，无generic替代编译器fallback。资源申请24GiB由后续提交负责人配置，本包不能自行提交。
- stage函数保存每条命令/单条pipeline的退出码；set -e及pipefail使失败止于该阶段。编译函数最后命令为gcc，运行函数最后命令为guard|tee；不会将前面的算子失败覆盖为末尾printf成功。finish等待probe.log的tee，失败反映最终wrapper exit。
- 共19阶段：allocation/compiler/manifest/build-guard、6guard、build-dispatch、6dispatch、build-assembly/complete。仅最后阶段输出PROBE_COMPLETE；缺失与失败保留，不生成或改写validation。
- 全量汇编审查尚待真实.s，不能从26个理想源级Z值推断无spill。DUP可能折回indexed，必须识别七阶段及四/二/一列循环，不声称机器码与C6/C29/C32相同或提速。
