# AE final tools independent static review

Reviewed on 2026-09-13 by `conv_o_accept_sep12`. **No blocking static finding in the final preparation. FINAL / STOP.** This review supplies no compute authorization or actual correctness/codegen result.

## Read scope and final identity

Read all of `driver.py` (344 lines), `accept_returned.py` (409), `freeze_returned.py` (294), `INTERFACE.md` (74), `README.md`, `STATIC_REVIEW.md`, preparation commands/failure record, both source manifests and `prepared.json`, and the complete 856-line `AC-to-AE.patch`. Reviewed against the previously read AC tools/checkers and the independently prepared C56 source. Only lightweight text reads, SHA calculations and byte comparisons were used; no AE import/execution, compilation, numerical test, SSH, job, accept or freeze was performed.

| Final file | SHA-256 |
| --- | --- |
| driver.py | `9da53a71ddf0258d378f387cd59afaa3df8f5ef76c6f5572d4ded4401d29ff88` |
| accept_returned.py | `cf75ab3c04baa70ef06d9e3df626a7b2ad41fb28fea1183b75df9d34e26529d3` |
| freeze_returned.py | `2233acea93aebedf85ac6c0f3005a080020b197199f1f63014f8b6718ba75456` |
| INTERFACE.md | `be59da4a268c451dd76223909facdb8212128d766bf6a3d8a150bbeb1f3c5a17` |
| AC-to-AE.patch | `97ae1d8c882d10b9270881a60869a5e43f483ca656851ba1cb01649064050db7` |
| PREPARED_FILES.json | `69517b205bb47ff5c09f89a95b6da33d8ed67d5333b810698e3b18fb8a315cda` |

Independent SHA calculation matched all 17 entries of `PREPARED_FILES.json`. Three `cmp` calls exited 0: AE `conv2d.c` versus final C56 production source, and each AE C checker versus its original AC transport source. The latter retain hashes `ccbba2637255b5d2733dfbfdddd88afd0d09815d5759ca86c9e8c498475990d5` and `fa47796ed01ca2a7d925176b25a6b18d6d124385bf21c1e452a3c2f9afc0f81d`.

## Source and parent contract

The only candidate is `C56-row7shared3fence`, source SHA `6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c`. The transport copy is the final 112355-byte C56 source. Parent identity and future codegen comparison use **C55-row7x3shared3 / own frozen AC 1582860**, source SHA `cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138`; actual parent assembly is bound by the frozen AC assembly file's SHA. AC PASS, PCs and spill counts are not populated as C56 results.

The actual standard C56 record has `parent: C55-row7x3shared3` and no `source_parent` key. Both driver and acceptor use `record.get('source_parent', record.get('parent'))`, so this missing-key case is accepted while an explicitly wrong/null `source_parent` still fails. This is a read-only compatibility check, with no metadata migration. The three creation snapshots retain their original common SHA `ecf3a299a5618a1ff55472a9ab4e96118d780185381258823621649a148dc7c8`; the current prepared record retains the C56 source SHA and `verified: false`.

The full source diff consists of the three specified empty volatile asm insertions, each with 21 read-only `w` inputs, zero outputs and a `memory` clobber. Arithmetic, triple-column loop/u1 remainder, other 12 stages and dispatch remain as in C55. Wrapper changes bind C56 identity/hash; the two numerical checkers are unchanged. The retained `preparation-failure-1.json` honestly records the initial missing-`source_parent` text-preparation failure and original exit/output; it is not presented as an operator or diagnostic result.

## Numeric, assembly and freezing gates

The unchanged six configurations are VL bytes 16/32/64 crossed with threads 1/4. Per configuration: full **5744** = core 3888 + narrow 144 + small 720 + larger 32 + inherited boundary family 960; dispatch **1212** = 972 + 240; direct **432**. Totals are **34464 / 7272 / 2592 = 44328**. Rowseven entries are **1236 dispatch / 1080 direct**, and worker masks are **1 / 15**. `quad_boundary` remains the inherited grid label, as documented; it does not claim four-column C56 arithmetic. Scalar reference, read-only guards, canaries, exact helper entry checks and documented scope limitations remain those of the original checker bytes.

Acceptance requires the candidate's own submitted original job identity, actual SUCCEEDED scheduler state with job/system exits 0, wrapper exit 0, all 19 ordered stage exits 0, exact numerical headers/counts, GCC 10.3.1 and the strict actual three compile command traces. Preparation is explicitly incomplete/uncompiled/unexecuted/unverified. No performance measurement or automatic next submission is implied.

`ae-shared3-fence-paths-v1` preserves 13 semantic stages and dynamic actual arithmetic region counts. Shared `triple_main` accounts for work 3; u1 remainder paths cover 0/1/2 columns. Multiple nonoverlapping actual ranges are supported, arithmetic counts scale with work, path execution sums must match each remainder, and every u1 block must be used by a declared path. There is no fixed 14-region requirement or prefilled actual line/PC/spill result.

The new `column_fence_review` requires the exact source contract, actual scheduling/cross-column/loop-boundary/spill-relocation explanations, and three ordered boundaries 0/1/2; boundary 2 includes the next main iteration. `schedule_tightened` and each `all_accumulators_ready_before_next_column_loads` must be booleans, and **false is accepted**. `column_fences_reviewed: true` means the review was completed; it does not assert a beneficial schedule. Empty asm need not have an emitted instruction or marker. Actual FADD/load ordering and full surrounding schedule must provide the evidence. Nonnegative spill observations, including unchanged or increased spill, remain valid reported outcomes.

Full helper/clone identity, complete stage/transition/tail/address/bounds review, scalar and indirect stack, Z/Q/predicate stack accesses, D-register ABI preservation and dispatch review remain required. Whole-file FMA detection and exact function coverage remain in place. The parent comparison is the actual C55/AC assembly. The freezer requires the accepted own-source/job/counts/schema and fence explanations, preserves original evidence under the shared lock and atomically creates a new frozen target. It does not package, promote or turn a schedule/spill observation into a speed claim. Actual failures and parser failures remain distinguishable, with original artifacts retained.

## Bounded serial gate and single submission

The fixed identities in code match the current on-disk originals: AD **1582956**, AC **1582860**, AB **1582814**, AA **1582656**, Y **1582410**, X **1582372**, T **1582134**. The exact four AD members (`C26-r32`, `C55-row7x3shared3`, `C52-r3`, `C26-r33`) all carry 1582956; the exact four AB members (`C26-r30`, `C54-row7x3shared4`, `C52-r2`, `C26-r31`) all carry 1582814. Present P/self-AE reservations are included; absent prepared reservations do not block. There is no broad scan of other agents' work.

Missing/conflicting fixed identities and unknown reservations block. Job IDs are deduplicated and must receive a successful actual status query with matching identity, terminal state and integer job/system exits before submission. A prior terminal performance failure still counts as serial completion; it is not changed into performance eligibility. The exclusive reservation precedes upload, `--go` is explicit, and any existing/uncertain reservation prevents a second submission. Status/fetch stay bound to that original job and allowed original text/assembly files.

No change to the author's final tools or preparation files was required. This review added only this file. Main account usage was read as 19%; no reset was used. **FINAL / STOP.**
