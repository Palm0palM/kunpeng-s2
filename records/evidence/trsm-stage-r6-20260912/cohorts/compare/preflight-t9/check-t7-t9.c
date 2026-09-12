#include <math.h>
#include <omp.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(__linux__) || !defined(__aarch64__)
#error This comparison is for the scheduler-allocated Linux aarch64 target.
#endif

void trsm_t7_reference(int, int, const double *, int, double *, int);
void trsm_t9_candidate(int, int, const double *, int, double *, int);

enum { EXPECTED_CASES = 105, EXPECTED_ELEMENTS = 62853 };
static const long double tolerance = 1e-12L;
static int cases_checked, cases_passed;
static size_t elements_checked;
static long double worst_solution[2], worst_residual[2];

static int check_case(int m, int n)
{
    const int lda = m + 3, ldb = n + 7;
    const size_t nl = (size_t)m * lda, nb = (size_t)m * ldb;
    double *l = malloc(nl * sizeof(double));
    double *l7 = malloc(nl * sizeof(double));
    double *l9 = malloc(nl * sizeof(double));
    double *input = malloc(nb * sizeof(double));
    double *known = malloc(nb * sizeof(double));
    double *b7 = malloc(nb * sizeof(double));
    double *b9 = malloc(nb * sizeof(double));
    if (!l || !l7 || !l9 || !input || !known || !b7 || !b9) {
        printf("FAIL fixture-allocation m=%d n=%d\n", m, n);
        free(l); free(l7); free(l9); free(input); free(known); free(b7); free(b9);
        return 2;
    }
    for (size_t q = 0; q < nl; ++q) l[q] = 37.125 + (double)(q % 19);
    for (int i = 0; i < m; ++i) {
        double diag = 1.031;
        for (int k = 0; k < i; ++k) {
            const double a = ((i * 19 + k * 31) % 97 - 48) / 997.0;
            l[(size_t)i * lda + k] = a;
            diag += fabs(a);
        }
        l[(size_t)i * lda + i] = diag;
    }
    for (size_t q = 0; q < nb; ++q)
        known[q] = input[q] = 31.125 + (double)(q % 19);
    for (int i = 0; i < m; ++i)
        for (int j = 0; j < n; ++j)
            known[(size_t)i * ldb + j] = ((i * 13 + j * 17) % 101 - 50) / 103.0;
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            long double acc = 0;
            for (int k = 0; k <= i; ++k)
                acc += (long double)l[(size_t)i * lda + k] * known[(size_t)k * ldb + j];
            input[(size_t)i * ldb + j] = (double)acc;
        }
    }
    memcpy(l7, l, nl * sizeof(double));
    memcpy(l9, l, nl * sizeof(double));
    memcpy(b7, input, nb * sizeof(double));
    memcpy(b9, input, nb * sizeof(double));
    trsm_t7_reference(m, n, l7, lda, b7, ldb);
    trsm_t9_candidate(m, n, l9, lda, b9, ldb);

    size_t nonfinite = 0, numeric_mismatches = 0, bitwise_mismatches = 0;
    size_t solution_failures[2] = {0, 0}, residual_failures[2] = {0, 0};
    size_t padding_failures[2] = {0, 0};
    long double max_solution[2] = {0, 0}, max_residual[2] = {0, 0};
    int printed_difference = 0;
    const double *outputs[2] = {b7, b9};
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            const size_t offset = (size_t)i * ldb + j;
            const int finite = isfinite(b7[offset]) && isfinite(b9[offset]);
            const int numeric_equal = finite && b7[offset] == b9[offset];
            const int bitwise_equal = memcmp(b7 + offset, b9 + offset, sizeof(double)) == 0;
            nonfinite += !finite;
            numeric_mismatches += !numeric_equal;
            bitwise_mismatches += !bitwise_equal;
            ++elements_checked;
            if ((!finite || !numeric_equal || !bitwise_equal) && !printed_difference) {
                printf("DIFFERENCE m=%d n=%d i=%d j=%d T7=%a T9=%a finite=%d numeric_equal=%d bitwise_equal=%d\n",
                       m, n, i, j, b7[offset], b9[offset], finite, numeric_equal, bitwise_equal);
                printed_difference = 1;
            }
            for (int impl = 0; impl < 2; ++impl) {
                const double *output = outputs[impl];
                const long double solution_error = fabsl((long double)output[offset] - known[offset]);
                long double product = 0;
                for (int k = 0; k <= i; ++k)
                    product += (long double)l[(size_t)i * lda + k] * output[(size_t)k * ldb + j];
                const long double residual = fabsl(product - input[offset]);
                if (!isfinite(solution_error) || solution_error > tolerance)
                    ++solution_failures[impl];
                if (!isfinite(residual) || residual > tolerance)
                    ++residual_failures[impl];
                if (solution_error > max_solution[impl]) max_solution[impl] = solution_error;
                if (residual > max_residual[impl]) max_residual[impl] = residual;
            }
        }
        for (int j = n; j < ldb; ++j) {
            const size_t offset = (size_t)i * ldb + j;
            for (int impl = 0; impl < 2; ++impl)
                padding_failures[impl] += memcmp(outputs[impl] + offset, input + offset, sizeof(double)) != 0;
        }
    }
    const int l7_changed = memcmp(l7, l, nl * sizeof(double)) != 0;
    const int l9_changed = memcmp(l9, l, nl * sizeof(double)) != 0;
    const int failed = nonfinite || numeric_mismatches || bitwise_mismatches ||
        solution_failures[0] || solution_failures[1] || residual_failures[0] || residual_failures[1] ||
        padding_failures[0] || padding_failures[1] || l7_changed || l9_changed;
    ++cases_checked;
    cases_passed += !failed;
    for (int impl = 0; impl < 2; ++impl) {
        if (max_solution[impl] > worst_solution[impl]) worst_solution[impl] = max_solution[impl];
        if (max_residual[impl] > worst_residual[impl]) worst_residual[impl] = max_residual[impl];
    }
    printf("CASE_%s m=%d n=%d lda=%d ldb=%d elements=%zu nonfinite=%zu numeric_mismatches=%zu bitwise_mismatches=%zu "
           "T7_solution_error=%.21Lg T9_solution_error=%.21Lg T7_residual=%.21Lg T9_residual=%.21Lg "
           "T7_solution_failures=%zu T9_solution_failures=%zu T7_residual_failures=%zu T9_residual_failures=%zu "
           "T7_padding_failures=%zu T9_padding_failures=%zu T7_L_changed=%d T9_L_changed=%d\n",
           failed ? "FAIL" : "PASS", m, n, lda, ldb, (size_t)m * n, nonfinite, numeric_mismatches, bitwise_mismatches,
           max_solution[0], max_solution[1], max_residual[0], max_residual[1],
           solution_failures[0], solution_failures[1], residual_failures[0], residual_failures[1],
           padding_failures[0], padding_failures[1], l7_changed, l9_changed);
    free(l); free(l7); free(l9); free(input); free(known); free(b7); free(b9);
    return failed;
}

int main(void)
{
    const char *job = getenv("TRSM_SCHEDULER_JOB_ID");
    if (!job || !*job || omp_get_max_threads() != 1) {
        puts("PREFLIGHT_BLOCKED requires explicit scheduler job ID and OMP_NUM_THREADS=1");
        return 2;
    }
    int workers = 0;
#pragma omp parallel reduction(+:workers)
    {
        workers += 1;
    }
    if (workers != 1) {
        printf("PREFLIGHT_BLOCKED expected one test worker, found %d\n", workers);
        return 2;
    }
    printf("MODE=T7_T9_NUMERIC_COMPARE THREADS=%d JOB_ID=%s TOLERANCE=1e-12 PERFORMANCE_BASELINE=T8-svepanel16\n", workers, job);
    const int ms[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 16, 17, 255, 256, 257};
    const int ns[] = {1, 7, 8, 9, 15, 16, 17};
    int failures = 0;
    for (size_t mi = 0; mi < sizeof(ms) / sizeof(ms[0]); ++mi) {
        for (size_t ni = 0; ni < sizeof(ns) / sizeof(ns[0]); ++ni) {
            const int rc = check_case(ms[mi], ns[ni]);
            if (rc == 2) return 2;
            failures += rc != 0;
        }
    }
    printf("NUMERIC_SUMMARY cases_checked=%d cases_passed=%d elements_checked=%zu solves=%d "
           "T7_max_solution_error=%.21Lg T9_max_solution_error=%.21Lg T7_max_residual=%.21Lg T9_max_residual=%.21Lg\n",
           cases_checked, cases_passed, elements_checked, cases_checked * 2,
           worst_solution[0], worst_solution[1], worst_residual[0], worst_residual[1]);
    if (failures || cases_checked != EXPECTED_CASES || cases_passed != EXPECTED_CASES || elements_checked != EXPECTED_ELEMENTS) {
        puts("TRSM_T9_NUMERIC_COMPLETE=0");
        return 1;
    }
    puts("TRSM_T9_NUMERIC_COMPLETE=1 CASES=105 ELEMENTS=62853 SOLVES=210 FINITE_NUMERIC_BITWISE=1 TOLERANCE=1e-12 PADDING_L_UNCHANGED=1");
    return 0;
}
