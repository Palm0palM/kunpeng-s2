/* Diagnostic-only hooks. This TU uses real libc allocation/copy/free.
 * Macros redirect only the candidate TU, never this TU or the guard. */
#include "copy_probe.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef COPY_EXPECT_PADDED
#error "Set expected stride mode for the diagnostic, not production source"
#endif
struct probe_state {
    const float *input, *reference;
    float *output, *buffer;
    size_t height, width, stride, elements, bytes, output_count;
    unsigned row_seen[32];
    size_t attempts, successes, copies, frees;
    int eligible;
};
static struct probe_state g;
static int force_failure;
static size_t cases_seen, eligible_seen, total_attempts, total_successes;
static size_t total_copies, total_frees, total_forced, total_errors;
static const uint32_t padding_poison = UINT32_C(0x7fc12345);
static void issue(const char *why) {
    __atomic_fetch_add(&total_errors, (size_t)1, __ATOMIC_RELAXED);
    fprintf(stderr, "COPY_PROBE_ERROR=%s\n", why);
}
void copy_probe_set_failure(int enabled) { force_failure = enabled; }
void copy_probe_begin(const float *input, int height, int width,
                      const float *kernel, int kh, int kw,
                      float *output, const float *reference, size_t count) {
    (void)kernel; (void)kw;
    memset(&g, 0, sizeof(g));
    ++cases_seen;
    if (height < 1 || height > 32 || width < 1 || width > 129) {
        issue("unexpected focused-matrix dimensions"); exit(7);
    }
    g.input=input; g.reference=reference; g.output=output;
    g.height=(size_t)height; g.width=(size_t)width; g.output_count=count;
    /* Independent small-domain construction, not copied rounding code. */
    size_t padded=g.width;
    while (padded % 16 != 0 || (padded / 16) % 2 != 1) ++padded;
    g.eligible=kh>=4 && height-kh+1>=4 && width>=64 && padded!=g.width;
    g.stride=COPY_EXPECT_PADDED ? padded : g.width;
    g.elements=padded*g.height;
    g.bytes=g.elements*sizeof(float);
    if (g.eligible) ++eligible_seen;
}
void *candidate_malloc(size_t bytes) {
    ++g.attempts; ++total_attempts;
    if (!g.eligible || g.attempts!=1 || bytes!=g.bytes) {
        issue("candidate malloc gate/count/size mismatch"); return NULL;
    }
    if (force_failure) { ++total_forced; return NULL; }
    g.buffer=malloc(bytes);
    if (!g.buffer) { issue("underlying diagnostic malloc failed"); return NULL; }
    ++g.successes; ++total_successes;
    for (size_t i=0;i<g.elements;++i)
        memcpy(g.buffer+i,&padding_poison,sizeof(padding_poison));
    return g.buffer;
}
void *candidate_memcpy(void *destination, const void *source, size_t bytes) {
    if (!g.buffer || bytes!=g.width*sizeof(float)) {
        issue("copy without live allocation or wrong length"); return destination;
    }
    const uintptr_t d=(uintptr_t)destination, b=(uintptr_t)g.buffer;
    const size_t row_bytes=g.stride*sizeof(float);
    if (d<b || (d-b)%row_bytes!=0 || (d-b)/row_bytes>=g.height) {
        issue("copy destination stride/range mismatch"); return destination;
    }
    const size_t row=(size_t)((d-b)/row_bytes);
    if (source!=(const void *)(g.input+row*g.width)) {
        issue("copy source row mismatch"); return destination;
    }
    if (__atomic_fetch_add(&g.row_seen[row],1U,__ATOMIC_RELAXED)!=0)
        issue("row copied more than once");
    __atomic_fetch_add(&g.copies,(size_t)1,__ATOMIC_RELAXED);
    __atomic_fetch_add(&total_copies,(size_t)1,__ATOMIC_RELAXED);
    return memcpy(destination,source,bytes);
}
static void check_poison(size_t first,size_t last) {
    for (size_t i=first;i<last;++i) {
        uint32_t bits;
        memcpy(&bits,g.buffer+i,sizeof(bits));
        if (bits!=padding_poison) { issue("padding/unused area modified"); return; }
    }
}
void candidate_free(void *pointer) {
    ++g.frees; ++total_frees;
    if (!g.buffer || pointer!=(void *)g.buffer || g.frees!=1) {
        issue("free pointer/count mismatch"); return;
    }
    if (g.copies!=g.height) issue("free before every input row copied");
    for (size_t row=0;row<g.height;++row) {
        if (__atomic_load_n(&g.row_seen[row],__ATOMIC_RELAXED)!=1)
            issue("missing or duplicate copied row at free");
        if (memcmp(g.buffer+row*g.stride,g.input+row*g.width,g.width*sizeof(float)))
            issue("copied payload differs or was modified");
        if (COPY_EXPECT_PADDED) check_poison(row*g.stride+g.width,(row+1)*g.stride);
    }
    if (!COPY_EXPECT_PADDED) check_poison(g.height*g.width,g.elements);
    /* Guard reference already exists; this check happens BEFORE actual free. */
    if (memcmp(g.output,g.reference,g.output_count*sizeof(float)))
        issue("output not complete/correct when candidate frees input copy");
    free(g.buffer); g.buffer=NULL;
}
int copy_probe_end(void) {
    const size_t wanted_attempts=g.eligible ? 1 : 0;
    const size_t wanted_success=g.eligible && !force_failure ? 1 : 0;
    const size_t wanted_copies=wanted_success ? g.height : 0;
    if (g.attempts!=wanted_attempts || g.successes!=wanted_success ||
        g.frees!=wanted_success || g.copies!=wanted_copies)
        issue("per-call allocation/copy/free totals mismatch");
    if (g.buffer) { issue("candidate returned without freeing"); free(g.buffer); g.buffer=NULL; }
    return __atomic_load_n(&total_errors,__ATOMIC_RELAXED)==0;
}
int copy_probe_report(size_t expected_cases,size_t expected_eligible,size_t expected_copies) {
    const size_t expected_success=force_failure ? 0 : expected_eligible;
    const size_t expected_forced=force_failure ? expected_eligible : 0;
    if (cases_seen!=expected_cases || eligible_seen!=expected_eligible ||
        total_attempts!=expected_eligible || total_successes!=expected_success ||
        total_forced!=expected_forced || total_copies!=expected_copies || total_frees!=expected_success)
        issue("configuration totals mismatch");
    printf("COPY_PROBE_MODE=%s STRIDE_MODE=%s CASES=%zu ELIGIBLE=%zu DISABLED=%zu "
           "MALLOC_ATTEMPTS=%zu MALLOC_SUCCESSES=%zu FORCED_FAILURES=%zu "
           "MEMCPY_CALLS=%zu FREE_CALLS=%zu ERROR_COUNT=%zu\n",
           force_failure ? "failure" : "success",COPY_EXPECT_PADDED ? "padded" : "original",
           cases_seen,eligible_seen,cases_seen-eligible_seen,total_attempts,total_successes,
           total_forced,total_copies,total_frees,total_errors);
    return total_errors==0;
}
