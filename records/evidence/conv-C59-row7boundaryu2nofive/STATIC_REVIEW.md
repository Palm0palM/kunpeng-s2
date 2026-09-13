# C59 source-only static review

Standard new copied all four C58 source bytes matching its current record. conv2d also matches the frozen AH source. Original creation experiment/record bytes are retained separately; their C58 source hashes are not refreshed. Current hashes are recorded by source-audit and standard checkpoint.

The input_5 marker-to-shared region contains exactly one pragma. Removing this one line changes the total count12 to11. Inserting it back at the same offset restores the entire parent conv2d byte sequence. All other code, including input_5 loop/18 updates, per-tile resets, shared2/u1, kh defense, width/height remainders and dispatch, remains identical. Other three files remain byte-identical.

A future own remote diagnostic must check actual default lowering, odd/even columns, guards/counts/exits, fused0, spill redistribution and stack changes; AH44328 is not inherited. Actual performance is unmeasured. No operator, compiler, test, SSH, job or diagnostic tool was run. C58 parent metadata and record were not written.
