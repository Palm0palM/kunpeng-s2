# Static review: C40-row6x3u1

Scope: source reading, arithmetic reasoning and lightweight text comparison only. No compilation, local operator test, sanitizer, benchmark, SSH or compute-node job was performed. Static review does not establish runtime correctness or performance.

## Change boundary

`source/conv2d.c` contains two insertions relative to C26: the new `conv_sve_rowsix` helper and its six-row dispatch branch. Removing those insertions restores the parent text. The existing quad/triple/pair/prefix/tail helpers, old C6 dispatch, non-SVE path and public interface are unchanged. `bench_conv.c`, `run.sh` and `README.md` are byte-identical to the parent. Therefore existing compiler flags, strict FP settings, benchmark verification, thread limits, binding and resource behavior are retained.

## Kernel-row and column order

Let `r` be an output-row index in `0..5`, and `t` the input-row offset relative to the group's first output row.

| Stage | Input rows | Active outputs | Kernel row for output r |
| --- | --- | --- | --- |
| Leading | `t=0,1,2,3,4` | `0..t` | `t-r` |
| Shared | `t=5..kh-1` | `0..5` | `t-r` |
| Trailing | `t=kh+s`, `s=0..4` | `s+1..5` | `kh+s-r` |

For each output `r`, these stages collectively visit input rows `r..kh+r-1` exactly once and in increasing order. Its coefficient row is consequently `0..kh-1` exactly once and in increasing order. Each stage's `ik` visits `0..kw-1` in increasing order. There are no alternate partial sums, pairwise reductions, skipped odd columns or duplicate coefficients. The expressions explicitly multiply then add into that output's existing accumulator; the unchanged runner disables contraction and fast-math.

When `kh=6`, the shared loop contains just `t=5`; both leading and trailing stages remain valid. `kw=1` executes one iteration in each active stage. Normal `kh<6` and `oh<6` use the unchanged C6 dispatch. The direct helper's defensive `kh<6` branch covers six available output rows with quad plus pair before any new-stage pointer is formed.

## Rows, integer widths and pointer bounds

The original public guard rejects nonpositive kernels and input dimensions smaller than the kernel before calculating output dimensions. This review retains the original contract that input, kernel and output pointers designate sufficiently large valid arrays; the interface has no buffer-size arguments.

The six-row path uses `size_t output_rows=(size_t)oh` and computes `groups=output_rows/6+(output_rows%6!=0)`, without adding five to a narrow integer. For every iteration, `first_row=group*6 < output_rows`; hence `remaining=output_rows-first_row` is positive. Calls with six output pointers occur only when `remaining>=6`.

For a complete group beginning at row `j`, the largest input row is `j+kh+4`, the final row needed by output `j+5`. Since `j+5<=oh-1`, it is at most `inputHeight-1`. Trailing addresses use `((size_t)kh+s)*stride`; widening precedes the addition. Shared coefficient offsets widen `t` before subtracting up to five, valid because `t>=5`; trailing coefficients subtract at most five from widened `kh`, valid because this path has `kh>=6`. Multiplication by `stride` or `kw` occurs as `size_t` arithmetic. Full-array offset representability remains part of the original valid-storage contract.

The final row group is handled as follows. No branch forms output pointers for nonexistent rows:

| Remaining rows | Calls |
| ---: | --- |
| 1 | prefix at row 0 |
| 2 | pair at rows 0–1 |
| 3 | triple at rows 0–2 |
| 4 | quad at rows 0–3 |
| 5 | quad at rows 0–3; prefix at row 4 |
| 6 or more | rowsix at rows 0–5 for this group |

## Columns and scalable VL

`lanes=svcntw()` is evaluated at runtime; the code does not assume a specific SVE width. The full-block condition `ow-i>=3*lanes` guarantees `i+3*lanes<=ow`. For `ik<=kw-1`, the last lane of the last load is at column `i+ik+3*lanes-1 <= ow+kw-2 = inputWidth-1`. The last output store is at most `ow-1`. No extra complete vector beyond the three valid windows is fetched.

Each increment keeps `i<=ow`; subtraction and the loop index do not overflow their existing `int` range. The architecture's bounded SVE vector length makes `3*lanes` representable as `int`. At `ow<3*lanes`, there are no new full-block loads. At equality there is one full block and no tail. Above equality, the unprocessed suffix has fewer than `3*lanes` columns and is passed to the unchanged quad/pair helpers with `base+i`, `dst+i`, `ow-i`, and the unchanged global input stride. Quad covers rows 0–3 and pair covers 4–5, exactly once.

## Thread ownership and limits

Each OpenMP iteration writes only `[6*g,min(6*g+6,oh))` output rows. These half-open intervals partition the output row set. Each helper's full blocks and suffix are disjoint within a row; fallback combinations also use disjoint rows. Accumulators are automatic helper-local SVE variables, and all inputs and coefficients are read-only. No additional parallel region, atomics, shared state or thread count is introduced. The existing static scheduling and runner's maximum 38 threads remain in force.

No static correctness issue was identified. The 18-accumulator allocation, eleven-stage code size, narrower horizontal block and six-row task granularity remain performance risks requiring actual compute-node assembly and measurements.

Root independent source review: checked the shared t=5..kh-1 loop and all five trailing coefficient mappings against t-r, scalar-first size_t offsets, 18 stores, quad+pair column tails and each remainder branch in the six-row dispatch. No new static issue found. The kh<6 direct-helper path still requires explicit diagnostic coverage; source review is not runtime proof.
