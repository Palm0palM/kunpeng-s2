# r14 actual target assembly: history budget

Read the assembly emitted on the allocated compute node by r14 preflight; no local compilation or assembly generation occurred. This is an instruction/control-flow observation, not a phase timing or cache-counter result.

T17 `diagnostics/preflight-results/T17-lhistbudget4/trsm-panel16.s`: lines5026–5031 form b*(b-1), shift left10 (1024 bytes), compare x2 with4194304 and branch `bls .L530`. The zero-initialized history pointer at `[sp,80]` remains zero when over budget. `.L530` at5122 performs the allocation at5136; nonzero return branches to the existing `.L523` fallback, while success stores the pointer and rejoins it. The earlier `tst w0,4194304` is HWCAP SVE bit22 detection, not the byte-budget comparison.

T18 `diagnostics/preflight-results/T18-budgetwide/trsm-panel16.s`: corresponding byte calculation/comparison at5515–5520 and `.L568` allocation branch at5611–5630 exhibit the same budget semantics. The separate earlier HWCAP test at5510 is again not the budget gate.

The independently observed allocation rows establish actual boundary behavior: m1039 needs4128768 bytes and may allocate shared history; m1040 needs4259840 bytes and skips it under the4MiB policy. Source guards and preflight also cover unsupported/narrow SVE and failure paths. No claim is made that this budget equals a hardware cache size or that these instructions alone demonstrate performance improvement.
