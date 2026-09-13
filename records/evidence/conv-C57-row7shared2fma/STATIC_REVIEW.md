# C57 static source review

Final source SHA256 `3cc03ec4d13422238b1e461dd7213876cc50283a7433132ee94b41c4724ec6c5`, 107407 bytes. Original parent C52 SHA256 `8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7` matches frozen T1582134 raw bytes. The production change is confined to shared source lines 1477–1613; 63 actual replacement lines are listed in source-audit.json.

The complete candidate.patch was read: three hunks correspond to main ik, main ik+1 and u1 remainder. Each contains exactly a..g × lanes0..2 = 21 substitutions. Every accumulator is changed three times; multiplier v and its matching a..g coefficient, addend accumulator, predicate and statement order are preserved. All loop bounds, pointer expressions and lexical scopes are unchanged. The generator's reverse replacement exactly restores the entire parent source; prefix/suffix are byte-identical. README.md, bench_conv.c and run.sh are separately byte-equal to parent, with individual hashes in source-audit.json.

This is a fused-rounding change. Source-level svmla count is 63; there is no machine instruction count, actual FMA/spill observation or numerical PASS. No static scope blocker found, but original official tolerance feasibility is unmeasured and remains mandatory before further research. Legacy bitwise/FMA0 acceptance is deliberately not run or modified.

Standard new and checkpoint each ran once with exit0; prepare-source.py ran once with exit0. All three stderr files are empty. The original experiment.json remains planned with parent-source hashes; checkpoint alone writes the separate prepared record with current source hashes and verified=false. Creation bytes match their original saved hash. No baseline, best, AE or AF data was edited.
