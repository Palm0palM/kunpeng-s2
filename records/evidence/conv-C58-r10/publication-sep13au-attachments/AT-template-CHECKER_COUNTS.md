# AR checker dimensions and expected entries: static derivation only

C62 jointly changes seven-row width from 3VL to 2VL and shared kernel-column unroll from two to four. These new diagnostics have not been compiled or run. The unmodified bitwise scalar reference, memcmp, read-only input/kernel, guard pages, canaries, poisoned output, worker VL/thread checks and numerical acceptance stay in place.

The six width choices are now 2L-1, 2L, 2L+1, 4L-1, 4L, 4L+1 for each L=4/8/16. All six are distinct and positive. They exercise zero/one/two full 2L tiles, exact tiles and width remainders. small widths are 1/2L-1/2L+1, larger-kernel width is 2L+1, direct-helper widths are 2L-1/2L/2L+1. Every checker width tied to the candidate tile was adapted, not only BLOCK_OUTPUTS.

Per configuration, full core=6 widths*3 kh(6..8)*3 kw(1..3)*18 heights*2 pads*2 guard orientations=3888. narrow=3*3*4*2*2=144. small=3 widths*5 kh(1..5)*3 kw*4 heights*2*2=720. larger=4 kernel pairs*2 heights*2*2=32. quad boundary=6 widths*2 kh(7..8)*5 kw(4..8)*4 heights(7,8,14,28)*2*2=960. Total=5744. kw4..8 covers one quad plus zero/one/two/three residual columns and two full quads. The last group has exact and partial width tiles and t transitions; larger kernels retain kh/kw81.

Dispatch cases have no pad/orientation repetition: core=6*3*3*18=972; quad=6*2*5*4=240; total1212. Production dispatch into rowseven depends on kh>=7 and oh>=7, not output width. Sum floor(h/7) over h=1..15,21,22,28 is21. Therefore core rowseven entries=6 widths*2 kh*3 kw*21=756. Quad heights sum1+1+2+4=8; quad entries=6*2*5*8=480. Total1236. Each case still checks its own expected delta, and the aggregate1236 is not substituted from observed output. Widths below2L still enter rowseven and then take width fallback.

Direct kh<7 cases=3 widths*6 kh(1..6)*3 kw*2 heights(7,28)*2 pads*2 orientations=432. Every call explicitly enters rowseven regardless of tile width. Expected entry sum=3*6*3*(1+4)*2*2=1080. Both dispatch and direct sets include oh28 with four independent static groups, requiring worker mask1 at one thread and15 at four threads. This remains a runtime check.

Six VL/thread configurations yield (5744+1212+432)*6=44328. Wrapper retains19 ordered stages and strict GCC10.3.1/generic/FP-contract-off, resources38CPU/24576MiB/one packed NUMA/1800s.

Legacy PREFIX/TAIL/ROWPAIR/ROWTRIPLE/ROWQUAD counts can change because widths now cross the unchanged 4L fallback tiles. AR keeps the exercised checker requirement that each is nonzero; exact per-case rowseven deltas and1236/1080 remain mandatory. Do not copy AP summary expectations10850/10850/234/2746/1778 into a future AR summarizer. Report original observed legacy counts separately, with nonzero coverage; never set expected counts from actual output. No AR job, runtime count or acceptance exists at preparation time.
