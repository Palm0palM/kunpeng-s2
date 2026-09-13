# Independent source and package review: C42

Read-only source review and lightweight package copying only. No C compiler, assembly, diagnostic executable, sanitizer, benchmark, SSH, scheduler submission or reset was used.

## Candidate source review against C41

The source diff contains exactly five replacements, all inside `conv_sve_rowquint`'s shared `t=4..kh-1` stage. Each replacement is confined to one existing input-vector scope. Replacing those five assembly groups with the original five intrinsic multiply/add expressions per group restores the entire C41 source text exactly. The source files `README.md`, `bench_conv.c` and `run.sh` are also byte-identical to C41. The other eight quint stages, full-block condition, five input loads, stores, suffix, defensive fallback, public dispatch and non-SVE code are unchanged.

Each scope has five read/write early-clobber accumulators (`+&w`), one write-only early-clobber temporary (`=&w`), and six `w` inputs: the original input vector and five coefficient vectors. Read/write preserves the incoming accumulator value. Early clobbers prevent an output changed before the end of the multi-instruction fragment from sharing a register with a still-needed input; the temporary also cannot overwrite those inputs. No undeclared fixed register is used. Actual allocation and acceptance of SVE values with these constraints and `%Z` remain GCC10 target-build questions.

The ten template instructions alternate `fmul tmp, v, coefficient` and `fadd acc, acc, tmp` for output rows a,b,c,d,e. Every temporary is defined by a multiply before it is read. Operand order matches the original expressions, each output's old accumulator participates in its addition, and multiplication/addition remain separate. The same accumulator is used through increasing kernel rows and columns; no partial sum or reassociation is introduced. Five fragments specify 25 FMUL and 25 FADD per shared kernel-column iteration.

`%Z[operand].s` requests SVE register names with float32 lanes; the assembly has no predication, memory accesses, fixed registers, prefetch, FMA or NZCV-writing instruction. It is only reached inside the unchanged full `5*lanes` block, whose original predicate is all true. All active lanes therefore correspond to valid outputs. Tail and narrow-width processing retain the original predicated helpers. The memory clobber is a compiler memory barrier; it neither accesses memory nor constitutes a hardware fence.

The original load addresses are untouched. With `ow-i>=5*lanes`, the last load lane has column `i+ik+5*lanes-1 <= ow+kw-2 = inputWidth-1`; the last output store is at most `ow-1`. Input/kernel row expressions and five-row group ownership are unchanged. `kh<5` and output suffixes bypass these new fragments. No new integer arithmetic, pointer or thread schedule is introduced by the assembly replacement.

No source-level correctness obstruction was found. The nominal 25 accumulators + five coefficients + input + scratch exhausts 32 vector registers and is not proof of a feasible spill-free allocation. GCC may need spills, copies or different live ranges. Scratch reuse and memory barriers may also reduce instruction overlap. No performance inference follows.

## Diagnostic package identity and coverage

Only the new C42 package directory is written. Its `conv2d.c` copy is byte-identical to prepared C42, SHA256 `cbdadacaa24a28f2eff0b9d01810ccae69ddc127da22942f30b15a6713265def`. The four execution inputs `check_conv_guard.c`, `check_sve_dispatch.c`, `remote_job.sh` and `candidate.env` are byte-identical to the independently reviewed C41 package. The initial source manifest records these identities. No shared driver or other package is modified.

Consequently the matrix is unchanged: 3776 uninstrumented production cases + 504 public-dispatch cases + 288 direct defensive cases per configuration, 27408 total for 16/32/64 vector bytes × 1/4 threads. Expected quint entries remain 528 public and 720 direct, with exact per-case deltas and worker masks 1/15. Widths cover 4VL..5VL suffix behavior and 5VL/10VL transitions; kh4/5/6 crosses the assembly gate; kw1/2/3 covers small odd/even kernels; oh1..10/20 covers remainders and four workers. Direct kh1..4 checks the unchanged defensive helper branch. Original bitwise reference, read-only inputs/kernel, allocation guards, poisoned output and canaries are retained.

Production source is compiled without instrumentation for full correctness and assembly. Only the separate include-based diagnostic TU receives function instrumentation to count actual entries and permit direct static-helper calls. Existing allocation, GCC10.3.1, VL, thread, count, reference and exit checks remain in force. Function-entry coverage is not a claim that the final compiler emits the intended registers or has no spills.

Before runtime acceptance, the target compiler must accept the actual `%Z` template and all early-clobber constraints. Inspect the uninstrumented output for the ten-instruction fragments and actual operand bindings, all nine quint stages and transitions for spill traffic, and FMA absence throughout the candidate. Preserve compile failure instead of silently changing constraints. The other eight pure-C stages may still spill even if the middle improves.

All G-round candidates remain prepared until F-round performance finishes and root gives explicit execution GO. Fetching artifacts alone does not complete validation; no runtime correctness, assembly or speed result has been obtained here.
