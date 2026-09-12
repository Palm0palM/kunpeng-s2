# Independent static source review

Reviewed against C21-r3 after checkpoint. Only conv_sve_rowtriple changed; preceding helpers, top-level dispatch, non-SVE body, README, benchmark and runner remain byte-identical.

All five phases consistently extend a/ab/abc/bc/c accumulators from 4 to 6 vectors. The paired coefficient loop preserves k0 then k1 for every accumulator, the odd final coefficient paths update a4/a5, b4/b5, c4/c5 as applicable, and all 18 vectors are stored. x3/x4 use adjacent vectors, x5 uses p+5VL+1, and no complete v6 is loaded. Full tile guard ow-i>=6VL proves shifted source windows and stores remain in bounds. Residual width remains below6VL and falls through the unchanged prefix/tail helpers. kh<3 and row group dispatch are unchanged.

This source inspection does not establish target performance or absence of spills. Remote guard/dispatch correctness and assembly inspection are still required before official performance measurement. No local compilation or tests were performed.
