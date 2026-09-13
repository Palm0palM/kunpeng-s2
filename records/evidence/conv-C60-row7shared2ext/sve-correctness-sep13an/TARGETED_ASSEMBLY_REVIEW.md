# AN C60 目标汇编独立审查

只读原 AN1589554 返回的 `raw/conv2d-sve.s` 及父 C7/C58 的 AH 汇编记录。未 import、编译、执行算子、SSH 或修改源/工具/实验记录。

**实际共享两列循环生成了预期的四次加载及三次 EXT，主循环没有 Z spill；这不构成性能提升结论。**

LOCAL_USER目标LOCAL_USER实际范围LOCAL_USER指令数|FMUL/FADD|LD1W/LD1RW|EXT/MOVPRFX|Z 栈读/写LOCAL_USER
LOCAL_USER---LOCAL_USER---LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
LOCAL_USER共享两列 `.L407`|6879–7006|127|42/42|4/14|3/3|0/0|
LOCAL_USER余一列 `.L409` 至回跳|7010–7074|63|21/21|3/7|0/0|0/0|
LOCAL_USER完整 rowseven helper|5705–8318|2432|546/546|145/182|3/3|9/15|

计数包含无操作数的 ret，排除标签、指示符和空行。父 AH helper 是2448条，主共享循环123条；C60全函数少16条，但主循环多4条。这些是静态指令出现数，不能视为动态周期或访存流量。

主循环6881/6885/6886用 p0/z 完整加载 z14/z12/z13，对应源 v0/v2/v1；6895用 p1/z 将尾元素加载到z19。三对 MOVPRFX/EXT 为6888–6889、6898–6899、6900–6901，分别构造 `(v0,v1)`、`(v1,v2)`、`(v2,tail)` 拼接后偏移4字节的窗口，等于一个 float 的偏移。第一列和第二列仍分别乘、加，14个权重广播；整个 `.s` 扫描 FMLA/FMLS/FNMLA/FNMLS/FMADD/FMSUB/FNMADD/FNMSUB/FMAD/FMSB/FNMAD/FNMSB 为0。

5791的 `ptrue p1.b,vl1` 只把谓词 bit0 置为活动；对 `.s` 的 LD1W，活动条件取每个32位元素对应的谓词位0、4、8……，因此仅第一个 float 活动，其他元素不访问内存，并由 `/z` 置零。p0在5767为 `ptrue p0.b,all`。本helper内未见其他p0/p1写入或predicate栈保存，主循环内也无调用破坏该谓词。

输入地址对应连续完整窗口和单元素尾部：初始化以CNTW/CNTH构造 L/2L，5795及5798给尾部3L偏移；这些地址通过sp+584/592/600的标量地址槽传到共享段。共享迭代中 x12=x10−2L*sizeof(float)，x11为中间窗口，x14为尾部基址，三者及tail按同一输入行步长推进，列索引x2按2增加。源完整块及pair条件给出 `i+3L<=ow`、`ik<=kw−2`，从而唯一tail元素 `i+ik+3L<=ow+kw−2=W−1`。EXT末窗口仅使用tail第0个float；未生成越界的完整VL尾加载。

栈帧为 **704 B + 3 VL**（5708 ADDVL sp,-3；5710 SUB sp,704），恢复见8036/8038、8259/8261、8295/8297；父AH为720 B + 3 VL。完整helper仍有9 LDR Z / 15 STR Z，与父AH数量相同：input_5中的临时乘积3读3写仍在，另6读12写出现在trailing转场及互斥入口。基址由sp+704建立，使用0/1/2 VL槽位；例如6744写2VL、6770读2VL，7093写1VL、7209读1VL。未见Q或predicate寄存器栈访问；标量/地址栈访问仍存在。不能把全函数静态9/15解释成一次执行必然发生的次数。

D8..D15低64位ABI仍为四对，保存5827/5832/5837/5842，恢复8004/8007/8010/8013，单独于Z spill统计。本报告仅覆盖目标load/EXT/predicate/栈行为及计数，未重审所有边界累计链，不代替独立数值验收或同资源性能比较。
