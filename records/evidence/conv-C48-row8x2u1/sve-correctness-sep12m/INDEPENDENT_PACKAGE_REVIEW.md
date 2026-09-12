# M / C48 independent package review

Root read the actual frozen full/dispatch/direct guard loops and compared the wrapper with reviewed L. This is lightweight source inspection only; no compiler, operator, test executable, SSH or scheduler submission was run.

The actual full matrix has4320 core(6 widths*3kh*3kw*20heights*4placements),144 narrow,864 small and32 large cases, hence5360. The dispatcher matrix drops the placement factor and has1080 cases. Only kh8/9 activates roweight; summed floor(oh/8) over1..17/24/25/32 is22, giving6*2*3*22=792 entries. The direct adapter supplies exactly8 or32 valid output rows for kh1..7;3widths*7kh*3kw*2heights*4placements=504 cases and3*7*3*4*(1+4)=1260 entries. Totals are6944 per configuration,41664 across six real VL/thread configurations, all still planned.

The actual direct adapter uses size_t row/input/output strides and8 distinct output pointers, schedules disjoint groups and validates its own permitted shape. Switching the checked_conv pointer and resetting the worker mask occur after prior teams have joined. Every public/direct case checks its entry increment in addition to the aggregate counts; oh32 produces four whole groups for the four-worker mask. The old five helpers remain instrumented, while no nonexistent rowsix symbol is referenced.

Actual width/height sets cover2VL/4VL full-block edges, kh7/8/9, smallkh1..6, directkh1..7 and every remainder1..7, including17/25. The wrapper differs from L only in its candidate/count/shape assertions; it retains strict flags, resource validation,19 ordered stages, three actual GCC commands, separate uninstrumented production guard and instrumented dispatch builds. Scalar reference, readonly inputs, allocation-edge guards and output canary remain in use. No per-row guard, sanitizer, dynamic nonSVE or completed numerical check is claimed.

No definite static blocker was found in this inspected package. Actual compilation, real numerical logs,15-stage/transition/dispatch assembly and final scheduler/wrapper exits remain required. This does not authorize a new job or establish performance.
