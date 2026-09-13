# C64 independent source review

Reviewer `/root/c61_review_resume`, 2026-09-13. Read candidate.patch, SOURCE_AUDIT.json, STATIC_REVIEW.md and actual C7/C64 source. Only review documents written; no operator/compiler/test/driver/network activity. Text-only brace parsing, expression resolution, byte comparison and statement counting performed independently of the candidate generator.

**No source static blocker found.** Actual source identity is `fcbfaf198157718355bee19a5cf9cab5e567508e69f38050595e146b3d57e421`; actual C7→C64 unified diff exactly equals candidate.patch. Three companion files are byte-identical to C7.

Independently located exactly twelve pragma-unroll2 boundary loops. Replacing their bodies with the same marker reconstructs equal complete parent/candidate files. Thus loop headers and pragmas, row/kernel pointers, width block, initializers/stores, shared2 and its u1 remainder, whole-function exterior and dispatch are unchanged. This is stronger than relying on the audit booleans alone.

Resolved every boundary update's input-variable and coefficient-variable expressions. Each output chain keeps the identical predicate, original row+ik+vector*lanes load, matching kernel-row coefficient and separate multiply then add. Only independent outputs/vectors reorder within an ik iteration; all kernel row/column traversal remains unchanged. Loading all three input windows earlier adds no new address. Existing i+3L<=ow and ik<=kw−1 bound the final active element by inputWidth−1, including kw1 and the last full width block.

Per-boundary rows/counts independently matched audit: a/ab/abc/abcd/abcde/abcdef then bcdefg/cdefg/defg/efg/fg/g. Each has three input loads; row counts 1/2/3/4/5/6/6/5/4/3/2/1 give **126 FMUL-source operations, 126 FADD-source operations, 36 loads and42 broadcasts** across one iteration of each source body. All twelve original unroll2 hints remain.

This code-generation hypothesis is unmeasured. GCC may reschedule beyond source scopes; actual own AV correctness and boundary/shared-loop spill/frame review are required before any performance comparison. No previous C7/C61 pass is inherited and no best source/package is changed by this review.
