# C22-row2loads

Parent: fresh C4 control C19-r3 (same source as published C19-r2).

Hypothesis: C4 shared-row assembly spends three ext and three movprfx operations on adjacent coefficient windows. Replace only these three interior-loop windows with direct shifted vector loads. This trades three extra input loads for six permutation/copy instructions; whether the compute node benefits must be measured.

The first/last input-row loops, width tile, two-row schedule, tail/prefix, official benchmark and runner are unchanged. Every output receives the same float products in the same order, with no FMA or reassociation.

Safety: each shifted load spans p+n*VL+1 through p+(n+1)*VL, n=0,1,2. Since ik+1<kw and i+4*VL<=ow, every lane is inside the corresponding valid input row. It is the same mathematical window previously formed with ext. No extra full fifth vector is read. The existing fourth shifted window is unchanged.

Validation pending on allocated compute nodes: 1/4 threads, SVE 128/256/512 bits, read-only guarded input/kernel, output sentinels, independent strict scalar bitwise reference, helper-entry coverage, then matched 38-core/one-NUMA three-suite official measurements. No local compilation or tests.
