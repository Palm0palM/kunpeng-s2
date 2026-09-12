# Independent static review

A second read-only review confirmed four-float replicate and per-128-bit lane indexing match; every accumulator uses lane 0,1,2,3 in order. kw-ik>=4 protects all coefficient loads and the last input window; original pair/single remainder code is preserved. Low-Z constraints can cause moves/spills and remain a remote code-generation question. No local compilation/tests or extra hash scan.
