# C41 five-row × five-vector diagnostic package

**Prepared only; no compilation, test or job submission has occurred.** Root/checks owns a later unique scheduler submission. C37/C38/C39 and C40 retain priority. This template covers pure-C C41 only; it does not claim coverage or authorize execution for the future C42 assembly candidate.

Candidate `C41-row5x5u1` uses measured source parent `C33-row5x4u1`, not the formal best. `source/conv2d.c` is an unchanged copy of prepared C41, SHA256 `ca50684addef168079d4f960df721f5af195b20b3b021ff0eb7c47ec42692a95`. Production source, shared drivers and public tools are not edited. The guard/reference and independent function instrumentation are adapted from the statically reviewed C40 package. The five input files are recorded in `source-manifest.json`; the remote job will save the matching SHA list.

## Exact planned matrix

Use requested vector byte lengths **16/32/64** (SVE128/256/512) and **1/4 OpenMP threads**, six configurations. `L` denotes the actual float-lane count, checked for the initial thread and every worker. Widths are derived from that runtime value.

| Uninstrumented production family | Widths | Kernels | Output heights | Allocation modes | Cases/configuration |
| --- | --- | --- | --- | ---: | ---: |
| Block, suffix and group edges | `4L,4L+1,5L-1,5L,5L+1,10L-1,10L,10L+1` | `kh=4,5,6` × `kw=1,2,3` | `1..10,20` | 4 | **3,168** |
| Single output column | `1` | `kh=4,5,6` × `kw=1,2,3` | `1,5,9,20` | 4 | **144** |
| Smaller-kernel original dispatch | `1,5L-1,5L+1` | `kh=1..3` × `kw=1,2,3` | `1,5,9,20` | 4 | **432** |
| Longer/rectangular loops | `5L+1` | `(8,7),(7,8),(15,15),(81,81)` | `5,9` | 4 | **32** |
| **Full total** | | | | | **3,776** |

Four allocation modes are `pad=0/1 float` × leading/trailing allocation edge. Input and kernel are read-only; allocations have guard pages; output starts poisoned; every result bit is compared with the strict scalar reference; canaries outside all logical arrays must remain intact. These are whole-allocation edge guards, not separate guards at each row. Sanitizers are not run or claimed.

The width set explicitly covers a suffix between 4L and 5L: at `ow=4L/4L+1/5L-1`, quint has no full block and its existing quad fallback must process at least one 4L block; at `ow=10L-1`, quint first processes 5L and hands a `5L-1` suffix to quad plus prefix. `5L` and `10L` have no horizontal remainder, while their ±1 neighbors test transitions. Width 1 covers the narrowest fallback. Heights 6..9 cover remainders 1..4; 5/10 cover complete groups; 20 supplies four complete five-row groups for four workers. `kh=4/5/6` straddles the new helper's gate and smallest active kernel.

The separate instrumented executable retains the same reference and memory checks and performs:

| Instrumented family | Widths | Kernels | Output heights | Allocation modes | Cases/configuration |
| --- | --- | --- | --- | ---: | ---: |
| Actual public dispatch | Same eight core widths | `kh=4,5,6` × `kw=1,2,3` | `5,6,7,8,9,10,20` | fixed `pad=1, trailing` | **504** |
| Forced direct defensive fallback | `5L-1,5L,5L+1` | `kh=1..4` × `kw=1,2,3` | `5,20` | all 4 | **288** |

Total: **3,776 + 504 + 288 = 4,568** checks/configuration; **27,408** checks across six configurations. Counts are planned, not passed. Instrumentation timings are never a performance result.

## Exact entry and worker evidence

The production executable compiles `check_conv_guard.c` plus unchanged `conv2d.c` as separate source files without function instrumentation. A second executable alone receives `-finstrument-functions` and includes that same unchanged candidate so its static helper can be addressed. Atomic callbacks count quint/quad/triple/pair/prefix/tail; the callbacks are marked `no_instrument_function`.

For each public-dispatch case, the quint count delta must be **0 for kh=4**, or exactly `floor(oh/5)` for kh=5/6. Across this matrix the expected quint total is `8 widths × 2 active kh × 3 kw × (5×1+2+4) = 528`. Below 5L the helper enters its unchanged horizontal suffix; equal/greater widths, together with the inspected source block condition, establish full-block reachability. This records function entries rather than inserting a basic-block counter into production source.

For direct fallback, a diagnostic wrapper calls `conv_sve_rowquint` on five valid output rows per group despite kh=1..4, forcing the defensive branch that public dispatch excludes. It uses the original quad-plus-prefix fallback, not a patched implementation. Per-case count must equal `oh/5`; total expected entries are `3 widths × 4 kh × 3 kw × 4 allocation modes × (1+4) = 720`.

Each phase independently checks a worker mask: **1** with one thread, **15** with four. The 20-row shapes give each of four workers one full quint group. Reads and mask reset occur after completed calls/OMP joins; the direct call target changes only between joined phases. Prefix, tail, pair, triple and quad must all have nonzero public-phase entries. Outputs remain private to their group.

## Remote build and acceptance

The wrapper checks Linux/AArch64, exactly 38 allocated CPUs within one NUMA node, and GCC10.3.1 before compiling the diagnostic. It uses the same strict options as the reviewed C40 diagnostic: `-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp`, plus `EXPECTED_ACC=5` solely for the diagnostic. Production CONV macros retain their defaults. OMP uses close/cores with dynamic teams disabled; the six configurations use only 1 or 4 workers within the 38-CPU allocation.

Three builds are planned: the uninstrumented production full executable, the independent instrumented entry/direct executable, and uninstrumented `conv2d.c -S` for actual production assembly. `set -euo pipefail`, build logs, waited tee logging and `exit-code.txt` preserve failures. A compiler error, unsupported/mismatched VL, thread mismatch, reference/canary fault or entry/count mismatch prevents completion.

Root/checks must reconcile one stored job ID, inspect the successful scheduler terminal state and all job/system/wrapper exits, compare the remote source manifest, and verify six full summaries of 3,776, six public summaries of 504, six direct summaries of 288, exact quint totals 528/720, per-phase worker masks, nonzero legacy entries and `PROBE_COMPLETE=1`. Then inspect actual shared-loop arithmetic/load/broadcast counts, spill locations and FMA absence, distinguishing ABI saves from loop spills. A spill is a performance finding, not automatically a correctness failure.

The public driver is intentionally untouched. Integration, unique submission and validation are root/checks responsibilities. `validation.json` stays incomplete until runtime acceptance; fetched or partial logs alone do not pass. Preserve failed/inconclusive evidence and avoid mixing this correctness work with performance timing. This package supports no speed or promotion claim.
