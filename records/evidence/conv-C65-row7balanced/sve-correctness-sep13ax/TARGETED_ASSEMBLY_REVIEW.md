# AX C65 actual production assembly review

Reviewer `/root/c61_review_resume`, 2026-09-13. Original diagnostic job **1591086**, candidate source SHA256 `a855c14b81c00f3d398ac36c5ece6726e15235f18ebf3fe4746570da25a7f874`. Reviewed returned uninstrumented `raw/conv2d-sve.s`, with C7 reference `.runs/conv/sep13ah-checks/C58-row7boundaryu2/raw/conv2d-sve.s`. Only this document edited for the returned-assembly review; no compilation, operator execution, network, acceptance or freeze.

**No targeted assembly blocker found.** The new scalar dispatcher implements runtime-team partitioning and contiguous same-group slices; the original seven-row arithmetic retains the checked C7 loop counts and spill/frame profile. This is the source author's assembly review, complementary to root's independent review and the independently implemented numerical/entry/exact-once checks. Static instruction counts do not establish speed or promotion.

## Target isolation and runtime synchronization

`conv_sve_dispatch_lanes` at lines 8–15 is under `.arch armv8-a+sve` (line 6) and consists of exactly **CNTW x0; RET** (11–12). The generic architecture is restored at 8348 before the OpenMP outlined functions. `conv2d._omp_fn.0` at 8533–8787 contains no CNTW, Z/predicate operations or floating-point arithmetic. Its frame is **208 scalar bytes** and it has **205 static instructions**, including ret, with 3 UDIV, 3 MSUB, 3 MADD and 14 BL across all paths. These counts are descriptive only.

The compiler places the lane query inside the winning `single` branch: GOMP_single_start at 8570, conditional branch at 8572, lane-helper call at 8573, multiply by three via ADD at 8574, and shared block store at 8575. **The actual binary queries lanes only in the single winner**, despite source positioning of the local query before `single`. GOMP_barrier at 8577 publishes that common block. omp_get_num_threads at 8579 and omp_get_thread_num at 8583 obtain the actual team and worker; the common block is reloaded at 8585. This preserves one partition domain for every worker. It does not justify claiming one executed CNTW per worker.

The `conv2d` launch passes zero requested thread count and flags to GOMP_parallel (8954), so the partition is based on the actual runtime team rather than a fixed 38-thread assumption.

## Actual integer partition and coalescing

With B=3*lanes, T=ceil(ow/B), G=ceil(oh/7), N=G*T, P=actual team and t=worker, the actual UDIV/MSUB/CINC instructions form T, then quotient q=N/P and remainder r=N%P. CSEL chooses min(t,r); MADD forms begin=t*q+min(t,r). CINC using the still-live comparison flags adds (t<r), followed by ADD q for finish. It does not use N*t. The cursor/finish comparison skips empty intervals before helper calls.

At `.L573`, UDIV and MSUB recover group=cursor/T and first_tile=cursor%T. CSEL computes take=min(finish-cursor,T-first_tile), so one call consumes all of a worker's contiguous tiles in the current group. Scalar address arithmetic computes first_row=7*group and first_column=first_tile*B while retaining original full input/output row strides. The last-column endpoint uses CSEL to select ow when last_tile==T; otherwise it selects last_tile*B. The selected difference becomes the helper's slice width. The compiler speculatively computes last_tile*B before selection, unlike the source conditional expression, but this still fits target 64-bit size_t under int32 positive dimensions and legal SVE vector lengths (the rounded endpoint is at most ow+B-1). The selected endpoint and first column are within ow, so the 32-bit width subtraction remains within the positive CONVINT range.

Full groups call the unchanged conv_sve_rowseven once per slice. The remaining-row dispatch retains 6=quad+pair, 5=quad+prefix, 4=quad, 3=triple, 2=pair and 1=prefix. These branches rejoin `.L579`, advance cursor by take and compare against finish. The final partial column tile is clamped, and empty worker intervals have no helper invocation. The assembly therefore supports the intended partition/control-flow mechanism; observed numerical correctness and exact-once output coverage remain separate diagnostic evidence.

## Original arithmetic helper comparison

Counts below exclude labels/directives/CFI and include instruction mnemonics, branches and ret where present. Ranges are inclusive in the returned assembly. The new metadata helper shifts local label numbering: C65 shared pair is `.L408`, not C7 `.L407`.

LOCAL_USER Region LOCAL_USER C65 actual lines / instructions LOCAL_USER FMUL / FADD / LD1W / LD1RW LOCAL_USER Z LDR / STR LOCAL_USER C7 actual comparison LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER
LOCAL_USER Shared pair `.L408` LOCAL_USER 6897–7020 / **123** LOCAL_USER **42 / 42 / 6 / 14** LOCAL_USER **0 / 0** LOCAL_USER .L407, 6886–7009, same counts LOCAL_USER
LOCAL_USER Shared remainder `.L410` LOCAL_USER 7024–7088 / **63** LOCAL_USER **21 / 21 / 3 / 7** LOCAL_USER **0 / 0** LOCAL_USER .L409, 7013–7077, same counts LOCAL_USER
LOCAL_USER Full seven-row helper LOCAL_USER 5716–8344 / **2448** LOCAL_USER **546 / 546 / 147 / 182** LOCAL_USER **9 / 15** LOCAL_USER 5705–8333, same counts LOCAL_USER

Prologue 5719 ADDVL sp,-3 and 5721 SUB sp,720 retain **720 bytes + 3 VL**, matching C7. The three return paths restore +3VL/+720 (8059/8061, 8285/8287, 8322/8324). Scalable spills elsewhere in the full helper remain; the zero counts above apply specifically to shared pair/remainder. Counts and frames match, but this is not a claim of byte-identical machine code or identical scalar register allocation.

A whole-file scan of scalar/vector fused multiply-add/subtract, negative and widening variants and FMMLA found **zero** fused floating-point instructions. Separate FMUL/FADD remains. No new arithmetic helper or vector spill was introduced into the scalar dispatcher.

The first lightweight text counter used the old shared label and failed to locate a range; subsequent counts used the observed C65 `.L408`/`.L410` labels. This was text parsing only, with no operator run. Root independently obtained the same principal counts. Performance remains for the separately authorized matched remote measurement.
