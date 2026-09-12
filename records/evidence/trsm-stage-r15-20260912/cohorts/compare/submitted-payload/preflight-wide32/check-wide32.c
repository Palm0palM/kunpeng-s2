#include <errno.h>
#include <limits.h>
#include <math.h>
#include <omp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/auxv.h>
#include <sys/prctl.h>
#include <linux/prctl.h>

#ifndef TRSM_SOURCE
#error Pass the absolute candidate trsm.c path as TRSM_SOURCE.
#endif
#ifndef TRSM_TEST_EXPECTED_CT
#error Pass the required CT as TRSM_TEST_EXPECTED_CT.
#endif
#if TRSM_TEST_EXPECTED_CT != 32 && TRSM_TEST_EXPECTED_CT != 64 && TRSM_TEST_EXPECTED_CT != 128
#error Expected CT must be 32, 64, or 128.
#endif
#if defined(TEST_NO_SVE) && defined(TEST_SHARED_ALLOC_FAIL)
#error Select only one fallback injection per build.
#endif

static unsigned long aligned_alloc_calls, injected_alloc_failures, shared_shape_ok;
static size_t expected_shared_alloc_bytes;
#if defined(TEST_SHARED_ALLOC_FAIL)
static int trsm_test_shared_alloc_fail(void **p, size_t alignment, size_t bytes) {
    unsigned long call = __atomic_add_fetch(&aligned_alloc_calls, 1, __ATOMIC_RELAXED);
    if (call == 1) {
        __atomic_store_n(&shared_shape_ok,
            alignment == 64 && bytes == expected_shared_alloc_bytes
            && expected_shared_alloc_bytes > 0 && omp_get_level() == 0,
            __ATOMIC_RELAXED);
        __atomic_fetch_add(&injected_alloc_failures, 1, __ATOMIC_RELAXED);
        return ENOMEM;
    }
    return posix_memalign(p, alignment, bytes);
}
#define posix_memalign trsm_test_shared_alloc_fail
#endif
#if defined(TEST_NO_SVE)
static unsigned long trsm_test_no_sve(unsigned long key) { (void)key; return 0; }
#define getauxval trsm_test_no_sve
#endif
/* The runner inserts one call in a test-only copy of the kernel body.
 * Function-entry instrumentation remains an independent call counter. */
static unsigned long argument_entries, bad_argument_entries;
static int expected_ldx, expected_panel_stride;
static void trsm_test_wide_arguments(int ldx, int panel_stride)
    __attribute__((no_instrument_function));
static void trsm_test_wide_arguments(int ldx, int panel_stride) {
    __atomic_fetch_add(&argument_entries, 1, __ATOMIC_RELAXED);
    if (ldx != expected_ldx || panel_stride != expected_panel_stride)
        __atomic_fetch_add(&bad_argument_entries, 1, __ATOMIC_RELAXED);
}
#include TRSM_SOURCE
_Static_assert(CT == TRSM_TEST_EXPECTED_CT && KB == 256,
               "Candidate CT/KB differs from the required test configuration");
#if defined(TEST_SHARED_ALLOC_FAIL)
#undef posix_memalign
#endif
#if defined(TEST_NO_SVE)
#undef getauxval
#endif
#if !TRSM_CAN_DISPATCH_SVE
#error This supplementary test requires the Linux aarch64 GCC SVE dispatch build.
#endif

/* Instrument the actual function entrance without editing the candidate. */
static unsigned long wide_entries;
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)update4x32_sve)
        __atomic_fetch_add(&wide_entries, 1, __ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn, void *caller) { (void)fn; (void)caller; }

enum { GUARD = 16, DIRECT_KB = 256 };
static const double sentinel = 37.125;
static int can_enter, workers, checked;

static void reset_counters(void) {
    __atomic_store_n(&wide_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&aligned_alloc_calls, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&injected_alloc_failures, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&shared_shape_ok, 0, __ATOMIC_RELAXED);
    expected_shared_alloc_bytes = 0;
    __atomic_store_n(&argument_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&bad_argument_entries, 0, __ATOMIC_RELAXED);
    expected_ldx = expected_panel_stride = 0;
}

static void fill_sentinel(double *p, size_t count) {
    for (size_t i = 0; i < count; ++i) p[i] = sentinel;
}

static int micro_check(void) {
    const int counts[] = {0, 1, 2, 7, 31, 255, 256};
    const int pads[] = {3, 11};
    int checked_micro = 0;
    for (size_t ci = 0; ci < sizeof(counts) / sizeof(counts[0]); ++ci)
    for (size_t pi = 0; pi < sizeof(pads) / sizeof(pads[0]); ++pi)
    for (int packed = 0; packed <= 1; ++packed) {
        int count = counts[ci], lda = count + pads[pi];
        int ldc = 39 + (int)pi * 4, ldx = packed ? 8 : 47 + (int)pi * 2;
        size_t nl = (size_t)4 * lda + 2 * GUARD;
        size_t nx = (packed ? 4u * DIRECT_KB * 8 : (size_t)DIRECT_KB * ldx) + 2 * GUARD;
        size_t nc = (size_t)4 * ldc + 2 * GUARD;
        double *ls = malloc(nl * sizeof(double)), *lsaved = malloc(nl * sizeof(double));
        double *xs = malloc(nx * sizeof(double)), *xsaved = malloc(nx * sizeof(double));
        double *cs = malloc(nc * sizeof(double)), *want = malloc(nc * sizeof(double));
        if (!ls || !lsaved || !xs || !xsaved || !cs || !want) {
            puts("FAIL micro fixture allocation");
            free(ls); free(lsaved); free(xs); free(xsaved); free(cs); free(want);
            return 1;
        }
        fill_sentinel(ls, nl); fill_sentinel(xs, nx); fill_sentinel(cs, nc);
        double *l = ls + GUARD, *x0 = xs + GUARD, *c = cs + GUARD;
        int panel_stride = packed ? DIRECT_KB * 8 : 8;
        for (int r = 0; r < 4; ++r) for (int k = 0; k < count; ++k)
            l[(size_t)r * lda + k] = (2 * ((r * 7 + k * 11) % 29) - 27) / 101.0;
        for (int k = 0; k < count; ++k) for (int j = 0; j < 32; ++j)
            x0[(size_t)(j / 8) * panel_stride + (size_t)k * ldx + j % 8]
                = (2 * ((k * 13 + j * 17) % 97) - 95) / 103.0;
        for (int r = 0; r < 4; ++r) for (int j = 0; j < 32; ++j)
            c[(size_t)r * ldc + j] = (2 * ((r * 31 + j * 7) % 59) - 57) / 83.0;
        memcpy(lsaved, ls, nl * sizeof(double));
        memcpy(xsaved, xs, nx * sizeof(double));
        memcpy(want, cs, nc * sizeof(double));
        /* Independent saved inputs, one scalar increasing-k fma chain per lane.
         * C and all padding/guards remain in this full-buffer bitwise reference. */
        for (int r = 0; r < 4; ++r) for (int j = 0; j < 32; ++j) {
            double sum = 0;
            size_t panel_origin = GUARD + (size_t)(j / 8) * panel_stride;
            for (int k = 0; k < count; ++k)
                sum = fma(lsaved[GUARD + (size_t)r * lda + k],
                          xsaved[panel_origin + (size_t)k * ldx + j % 8], sum);
            want[GUARD + (size_t)r * ldc + j] -= sum;
        }
        reset_counters();
        expected_ldx = ldx; expected_panel_stride = panel_stride;
        update4x32_sve(count, l, lda, x0, ldx, panel_stride, c, ldc);
        unsigned long calls = __atomic_load_n(&wide_entries, __ATOMIC_RELAXED);
        unsigned long arguments = __atomic_load_n(&argument_entries, __ATOMIC_RELAXED);
        unsigned long bad_arguments = __atomic_load_n(&bad_argument_entries, __ATOMIC_RELAXED);
        int bad = calls != 1 || arguments != calls || bad_arguments
            || memcmp(cs, want, nc * sizeof(double))
            || memcmp(ls, lsaved, nl * sizeof(double)) || memcmp(xs, xsaved, nx * sizeof(double));
        if (bad)
            printf("FAIL micro count=%d lda=%d layout=%s calls=%lu ordered_FMA_or_guard_mismatch=1\n",
                   count, lda, packed ? "packed" : "strided", calls);
        free(ls); free(lsaved); free(xs); free(xsaved); free(cs); free(want);
        if (bad) return 1;
        ++checked_micro;
        printf("ARGUMENTS_PASS calls=%lu bad=0 expected_ldx=%d expected_panel_stride=%d\n",
               arguments, expected_ldx, expected_panel_stride);
        printf("MICRO_PASS count=%d lda=%d layout=%s calls=%lu\n",
               count, lda, packed ? "packed" : "strided", calls);
    }
    printf("PASS micro_cases=%d ordered_FMA_bitwise=1 L_X_guards_unchanged=1\n", checked_micro);
    return checked_micro != 28;
}

/* Structured dense fixtures supplement the unchanged general boundary suite.
 * Exact dyadic alpha/beta permit an independent O(m*n) long-double prefix
 * construction and residual, instead of repeating O(m*m*n) fixture work. */
static double fixture_alpha(int r) { return (r % 17 + 1) / 1048576.0; }
static double fixture_beta(int k) { return (k % 13 + 1) / 16.0; }

static unsigned long expected_entries(int m, int n) {
    unsigned long total = 0;
    if (!can_enter) return 0;
    /* Count complete output 4-row groups below each solved 256-row block.
     * Since CT=32/64/128 is divisible by 4 and 32, tile boundaries do not discard
     * any complete 4-row or 32-column group. This does not replay call loops. */
    for (int end = DIRECT_KB; end < m; end += DIRECT_KB)
        total += (unsigned long)((m - end) / 4) * (unsigned long)(n / 32);
    return total;
}

static int case_check(int m, int n) {
    int lda = m + 3, ldb = n + 7;
    size_t nl = (size_t)m * lda + 2 * GUARD, nb = (size_t)m * ldb + 2 * GUARD;
    double *ls = malloc(nl * sizeof(double)), *lsaved = malloc(nl * sizeof(double));
    double *bs = malloc(nb * sizeof(double)), *known = malloc(nb * sizeof(double));
    double *rhs = malloc((size_t)m * n * sizeof(double));
    long double *prefix = calloc((size_t)n, sizeof(long double));
    if (!ls || !lsaved || !bs || !known || !rhs || !prefix) {
        puts("FAIL whole fixture allocation");
        free(ls); free(lsaved); free(bs); free(known); free(rhs); free(prefix);
        return 1;
    }
    fill_sentinel(ls, nl); fill_sentinel(bs, nb); fill_sentinel(known, nb);
    double *l = ls + GUARD, *b = bs + GUARD, *x = known + GUARD;
    for (int r = 0; r < m; ++r) {
        for (int k = 0; k < r; ++k)
            l[(size_t)r * lda + k] = fixture_alpha(r) * fixture_beta(k);
        l[(size_t)r * lda + r] = 2.031 + (r % 11) / 127.0;
        for (int j = 0; j < n; ++j) {
            x[(size_t)r * ldb + j] = ((r * 13 + j * 17) % 101 - 50) / 103.0;
            long double value = (long double)l[(size_t)r * lda + r] * x[(size_t)r * ldb + j]
                + (long double)fixture_alpha(r) * prefix[j];
            rhs[(size_t)r * n + j] = b[(size_t)r * ldb + j] = (double)value;
            prefix[j] += (long double)fixture_beta(r) * x[(size_t)r * ldb + j];
        }
    }
    memcpy(lsaved, ls, nl * sizeof(double));
    reset_counters();
    expected_shared_alloc_bytes = ((size_t)n + 7) / 8 * DIRECT_KB * 8 * sizeof(double);
#if defined(TEST_SHARED_ALLOC_FAIL)
    expected_ldx = ldb; expected_panel_stride = 8;
#else
    expected_ldx = 8; expected_panel_stride = DIRECT_KB * 8;
#endif
    l_trsm(m, n, l, lda, b, ldb);
    unsigned long calls = __atomic_load_n(&wide_entries, __ATOMIC_RELAXED);
    unsigned long expected = expected_entries(m, n);
    unsigned long arguments = __atomic_load_n(&argument_entries, __ATOMIC_RELAXED);
    unsigned long bad_arguments = __atomic_load_n(&bad_argument_entries, __ATOMIC_RELAXED);
    int bad = calls != expected || arguments != calls || bad_arguments, shared_fail = 0;
    if (arguments != calls || bad_arguments)
        printf("FAIL kernel-arguments calls=%lu observations=%lu bad=%lu\n", calls, arguments, bad_arguments);
    if (bad) printf("FAIL entry-count m=%d n=%d calls=%lu expected=%lu\n", m, n, calls, expected);
#if defined(TEST_SHARED_ALLOC_FAIL)
    shared_fail = 1;
    unsigned long allocations = __atomic_load_n(&aligned_alloc_calls, __ATOMIC_RELAXED);
    unsigned long failures = __atomic_load_n(&injected_alloc_failures, __ATOMIC_RELAXED);
    unsigned long shape = __atomic_load_n(&shared_shape_ok, __ATOMIC_RELAXED);
    if (allocations != 1 || failures != 1 || shape != 1 || !can_enter || !expected || calls != expected) {
        printf("FAIL shared-allocation calls=%lu injected=%lu shape=%lu wide_calls=%lu expected=%lu\n",
               allocations, failures, shape, calls, expected);
        bad = 1;
    }
#endif
    if (memcmp(ls, lsaved, nl * sizeof(double))) { puts("FAIL L or L guards modified"); bad = 1; }
    if (memcmp(bs, known, GUARD * sizeof(double))
            || memcmp(bs + GUARD + (size_t)m * ldb,
                      known + GUARD + (size_t)m * ldb, GUARD * sizeof(double))) {
        puts("FAIL B exterior guard modified"); bad = 1;
    }
    double max_error = 0, max_residual = 0;
    memset(prefix, 0, (size_t)n * sizeof(long double));
    for (int r = 0; r < m && !bad; ++r) {
        if (memcmp(b + (size_t)r * ldb + n, x + (size_t)r * ldb + n,
                   (size_t)(ldb - n) * sizeof(double))) {
            printf("FAIL B row padding m=%d n=%d r=%d\n", m, n, r); bad = 1; break;
        }
        for (int j = 0; j < n; ++j) {
            double got = b[(size_t)r * ldb + j];
            double error = fabs(got - x[(size_t)r * ldb + j]);
            long double product = (long double)lsaved[GUARD + (size_t)r * lda + r] * got
                + (long double)fixture_alpha(r) * prefix[j];
            long double residual = fabsl(product - (long double)rhs[(size_t)r * n + j]);
            if (!isfinite(got) || !isfinite(error) || !isfinite(residual)
                    || error > 1e-12 || residual > 1e-12L) {
                printf("FAIL whole m=%d n=%d r=%d j=%d error=%.17g residual=%.21Lg\n",
                       m, n, r, j, error, residual); bad = 1; break;
            }
            if (error > max_error) max_error = error;
            if (residual > max_residual) max_residual = (double)residual;
            prefix[j] += (long double)fixture_beta(r) * got;
        }
    }
    free(ls); free(lsaved); free(bs); free(known); free(rhs); free(prefix);
    if (bad) return 1;
    ++checked;
    printf("ARGUMENTS_PASS calls=%lu bad=0 expected_ldx=%d expected_panel_stride=%d\n",
           arguments, expected_ldx, expected_panel_stride);
    printf("CASE_PASS m=%d n=%d threads=%d calls=%lu expected=%lu max_error=%.17g max_residual=%.17g padding_L_unchanged=1 shared_fail=%d\n",
           m, n, workers, calls, expected, max_error, max_residual, shared_fail);
#if defined(TEST_SHARED_ALLOC_FAIL)
    printf("SHARED_ALLOC_PASS calls=%lu injected=%lu\n", allocations, failures);
#endif
    return 0;
}

int main(int argc, char **argv) {
    printf("TILE_CONFIG_PASS KB=%d CT=%d\n", KB, CT);
    const char *mode = "full";
    int narrow = 0;
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--narrow-vl")) narrow = 1;
        else if (!strcmp(argv[i], "micro") || !strcmp(argv[i], "full") || !strcmp(argv[i], "smoke"))
            mode = argv[i];
        else { puts("FAIL unknown argument"); return 1; }
    }
    if (!(getauxval(AT_HWCAP) & HWCAP_SVE)) {
        puts("PREFLIGHT_BLOCKED real HWCAP_SVE absent"); return 2;
    }
    if (omp_get_max_threads() < 1 || omp_get_max_threads() > 38) {
        puts("FAIL invalid thread count"); return 1;
    }
    if (narrow) {
#if defined(PR_SVE_SET_VL) && defined(PR_SVE_VL_LEN_MASK)
        int actual = prctl(PR_SVE_SET_VL, 16);
        if (actual < 0 || (actual & PR_SVE_VL_LEN_MASK) != 16) {
            perror("PREFLIGHT_BLOCKED PR_SVE_SET_VL 16"); return 2;
        }
        printf("NARROW_VL_PASS requested=16 actual=%d\n", actual & PR_SVE_VL_LEN_MASK);
#else
        puts("PREFLIGHT_BLOCKED PR_SVE_SET_VL unavailable"); return 2;
#endif
    }
    int min_vl = INT_MAX, max_vl = 0, widths_ok = 1;
#pragma omp parallel reduction(min:min_vl) reduction(max:max_vl) reduction(&:widths_ok) reduction(+:workers)
    {
        int vl = -1;
#if defined(PR_SVE_GET_VL) && defined(PR_SVE_VL_LEN_MASK)
        int status = prctl(PR_SVE_GET_VL);
        if (status >= 0) vl = status & PR_SVE_VL_LEN_MASK;
#endif
        if (vl < min_vl) min_vl = vl;
        if (vl > max_vl) max_vl = vl;
        widths_ok &= vl == (narrow ? 16 : 64);
        widths_ok &= trsm_sve_has_eight_doubles() == !narrow;
        workers += 1;
    }
    if (!widths_ok || workers != omp_get_max_threads()) {
        printf("PREFLIGHT_BLOCKED workers=%d expected_workers=%d min_vl=%d max_vl=%d\n",
               workers, omp_get_max_threads(), min_vl, max_vl); return 2;
    }
    int effective_hwcap_sve = 1;
#if defined(TEST_NO_SVE)
    effective_hwcap_sve = 0;
#endif
    can_enter = effective_hwcap_sve && !narrow;
    printf("DISPATCH workers=%d hwcap_sve=%d min_vl=%d max_vl=%d expected_wide=%d\n",
           workers, effective_hwcap_sve, min_vl, max_vl, can_enter);
#if defined(TEST_SHARED_ALLOC_FAIL)
    if (!can_enter || strcmp(mode, "smoke")) {
        puts("FAIL shared-allocation injection requires SVE8 smoke mode"); return 1;
    }
#endif
    if (!strcmp(mode, "micro")) {
        if (!can_enter || workers != 1) { puts("FAIL micro requires one SVE8 worker"); return 1; }
        return micro_check();
    }
    puts("FIXTURE dense_structured_lower=1 independent_long_double_prefix=1 supplement_only=1");
    if (!strcmp(mode, "full")) {
        const int dims[][2] = {{4100, 31}, {4100, 32}, {4100, 33},
                              {4105, 63}, {4105, 64}, {4105, 65},
                              {4111, 95}, {4111, 96}, {4111, 97},
                              {4111, 127}, {4111, 128}, {4111, 129}};
        for (size_t i = 0; i < sizeof(dims) / sizeof(dims[0]); ++i)
            if (case_check(dims[i][0], dims[i][1])) return 1;
    } else if (case_check(4111, 129)) return 1;
    printf("PASS whole_cases=%d padding_L_unchanged=1 actual_entry_counts=1\n", checked);
    return 0;
}
