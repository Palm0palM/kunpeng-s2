# C26-row4loads

Source parent: C24-row4x4, itself derived from verified C5. Only the shared four-output interior paired-coefficient loop changes: x0/x1/x2 are loaded from p+0/1/2*VL+1 instead of ext of adjacent windows. Values and arithmetic order are identical. Original final shifted window, seven row phases, four-row dispatch, odd coefficient paths, fallback helpers, benchmark, runner and other source files remain unchanged.

Hypothesis: save three ext and three movprfx at the cost of three extra input loads. More input sharing may amortize the added bandwidth. No improvement claimed before measurement.

Load bound is unchanged: full4VL tile and ik+1<kw keep every lane <=inputWidth-1. C24's row bound j+kh+2<=inputHeight-1 and disjoint row groups remain valid. No local compilation or tests. Require scheduled remote guard/dispatch across1/4threads and128/256/512bit SVE, assembly/no-FMA review, then matched allocation performance and confirmation before any promotion.
