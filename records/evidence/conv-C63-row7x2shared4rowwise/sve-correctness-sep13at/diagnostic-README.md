# AT C63 prepared diagnostic

Own unexecuted diagnostics for C63-row7x2shared4rowwise, source parent C58-r1=currentC7. Only C62 shared4 internal scheduling changed to two input vectors followed by one scoped weight per row. Source count remains56mul/56add/8loads/28broadcast; no actual spill reduction or speed claim.

Both checker files are byte-identical to the executed AR package, including EXPECTED_ACC2 and all2VL/4VL width boundaries. CHECKER_COUNTS.md is the original AR derivation copied verbatim as reusable coverage documentation, not C63 results. Wrapper only substitutes candidate and source identity; candidate.env only substitutes candidate. Matrix44328 and19 stages, GCC10.3.1 strict/generic,38CPU24576MiBsingle packed NUMA1800,VL16/32/64 bytes x threads1/4 unchanged.

The driver requires original AS1590550 complete with order C58-r8/C62-row7x2shared4/C58-r9 and36 recorded samples, plus live terminal status and integer job/system exits. AS was running when preparation was requested; this preparation never queries it. Unknown reservation, missing results, query failure or nonterminal status blocks root GO. Root remains sole submitter. Current C63 four production files, frozen five transport files, creation identity and confirmed C7 source are checked without rewriting metadata or inheriting AR PASS.

No job.json, raw, summary or numerical acceptance exists. Archive names include ROOT_REVIEW.md and INDEPENDENT_TOOLS_REVIEW.md; both are currently NOT_REVIEWED and deliberately absent, not fabricated approvals. Root/independent review must create actual reports before acceptance. Real AT_SUMMARY, targeted shared4 rowwise/u1 assembly and ROOT_RETURNED_REVIEW can only be made from original returned evidence. Acceptance remains one-shot44328 validation and freeze; no performance, confirmation, promotion or ZIP.

Prepared interfaces, NOT EXECUTED:
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json status
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json fetch
python3 .runs/conv/sep13at-checks/accept_and_freeze.py --job-id <actual_original_AT_ID>

All future calls retain argv/UTC/stdout/stderr/exit via sep13-run-logged.py. No local operator execution or reset card. The user cancelled the old40-percent threshold; do not treat historical stop metadata as current policy.
