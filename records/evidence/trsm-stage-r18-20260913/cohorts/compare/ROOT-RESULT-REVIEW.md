# r18 result review

Job 1582004 SUCCEEDED on COMPUTE_NODE, NUMA 2, CPU 76–113, 38 threads; scheduler job/system exit codes and cohort exit are zero. Duration 145 seconds. Observed raw official rows and both complete wide-preflight summaries before executing finish_records.py exactly once. Registration returned passed/verified for both members and comparison eligible=false. A subsequent unrelated rg command used an obsolete local candidate directory and returned 2; it did not invalidate or rerun the already successful finish action.

Formal AB/BA/AB: 18/18 PASS; independent warmup AB: 6/6 PASS. Both sources match their frozen inputs and original r17 measured implementation, with the complete r17 prior preserved. All formal samples retained, no pooling. Raw formal and warmup audit checks, actual KML25.1/GCC12 linkage, resource and identity checks passed. This is not specified KML25.2 revalidation.

|Member|Small ms|Middle ms|Large ms|Sum of medians ms|
|---|---|---|---|---:|
|T19-control13|14.54 / 14.96 / 14.63|122.84 / 123.44 / 119.39|180.00 / 180.58 / 181.11|318.05|
|T20-wideunroll2|14.33 / 13.97 / 14.33|120.86 / 120.55 / 118.15|174.69 / 174.30 / 174.87|309.57|

T20 gains small/middle/large 2.0506% / 1.8642% / 3.2617%; total 2.6662% below the unchanged 3.2970% noise threshold. No individual regression this round, but total gate still fails. Do not promote. Current source and ZIP remain T19, measurement ID T19-control13. The middle-case variation reversed relative to r17 despite unchanged small-path source; do not attribute that change to the wide-loop optimization or pool runs across nodes.

Both members repeated the complete CT64/KB256 wide preflight: 28 micro, 28 whole, 56 argument cases, 463420 observations and zero mismatches, 7 test processes. All 15 recorded steps exit zero, including allocation failure, no SVE and actual narrow VL. Unchanged small-path full tests are historical job 1579861, not newly executed. No local task code or sanitizer ran.

The r17 compiler output identified eight MOVPRFX instructions in each unrolled pair. Next prepare a separate candidate that restricts register lifetimes between the two k steps and inspect actual target assembly/performance before making any speed claim. Preserve T20 as the mechanism control and T19 as the promotion parent.
