# Static review: C41-row5x5u1

This review uses source reading and lightweight text comparisons only. No compiler, operator test, sanitizer, benchmark, SSH or job submission was run.

## Scope

Relative to C33, the diff is confined to `conv_sve_rowquint`: one block-width replacement, five accumulator initializers, nine fifth-vector input scopes and five output stores. Removing those additions and restoring `block=4*lanes` recovers the parent helper text. Everything outside the helper, including five-row dispatch, other helpers, public/non-SVE code and fallback expressions, remains byte-identical. `bench_conv.c`, `run.sh` and `README.md` remain byte-identical, preserving the original strict FP flags, macros, benchmark verification, OpenMP binding and resource limits.

## Accumulation order and row bounds

The nine stages are unchanged: leading input rows `t=0..3`, shared `t=4..kh-1`, and trailing `t=kh..kh+3`. For output row `r=0..4`, active input rows run `r..kh+r-1` and coefficient rows `t-r` run exactly `0..kh-1` in order. Every new accumulator receives exactly the same coefficient sequence as the corresponding first-four accumulators, at its fifth input-vector position. Each `ik` loop remains `0..kw-1`, one column at a time, with explicit separate multiply then add. `kw=1`, odd/even `kw`, and the smallest active `kh=5` need no special remainder logic.

The helper's `kh<5` branch and public `kh>=5 && oh>=5` gate are unchanged. In a complete five-row group starting at output row `j`, the maximum input row remains `j+kh+3`, exactly the last row required by output `j+4`, and is at most `inputHeight-1`. Existing `size_t` row/stride arithmetic and the original valid-storage contract are preserved. This width-only change forms no new row address or kernel-row expression.

## Horizontal bounds and scalable vectors

`lanes=svcntw()` remains runtime-scalable; `block=5*lanes` is bounded by the architecture's SVE length limits and fits the existing `int` loop representation. A complete block requires `ow-i>=5*lanes`, so `i+5*lanes<=ow`. The last lane of the fifth input load is at column `i+ik+5*lanes-1`. With `ik<=kw-1`, this is at most `ow+kw-2=inputWidth-1`. The fifth output store ends at `i+5*lanes-1<=ow-1`. There is no sixth load, extra full vector or shifted-window lookahead.

After each complete block, `i` remains at most `ow`. Below `5*lanes`, the new full block executes zero times; at equality it executes exactly once; above it, the suffix is smaller than `5*lanes`. The unchanged suffix calls quad for rows 0–3 and prefix for row 4 using `base+i`, `dst+i`, `ow-i` and the original input stride. These helpers can already handle a suffix spanning any number of their own full blocks plus masked tail; increasing the possible suffix from less than 4VL to less than 5VL introduces no gap or overlap. The main block and suffix write disjoint column intervals.

## Dispatch and parallel ownership

The unchanged public path computes `groups=output_rows/5+(output_rows%5!=0)` using `size_t`, assigns group `g` rows `[5g,min(5g+5,oh))`, and uses static OpenMP scheduling. Remaining 1/2/3/4 rows still use prefix/pair/triple/quad respectively. Full five-row pointer lists are formed only for groups with five present outputs; smaller kernels/heights use the original C6 fallback dispatch. No thread count, parallel region, shared accumulator, reduction, synchronization or row task is added. Every output element remains owned by one group and one horizontal block/suffix.

No static correctness obstruction was identified. The 25-accumulator pressure, actual compiler schedule, possible spill traffic and performance are unresolved until scheduled compute-node validation.
