# C58 后续边界建议（未执行）

需自身数值及实际机器码证据，不能引用父 T PASS 作为本版通过。仅建议后续经 root 授权在分配节点执行：

|维度|建议覆盖与目的|
|---|---|
|kw|1/2/3/4/5/6/7/8/15/81；短循环、奇偶尾项、两轮及长循环。所有12个边界阶段都要检查实际展开/余项路径。|
|kh/oh|kh7/8、oh7/8/13/14/15/21：完整七行组、组间转换和分派余项；kh1..6及oh<7保留 fallback 覆盖。|
|VL与水平边界|VL16/32/64字节，L=VL/4；ow1、3L−1/3L/3L+1、6L−1/6L/6L+1，覆盖未进入 rowseven、整块、尾部及下一块。|
|线程与地址|线程1/4、真实全局stride/padding、非对齐和 guard 边界；不把 tile 宽度当输入stride。|
|机器审查|13个语义阶段全部 helper/clone、12处 pragma 对应控制流、kw奇偶路径、shared原工作量、每acc依赖顺序、完整 Z/Q/谓词/标量栈和ABI。展开产生的动态区域数量不预填。|

保留小 kernel、非 SVE、invalid-input fallback 的原源码与适用验证。任何未来官方性能仍须原 benchmark/参考/容差/计时/flags；当前文件不创建 checker、job 或 performance campaign。
