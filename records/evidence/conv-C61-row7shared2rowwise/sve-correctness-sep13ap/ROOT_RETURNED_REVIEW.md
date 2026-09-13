# AP root returned evidence review

Root read AP_SUMMARY.md and actual C61 shared-pair/remainder assembly and prologue. Original AP1590209 returned44328 checks,19 ordered zero-exit stages, GCC10.3.1,38CPUs/24576MiB single packed NUMA; job/system/wrapper0. No performance claim.

Actual pair .L407 has 123 instructions with6 LD1W,14 LD1RW,42 FMUL/42 FADD and no vector stack instruction. Remainder 63 instructions,3/7 loads/broadcasts and21/21 mul/add; no vector stack instruction. GCC interleaves independent output updates from both columns while preserving each chain, as also checked by bitwise tests. Root read exact prologue720B+3VL. Full helper static count includingret=2449; independent targeted review will cover parent comparison and vector stack slots. Counts are static and do not establish speed.

Only after reading the targeted report may the root execute one acceptance; AQ requires accepted own diagnostics. No local operator execution, no reset. The40% limit was explicitly revoked by user.
