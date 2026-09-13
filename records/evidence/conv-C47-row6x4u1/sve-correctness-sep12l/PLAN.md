# C47 L single-package plan

Prepare independent verification for six rows × four scalable vectors. Preserve C47 source exactly; adapt the frozen C40 guard widths3L/6L→4L/8L, without copying its successful validation or code-generation results.

The code's core arrays have six widths and13 output heights (1..12,24), three kh values5..7, three kw values1..3, and four allocation modes:6×13×3×3×4=2808. Narrow144, small576 and larger32 give full3560. Public dispatch has6×3×3×8=432 cases; direct fallback3×5×3×2×4=360. Six VL/thread configurations give26112 total planned checks. Dispatch rowsix entries6×2×3×(6+2+4)=432 and direct entries3×5×3×4×(1+4)=900 are per-configuration expectations, not observed counts.

Width4L−1 checks whole horizontal fallback,4L exact one new block,4L+1 new block plus suffix;8L−1 is one new block plus4L−1 suffix,8L exact two blocks and8L+1 two blocks plus one output. Original quad/pair horizontal tail now receives0..4L−1. Narrow1 and small-kernel4L±1 also exercise legacy paths; directkh1..5 at4L±1/4L forces the unchanged defensive quad+pair branch. Output heights1..12 include all remainder1..5, and24 supplies four complete groups for four workers.

Three products: uninstrumented production guard+candidate; separately instrumented dispatch/direct translation unit; uninstrumented production assembly. Strict flags, GCC10.3.1, generic target,38 allocated CPUs/one NUMA, dynamic-off/close/cores and requestedVL16/32/64×threads1/4 remain fixed. The19-stage wrapper logs actual commands and exits; it does not change the production benchmark or runner.

Future root/checks acceptance must verify actual scheduler/job/system/wrapper success, source transport identities, six full/public/direct summaries, exact per-case entries/masks1/15, nonzero legacy helper entries, all19 stage exits, completion marker and actual eleven-stage/whole-helper stack/FMA review. This package is only prepared. No shared tools, compute, SSH, tests, submission, push or reset are authorized or performed here.
