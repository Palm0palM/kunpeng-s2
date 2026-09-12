# T7-sve24rows preparation

Prepared from .runs/trsm/T5-sve16rows/source/ on 2026-09-11. The parent agent will create the paired measurement baseline T5-control10. Only trsm.c is changed: add a 24-by-8 SVE update and dispatch complete 24-row tiles before the existing 16/8/4/scalar tails. Source, benchmark, runner, README and compatibility header were copied; only the kernel source was edited. No local compilation, correctness test, benchmark, sanitizer, hash computation/verification, scheduler submission or publication was performed.

## Single hypothesis

Twenty-four independent output rows reuse each X vector, with 24 increasing-k FMA chains. Every row still subtracts its completed sum from C once. For a full CT=64 tile, the row decomposition is 24+24+16 rather than four 16-row calls. All other tiling, small-workset code, 64 MiB algorithm selection budget, packing, thread settings and accuracy requirements remain unchanged. Higher reuse and fewer calls are a performance hypothesis, not a measured improvement.

The new helper is target("arch=armv8-a+sve") and noinline, inside the existing TRSM_CAN_DISPATCH_SVE compile guard. It is only called after HWCAP_SVE and the active OpenMP worker's svcntd()==8 check. Full eight-column panels use SVE24; incomplete columns use the corresponding 24-row scalar update. Remaining rows continue through the existing SVE16, SVE8, SVE4 or NEON/scalar paths. xp and xstride retain the original packed allocation or direct-B fallback selection; X stride remains separate from C stride.

## Static register and correctness review

- Source-level vector liveness has 24 accumulator vectors plus one X vector during the k loop. Against the 32 architectural SVE Z registers, seven registers remain for coefficient broadcasts and other compiler temporaries; the predicate occupies the separate predicate register class. This does not guarantee spill-free GCC output. Scalar/address temporaries and register allocation, plus register save/restore overhead, must be checked in target-generated assembly before performance claims.
- Each accumulator a0..a23 uses the matching L row and C row. Each lane follows k=0..count-1 in the original order, then a separate C-sum subtraction. No sum reassociation or cross-row reduction was introduced.
- first_row advances by complete 24-row groups, then the original complete 16-row and 8-row groups, followed by four/scalar rows. Every selected row lies below ie and each column belongs to its existing CT tile; there are no new writes between worker-owned rectangles.
- A partial last column panel writes only cols valid lanes. Allocation failure passes X directly from B with ldx=ldb while output ldc=ldb; successful packing uses ldx=8. No new allocation was introduced.

## Target-only validation required

1. Direct update24x8_sve count values 0/1/2/3/7/63/128/255/256/257 with ldx=8/11/65 and independent ldc=ldx+5. Compare increasing-k explicit FMA reference and preserve all C padding; inspect input L/X immutability if supported by the harness.
2. Verify actual whole-operator SVE24 entry, 1/4-thread paths, forced packing-allocation failure and forced non-SVE fallback; keep the existing per-thread hardware/vector-width guard checks.
3. Cover remaining row heights around 15/16/17, 23/24/25, 31/32/33, 39/40/41, 47/48/49, 55/56/57 and 63/64. For whole-operator large-path cases, m=4096+h gives the final CT tile height h after aligned KB boundaries; use representative heights with n=7/8/9/63/64/65. Include m=4095/4096/4097 for algorithm selection and m%KB tails.
4. Preserve independent lda/ldb padding, unchanged L, nonpositive dimensions and tolerance 1e-12. Inspect target assembly for unexpected vector spills within the k loop, FMA ordering, and code size/save-restore costs.
5. Compare three independent complete official suites against T5-control10 under one 38-CPU, single-NUMA scheduler allocation with TEST_RUNS=3, identical compiler/flags/binding and actual reference library explicitly recorded. OpenBLAS validation must not be labeled official KML revalidation.
