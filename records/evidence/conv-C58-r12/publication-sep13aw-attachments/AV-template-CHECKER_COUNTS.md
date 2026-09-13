# AV checker scope: unchanged executed AP bytes

Both checker source files come byte-for-byte from AP C61, not AR/AT. EXPECTED_ACC=3 and BLOCK_OUTPUTS=3L. Full and dispatch main widths remain3L-1,3L,3L+1,6L-1,6L,6L+1; small widths1/3L-1/3L+1, larger-kernel width3L+1, direct widths3L-1/3L/3L+1. VL16/32/64 bytes x1/4 threads gives six configurations. No new C64 result is inferred from checker reuse.

Per configuration full core=6 widths*3 kh*3 kw*18 heights*2 pads*2 orientations=3888; narrow=3*3*4*2*2=144; small=3*5*3*4*2*2=720; larger=4 kernel pairs*2 heights*2*2=32; kw4..8 extra coverage=6*2*5*4*2*2=960. Total5744. Dispatch core6*3*3*18=972 plus quad coverage6*2*5*4=240 gives1212. Direct3 widths*6 kh*3 kw*2 heights*2*2=432. Combined(5744+1212+432)*6=44328.

Per-case rowseven entry expectations remain independent of width. For core heights1..15,21,22,28, sum floor(h/7)=21. Thus dispatch entries=6 widths*2 kh*3 kw*21 +6 widths*2 kh*5 kw*(1+1+2+4)=756+480=1236. Direct entries=3 widths*6 kh*3 kw*(1+4)*2*2=1080. Each case checks its delta, plus aggregate totals and worker mask1 or15. The five legacy helpers must remain nonzero per original checker; runtime observation is recorded separately, never copied into an expected value.

All bitwise scalar memcmp, readonly input/kernel, guard pages, canaries, poisoned output, strict FP order and actual worker VL/thread checks are unchanged AP code. Wrapper retains19 ordered stages, GCC10.3.1/generic, no fast math and FP contraction disabled;38CPU/24576MiB/one packed NUMA/1800s. No local operator runs. This document states expected coverage, not C64 validation.
