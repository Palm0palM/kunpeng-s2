#define _DEFAULT_SOURCE 1
#include <arm_sve.h>
#include <asm/hwcap.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/auxv.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <unistd.h>

/* Diagnostic only. Compile and execute on allocated Linux/AArch64 nodes. */
void conv2d(const float *, int, int, const float *, int, int, float *);
#ifndef EXPECTED_ACC
#error "Pass EXPECTED_ACC as the number of vectors per output row in the candidate main helper."
#endif
struct guarded {
    void *mapping;
    size_t mapping_bytes, usable_bytes, count;
    unsigned char *usable;
    float *data;
};
static const uint32_t canary = UINT32_C(0x7fa1b2c3);
static const uint32_t poison = UINT32_C(0x7fc0a5a5);
static uint32_t rng = 7;
static float sample(void) {
    rng = rng * 1664525u + 1013904223u;
    return ((int)(rng >> 16) - 32768) * 0.000030517578125f;
}
static void fail(const char *message) { perror(message); exit(3); }
static struct guarded allocate_guarded(size_t count, int pad, int leading) {
    const long page_long = sysconf(_SC_PAGESIZE);
    if (page_long <= 0) fail("page size");
    const size_t page = (size_t)page_long;
    const size_t bytes = (count + (size_t)pad) * sizeof(float);
    struct guarded g;
    g.count = count;
    g.usable_bytes = ((bytes + page - 1) / page) * page;
    g.mapping_bytes = g.usable_bytes + 2 * page;
    g.mapping = mmap(NULL, g.mapping_bytes, PROT_NONE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (g.mapping == MAP_FAILED) fail("mmap");
    g.usable = (unsigned char *)g.mapping + page;
    if (mprotect(g.usable, g.usable_bytes, PROT_READ | PROT_WRITE)) fail("mprotect rw");
    for (size_t i = 0; i < g.usable_bytes; i += sizeof(uint32_t))
        memcpy(g.usable + i, &canary, sizeof(canary));
    g.data = leading ? (float *)(g.usable + (size_t)pad * sizeof(float))
                     : (float *)(g.usable + g.usable_bytes - bytes);
    return g;
}
static void readonly(struct guarded *g) {
    if (mprotect(g->usable, g->usable_bytes, PROT_READ)) fail("mprotect readonly");
}
static int outside_unchanged(const struct guarded *g) {
    const size_t begin = (const unsigned char *)g->data - g->usable;
    const size_t end = begin + g->count * sizeof(float);
    for (size_t i = 0; i < g->usable_bytes; i += sizeof(uint32_t)) {
        uint32_t got;
        if (i >= begin && i < end) continue;
        memcpy(&got, g->usable + i, sizeof(got));
        if (got != canary) return 0;
    }
    return 1;
}
static void release(struct guarded *g) {
    if (munmap(g->mapping, g->mapping_bytes)) fail("munmap");
}
__attribute__((target("arch=armv8-a+sve"), no_instrument_function))
static unsigned runtime_lanes(void) { return svcntw(); }
typedef void (*conv_call)(const float *, int, int, const float *, int, int, float *);
/* Set only between completed cases; production always calls unchanged conv2d. */
static conv_call checked_conv = conv2d;
static int one_case(int ow, int kh, int kw, int oh, int pad, int leading) {
    const int width = ow + kw - 1, height = oh + kh - 1;
    const size_t ni = (size_t)width * height, nk = (size_t)kh * kw;
    const size_t no = (size_t)oh * ow;
    struct guarded input = allocate_guarded(ni, pad, leading);
    struct guarded kernel = allocate_guarded(nk, pad, leading);
    struct guarded output = allocate_guarded(no, 0, leading);
    float *ref = malloc(no * sizeof(float));
    if (!ref) fail("malloc reference");
    for (size_t i = 0; i < ni; ++i) input.data[i] = sample();
    for (size_t i = 0; i < nk; ++i) kernel.data[i] = sample();
    for (size_t i = 0; i < no; ++i) memcpy(output.data + i, &poison, sizeof(poison));
    readonly(&input);
    readonly(&kernel);
    for (int y = 0; y < oh; ++y) for (int x = 0; x < ow; ++x) {
        float sum = 0.0f;
        for (int ky = 0; ky < kh; ++ky) for (int kx = 0; kx < kw; ++kx)
            sum += input.data[(size_t)(y + ky) * width + x + kx] * kernel.data[(size_t)ky * kw + kx];
        ref[(size_t)y * ow + x] = sum;
    }
    checked_conv(input.data, height, width, kernel.data, kh, kw, output.data);
    int good = memcmp(ref, output.data, no * sizeof(float)) == 0;
    good = good && outside_unchanged(&input) && outside_unchanged(&kernel) && outside_unchanged(&output);
    if (!good) fprintf(stderr, "FAIL ow=%d kh=%d kw=%d oh=%d pad=%d leading=%d\n", ow, kh, kw, oh, pad, leading);
    free(ref);
    release(&input); release(&kernel); release(&output);
    return good;
}
static int setup_config(int argc, char **argv) {
    if (argc != 2 || !(getauxval(AT_HWCAP) & HWCAP_SVE)) {
        fprintf(stderr, "SVE hardware and explicit vector byte length are required\n"); exit(3);
    }
    const int bytes = atoi(argv[1]);
    if (bytes != 16 && bytes != 32 && bytes != 64) exit(3);
    if (prctl(PR_SVE_SET_VL, (unsigned long)bytes, 0, 0, 0) < 0) fail("PR_SVE_SET_VL");
    if ((prctl(PR_SVE_GET_VL, 0, 0, 0, 0) & PR_SVE_VL_LEN_MASK) != bytes) exit(5);
    omp_set_dynamic(0);
    int bad_workers = 0, actual_threads = 0;
    #pragma omp parallel reduction(+:bad_workers)
    {
        if (runtime_lanes() != (unsigned)bytes / sizeof(float)) ++bad_workers;
        #pragma omp single
        actual_threads = omp_get_num_threads();
    }
    if (bad_workers || (actual_threads != 1 && actual_threads != 4)) {
        fprintf(stderr, "Worker VL/thread mismatch: bad=%d threads=%d\n", bad_workers, actual_threads); exit(5);
    }
    if (actual_threads != omp_get_max_threads()) exit(5);
    printf("SVE_BYTES=%d SVE_LANES=%u BLOCK_OUTPUTS=%u THREADS=%d\n", bytes,
           runtime_lanes(), EXPECTED_ACC * runtime_lanes(), actual_threads);
    return (int)runtime_lanes();
}

int main(int argc, char **argv) {
    const int lanes = setup_config(argc, argv);
    const int widths[] = {4*lanes,4*lanes+1,5*lanes-1,5*lanes,5*lanes+1,10*lanes-1,10*lanes,10*lanes+1};
    const int heights[] = {1,2,3,4,5,6,7,8,9,10,20};
    int count = 0, core = 0, narrow = 0, small = 0, larger = 0;
    for (unsigned w=0; w<sizeof(widths)/sizeof(*widths); ++w)
    for (int kh=4; kh<=6; ++kh)
    for (int kw=1; kw<=3; ++kw)
    for (unsigned h=0; h<sizeof(heights)/sizeof(*heights); ++h)
    for (int pad=0; pad<=1; ++pad)
    for (int leading=0; leading<=1; ++leading) {
        if (!one_case(widths[w],kh,kw,heights[h],pad,leading)) return 1;
        ++core; ++count;
    }
    const int extra_heights[] = {1,5,9,20};
    for (int kh=4; kh<=6; ++kh)
    for (int kw=1; kw<=3; ++kw)
    for (unsigned h=0; h<sizeof(extra_heights)/sizeof(*extra_heights); ++h)
    for (int pad=0; pad<=1; ++pad)
    for (int leading=0; leading<=1; ++leading) {
        if (!one_case(1,kh,kw,extra_heights[h],pad,leading)) return 1;
        ++narrow; ++count;
    }
    const int small_widths[] = {1,5*lanes-1,5*lanes+1};
    for (unsigned w=0; w<sizeof(small_widths)/sizeof(*small_widths); ++w)
    for (int kh=1; kh<=3; ++kh)
    for (int kw=1; kw<=3; ++kw)
    for (unsigned h=0; h<sizeof(extra_heights)/sizeof(*extra_heights); ++h)
    for (int pad=0; pad<=1; ++pad)
    for (int leading=0; leading<=1; ++leading) {
        if (!one_case(small_widths[w],kh,kw,extra_heights[h],pad,leading)) return 1;
        ++small; ++count;
    }
    const int larger_kernels[][2] = {{8,7},{7,8},{15,15},{81,81}};
    const int larger_heights[] = {5,9};
    for (unsigned k=0; k<sizeof(larger_kernels)/sizeof(*larger_kernels); ++k)
    for (unsigned h=0; h<sizeof(larger_heights)/sizeof(*larger_heights); ++h)
    for (int pad=0; pad<=1; ++pad)
    for (int leading=0; leading<=1; ++leading) {
        if (!one_case(5*lanes+1,larger_kernels[k][0],larger_kernels[k][1],larger_heights[h],pad,leading)) return 1;
        ++larger; ++count;
    }
    if (core!=3168 || narrow!=144 || small!=432 || larger!=32 || count!=3776) return 6;
    printf("FULL_MATRIX_COUNTS core=%d narrow=%d small=%d larger=%d\n",core,narrow,small,larger);
    printf("PASS: %d convolution cases; readonly input/kernel, guarded allocation edges, poisoned/guarded output, bitwise scalar reference\n",count);
    return 0;
}
