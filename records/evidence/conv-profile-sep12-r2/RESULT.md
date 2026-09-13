# C6 task-only profile r2

Job1579588 SUCCEEDED, job/system/wrapper exits0. Original case4 reports one PASS. record/report/annotate/objdump all exited0. Transport manifest and symbol/ELF address mapping were checked.

The capture contains38266 samples;2666 map to conv_sve_rowquad in conv2d_profile. Total lost samples0. Quad accounts for6.75% of whole-process sampled event periods, while the official reference dominates93.10%; these are not operator CPI. Within quad, the shared two-column loop0x4055f8..0x405768 accounts for approximately92.90% of rounded local event periods. The loop has93 instructions,32FMUL and32FADD. Its first LD1RW IP has25.25%, but sampling skid and attribution bias prevent calling this cache-miss latency or proving a broadcast bottleneck.

The old remote parser reports inconclusive only because its regex misses the new IPC suffix columns. Original files remain unchanged; report and annotate both explicitly show2666 quad samples. See profile-analysis.json for actual regions/IPs and limitations. The percentages are rounded (all annotation rows sum100.11%). Validation/warmup/timed conv invocations are combined. No instruction/stall/cache event or pure timed-region CPI was collected; the249.79ms printed under perf is diagnostic and never a performance record.

This establishes the shared quad loop as the useful next profiling/optimization region, not a specific hardware-cause explanation. No further profile job was submitted.
