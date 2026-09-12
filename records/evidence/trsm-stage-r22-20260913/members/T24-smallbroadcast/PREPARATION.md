# T24 small coefficient broadcast

Prepared from current T19-control13/source, prior measurement job1582392. Single hypothesis: explicit LD1RD for the eight small-kernel historical row coefficients can replace scalar LDR plus MOV broadcast. Only solve8x16_panel_sve history body changes, keeping one k step, original16accumulator order, two X panel loads, final forward solve and entire large path. No T23 unroll.

Eight inline asm expressions read exactly the listed double memory operand and produce one SVE vector. Predicate is existing all-active pg. Output =w, predicate Upl, memory Q (single base); one load instruction, no flags, extra memory access, modified inputs or clobbers. No volatile or blanket memory barrier needed for a pure read with used output and explicit memory operand. Vector svmla replaces scalar-operand svmla_n while preserving the same elementwise FMA operands/order.

Primary references read before implementation: ACLE states there is no dedicated LD1RD intrinsic and svdup from memory may be optimized to it: https://arm-software.github.io/acle/main/acle.html#sve-ld1r-instructions . GCC constraints: https://gcc.gnu.org/onlinedocs/gcc/Machine-Constraints.html (w/Upl/Q). GCC12 extended asm memory operand semantics: https://gcc.gnu.org/onlinedocs/gcc-12.3.0/gcc/Extended-Asm.html . Actual GCC12 compile/assembly remains to be tested on allocated compute only.

Potential cost: Q addressing needs explicit base-register arithmetic, scheduling flexibility and register allocation may differ. No speed claim. Local source/document editing only, no compilation/tests, no hash operations.
