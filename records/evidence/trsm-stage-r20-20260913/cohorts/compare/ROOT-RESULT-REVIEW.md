# r20 result review

Job 1582239 SUCCEEDED on COMPUTE_NODE, NUMA 2, CPU 76–113, 38 CPUs; actual duration 225 seconds. Scheduler job/system and cohort exits are zero. Inspected raw official rows and complete wide preflight summaries, then executed finish_records.py exactly once. Formal ABC/BCA/CAB: 27/27 PASS; excluded independent warmup ABC: 9/9 PASS; max error 1.11e-15. Raw official/warmup/identity/resource/linkage audits passed. Actual KML25.1/GCC12, not specified KML25.2 revalidation.

|Member|Small ms|Middle ms|Large ms|Sum of medians ms|
|---|---|---|---|---:|
|T19-control13|14.34 / 14.60 / 14.60|120.26 / 121.82 / 120.24|181.49 / 181.53 / 181.08|316.35|
|T20-wideunroll2|15.76 / 14.57 / 14.44|119.88 / 120.75 / 120.53|195.75 / 174.53 / 174.08|309.63|
|T22-unrollreg|14.36 / 14.76 / 14.67|120.25 / 120.61 / 118.85|180.08 / 188.08 / 194.50|323.00|

T20 total gain 2.12423%, below 12.41620% noise; T22 total regression 2.10210%, large regression 3.63105%, noise threshold 7.66695%. Neither is eligible. T20-to-T22 is mechanism-only: T22 large regression 7.76371%, total regression 4.31806%. Retain all samples, including T20 large 195.75 ms and T22 large 188.08/194.50 ms; do not replace slow samples or merge old timings. Current T19 source remains byte-identical, no promotion or new ZIP.

Each member completed 28 direct micro, 28 whole, 56 argument cases, 463420 observations with zero mismatches and seven test processes. All 15 steps exit zero. Guard identities match job1582239 and 38 CPUs. Includes zero/odd tails, padding, packed/strided loads, failed allocation, no SVE, actual narrow VL and KB tails. Unchanged small-path full validation is historical T19 job1579861. No local task execution, sanitizer or hashes.

## Assembly evidence and conclusion

The entire uninstrumented trsm-wide4x32.s file generated for T22 is byte-identical to the historical T21 file from job1582129, including update4x32_sve. This is assembly-text equality, not a claim that remote executable binaries were verified equal. The loop remains 71 instructions / 32 fused multiply-adds / 1 MOVPRFX per two k, no hot stack access or vector ABI saves. T20 remains 78 / 32 / 8; T19 remains 34 / 16 / 0 per k. Ordinary MOV counts remain eight per pair for T20/T22.

Removing only memory clobbers did not alter this compiler output; it cannot explain a cross-round T21/T22 timing difference. The requested compiler experiment is complete and unpromoted. Preserve both failed constraint variants and shift to an independent T19 small-path history-loop candidate. Any new small-path change requires fresh panel8x16 tests; wide-only historical validation is insufficient.
