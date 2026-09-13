# AT C63 actual shared-loop assembly review

Reviewer `/root/c61_review_resume`, 2026-09-13. Original AT **1590603**, C63 source `d78a863eb49c85d415420819e4b6ef8379260a34ad9f118da5bab1bdca7e94a8`. Read actual returned `raw/conv2d-sve.s`; C62 comparison uses the already reviewed AR actual assembly counts in `../../sep13ar-checks/C62-row7x2shared4/TARGETED_ASSEMBLY_REVIEW.md`. Only this document was written; no operator execution, compilation, acceptance, freeze or benchmark.

**No targeted assembly blocker found.** The actual row-wise schedule greatly reduces C62's scalable spilling, while retaining one temporary spill pair. This supports the scheduling hypothesis at code-generation level, but it does not establish improvement against C7 or qualify C63 for promotion.

Counts include mnemonic lines and branches/ret, excluding labels, directives and CFI. Inclusive line ranges refer to original returned `.s`; u1 includes its common comparison label.

LOCAL_USER Region LOCAL_USER Actual C63 range / instructions LOCAL_USER C63 arithmetic / array loads LOCAL_USER Z stack load/store LOCAL_USER C62 reference LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER
LOCAL_USER quad `.L407` LOCAL_USER 6661–6822 / **161** LOCAL_USER 56 FMUL, 56 FADD, 8 LD1W, 28 LD1RW LOCAL_USER **1 / 1** LOCAL_USER 211 instructions; 17 / 17 LOCAL_USER
LOCAL_USER u1 `.L409` LOCAL_USER 6827–6876 / **48** LOCAL_USER 14 FMUL, 14 FADD, 2 LD1W, 7 LD1RW LOCAL_USER **0 / 0** LOCAL_USER 48 instructions; 0 / 0 LOCAL_USER
LOCAL_USER entire rowseven helper before .size LOCAL_USER 5705–7875 / **1990** LOCAL_USER 392 FMUL, 392 FADD, 102 LD1W, 196 LD1RW LOCAL_USER **1 / 1** LOCAL_USER 2260 instructions; 98 / 86 LOCAL_USER

The complete returned assembly scan finds **zero fused floating-point instructions**, including negative/scalar/widening variants and fmmla. Ordinary separate FMUL/FADD remain. The quad has no EXT or new tail load; all eight original input windows use p0/z.

Actual `.L410` checks kw>3 before quad and resets seven kernel pointers. Quad input windows use x9/x8 at column zero, x10/x28 at one, x23/x22 at two and x21/x18 at three, each indexed by x0*4. Kernel offsets remain 0/4/8/12 bytes. x0 advances by four, coefficient pointers advance by 16, and cmp x24/x0 closes the quad. The original full-column count initializes u1 via w20; `.L546` and `.L409` handle zero through three residual columns, with scalar-column increment one. t advances one row after the shared stage. Actual arithmetic and loads match the fourteen-chain/four-column source work; root separately verifies numeric correctness. This is not an exhaustive symbolic proof of every chain or boundary path.

The sole scalable spill is at **6754 STR z4,[x11]** and **6759 LDR z26,[x11]**, where x11 is formed from **sp+688**. The value is a partially updated accumulator saved while the last-column coefficient and other rows' broadcasts are scheduled, then reloaded before its final addition. There are no other LDR/STR Z instructions in the helper. This is therefore a genuine reduction from C62's many loop and transition spills, but not a spill-free loop.

Frame is **688 bytes + 1 VL**, established by 5708 ADDVL sp,-1 and 5710 SUB sp,688. Three return paths balance ADDVL sp,+1 / ADD sp,688 at 7618/7620, 7816/7818 and 7853/7855. At VL16/32/64 it is 704/720/752 bytes, versus C62's 960/1232/1776. D8…D15 low-64-bit ABI saves remain STP pairs at 5824/5829/5833/5838 and matching LDP restores at 7586/7589/7592/7595. These ABI operations and scalar/address stack traffic are distinct from scalable temporary spills.

For the identical 2VL-by-four-column tile, C63 removes 50 static loop instructions relative to C62 (211→161), principally reducing Z stack traffic from 34 to two instructions and its address setup. For six VL output width by four columns, C63 uses three quads =483 instructions versus C7's four 3VL/two-column pairs =492. C63 still has more coefficient broadcasts for that equal work (84 versus56). This static comparison excludes boundary/remainder/setup/cache/scheduling costs and is not a timing estimate or evidence that C63 beats C7.

Own AT numerical/compiler/allocation/source/stage/job acceptance remains the root's responsibility. AU must measure C63 against unchanged current C7 controls before any performance conclusion.
