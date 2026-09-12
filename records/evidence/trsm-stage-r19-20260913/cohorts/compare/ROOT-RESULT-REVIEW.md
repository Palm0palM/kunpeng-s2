# r19 result review

Job 1582129 SUCCEEDED on COMPUTE_NODE, NUMA 2, CPU 76–113; 38 CPUs, 24 GiB, 1800-second limit, actual 217 seconds. Scheduler job/system and cohort exit codes are zero. Raw official rows and complete preflight summaries were inspected before finish_records.py executed once. All 27 formal and 9 warmup rows PASS, max error 1.11e-15. Formal ABC/BCA/CAB preserves all three independent suites per member; warmup ABC stays excluded. Actual reference/dependencies are KML25.1 and GCC12 libgomp, not specified KML25.2 revalidation.

|Member|Small ms|Middle ms|Large ms|Sum of medians ms|
|---|---|---|---|---:|
|T19-control13|15.17 / 14.30 / 14.55|122.78 / 121.78 / 121.03|180.75 / 180.40 / 180.26|316.73|
|T20-wideunroll2|14.06 / 14.64 / 13.47|120.15 / 118.22 / 119.66|174.89 / 174.38 / 174.34|308.10|
|T21-unrollfence|15.11 / 14.61 / 14.73|119.96 / 119.84 / 120.16|180.86 / 179.46 / 180.12|314.81|

T20 gains 2.72472% total and 3.33703% large, but total is below 8.32148% noise. T21 gains only 0.60619% total, below 5.97938%, with small-case regression 1.23711%. Neither qualifies. T20-to-T21 mechanism-only comparison shows T21 large-case regression 3.29166% and total regression 2.17786%; it is not promotion authority. Current T19 source remains byte-identical to the baseline; no promotion or new ZIP.

All three complete CT64/KB256 wide preflights passed: each has 28 direct micro cases, 28 whole cases, 56 argument cases, 463420 observations and zero mismatches, seven test processes. All 15 steps in each summary.tsv exit zero; guard job IDs are 1582129 with 38 assigned CPUs. Original raw official/warmup/identity/linkage audits passed before recording. Both prior records from r18 are preserved completely. Historical small-path full validation remains T19 job1579861 and was not rerun. No local task code, sanitizer or hashes.

## Actual target assembly

Read the uninstrumented assembly from final diagnostics; the earlier T21 preview is byte-identical to the final file. All hot loops are .L25, with no [sp] accesses. T19 has 34 instructions / 16 FMLA per k. T20 has 78 instructions per two k, 26 FMLA + 6 FMAD, 8 MOVPRFX, 8 MOV broadcasts/moves. T21 has 71 instructions per two k, 19 FMLA + 13 FMAD, 1 MOVPRFX, still 8 MOV broadcasts/moves. T20 saves d8–d15 outside the hot loop; T21 uses no such vector ABI saves, while still retaining its general-register stack frame. These are static code observations, not a performance model.

Reducing MOVPRFX did not improve measured performance. Restricting load scheduling is a plausible cause to investigate, not a proven causal conclusion. Next prepare a distinct T22 keeping the same accumulator constraints but removing only their memory clobbers, then inspect target assembly and compare with T19/T20. Preserve the failed T21 attempt and do not adjust promotion gates or merge historical samples.
