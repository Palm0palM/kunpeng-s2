# r17 新基线控制器审查

root 核对唯一T19-control13 / parent=null / 来源T19的身份：准备前必须当前best仍T19、原记录通过且晋级、source job1579861；四题目文件与原测量及已复验ZIP一致，五文件从当前交付目录冻结。不存在目标run/record才可prepare，冻结末尾再次核对原记录、当前best及所有源码。来源记录完整另存，没有覆盖原T19。

目标driver和reference继承r16的Linux aarch64、38CPU单NUMA、真实已确认job、GCC12/KML25.1/gomp与官方runner门禁。唯一成员先一次完整预热，再三套正式；不重复无改动候选的专用预检，也不生成此类新成功声明。新的9正式/3预热日志必须完整通过。

提交沿用r16排他attempt、先持久化已知job再发marker；未知状态禁止重提。collect核对成功终态及实际job，取回全部原始日志。finish排他一次，在登记前审核配置、五源码、调度、runner、逐组精度、真实依赖和原始预热，新的parent=null记录不使用repeat-existing；当前源码或best发生变化则拒绝登记。finish不自动晋级。

AST、Shell内嵌AST与bash -n通过，仅读取/解析文本，无本机题目编译或运行，无哈希。允许解除prepare阻断并执行一次准备与提交。
