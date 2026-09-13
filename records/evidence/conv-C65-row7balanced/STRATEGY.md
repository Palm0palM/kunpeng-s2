# C65: coalesced balanced seven-row dispatch

Balance only current C7 seven-row SVE dispatch: partition the flattened row-group/3VL-width-tile domain by actual OpenMP team using quotient/remainder intervals, merge each worker contiguous same-group tiles into one unchanged helper call, and preserve per-output arithmetic. One common 3VL partition width is selected after worker-local target-safe VL query. Existing helpers and all other dispatch remain unchanged. No fixed 256-column subcalls or timed allocation.

C7 group counts580/872/601/902 give maximum per-worker counts16/23/16/24 at38 threads. Equal-group-cost imbalance model has a weighted ceiling about1.41 percent of C7 measured time; this is a hypothesis budget, not a score or prediction. Historical C30 flattened four-row/fixed256-column chunks. C65 differs by7-row C7,3VL alignment and coalescing: at mostP-1 worker boundaries add group fragments, avoiding a helper call per small chunk. Real setup, partial-row/tail costs, cache effects and uneven work can erase this small budget.

No compiler, test, diagnostic, benchmark, job, qualification or package exists for this candidate. It must not inherit existing rowseven entry-count expectations.
