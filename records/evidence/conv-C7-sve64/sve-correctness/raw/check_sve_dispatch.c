#define main guard_main
#include "check_conv_guard.c"
#undef main
#include "conv2d.c"
static unsigned long sve_entries;
void __cyg_profile_func_enter(void *fn, void *caller)
    __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *fn, void *caller)
    __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)conv_sve_prefix)
        __atomic_fetch_add(&sve_entries, 1, __ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn, void *caller) {(void)fn; (void)caller;}
int main(void) {
    if (!(getauxval(AT_HWCAP) & HWCAP_SVE)) return 3;
    int rc = guard_main();
    unsigned long calls = __atomic_load_n(&sve_entries, __ATOMIC_RELAXED);
    printf("SVE_HELPER_ACTUAL_ENTRIES=%lu\n", calls);
    return rc ? rc : (calls ? 0 : 4);
}
