# T22 target validation plan

Compare unchanged T19-control13, unchanged T20-wideunroll2, and new T22 in a fresh single-NUMA allocation, at most 38 CPUs, 24 GiB and 1800 seconds, with actual KML25.1/GCC12. Both repeat members preserve their full prior from r19 job1582129. T19 is the promotion parent; T20 is the mechanism control. Do not compare against historical T21 timings as if measured together.

All members run complete existing CT64/KB256 wide32 preflight: counts 0/1/2/7/31/255/256, packed/strided inputs and padding (28 direct cases), 28 whole cases, 56 argument checks and seven test processes, including allocation failure/no SVE/actual narrow VL and KB tails. Generate uninstrumented target assembly and inspect loop fused ops, MOVPRFX, load scheduling and stack references. Keep unmodified small-path full validation explicitly historical job1579861.

One official warmup ABC, then formal ABC/BCA/CAB, each member three complete suites, TEST_RUNS=3. Preserve all 27 formal and 9 warmup rows, actual dependencies, environment and original logs. Keep the existing noise/per-case promotion gate, no pooled samples. No local preprocessing/compilation/testing, no hash operations. Only a qualified promoted winner can proceed to independent exact-ZIP validation.
