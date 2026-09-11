# T6-pair2budget preparation

Prepared from promoted T5-sve16rows on 2026-09-11. The existing solve_panel function is preserved in place without modification. solve_panel_grouped derives from the measured T5-panelpair candidate and permits a fixed maximum of 2 adjacent 8-column panels in each group. No compilation, test, benchmark, or hash operation was run locally. No scheduler job or publication was performed.

## Hypothesis

The earlier unconstrained pair candidate improved the smallest official case but regressed the middle case. Restrict grouped execution to a documented 256 KiB tuning budget for packed RHS panels plus four current L rows. The budget is not a claim about hardware cache capacity. For positive dimensions that select the small-workset algorithm, grouping is eligible only when m*(2*8+4)*sizeof(double) <= 256*1024. This permits m <= 1638; larger m calls the original solve_panel. The independent 64 MiB small/large dispatch and all SVE16 blocked code remain unchanged.

Within eligible groups, the actual OpenMP team size must leave at least two groups per worker: ceil(n/8) >= 2*2*actual_threads. Otherwise solve_panel_grouped uses one panel per task and allocation. Each group advances four rows across its independent panels, retaining panel_sums, increasing-k and increasing-q chains, diagonal division order, zero-padded invalid lanes, and scalar allocation-failure fallback. The last group processes only its real panels and columns. Official benchmark, runner, and compatibility header are copied unchanged.

## Required target-node boundaries

- Budget: m=1637/1638/1639; n=65 is sufficient to enable grouping with one thread. Include m%4 row tails. The budget-above case must call the unmodified solve_panel.
- Thread threshold below/at: 1 thread: n=24/25; 4 threads: n=120/121; 38 threads: n=1208/1209. Use small m such as 5 or 65 to keep all these calls within the budget.
- Final incomplete group: n=33 (1 thread), n=129 (4 threads), n=1217 (38 threads). Also check partial last columns around 7/8/9, 15/16/17, and 31/32/33 where practical.
- Independent lda/ldb padding, L immutability, 1e-12 tolerance, and nonpositive dimensions unchanged. Force allocation failure both below and above thread thresholds, and on both sides of the budget threshold.
- Existing large-path, SVE guard and allocation-failure tests still apply to the baseline. Final comparison must use three complete official suites per member in one scheduler allocation with identical 38-thread settings, TEST_RUNS=3, and the actual reference library recorded.

Only this candidate directory was edited. This is preparation, not a correctness or performance claim.
