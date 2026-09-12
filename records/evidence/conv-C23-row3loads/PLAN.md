# C23-row3loads

Source: unchanged C5 / C21-r3 baseline snapshot. Only three overlapping k1 windows in the triple-output shared middle phase are replaced by direct shifted loads. Five input loads become eight; three ext plus three movprfx are expected to disappear. This is a hypothesis until target assembly and timing are collected.

Each loaded lane equals the former concatenation lane. Per-output kernel row/column order, separate multiply/add, coefficients, 4VL width, schedules, first/tail phases and all fallback helpers remain unchanged. The maximum shifted-window column is i + 4VL - 1 + ik + 1 <= inputWidth - 1 because the pair loop requires ik+1 < kw. Read-only inputs and nonoverlapping outputs stay unchanged.

Do not compile or test locally. Required verification: scheduled compute-node strict bitwise guard/dispatch checks across 128/256/512-bit SVE and 1/4 threads, source hashes and assembly, then three full official suites in the same allocation as controls. No FMA/fast-math or benchmark edits. Retain all timings and reject if noise or regression exceeds the declared gate.
