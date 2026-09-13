/* Separate instrumentation build: dispatch evidence only, never performance. */
#define main guard_main
#include "check_conv_guard.c"
#undef main
#include "conv2d.c"
static unsigned long prefix_entries, tail_entries;
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)conv_sve_prefix) __atomic_fetch_add(&prefix_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_tail) __atomic_fetch_add(&tail_entries, 1, __ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn, void *caller) { (void)fn; (void)caller; }
int main(int argc, char **argv) {
    const int rc = guard_main(argc, argv);
    const unsigned long prefix = __atomic_load_n(&prefix_entries, __ATOMIC_RELAXED);
    const unsigned long tail = __atomic_load_n(&tail_entries, __ATOMIC_RELAXED);
    printf("SVE_PREFIX_ACTUAL_ENTRIES=%lu SVE_TAIL_ACTUAL_ENTRIES=%lu\n", prefix, tail);
    return rc ? rc : (prefix && tail ? 0 : 4);
}
