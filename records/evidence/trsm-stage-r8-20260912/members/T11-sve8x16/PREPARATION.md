# T11-sve8x16 preparation

Prepared on 2026-09-12. Status: source prepared; target compilation, correctness checks, assembly review, and performance measurement have not run for this candidate.

Independent static review reported no concrete defect and is retained in `STATIC-REVIEW.md`. The text-only `git diff --no-index --check` emitted no whitespace diagnostics (it returned 1 for the differing files). These are not compilation or runtime correctness results.

## Origin and single hypothesis

- Copied all five source files from `.runs/trsm/T8-svepanel16/source/`: `trsm.c`, `bench_trsm.c`, `run.sh`, `README.md`, and `compat/kblas.h`.
- Only `source/trsm.c` was edited. The four supporting files retain the T8 content. A recursive text diff shows only the new kernel and the two large-update call-site changes below.
- Current best remains T8-svepanel16. The r6 T9 candidates and r7 T10-lhistbarrier did not advance the best version; T11 must be measured against the current round's T8-control12 in the same environment. Historical timings are not a replacement for that comparison.
- Single hypothesis: in the large blocked update, an 8-row by 16-column SVE kernel can reduce L coefficient broadcasts and L address work by applying each row's coefficient to two X vectors. It has sixteen accumulators. Two calls cover the original 16-row by 16-column region. The resulting change in X loads, register allocation, and scheduling is a performance risk to measure, not a demonstrated improvement.
- This is a large-update microkernel experiment. The previous T5/T6 panel pairing experiments concerned the small path and do not constitute a prior test of this kernel shape.

## Implementation boundary

- Added `update8x16_sve` at `source/trsm.c:601`, with the requested two-X-pointer signature and the same `target("arch=armv8-a+sve"), noinline` attributes as `update16x8_sve`.
- Each of sixteen sums starts at zero. Each increasing `k` loads `X0[k]` and `X1[k]`, then loads one scalar L coefficient per row and applies two explicit `svmla_n_f64_x` operations. Only after the full dot product does each output execute `C - sum`. No negative-FMA accumulation from C, reassociation, approximate division, or reciprocal changes were introduced.
- The existing 16-row outer loop remains at line 759. Its full 16-column loop calls the new kernel at lines 765 and 766, with the second call advancing both L and C by eight rows.
- The existing 8-row remainder loop remains at line 788. Its full 16-column loop calls the new kernel at line 794.
- `KB=256`, `CT=64`, OpenMP task division, synchronization, algorithm selection, allocation, packing, diagonal solve, small path, all existing kernels, and the four-row/scalar fallback code retain T8 behavior.

## Static index, tail, and fallback review

- `RHS=8` and `CT=64` keep every new `j` aligned to an 8-column panel. `j+16<=je` requires both eight-column vectors to lie in the current column tile. Each loop advances by 16, and the existing eight-column/scalar loop resumes from that same `j`, so no column is skipped or processed twice.
- Shared layout remains `[ceil(n/8)][KB][8]`. In packed mode, `X0=packed+(j/8)*KB*8`, `X1=X0+KB*8`, and both k strides are 8. The second panel is not treated as `X0+8`. Both full panels were populated by the unchanged diagonal solve before its existing implicit barrier.
- If shared allocation fails, `X0=B+kk*ldb+j`, `X1=X0+8`, and both k strides are `ldb`. Their input rows are `kk..end-1`; output rows begin at `end`, preserving separation between the solved inputs and C writes.
- The 16-row loop requires `ie-first_row>=16`; its two calls write rows 0..7 and 8..15. The 8-row loop requires `first_row+8<=ie`. Remaining complete eight-column vectors use `update16x8_sve` / `update8x8_sve`; fewer than eight columns use the unchanged scalar code.
- Four-row and smaller row tails still use the original update path. NEON and scalar fallbacks retain their original code and task coverage.
- The definition and all three new calls are within `#if TRSM_CAN_DISPATCH_SVE`. Calls are additionally within the worker's existing `if(use_sve)`, whose HWCAP check and worker-local `svcntd()==RHS` guard are unchanged. A non-SVE compilation excludes the new definition and references; target compilation still must verify this.
- No new allocation, shared layout, budget, official-size equality check, compiler flag, benchmark input, tolerance, timing region, or thread setting was added.

## Required work on an allocated supercomputer compute node

1. Compile with the actual target compiler and unchanged T8 flags, and check the non-SVE build branch there. This candidate has not been compiled on any machine.
2. Run a direct **bitwise** new-kernel check against two existing `update8x8_sve` calls using the same increasing-k explicit FMA semantics. Cover packed panels separated by `KB*8`, original strided rows with `X1=X0+8`, padded and distinct `lda`/`ldx`/`ldc`, guard zones, unchanged L/X, cancellation/signed finite data, and counts including 0, 1, 7, 8, 15, 255, and 256. Require the eight-double SVE guard before calling either SVE kernel.
3. Run end-to-end cases with **m>4096 and n>=16** that actually enter the new kernel, including a 16-row block and an 8-row remainder, complete and partial column tiles, and row/column padding. Suggested focused shapes are 4097x16, 4097x17, 4104x24, 4108x31, and 4111x65. Preserve known-solution checks, L invariance, padding/guard checks, and the existing correctness tolerance. Also exercise allocation-failure fallback through a separate harness mechanism without changing the candidate source. The existing 4097x9 case cannot prove the new kernel, because it contains no complete sixteen-column span.
4. Inspect generated assembly for the new kernel: confirm the per-output FMA chain, eight reusable L coefficients per k, two X vector loads, final subtraction semantics, and any register spills or unexpected hot-loop work.
5. Only after correctness succeeds, use the unchanged official benchmark and a same-round T8-control12 comparison with matching allocation, compiler/options, thread binding, reference library, inputs, and repeat settings. Keep raw results, every PASS/FAIL, per-case measurements, and scheduler completion. No improvement or promotion is claimed at preparation time.

All executable compilation, correctness, sanitizer, and benchmark work must run on scheduler-allocated supercomputer compute nodes. Local activity in this preparation was limited to reading and editing text, copying source files, and static text comparison. No local compile/test, network operation, job submission, hash calculation/verification, reset credit, experiment registration, or promotion was performed.
