# AR root returned evidence review

Root read original AR_SUMMARY.md, sharedquad beginning/end, full remainder and helper prologue. AR1590510 actual44328checks/19stage/strictGCC10.3.1/ACC2,38CPU24576MiBsingleNUMA/job-system-wrapper0. Legacy nonzero fallback coverage remains present with changed widths; actual values are recorded separately, not forced to AP values. No performance claim.

Actual quad .L4076751-6962 has211instructions,56FMUL56FADD,8LD1W28LD1RW,17LDR Z/17STR Z through stack-derived addresses. Remainder6984-7032 has48instructions14FMUL14FADD2LD1W7LD1RW and no vector stack instruction inside loop. Full helper2260instructions includingret; frame688B+17VL,98Zreads86Zwrites across static paths. C7frame720B+3VL; narrowing output tile changes work per iteration, so raw instruction counts cannot be interpreted as runtime speed.

C62 has not eliminated scalable spills. This is an observed compiler result, not grounds to claim numerical failure or measured regression. Same-environment first comparison will measure cost once; no improvement can be declared until actual dualgate and independentconfirmation. Root awaits final targeted review before one acceptance. No local operator execution, noreset.
