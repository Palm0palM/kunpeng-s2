# Q / C51 检查器独立静态审查

结论：在最终声明的有界矩阵内，未发现阻碍执行诊断的检查器问题。这里只是静态审查结论，不是编译接受、数值 PASS、实际入口或性能证明。根代理已确认接受本轮相对原建议的范围缩减，不要求扩大矩阵；本审查不授予 compute GO。

作者宣布两份 C 检查器最终 ready 后，我逐行阅读最终文件；另仅读取 C51 生产 helper 接口、防御/横向尾部及公共 dispatch 所需片段。没有从被测实现生成预期数值，没有执行或导入工具、测试程序、编译器或 SSH，没有修改 Q 文件。driver、wrapper、验收及归档工具由根代理另行审查，本次不重复。

## 审查字节与范围

|文件|SHA256|读取范围|
|---|---|---|
|sep13q-checks/C51-row7x3u1/source/check_conv_guard.c|b11bfe06a6d09228ad0d4dc6ae3d7581642fb534a1bd612f94c86574f41cc307|全部174行|
|sep13q-checks/C51-row7x3u1/source/check_sve_dispatch.c|5751451998db3f2bee920afc78af05039d5b11949db5a4765aefe8553d4aacbc|全部117行|

生产接口读取 `.runs/conv/C51-row7x3u1/source/conv2d.c` 1237..1254、1751..1755、1760..1845：rowseven 接收七个目的行指针与原输入 stride；kh<7防御为quad+triple；主块3×svcntw；横向尾部同样quad+triple；新公共分派只在kh>=7且oh>=7进入七行分组。接口阅读仅用于核对调用边界和入口数，没有替代独立 scalar reference。

## 尺寸、去重和数量

下表 L 均指 `svcntw()` 的 float lane 数，字节 VL 为16/32/64，对应 L=4/8/16。核心宽度来自 `3L−1,3L,3L+1,6L−1,6L,6L+1`（guard130、dispatch69）：

|VL字节|L|六个实际核心宽度|
|---:|---:|---|
|16|4|11、12、13、23、24、25|
|32|8|23、24、25、47、48、49|
|64|16|47、48、49、95、96、97|

每配置内宽度正且互异；不同 VL 的同一整数宽度属于不同配置，不算重复。核心高度1..15/21/22/28共18个且互异。full的narrow使用ow1，与核心不重叠；small使用kh1..5，与核心/narrow的kh6..8不重叠；larger四形状(10,7)/(9,8)/(15,15)/(81,81)又与前述集合不重叠。small的三宽及其高度数组也无重复。dispatch有意重复生产核心形状以检查入口，direct有意重复部分尺寸以强制内部防御分支；它们是独立层，不能当作额外独特生产形状数。

按实际数组/循环独立推导，而非照抄末尾常量：

|层|推导|每配置|六配置|
|---|---|---:|---:|
|full core|6宽×3kh×3kw×18高×2pad×2leading|3888|23328|
|full narrow|1宽×3kh×3kw×4高×4分配方式|144|864|
|full small|3宽×5kh×3kw×4高×4分配方式|720|4320|
|full larger|1宽×4kernel×2高×4分配方式|32|192|
|full合计|以上四层|4784|28704|
|dispatch|6宽×3kh×3kw×18高，固定pad1/leading0|972|5832|
|direct|3宽×6kh×3kw×2高×4分配方式|432|2592|
|总计|4784+972+432|6188|37128|

guard170在输出PASS前核对四family及总数；dispatch91/114核对两层case数及入口数，不会以打印计划数替代循环计数。这里的六配置数量仍是计划，是否每个配置真实执行完成由根代理审查的包装/返回验收负责。

核心kh6/7/8跨越公共分派阈值；kh7覆盖共享阶段一次，kh8覆盖重复。oh1..6验证低于七行阈值，oh7为一整组，oh8..13在已有整组后覆盖余行1..6，oh14/15、21/22和28覆盖多组与余行；oh28可提供四个完整七行组。直接层kh1..6、oh7/28明确强制生产中通常不可达的kh<7 helper防御。

## 独立数值参考与内存保护

guard75..101以输入尺寸 `height=oh+kh−1,width=ow+kw−1` 分配足够完整矩形。89..94的参考是独立y/x/ky/kx顺序scalar循环，初值float +0，逐项乘加写入单独ref；没有调用生产helper、没有读取生产内部累加器或用输出修正参考。95调用被测入口，96以memcmp逐位比较完整输出，未引入容差。该数值合同依赖未来真实编译flags保持严格浮点及关闭FMA contraction；本次不宣称编译器已满足。

33..51为每个allocation保留两端PROT_NONE；pad0/1与leading0/1使输入/kernel分别接近起止guard，另一侧可写页外围仍铺canary。input/kernel在84..88初始化后改为只读；任何写入应触发权限错误。输出先全部poison，周边可写页使用canary，96..97同时检查数值及三个allocation外围。输出固定pad0但分别贴近两端guard；输入pad的两个取值不等于两个不同output偏移。ref独立分配且最后释放，各mapping也释放。

所有选定尺寸均为小正整数，尺寸推导、元素数、page rounding在该有界集合内没有整数溢出问题。没有每行独立guard；跨行仍落在allocation内的错误读取靠数值比较发现，不得声称每行都受guard页约束。没有invalid-dimension、屏蔽SVE、sanitizer、NaN/Inf专用矩阵或性能计时。

## VL、线程和真实入口证据

guard103..125只接受VL字节16/32/64，并检查HWCAP_SVE、PR_SVE_SET_VL及GET_VL；独立OpenMP team中的每个worker核对runtime_lanes，actual_threads须为1或4且与omp_get_max_threads一致，动态team关闭。EXPECTED_ACC只用于打印主块输出数，不参与参考数值或决定行数；本候选应由包装传3。setup证明初始化team配置；它不是在每个算术阶段重复采样的VL计数。

dispatch14..28的enter/exit hook有no_instrument_function声明，避免自身递归插桩；只通过实际函数地址识别helper，原子增计数。rowseven入口还按实际omp_get_thread_num原子OR mask，未把理论组分派填入观察字段。运行时库调用不来自本文件的被测实现；该构建只作诊断，不当生产对象或性能样本。

53..64在每个case前后读取真实rowseven累计值，要求差值精确等于接口预期。public层kh6或oh<7时应为0，其余为floor(oh/7)，不要求宽度达到主块才计入口，因为窄宽会进入helper后回退。18个高度的floor(oh/7)之和为21，因此public总入口为6宽×2个有效kh×3kw×21=756；与91的常量一致。不会仅因全局总数正确而放过单case少计/多计。

direct32..51只接受oh7/28和kh1..6，按完整七行组直接调用helper。每组input base偏移 `row*width`，目的行间距保留全局ow，七个指针仅指向存在的输出行；没有错误压缩为临时紧凑尾块。每case入口预期oh/7，因此总数为3宽×6kh×3kw×4分配方式×(1+4)=1080。它验证真实内部helper防御，不能归作公共dispatch的额外覆盖。

`checked_conv`指针只在串行case边界改写。one_case返回前，生产函数和direct wrapper里的parallel-for都已隐式join；因此95..97修改指针及清零direct mask不与此前team并发。总rowseven计数不清零，通过减去dispatch_entries取得direct值；每casebefore/delta仍成立。expected_mask在已验证max_threads=1/4后计算，分别1/15；oh28含四整组，让四线程套件有机会实际观察全部worker。

旧prefix/tail/pair/triple/quad在public套件结束时均要求非零；这只证明它们在套件中实际进入过，不能证明每case余6/5等逐一走了指定旧helper路线。rowseven入口虽逐case检查，worker mask仍为public/direct各自整套累计，而非每case或每阶段mask。数值检查覆盖全部输出；上述入口范围限制已写入最终接口。

## 发现并已澄清的范围差异

初次对照C51原BOUNDARY_MATRIX建议时发现当前C文件省略低L/2L±1的864个full case；direct宽度为3L−1/3L/3L+1，没有建议的ow1；larger采用10×7/9×8而不是建议9×7/8×8。已反馈作者和根代理。作者在最终Q INTERFACE“返回每配置”之前明确说明这些差异、原因及suite级旧helper/mask限制；我已读取实际补充文字。作者未改两份C检查器或首次manifest，根代理明确认可此有界范围，不要求扩大。

因此没有待修复的阻碍项。正常full的ow1覆盖不能替代direct ow1；旧helper源码未改也不等于本轮重测了低VL边界。最终结果应按37128实际计划及上述限制表述，不写成最初40368建议矩阵全部完成。

本审查只新增本文件；其余文件未改。审查完成，STOP。后续是否计算由根代理另行决定。
