# r20 controller review

Reviewed source and controller differences against successful r19. A/B remain unchanged T19/T20 repeats, now requiring complete prior records from job1582129. C=T22-unrollreg is a new child of current T19-control13. T22 differs from measured T21 only by removing the two memory clobbers and correcting its comment; both empty read/write vector constraint groups and all 16 accumulator variables are preserved. Arithmetic, addresses, tails, small paths and support files are unchanged. Compiler acceptance and speed remain target-only questions.

Protocol remains ABC warmup, ABC/BCA/CAB three independent formal suites, TEST_RUNS=3, 27 formal/9 warmup rows. All three full CT64 wide preflights and guard job/38-CPU checks are required. Raw official/warmup/dependency audits precede all record writes. T20-to-T22 is mechanism-only; promotion parent remains T19-control13. All exclusivity, prior identity and frozen-source checks remain. No automatic promotion, sample pooling or gate changes. Preflight/reference/wrapper bytes match r19. Historical small-path validation stays explicitly job1579861.

Local validation comprised manual source/controller diffs, Python AST, bash syntax and direct source comparisons. No local task execution, sanitizer or hashes. Reviewed before prepare.
