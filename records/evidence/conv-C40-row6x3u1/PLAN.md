# C40-row6x3u1: six output rows × three SVE vectors

Status: prepared for a later round; no compilation, operator execution, diagnostic result, assembly result, or performance result exists for this candidate. C37/C38/C39 take priority. Do not submit this candidate automatically.

Parent and source parent: `C26-row4loads`, the formal C6 source. The only changed submission file is `source/conv2d.c`. The benchmark, runner, README, existing helpers, original dispatch and non-SVE path remain byte-preserved.

## Single hypothesis and implementation

Change the shared tile shape to six adjacent output rows × three scalable SVE vectors, with one kernel column per iteration. The new `conv_sve_rowsix` has 18 accumulators and shares each loaded input vector among up to six output rows. This may reduce input-load work per output while leaving room for coefficients and temporaries. It is a hypothesis, not an established memory or hardware bottleneck.

The stage construction follows the inspected C33 five-row helper and C28 generator's input-row/output-row mapping, without running or changing their generator. No existing candidate with the six-row × three-vector shape was found in the inspected candidate plans. The C33 helper is not imported: all fallbacks are the existing C6 helpers.

The helper has five explicit leading input rows `t=0..4`, a shared loop `t=5..kh-1`, and five explicit trailing input rows `t=kh..kh+4`. An active output row `r` uses kernel row `t-r`. Every stage traverses `ik=0..kw-1`, with separate `svmul_f32_x` followed by `svadd_f32_x`. There is no unrolling, lane multiply, prefetch, inline assembly, FMA, reassociation, or reduction change.

The main block spans `3*svcntw()` columns. Its three input loads start at `row+ik+n*lanes`, for `n=0,1,2`; no fourth vector is loaded. Any remaining columns use the original quad helper for rows 0–3 and pair helper for rows 4–5, with shifted pointers and the original global input stride.

The new top-level path requires SVE, `kernelHeight>=6`, and `oh>=6`. It partitions output rows into groups of six with static OpenMP scheduling. The last 1/2/3/4 rows use prefix/pair/triple/quad respectively; five rows use quad plus prefix. Calls form pointers only for rows present in that branch. For smaller kernels or output heights, the original C6 dispatch is used unchanged. The new helper also has a defensive `kh<6` quad-plus-pair fallback.

## Source-level tradeoffs to verify remotely

These counts apply only to a complete shared middle iteration and are not measured machine instruction counts:

| Shared middle | Output-vector × kernel-column updates | Input vector loads | Coefficient broadcasts | Separate multiplies / adds |
| --- | ---: | ---: | ---: | ---: |
| C6: four rows × four vectors × two columns | 32 | 8 | 8 | 32 / 32 |
| C40: six rows × three vectors × one column | 18 | 3 | 6 | 18 / 18 |

Input loads per update fall from 1/4 to 1/6; broadcasts per update rise from 1/4 to 1/3. There is one source-level inner-loop backedge per 18 updates instead of per 32. Eleven stages replace the C6 seven-stage shape. More leading/trailing work, a narrower horizontal block, fewer OpenMP row groups and different load balance can offset any input reuse.

The middle has 18 accumulator values plus six coefficient values. The source scopes one input vector at a time, but GCC can retain or reorder multiple input/product values. Actual register allocation, spills, instruction scheduling and total instruction count are unknown. No no-spill or performance claim is made from the source budget.

## Pending compute-node validation

Root/checks owns execution. First use the existing guarded correctness workflow, preserving reference code, tolerances and compiler/FP settings. Include direct and dispatched `conv_sve_rowsix` coverage, `kh=1..7` and larger odd/even kernels, `kw=1` and odd/even widths, `oh=1..12` plus larger nonmultiples of six, and widths around `3*VL`, `6*VL`, and existing fallback boundaries. Exercise alignment/guard-page modes, thread counts, SVE VL variants and non-SVE fallback as supported by the established diagnostic harness. The new helper's defensive small-kernel branch needs direct coverage because normal dispatch bypasses it.

Inspect actual shared-loop assembly for load/broadcast arithmetic counts, accumulator spills, FMA absence and compiler scheduling. Only after correctness acceptance should a same-allocation comparison against a fresh unchanged C6 control be scheduled with the same compiler, strict FP flags, 38-thread limit, affinity, inputs and complete repeated official suites. Preserve negative or inconclusive results; independent package validation would still be required before promotion. No result is invented here.

See `STATIC_REVIEW.md` for the bounds and accumulation-order derivation. The workflow checkpoint is the authoritative source hash and prepared-state record.
