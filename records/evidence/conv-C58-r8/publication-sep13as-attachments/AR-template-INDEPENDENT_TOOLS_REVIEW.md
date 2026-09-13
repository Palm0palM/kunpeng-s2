# AR C62 independent diagnostic-template review

Reviewer `/root/c61_review_resume`, 2026-09-13. Independently reviewed the new AP-to-AR transport/checker changes and `CHECKER_COUNTS.md`. Reviewer prepared C62 source earlier; this review concentrates on the root's separately prepared diagnostic template. This file is the sole edit. No driver import/execution, scheduler query, submission, compiler, operator, test, acceptance or freeze was run; local Python only parsed text/JSON, compared bytes and recomputed static cardinalities.

**Conclusion: no static blocker.** Root may run the actual serial gate and submit exactly one AR job if it clears. This is neither a diagnostic pass nor a performance result. Actual AR numerical logs, allocation, compiler output, source association and generated assembly remain required.

## Checker coverage and independent counts

All six saved diffs (driver, acceptor, both checkers, wrapper and candidate.env) equal the active AP-to-AR file differences exactly. Python driver and acceptor AST parsing passed. Manifest matches the five transport files, and transport conv2d.c equals prepared C62 source `e6cc9bdb4c14e9f6982f687123379ebf5dfb2013777f7bb076c04edd4827dc8a`.

- Full/dispatch widths are 2L−1/2L/2L+1/4L−1/4L/4L+1 for L=4/8/16. They are distinct and positive, covering zero/one/two full 2L tiles, exact tiles and width remainders. Small/direct/larger widths changed consistently; no old 3L/6L candidate boundary remains.
- Full core independently recomputed: 6×3×3×18×2×2 = **3888**; narrow 3×3×4×2×2 = **144**; small 3×5×3×4×2×2 = **720**; larger 4×2×2×2 = **32**; quad 6×2×5×4×2×2 = **960**. Total **5744**.
- Dispatch: 6×3×3×18 + 6×2×5×4 = **1212**. Sum floor(h/7) over heights 1…15,21,22,28 is 21. Expected rowseven entries are 6×2×3×21 + 6×2×5×(1+1+2+4) = **1236**. Every case still compares actual entry delta with its independently defined expectation. Width does not change production rowseven entry; narrow widths then take fallback.
- Direct: 3×6×3×2×2×2 = **432**; explicit entry sum 3×6×3×(1+4)×2×2 = **1080**. kh1…6 exercises defensive fallback. Checked function and worker mask reset only after prior teams join.
- kw4…8 covers one quad with residual counts 0/1/2/3 and two quads at kw8. Heights 7/8/14/28 cover group boundaries; kh7/8 and larger kernels cover t transitions. Six configurations give (5744+1212+432)×6 = **44328**.
- Bitwise scalar reference/memcmp, read-only input/kernel, guard orientations, outside canaries and poisoned output are unchanged. Actual VL is checked for every worker, and actual threads must be 1/4 and equal the OpenMP maximum. oh28 forces four independent static groups; masks 1/15 remain required. No tolerance relaxation exists.
- Legacy prefix/tail/pair/triple/quad instrumentation still requires every helper count nonzero. Changed widths can change these aggregate counts; do not copy AP's old legacy counts as exact expectations. 4L and 4L+1 widths with remaining output rows still exercise fallback helpers. Root must inspect actual nonzero returned counts.

## Transport and acceptance

- Predecessor is AQ **1590254**, with C58-r6/C61-row7shared2rowwise/C58-r7 and 36 samples. Current campaign read during review is complete with that identity/order/count. Actual scheduler identity, terminal state and integer job/system exits are additionally required; campaign data alone cannot clear the serial gate.
- AR reservation did not exist at review. Exclusive reservation precedes upload/submission; existing or ambiguous reservations prevent another submit. Status/fetch reuse the saved original ID. Acceptance rejects AQ's ID and requires new AR summary/job/raw association.
- Resources remain 38 CPUs, 24576 MiB, one packed NUMA, 1800 seconds. Wrapper checks Linux AArch64, exact affinity count and one NUMA before building. Actual allocation still requires returned review.
- Env and wrapper require EXPECTED_ACC=2; checker rejects other values at compile time. Header must show BLOCK_OUTPUTS=2L. Acceptor expects three compiler argv with ACC2, GCC 10.3.1, generic target, strict separate FP and unchanged OpenMP settings. Dispatch instrumentation stays outside timed production.
- All **19** ordered zero-exit stages, SUCCEEDED/job-system zero, wrapper zero, six actual VL/thread headers, exact PASS/family/entry/mask counts, no FAIL/ERROR, original/returned source bytes and no fused floating-point mnemonics remain mandatory. Own actual 2VL/shared4 targeted assembly and root-returned reviews must be read before freeze.
- Archive preserves original raw/preparation/creation evidence and labels performance unmeasured. It cannot infer AS qualification, promote or create a best ZIP. C7 remains authoritative until own diagnostic, matched performance and independent confirmation meet existing gates.

No AP success is inherited by C62 and no new job ID or measured count was invented. An initial attempt to replace this placeholder via a combined delete/add patch was rejected before any edit; this ordinary update applied the review instead. That was a documentation-tool failure, not an operator failure.
