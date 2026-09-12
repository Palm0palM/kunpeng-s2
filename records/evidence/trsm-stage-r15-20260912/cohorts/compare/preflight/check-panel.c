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
#ifndef TEST_HAS_HISTORY_BUDGET
#define TEST_HAS_HISTORY_BUDGET 0
#endif
#if TEST_HAS_HISTORY_BUDGET && !TEST_HAS_PACKEDL16
#error A history budget requires a packed-history kernel.
#endif
#if TEST_HAS_PACKEDL16 && !TEST_HAS_PANEL16
#error The packed-history candidate must retain its original panel16 fallback.
#endif
#if (defined(TEST_ALLOC_FAIL) + defined(TEST_SHARED_ALLOC_FAIL) + defined(TEST_X_ALLOC_FAIL)) > 1
#error Select only one allocation failure injection.
#endif
static unsigned long aligned_alloc_calls, injected_alloc_failures, later_alloc_successes;
static size_t expected_shared_alloc_bytes;
static unsigned long first_shared_shape_ok;
static int allocation_small_path;
static size_t expected_x_bytes, expected_kb_bytes;
static unsigned long allocation_calls[3], allocation_successes[3], allocation_failures[3];
static size_t allocation_bytes[3];
static int allocation_levels[3];
static unsigned long allocation_shape_bad;
static unsigned long worker_x_calls[38];
/* Kind 0 is small-path shared history, 1 is worker X, 2 is large-path RHS.
 * The fixture sets the independently calculated algorithm path before l_trsm.
 * omp_get_level()==1 also holds for the serialized one-thread parallel region. */
static int trsm_test_observed_alloc(void **p, size_t alignment, size_t bytes)
    __attribute__((no_instrument_function));
static int trsm_test_observed_alloc(void **p, size_t alignment, size_t bytes) {
    unsigned long call = __atomic_add_fetch(&aligned_alloc_calls, 1, __ATOMIC_RELAXED);
    int level = omp_get_level();
    int kind = level == 0 ? (allocation_small_path ? 0 : 2) : 1;
    size_t wanted = kind == 0 ? expected_shared_alloc_bytes
        : kind == 1 ? expected_x_bytes : expected_kb_bytes;
    int shape = alignment == 64 && bytes == wanted && wanted > 0
        && (kind == 1 ? allocation_small_path && level == 1 : level == 0);
    __atomic_fetch_add(&allocation_calls[kind], 1, __ATOMIC_RELAXED);
    __atomic_store_n(&allocation_levels[kind], level, __ATOMIC_RELAXED);
    __atomic_fetch_add(&allocation_bytes[kind], bytes, __ATOMIC_RELAXED);
    if (!shape) __atomic_fetch_add(&allocation_shape_bad, 1, __ATOMIC_RELAXED);
    if (kind == 1) {
        int worker = omp_get_thread_num();
        if (worker < 0 || worker >= 38)
            __atomic_fetch_add(&allocation_shape_bad, 1, __ATOMIC_RELAXED);
        else __atomic_fetch_add(&worker_x_calls[worker], 1, __ATOMIC_RELAXED);
    }
    if (kind == 0 && call == 1) __atomic_store_n(&first_shared_shape_ok, shape, __ATOMIC_RELAXED);
    int inject = 0;
#if defined(TEST_ALLOC_FAIL)
    inject = 1;
#elif defined(TEST_SHARED_ALLOC_FAIL)
    inject = kind == 0;
#elif defined(TEST_X_ALLOC_FAIL)
    inject = kind == 1;
#endif
    int code;
    if (inject) {
        __atomic_fetch_add(&injected_alloc_failures, 1, __ATOMIC_RELAXED);
        code = ENOMEM;
    } else {
        code = posix_memalign(p, alignment, bytes);
    }
    __atomic_fetch_add(code == 0 ? &allocation_successes[kind] : &allocation_failures[kind], 1, __ATOMIC_RELAXED);
    if (code == 0 && call > 1) __atomic_fetch_add(&later_alloc_successes, 1, __ATOMIC_RELAXED);
    return code;
}
#define posix_memalign trsm_test_observed_alloc
#if defined(TEST_NO_SVE)
static unsigned long trsm_test_no_sve(unsigned long key) { (void)key; return 0; }
#define getauxval trsm_test_no_sve
#endif
#include TRSM_SOURCE
#undef posix_memalign
#if TEST_HAS_HISTORY_BUDGET
_Static_assert(TRSM_PACKED_HISTORY_BUDGET_BYTES == 4 * 1024 * 1024,
               "The source history budget must be exactly 4 MiB");
#endif
_Static_assert(sizeof(double) == 8, "The history byte audit requires 8-byte double");
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
static int effective_sve = 1;
static int budget_mode;
static int allocation_checked, budget_checked, shared_injection_cases;
static const double sentinel = 37.125;

static void reset_call_counters(void) {
    __atomic_store_n(&panel_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&packed_panel_entries, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&aligned_alloc_calls, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&injected_alloc_failures, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&later_alloc_successes, 0, __ATOMIC_RELAXED);
    __atomic_store_n(&first_shared_shape_ok, 0, __ATOMIC_RELAXED);
    expected_shared_alloc_bytes = 0;
    expected_x_bytes = expected_kb_bytes = 0;
    allocation_small_path = 0;
    __atomic_store_n(&allocation_shape_bad, 0, __ATOMIC_RELAXED);
    for (int kind = 0; kind < 3; ++kind) {
        __atomic_store_n(&allocation_calls[kind], 0, __ATOMIC_RELAXED);
        __atomic_store_n(&allocation_successes[kind], 0, __ATOMIC_RELAXED);
        __atomic_store_n(&allocation_failures[kind], 0, __ATOMIC_RELAXED);
        __atomic_store_n(&allocation_bytes[kind], 0, __ATOMIC_RELAXED);
        __atomic_store_n(&allocation_levels[kind], -1, __ATOMIC_RELAXED);
    }
    for (int worker = 0; worker < 38; ++worker)
        __atomic_store_n(&worker_x_calls[worker], 0, __ATOMIC_RELAXED);
}

static size_t history_bytes(int m) {
    size_t blocks = (size_t)m / 16;
    return blocks < 2 ? 0 : 128u * blocks * (blocks - 1) * sizeof(double);
}

static int history_fits(int m) {
#if TEST_HAS_HISTORY_BUDGET
    return history_bytes(m) <= 4u * 1024u * 1024u;
#else
    (void)m;
    return 1;
#endif
}

static int allocation_check(int m, int n, int history_expected) {
    unsigned long wanted[3] = {(unsigned long)history_expected,
        allocation_small_path ? (unsigned long)omp_get_max_threads() : 0,
        allocation_small_path ? 0 : 1};
    size_t each_bytes[3] = {expected_shared_alloc_bytes, expected_x_bytes, expected_kb_bytes};
    unsigned long failed[3] = {0, 0, 0};
#if defined(TEST_ALLOC_FAIL)
    for (int kind = 0; kind < 3; ++kind) failed[kind] = wanted[kind];
#elif defined(TEST_SHARED_ALLOC_FAIL)
    failed[0] = wanted[0];
#elif defined(TEST_X_ALLOC_FAIL)
    failed[1] = wanted[1];
#endif
    unsigned long total = 0, failures = 0;
    int bad = __atomic_load_n(&allocation_shape_bad, __ATOMIC_RELAXED) != 0;
    for (int kind = 0; kind < 3; ++kind) {
        unsigned long calls = __atomic_load_n(&allocation_calls[kind], __ATOMIC_RELAXED);
        bad |= calls != wanted[kind]
            || __atomic_load_n(&allocation_levels[kind], __ATOMIC_RELAXED) != (wanted[kind] ? (kind == 1 ? 1 : 0) : -1)
            || __atomic_load_n(&allocation_bytes[kind], __ATOMIC_RELAXED) != wanted[kind] * each_bytes[kind]
            || __atomic_load_n(&allocation_failures[kind], __ATOMIC_RELAXED) != failed[kind]
            || __atomic_load_n(&allocation_successes[kind], __ATOMIC_RELAXED) != wanted[kind] - failed[kind];
        total += wanted[kind]; failures += failed[kind];
    }
    bad |= __atomic_load_n(&aligned_alloc_calls, __ATOMIC_RELAXED) != total
        || __atomic_load_n(&injected_alloc_failures, __ATOMIC_RELAXED) != failures;
    for (int worker = 0; worker < 38; ++worker)
        bad |= __atomic_load_n(&worker_x_calls[worker], __ATOMIC_RELAXED)
            != (unsigned long)(allocation_small_path && worker < omp_get_max_threads());
    if (bad) { printf("FAIL allocation-audit m=%d n=%d\n", m, n); return 1; }
    ++allocation_checked;
    if (budget_mode) ++budget_checked;
#if defined(TEST_SHARED_ALLOC_FAIL)
    if (failed[0]) ++shared_injection_cases;
#endif
    printf("ALLOC_PASS m=%d n=%d small=%d history_expected=%d history_calls=%lu history_bytes=%zu history_success=%lu history_fail=%lu x_calls=%lu x_bytes=%zu x_success=%lu x_fail=%lu kb_calls=%lu kb_bytes=%zu kb_success=%lu kb_fail=%lu total=%lu injected=%lu history_level=%d x_level=%d kb_level=%d shape_bad=0 x_each_worker_once=1\n",
        m, n, allocation_small_path, history_expected,
        allocation_calls[0], allocation_bytes[0], allocation_successes[0], allocation_failures[0],
        allocation_calls[1], allocation_bytes[1], allocation_successes[1], allocation_failures[1],
        allocation_calls[2], allocation_bytes[2], allocation_successes[2], allocation_failures[2], total, failures,
        allocation_levels[0], allocation_levels[1], allocation_levels[2]);
    return 0;
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
    size_t triangular = (size_t)m * ((size_t)m + 1) / 2;
    allocation_small_path = triangular <= (64u * 1024u * 1024u) / sizeof(double);
    int history_expected = allocation_small_path && TEST_HAS_PACKEDL16
        && effective_sve && m >= 32 && history_fits(m);
    expected_shared_alloc_bytes = history_bytes(m);
    expected_x_bytes = (size_t)m * 8 * sizeof(double);
    expected_kb_bytes = ((size_t)n + 7) / 8 * 256 * 8 * sizeof(double);
    l_trsm(m, n, l, lda, b, ldb);
    unsigned long actual = __atomic_load_n(&panel_entries, __ATOMIC_RELAXED);
    unsigned long packed_actual = __atomic_load_n(&packed_panel_entries, __ATOMIC_RELAXED);
    unsigned long expected = can_enter && triangular <= (64u * 1024u * 1024u) / sizeof(double)
        ? (unsigned long)(m / 16) * (unsigned long)((n + 7) / 8) : 0;
    unsigned long packed_expected = can_enter_packed && expected && history_expected
        ? (unsigned long)(m / 16 - 1) * (unsigned long)((n + 7) / 8) : 0;
    int bad = actual != expected || packed_actual != packed_expected;
    bad |= allocation_check(m, n, history_expected);
    if (bad) printf("FAIL entry-count m=%d n=%d actual=%lu expected=%lu packed_actual=%lu packed_expected=%lu\n",
                    m, n, actual, expected, packed_actual, packed_expected);
#if defined(TEST_SHARED_ALLOC_FAIL)
    unsigned long calls = __atomic_load_n(&aligned_alloc_calls, __ATOMIC_RELAXED);
    unsigned long failures = __atomic_load_n(&injected_alloc_failures, __ATOMIC_RELAXED);
    unsigned long successes = __atomic_load_n(&later_alloc_successes, __ATOMIC_RELAXED);
    unsigned long shared_first = __atomic_load_n(&first_shared_shape_ok, __ATOMIC_RELAXED);
    if (!TEST_HAS_PACKEDL16 || m < 32 || !expected || failures != (unsigned long)history_expected
            || shared_first != (unsigned long)history_expected
            || calls != (unsigned long)omp_get_max_threads() + (unsigned long)history_expected
            || successes != (unsigned long)omp_get_max_threads() - (unsigned long)!history_expected
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
        if (history_expected)
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
                 || !strcmp(argv[i], "shared-fail") || !strcmp(argv[i], "budget")
                 || !strcmp(argv[i], "budget-smoke")) mode = argv[i];
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
#if defined(TEST_NO_SVE)
    effective_sve = 0;
#endif
#if defined(TEST_NO_SVE) || defined(TEST_ALLOC_FAIL) || defined(TEST_X_ALLOC_FAIL)
    can_enter = 0;
#endif
    can_enter_packed = TEST_HAS_PACKEDL16 && can_enter;
#if defined(TEST_SHARED_ALLOC_FAIL)
    can_enter_packed = 0;
    if ((strcmp(mode, "shared-fail") && strcmp(mode, "budget")) || !TEST_HAS_PACKEDL16 || !can_enter || narrow) {
        puts("FAIL first-shared-allocation target requires packed candidate, SVE8 and shared-fail small mode"); return 1;
    }
#else
    if (!strcmp(mode, "shared-fail")) { puts("FAIL shared-fail mode requires first-shared-allocation injection"); return 1; }
#endif
    budget_mode = !strcmp(mode, "budget") || !strcmp(mode, "budget-smoke");
    printf("SOURCE_FEATURES_PASS panel16=%d packedL16=%d has_budget=%d history_budget_bytes=%u\n",
        TEST_HAS_PANEL16, TEST_HAS_PACKEDL16, TEST_HAS_HISTORY_BUDGET,
        TEST_HAS_HISTORY_BUDGET ? 4u * 1024u * 1024u : 0u);
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
    } else if (!strcmp(mode, "budget")) {
        const int ms[] = {1023, 1024, 1039, 1040, 1041};
        for (size_t i = 0; i < sizeof(ms) / sizeof(ms[0]); ++i)
            if (case_check(ms[i], 9)) return 1;
    } else if (!strcmp(mode, "budget-smoke")) {
        if (case_check(1039, 313) || case_check(1040, 313)) return 1;
    } else {
        if (case_check(4095, 9) || case_check(4097, 9)) return 1;
    }
    if (noop_check()) return 1;
    printf("ALLOCATION_SUMMARY_PASS cases=%d budget_cases=%d shared_injection_cases=%d\n",
           allocation_checked, budget_checked, shared_injection_cases);
    printf("PASS whole_cases=%d noop_cases=%d non_dyadic_long_double_RHS=1 padding_L_unchanged=1 max_error=%.17g\n", checked, noop_checked, worst);
    return 0;
}
