# T23-smallunroll2 preparation

Prepared source only; no compiler, target assembly, correctness or performance result. Intended parent/current implementation is T19-control13 (T19-panel8x16budget), latest measurement job1582239. Source copied from that unchanged baseline, without T20/T21/T22 large-loop variants.

Hypothesis: apply two-step increasing-k unrolling to the small-path solve8x16_panel_sve history loop. Its r19 target assembly has 37 instructions per k, 16 FMLA, eight scalar coefficient loads/broadcasts and two X-vector loads. Unrolling may give GCC more opportunity to overlap those loads while sharing loop management. Register pressure and code size may instead regress performance, so target evidence is required.

Only the history k loop changes. Reuse the same 16 accumulators, first k then k+1, and retain the original single-step tail. Do not split or reorder reductions. The final eight-row triangular solve, single subtraction/division per output, scratch layout, whole-path budget/dispatch and allocation fallback remain exact T19. Large update path is unchanged T19. No benchmark/runner/support-file changes, hashes or local task execution. Do not package this unmeasured candidate.
