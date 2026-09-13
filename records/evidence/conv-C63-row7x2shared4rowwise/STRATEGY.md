# C63: 7 rows, 2VL, shared4 with rowwise weights

Standard parent is current C7/C58-r1. C62 is the design source, not a measured performance baseline for this candidate. Only C62 quad body changes: each ordered column loads v0/v1, then each row broadcasts one coefficient and updates its two accumulators. All other C62 bytes remain, including 14 accumulators, twelve boundary unroll2 hints, remainder and dispatch. Companion files match C7.

Hypothesis: shorter coefficient lifetime may help the jointly narrowed/shared4 tile after C62 emitted substantial scalable spills. GCC may reorder and retain spills; no spill reduction or speed claim. Each chain keeps ik0..3, separate mul then add, with unchanged addresses and predicates. Own scheduled-node numerical validation and real assembly are required before performance measurement.
