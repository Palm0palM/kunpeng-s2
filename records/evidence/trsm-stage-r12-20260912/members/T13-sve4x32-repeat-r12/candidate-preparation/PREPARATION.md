# T13-sve4x32 preparation

Prepared on 2026-09-12 from T8-svepanel16. Status: source prepared only; target compilation, correctness, assembly inspection, performance measurement, registration, and promotion have not run for this candidate. The coordinator reports r9 has reached scheduler SUCCEEDED; this independent candidate waits for the completed collection and baseline decision before any submission.

The root agent independently read the new kernel and the 16/8/4-row dispatch changes and reported no concrete static defect. This review does not establish target compilation or runtime correctness.

## Single hypothesis and its cost

Replace only complete 32-column spans of the large blocked update with a four-row by 32-column SVE kernel. Sixteen named vector accumulators consume four X vectors per k; each of four L coefficients feeds four explicit FMAs. The hypothesis is that reduced L reloads and row-address work can outweigh the extra X reads and different instruction scheduling. It is not a demonstrated improvement.

For the same 128 output values at one k, the source-level input-load demand is:

| Kernel | L scalars | X vectors of 64 bytes | Input bytes per k |
| --- | ---: | ---: | ---: |
| T8 16x8 | 16 | 1 | 192 |
| T11 8x16 | 8 | 2 | 192 |
| T13 4x32 | 4 | 4 | 288 |

T13 therefore does **not** reduce total input bytes in this comparison. These counts describe kernel operands, not measured memory-system or DRAM traffic. Extra X loads, register pressure, spills, and scheduling changes are explicit risks; target assembly and end-to-end measurements must decide whether the tradeoff is useful.

## Exact source scope

- The destination did not exist before creation. All five original files were copied from `.runs/trsm/T8-svepanel16/source/`: `trsm.c`, `bench_trsm.c`, `run.sh`, `README.md`, and `compat/kblas.h`.
- Only `source/trsm.c` differs. A recursive source text diff contains the new kernel and the complete-32-column loops in the original 16-, 8-, and 4-row update groups. Four supporting files retain their T8 contents.
- `update4x32_sve` begins at line 599. Its eight parameters are `count,L,lda,X0,ldx,panel_stride,C,ldc`. `X1`, `X2`, and `X3` are derived from `X0+q*panel_stride` at entry.
- The original 16-row outer loop retains its stride and calls the new kernel at lines 759, 760, 761, and 762, offsetting L/C by 0, 4, 8, and 12 rows.
- The original 8-row tail loop calls it at lines 789 and 790, offsetting L/C by 0 and 4 rows.
- The final row loop now has an explicit outer block to allow the complete-four-row call at line 821. Its existing eight-column/scalar body is preserved with one extra indentation level. Fewer than four rows bypass the new kernel.
- T11's 8x16 kernel and T12's small-path barriers are not present. Every original T8 FMA/division expression, old kernel, history/diagonal solve, small path, algorithm selector, target attributes, allocation, packing, `KB=256`, `CT=64`, and OpenMP task/barrier structure is retained.

## Static indexing and semantic review

- Each new loop starts `j` at the existing `jb`, requires `j+32<=je`, and advances that same `j` by 32. Its original T8 loop then continues from that `j` in eight-column steps. Complete eight-column remainders use `update16x8_sve`, `update8x8_sve`, or `update4x8_sve`; narrow columns retain the original scalar code.
- `CT=64` and `RHS=8` keep each new `j` aligned to packed panel boundaries. In packed mode, `X0=packed+(j/8)*KB*8`, `panel_stride=KB*8=2048` doubles, and `ldx=8`. Four complete panels are present whenever the 32-column guard passes. Their solved rows were published by the unchanged diagonal-solve barrier.
- On shared allocation failure, `X0=B+kk*ldb+j`, `panel_stride=8`, and `ldx=ldb`; the four vectors select adjacent groups of eight columns from each original B row. Input rows remain `kk..end-1`, while output rows start at or below `end`, so the new calls do not overwrite their X inputs.
- Sixteen named sums begin at zero. Each increasing k loads all four X vectors and performs one explicit `svmla_n_f64_x` per output vector using that row's L coefficient. After the loop, each output executes a single `C-sum`; it does not begin from C, use negative FMA, reassociate the reduction, or change division.
- The new definition and every call are within `#if TRSM_CAN_DISPATCH_SVE`; calls additionally require the existing worker-local `use_sve`. The unchanged HWCAP and `svcntd()==8` guard limits full predicates to eight double lanes. The four-row call also requires `ie-i>=4`. Non-SVE and narrow-VL paths retain the original task coverage, NEON kernel, and scalar code.
- For each row group, complete 32-column spans and subsequent old eight-column/scalar spans cover disjoint columns exactly once. Four calls cover a complete sixteen-row group, two cover eight rows, one covers four rows, and smaller rows remain entirely in the old code.

## Deferred compute-node validation

1. Compile with the actual target compiler and unchanged baseline flags, including the non-SVE compilation branch. Inspect the new target assembly for four X loads and four reusable L coefficients per k, sixteen accumulators, unchanged increasing-k FMA chains and final subtraction, register spills, address instructions, and call overhead. Empty compiler success is not a correctness or performance result.
2. Add a direct bitwise microkernel check using independent general non-dyadic L/X values, increasing-k scalar `fma` reference from zero followed by one C subtraction, padded L/C, and full input/output guard buffers. Cover counts 0/1/2/7/31/255/256, two L leading dimensions, and both packed four-panel stride 2048/ldx8 and strided panel stride8/ldx>32. Require actual eight-double SVE before direct calls and count actual entries.
3. Run end-to-end cases that enter the large path with `n>=32`, including 4105x41 (32+8+1 columns and 8+1 row tail) and 4111x63 (32+8+8+8+7 columns and 8+4+3 row tail), padded `lda=m+3` and `ldb=n+7`, one/four threads, and at least one 38-thread case. Include shared packed allocation failure, no-SVE injection, and actual narrow VL. The earlier 4105x25/4111x31 tests contain no complete 32-column span and cannot prove the new kernel.
4. Check exact entry totals independently using `sum(floor((m-min(kk+256,m))/4)*floor(n/32))` over diagonal blocks when SVE8 is active; complete 64-row/column tiles preserve these group counts. No-SVE/narrow VL must produce zero entries. Shared allocation failure must still produce the expected nonzero entries through original-B strides. Preserve finite values, the existing 1e-12 tolerance, L read-only checks, B padding, and residual/known-solution checks.
5. Only after all required correctness checks, compare against the then-current valid baseline using unchanged official benchmark inputs, warm-up and repeated-suite protocol, flags, reference library, 38-core single-NUMA allocation, and binding. Preserve every result, including regressions; do not promote from instruction counts or operand-byte arguments.

All executable compilation, correctness, sanitizer, and performance work must run on scheduler-allocated supercomputer compute nodes. This preparation used only source copying, text edits, and static text comparison. No local compile/test, SSH/network access, job submission, hash calculation/verification, record update, or promotion was performed; main `trsm/` and public tools were not changed.
