# C42 five-row × five-vector explicit-assembly diagnostic package

**Prepared only; no compilation, test or job submission has occurred.** All G-round candidates wait until F-round performance has finished and root explicitly gives GO. Root/checks owns a later unique scheduler submission. The public driver and other packages are unchanged.

Candidate `C42-row5x5asm` uses prepared pure-C source parent `C41-row5x5u1`. Neither is a measured or promoted best. `source/conv2d.c` is an unchanged copy of prepared C42, SHA256 `cbdadacaa24a28f2eff0b9d01810ccae69ddc127da22942f30b15a6713265def`. The four other diagnostic input files are byte-identical to the reviewed C41 template. This deliberately preserves the same **27,408** checks, matrix ordering, random reference generation, compile conditions and entry expectations for a comparable correctness check. Performance still requires a separate same-allocation experiment.

C42 changes only the five input-vector scopes in the quint shared middle `t=4..kh-1`: each uses five ordered standalone FMUL/FADD pairs, one scratch, five `+&w` accumulator constraints, `=&w` scratch, six `w` inputs, `%Z` register formatting and a `memory` compiler barrier. The independent source review found no source-level ordering/boundary obstruction; it does not establish that GCC10.3.1 accepts the concrete template or constraints. Compile failure must be retained as failure; do not silently change templates or constraints to make this copy pass.

**Target execution must verify actual GCC10 template acceptance, concrete registers and instruction operands, every one of the nine quint stages and transitions for spill traffic, and FMA absence.** The middle's source template specifies 25 FMUL and 25 FADD per kernel column; source-level 32-register budgeting is not a no-spill guarantee. The other eight stages remain pure C and can still spill or dominate the result. Inspect uninstrumented production assembly, not the entry-instrumented binary, for these findings. A `memory` clobber constrains compiler memory motion and is not a hardware fence or evidence of a hardware bottleneck.

Production source and benchmark/runner are not edited. `source-manifest.json` identifies the immutable source copy and four unchanged template files; remote acceptance compares the same five files. This package contains no result or performance claim.

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
