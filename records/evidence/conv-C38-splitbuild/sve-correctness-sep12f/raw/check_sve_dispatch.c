/* Separate diagnostic instrumentation; never use its timings as performance. */
#define main guard_main
#include "check_conv_guard.c"
#undef main
#include "conv2d.c"
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
int main(int argc, char **argv) {
    const int rc = guard_main(argc, argv);
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
