# C46 I diagnostic plan

Reuse the original C42 planned27408-case matrix with unchanged guard/reference and instrumentation source; use immutable C46 production source. The only algorithm change from C42 is its separately recorded150 operand-print modifier corrections. C42 failed and cannot supply dynamic evidence.

Six requested configurations are16/32/64 SVE bytes ×1/4 threads. Per configuration:3776 production full +504 public dispatch +288 forced direct defensive cases =4568. All six total27408. Expected quint entries per configuration:528 dispatch and720 direct; expected worker masks1/15. Width/height/kernel/allocation products are detailed in README and remain unchanged.

The wrapper preserves strict production compilation (`-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp` and diagnostic-only `EXPECTED_ACC=5`), Linux/AArch64,38 allocated CPUs within one NUMA, GCC10.3.1, close/cores binding and dynamic-off. It separates uninstrumented production from entry instrumentation and actual production `-S`. New I-only identity/command/stage logging is not operator execution or numerical evidence.

Submission remains root/checks work after explicit GO and one reconciled job ID. Compilation failure is terminal evidence for this candidate. Acceptance must validate all six actual full/public/direct logs, per-case entries, masks, all19 stage exits, scheduler/job/system/wrapper exits, source manifest, all nine stages/transitions/whole-helper spills and actual five-asm disjointness/order/FMA. No local compilation/tests, SSH, submission, public driver edit or reset card occurred during preparation.
