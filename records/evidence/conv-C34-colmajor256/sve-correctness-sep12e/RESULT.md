# C34 验收

作业1579381 SUCCEEDED，job/system/wrapper退出0；六配置21748 full+96 smoke，共131064项通过，validation.complete=true。新增各worker真实调用计数证明四线程参与：worker0..3各784/160/336/64次；单线程1344次。完整输出逐位、输入只读、保护页/canary、VL及来源自动manifest通过。256列边界、全局ow行距、局部chunk宽度和column-major双射覆盖原样保留。

quad共享二列主循环仍.L342，93指令、32mul+32add、8输入load+8广播，无向量spill/EXT/MOVPRFX，全源码0FMA。固定752B栈帧为外层标量/ABI保存。保持C6，待根代理正式性能比较。没有本机编译测试、重置卡或性能提交。
