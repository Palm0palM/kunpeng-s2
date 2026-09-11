# CONV C4 submission package

Download [conv.zip](conv.zip) and upload it unchanged to the CONV competition task. Do not re-compress the version directory or include these notes in the ZIP.

C4 is the current verified best: measurement C19-r2, source candidate C19-sverow2. Adjacent output rows share SVE input loads while preserving each output's kernel traversal and separate multiply/add order.

Matched 38-core single-NUMA measurement: C3 591.29 ms -> C4 561.54 ms, a 5.03% time reduction, with every case improving. The exact ZIP was checksum-verified and extracted on compute job 1507738, then passed 3 complete suites (12/12 cases, zero error). Its per-case median total was 562.02 ms. All compilation and tests ran on scheduled compute nodes; local work only copied and inspected files. No official competition score is claimed.

The archive contains only conv/README.md, conv/bench_conv.c, conv/conv2d.c and conv/run.sh. The runner retains executable permissions. See [package.json](package.json) for member hashes and [SHA256SUMS](SHA256SUMS) for the archive checksum.

[Full report](../../../docs/CONV_SEP11.md) | [All version measurements](../../../docs/CONV_SEP11_ROUND_RECORDS.md)

After manual submission, report version C4, platform score, submission time and pass/fail status so the actual result can be recorded.
