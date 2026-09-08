# C6-row2 local validation

Parent: C0-r3. Status: prepared for remote measurement; no speed claim.

Only candidate `source/conv2d.c` was changed. `run.sh` and official `bench_conv.c` match the parent hashes.

Default block32 now schedules output row pairs and calculates a fixed 2x16 tile with 32 independent float accumulators. Both output rows use the same loaded kernel coefficients. Every output retains sequential jk/ik accumulation, and the two kernel steps remain separate multiply/add operations. Column tails use paired widths8/4/2/1; an odd final row uses the baseline single-row implementation. Nondefault block sizes retain the original single-row implementation, and unroll1 remains supported. No allocations, reductions, FMA, fast-math, testcase-specific choices or benchmark changes were introduced.

| Check | Threads | Cases per run | Result |
| --- | --- | --- | --- |
| UBSan | 1 and 4 | 418 | Bitwise scalar equality, exit0 |
| Guard pages for input/output | 1 and 4 | 418 | Bitwise scalar equality, exit0 |
| UBSan, output heights1–5 | 1 and 4 | 2090 | Bitwise scalar equality, exit0 |
| Guard pages, output heights1–5 | 1 and 4 | 2090 | Bitwise scalar equality, exit0 |
| Block24 fallback, UBSan + guard pages, heights1–5 | 1 and 4 | 2090 | Bitwise scalar equality, exit0 |
| Unroll1, UBSan + guard pages, heights1–5 | 1 and 4 | 2090 | Bitwise scalar equality, exit0 |

Compiler: Apple Clang17.0.0, macOS ARM64; these are correctness checks only, not Kunpeng performance measurements. Commands, compiler banner, test hashes and source hash are in `results.json`; `run_checks.py` reproduces all12 runs. Original418-case harnesses were copied from C1-block. Extended harnesses add output heights1–5 to cover single-row, even-row and odd-row scheduling.

The remote coordinator must compile and run unchanged official benchmark with the parent environment and compare three independent suites before any promotion.
