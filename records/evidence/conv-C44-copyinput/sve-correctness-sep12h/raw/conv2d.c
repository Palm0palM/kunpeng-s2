#include <stddef.h>

#if defined(__linux__) && defined(__aarch64__)
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <arm_sve.h>
#include <sys/auxv.h>
#include <asm/hwcap.h>
#define CONV_CAN_DISPATCH_SVE 1
#else
#define CONV_CAN_DISPATCH_SVE 0
#endif

typedef float CONVFLOAT;
typedef int CONVINT;

/*
 * V2：固定输出分块 + 固定宽度 tail + 可选 kernel 两步展开。
 *
 * 语义：连续行主序 float 矩阵，valid 卷积（与官方相同，不翻转 kernel）。
 * input/kernel 只读；output 不能与它们重叠，每个输出被完整覆盖。
 * 正确性关键：每个输出仍按 jk 从小到大、ik 从小到大进行 float 累加。
 * SIMD lane 对应不同输出，不能对同一输出做 partial sum 后重新求和。
 * benchmark 与本文件都要使用 -ffp-contract=off，且不能使用 fast-math。
 *
 * 本轮只写代码：寄存器驻留、向量指令、速度和 PASS 均待目标机器验证。
 */
#ifdef __FAST_MATH__
#error "Strict reference accumulation requires disabling fast-math"
#endif

#ifndef CONV_BLOCK
#define CONV_BLOCK 32
#endif
#if CONV_BLOCK <= 0
#error "CONV_BLOCK must be positive"
#endif

/*
 * 2：每轮按顺序处理两个 kernel 元素，减少循环比较/跳转。
 * 1：保留单步 kernel 循环，供比赛机器单独比较展开的影响。
 * 两步展开会增加输入/乘积临时值，不保证所有 CPU 都更快。
 */
#ifndef CONV_KERNEL_UNROLL
#define CONV_KERNEL_UNROLL 2
#endif
#if CONV_KERNEL_UNROLL != 1 && CONV_KERNEL_UNROLL != 2
#error "CONV_KERNEL_UNROLL must be 1 or 2"
#endif

/* 内联可暴露固定数组大小；没有此属性仍正确，但优化效果可能不同。 */
#if defined(__GNUC__) || defined(__clang__)
#define CONV_INLINE static inline __attribute__((always_inline))
#else
#define CONV_INLINE static inline
#endif

/*
 * 宏生成固定宽度函数：N 是编译期常量，acc 的大小和 b 循环次数均已知。
 * 这样便于编译器展开 b 循环、把数组拆成独立寄存器，避免动态尾部长度。
 * N=32 在 NEON 上可映射为八个四路向量 accumulator；实际分配要看汇编。
 * acc 的生命期覆盖完整 kernel，output 只写一次，不需要先 memset。
 *
 * 宏中的 _Pragma("omp simd") 等价于普通代码的 #pragma omp simd。
 * b 之间完全独立，而 ik 之间保留依赖，所以这里不能加 reduction 子句。
 *
 * 两步展开的浮点顺序：
 *   acc = round(acc + round(input0 * k0));
 *   acc = round(acc + round(input1 * k1));
 * 不能改成 acc += input0*k0 + input1*k1，那样加法括号会变。
 * CONV_KERNEL_UNROLL 是常量，编译器可以消除对应的 if 分支。
 */
#define DEFINE_CONV_TILE(NAME, N)                                            \
CONV_INLINE void NAME(const float *restrict base, size_t stride,              \
                      const float *restrict kernel, int kh, int kw,          \
                      float *restrict dst)                                   \
{                                                                            \
    float acc[N] = {0.0f};                                                   \
    const float *krow = kernel;                                              \
    for (int jk = 0; jk < kh; ++jk) {                                        \
        const float *row = base + (size_t)jk * stride;                       \
        int ik = 0;                                                         \
        if (CONV_KERNEL_UNROLL == 2) {                                       \
            for (; ik < kw - 1; ik += 2) {                                   \
                const float k0 = krow[ik];                                  \
                const float k1 = krow[ik + 1];                              \
                const float *window = row + ik;                             \
                _Pragma("omp simd")                                        \
                for (int b = 0; b < (N); ++b) {                              \
                    acc[b] += window[b] * k0;                               \
                    acc[b] += window[b + 1] * k1;                           \
                }                                                           \
            }                                                               \
        }                                                                   \
        for (; ik < kw; ++ik) {                                              \
            const float k = krow[ik];                                       \
            const float *window = row + ik;                                 \
            _Pragma("omp simd")                                             \
            for (int b = 0; b < (N); ++b) {                                  \
                acc[b] += window[b] * k;                                    \
            }                                                               \
        }                                                                   \
        krow += kw;                                                         \
    }                                                                       \
    _Pragma("omp simd")                                                      \
    for (int b = 0; b < (N); ++b) {                                          \
        dst[b] = acc[b];                                                     \
    }                                                                       \
}

DEFINE_CONV_TILE(conv_tile_main, CONV_BLOCK)
DEFINE_CONV_TILE(conv_tile_16, 16)
DEFINE_CONV_TILE(conv_tile_8, 8)
DEFINE_CONV_TILE(conv_tile_4, 4)
DEFINE_CONV_TILE(conv_tile_2, 2)
DEFINE_CONV_TILE(conv_tile_1, 1)
#undef DEFINE_CONV_TILE
#undef CONV_INLINE

#if CONV_CAN_DISPATCH_SVE
/* Process the remainder with 4/2 full vectors and one predicated vector.
 * Every active lane keeps the same ordered float products and additions.
 * Pointers are formed only for vectors with at least one valid output. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void conv_sve_tail(const float *restrict base, size_t stride,
                          const float *restrict kernel, int kh, int kw,
                          float *restrict dst, int ow)
{
    const int lanes = (int)svcntw();
    const svbool_t pg = svptrue_b32();
    int i = 0;
    while (ow - i >= 4 * lanes) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        svfloat32_t a2 = svdup_n_f32(0.0f);
        svfloat32_t a3 = svdup_n_f32(0.0f);
        for (int jk = 0; jk < kh; ++jk) {
            const float *row = base + (size_t)jk * stride + i;
            const float *kr = kernel + (size_t)jk * kw;
            for (int ik = 0; ik < kw; ++ik) {
                const svfloat32_t k = svdup_n_f32(kr[ik]);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, svld1(pg, row + ik + 0 * lanes), k));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, svld1(pg, row + ik + 1 * lanes), k));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, svld1(pg, row + ik + 2 * lanes), k));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, svld1(pg, row + ik + 3 * lanes), k));
            }
        }
        svst1(pg, dst + i + 0 * lanes, a0);
        svst1(pg, dst + i + 1 * lanes, a1);
        svst1(pg, dst + i + 2 * lanes, a2);
        svst1(pg, dst + i + 3 * lanes, a3);
        i += 4 * lanes;
    }
    while (ow - i >= 2 * lanes) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        for (int jk = 0; jk < kh; ++jk) {
            const float *row = base + (size_t)jk * stride + i;
            const float *kr = kernel + (size_t)jk * kw;
            for (int ik = 0; ik < kw; ++ik) {
                const svfloat32_t k = svdup_n_f32(kr[ik]);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, svld1(pg, row + ik + 0 * lanes), k));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, svld1(pg, row + ik + 1 * lanes), k));
            }
        }
        svst1(pg, dst + i + 0 * lanes, a0);
        svst1(pg, dst + i + 1 * lanes, a1);
        i += 2 * lanes;
    }
    while (i < ow) {
        const int count = ow - i < lanes ? ow - i : lanes;
        const svbool_t active = svwhilelt_b32((uint64_t)0, (uint64_t)count);
        svfloat32_t a = svdup_n_f32(0.0f);
        for (int jk = 0; jk < kh; ++jk) {
            const float *row = base + (size_t)jk * stride + i;
            const float *kr = kernel + (size_t)jk * kw;
            for (int ik = 0; ik < kw; ++ik) {
                const svfloat32_t k = svdup_n_f32(kr[ik]);
                a = svadd_f32_x(active, a, svmul_f32_x(active, svld1(active, row + ik), k));
            }
        }
        svst1(active, dst + i, a);
        i += count;
    }
}
#endif
#if CONV_CAN_DISPATCH_SVE
/* Generic TU dispatches here only when Linux reports usable SVE. Each lane is
 * an independent output; eight accumulators span the entire kernel. Keep the
 * multiplication and addition separate, in the reference jk/ik order. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static int conv_sve_prefix(const float *restrict base, size_t stride,
                           const float *restrict kernel, int kh, int kw,
                           float *restrict dst, int ow)
{
    const int lanes = (int)svcntw();
    const int block = 8 * lanes;
    const svbool_t pg = svptrue_b32();
    int i = 0;
    for (; ow - i >= block; i += block) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        svfloat32_t a2 = svdup_n_f32(0.0f);
        svfloat32_t a3 = svdup_n_f32(0.0f);
        svfloat32_t a4 = svdup_n_f32(0.0f);
        svfloat32_t a5 = svdup_n_f32(0.0f);
        svfloat32_t a6 = svdup_n_f32(0.0f);
        svfloat32_t a7 = svdup_n_f32(0.0f);
        const float *krow = kernel;
        for (int jk = 0; jk < kh; ++jk) {
            const float *row = base + (size_t)jk * stride + i;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t k0 = svdup_n_f32(krow[ik]);
                const svfloat32_t k1 = svdup_n_f32(krow[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p + 0 * lanes);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t v4 = svld1(pg, p + 4 * lanes);
                const svfloat32_t v5 = svld1(pg, p + 5 * lanes);
                const svfloat32_t v6 = svld1(pg, p + 6 * lanes);
                const svfloat32_t v7 = svld1(pg, p + 7 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, k0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, k0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, k0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, k0));
                a4 = svadd_f32_x(pg, a4, svmul_f32_x(pg, v4, k0));
                a5 = svadd_f32_x(pg, a5, svmul_f32_x(pg, v5, k0));
                a6 = svadd_f32_x(pg, a6, svmul_f32_x(pg, v6, k0));
                a7 = svadd_f32_x(pg, a7, svmul_f32_x(pg, v7, k0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, svext_f32(v0, v1, 1), k1));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, svext_f32(v1, v2, 1), k1));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, svext_f32(v2, v3, 1), k1));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, svext_f32(v3, v4, 1), k1));
                a4 = svadd_f32_x(pg, a4, svmul_f32_x(pg, svext_f32(v4, v5, 1), k1));
                a5 = svadd_f32_x(pg, a5, svmul_f32_x(pg, svext_f32(v5, v6, 1), k1));
                a6 = svadd_f32_x(pg, a6, svmul_f32_x(pg, svext_f32(v6, v7, 1), k1));
                a7 = svadd_f32_x(pg, a7, svmul_f32_x(pg, svld1(pg, p + 7 * lanes + 1), k1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t k = svdup_n_f32(krow[ik]);
                const float *p = row + ik;
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, svld1(pg, p), k));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, svld1(pg, p + lanes), k));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, svld1(pg, p + 2 * lanes), k));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, svld1(pg, p + 3 * lanes), k));
                a4 = svadd_f32_x(pg, a4, svmul_f32_x(pg, svld1(pg, p + 4 * lanes), k));
                a5 = svadd_f32_x(pg, a5, svmul_f32_x(pg, svld1(pg, p + 5 * lanes), k));
                a6 = svadd_f32_x(pg, a6, svmul_f32_x(pg, svld1(pg, p + 6 * lanes), k));
                a7 = svadd_f32_x(pg, a7, svmul_f32_x(pg, svld1(pg, p + 7 * lanes), k));
            }
            krow += kw;
        }
        svst1(pg, dst + i, a0);
        svst1(pg, dst + i + lanes, a1);
        svst1(pg, dst + i + 2 * lanes, a2);
        svst1(pg, dst + i + 3 * lanes, a3);
        svst1(pg, dst + i + 4 * lanes, a4);
        svst1(pg, dst + i + 5 * lanes, a5);
        svst1(pg, dst + i + 6 * lanes, a6);
        svst1(pg, dst + i + 7 * lanes, a7);
    }
    if (i < ow) {
        conv_sve_tail(base + i, stride, kernel, kh, kw, dst + i, ow - i);
    }
    return ow;
}
#endif

#if CONV_CAN_DISPATCH_SVE
/* Two adjacent output rows share each middle input row. For the first output
 * kernel rows arrive as 0, 1, ..., kh-1; for the second they independently
 * arrive as 0, 1, ..., kh-1. No output uses partial sums or reordered adds. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void conv_sve_rowpair(const float *restrict base, size_t stride,
                             const float *restrict kernel, int kh, int kw,
                             float *restrict dst0, float *restrict dst1, int ow)
{
    const int lanes = (int)svcntw();
    const int block = 4 * lanes;
    const svbool_t pg = svptrue_b32();
    int i = 0;
    for (; ow - i >= block; i += block) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        svfloat32_t a2 = svdup_n_f32(0.0f);
        svfloat32_t a3 = svdup_n_f32(0.0f);
        svfloat32_t b0 = svdup_n_f32(0.0f);
        svfloat32_t b1 = svdup_n_f32(0.0f);
        svfloat32_t b2 = svdup_n_f32(0.0f);
        svfloat32_t b3 = svdup_n_f32(0.0f);
        /* Only the first output uses input row zero. */
        {
            const float *row = base + i;
            const float *ka = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                /* Shift only the last valid window; do not load v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
            }
        }
        /* Middle input rows serve both outputs using offset kernel rows. */
        for (int t = 1; t < kh; ++t) {
            const float *row = base + (size_t)t * stride + i;
            const float *ka = kernel + (size_t)t * kw;
            const float *kb = kernel + (size_t)(t - 1) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                /* Shift only the last valid window; do not load v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
            }
        }
        /* Only the second output uses the final input row. */
        {
            const float *row = base + (size_t)kh * stride + i;
            const float *kb = kernel + (size_t)(kh - 1) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                /* Shift only the last valid window; do not load v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
            }
        }
        svst1(pg, dst0 + i + 0 * lanes, a0);
        svst1(pg, dst0 + i + 1 * lanes, a1);
        svst1(pg, dst0 + i + 2 * lanes, a2);
        svst1(pg, dst0 + i + 3 * lanes, a3);
        svst1(pg, dst1 + i + 0 * lanes, b0);
        svst1(pg, dst1 + i + 1 * lanes, b1);
        svst1(pg, dst1 + i + 2 * lanes, b2);
        svst1(pg, dst1 + i + 3 * lanes, b3);
    }
    if (i < ow) {
        conv_sve_prefix(base + i, stride, kernel, kh, kw, dst0 + i, ow - i);
        conv_sve_prefix(base + stride + i, stride, kernel, kh, kw, dst1 + i, ow - i);
    }
}
#endif

#if CONV_CAN_DISPATCH_SVE
/* Three adjacent outputs share each common input row. Input rows are visited
 * in ascending order: output r uses kernel row t-r, so each output retains
 * exactly the original kernel-row and kernel-column accumulation order. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void conv_sve_rowtriple(const float *restrict base, size_t stride,
                               const float *restrict kernel, int kh, int kw,
                               float *restrict dst0, float *restrict dst1,
                               float *restrict dst2, int ow)
{
    /* Tiny kernels have no three-output overlap; keep the measured helpers. */
    if (kh < 3) {
        conv_sve_rowpair(base, stride, kernel, kh, kw, dst0, dst1, ow);
        conv_sve_prefix(base + 2 * stride, stride, kernel, kh, kw, dst2, ow);
        return;
    }
    const int lanes = (int)svcntw();
    const int block = 4 * lanes;
    const svbool_t pg = svptrue_b32();
    int i = 0;
    for (; ow - i >= block; i += block) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        svfloat32_t a2 = svdup_n_f32(0.0f);
        svfloat32_t a3 = svdup_n_f32(0.0f);
        svfloat32_t b0 = svdup_n_f32(0.0f);
        svfloat32_t b1 = svdup_n_f32(0.0f);
        svfloat32_t b2 = svdup_n_f32(0.0f);
        svfloat32_t b3 = svdup_n_f32(0.0f);
        svfloat32_t c0 = svdup_n_f32(0.0f);
        svfloat32_t c1 = svdup_n_f32(0.0f);
        svfloat32_t c2 = svdup_n_f32(0.0f);
        svfloat32_t c3 = svdup_n_f32(0.0f);
        /* Input row 0 contributes only to output 0. */
        {
            const float *row = base + i;
            const float *ka = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                /* Only load the final shifted valid window. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
            }
        }
        /* Input row 1 starts output 1 and advances output 0. */
        {
            const float *row = base + stride + i;
            const float *ka = kernel + kw;
            const float *kb = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                /* Only load the final shifted valid window. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
            }
        }
        /* Every middle input row advances all three outputs. */
        for (int t = 2; t < kh; ++t) {
            const float *row = base + (size_t)t * stride + i;
            const float *ka = kernel + (size_t)t * kw;
            const float *kb = kernel + (size_t)(t - 1) * kw;
            const float *kc = kernel + (size_t)(t - 2) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                /* Only load the final shifted valid window. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
            }
        }
        /* Input row kh finishes output 1 and advances output 2. */
        {
            const float *row = base + (size_t)kh * stride + i;
            const float *kb = kernel + (size_t)(kh - 1) * kw;
            const float *kc = kernel + (size_t)(kh - 2) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                /* Only load the final shifted valid window. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
            }
        }
        /* Input row kh+1 finishes output 2; widen before adding one. */
        {
            const float *row = base + ((size_t)kh + 1) * stride + i;
            const float *kc = kernel + (size_t)(kh - 1) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                /* Only load the final shifted valid window. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
            }
        }
        svst1(pg, dst0 + i + 0 * lanes, a0);
        svst1(pg, dst0 + i + 1 * lanes, a1);
        svst1(pg, dst0 + i + 2 * lanes, a2);
        svst1(pg, dst0 + i + 3 * lanes, a3);
        svst1(pg, dst1 + i + 0 * lanes, b0);
        svst1(pg, dst1 + i + 1 * lanes, b1);
        svst1(pg, dst1 + i + 2 * lanes, b2);
        svst1(pg, dst1 + i + 3 * lanes, b3);
        svst1(pg, dst2 + i + 0 * lanes, c0);
        svst1(pg, dst2 + i + 1 * lanes, c1);
        svst1(pg, dst2 + i + 2 * lanes, c2);
        svst1(pg, dst2 + i + 3 * lanes, c3);
    }
    if (i < ow) {
        conv_sve_prefix(base + i, stride, kernel, kh, kw, dst0 + i, ow - i);
        conv_sve_prefix(base + stride + i, stride, kernel, kh, kw, dst1 + i, ow - i);
        conv_sve_prefix(base + 2 * stride + i, stride, kernel, kh, kw, dst2 + i, ow - i);
    }
}
#endif

#if CONV_CAN_DISPATCH_SVE
/* Four adjacent outputs share each common input row. Output r consumes
 * kernel row t-r while t increases, preserving every output's original
 * kernel-row/column order and separate float multiplication/addition. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void conv_sve_rowquad(const float *restrict base, size_t stride,
                             const float *restrict kernel, int kh, int kw,
                             float *restrict dst0, float *restrict dst1,
                             float *restrict dst2, float *restrict dst3, int ow)
{
    /* Tiny kernels have no four-output overlap; keep the measured helpers. */
    if (kh < 4) {
        conv_sve_rowtriple(base, stride, kernel, kh, kw, dst0, dst1, dst2, ow);
        conv_sve_prefix(base + 3 * stride, stride, kernel, kh, kw, dst3, ow);
        return;
    }
    const int lanes = (int)svcntw();
    const int block = 4 * lanes;
    const svbool_t pg = svptrue_b32();
    int i = 0;
    for (; ow - i >= block; i += block) {
        svfloat32_t a0 = svdup_n_f32(0.0f);
        svfloat32_t a1 = svdup_n_f32(0.0f);
        svfloat32_t a2 = svdup_n_f32(0.0f);
        svfloat32_t a3 = svdup_n_f32(0.0f);
        svfloat32_t b0 = svdup_n_f32(0.0f);
        svfloat32_t b1 = svdup_n_f32(0.0f);
        svfloat32_t b2 = svdup_n_f32(0.0f);
        svfloat32_t b3 = svdup_n_f32(0.0f);
        svfloat32_t c0 = svdup_n_f32(0.0f);
        svfloat32_t c1 = svdup_n_f32(0.0f);
        svfloat32_t c2 = svdup_n_f32(0.0f);
        svfloat32_t c3 = svdup_n_f32(0.0f);
        svfloat32_t d0 = svdup_n_f32(0.0f);
        svfloat32_t d1 = svdup_n_f32(0.0f);
        svfloat32_t d2 = svdup_n_f32(0.0f);
        svfloat32_t d3 = svdup_n_f32(0.0f);
        /* Input row 0 starts output 0. */
        {
            const float *row = base + i;
            const float *ka = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
            }
        }
        /* Input row 1 advances output 0 and starts output 1. */
        {
            const float *row = base + stride + i;
            const float *ka = kernel + kw;
            const float *kb = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
            }
        }
        /* Input row 2 advances outputs 0/1 and starts output 2. */
        {
            const float *row = base + 2 * stride + i;
            const float *ka = kernel + (size_t)2 * kw;
            const float *kb = kernel + kw;
            const float *kc = kernel;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
            }
        }
        /* Each middle input row advances all four outputs. */
        for (int t = 3; t < kh; ++t) {
            const float *row = base + (size_t)t * stride + i;
            const float *ka = kernel + (size_t)t * kw;
            const float *kb = kernel + (size_t)(t - 1) * kw;
            const float *kc = kernel + (size_t)(t - 2) * kw;
            const float *kd = kernel + (size_t)(t - 3) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ak0 = svdup_n_f32(ka[ik]);
                const svfloat32_t ak1 = svdup_n_f32(ka[ik + 1]);
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const svfloat32_t dk0 = svdup_n_f32(kd[ik]);
                const svfloat32_t dk1 = svdup_n_f32(kd[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svld1(pg, p + 0 * lanes + 1);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak0));
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, x0, ak1));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk0));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, x0, dk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svld1(pg, p + 1 * lanes + 1);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak0));
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, x1, ak1));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk0));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, x1, dk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svld1(pg, p + 2 * lanes + 1);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak0));
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, x2, ak1));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk0));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, x2, dk1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak0));
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, x3, ak1));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk0));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, x3, dk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ak = svdup_n_f32(ka[ik]);
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t dk = svdup_n_f32(kd[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                a0 = svadd_f32_x(pg, a0, svmul_f32_x(pg, v0, ak));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                a1 = svadd_f32_x(pg, a1, svmul_f32_x(pg, v1, ak));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                a2 = svadd_f32_x(pg, a2, svmul_f32_x(pg, v2, ak));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                a3 = svadd_f32_x(pg, a3, svmul_f32_x(pg, v3, ak));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk));
            }
        }
        /* Input row kh finishes output 1 and advances outputs 2/3. */
        {
            const float *row = base + (size_t)kh * stride + i;
            const float *kb = kernel + (size_t)(kh - 1) * kw;
            const float *kc = kernel + (size_t)(kh - 2) * kw;
            const float *kd = kernel + (size_t)(kh - 3) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t bk0 = svdup_n_f32(kb[ik]);
                const svfloat32_t bk1 = svdup_n_f32(kb[ik + 1]);
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const svfloat32_t dk0 = svdup_n_f32(kd[ik]);
                const svfloat32_t dk1 = svdup_n_f32(kd[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk0));
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, x0, bk1));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk0));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, x0, dk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk0));
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, x1, bk1));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk0));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, x1, dk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk0));
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, x2, bk1));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk0));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, x2, dk1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk0));
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, x3, bk1));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk0));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, x3, dk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t bk = svdup_n_f32(kb[ik]);
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t dk = svdup_n_f32(kd[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                b0 = svadd_f32_x(pg, b0, svmul_f32_x(pg, v0, bk));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                b1 = svadd_f32_x(pg, b1, svmul_f32_x(pg, v1, bk));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                b2 = svadd_f32_x(pg, b2, svmul_f32_x(pg, v2, bk));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                b3 = svadd_f32_x(pg, b3, svmul_f32_x(pg, v3, bk));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk));
            }
        }
        /* Input row kh+1 finishes output 2 and advances output 3. */
        {
            const float *row = base + ((size_t)kh + 1) * stride + i;
            const float *kc = kernel + (size_t)(kh - 1) * kw;
            const float *kd = kernel + (size_t)(kh - 2) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t ck0 = svdup_n_f32(kc[ik]);
                const svfloat32_t ck1 = svdup_n_f32(kc[ik + 1]);
                const svfloat32_t dk0 = svdup_n_f32(kd[ik]);
                const svfloat32_t dk1 = svdup_n_f32(kd[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck0));
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, x0, ck1));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk0));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, x0, dk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck0));
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, x1, ck1));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk0));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, x1, dk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck0));
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, x2, ck1));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk0));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, x2, dk1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck0));
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, x3, ck1));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk0));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, x3, dk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t ck = svdup_n_f32(kc[ik]);
                const svfloat32_t dk = svdup_n_f32(kd[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                c0 = svadd_f32_x(pg, c0, svmul_f32_x(pg, v0, ck));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                c1 = svadd_f32_x(pg, c1, svmul_f32_x(pg, v1, ck));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                c2 = svadd_f32_x(pg, c2, svmul_f32_x(pg, v2, ck));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                c3 = svadd_f32_x(pg, c3, svmul_f32_x(pg, v3, ck));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk));
            }
        }
        /* Input row kh+2 finishes output 3; widen before adding. */
        {
            const float *row = base + ((size_t)kh + 2) * stride + i;
            const float *kd = kernel + (size_t)(kh - 1) * kw;
            int ik = 0;
            for (; ik < kw - 1; ik += 2) {
                const svfloat32_t dk0 = svdup_n_f32(kd[ik]);
                const svfloat32_t dk1 = svdup_n_f32(kd[ik + 1]);
                const float *p = row + ik;
                const svfloat32_t v0 = svld1(pg, p);
                const svfloat32_t v1 = svld1(pg, p + 1 * lanes);
                const svfloat32_t x0 = svext_f32(v0, v1, 1);
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk0));
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, x0, dk1));
                const svfloat32_t v2 = svld1(pg, p + 2 * lanes);
                const svfloat32_t x1 = svext_f32(v1, v2, 1);
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk0));
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, x1, dk1));
                const svfloat32_t v3 = svld1(pg, p + 3 * lanes);
                const svfloat32_t x2 = svext_f32(v2, v3, 1);
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk0));
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, x2, dk1));
                /* Load only the final shifted window, not a whole v4. */
                const svfloat32_t x3 = svld1(pg, p + 3 * lanes + 1);
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk0));
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, x3, dk1));
            }
            for (; ik < kw; ++ik) {
                const svfloat32_t dk = svdup_n_f32(kd[ik]);
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                d0 = svadd_f32_x(pg, d0, svmul_f32_x(pg, v0, dk));
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                d1 = svadd_f32_x(pg, d1, svmul_f32_x(pg, v1, dk));
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                d2 = svadd_f32_x(pg, d2, svmul_f32_x(pg, v2, dk));
                const svfloat32_t v3 = svld1(pg, row + ik + 3 * lanes);
                d3 = svadd_f32_x(pg, d3, svmul_f32_x(pg, v3, dk));
            }
        }
        svst1(pg, dst0 + i + 0 * lanes, a0);
        svst1(pg, dst0 + i + 1 * lanes, a1);
        svst1(pg, dst0 + i + 2 * lanes, a2);
        svst1(pg, dst0 + i + 3 * lanes, a3);
        svst1(pg, dst1 + i + 0 * lanes, b0);
        svst1(pg, dst1 + i + 1 * lanes, b1);
        svst1(pg, dst1 + i + 2 * lanes, b2);
        svst1(pg, dst1 + i + 3 * lanes, b3);
        svst1(pg, dst2 + i + 0 * lanes, c0);
        svst1(pg, dst2 + i + 1 * lanes, c1);
        svst1(pg, dst2 + i + 2 * lanes, c2);
        svst1(pg, dst2 + i + 3 * lanes, c3);
        svst1(pg, dst3 + i + 0 * lanes, d0);
        svst1(pg, dst3 + i + 1 * lanes, d1);
        svst1(pg, dst3 + i + 2 * lanes, d2);
        svst1(pg, dst3 + i + 3 * lanes, d3);
    }
    if (i < ow) {
        conv_sve_rowtriple(base + i, stride, kernel, kh, kw,
                           dst0 + i, dst1 + i, dst2 + i, ow - i);
        conv_sve_prefix(base + 3 * stride + i, stride, kernel, kh, kw, dst3 + i, ow - i);
    }
}
#endif

void conv2d(const CONVFLOAT *input, CONVINT inputHeight, CONVINT inputWidth,
            const CONVFLOAT *kernel, CONVINT kernelHeight, CONVINT kernelWidth,
            CONVFLOAT *output)
{
    /*
     * 在减法之前检查尺寸，避免负 kernel 或极端 int 参数引起有符号溢出。
     * 合法调用仍须提供有效指针和足够的存储空间，接口没有缓冲区长度参数。
     */
    if (kernelHeight <= 0 || kernelWidth <= 0 ||
        inputHeight < kernelHeight || inputWidth < kernelWidth) {
        return;
    }
    const int oh = inputHeight - kernelHeight + 1;
    const int ow = inputWidth - kernelWidth + 1;
    const size_t stride = (size_t)inputWidth;
#if CONV_CAN_DISPATCH_SVE
    const int use_sve = (getauxval(AT_HWCAP) & HWCAP_SVE) != 0;
    if (use_sve) {
        const float *sve_input = input;
        size_t sve_stride = stride;
        float *input_copy = NULL;
        /* 16 floats / 64 bytes is an experiment parameter, not cache geometry.
         * The same padded allocation and gate are used by the copy control. */
        if (kernelHeight >= 4 && oh >= 4 && inputWidth >= 64 &&
            stride <= SIZE_MAX - (size_t)15) {
            const size_t height = (size_t)inputHeight;
            size_t padded_lines = (stride + (size_t)15) / (size_t)16;
            padded_lines |= (size_t)1;
            if (padded_lines <= SIZE_MAX / (size_t)16) {
                const size_t padded_stride = padded_lines * (size_t)16;
                if (padded_stride != stride &&
                    stride <= SIZE_MAX / sizeof(float) &&
                    height <= SIZE_MAX / padded_stride) {
                    const size_t copy_elements = height * padded_stride;
                    if (copy_elements <= SIZE_MAX / sizeof(float)) {
                        const size_t allocation_bytes = copy_elements * sizeof(float);
                        const size_t copy_limit_bytes = (size_t)536870912;
                        if (allocation_bytes <= copy_limit_bytes) {
                            input_copy = malloc(allocation_bytes);
                            if (input_copy != NULL) {
                                const size_t copy_stride = stride;
                                const size_t row_bytes = stride * sizeof(float);
#pragma omp parallel for schedule(static)
                                for (int copy_row = 0; copy_row < inputHeight; ++copy_row) {
                                    memcpy(input_copy + (size_t)copy_row * copy_stride,
                                           input + (size_t)copy_row * stride, row_bytes);
                                }
                                /* The copy loop's implicit barrier precedes compute. */
                                sve_input = input_copy;
                                sve_stride = copy_stride;
                            }
                        }
                    }
                }
            }
        }
        /* Avoid oh+3 and j+3: each group starts at a valid output row. */
        const int groups = oh / 4 + (oh % 4 != 0);
#pragma omp parallel for schedule(static)
        for (int group = 0; group < groups; ++group) {
            const int j = group * 4;
            const int remaining = oh - j;
            const float *base = sve_input + (size_t)j * sve_stride;
            float *dst = output + (size_t)j * (size_t)ow;
            if (remaining >= 4) {
                conv_sve_rowquad(base, sve_stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + ow, dst + (size_t)2 * ow,
                                 dst + (size_t)3 * ow, ow);
            } else if (remaining == 3) {
                conv_sve_rowtriple(base, sve_stride, kernel, kernelHeight, kernelWidth,
                                   dst, dst + ow, dst + (size_t)2 * ow, ow);
            } else if (remaining == 2) {
                conv_sve_rowpair(base, sve_stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + ow, ow);
            } else {
                conv_sve_prefix(base, sve_stride, kernel, kernelHeight,
                                kernelWidth, dst, ow);
            }
        }
        if (input_copy != NULL) free(input_copy);
        return;
    }
#endif

    /*
     * 每行工作量相同，静态划分使线程写连续区域。acc 是线程局部变量；
     * 不需要原子操作、跨线程 reduction 或计时区内的 malloc。
     * 官方尺寸有足够多的输出行，暂不增加 collapse 和动态调度。
     */
#pragma omp parallel for schedule(static)
    for (int j = 0; j < oh; ++j) {
        const float *base = input + (size_t)j * stride;
        float *dst = output + (size_t)j * (size_t)ow;
        int i = 0;
#if CONV_CAN_DISPATCH_SVE
        if (use_sve) {
            i = conv_sve_prefix(base, stride, kernel, kernelHeight,
                                kernelWidth, dst, ow);
        }
#endif

        /*
         * ow-i >= B 等价于 i+B <= ow，但不会让 i+B 溢出。
         * 输入最后一列：i+N-1+kw-1 <= inputWidth-1。
         * 两步展开仅在 ik+1 < kw 时进入，因此 window[b+1] 也满足边界。
         * jk 最大为 kh-1，最后输入行 j+kh-1 <= inputHeight-1。
         */
        for (; ow - i >= CONV_BLOCK; i += CONV_BLOCK) {
            conv_tile_main(base + i, stride, kernel,
                           kernelHeight, kernelWidth, dst + i);
        }

        /*
         * 例：尾部 27 个输出拆成 16+8+2+1；12 个拆成 8+4。
         * 每块都拥有编译期固定的 acc 和 b 循环，没有运行时长度的累加循环。
         * 16 用 while，兼容大于 32 的自定义主块；后续各块最多执行一次。
         * 代价：多次遍历 kernel 和更大的机器代码，实际收益仍须实测。
         * 所有分支只看剩余宽度，不识别公开 testcase。
         */
        while (ow - i >= 16) {
            conv_tile_16(base + i, stride, kernel, kernelHeight, kernelWidth, dst + i);
            i += 16;
        }
        if (ow - i >= 8) {
            conv_tile_8(base + i, stride, kernel, kernelHeight, kernelWidth, dst + i);
            i += 8;
        }
        if (ow - i >= 4) {
            conv_tile_4(base + i, stride, kernel, kernelHeight, kernelWidth, dst + i);
            i += 4;
        }
        if (ow - i >= 2) {
            conv_tile_2(base + i, stride, kernel, kernelHeight, kernelWidth, dst + i);
            i += 2;
        }
        if (i < ow) {
            conv_tile_1(base + i, stride, kernel, kernelHeight, kernelWidth, dst + i);
        }
    }
}
