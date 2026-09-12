# C45-row4dup4 independent source review

Reviewed the actual `source/conv2d.c` diff against C26-row4loads, the containing quad helper and unchanged two/one-column suffix, plus this candidate's PLAN/STATIC_REVIEW and the prior design notes. No compilation, operator test, parser test, SSH, submission or source modification was performed. Only this review is new. The prepared checkpoint identifies conv2d.c as `d428611f068b81befa4412a6bd11480468e3b7816906647d15cc0e9265c866a5`; this is transcribed from the existing record, not a repeated hash audit.

No source-level blocking problem was found. The candidate remains prepared and unverified; this review does not establish actual GCC10.3.1 acceptance, instruction selection, register allocation, correctness or performance.

## Scope and numerical order

The actual diff inserts one150-line block at the existing quad shared t=3..kh-1 stage. The original two-column and single-column loops follow it unchanged. No other quad stage, helper, dispatch, non-SVE/invalid path, output initialization/store, resource or floating-point flag changes appear in the kernel diff.

The new block is q-major: q=0,1,2,3 are separate literal scopes; each q visits input vector n=0,1,2,3 and updates a/b/c/d at that n. Every output uses its own ka/kb/kc/kd coefficient consistently; no row/vector accumulator substitution was found. For fixed output r and n, its chain receives ik+0,ik+1,ik+2,ik+3, then the next four-column block, then the original two/one remainder. The outer t sequence and kernel mapping a=t, b=t-1, c=t-2, d=t-3 do not change. The nested independent svmul and svadd retain the original operands and dependency chain; no partial sums, FMA intrinsic, lane-multiply intrinsic, inline asm or prefetch is introduced. Actual absence of compiler-generated FMA still requires target assembly under the preserved strict flags.

The four LD1RQ calls load ka/b/c/d+ik. The sixteen DUP calls select literal element0..3 from the corresponding pack. Per the ACLE semantics already documented in the design, the all-true predicate loads four consecutive f32 coefficients into the repeating128-bit pattern, and DUP broadcasts the selected whole-vector element. Every legal SVE width contains those first four elements; no variable/out-of-range lane selection or whole-VL coefficient overread is introduced. Exact target compiler acceptance remains a separate diagnostic gate.

## Bounds and remainder proof

At the new loop, ik starts0 and maintains0<=ik<=kw. The positive-kernel path with `kw-ik>=4` implies ik<=kw-4; subtraction is nonnegative and the increment ik+4<=kw cannot overflow int. kw1/2/3 skip the block. On exit,0<=kw-ik<=3; the original pair loop consumes two if present and the scalar-column suffix consumes the remaining one. kw4,5,6,7 therefore exercise remainder0,1,2,3 without omission or duplication.

The four coefficient elements end at ik+3<=kw-1 in each valid row. For L=svcntw(), the original full-block predicate gives i+4L<=ow. New input window(n,q) spans i+ik+nL+q through i+ik+(n+1)L+q-1. Its maximum at n=3,q=3 is i+ik+4L+2 <= ow+kw-2 = inputWidth-1. Every earlier window is smaller. No full fifth vector is loaded, and the final +3 window is legal even at the last full output block and last four-column kernel block.

The shared t loop and its size_t row-address calculations are unchanged, so the original legal input-row range and global output-row stride remain intact. The inserted block adds only within-row offsets; it does not change OMP ownership or create shared state. Existing helpers still handle all output-column and output-row tails, small kh and non-SVE execution.

## What the hypothesis actually changes

The inserted source contains four LD1RQ calls, sixteen DUP calls, sixteen complete input loads,64 ordinary multiply and64 independent add updates per four kernel columns. This matches the stated same-work comparison. It replaces16 scalar coefficient-load/broadcast operations with4 quadword loads plus16 explicit register broadcasts, so it must not be presented as a net12-instruction reduction or reduced coefficient bytes. Only target code can show whether DUP survives or is folded into indexed FMUL, whether q-major scheduling survives, and whether pack/broadcast/input lifetimes spill.

The design correctly retains C29/C32 as earlier failed four-column approaches and distinguishes their indexed operations/barriers from this explicit-DUP source. C6 profile r2 identifies the shared loop as a useful region; its LD1RW IP percentage and the recorded cache geometry do not prove a coefficient-cache bottleneck or predict improvement. C45's nominal26Z budget is not a no-spill result.

Proceed only through the planned independent target diagnostic after root GO: verify actual four/two/one-column paths and all seven quad stages, literal-lane API acceptance, strict bitwise/guard/readonly/canary results over VL16/32/64 and1/4 threads, actual ordinary/indexed FMUL and DUP/LD1RQ counts, transitions/whole-helper spills and FMA. If codegen merely recreates an old arrangement or gives no useful distinct hypothesis, preserve that result and do not automatically start performance measurement. No result or promotion is asserted here.
