# T12-forwardbarrier preparation

Prepared on 2026-09-12 from T8-svepanel16. Status: source prepared only. Wait for r8 to complete before any target submission or comparison. If T11 advances the best version, transplant this isolated change onto that new best before measuring; this T8-derived directory is not a candidate against a changed baseline without that step.

## Single hypothesis and code-generation target

The coordinator's explorer reports that actual T8 target assembly in `.L24` places thirteen dependent `a15` FMAs for within-block q=2..14 together at assembly lines 950–979. The reported T8 hot kernel has no spill. This experiment concerns timely consumption and scheduling of the forward-substitution dependency chain, not a spill repair.

After the existing `a15` update at within-block q=3, q=7, and q=11, insert exactly:

```c
__asm__ __volatile__("" : "+w"(a15) : : "memory");
```

The read/write vector-register operand forces that intermediate `a15` value to be available at the compiler barrier. The memory clobber constrains motion across the boundary. The target is to consume the chain in groups of at most four within-block steps, shortening the lifetime of solved values that would otherwise feed the concentrated late chain. Empty assembly adds no hardware synchronization instruction and does not change the stated FMA inputs or order.

This can also lose useful scheduling freedom, delay other FMAs or loads, or introduce spills. The empty statement has no machine instruction by itself, but its effect on generated code and performance must be observed on the target; there is no speedup claim at preparation time.

## Exact scope

- Copied the five original files from `.runs/trsm/T8-svepanel16/source/`: `trsm.c`, `bench_trsm.c`, `run.sh`, `README.md`, and `compat/kblas.h`. The destination did not exist before creation.
- Only `source/trsm.c` differs, by three added assembly statements inside `solve16x8_panel_sve`, immediately after `a15` updates at q=3/7/11. Their candidate line numbers are 208, 263, and 302.
- The increasing-k history loop, every existing FMA and division, all data layouts, allocation, runtime dispatch, target attributes, small/large algorithm choice, and other kernels retain their T8 contents.
- No source, record, main `trsm/` file, submitted payload, public tool, or supporting source file was changed for this preparation.

## Static review and deferred validation

The text diff must remain exactly three insertions at the named q boundaries, all in the existing SVE-only function. The barriers preserve the existing per-output FMA chain and exact division expressions; this is a static observation, not a runtime correctness result.

After r8 determines the baseline, perform all of the following on scheduler-allocated supercomputer compute nodes using the baseline's actual compiler and unchanged flags:

1. Target compilation, followed by assembly inspection of the within-block forward substitution. Verify that the formerly concentrated `a15` chain is divided at the three intended q boundaries; check hot-loop instructions, solved-value lifetimes, loads/stores, and any new spills. Retain the increasing-k history behavior and all 120 within-block FMAs / 16 divisions.
2. The existing direct panel microkernel bitwise ordered-FMA checks, followed by the unchanged general boundary, padding, L-read-only, SVE dispatch, allocation-failure, and official correctness gates appropriate to the selected baseline.
3. Same-environment comparison against the then-current baseline, with the established warm-up and repeated official benchmark protocol. A successful compile or desired assembly change does not establish a performance improvement. Preserve any neutral or regressive result rather than promoting on theory.

No local compilation or test execution, target compilation, network/SSH action, job submission, hash calculation or verification, experiment registration, or promotion has been performed for T12. Local work was limited to source copying, text editing, and static text inspection.
