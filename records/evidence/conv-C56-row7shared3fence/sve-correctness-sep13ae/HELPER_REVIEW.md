# AE C56 actual rowseven helper review

**Helper review complete; overall review remains incomplete with dispatch pending. FINAL / STOP.** Root owns the separate dispatch fragment, final merge, accept and freeze. This report concerns original AE job **1583102**, not a new run.

Actual source SHA `6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`; actual `.s` SHA `357025e3e88d302ea981193ba1b2e43e4715aba37bc474250654aa0fcbce20fa`. The single `conv_sve_rowseven` is **5705–7259**, from label through `.size`, **1555 text lines / 1391 instructions**. The complete helper was read, including prologue, all stage bodies and transitions, loops, zero-width path, output, horizontal tail, defensive kh path and epilogues. There is no rowseven clone in the actual function inventory.

GCC **10.3.1** accepted the returned source. Actual probe line 395 is the strict uninstrumented `-S conv2d.c` invocation with `-fno-fast-math -ffp-contract=off -mcpu=generic`; build-assembly and all 19 original stages exit 0. The entire `.s` has **0 fused multiply-add/subtract instructions**. Only assembly text is available; no object disassembly or numeric/performance program was run locally. Q separately records the actual **44328** numerical cases and all original exits in `sep13ae-lifecycle-summary.{json,md}`. This report does not execute acceptance or claim a timing result.

## Actual changes from the original C55/AC parent

Parent is **C55-row7x3shared3 / AC 1582860**, frozen source SHA `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`, assembly SHA `0843c7259fdcb63d78d37965de48c229f81a505f59df81eb579fd792452aa39c`. Parent counts were reread from those actual bytes and compared with the previously completed full AC helper review.

| Observation | Parent AC | Actual AE |
| --- | ---: | ---: |
| Shared main instructions / 3 columns | 189 | 190 |
| Shared LD1W / LD1RW / FMUL / FADD | 9 / 21 / 63 / 63 | 9 / 21 / 63 / 63 |
| Shared main Z stack loads / stores | 5 / 5 | 5 / 5 |
| u1 body instructions / column | 63 | 63 |
| Whole helper instructions | 1492 | 1391 |
| Whole helper Z stack loads / stores | 30 / 45 | 5 / 5 |
| Included zero-initialization Z stores | 5 | 0 |
| Frame | 880 + 5VL | 848 + 5VL |
| Frame at VL bytes 16 / 32 / 64 | 960 / 1040 / 1200 B | 928 / 1008 / 1168 B |

All twelve other arithmetic bodies retain the parent instruction counts 14/23/31/39/47/55, mirrored on exit. The main still has one LSL and three rolling coefficient-pointer `+12` updates. Its 19 scalar ADDs include coefficient/input addressing, stack aliases and loop progress. Extensive outer pointer stepping remains. The net main `+1` is not an emitted fence or a direct estimate of fence cost. The helper `−101` and disappearance of peripheral vector traffic are static observations; they do not establish faster execution.

## Thirteen stages and actual ranges

Ranges below are actual labels through the corresponding loop backedge. The source stages remain 13; shared has two actual loop regions, giving **14 actual arithmetic regions**. No region count or line number was inherited as a result.

| Semantic stage | Actual range | Instructions | FMUL / FADD | Work | Z load / store |
| --- | --- | ---: | ---: | ---: | ---: |
| input_0 | 6029–6043 | 14 | 3 / 3 | 1 | 0 / 0 |
| input_1 | 6055–6078 | 23 | 6 / 6 | 1 | 0 / 0 |
| input_2 | 6091–6122 | 31 | 9 / 9 | 1 | 0 / 0 |
| input_3 | 6136–6175 | 39 | 12 / 12 | 1 | 0 / 0 |
| input_4 | 6190–6237 | 47 | 15 / 15 | 1 | 0 / 0 |
| input_5 | 6253–6308 | 55 | 18 / 18 | 1 | 0 / 0 |
| shared / triple_main | 6349–6539 | 190 | 63 / 63 | 3 | 5 / 5 |
| shared / u1_remainder | 6546–6609 | 63 | 21 / 21 | 1 | 0 / 0 |
| trailing_0 | 6650–6705 | 55 | 18 / 18 | 1 | 0 / 0 |
| trailing_1 | 6716–6763 | 47 | 15 / 15 | 1 | 0 / 0 |
| trailing_2 | 6773–6812 | 39 | 12 / 12 | 1 | 0 / 0 |
| trailing_3 | 6822–6853 | 31 | 9 / 9 | 1 | 0 / 0 |
| trailing_4 | 6861–6884 | 23 | 6 / 6 | 1 | 0 / 0 |
| trailing_5 | 6892–6906 | 14 | 3 / 3 | 1 | 0 / 0 |

Each prefix stage starts the next output row and advances all earlier outputs. Their fixed destination register groups are a=`18/29/31`, b=`8/15/22`, c=`11/13/12`, d=`0/14/1`, e=`23/24/30`, f=`25/26/9`; `.L394` initializes g=`7/16/10`. Trailing stages finish b through g in that same map. All actual multiplication results feed separate additions; no stage transition resets an active sum. Output lines 6918–6963 contain all 21 `ST1W`, matched to destination rows 0–6 and their three vector offsets.

## Three column-end constraints and all 21 chains

C56 source 1531–1540, 1582–1591 and 1633–1642 has exactly three empty volatile asm templates, each with 21 read-only `w` inputs, no outputs and a `memory` clobber. The returned helper has **no APP/NO_APP marker or separately identifiable emitted fence instruction/PC**. Mapping status is `not_separately_identifiable`; actual surrounding dataflow supplies the evidence.

| Boundary | Last current-column FADD | First next-column load | Actual emitted separation |
| --- | --- | --- | --- |
| column 0 → 1 | 6406, d2 | coefficient 6408; input 6412 | all 21 definitions precede both |
| column 1 → 2 | 6463, a2 | input 6470; coefficient 6472 | all 21 definitions precede both; five STRZ occur between |
| column 2 → next iteration | 6531, d2 | next main 6351 via backedge 6539; or u1 6548 | only scalar progress/branch intervene |

The actual `schedule_tightened` and three boundary booleans are true. This describes emitted order and dependencies, not a hardware barrier or a promise that the CPU has completed every add before issuing a later load. Original AC loads column 1 at 6409 and column 2 at 6416 while other column-0 chains continue; AE visibly separates them. The third boundary was checked independently and is not claimed to be a new difference at every instruction.

Input vector-0/1/2 load lines are `[6351,6355,6371]`, `[6412,6429,6447]`, `[6470,6474,6493]`. Coefficient loads in output-row a..g order are `[6353,6374,6383,6384,6358,6364,6369]`, `[6408,6414,6415,6423,6410,6413,6430]`, `[6475,6476,6472,6503,6480,6484,6496]`. Their scalar addresses map to input `row + ik + column + vector*lanes` and kernel row `t-r`, with column offsets 0/4/8 bytes.

All 63 main FADDs appear exactly once in this table. Each chain preserves the previous sum, including actual register renames, `MOV 6466` and five stack transfers. A lightweight walk of the emitted register/stack text also matched this manually derived table and the final entry-register map; it performs no numerical convolution.

| Accumulator | Entry / exit Z register | column 0 FADD | column 1 FADD | column 2 FADD |
| --- | --- | ---: | ---: | ---: |
| a0 | z18 | 6357 | 6421 | 6507 |
| a1 | z29 | 6391 | 6436 | 6483 |
| a2 | z31 | 6393 | 6463 | 6530 |
| b0 | z8 | 6382 | 6422 | 6523 |
| b1 | z15 | 6399 | 6440 | 6485 |
| b2 | z22 | 6396 | 6458 | 6519 |
| c0 | z11 | 6397 | 6424 | 6478 |
| c1 | z13 | 6402 | 6435 | 6518 |
| c2 | z12 | 6405 | 6459 | 6525 |
| d0 | z0 | 6390 | 6427 | 6508 |
| d1 | z14 | 6404 | 6444 | 6528 |
| d2 | z1 | 6406 | 6462 | 6531 |
| e0 | z23 | 6362 | 6428 | 6490 |
| e1 | z24 | 6363 | 6439 | 6497 |
| e2 | z30 | 6395 | 6452 | 6499 |
| f0 | z25 | 6372 | 6461 | 6511 |
| f1 | z26 | 6368 | 6445 | 6491 |
| f2 | z9 | 6375 | 6454 | 6501 |
| g0 | z7 | 6379 | 6432 | 6526 |
| g1 | z16 | 6376 | 6446 | 6529 |
| g2 | z10 | 6381 | 6457 | 6515 |

## Complete stack and ABI review

The five slots at `SP + 848 + n*VL` store completed **second-column** sums and reload them during the third column. They are the only Z memory instructions anywhere in the helper:

| Slot | Sum | STRZ | LDRZ | Final third-column FADD |
| ---: | --- | ---: | ---: | ---: |
| 0 | b2 | 6469 | 6516 | 6519 |
| 1 | c2 | 6464 | 6520 | 6525 |
| 2 | d2 | 6465 | 6527 | 6531 |
| 3 | f2 | 6467 | 6500 | 6501 |
| 4 | g2 | 6468 | 6502 | 6515 |

Both slot-base aliases were traced: x12 is SP+848 at 6450 for stores; x0 is SP+848 at 6498 for loads. All stores precede their own loads on every main path. All five final sums return to live registers before the main backedge or remainder. There is no vector traffic at prefix/trailing transitions, shared entry/exit, u1 entry/exit, t advancement, zero-init or output; no Q/predicate stack access exists. Thus the parent peripheral traffic has disappeared while the five live vector slots and the main 5/5 traffic remain.

Low 64-bit ABI saves are separate: D8/D9 at 5776↔7049, D10/D11 at 5782↔7052, D12/D13 at 5787↔7055, D14/D15 at 5796↔7058, offsets 112/128/144/160. Prologue allocates 848+5VL at 5708/5710. All normal/tail/fallback exits release both portions, and each branch restores only registers actually saved on that path.

Fixed/indirect scalar stack accesses were read throughout. Pointer-cache aliases include SP+800, SP+576/SP+608 and SP+520; scalar state ends with stride at 840–847. The five vector slots start at 848. Incoming arguments are read through SP+5VL+848..880, i.e. original SP+0..32; tail-call width is written to original SP+0 before frame release. GPR/pointer/counter traffic and outgoing arguments are not classified as vector spill. Stack alignment remains 16-byte aligned for the reviewed VLs.

## Control flow, bounds and reset

`kw<=2` takes 6343–6344 to `.L426`, sets ik=0 at 7112 and skips the triple. The main starts ik=0 at 6347, consumes three legal columns, advances ik by 3 at 6532–6533 and repeats only when `kw-ik>2`. The residual equality test is 6541–6542. `.L409` then executes zero, one or two times, incrementing ik by 1 at 6584 and stopping at kw. For kw 3/4/5 this is one main plus 0/1/2; for 6/7/8 it is two main plus 0/1/2; 15/81 exercise longer main loops. No remainder loads or slot reads occur on the zero-remainder route.

Each t begins at `.L410`. Kernel and input origins are rebuilt before main, and its rolling x2/x3/x4 pointers and index are reset. `.L408` advances coefficient addresses by 4*kw and input addresses by 4*stride; t increments from 6 to kh. Therefore kh=7 executes one shared row, kh=8 two. Final pointer increments do not cause a further dereference once the t/main guard fails. Each horizontal tile reaches `.L423` afresh, initializes prefix sums, reloads original kernel origins at `.L394` and initializes g. The 3*lanes output step and cached input offsets advance together before backedge 7048; no tile inherits prior output sums.

For full tiles, `ow-i>=3*lanes`; the furthest lane `i+ik+3*lanes-1` is at most `ow+kw-2` for ik<kw. Shared coefficient row t-r stays in 0..kh-1. Trailing input rows kh..kh+5 match the seven-output window. The twelve u1 loops retain bounded column progression and increasing kernel-row order. The defensive kw<=0 path zeroes a..f at 7115–7133, initializes g at `.L394`, skips arithmetic and writes zero sums without reading uninitialized vector slots.

kh<=6 branches at 5745–5746 to `.L391`: rowquad call 7214 then rowtriple tail call 7239 at base+4*stride. The 3*lanes width guard 5757–5758 can bypass SVE/D saves; `.L455` supplies i=0 and remaining ow. After full tiles D registers are restored before `.L393`. A positive horizontal remainder calls rowquad at 7164 for rows 0–3, then tail-calls rowtriple at 7201 for rows 4–6, both using base+i and matching destination offsets. These are actual caller boundaries; the separate dispatch review remains root-owned.

No helper-schema mismatch or unsupported lowering was found. `assembly-helper-review.json` sets helper-specific completion flags true and leaves `review_complete=false`, `dispatch_reviewed=false`, `dispatch_pending=true`. Only this report, the helper fragment and `helper-text-counts.json` were written. No raw/source/tool/record/baseline changes, network action, accept, freeze, package or promotion were performed. Main usage last read 20%, below the 40% stop threshold; no reset was used. **FINAL / STOP.**
