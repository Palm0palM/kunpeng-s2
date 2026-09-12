/* Diagnostic-only instrumentation. Production source is included unchanged.
 * These runs establish entries/branches and bitwise correctness, never speed. */
#define main guard_main
#include "check_conv_guard.c"
#undef main
#include "conv2d.c"

static unsigned long prefix_entries, tail_entries, rowpair_entries;
static unsigned long rowtriple_entries, rowquad_entries, roweight_entries;
static unsigned long roweight_worker_mask;

void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)conv_sve_roweight) {
        __atomic_fetch_add(&roweight_entries, 1, __ATOMIC_RELAXED);
        const int worker = omp_get_thread_num();
        if (worker >= 0 && worker < 4)
            __atomic_fetch_or(&roweight_worker_mask, 1ul << worker, __ATOMIC_RELAXED);
    }
    if (fn == (void *)conv_sve_rowquad) __atomic_fetch_add(&rowquad_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_rowtriple) __atomic_fetch_add(&rowtriple_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_rowpair) __atomic_fetch_add(&rowpair_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_prefix) __atomic_fetch_add(&prefix_entries, 1, __ATOMIC_RELAXED);
    if (fn == (void *)conv_sve_tail) __atomic_fetch_add(&tail_entries, 1, __ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn, void *caller) { (void)fn; (void)caller; }

/* Force the otherwise unreachable kh<8 defensive branch, using eight valid
 * output rows per call. Distinct groups own distinct output rows. */
static void direct_roweight(const float *input, int height, int width,
                          const float *kernel, int kh, int kw, float *output) {
    const int oh = height - kh + 1, ow = width - kw + 1;
    if ((oh != 8 && oh != 32) || kh < 1 || kh >= 8 || kw < 1) {
        fprintf(stderr, "Invalid direct-helper diagnostic shape\n");
        exit(7);
    }
    const size_t input_stride = (size_t)width, output_stride = (size_t)ow;
    const size_t groups = (size_t)oh / 8;
#pragma omp parallel for schedule(static)
    for (size_t group = 0; group < groups; ++group) {
        const size_t row = group * 8;
        const float *base = input + row * input_stride;
        float *dst = output + row * output_stride;
        conv_sve_roweight(base, input_stride, kernel, kh, kw,
                       dst, dst + output_stride, dst + 2 * output_stride,
                       dst + 3 * output_stride, dst + 4 * output_stride,
                       dst + 5 * output_stride, dst + 6 * output_stride,
                       dst + 7 * output_stride, ow);
    }
}

static int checked_entry_case(int ow, int kh, int kw, int oh, int pad,
                              int leading, unsigned long expected_entries) {
    const unsigned long before = __atomic_load_n(&roweight_entries, __ATOMIC_RELAXED);
    if (!one_case(ow, kh, kw, oh, pad, leading)) return 0;
    const unsigned long delta = __atomic_load_n(&roweight_entries, __ATOMIC_RELAXED) - before;
    if (delta != expected_entries) {
        fprintf(stderr, "ENTRY_FAIL ow=%d kh=%d kw=%d oh=%d actual=%lu expected=%lu\n",
                ow, kh, kw, oh, delta, expected_entries);
        return 0;
    }
    return 1;
}

int main(int argc, char **argv) {
    const int lanes = setup_config(argc, argv);
    const unsigned long expected_mask = (1ul << omp_get_max_threads()) - 1;
    const int widths[] = {2*lanes-1,2*lanes,2*lanes+1,4*lanes-1,4*lanes,4*lanes+1};
    const int heights[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,24,25,32};
    int dispatch_count = 0;
    checked_conv = conv2d;
    for (unsigned w=0; w<sizeof(widths)/sizeof(*widths); ++w)
    for (int kh=7; kh<=9; ++kh)
    for (int kw=1; kw<=3; ++kw)
    for (unsigned h=0; h<sizeof(heights)/sizeof(*heights); ++h) {
        const unsigned long expected = kh >= 8 && heights[h] >= 8 ? (unsigned long)heights[h] / 8 : 0;
        if (!checked_entry_case(widths[w],kh,kw,heights[h],1,0,expected)) return 1;
        ++dispatch_count;
    }
    const unsigned long dispatch_entries = __atomic_load_n(&roweight_entries, __ATOMIC_RELAXED);
    const unsigned long dispatch_mask = __atomic_load_n(&roweight_worker_mask, __ATOMIC_RELAXED);
    const unsigned long prefix = __atomic_load_n(&prefix_entries, __ATOMIC_RELAXED);
    const unsigned long tail = __atomic_load_n(&tail_entries, __ATOMIC_RELAXED);
    const unsigned long pair = __atomic_load_n(&rowpair_entries, __ATOMIC_RELAXED);
    const unsigned long triple = __atomic_load_n(&rowtriple_entries, __ATOMIC_RELAXED);
    const unsigned long quad = __atomic_load_n(&rowquad_entries, __ATOMIC_RELAXED);
    printf("SVE_PREFIX_ACTUAL_ENTRIES=%lu SVE_TAIL_ACTUAL_ENTRIES=%lu\n",prefix,tail);
    printf("SVE_ROWPAIR_ACTUAL_ENTRIES=%lu SVE_ROWTRIPLE_ACTUAL_ENTRIES=%lu SVE_ROWQUAD_ACTUAL_ENTRIES=%lu\n",pair,triple,quad);
    printf("DISPATCH_ROWEIGHT_ACTUAL_ENTRIES=%lu EXPECTED=792 WORKER_MASK=%lu EXPECTED_MASK=%lu\n",dispatch_entries,dispatch_mask,expected_mask);
    if (dispatch_count!=1080 || dispatch_entries!=792 || dispatch_mask!=expected_mask ||
        !prefix || !tail || !pair || !triple || !quad) return 4;
    printf("PASS: %d dispatch cases; exact per-case roweight entries and bitwise scalar reference\n",dispatch_count);

    /* Assignment and mask reset happen after every previous team has joined. */
    checked_conv = direct_roweight;
    __atomic_store_n(&roweight_worker_mask, 0, __ATOMIC_RELAXED);
    const int direct_widths[] = {2*lanes-1,2*lanes,2*lanes+1};
    const int direct_heights[] = {8,32};
    int direct_count = 0;
    for (unsigned w=0; w<sizeof(direct_widths)/sizeof(*direct_widths); ++w)
    for (int kh=1; kh<=7; ++kh)
    for (int kw=1; kw<=3; ++kw)
    for (unsigned h=0; h<sizeof(direct_heights)/sizeof(*direct_heights); ++h)
    for (int pad=0; pad<=1; ++pad)
    for (int leading=0; leading<=1; ++leading) {
        const unsigned long expected = (unsigned long)direct_heights[h] / 8;
        if (!checked_entry_case(direct_widths[w],kh,kw,direct_heights[h],pad,leading,expected)) return 1;
        ++direct_count;
    }
    const unsigned long direct_entries = __atomic_load_n(&roweight_entries, __ATOMIC_RELAXED) - dispatch_entries;
    const unsigned long direct_mask = __atomic_load_n(&roweight_worker_mask, __ATOMIC_RELAXED);
    printf("DIRECT_ROWEIGHT_ACTUAL_ENTRIES=%lu EXPECTED=1260 WORKER_MASK=%lu EXPECTED_MASK=%lu\n",direct_entries,direct_mask,expected_mask);
    if (direct_count!=504 || direct_entries!=1260 || direct_mask!=expected_mask) return 4;
    printf("PASS: %d direct fallback cases; kh1..7, readonly/guard/canary and bitwise scalar reference\n",direct_count);
    return 0;
}
