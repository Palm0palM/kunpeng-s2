# AV C64 actual boundary/shared-loop assembly review

Reviewer `/root/c61_review_resume`, 2026-09-13. Original AV **1590847**, source `fcbfaf198157718355bee19a5cf9cab5e567508e69f38050595e146b3d57e421`. Read actual returned `raw/conv2d-sve.s` and compared targeted regions against C7 source-candidate AH actual assembly. Only this document edited; no compilation, operator, tests, network, acceptance or freeze.

**No targeted assembly blocker found.** Boundary reordering reduces some scalable spill instructions and one VL of frame, but does not eliminate input5/transition spills. Main shared2/u1 actual operation counts match C7. These static findings are not speed or promotion evidence.

Counts include mnemonics/branches/ret and exclude labels/directives/CFI. Inclusive line ranges refer to original assembly.

LOCAL_USER Region LOCAL_USER C64 actual range / instructions LOCAL_USER C64 FMUL/FADD/LD1W/LD1RW LOCAL_USER Z load/store in loop LOCAL_USER C7 reference LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER
LOCAL_USER input5 pair `.L405` LOCAL_USER 6732–6846 / **114** LOCAL_USER 36/36/6/12 LOCAL_USER **2/2** LOCAL_USER 6734–6851 /117; 3/3 LOCAL_USER
LOCAL_USER shared2 `.L407` LOCAL_USER 6881–7004 / **123** LOCAL_USER 42/42/6/14 LOCAL_USER **0/0** LOCAL_USER 6886–7009 /123; 0/0 LOCAL_USER
LOCAL_USER shared u1 `.L409` LOCAL_USER 7008–7072 / **63** LOCAL_USER 21/21/3/7 LOCAL_USER **0/0** LOCAL_USER 7013–7077 /63; 0/0 LOCAL_USER
LOCAL_USER trailing0 pair `.L412` LOCAL_USER 7098–7206 / **108** LOCAL_USER 36/36/6/12 LOCAL_USER **0/0** LOCAL_USER 7103–7211 /108; 0/0 LOCAL_USER
LOCAL_USER trailing1 pair `.L414` LOCAL_USER 7311–7403 / **92** LOCAL_USER 30/30/6/10 LOCAL_USER **0/0** LOCAL_USER 7319–7411 /92; 0/0 LOCAL_USER
LOCAL_USER trailing2 pair `.L416` LOCAL_USER 7491–7567 / **76** LOCAL_USER 24/24/6/8 LOCAL_USER **0/0** LOCAL_USER 7501–7577 /76; 0/0 LOCAL_USER

Full helper is 5705–8313 before `.size`, **2428 instructions including ret**, versus C7's2448. Both have 546 FMUL,546 FADD,147 LD1W,182 LD1RW across all paths. Full C64 helper has **7 LDR Z /13 STR Z**, versus C7's9/15. Whole returned assembly fused-float scan (vector/scalar/negative/widening variants and fmmla) finds **zero**. Separate ordinary multiply/add is retained.

Input5 now stores one accumulator at **6728** to sp+720 before `.L405` (alternate entry **8149**). In each pair iteration, **6778 LDR z1** reads that accumulator before its first-column update, **6795 STR z1** writes it, **6829 LDR z1** reads it for the second-column update, and **6831 STR z0** writes the updated value. All four accesses resolve to the same sp+720 slot through x3/x0. This is a change in spill placement/role relative to C7's three temporary-product pairs, not a claim of zero spill cost. Column step remains two and observed operation counts are six rows×three vectors×two columns.

Trailing pair bodies above have no internal Z stack accesses, but transitions still do:

- Before trailing0, **7092 STR z4** to sp+720 and **7095 STR z9** to sp+720+VL; **7209/7210** reload them. Odd entry **8121** joins the same setup.
- Before trailing1, **7309** stores z4, **7406** reloads it; alternate entry **8126** stores it as well.
- Before trailing2, **7488/7489** store z9/z4 and **7569/7570** reload; alternate entry **8136/8137** preserves the same two slots.

These paths account for the full static7/13 counts. Alternative branches mean static occurrences cannot be read as dynamic events per call. Legacy C7 likewise had transition spills; no full-stage spill-free claim is appropriate.

Frame is **720 bytes +2VL**: prologue5708 ADDVL sp,-2 and5710 SUB sp,720. C7 used720+3VL. Balanced returns restore +2VL/+720 at8036/8038,8254/8256 and8291/8293. VL16/32/64 frame sizes are752/784/848 bytes, versus C7's768/816/912. D8…D15 low64-bit ABI saves remain STP pairs5830/5835/5840/5845, restored8004/8007/8010/8013; they are distinct from scalable spills. Scalar/address stack traffic also remains.

Shared main columns still advance by two; u1 advances by one for the original odd remainder. No additional EXT, tail window, predicate or arithmetic work is present in those regions. Counts alone do not mean identical machine code/register assignment. This review intentionally targets input5, first trailing transitions, shared2, frame and fused operations; numerical/stage/compiler/allocation/source/job acceptance is independently owned by root. All performance conclusions await matched measurement.
