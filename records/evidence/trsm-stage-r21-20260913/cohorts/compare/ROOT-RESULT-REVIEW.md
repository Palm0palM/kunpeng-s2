# r21 actual result review

Known job1582392 SUCCEEDED, job/system/cohort exits zero, 529 seconds, compute NUMA2 CPU76–113. Both strict original-log audits and KML25.1/private GCC12 linkage checks pass: 18 formal and 6 warmup, three full suites/member AB/BA/AB. All samples retained. No historical pooling.

Both dedicated panel8x16 preflights pass 37/37 steps, 27 processes: 46 micro, 615 whole, 96 noop, 32 budget groups; 633 argument cases and 6388 observations with no mismatch. Guards bind to job1582392 and 38 CPUs. Original instrumented-copy-only hook and original assembly audited. Maximum preflight error3.88578e-16; official max1.11e-15.

T19 medians14.41/119.57/180.48 =314.46ms; T23 14.40/128.33/181.95 =324.68ms. Middle regression7.32625%, total regression3.25002%, original noise threshold4.44136%; candidate ineligible. Keep T19-control13 and unchanged exact-tested T19 ZIP. Fresh prior record preserves r20 job1582239.

Final collected assembly matches both earlier previews byte-for-byte. T19 history37instructions/16FMLA per k, T23 81/32 fused operations per pair and eight MOVPRFX. Neither hot loop accesses stack. T23 has a larger112-byte ABI frame versus32; saves are outside the hot loop. These observations do not isolate one causal instruction. No hash/binary-identity claim.

No source promotion, new package, local task execution, sanitizer claim, reset credit, shutdown or contest submission. Actual KML25.1 is not the specified KML25.2 validation. Next experiment should start from T19, not the regressed T23.
