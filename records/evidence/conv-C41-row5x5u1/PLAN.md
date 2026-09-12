# C41-row5x5u1: pure-C five-row × five-vector control

Status: prepared only. No compilation, assembly, correctness run or performance measurement has been performed. This is a later reserve behind C37/C38/C39 and C40; do not auto-submit.

Parent and source parent: `C33-row5x4u1`, an already measured five-row × four-vector experiment, **not the formal best**. The candidate preserves that parent's five-row dispatch and changes only the horizontal width of `conv_sve_rowquint` from `4*VL` to `5*VL`. It is a pure-C same-shape control for a possible future assembly experiment; no assembly implementation is included or authorized by this preparation.

## Single change and hypothesis

The helper now has 25 accumulators (`a0..a4` through `e0..e4`). Each of its nine ordered input-row stages adds one input-vector scope at offset `4*lanes` and updates the active outputs' fifth accumulators. Five matching stores are added. The single-column `ik` loops, coefficient row mapping, first four vector scopes, `kh<5` fallback, horizontal suffix handling, helper interface and all other code remain unchanged. The other three submission files are unchanged.

Within the same five-row shape, a wider horizontal block may amortize coefficient broadcasts, loop control and stage setup over more outputs. This is unmeasured. In a full shared middle iteration, the source changes from 20 updates / 4 input loads / 5 broadcasts / 20 separate multiply-add pairs to 25 updates / 5 input loads / 5 broadcasts / 25 pairs. Input loads per update remain 1/5; coefficient broadcasts and loop backedges per update fall from 1/4 to 1/5 and from 1/20 to 1/25 respectively. These are source-level operation counts, not an instruction count or a speed prediction.

Register pressure is the main risk: 25 accumulators + five coefficients + one input + one product = 32 vector values, with zero nominal register headroom. This estimate is not a proven live-register allocation. GCC may retain/reorder input windows, reuse operands or need other temporaries; spills may occur. Source-level single-input scopes do not constrain the generated schedule. A wider suffix and code size can also offset any amortization. No inline assembly, barriers, prefetch, lane operation, FMA, fast-math or scheduling change is introduced.

## Pending validation

Root/checks owns all future execution on a scheduled compute node. First check strict bitwise correctness and allocation edges with runtime widths around `5*VL` and `10*VL`, including width 1 and the existing fallback boundaries; cover `kh=1..6` plus odd/even larger kernels, `kw=1/2/3` and larger odd/even widths, output heights around five-row groups and every remainder 1..4, and enough rows to reach all four diagnostic workers. Include supported VL128/256/512 and 1/4-thread settings, entry proof for the real quint helper, and its small-kernel defensive fallback. Keep production source separate from diagnostic instrumentation.

Read the uninstrumented shared-loop assembly before interpreting results: count arithmetic, loads, broadcasts, register spills and FMA instructions, distinguishing stack spills from ABI saves. A later same-allocation comparison should include a fresh unchanged C33 control to isolate width and a fresh formal-best control to assess usefulness, with identical compiler/flags/resources/affinity/official suites. Historical C33 timings must not be treated as a contemporaneous baseline. This candidate may serve as the same-shape pure-C control for future assembly only after its own behavior is measured. There is no performance result or promotion decision yet.

`STATIC_REVIEW.md` records the unchanged row mapping and new horizontal boundary. The workflow checkpoint records the authoritative prepared source hash.
