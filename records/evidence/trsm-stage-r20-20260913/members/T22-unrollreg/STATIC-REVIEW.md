# T22 static review

Compared the whole source with measured T21. Outside the two-statement block all bytes are unchanged. Inside, exactly two memory clobbers are removed and the comment is corrected; all 16 intended read/write accumulator variables remain present exactly once in the original groups/order. Empty extended asm with outputs only has no memory access or instructions. It preserves input/output register values at execution while retaining explicit compiler dependencies; source FMA expressions and increasing-k order are unchanged.

No new address expression or allocation exists; zero/one count bypasses the inserted block, odd tail, full-width guard, narrow/no-SVE/failed-allocation paths remain inherited unchanged. Four support files match T21. This is source review only: no target compiler, assembly or runtime result is claimed and no task code was executed locally. New target preflight and complete official suites remain required.
