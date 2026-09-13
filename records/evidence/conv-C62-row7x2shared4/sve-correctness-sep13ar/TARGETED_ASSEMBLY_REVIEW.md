# AR C62 actual shared-loop assembly review

Reviewer `/root/c61_review_resume`, 2026-09-13. Original AR **1590510**, C62 source `e6cc9bdb4c14e9f6982f687123379ebf5dfb2013777f7bb076c04edd4827dc8a`. Read actual returned `raw/conv2d-sve.s`, compared against C7 source-candidate AH `../../sep13ah-checks/C58-row7boundaryu2/raw/conv2d-sve.s`. Only this review was written. No operator execution, compilation, acceptance, freeze or performance measurement.

**No targeted arithmetic/code-shape blocker found, but significant scalable spilling remains.** Reducing the tile to fourteen accumulators did not make this four-column schedule spill-free. Actual speed must be measured; smaller total helper text is not an efficiency result because the tile computes fewer output columns.

Counts are actual mnemonic lines, including branches and ret, excluding directives/labels/CFI. Inclusive original line ranges include loop control.

LOCAL_USER Region LOCAL_USER C62 range / instructions LOCAL_USER Actual C62 work LOCAL_USER C7 counterpart LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER
LOCAL_USER shared quad `.L407` LOCAL_USER 6751–6962 / **211** LOCAL_USER 56 FMUL, 56 FADD, 8 LD1W, 28 LD1RW, **17 LDR Z / 17 STR Z** LOCAL_USER pair 6886–7009: 123 instructions, 42/42/6/14, no Z spill LOCAL_USER
LOCAL_USER u1 remainder `.L409` LOCAL_USER 6984–7032 / **48** LOCAL_USER 14 FMUL, 14 FADD, 2 LD1W, 7 LD1RW, no Z spill within loop LOCAL_USER 7013–7077: 63 instructions, 21/21/3/7, no Z spill LOCAL_USER
LOCAL_USER complete rowseven helper before .size LOCAL_USER 5705–8145 / **2260** LOCAL_USER 392 FMUL, 392 FADD, 102 LD1W, 196 LD1RW; **98 LDR Z / 86 STR Z** LOCAL_USER 5705–8333 / 2448; 9 LDR Z / 15 STR Z LOCAL_USER

The entire returned `.s` has **zero** fused floating-point mnemonics (including vector/scalar/negative/widening variants and fmmla). The actual quad uses ordinary independent FMUL/FADD. There is no EXT or packed lane-broadcast transformation in the shared loop.

At each shared row `.L410`, `cmp w19,3; ble .L426` handles kw below four; otherwise seven coefficient pointers are reset before quad. Input pairs use base windows x9/x8 at column zero, x10/x28 at one, x23/x22 at two, and x21/x18 at three, each indexed by x0*4. Coefficient offsets are 0/4/8/12 bytes. Quad advances x0 by four and each coefficient pointer by 16, then compares against the complete-column bound at x24. After quad, the original scalar-column position in w20 initializes u1. `.L406` skips u1 when empty; `.L409` advances its index by one, covering residual counts zero through three. Width is 2VL and the source guard ensures each vector window remains in range. Actual loop counts match the source's fourteen chains with four column updates; this targeted review does not claim a full symbolic enumeration of every chain or all twelve boundary stages.

Spill/frame observations:

- Prologue 5708 `addvl sp,sp,#-17` and 5710 `sub sp,sp,#688` gives **688 bytes + 17 VL**, versus C7's 720 + 3 VL. At VL16/32/64 this is 960/1232/1776 bytes, versus 768/816/912. Three return paths restore +17VL and +688 at 7859/7861, 8086/8088 and 8123/8125.
- Shared stack addresses are based at sp+688 plus scalable slots. Slots 0…12 hold thirteen accumulator chains, while one accumulator stays in z28. Slots 13…16 hold four temporary broadcast coefficients. The quad therefore has 13 accumulator loads/stores plus four coefficient loads/stores = **17/17**. Representatives: coefficient stores at the beginning of `.L407` via ADDVL #13/#14/#15/#16, accumulator slot4 load/store around the first output pair, and slot13…16 reloads near the final two output rows.
- Quad entry spills several accumulators before `.L407`, and quad exit reloads seven chains before `.L406`. Remainder entry loads five chains and remainder exit stores them. Therefore its zero loop-body spills must not be described as zero remainder-path stack traffic. Other boundary transitions also spill; the full-helper **98/86** counts are static occurrences across alternative paths, not dynamic events per call.
- ABI D8…D15 low-64-bit saves remain four STP pairs at 5824/5829/5833/5838 and LDP restores at 7827/7830/7833/7836. They are separate from scalable Z spills. Scalar/address stack traffic remains present.

For equal shared work of **six VL output width by four kernel columns**, C62 requires three quad iterations (3×211 = **633** static instructions), while C7 requires four pair iterations (4×123 = **492**). Both do 168 FMUL/FADD and 24 input-vector loads; C62 uses 84 broadcasts versus C7's 56 and adds 102 loop-body Z load/store instructions versus zero. This is a 28.66% increase in static loop instructions for that work; it excludes loop entry/exit, boundaries, cache and scheduling effects and is **not a measured time estimate**.

Root must independently finish numerical/stage/job/compiler evidence acceptance. Retain this schedule/spill evidence regardless of AS performance outcome; no speed or promotion claim is made here.
