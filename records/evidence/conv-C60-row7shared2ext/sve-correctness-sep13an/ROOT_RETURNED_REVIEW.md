# AN root returned evidence review

Root read actual AN_SUMMARY.md and actual sharedpair assembly.L4076879-7006, remainder7010-7074 and prologue. AN1589554 actual44328 cases/19stages/GCC10.3.1/singleNUMA38CPU/job-system-wrapper0; acceptor will reread originals, no claimedperformanceyet.

Sharedpair is127instructions,4LD1W(3fullp0+1tailp1),14LD1RW,42FMUL42FADD,3EXT#4 with3MOVPRFX and0Zspill; parentC7pair123instructions/6LD1W/14LD1RW/42+42/0spill. Remainder63/3LD1W7LD1RW21+21/0spill unchanged shape. p1 is ptruep1.b,vl1, thus onlybit0 valid; for.s memory predicate onlyfirstfloat active. Source boundary proof ensures thatoneelement is withinrow, nofullvector tail load. Actual extraEXT/shuffle work could offset fewerloads.

Helper5705-8318 contains2432instructions includingret; frame704B+3VL (parent720B+3VL),9Zreads15Zwrites inwholehelper remain, notallspillgone. Whole.sfusedscan and stackbase mapping are independently checked inTARGETED_ASSEMBLY_REVIEW.md; root will read final beforeone-shotaccept. Noexhaustiveallblocknewaudit, no speedclaim or localoperator. Freshquota<40 before performanceGO, noreset.
