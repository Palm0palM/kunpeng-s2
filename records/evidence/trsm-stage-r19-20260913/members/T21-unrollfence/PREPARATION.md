# T21-unrollfence preparation

Status: source prepared only; no compilation, target assembly, correctness or performance result yet. Intended promotion parent T19-control13, source origin and mechanism control T20-wideunroll2. T20 was not promoted in r17/r18: its large case improved 3.70%/3.26%, but total gains failed the unchanged noise gate.

Hypothesis: r17 GCC generated eight MOVPRFX per two-k iteration. Bound compiler scheduling between the two steps to shorten X/L temporary live ranges and reduce register moves. Insert two empty volatile asm statements covering all 16 accumulators in two eight-output groups, with memory clobbers before second-step loads. Every output is read/write, so the empty instruction sequence preserves its current value. This is a compiler scheduling experiment, not a hardware fence or concurrency change. It may reduce useful load overlap or introduce other moves; target assembly and official performance decide.

Only this insertion differs from T20. No change to arithmetic expressions, k order, tail, addresses, thresholds, dispatch, allocation, small path, benchmark, runner or support files. No hash operations or local task execution. Do not promote or package this unmeasured source.
