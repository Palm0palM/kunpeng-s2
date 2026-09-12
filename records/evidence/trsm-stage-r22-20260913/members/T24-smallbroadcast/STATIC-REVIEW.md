# T24 source review

Reviewed eight exact inline-load replacements and16vector FMA replacements in existing single-k history body. All text outside old history body is byte-identical T19; support files unchanged. Addresses remain L[row*lda+k] for row0..7 and k0..start-1. Memory operand has one double width; LD1RD broadcasts exactly that element. Output vector does not overlap input predicate/general-register class, and this single instruction has no early output before a separate later input use. No changed FMA chain, index bound, allocation, dispatch or final solve. No local task execution or hash operation.

Compiler/assembler acceptance, ABI register handling, scalar-vs-vector FMA exact behavior on target and runtime speed remain unverified pending full preflight and official comparison. Documentation justifies the constraints; it is not a substitute for actual target compilation.
