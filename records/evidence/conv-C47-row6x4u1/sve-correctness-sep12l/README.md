# C47 six-row × four-vector L diagnostic package

**Prepared only. No local or remote compilation, operator test, SSH or job submission occurred.** This package has no shared driver/acceptance/freezer and creates no scheduler identity. Later execution requires explicit root coordination. Current K confirmation/package work has priority; this preparation grants no compute authorization.

Candidate `C47-row6x4u1`, source parent `C40-row6x3u1`, changes only the six-row helper's horizontal block from3VL to4VL and18 to24 accumulators. Its independent source review found no source-level ordering/boundary blocker; target correctness/code generation remain unmeasured. The immutable production copy is identified by the new transport manifest. C40's historical26112 PASS and assembly are not reused as C47 results.

Both C harnesses come from C40's frozen actual diagnostic source, with width expressions only changed from3L/6L boundaries to4L/8L. The six-row grouping, kh gates, strict scalar reference, allocation guards/read-only/canary logic, atomic entry counters and direct kh1..5 fallback remain unchanged. There are still six core widths, so counts derived from the actual adapted loop products remain **3560 full +432 dispatch +360 direct =4352 per configuration**, **26112 planned across six configurations**. Equal counts do not mean equal inputs or inherited PASS.

The wrapper follows the I package's19 named stage exits and three actual shell-quoted BUILD_COMMAND lines, adapted only for C47 identity, four vectors and rowsix counts. It retains GCC10.3.1/generic/strict-FP and allocation/binding checks. Stage order is recorded in prepared.json; partial or failed compilation/execution prevents completion. Logs use guard-vl*/dispatch-vl*, build-*.log, compiler-version.txt, source-sha256.txt, stage-exits.txt, probe.log and exit-code.txt. No log, binary, actual .s, job ID or passed validation was copied.

`source-manifest.json` (bytes/SHA) and `source-hashes.json` (digest map) cover exactly five source inputs. `prepared.json` counts are planned, while validation.json remains incomplete. This new source copy is `e974915cb4e5e522526070bfdcff42b08dd7866412dbde11c76a07fac1b86d0a`.

## Pending actual production assembly

Read all eleven rowsix stages (`input_0..4`, `shared`, `trailing_0..4`), each transition and the entire helper, including indirect stack addresses and ABI saves. The source shared iteration specifies24 independent FMUL/FADD pairs, four input loads and six coefficient broadcasts per kernel column; actual instruction counts and register allocation are unknown. A24-accumulator source budget cannot establish no-spill behavior. Check whole-source fused instructions and preserve any spill or compile failure honestly. Use uninstrumented production `-S`, never the instrumented entry executable, for these findings. No asm/prefetch/lane instructions were added at source level.

## Bounded matrix and exact planned counts

Let `L` be the actual per-thread number of float lanes, checked at runtime. Run six configurations: requested vector bytes **16 / 32 / 64**, each with **1 / 4 OpenMP threads**. These are SVE 128 / 256 / 512-bit settings, not three times an assumed fixed vector length. Both the initial thread and every OpenMP worker must report the requested VL; the team size must match the requested setting.

| Production-source family | Widths | Kernels | Output heights | Allocation modes | Cases/configuration |
| --- | --- | --- | --- | ---: | ---: |
| Six-row threshold and group edges | `4L-1,4L,4L+1,8L-1,8L,8L+1` | `kh=5,6,7` × `kw=1,2,3` | `1..12,24` | 4 | 2,808 |
| Single-column output | `1` | `kh=5,6,7` × `kw=1,2,3` | `1,6,11,24` | 4 | 144 |
| Smaller-kernel original dispatch | `1,4L-1,4L+1` | `kh=1..4` × `kw=1,2,3` | `1,6,11,24` | 4 | 576 |
| Longer/rectangular ordered loops | `4L+1` | `(8,7),(7,8),(15,15),(81,81)` | `6,11` | 4 | 32 |
| **Uninstrumented full total** | | | | | **3,560** |

The four allocation modes are `pad=0/1 float` × `leading/trailing allocation edge`. Input and kernel are made read-only. Guard pages surround each usable allocation; the output is poisoned before execution, all output bits are compared with the strict scalar reference, and bytes outside every logical array are checked for canary changes. These are allocation-edge checks, not an assertion that every input row has a separate guard page. No sanitizer is claimed.

`oh=7..11` exercises every six-row remainder 1..5. `oh=1..5` and `kh=5` exercise original dispatch. `oh=6/12` exercises exact complete groups, and `oh=24` supplies four complete six-row groups so all four workers can enter the new helper. Runtime widths bound the new single/two-block transitions for every requested VL; narrow and suffix paths still use the existing helpers.

The independent instrumented executable performs two further matrices, both retaining the same bitwise reference, read-only input/kernel and output canary checks:

| Instrumented family | Widths | Kernels | Output heights | Allocation modes | Cases/configuration |
| --- | --- | --- | --- | ---: | ---: |
| Actual public dispatch | `4L±1,4L,8L±1,8L` (six distinct widths) | `kh=5,6,7` × `kw=1,2,3` | `6,7,8,9,10,11,12,24` | fixed `pad=1, trailing` | **432** |
| Forced direct small-kernel fallback | `4L-1,4L,4L+1` | `kh=1..5` × `kw=1,2,3` | `6,24` | all 4 | **360** |

Thus each configuration has **3,560 + 432 + 360 = 4,352** checks, and six configurations have **26,112** planned checks. The two instrumented phases are additional checks, not included again in the production-source count. Instrumentation exists only to prove entry and otherwise unreachable defensive fallback; its timings must not be used as performance.

## Entry and branch proof

`-finstrument-functions` is applied only to `check_sve_dispatch.c`, which includes the unchanged candidate. Atomic entry counters track rowsix/quad/triple/pair/prefix/tail. Callbacks are marked `no_instrument_function` to prevent recursion. Before and after each completed case, the diagnostic checks the exact rowsix-entry difference:

- Public dispatch: `kh=5` requires **zero** rowsix entries. `kh=6/7` requires exactly `floor(oh/6)` entries, independent of width. Summed over the matrix: `6 widths × 2 active kh × 3 kw × (6×1 + 2 + 4) = 432` entries. Widths below `4L` check entry plus horizontal fallback; widths equal/above `4L`, with the inspected source block condition, establish actual main-block reachability. This is a function-entry probe, not a counter inserted in the main loop.
- Direct fallback: a diagnostic-only wrapper calls `conv_sve_rowsix` directly for groups of six valid rows, with `kh=1..5`. This bypasses the public condition that would normally exclude the helper. Each case must record `oh/6` entries and still match the scalar reference. Summed entries: `3 widths × 5 kh × 3 kw × 4 allocation modes × (1+4) = 900`. The helper's first `kh<6` branch then executes the unchanged quad-plus-pair fallback; the production candidate is not patched.
- Separate per-phase worker masks must be `1` for one thread and `15` for four threads. The four-group shapes ensure the helper is reached by each worker. The mask is reset only between fully joined phases. Prefix, tail, pair, triple and quad entries must all be nonzero after public-dispatch smoke. Every output row remains private to its group.

The direct wrapper changes only the diagnostic call target between completed phases. Its own OpenMP loop uses widened row/stride products, outputs exactly six rows per group, and rejects dimensions other than the declared direct matrix. It does not bypass scalar reference or guard/canary checks.

## Build, execution and acceptance

`source/remote_job.sh` first requires Linux/AArch64, exactly 38 allocated CPUs contained in one NUMA node, and GCC 10.3.1. Root/checks must submit it through the scheduler. Its flags retain `-O3 -std=c11 -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp`, standard warning/default-source options, and the diagnostic-only `EXPECTED_ACC=4`. Existing production CONV macro defaults remain unchanged. OMP is static/close/cores with dynamic teams disabled; only the selected 1/4 workers execute the correctness suites inside the 38-CPU allocation.

Three separate compile products are planned:

1. `check_conv_guard.c + conv2d.c` without instrumentation, for 3,560 cases/configuration.
2. `check_sve_dispatch.c` with function instrumentation, for 432 public-dispatch plus 360 direct-fallback cases/configuration.
3. `conv2d.c -S` without instrumentation, for actual production helper assembly.

The wrapper uses `set -euo pipefail`, preserves build logs, waits for its tee logger and writes `exit-code.txt` before exit. Any compile error, mismatched VL/thread, incorrect entry delta/mask, memory fault, changed canary, bit mismatch or count mismatch prevents `PROBE_COMPLETE=1`.

Root/checks acceptance must verify the scheduler's successful terminal state, job/system/wrapper exits, the complete remote source manifest, all six full summaries of 3,560, all six dispatch summaries of 432, all six direct summaries of 360, exact rowsix totals/masks, nonzero legacy helper entries and the completion marker. Then read actual `conv_sve_rowsix` shared-loop assembly for arithmetic/load/broadcast counts, spills and FMA absence. Fetching logs alone is not validation; `validation.json` must remain incomplete until this acceptance is finished. Store negative/incomplete results honestly and resume only the same recorded job ID when applicable. No performance or promotion conclusion follows from this package.
