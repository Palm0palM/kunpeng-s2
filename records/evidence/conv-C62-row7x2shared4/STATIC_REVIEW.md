# C62 static scope, arithmetic and bounds

Prepared source only; no compilation, checker, sanitizer, benchmark, remote job or score exists.

Only conv_sve_rowseven changes. Seven output rows and thirteen input-row phases remain; every phase now has two full SVE vectors per output, fourteen independent accumulators. Each lane still receives the original kernel row order; shared columns are ik, ik+1, ik+2, ik+3, each separate mul/add. The remainder runs one column for zero through three columns. Twelve boundary unroll-2 pragmas remain. The dispatch, kh<7 defensive fallback, width fallback calls and all other helper functions are byte-unchanged; fallback width argument naturally becomes ow-i after a 2VL tile.

For main width tiles, ow-i>=2L implies i+2L<=ow. Maximum loaded column is column<=kw-1. The last active element of vector one is i+column+2L-1 <= ow+kw-2 = inputWidth-1. Shared quad condition kw-ik>=4 ensures ik+3<=kw-1; no signed ik+4 guard overflow is introduced. After each quad ik advances by four and u1 covers every residual column in original order. No new pointers or predicates are added. Existing vertical t/kh and seven-output dispatch bounds remain unchanged.

Static shared body: 56 ordinary svmul plus 56 svadd, eight full input loads, 28 coefficient broadcasts, four updates for each of fourteen chains. Source vector-two scopes, initializers and stores are removed only inside this function. This is source-level reasoning, not a proof of generated code or runtime behavior.

Future own diagnostic must use EXPECTED_ACC=2, BLOCK_OUTPUTS=2L and widths around 2L and 4L, including the existing kw4..8 remainder coverage. Retaining the same family cardinalities permits 5744 full/1212 dispatch/432 direct per configuration, but the new checker and expected entry/fallback coverage must be independently reviewed before execution. It may not inherit C61 or C7 acceptance. Future shared4 assembly expects 56 FMUL/56 FADD/8 LD1W/28 LD1RW in semantic work, with actual schedule/spills to be measured; u1 expects 14/14/2/7.
