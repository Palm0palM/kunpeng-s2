# T21 required target validation

Use a fresh scheduler allocation, KML25.1/GCC12, at most 38 CPUs, one NUMA, 24 GiB and 1800 seconds. First compile and generate uninstrumented target assembly on the compute node. Inspect update4x32_sve for MOVPRFX, FMA order, loop branches and hot stack accesses; compilation alone is not correctness.

Run existing complete CT64/KB256 wide32 preflight for T21, T20 and T19: 28 direct micro cases (counts 0/1/2/7/31/255/256; packed/strided; padding 3/11), 28 whole cases, 56 argument checks, seven processes, allocation-failure, no-SVE and actual narrow-VL paths. Keep unchanged small-path full tests explicitly historical and associate unchanged source bytes.

Then one official warmup per member and three interleaved full official suites each, TEST_RUNS=3. Preserve all actual samples and reference/linkage/identity evidence. Compare T21 with current parent T19-control13 for promotion; T20 is a mechanism control, not a substitute parent. Do not pool historical samples or lower the existing noise/per-case gate. Only an eligible verified candidate proceeds to separate exact-ZIP validation.
