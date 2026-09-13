# C64: rowwise weights in twelve C7 boundary loops

Only C7 rowseven boundary column bodies change: first load three input vectors, then broadcast one participating row coefficient in its own scope and update that row’s three accumulators. Input boundaries use a/ab/abc/abcd/abcde/abcdef; trailing boundaries use bcdefg/cdefg/defg/efg/fg/g. Shared2 and its scalar-column remainder remain C7 bytes.

This aims to shorten simultaneous coefficient lifetimes in the boundary loops where C7 emitted scalable spills. It lengthens simultaneous input-window lifetime; GCC can reschedule, retain or add spills. There is no correctness, spill-reduction or speed claim until own scheduled-node diagnostics and performance.
