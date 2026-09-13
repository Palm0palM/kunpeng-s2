# C62: 7 rows, two vectors, four shared columns

Joint tile hypothesis from C7: reduce only rowseven width from 3VL/21 accumulators to 2VL/14 accumulators to make room for shared four-column unrolling. Preserve seven-row dispatch, twelve boundary unroll2 hints, strict per-output ik0..3 separate mul/add, scalar-column remainder and all fallback/companion code. This jointly changes vector width and shared unroll, not an isolated single-parameter experiment.

This is a combined register-budget hypothesis. C54 tried 7x3VL/shared4 and regressed with substantial scalable spills; C48 tried 8x2VL/u1. Neither is this tile. Reducing width raises coefficient-broadcast work per output by about 50 percent, which may outweigh improved scheduling or fewer spills. GCC can reorder independently; no spill reduction or speedup is claimed. C7 remains best.
