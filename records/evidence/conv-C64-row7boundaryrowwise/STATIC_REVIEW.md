# C64 source-only static review

Exactly12 pragma-marked boundary bodies replaced; loop headers, pragma2, input/kernel pointer definitions, predicates, block bounds, accumulator initialization/stores, shared2/remainder and dispatch remain byte-identical to C7. Replacing each generated body by its saved old body reconstructs the entire parent file exactly.

|Boundary|Rows|Mul|Add|Loads|Broadcasts|
LOCAL_USER---LOCAL_USER---LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER
|input_0|a|3|3|3|1|
|input_1|ab|6|6|3|2|
|input_2|abc|9|9|3|3|
|input_3|abcd|12|12|3|4|
|input_4|abcde|15|15|3|5|
|input_5|abcdef|18|18|3|6|
|trailing_0|bcdefg|18|18|3|6|
|trailing_1|cdefg|15|15|3|5|
|trailing_2|defg|12|12|3|4|
|trailing_3|efg|9|9|3|3|
|trailing_4|fg|6|6|3|2|
|trailing_5|g|3|3|3|1|

For each active chain, symbolic matching preserves the same input window/predicate and same kernel row/ik coefficient with separate multiply then add. Only independent output chains reorder; t/ik traversal is unchanged. Loading v1/v2 earlier introduces no new address, including kw=1 and final full output block. Existing full-window bounds still apply.

All12 unroll2 hints remain. Totals across one iteration of each boundary source body are126 mul,126 add,36 input loads,42 broadcasts. This is static source count, not dynamic execution or assembly. Official runner/benchmark/README match C7. No local operator compile/test, no diagnostic template, network or submission. Standard creation originals preserved before extended metadata; prepared is not verified.
