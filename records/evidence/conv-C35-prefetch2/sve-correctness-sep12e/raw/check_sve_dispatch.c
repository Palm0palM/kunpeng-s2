/* Separate diagnostic instrumentation; never use its timings as performance. */
#define main guard_main
#include "check_conv_guard.c"
#undef main
/* Diagnostic-only counter preserves the original read/locality hint.
 * The uninstrumented guard and assembly compile conv2d.c directly. */
static unsigned long prefetch_hints;
static void diagnostic_prefetch(const void *address) __attribute__((no_instrument_function));
static void diagnostic_prefetch(const void *address) {
    __atomic_fetch_add(&prefetch_hints, 1, __ATOMIC_RELAXED);
    __builtin_prefetch(address, 0, 3);
}
#define __builtin_prefetch(address, rw, locality) diagnostic_prefetch((address))
#include "conv2d.c"
#undef __builtin_prefetch
static unsigned long prefix_entries, tail_entries, rowpair_entries;
#if CHECK_ROWTRIPLE
static unsigned long rowtriple_entries;
#endif
#if CHECK_ROWQUAD
static unsigned long rowquad_entries;
#endif
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)conv_sve_rowpair) __atomic_fetch_add(&rowpair_entries, 1, __ATOMIC_RELAXED);
#if CHECK_ROWTRIPLE
    if (fn == (void *)conv_sve_rowtriple) __atomic_fetch_add(&rowtriple_entries, 1, __ATOMIC_RELAXED);
#endif
#if CHECK_ROWQUAD
    if (fn == (void *)conv_sve_rowquad) __atomic_fetch_add(&rowquad_entries, 1, __ATOMIC_RELAXED);
#endif
    if (fn == (void *)conv_sve_prefix) __atomic_fetch_add(&prefix_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_tail) __atomic_fetch_add(&tail_entries, 1, __ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn, void *caller) { (void)fn; (void)caller; }
static int check_prefetch_branch(void) {
    const int block = 4 * (int)runtime_lanes();
    int cases = 0;
    unsigned long total = 0;
    for (int kh = 5; kh <= 7; ++kh)
    for (int delta = -1; delta <= 1; ++delta)
    for (int height = 4; height <= 16; height += 12) {
        const int width = block + delta;
        const unsigned long expected = 4UL * (unsigned long)(width / block) *
            (unsigned long)(height / 4) * (unsigned long)(kh - 5);
        __atomic_store_n(&prefetch_hints, 0, __ATOMIC_RELAXED);
        if (!one_case(width, kh, 3, height, 0, 1)) return 0;
        const unsigned long actual = __atomic_load_n(&prefetch_hints, __ATOMIC_RELAXED);
        printf("PREFETCH_CASE kh=%d ow=%d oh=%d hints=%lu expected=%lu\n", kh, width, height, actual, expected);
        if (actual != expected) return 0;
        ++cases;
        total += actual;
    }
    printf("PREFETCH_PROBE_PASS cases=%d total_hints=%lu\n", cases, total);
    return cases == 18 && total == 120;
}
int main(int argc, char **argv) {
    const int rc = guard_main(argc, argv);
    if (rc) return rc;
    if (!check_prefetch_branch()) return 5;
    const unsigned long prefix = __atomic_load_n(&prefix_entries, __ATOMIC_RELAXED);
    const unsigned long tail = __atomic_load_n(&tail_entries, __ATOMIC_RELAXED);
    const unsigned long pair = __atomic_load_n(&rowpair_entries, __ATOMIC_RELAXED);
    printf("SVE_PREFIX_ACTUAL_ENTRIES=%lu SVE_TAIL_ACTUAL_ENTRIES=%lu\n", prefix, tail);
    printf("SVE_ROWPAIR_ACTUAL_ENTRIES=%lu\n", pair);
#if CHECK_ROWTRIPLE
    const unsigned long triple = __atomic_load_n(&rowtriple_entries, __ATOMIC_RELAXED);
    printf("SVE_ROWTRIPLE_ACTUAL_ENTRIES=%lu\n", triple);
    const int triple_ok = triple != 0;
#else
    printf("SVE_ROWTRIPLE_ACTUAL_ENTRIES=NOT_APPLICABLE\n");
    const int triple_ok = 1;
#endif
#if CHECK_ROWQUAD
    const unsigned long quad = __atomic_load_n(&rowquad_entries, __ATOMIC_RELAXED);
    printf("SVE_ROWQUAD_ACTUAL_ENTRIES=%lu\n", quad);
    const int quad_ok = quad != 0;
#else
    printf("SVE_ROWQUAD_ACTUAL_ENTRIES=NOT_APPLICABLE\n");
    const int quad_ok = 1;
#endif
    return rc ? rc : (pair && triple_ok && quad_ok ? 0 : 4);
}
