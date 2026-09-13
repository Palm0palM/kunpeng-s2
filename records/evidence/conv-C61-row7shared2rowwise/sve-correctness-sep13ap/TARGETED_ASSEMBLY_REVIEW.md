# AP C61 returned assembly review

Reviewer `/root/c61_review_resume`, 2026-09-13. Original AP job **1590209**, source C61-row7shared2rowwise (`40a3184f346983864593de73b3e3ade7973b1af9d2d273d566432e882a6904fa`). Read the actual returned `raw/conv2d-sve.s` and parent C7 source-candidate AH `../../sep13ah-checks/C58-row7boundaryu2/raw/conv2d-sve.s`. No compilation, execution, acceptance, freeze, or performance measurement was performed by this review.

**Conclusion: no targeted assembly blocker found.** The row-wise source reorder produces a changed actual schedule with the same shared-pair arithmetic/load counts and no shared-loop Z spills. It does not reduce the full helper's existing spill count or frame, so no speedup follows from this static result. Root must separately accept the actual numerical/stage/compiler/job evidence and measure performance.

Instruction counts below count mnemonic lines (including branches and `ret`) and exclude labels, alignment directives and CFI. Ranges are inclusive original `.s` line numbers; remainder ranges include the common compare/back-edge label.

LOCAL_USER Region LOCAL_USER C61 actual range / instructions LOCAL_USER Parent C7 actual range / instructions LOCAL_USER Arithmetic and input operations LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER
LOCAL_USER Shared two-column `.L407` LOCAL_USER 6887–7010 / 123 LOCAL_USER 6886–7009 / 123 LOCAL_USER Each: 42 FMUL, 42 FADD, 6 LD1W, 14 LD1RW LOCAL_USER
LOCAL_USER Shared single-column remainder `.L409` LOCAL_USER 7014–7078 / 63 LOCAL_USER 7013–7077 / 63 LOCAL_USER Each: 21 FMUL, 21 FADD, 3 LD1W, 7 LD1RW LOCAL_USER
LOCAL_USER Complete `conv_sve_rowseven` helper, before `.size` LOCAL_USER 5705–8334 / 2449 LOCAL_USER 5705–8333 / 2448 LOCAL_USER Each: 546 FMUL, 546 FADD, 147 LD1W, 182 LD1RW LOCAL_USER

The pair retains column induction `add x0,x0,2` and byte coefficient offset `add x2,x2,8`, ending at `cmp x17,x0; bne .L407`. GCC interleaves operations for the two columns instead of preserving the source scopes literally. Early pair loads use the three original windows and their one-column-shifted counterparts: LD1W at x12/x10/x11 and x14/x16/x15. All use p0/z; there is no EXT or new tail load. The seven coefficient broadcasts for each column are interleaved with separate FMUL/FADD. The remainder increments its column by one and executes the original three-window/seven-coefficient work. Neither region contains LDR/STR Z, stack references, or extra data loads beyond the counted LD1W/LD1RW.

A scan of the complete returned assembly for fused floating-point mnemonics (`fmla/fmls/fmad/fmsb`, negative variants, scalar fused forms, widening fused forms and `fmmla`) finds **zero**. Thus the observed actual compiler output retains separate multiply and add instructions. This targeted review does not claim a full symbolic proof of all 21 chains or exhaustive boundary-path verification; that scope is supported by the candidate's own remote bitwise tests and root numerical review.

Frame and spills remain the same size/count as C7:

- Prologue 5708 `addvl sp,sp,#-3` and 5710 `sub sp,sp,#720`: **720 bytes + 3 VL**. Return paths have paired `addvl sp,sp,#3` and `add sp,sp,720` at 8051/8053, 8275/8277, and 8312/8314.
- Full helper has **9 LDR Z and 15 STR Z** in C61 and C7. These are static instruction occurrences across all paths, not per-call execution counts. Input-5 temporary spill representatives are stores 6752/6764/6791 and reloads 6778/6781/6792, through pointers based at `sp+720`. Shared pair/remainder have none. Trailing transitions retain z6/z1 saves such as 7099/7101 and reloads 7215/7216; other paths repeat these saves/reloads, including mutually exclusive entry paths around 8137 onward.
- ABI low-64-bit D8–D15 saves remain four STP pairs at 5830/5835/5840/5845; matching LDP pairs are 8019/8022/8025/8028. These ABI saves are distinct from Z temporary spills. Scalar/address stack traffic is also present and must not be described as spill-free.
- Complete-helper mnemonic differences relative to C7 are +3 MOV, −4 LDR, +2 LDP, giving net **+1 instruction**; all other mnemonic counts match. This is a small register/address scheduling change, not an instruction-count reduction.

This report covers actual shared loops, fused arithmetic, helper size, frame and representative spill paths. It intentionally does not enumerate all twelve boundary loops or assert any performance improvement.
