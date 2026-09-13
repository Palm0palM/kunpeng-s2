# Bounded next hypothesis after C64

Independent reviewer recommends C7 dispatch-only workload partition. Keep seven-row/3VL shared2 and all helper bytes. Linearize (group, ceil(ow/(3VL))) aligned tiles; split contiguous tile ranges across actual OpenMP workers and merge each worker's tiles within one row group into a single helper call. At most thread_count-1 extra row-group fragments; avoid one helper call per tile. Preserve final-column and remaining-row behavior exactly.

Four official row-group counts580/872/601/902 under38 workers currently require16/23/16/24 groups on busiest workers. Equal-group-cost upper-bound imbalance recovery4.61%/0.229%/1.15%/1.10%; weighted by C7 measured case times about6.17ms/1.41% total. This is a model, not measured improvement or guarantee. Extra setup/cache/partial tail cost could consume the entire budget.

Prior C30 tried four-row fixed256-column flattening,447.65ms/+1.04% gain rejected by2.02%spread. New hypothesis must distinguish seven-row confirmed C7,3VL alignment and coalesced intervals adding at most37 fragments rather than fixed chunk calls. Do not claim load balancing is untried generally.

Correctness coverage must independently derive dispatch/helper-entry expectations for the new partition, covering actual1/4/38 workers, VL16/32/64, fewer tiles than threads, split row groups, column and row tails, per-output exact once and no overlap. Do not copy current1236 expected entries after changing dispatch. No candidate or new job created by this note; decide after AW original comparison and start from actual best.
