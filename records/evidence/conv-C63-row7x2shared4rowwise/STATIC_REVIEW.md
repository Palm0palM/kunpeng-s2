# C63 source-only static review

Generated from the recorded C62 source with one bounded quad-loop replacement; reverse replacement reproduces C62 bytes exactly. Each of four columns retains identical input offsets, seven weight addresses and two updates per row. Statement order changes only between independent output chains; each chain still processes ik, ik+1, ik+2, ik+3. Source body counts remain 56 separate mul + 56 add + 8 input loads + 28 broadcasts.

Input windows/predicate and kw-ik>=4 guard are unchanged from C62. Earlier loading of v1 accesses the same valid window; no extra memory read or full-width tail access is introduced. Seven-row/2VL layout, all 12 boundary unroll2 hints, remainder, stores, dispatch and other helpers are original C62 bytes. Official benchmark and runner match C7.

Textual address/expression checks and reverse-byte proof are preparation checks only: no operator compilation, correctness run, sanitizer, assembly or performance measurement was performed. Prepared status is not PASS. Standard creation metadata remains separately preserved; extended metadata identifies C7 parent and C62 design source.
