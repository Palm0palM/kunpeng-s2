# C63 source and AU performance static review

Reviewer `/root/c61_review_resume`, 2026-09-13. Read C63 source, complete `delta-from-C62.patch`, and AU performance driver. This file is the sole edit; no source/driver modifications, imports, operator compilation/execution, test or submission. Local Python only compared text/bytes, parsed Python AST and counted source statements.

## C63 source: no static blocker

- Actual C62-to-C63 source diff exactly equals saved `delta-from-C62.patch`. The prefix before the shared quad and suffix starting at u1 are byte-identical. Thus changes are confined to the shared four-column body; whole-function exterior, all twelve boundary unroll2 hints, u1 remainder, width/vertical bounds, dispatch and fallback remain unchanged. Three companion files match C62.
- Actual C63 source identity is `d78a863eb49c85d415420819e4b6ef8379260a34ad9f118da5bab1bdca7e94a8`, matching AU's candidate identity gate.
- Each column loads v0/v1 from the same original two windows, then seven separate row scopes each broadcast one matching coefficient and update that row's two independent accumulators. Column sequence is exactly ik, ik+1, ik+2, ik+3. All fourteen chains receive four updates in that order, with unchanged separate multiplication/addition. Source reordering changes independent row/vector scheduling, not any chain's reduction order.
- Static quad counts are **56 svmul, 56 svadd, eight svld1 and 28 broadcasts**. No EXT, new address, arithmetic reassociation, FMA, new predicate or widening load is introduced. Existing kw-ik>=4 and width2L bounds apply unchanged.
- This static result does not establish actual GCC schedule/spill improvement, runtime correctness or speed. C63 needs its own AT diagnostics and controlled AU performance. C62's AR pass cannot be inherited.

## AU driver: one concrete preparation defect found

Initial active `diagnostic()` required `TARGETED_AUSEMBLY_REVIEW.md`. This is a corrupted AS-to-AU token replacement; actual diagnostic acceptance produces `TARGETED_ASSEMBLY_REVIEW.md`. The malformed path would stop AU despite a valid AT review. Root was notified to correct the driver before use and preserve the initial template evidence. Do not create a misspelled review file to bypass the condition. `Exact12PAUS/error0` is a second corrupted token, limited to an error string; correct it to PASS for clear records. Reviewer did not edit the driver.

Other inspected behavior is correct:

- AT_JOB_ID=None intentionally prevents execution before the real own AT job is saved and bound. Candidate is C63; diagnostic directory is its own `sve-correctness-sep13at`. Passed/complete 44328 cases, candidate/source identity, original bound job, actual assembly/root review and fresh successful scheduler zero exits remain required.
- Controls C58-r10 and C58-r11 surround C63, have no existing directories/records at review, and the AU campaign does not exist. They are new unchanged C7 controls. Settings match measured C7; all three execute sequentially within one allocation, each with three full suites.
- Result gates remain four cases × three samples × three members =36, all standard verified checks, exact original samples, error zero, wrapper and scheduler exits zero, same job/machine/settings/compiler/38-thread allocation, and unchanged controls. Both opening and closing comparison eligibility are required before separate confirmation. No automatic promotion/packaging is enabled.
- Unique campaign/member reservations and original creation snapshots remain; uncertain submissions must be reconciled rather than repeated. C7 remains authoritative.

Pending: root corrects the malformed assembly path (functional) and PASS string (cosmetic), then this preparation issue can be closed by a read-only check. The new AT template itself is outside this review.

Follow-up: root rebuilt AU from AS with bounded replacements, retaining the initial malformed template and corrected diff. Read-only verification confirms active `TARGETED_ASSEMBLY_REVIEW.md` and `Exact12PASS/error0` are restored, both corrupted tokens are absent, Python AST parses, and AT_JOB_ID remains None. **The AU preparation defect is closed; no static AU blocker remains.** Actual own AT acceptance and ID binding remain prerequisites.
