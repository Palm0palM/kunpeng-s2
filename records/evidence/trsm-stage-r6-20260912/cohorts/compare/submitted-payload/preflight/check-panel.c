#include <errno.h>
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
#ifndef TEST_HAS_PANEL16
#define TEST_HAS_PANEL16 0
#endif
#ifndef TEST_HAS_PACKEDL16
#define TEST_HAS_PACKEDL16 0
#endif
#if TEST_HAS_PACKEDL16 && !TEST_HAS_PANEL16
#error The packed-history candidate must retain its original panel16 fallback.
#endif
#if defined(TEST_ALLOC_FAIL) && defined(TEST_SHARED_ALLOC_FAIL)
#error Select either all-allocation failure or first-shared-allocation failure.
#endif
static unsigned long aligned_alloc_calls, injected_alloc_failures, later_alloc_successes;
static size_t expected_shared_alloc_bytes;
static unsigned long first_shared_shape_ok;
#if defined(TEST_ALLOC_FAIL)
static int trsm_test_alloc_fail(void **p, size_t alignment, size_t bytes) {
    (void)p; (void)alignment; (void)bytes;
    return ENOMEM;
}
#define posix_memalign trsm_test_alloc_fail
#elif defined(TEST_SHARED_ALLOC_FAIL)
static int trsm_test_first_shared_alloc_fail(void **p, size_t alignment, size_t bytes) {
    unsigned long call = __atomic_add_fetch(&aligned_alloc_calls, 1, __ATOMIC_RELAXED);
    if (call == 1) {
        __atomic_store_n(&first_shared_shape_ok,
                         alignment == 64 && bytes == expected_shared_alloc_bytes
                         && expected_shared_alloc_bytes > 0 && omp_get_level() == 0,
                         __ATOMIC_RELAXED);
        __atomic_fetch_add(&injected_alloc_failures, 1, __ATOMIC_RELAXED);
        return ENOMEM;
    }
    int code = posix_memalign(p, alignment, bytes);
    if (code == 0) __atomic_fetch_add(&later_alloc_successes, 1, __ATOMIC_RELAXED);
    return code;
}
#define posix_memalign trsm_test_first_shared_alloc_fail
#endif
#if defined(TEST_NO_SVE)
static unsigned long trsm_test_no_sve(unsigned long key) { (void)key; return 0; }
#define getauxval trsm_test_no_sve
#endif
#include TRSM_SOURCE
#if defined(TEST_ALLOC_FAIL) || defined(TEST_SHARED_ALLOC_FAIL)
#undef posix_memalign
#endif
#if defined(TEST_NO_SVE)
#undef getauxval
#endif
#if !TRSM_CAN_DISPATCH_SVE
#error This test requires the actual Linux aarch64 GCC SVE dispatch build.
#endif

static unsigned long panel_entries, packed_panel_entries;
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
#if TEST_HAS_PANEL16
    if (fn == (void *)solve16x8_panel_sve)
        __atomic_fetch_add(&panel_entries, 1, __ATOMIC_RELAXED);
#else
    (void)fn;
#endif
#if TEST_HAS_PACKEDL16
    if (fn == (void *)solve16x8_panel_packedL_sve) {
        __atomic_fetch_add(&panel_entries, 1, __ATOMIC_RELAXED);
        __atomic_fetch_add(&packed_panel_entries, 1, __ATOMIC_RELAXED);
    }
#endif
}
void __cyg_profile_func_exit(void *fn, void *caller) { (void)fn; (void)caller; }

static int checked, noop_checked;
static double worst;
static int can_enter, can_enter_packed;
static const double sentinel = 37.125;

static void reset_call_counters(void) {
    __atomic_store_n(&panel_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&packed_panel_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&aligned_alloc_calls, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&injected_alloc_failures, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&later_alloc_successes, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&first_shared_shape_ok, 0, __ATOMIC_RELAXED);
    expected_shared_alloc_bytes = 0;
}

static int case_check(int m, int n) {
    int lda = m + 3, ldb = n + 7;
    size_t nl = (size_t)m * lda, nb = (size_t)m * ldb;
    double *l = calloc(nl, sizeof(double)), *saved = malloc(nl * sizeof(double));
    double *b = malloc(nb * sizeof(double)), *x = malloc(nb * sizeof(double));
    if (!l || !saved || !b || !x) {
        puts("FAIL test fixture allocation");
        free(l); free(saved); free(b); free(x); return 1;
    }
    for (int i = 0; i < m; ++i) {
        double diag = 1.031;
        for (int k = 0; k < i; ++k) {
            double a = ((i * 19 + k * 31) % 97 - 48) / 997.0;
            l[(size_t)i * lda + k] = a; diag += fabs(a);
        }
        l[(size_t)i * lda + i] = diag;
    }
    memcpy(saved, l, nl * sizeof(double));
    for (size_t q = 0; q < nb; ++q) x[q] = b[q] = sentinel;
    for (int i = 0; i < m; ++i) for (int j = 0; j < n; ++j)
        x[(size_t)i * ldb + j] = ((i * 13 + j * 17) % 101 - 50) / 103.0;
    for (int i = 0; i < m; ++i) for (int j = 0; j < n; ++j) {
        long double acc = 0;
        for (int k = 0; k <= i; ++k)
            acc += (long double)l[(size_t)i * lda + k] * x[(size_t)k * ldb + j];
        b[(size_t)i * ldb + j] = (double)acc;
    }
    reset_call_counters();
#if defined(TEST_SHARED_ALLOC_FAIL)
    size_t full_blocks = (size_t)m / 16;
    expected_shared_alloc_bytes = 128u * full_blocks * (full_blocks - 1) * sizeof(double);
#endif
    l_trsm(m, n, l, lda, b, ldb);
    unsigned long actual = __atomic_load_n(&panel_entries, __ATOMIC_RELAXED);
    unsigned long packed_actual = __atomic_load_n(&packed_panel_entries, __ATOMIC_RELAXED);
    size_t triangular = (size_t)m * ((size_t)m + 1) / 2;
    unsigned long expected = can_enter && triangular <= (64u * 1024u * 1024u) / sizeof(double)
        ? (unsigned long)(m / 16) * (unsigned long)((n + 7) / 8) : 0;
    unsigned long packed_expected = can_enter_packed && expected && m >= 32
        ? (unsigned long)(m / 16 - 1) * (unsigned long)((n + 7) / 8) : 0;
    int bad = actual != expected || packed_actual != packed_expected;
    if (bad) printf("FAIL entry-count m=%d n=%d actual=%lu expected=%lu packed_actual=%lu packed_expected=%lu\n",
                    m, n, actual, expected, packed_actual, packed_expected);
#if defined(TEST_SHARED_ALLOC_FAIL)
    unsigned long calls = __atomic_load_n(&aligned_alloc_calls, __ATOMIC_RELAXED);
    unsigned long failures = __atomic_load_n(&injected_alloc_failures, __ATOMIC_RELAXED);
    unsigned long successes = __atomic_load_n(&later_alloc_successes, __ATOMIC_RELAXED);
    unsigned long shared_first = __atomic_load_n(&first_shared_shape_ok, __ATOMIC_RELAXED);
    if (!TEST_HAS_PACKEDL16 || m < 32 || !expected || failures != 1
            || shared_first != 1 || calls < 2 || successes != calls - 1
            || packed_actual != 0 || actual != expected) {
        printf("FAIL shared-allocation-fallback m=%d n=%d calls=%lu injected=%lu shared_first=%lu later_success=%lu old_entries=%lu expected=%lu packed_entries=%lu\n",
               m, n, calls, failures, shared_first, successes, actual - packed_actual, expected, packed_actual);
        bad = 1;
    }
#endif
    for (int i = 0; i < m && !bad; ++i) for (int j = 0; j < ldb; ++j) {
        double got = b[(size_t)i * ldb + j], want = x[(size_t)i * ldb + j];
        double error = fabs(got - want);
        if (!isfinite(error) || error > 1e-12 || (j >= n && got != sentinel)) {
            printf("FAIL whole m=%d n=%d i=%d j=%d error=%.17g\n", m, n, i, j, error);
            bad = 1; break;
        }
        if (error > worst) worst = error;
    }
    if (memcmp(l, saved, nl * sizeof(double))) { puts("FAIL L modified"); bad = 1; }
    free(l); free(saved); free(b); free(x);
    if (!bad) {
        ++checked;
        printf("CASE_PASS m=%d n=%d sve16_entries=%lu expected=%lu old_entries=%lu packed_entries=%lu packed_expected=%lu\n",
               m, n, actual, expected, actual - packed_actual, packed_actual, packed_expected);
#if defined(TEST_SHARED_ALLOC_FAIL)
        printf("SHARED_ALLOC_PASS m=%d n=%d calls=%lu injected=%lu shared_first=%lu later_X_success=%lu\n",
               m, n, calls, failures, shared_first, successes);
#endif
    }
    return bad;
}

static int noop_check(void) {
    const int dims[][2] = {{0, 9}, {-1, 9}, {17, 0}, {17, -1}};
    for (size_t i = 0; i < sizeof(dims) / sizeof(dims[0]); ++i) {
        double l = sentinel, b = sentinel;
        reset_call_counters();
        l_trsm(dims[i][0], dims[i][1], &l, 1, &b, 1);
        if (l != sentinel || b != sentinel) { puts("FAIL nonpositive no-op"); return 1; }
        if (__atomic_load_n(&panel_entries, __ATOMIC_RELAXED)
                || __atomic_load_n(&packed_panel_entries, __ATOMIC_RELAXED)
                || __atomic_load_n(&aligned_alloc_calls, __ATOMIC_RELAXED)
                || __atomic_load_n(&injected_alloc_failures, __ATOMIC_RELAXED)) {
            puts("FAIL nonpositive no-op entered kernel or allocator"); return 1;
        }
        ++noop_checked;
    }
    return 0;
}

static int micro_check(int packed_mode) {
#if TEST_HAS_PANEL16
#if !TEST_HAS_PACKEDL16
    if (packed_mode) { puts("FAIL packed micro requested without packed-history kernel"); return 1; }
#endif
    const int starts[] = {0, 1, 15, 16, 17, 255, 256};
    const int pads[] = {1, 7};
    int count = 0;
    for (size_t si = 0; si < sizeof(starts) / sizeof(starts[0]); ++si)
    for (size_t pi = 0; pi < sizeof(pads) / sizeof(pads[0]); ++pi) {
        int start = starts[si], m = start + 16, lda = m + pads[pi];
        size_t nl = (size_t)(m + 1) * lda, nx = (size_t)(m + 2) * RHS;
        size_t nh = (size_t)start * 16 + 32;
        double *l = malloc(nl * sizeof(double)), *saved = malloc(nl * sizeof(double));
        double *storage = malloc(nx * sizeof(double)), *want_storage = malloc(nx * sizeof(double));
        double *history_storage = malloc(nh * sizeof(double)), *history_saved = malloc(nh * sizeof(double));
        if (!l || !saved || !storage || !want_storage || !history_storage || !history_saved) {
            puts("FAIL micro fixture allocation");
            free(l); free(saved); free(storage); free(want_storage);
            free(history_storage); free(history_saved); return 1;
        }
        for (size_t q = 0; q < nl; ++q) l[q] = sentinel;
        for (int i = 0; i < m; ++i) {
            for (int k = 0; k < i; ++k) l[(size_t)i * lda + k] = ((i * 7 + k * 11) % 29 - 14) / 101.0;
            l[(size_t)i * lda + i] = 7.013 + i / 127.0;
        }
        memcpy(saved, l, nl * sizeof(double));
        for (size_t q = 0; q < nh; ++q) history_storage[q] = sentinel;
        double *history = history_storage + 16;
        for (int k = 0; k < start; ++k) for (int r = 0; r < 16; ++r)
            history[(size_t)k * 16 + r] = l[(size_t)(start + r) * lda + k];
        memcpy(history_saved, history_storage, nh * sizeof(double));
        for (size_t q = 0; q < nx; ++q) storage[q] = want_storage[q] = sentinel;
        double *x = storage + RHS, *want = want_storage + RHS;
        for (int i = 0; i < m; ++i) for (int j = 0; j < RHS; ++j)
            x[(size_t)i * RHS + j] = want[(size_t)i * RHS + j] = ((i * 13 + j * 17) % 47 - 23) / 71.0;
        for (int i = start; i < m; ++i) for (int j = 0; j < RHS; ++j) {
            double acc = 0;
            for (int k = 0; k < i; ++k)
                acc = fma(l[(size_t)i * lda + k], want[(size_t)k * RHS + j], acc);
            want[(size_t)i * RHS + j] = (want[(size_t)i * RHS + j] - acc) / l[(size_t)i * lda + i];
        }
        reset_call_counters();
#if TEST_HAS_PACKEDL16
        if (packed_mode)
            solve16x8_panel_packedL_sve(start, lda, l + (size_t)start * lda, x, history);
        else
#endif
            solve16x8_panel_sve(start, lda, l + (size_t)start * lda, x);
        int bad = memcmp(storage, want_storage, nx * sizeof(double)) || memcmp(l, saved, nl * sizeof(double))
            || memcmp(history_storage, history_saved, nh * sizeof(double))
            || __atomic_load_n(&panel_entries, __ATOMIC_RELAXED) != 1
            || __atomic_load_n(&packed_panel_entries, __ATOMIC_RELAXED) != (unsigned long)packed_mode;
        free(l); free(saved); free(storage); free(want_storage);
        free(history_storage); free(history_saved);
        if (bad) { printf("FAIL ordered-FMA micro packed=%d start=%d lda=%d\n", packed_mode, start, lda); return 1; }
        ++count;
    }
    printf("PASS %smicro_cases=%d ordered_FMA_bitwise=1 prefix_padding_L_unchanged=1 history_unchanged=1\n",
           packed_mode ? "packed_" : "", count);
    return 0;
#else
    (void)packed_mode;
    puts("FAIL direct micro requested for source without panel16 kernel");
    return 1;
#endif
}

int main(int argc, char **argv) {
    const char *mode = "full";
    int narrow = 0;
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--narrow-vl")) narrow = 1;
        else if (!strcmp(argv[i], "full") || !strcmp(argv[i], "smoke") || !strcmp(argv[i], "boundary")
                 || !strcmp(argv[i], "micro") || !strcmp(argv[i], "packed-micro")
                 || !strcmp(argv[i], "shared-fail")) mode = argv[i];
        else { puts("FAIL unknown argument"); return 1; }
    }
    if (!(getauxval(AT_HWCAP) & HWCAP_SVE)) { puts("PREFLIGHT_BLOCKED real HWCAP_SVE absent"); return 2; }
    if (omp_get_max_threads() > 38) { puts("FAIL thread limit exceeds 38"); return 1; }
    if (narrow) {
#if defined(PR_SVE_SET_VL) && defined(PR_SVE_VL_LEN_MASK)
        int actual = prctl(PR_SVE_SET_VL, 16);
        if (actual < 0 || (actual & PR_SVE_VL_LEN_MASK) != 16) {
            perror("PREFLIGHT_BLOCKED PR_SVE_SET_VL 16"); return 2;
        }
#else
        puts("PREFLIGHT_BLOCKED PR_SVE_SET_VL unavailable"); return 2;
#endif
    }
    int widths_ok = 1, workers = 0;
#pragma omp parallel reduction(&:widths_ok) reduction(+:workers)
    {
        widths_ok &= trsm_sve_has_eight_doubles() == !narrow;
        workers += 1;
    }
    if (!widths_ok) { puts("PREFLIGHT_BLOCKED per-worker vector length mismatch"); return 2; }
    if (workers != omp_get_max_threads()) { puts("FAIL actual worker count mismatch"); return 1; }
    can_enter = TEST_HAS_PANEL16 && !narrow;
#if defined(TEST_NO_SVE) || defined(TEST_ALLOC_FAIL)
    can_enter = 0;
#endif
    can_enter_packed = TEST_HAS_PACKEDL16 && can_enter;
#if defined(TEST_SHARED_ALLOC_FAIL)
    can_enter_packed = 0;
    if (strcmp(mode, "shared-fail") || !TEST_HAS_PACKEDL16 || !can_enter || narrow) {
        puts("FAIL first-shared-allocation target requires packed candidate, SVE8 and shared-fail small mode"); return 1;
    }
#else
    if (!strcmp(mode, "shared-fail")) { puts("FAIL shared-fail mode requires first-shared-allocation injection"); return 1; }
#endif
    printf("MODE=%s THREADS=%d NARROW_VL=%d EXPECT_SVE16=%d EXPECT_PACKEDL16=%d\n",
           mode, workers, narrow, can_enter, can_enter_packed);
    if (!strcmp(mode, "micro") || !strcmp(mode, "packed-micro")) {
        if (!can_enter) { puts("FAIL direct micro requires SVE8"); return 1; }
        return micro_check(!strcmp(mode, "packed-micro"));
    }
    if (!strcmp(mode, "full")) {
        const int ms[] = {1, 3, 4, 5, 15, 16, 17, 31, 32, 33, 63, 64, 65, 255, 256, 257};
        const int ns[] = {1, 7, 8, 9, 17};
        for (size_t i = 0; i < sizeof(ms) / sizeof(ms[0]); ++i)
        for (size_t j = 0; j < sizeof(ns) / sizeof(ns[0]); ++j)
            if (case_check(ms[i], ns[j])) return 1;
    } else if (!strcmp(mode, "shared-fail")) {
        const int ms[] = {32, 33, 63, 64, 65, 255, 256, 257};
        const int ns[] = {1, 7, 8, 9, 17};
        for (size_t i = 0; i < sizeof(ms) / sizeof(ms[0]); ++i)
        for (size_t j = 0; j < sizeof(ns) / sizeof(ns[0]); ++j)
            if (case_check(ms[i], ns[j])) return 1;
    } else if (!strcmp(mode, "smoke")) {
        const int dims[][2] = {{15, 9}, {16, 17}, {33, 313}, {257, 313}};
        for (size_t i = 0; i < sizeof(dims) / sizeof(dims[0]); ++i)
            if (case_check(dims[i][0], dims[i][1])) return 1;
    } else {
        if (case_check(4095, 9) || case_check(4097, 9)) return 1;
    }
    if (noop_check()) return 1;
    printf("PASS whole_cases=%d noop_cases=%d non_dyadic_long_double_RHS=1 padding_L_unchanged=1 max_error=%.17g\n", checked, noop_checked, worst);
    return 0;
}
