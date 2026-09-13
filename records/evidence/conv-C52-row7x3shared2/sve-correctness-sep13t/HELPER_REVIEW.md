# C52 / T 实际 rowseven helper 审查

本片段只完成 helper 审查，不代替 root 的 dispatch 审查和最终 accept/freeze。唯一 T 作业 **1582134** 的原样返回 `raw/conv2d-sve.s`，GCC **10.3.1**，实际 `conv_sve_rowseven` **5705–7053** 全部1349行已读；无该名称其他 clone。行号是文本位置，不是伪造机器PC。

- 源码 SHA256：`8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7`。
- 实际汇编 SHA256：`e42a1f618c0007479b282f963829b654b6d1b5a8dc8301c702f296586f8df220`。
- `wrapper.stdout.log:378–389` 记录计算节点真实 `gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DEXPECTED_ACC=3 -S conv2d.c -o conv2d-sve.s`；编译的是原生产源，没有 dispatch 检查器插桩。

## 13个语义阶段，14个实际算术范围

范围包括实际loop label与回边；odd的真实回边在.L454，不假设它必定降成直线代码。表中每列归一化仅除以该区域的kernel列工作量；不把静态指令数当作周期或性能结论。

| 阶段/区域 | label | 实际文本行 | 每迭代列数 | 指令 | FMUL/FADD | LD1W/LD1RW | 指令/列 |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| input_0 | .L395 | 5970–5984 | 1 | 14 | 3/3 | 3/1 | 14 |
| input_1 | .L397 | 5993–6016 | 1 | 23 | 6/6 | 3/2 | 23 |
| input_2 | .L399 | 6027–6058 | 1 | 31 | 9/9 | 3/3 | 31 |
| input_3 | .L401 | 6070–6109 | 1 | 39 | 12/12 | 3/4 | 39 |
| input_4 | .L403 | 6122–6169 | 1 | 47 | 15/15 | 3/5 | 47 |
| input_5 | .L405 | 6182–6237 | 1 | 55 | 18/18 | 3/6 | 55 |
| shared/paired | .L407 | 6270–6393 | 2 | 123 | 42/42 | 6/14 | 61.5 |
| shared/odd_remainder | .L409 | 6397–6461 | 1 | 63 | 21/21 | 3/7 | 63 |
| trailing_0 | .L412 | 6482–6537 | 1 | 55 | 18/18 | 3/6 | 55 |
| trailing_1 | .L414 | 6544–6591 | 1 | 47 | 15/15 | 3/5 | 47 |
| trailing_2 | .L416 | 6598–6637 | 1 | 39 | 12/12 | 3/4 | 39 |
| trailing_3 | .L418 | 6644–6675 | 1 | 31 | 9/9 | 3/3 | 31 |
| trailing_4 | .L420 | 6681–6704 | 1 | 23 | 6/6 | 3/2 | 23 |
| trailing_5 | .L422 | 6710–6724 | 1 | 14 | 3/3 | 3/1 | 14 |

14范围均无 indexed FMUL、LD1RQW、DUP、indexed MOV、EXT、MOVPRFX。整份返回汇编的FMA词法计数为0。

## 两列顺序与边界

Prologue computes unsigned paired bound at5768/5806/5907/5923 and equivalent W remainder start5941..5942. This bound is used only after kw>1 at6265. .L4106257..6470 iterates t beginning6; x21=stride*4 and x26=kw*4. After each row x3+=kw*4, other coefficient bases are recomputed from rolling x3/x4; input vector bases advance stride*4. At t==kh the code reloads saved scalar state and enters trailing0.

At6265..6266 kw<=1 branches to.L426. For kw>=2 x0=0,x2=4, x17=2*(floor((kw-2)/2)+1)=2*floor(kw/2). Each actual loop increments x0 by2 at6371 and x2 by8 at6386; cmp x17,x0 / bne.L407 at6392..6393 is the real backedge. After loop x1=signextend(w18), the same even bound, then branch.L454. kw2 executes one pair and skips odd; kw3 executes one pair then odd; positive even kw never reads beyond kw-1.

Entry is .L454 at6459, compare kw with current x1 and bgt.L409. x1 is0 through.L426 for kw<=1 or the even paired bound after6394. kw1 executes once; kw2 skips; kw3 executes column2 once; general odd executes final kw-1. x1+=1 at6424;6459..6461 is the real condition/backedge, not an invented straight-line PC. kw<=0 skips both regions. After completion6462..6470 advances t and input/coefficient-row state.

All21 accumulator FADD pairs were traced through the interleaved actual lowering: each ik add precedes its own ik+1 add. Row g vector1 temporarily renames z5 to z2 at6383, and its second add at6390 reads z2 into z5; it is not an independent partial sum. Other accumulators retain their destination register. Inputs and coefficient values for both columns really overlap (e.g.6279..6295); lexical C scopes did not prevent simultaneous liveness. No reassociation, indexed multiply or FMA observed.

| 累加器 | 实际寄存器 | ik的FADD行 | ik+1的FADD行 |
| --- | --- | ---: | ---: |
| a0 | z23 | 6277 | 6308 |
| a1 | z22 | 6284 | 6288 |
| a2 | z16 | 6287 | 6300 |
| b0 | z20 | 6294 | 6324 |
| b1 | z21 | 6299 | 6305 |
| b2 | z7 | 6304 | 6316 |
| c0 | z24 | 6309 | 6340 |
| c1 | z25 | 6315 | 6321 |
| c2 | z17 | 6320 | 6332 |
| d0 | z26 | 6325 | 6353 |
| d1 | z27 | 6331 | 6337 |
| d2 | z18 | 6336 | 6348 |
| e0 | z28 | 6341 | 6370 |
| e1 | z29 | 6347 | 6356 |
| e2 | z19 | 6352 | 6361 |
| f0 | z30 | 6360 | 6387 |
| f1 | z31 | 6366 | 6388 |
| f2 | z6 | 6367 | 6377 |
| g0 | z4 | 6382 | 6389 |
| g1 | z5 via z2 | 6383 | 6390 |
| g2 | z1 | 6376 | 6391 |

pair区域的输入第一列与第二列确有同时存活，不能用C中局部花括号声称编译器不会重叠。其123条指令/两列=61.5条/列；相对Q的63条/列只是静态代码事实。更多地址状态和ABI保存可能抵消它，当前没有C52性能结论。

## 全helper栈、转换、输出与回退

Fixed720byte frame: sub sp,sp,#720 at5708; balanced add sp at6887(normal),6993(width-tail),7026(kh<7). No addvl/subvl or scalable vector area. Scalar X/W pointers,counters and outgoing arguments occupy frame. Caller stack arguments read at currentSP720..752. The tail branches store outgoing ow atSP720 before restoring original SP; this is the callee stack argument, not a spill.

All1349 lines from actual function label5705 to.size7053 read, including prologue,13stage transitions,14arithmetic regions,zero-kw state path,21outputs,all restores and fallback/tail paths. No Z/Q/predicate spill loads/stores; D8..D14 save only low64bit ABI state. Source-level scope and21acc count were not used as spill proof.

ABI：D8/D9在5780保存、6862恢复（sp+112）；D10/D11在5785/6865（sp+128）；D12/D13在5790/6868（sp+144）；D14在5795/6871（sp+160）。这些是七个低64位ABI寄存器，不是七个SVE累加器spill。

Prologue5705..5955 materializes only scalar address/counter slots. Its indirect stack alias x0=sp+664 at5765 is consumed by STP X at5800/5803 and subsequent scalar LDR X at6118..6120/6178..6180; no vector access through that alias. x29=sp+16 is frame pointer. Input stage transitions initialize exactly each newly active output chain. Shared transition and paired/odd details are separately recorded. All trailing transitions6471..6724 reload scalar pointers only. All21 stores and output-pointer advancement6725..6858 were read. kw<=0 .L4256920..6939 zeros the18 previously established accumulators; .L394 zeros final3, shared skips its arithmetic, trailing skip jumps.L411 to zero stores. No indirect vector stack storage.

Saved x24/x30 at6245 and x28/x18 at6248 are scalar pointers/counters, restored6471/6473. Paired/odd contain no stack loads/stores, calls or Z/Q/predicate spills; outer address transitions use scalar state and Z accumulator chains only.

Width guard cntw*3 at5742..5747; fullblock entry ensures all three predicated-all vectors remain within the current output span and the final input load obeys source halo geometry. Exactly21 ST1W at6731..6779 store rows0..6 vectors0/1/2, distinct output bases with block offsets0,VL,2VL. i increments3VL at6761; x28 and all cached column pointers increment3VL*4 at6763/6780..6855; final compare repeats only if ow-i>=3VL. D saves restore before.L393. Narrow ow<3VL .L4567036..7050 sets i=0,remaining=ow then.L393. Any positive remainder .L4576940..7001 calls quad on rows0..3 with base+i/dst+i/ow-i, restores frame and tail-calls triple on rows4..6 with base+4*stride+i. kh<=6 branch5735..5738 enters.L3917002..7035 before SVE-body saves; calls quad then frame-restored triple with base+4*stride and unchanged ow. Early routes never restore unsaved D or X27/X28 registers. Shared body makes no calls.

Original separate FMUL/FADD retains kernel row/column order for each output. Actual final accumulator map: row0(z23,z22,z16),row1(z20,z21,z7),row2(z24,z25,z17),row3(z26,z27,z18),row4(z28,z29,z19),row5(z30,z31,z6),row6(z4,z5,z1). Paired region uses6 input LD1W,14 coefficient LD1RW and42ordinary FMUL/FADD; odd uses3/7/21/21. Other12 stages have3 LD1W,n LD1RW,3nordinary FMUL/FADD. All source assembly FMA lexemes0; no indexed FMUL,LD1RQW,DUP,indexed MOV,EXT,MOVPRFX in the14 regions. Both columns inputs/coefficients overlap in actual scheduling; no claimed one-window liveness guarantee. Counts describe assembly instructions, not dynamic cycles, objects, speed or official results.

两个文件仅整理实际源码/汇编文本。本代理未执行接受器、冻结器、题目、性能工具、SSH或新作业；未改源码、record、预期数量，未打包/晋级，未使用重置卡。数值生命周期由Galileo独立汇总，dispatch与后续最终决定由root负责。
