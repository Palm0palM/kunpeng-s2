#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <omp.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif
#if defined(__linux__) && defined(__aarch64__) && defined(__GNUC__) && \
    __GNUC__ >= 10 && !defined(__clang__)
#include <arm_sve.h>
#include <sys/auxv.h>
#include <asm/hwcap.h>
#define TRSM_CAN_DISPATCH_SVE 1
#else
#define TRSM_CAN_DISPATCH_SVE 0
#endif
enum { RHS = 8, ROWS = 4 };
/* L X = B，按 RHS 列独立分配线程；每线程把右端项打包为窄面板。
 * 同时累计 ROWS 行对已解部分的贡献，复用 X[k,:] 的加载。
 * 小对角块内部仍按前代顺序逐行求解。只读 L，原地输出 B。
 */
#if defined(__aarch64__)
static inline void panel_sums(int start,int lda,const double *L,const double *x,double *s)
{
    float64x2_t s0_0=vdupq_n_f64(0);
    float64x2_t s0_2=vdupq_n_f64(0);
    float64x2_t s0_4=vdupq_n_f64(0);
    float64x2_t s0_6=vdupq_n_f64(0);
    float64x2_t s1_0=vdupq_n_f64(0);
    float64x2_t s1_2=vdupq_n_f64(0);
    float64x2_t s1_4=vdupq_n_f64(0);
    float64x2_t s1_6=vdupq_n_f64(0);
    float64x2_t s2_0=vdupq_n_f64(0);
    float64x2_t s2_2=vdupq_n_f64(0);
    float64x2_t s2_4=vdupq_n_f64(0);
    float64x2_t s2_6=vdupq_n_f64(0);
    float64x2_t s3_0=vdupq_n_f64(0);
    float64x2_t s3_2=vdupq_n_f64(0);
    float64x2_t s3_4=vdupq_n_f64(0);
    float64x2_t s3_6=vdupq_n_f64(0);
    for(int k=0;k<start;++k) {
        float64x2_t b0=vld1q_f64(x+(size_t)k*RHS+0);
        float64x2_t b2=vld1q_f64(x+(size_t)k*RHS+2);
        float64x2_t b4=vld1q_f64(x+(size_t)k*RHS+4);
        float64x2_t b6=vld1q_f64(x+(size_t)k*RHS+6);
        { double a=L[(size_t)0*lda+k];
            s0_0=vfmaq_n_f64(s0_0,b0,a);
            s0_2=vfmaq_n_f64(s0_2,b2,a);
            s0_4=vfmaq_n_f64(s0_4,b4,a);
            s0_6=vfmaq_n_f64(s0_6,b6,a);
        }
        { double a=L[(size_t)1*lda+k];
            s1_0=vfmaq_n_f64(s1_0,b0,a);
            s1_2=vfmaq_n_f64(s1_2,b2,a);
            s1_4=vfmaq_n_f64(s1_4,b4,a);
            s1_6=vfmaq_n_f64(s1_6,b6,a);
        }
        { double a=L[(size_t)2*lda+k];
            s2_0=vfmaq_n_f64(s2_0,b0,a);
            s2_2=vfmaq_n_f64(s2_2,b2,a);
            s2_4=vfmaq_n_f64(s2_4,b4,a);
            s2_6=vfmaq_n_f64(s2_6,b6,a);
        }
        { double a=L[(size_t)3*lda+k];
            s3_0=vfmaq_n_f64(s3_0,b0,a);
            s3_2=vfmaq_n_f64(s3_2,b2,a);
            s3_4=vfmaq_n_f64(s3_4,b4,a);
            s3_6=vfmaq_n_f64(s3_6,b6,a);
        }
    }
    vst1q_f64(s+0*RHS+0,s0_0);
    vst1q_f64(s+0*RHS+2,s0_2);
    vst1q_f64(s+0*RHS+4,s0_4);
    vst1q_f64(s+0*RHS+6,s0_6);
    vst1q_f64(s+1*RHS+0,s1_0);
    vst1q_f64(s+1*RHS+2,s1_2);
    vst1q_f64(s+1*RHS+4,s1_4);
    vst1q_f64(s+1*RHS+6,s1_6);
    vst1q_f64(s+2*RHS+0,s2_0);
    vst1q_f64(s+2*RHS+2,s2_2);
    vst1q_f64(s+2*RHS+4,s2_4);
    vst1q_f64(s+2*RHS+6,s2_6);
    vst1q_f64(s+3*RHS+0,s3_0);
    vst1q_f64(s+3*RHS+2,s3_2);
    vst1q_f64(s+3*RHS+4,s3_4);
    vst1q_f64(s+3*RHS+6,s3_6);
}
#endif
#if TRSM_CAN_DISPATCH_SVE
/* The existing thread-width helper is defined with the large update kernels. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static int trsm_sve_has_eight_doubles(void);

/* Solve sixteen independent row dot products together, reusing each X load.
 * L points at the first output row and column zero; x keeps its original
 * row-zero origin. Each lane accumulates k in increasing order, including
 * the ordered within-block forward substitution below. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void solve16x8_panel_sve(int start,int lda,const double *L,double *x)
{
    svbool_t pg=svptrue_b64();
    svfloat64_t a0=svdup_n_f64(0);
    svfloat64_t a1=svdup_n_f64(0);
    svfloat64_t a2=svdup_n_f64(0);
    svfloat64_t a3=svdup_n_f64(0);
    svfloat64_t a4=svdup_n_f64(0);
    svfloat64_t a5=svdup_n_f64(0);
    svfloat64_t a6=svdup_n_f64(0);
    svfloat64_t a7=svdup_n_f64(0);
    svfloat64_t a8=svdup_n_f64(0);
    svfloat64_t a9=svdup_n_f64(0);
    svfloat64_t a10=svdup_n_f64(0);
    svfloat64_t a11=svdup_n_f64(0);
    svfloat64_t a12=svdup_n_f64(0);
    svfloat64_t a13=svdup_n_f64(0);
    svfloat64_t a14=svdup_n_f64(0);
    svfloat64_t a15=svdup_n_f64(0);
    for(int k=0;k<start;++k) {
        svfloat64_t previous=svld1_f64(pg,x+(size_t)k*RHS);
        a0=svmla_n_f64_x(pg,a0,previous,L[(size_t)0*lda+k]);
        a1=svmla_n_f64_x(pg,a1,previous,L[(size_t)1*lda+k]);
        a2=svmla_n_f64_x(pg,a2,previous,L[(size_t)2*lda+k]);
        a3=svmla_n_f64_x(pg,a3,previous,L[(size_t)3*lda+k]);
        a4=svmla_n_f64_x(pg,a4,previous,L[(size_t)4*lda+k]);
        a5=svmla_n_f64_x(pg,a5,previous,L[(size_t)5*lda+k]);
        a6=svmla_n_f64_x(pg,a6,previous,L[(size_t)6*lda+k]);
        a7=svmla_n_f64_x(pg,a7,previous,L[(size_t)7*lda+k]);
        a8=svmla_n_f64_x(pg,a8,previous,L[(size_t)8*lda+k]);
        a9=svmla_n_f64_x(pg,a9,previous,L[(size_t)9*lda+k]);
        a10=svmla_n_f64_x(pg,a10,previous,L[(size_t)10*lda+k]);
        a11=svmla_n_f64_x(pg,a11,previous,L[(size_t)11*lda+k]);
        a12=svmla_n_f64_x(pg,a12,previous,L[(size_t)12*lda+k]);
        a13=svmla_n_f64_x(pg,a13,previous,L[(size_t)13*lda+k]);
        a14=svmla_n_f64_x(pg,a14,previous,L[(size_t)14*lda+k]);
        a15=svmla_n_f64_x(pg,a15,previous,L[(size_t)15*lda+k]);
    }
    /* A solved row is immediately visible to every later row's FMA chain. */
    svfloat64_t solved;
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+0)*RHS),a0),
        svdup_n_f64(L[(size_t)0*lda+start+0]));
    svst1_f64(pg,x+(size_t)(start+0)*RHS,solved);
    a1=svmla_n_f64_x(pg,a1,solved,L[(size_t)1*lda+start+0]);
    a2=svmla_n_f64_x(pg,a2,solved,L[(size_t)2*lda+start+0]);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+0]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+0]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+0]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+0]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+0]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+0]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+0]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+0]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+0]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+0]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+0]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+0]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+0]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+1)*RHS),a1),
        svdup_n_f64(L[(size_t)1*lda+start+1]));
    svst1_f64(pg,x+(size_t)(start+1)*RHS,solved);
    a2=svmla_n_f64_x(pg,a2,solved,L[(size_t)2*lda+start+1]);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+1]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+1]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+1]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+1]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+1]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+1]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+1]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+1]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+1]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+1]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+1]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+1]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+1]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+2)*RHS),a2),
        svdup_n_f64(L[(size_t)2*lda+start+2]));
    svst1_f64(pg,x+(size_t)(start+2)*RHS,solved);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+2]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+2]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+2]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+2]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+2]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+2]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+2]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+2]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+2]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+2]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+2]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+2]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+2]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+3)*RHS),a3),
        svdup_n_f64(L[(size_t)3*lda+start+3]));
    svst1_f64(pg,x+(size_t)(start+3)*RHS,solved);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+3]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+3]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+3]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+3]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+3]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+3]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+3]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+3]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+3]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+3]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+3]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+3]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+4)*RHS),a4),
        svdup_n_f64(L[(size_t)4*lda+start+4]));
    svst1_f64(pg,x+(size_t)(start+4)*RHS,solved);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+4]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+4]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+4]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+4]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+4]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+4]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+4]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+4]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+4]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+4]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+4]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+5)*RHS),a5),
        svdup_n_f64(L[(size_t)5*lda+start+5]));
    svst1_f64(pg,x+(size_t)(start+5)*RHS,solved);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+5]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+5]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+5]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+5]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+5]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+5]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+5]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+5]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+5]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+5]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+6)*RHS),a6),
        svdup_n_f64(L[(size_t)6*lda+start+6]));
    svst1_f64(pg,x+(size_t)(start+6)*RHS,solved);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+6]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+6]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+6]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+6]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+6]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+6]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+6]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+6]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+6]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+7)*RHS),a7),
        svdup_n_f64(L[(size_t)7*lda+start+7]));
    svst1_f64(pg,x+(size_t)(start+7)*RHS,solved);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+7]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+7]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+7]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+7]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+7]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+7]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+7]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+7]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+8)*RHS),a8),
        svdup_n_f64(L[(size_t)8*lda+start+8]));
    svst1_f64(pg,x+(size_t)(start+8)*RHS,solved);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+8]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+8]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+8]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+8]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+8]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+8]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+8]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+9)*RHS),a9),
        svdup_n_f64(L[(size_t)9*lda+start+9]));
    svst1_f64(pg,x+(size_t)(start+9)*RHS,solved);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+9]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+9]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+9]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+9]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+9]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+9]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+10)*RHS),a10),
        svdup_n_f64(L[(size_t)10*lda+start+10]));
    svst1_f64(pg,x+(size_t)(start+10)*RHS,solved);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+10]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+10]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+10]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+10]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+10]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+11)*RHS),a11),
        svdup_n_f64(L[(size_t)11*lda+start+11]));
    svst1_f64(pg,x+(size_t)(start+11)*RHS,solved);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+11]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+11]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+11]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+11]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+12)*RHS),a12),
        svdup_n_f64(L[(size_t)12*lda+start+12]));
    svst1_f64(pg,x+(size_t)(start+12)*RHS,solved);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+12]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+12]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+12]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+13)*RHS),a13),
        svdup_n_f64(L[(size_t)13*lda+start+13]));
    svst1_f64(pg,x+(size_t)(start+13)*RHS,solved);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+13]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+13]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+14)*RHS),a14),
        svdup_n_f64(L[(size_t)14*lda+start+14]));
    svst1_f64(pg,x+(size_t)(start+14)*RHS,solved);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+14]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+15)*RHS),a15),
        svdup_n_f64(L[(size_t)15*lda+start+15]));
    svst1_f64(pg,x+(size_t)(start+15)*RHS,solved);
}

/* packed_history points at this block's k-major 16-row history. Only the
 * k<start coefficients use the shared layout; the ordered within-block
 * substitution and diagonal reads are identical to solve16x8_panel_sve. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void solve16x8_panel_packedL_sve(int start,int lda,const double *L,double *x,
                                         const double *packed_history)
{
    svbool_t pg=svptrue_b64();
    svfloat64_t a0=svdup_n_f64(0);
    svfloat64_t a1=svdup_n_f64(0);
    svfloat64_t a2=svdup_n_f64(0);
    svfloat64_t a3=svdup_n_f64(0);
    svfloat64_t a4=svdup_n_f64(0);
    svfloat64_t a5=svdup_n_f64(0);
    svfloat64_t a6=svdup_n_f64(0);
    svfloat64_t a7=svdup_n_f64(0);
    svfloat64_t a8=svdup_n_f64(0);
    svfloat64_t a9=svdup_n_f64(0);
    svfloat64_t a10=svdup_n_f64(0);
    svfloat64_t a11=svdup_n_f64(0);
    svfloat64_t a12=svdup_n_f64(0);
    svfloat64_t a13=svdup_n_f64(0);
    svfloat64_t a14=svdup_n_f64(0);
    svfloat64_t a15=svdup_n_f64(0);
    for(int k=0;k<start;++k) {
        svfloat64_t previous=svld1_f64(pg,x+(size_t)k*RHS);
        a0=svmla_n_f64_x(pg,a0,previous,packed_history[(size_t)k*16+0]);
        a1=svmla_n_f64_x(pg,a1,previous,packed_history[(size_t)k*16+1]);
        a2=svmla_n_f64_x(pg,a2,previous,packed_history[(size_t)k*16+2]);
        a3=svmla_n_f64_x(pg,a3,previous,packed_history[(size_t)k*16+3]);
        /* Keep each four-row FMA group before later coefficient loads,
         * avoiding sixteen simultaneously live broadcasts. */
        __asm__ __volatile__("" : "+w"(a0), "+w"(a1), "+w"(a2), "+w"(a3) : : "memory");
        a4=svmla_n_f64_x(pg,a4,previous,packed_history[(size_t)k*16+4]);
        a5=svmla_n_f64_x(pg,a5,previous,packed_history[(size_t)k*16+5]);
        a6=svmla_n_f64_x(pg,a6,previous,packed_history[(size_t)k*16+6]);
        a7=svmla_n_f64_x(pg,a7,previous,packed_history[(size_t)k*16+7]);
        __asm__ __volatile__("" : "+w"(a4), "+w"(a5), "+w"(a6), "+w"(a7) : : "memory");
        a8=svmla_n_f64_x(pg,a8,previous,packed_history[(size_t)k*16+8]);
        a9=svmla_n_f64_x(pg,a9,previous,packed_history[(size_t)k*16+9]);
        a10=svmla_n_f64_x(pg,a10,previous,packed_history[(size_t)k*16+10]);
        a11=svmla_n_f64_x(pg,a11,previous,packed_history[(size_t)k*16+11]);
        __asm__ __volatile__("" : "+w"(a8), "+w"(a9), "+w"(a10), "+w"(a11) : : "memory");
        a12=svmla_n_f64_x(pg,a12,previous,packed_history[(size_t)k*16+12]);
        a13=svmla_n_f64_x(pg,a13,previous,packed_history[(size_t)k*16+13]);
        a14=svmla_n_f64_x(pg,a14,previous,packed_history[(size_t)k*16+14]);
        a15=svmla_n_f64_x(pg,a15,previous,packed_history[(size_t)k*16+15]);
    }
    /* A solved row is immediately visible to every later row's FMA chain. */
    svfloat64_t solved;
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+0)*RHS),a0),
        svdup_n_f64(L[(size_t)0*lda+start+0]));
    svst1_f64(pg,x+(size_t)(start+0)*RHS,solved);
    a1=svmla_n_f64_x(pg,a1,solved,L[(size_t)1*lda+start+0]);
    a2=svmla_n_f64_x(pg,a2,solved,L[(size_t)2*lda+start+0]);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+0]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+0]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+0]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+0]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+0]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+0]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+0]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+0]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+0]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+0]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+0]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+0]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+0]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+1)*RHS),a1),
        svdup_n_f64(L[(size_t)1*lda+start+1]));
    svst1_f64(pg,x+(size_t)(start+1)*RHS,solved);
    a2=svmla_n_f64_x(pg,a2,solved,L[(size_t)2*lda+start+1]);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+1]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+1]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+1]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+1]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+1]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+1]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+1]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+1]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+1]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+1]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+1]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+1]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+1]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+2)*RHS),a2),
        svdup_n_f64(L[(size_t)2*lda+start+2]));
    svst1_f64(pg,x+(size_t)(start+2)*RHS,solved);
    a3=svmla_n_f64_x(pg,a3,solved,L[(size_t)3*lda+start+2]);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+2]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+2]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+2]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+2]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+2]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+2]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+2]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+2]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+2]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+2]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+2]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+2]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+3)*RHS),a3),
        svdup_n_f64(L[(size_t)3*lda+start+3]));
    svst1_f64(pg,x+(size_t)(start+3)*RHS,solved);
    a4=svmla_n_f64_x(pg,a4,solved,L[(size_t)4*lda+start+3]);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+3]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+3]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+3]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+3]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+3]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+3]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+3]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+3]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+3]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+3]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+3]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+4)*RHS),a4),
        svdup_n_f64(L[(size_t)4*lda+start+4]));
    svst1_f64(pg,x+(size_t)(start+4)*RHS,solved);
    a5=svmla_n_f64_x(pg,a5,solved,L[(size_t)5*lda+start+4]);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+4]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+4]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+4]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+4]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+4]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+4]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+4]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+4]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+4]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+4]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+5)*RHS),a5),
        svdup_n_f64(L[(size_t)5*lda+start+5]));
    svst1_f64(pg,x+(size_t)(start+5)*RHS,solved);
    a6=svmla_n_f64_x(pg,a6,solved,L[(size_t)6*lda+start+5]);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+5]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+5]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+5]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+5]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+5]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+5]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+5]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+5]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+5]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+6)*RHS),a6),
        svdup_n_f64(L[(size_t)6*lda+start+6]));
    svst1_f64(pg,x+(size_t)(start+6)*RHS,solved);
    a7=svmla_n_f64_x(pg,a7,solved,L[(size_t)7*lda+start+6]);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+6]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+6]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+6]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+6]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+6]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+6]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+6]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+6]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+7)*RHS),a7),
        svdup_n_f64(L[(size_t)7*lda+start+7]));
    svst1_f64(pg,x+(size_t)(start+7)*RHS,solved);
    a8=svmla_n_f64_x(pg,a8,solved,L[(size_t)8*lda+start+7]);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+7]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+7]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+7]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+7]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+7]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+7]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+7]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+8)*RHS),a8),
        svdup_n_f64(L[(size_t)8*lda+start+8]));
    svst1_f64(pg,x+(size_t)(start+8)*RHS,solved);
    a9=svmla_n_f64_x(pg,a9,solved,L[(size_t)9*lda+start+8]);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+8]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+8]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+8]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+8]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+8]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+8]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+9)*RHS),a9),
        svdup_n_f64(L[(size_t)9*lda+start+9]));
    svst1_f64(pg,x+(size_t)(start+9)*RHS,solved);
    a10=svmla_n_f64_x(pg,a10,solved,L[(size_t)10*lda+start+9]);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+9]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+9]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+9]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+9]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+9]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+10)*RHS),a10),
        svdup_n_f64(L[(size_t)10*lda+start+10]));
    svst1_f64(pg,x+(size_t)(start+10)*RHS,solved);
    a11=svmla_n_f64_x(pg,a11,solved,L[(size_t)11*lda+start+10]);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+10]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+10]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+10]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+10]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+11)*RHS),a11),
        svdup_n_f64(L[(size_t)11*lda+start+11]));
    svst1_f64(pg,x+(size_t)(start+11)*RHS,solved);
    a12=svmla_n_f64_x(pg,a12,solved,L[(size_t)12*lda+start+11]);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+11]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+11]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+11]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+12)*RHS),a12),
        svdup_n_f64(L[(size_t)12*lda+start+12]));
    svst1_f64(pg,x+(size_t)(start+12)*RHS,solved);
    a13=svmla_n_f64_x(pg,a13,solved,L[(size_t)13*lda+start+12]);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+12]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+12]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+13)*RHS),a13),
        svdup_n_f64(L[(size_t)13*lda+start+13]));
    svst1_f64(pg,x+(size_t)(start+13)*RHS,solved);
    a14=svmla_n_f64_x(pg,a14,solved,L[(size_t)14*lda+start+13]);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+13]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+14)*RHS),a14),
        svdup_n_f64(L[(size_t)14*lda+start+14]));
    svst1_f64(pg,x+(size_t)(start+14)*RHS,solved);
    a15=svmla_n_f64_x(pg,a15,solved,L[(size_t)15*lda+start+14]);
    solved=svdiv_f64_x(pg,
        svsub_f64_x(pg,svld1_f64(pg,x+(size_t)(start+15)*RHS),a15),
        svdup_n_f64(L[(size_t)15*lda+start+15]));
    svst1_f64(pg,x+(size_t)(start+15)*RHS,solved);
}
#endif
static void solve_panel(int m,int n,const double *L,int lda,double *B,int ldb)
{
    if(m<=0 || n<=0) return;
#if TRSM_CAN_DISPATCH_SVE
    const int have_sve=(getauxval(AT_HWCAP)&HWCAP_SVE)!=0;
    const int full_blocks=m/16;
    double *packed_history=NULL;
    /* Block b has 16*(16*b) history entries; their prefix is
     * 128*b*(b-1). Guard both the pair product and its byte conversion. */
    if(have_sve && full_blocks>=2) {
        const size_t blocks=(size_t)full_blocks;
        if(blocks<=SIZE_MAX/(blocks-1)) {
            const size_t pairs=blocks*(blocks-1);
            if(pairs<=SIZE_MAX/(128*sizeof(double))) {
                const size_t bytes=pairs*(128*sizeof(double));
                if(posix_memalign((void**)&packed_history,64,bytes)!=0)
                    packed_history=NULL;
            }
        }
    }
#endif
#pragma omp parallel
    {
#if TRSM_CAN_DISPATCH_SVE
        /* This condition is shared and precedes any worker allocation or
         * fallback. Every worker reaches the packing loop's barrier. */
        if(packed_history) {
#pragma omp for schedule(static)
            for(int block=1;block<full_blocks;++block) {
                const int start=16*block;
                const size_t b=(size_t)block;
                double *dst=packed_history+(size_t)128*b*(b-1);
                for(int k=0;k<start;++k)
                    for(int r=0;r<16;++r)
                        dst[(size_t)k*16+r]=L[(size_t)(start+r)*lda+k];
            }
        }
        const int use_sve=have_sve && trsm_sve_has_eight_doubles();
#endif
        double *x=NULL;
        if(posix_memalign((void**)&x,64,(size_t)m*RHS*sizeof(double))!=0) x=NULL;
#pragma omp for schedule(static)
        for(int jb=0;jb<n;jb+=RHS) {
            int w=n-jb<RHS?n-jb:RHS;
            if(!x) {
                for(int j=jb;j<jb+w;++j)for(int i=0;i<m;++i) {
                    double s=0;for(int k=0;k<i;++k)s+=L[(size_t)i*lda+k]*B[(size_t)k*ldb+j];
                    B[(size_t)i*ldb+j]=(B[(size_t)i*ldb+j]-s)/L[(size_t)i*lda+i];
                }
                continue;
            }
            for(int i=0;i<m;++i) {
                for(int j=0;j<w;++j)x[(size_t)i*RHS+j]=B[(size_t)i*ldb+jb+j];
                for(int j=w;j<RHS;++j)x[(size_t)i*RHS+j]=0;
            }
            int first_row=0;
#if TRSM_CAN_DISPATCH_SVE
            if(use_sve) {
                for(;m-first_row>=16;first_row+=16) {
                    if(packed_history && first_row!=0) {
                        const size_t block=(size_t)first_row/16;
                        const double *history=packed_history+(size_t)128*block*(block-1);
                        solve16x8_panel_packedL_sve(first_row,lda,L+(size_t)first_row*lda,x,history);
                    } else {
                        /* The first block has no history; allocation failure
                         * also keeps the original T8 coefficient loads. */
                        solve16x8_panel_sve(first_row,lda,L+(size_t)first_row*lda,x);
                    }
                }
            }
#endif
            for(int ii=first_row;ii<m;ii+=ROWS) {
                int h=m-ii<ROWS?m-ii:ROWS;
                double sums[ROWS*RHS]={0};
#if defined(__aarch64__)
                if(h==ROWS)panel_sums(ii,lda,L+(size_t)ii*lda,x,sums);
                else
#endif
                {
                    for(int k=0;k<ii;++k)for(int r=0;r<h;++r) {
                        double a=L[(size_t)(ii+r)*lda+k];
#pragma omp simd
                        for(int j=0;j<RHS;++j)sums[r*RHS+j]+=a*x[(size_t)k*RHS+j];
                    }
                }
                for(int r=0;r<h;++r) {
                    double *row=x+(size_t)(ii+r)*RHS;
                    // 已累计 k<ii；接着按顺序纳入当前小块内的已解行。
                    for(int q=0;q<r;++q) {
                        double a=L[(size_t)(ii+r)*lda+ii+q];
#pragma omp simd
                        for(int j=0;j<RHS;++j)sums[r*RHS+j]+=a*x[(size_t)(ii+q)*RHS+j];
                    }
                    double diag=L[(size_t)(ii+r)*lda+ii+r];
#pragma omp simd
                    for(int j=0;j<RHS;++j)row[j]=(row[j]-sums[r*RHS+j])/diag;
                }
            }
            for(int i=0;i<m;++i)for(int j=0;j<w;++j)B[(size_t)i*ldb+jb+j]=x[(size_t)i*RHS+j];
        }
        free(x);
    }
#if TRSM_CAN_DISPATCH_SVE
    free(packed_history);
#endif
}

#include <stddef.h>
#include <omp.h>
#if defined(__aarch64__)
#include <arm_neon.h>
#endif
enum { KB = 256, CT = 64 };
/* 分块前代：先求一个小对角块，再用矩阵乘更新下面的全部右端项。
 * 每一步 omp for 的 barrier 保证依赖完成；线程只写自己负责的矩形。
 * 更新改变浮点分组顺序，必须以官方 1e-12 容差验证。
 */
#if defined(__aarch64__)
static inline void update4x8(int count,const double *L,int lda,const double *X,int ldx,double *C,int ldc)
{
    float64x2_t a0_0=vdupq_n_f64(0);
    float64x2_t a0_2=vdupq_n_f64(0);
    float64x2_t a0_4=vdupq_n_f64(0);
    float64x2_t a0_6=vdupq_n_f64(0);
    float64x2_t a1_0=vdupq_n_f64(0);
    float64x2_t a1_2=vdupq_n_f64(0);
    float64x2_t a1_4=vdupq_n_f64(0);
    float64x2_t a1_6=vdupq_n_f64(0);
    float64x2_t a2_0=vdupq_n_f64(0);
    float64x2_t a2_2=vdupq_n_f64(0);
    float64x2_t a2_4=vdupq_n_f64(0);
    float64x2_t a2_6=vdupq_n_f64(0);
    float64x2_t a3_0=vdupq_n_f64(0);
    float64x2_t a3_2=vdupq_n_f64(0);
    float64x2_t a3_4=vdupq_n_f64(0);
    float64x2_t a3_6=vdupq_n_f64(0);
    for(int k=0;k<count;++k) {
        float64x2_t b0=vld1q_f64(X+(size_t)k*ldx+0);
        float64x2_t b2=vld1q_f64(X+(size_t)k*ldx+2);
        float64x2_t b4=vld1q_f64(X+(size_t)k*ldx+4);
        float64x2_t b6=vld1q_f64(X+(size_t)k*ldx+6);
        { double l=L[(size_t)0*lda+k];
            a0_0=vfmaq_n_f64(a0_0,b0,l);
            a0_2=vfmaq_n_f64(a0_2,b2,l);
            a0_4=vfmaq_n_f64(a0_4,b4,l);
            a0_6=vfmaq_n_f64(a0_6,b6,l);
        }
        { double l=L[(size_t)1*lda+k];
            a1_0=vfmaq_n_f64(a1_0,b0,l);
            a1_2=vfmaq_n_f64(a1_2,b2,l);
            a1_4=vfmaq_n_f64(a1_4,b4,l);
            a1_6=vfmaq_n_f64(a1_6,b6,l);
        }
        { double l=L[(size_t)2*lda+k];
            a2_0=vfmaq_n_f64(a2_0,b0,l);
            a2_2=vfmaq_n_f64(a2_2,b2,l);
            a2_4=vfmaq_n_f64(a2_4,b4,l);
            a2_6=vfmaq_n_f64(a2_6,b6,l);
        }
        { double l=L[(size_t)3*lda+k];
            a3_0=vfmaq_n_f64(a3_0,b0,l);
            a3_2=vfmaq_n_f64(a3_2,b2,l);
            a3_4=vfmaq_n_f64(a3_4,b4,l);
            a3_6=vfmaq_n_f64(a3_6,b6,l);
        }
    }
    vst1q_f64(C+(size_t)0*ldc+0,vsubq_f64(vld1q_f64(C+(size_t)0*ldc+0),a0_0));
    vst1q_f64(C+(size_t)0*ldc+2,vsubq_f64(vld1q_f64(C+(size_t)0*ldc+2),a0_2));
    vst1q_f64(C+(size_t)0*ldc+4,vsubq_f64(vld1q_f64(C+(size_t)0*ldc+4),a0_4));
    vst1q_f64(C+(size_t)0*ldc+6,vsubq_f64(vld1q_f64(C+(size_t)0*ldc+6),a0_6));
    vst1q_f64(C+(size_t)1*ldc+0,vsubq_f64(vld1q_f64(C+(size_t)1*ldc+0),a1_0));
    vst1q_f64(C+(size_t)1*ldc+2,vsubq_f64(vld1q_f64(C+(size_t)1*ldc+2),a1_2));
    vst1q_f64(C+(size_t)1*ldc+4,vsubq_f64(vld1q_f64(C+(size_t)1*ldc+4),a1_4));
    vst1q_f64(C+(size_t)1*ldc+6,vsubq_f64(vld1q_f64(C+(size_t)1*ldc+6),a1_6));
    vst1q_f64(C+(size_t)2*ldc+0,vsubq_f64(vld1q_f64(C+(size_t)2*ldc+0),a2_0));
    vst1q_f64(C+(size_t)2*ldc+2,vsubq_f64(vld1q_f64(C+(size_t)2*ldc+2),a2_2));
    vst1q_f64(C+(size_t)2*ldc+4,vsubq_f64(vld1q_f64(C+(size_t)2*ldc+4),a2_4));
    vst1q_f64(C+(size_t)2*ldc+6,vsubq_f64(vld1q_f64(C+(size_t)2*ldc+6),a2_6));
    vst1q_f64(C+(size_t)3*ldc+0,vsubq_f64(vld1q_f64(C+(size_t)3*ldc+0),a3_0));
    vst1q_f64(C+(size_t)3*ldc+2,vsubq_f64(vld1q_f64(C+(size_t)3*ldc+2),a3_2));
    vst1q_f64(C+(size_t)3*ldc+4,vsubq_f64(vld1q_f64(C+(size_t)3*ldc+4),a3_4));
    vst1q_f64(C+(size_t)3*ldc+6,vsubq_f64(vld1q_f64(C+(size_t)3*ldc+6),a3_6));
}
#endif
#if TRSM_CAN_DISPATCH_SVE
/* Linux vector length belongs to each thread. Call this target helper only
 * after HWCAP_SVE, then use the SVE microkernel only for exactly eight lanes. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static int trsm_sve_has_eight_doubles(void)
{
    return svcntd()==RHS;
}

/* Each lane follows the NEON kernel's increasing-k FMA chain, followed by one
 * C-sum subtraction. The caller guarantees four rows and eight double lanes;
 * ldx remains independent of ldc for packed and allocation-failure paths. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void update4x8_sve(int count,const double *L,int lda,const double *X,int ldx,double *C,int ldc)
{
    svbool_t pg=svptrue_b64();
    svfloat64_t a0=svdup_n_f64(0);
    svfloat64_t a1=svdup_n_f64(0);
    svfloat64_t a2=svdup_n_f64(0);
    svfloat64_t a3=svdup_n_f64(0);
    for(int k=0;k<count;++k) {
        svfloat64_t x=svld1_f64(pg,X+(size_t)k*ldx);
        a0=svmla_n_f64_x(pg,a0,x,L[(size_t)0*lda+k]);
        a1=svmla_n_f64_x(pg,a1,x,L[(size_t)1*lda+k]);
        a2=svmla_n_f64_x(pg,a2,x,L[(size_t)2*lda+k]);
        a3=svmla_n_f64_x(pg,a3,x,L[(size_t)3*lda+k]);
    }
    svst1_f64(pg,C+(size_t)0*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)0*ldc),a0));
    svst1_f64(pg,C+(size_t)1*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)1*ldc),a1));
    svst1_f64(pg,C+(size_t)2*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)2*ldc),a2));
    svst1_f64(pg,C+(size_t)3*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)3*ldc),a3));
}

/* Eight independent rows reuse each X vector; each row keeps the original
 * increasing-k FMA chain. Four-row and scalar tails use the existing code. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void update8x8_sve(int count,const double *L,int lda,const double *X,int ldx,double *C,int ldc)
{
    svbool_t pg=svptrue_b64();
    svfloat64_t a0=svdup_n_f64(0);
    svfloat64_t a1=svdup_n_f64(0);
    svfloat64_t a2=svdup_n_f64(0);
    svfloat64_t a3=svdup_n_f64(0);
    svfloat64_t a4=svdup_n_f64(0);
    svfloat64_t a5=svdup_n_f64(0);
    svfloat64_t a6=svdup_n_f64(0);
    svfloat64_t a7=svdup_n_f64(0);
    for(int k=0;k<count;++k) {
        svfloat64_t x=svld1_f64(pg,X+(size_t)k*ldx);
        a0=svmla_n_f64_x(pg,a0,x,L[(size_t)0*lda+k]);
        a1=svmla_n_f64_x(pg,a1,x,L[(size_t)1*lda+k]);
        a2=svmla_n_f64_x(pg,a2,x,L[(size_t)2*lda+k]);
        a3=svmla_n_f64_x(pg,a3,x,L[(size_t)3*lda+k]);
        a4=svmla_n_f64_x(pg,a4,x,L[(size_t)4*lda+k]);
        a5=svmla_n_f64_x(pg,a5,x,L[(size_t)5*lda+k]);
        a6=svmla_n_f64_x(pg,a6,x,L[(size_t)6*lda+k]);
        a7=svmla_n_f64_x(pg,a7,x,L[(size_t)7*lda+k]);
    }
    svst1_f64(pg,C+(size_t)0*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)0*ldc),a0));
    svst1_f64(pg,C+(size_t)1*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)1*ldc),a1));
    svst1_f64(pg,C+(size_t)2*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)2*ldc),a2));
    svst1_f64(pg,C+(size_t)3*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)3*ldc),a3));
    svst1_f64(pg,C+(size_t)4*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)4*ldc),a4));
    svst1_f64(pg,C+(size_t)5*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)5*ldc),a5));
    svst1_f64(pg,C+(size_t)6*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)6*ldc),a6));
    svst1_f64(pg,C+(size_t)7*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)7*ldc),a7));
}

/* Sixteen row accumulators share each X load, retaining increasing-k FMA
 * order within every lane. Eight/four-row tails use the existing kernels. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static void update16x8_sve(int count,const double *L,int lda,const double *X,int ldx,double *C,int ldc)
{
    svbool_t pg=svptrue_b64();
    svfloat64_t a0=svdup_n_f64(0);
    svfloat64_t a1=svdup_n_f64(0);
    svfloat64_t a2=svdup_n_f64(0);
    svfloat64_t a3=svdup_n_f64(0);
    svfloat64_t a4=svdup_n_f64(0);
    svfloat64_t a5=svdup_n_f64(0);
    svfloat64_t a6=svdup_n_f64(0);
    svfloat64_t a7=svdup_n_f64(0);
    svfloat64_t a8=svdup_n_f64(0);
    svfloat64_t a9=svdup_n_f64(0);
    svfloat64_t a10=svdup_n_f64(0);
    svfloat64_t a11=svdup_n_f64(0);
    svfloat64_t a12=svdup_n_f64(0);
    svfloat64_t a13=svdup_n_f64(0);
    svfloat64_t a14=svdup_n_f64(0);
    svfloat64_t a15=svdup_n_f64(0);
    for(int k=0;k<count;++k) {
        svfloat64_t x=svld1_f64(pg,X+(size_t)k*ldx);
        a0=svmla_n_f64_x(pg,a0,x,L[(size_t)0*lda+k]);
        a1=svmla_n_f64_x(pg,a1,x,L[(size_t)1*lda+k]);
        a2=svmla_n_f64_x(pg,a2,x,L[(size_t)2*lda+k]);
        a3=svmla_n_f64_x(pg,a3,x,L[(size_t)3*lda+k]);
        a4=svmla_n_f64_x(pg,a4,x,L[(size_t)4*lda+k]);
        a5=svmla_n_f64_x(pg,a5,x,L[(size_t)5*lda+k]);
        a6=svmla_n_f64_x(pg,a6,x,L[(size_t)6*lda+k]);
        a7=svmla_n_f64_x(pg,a7,x,L[(size_t)7*lda+k]);
        a8=svmla_n_f64_x(pg,a8,x,L[(size_t)8*lda+k]);
        a9=svmla_n_f64_x(pg,a9,x,L[(size_t)9*lda+k]);
        a10=svmla_n_f64_x(pg,a10,x,L[(size_t)10*lda+k]);
        a11=svmla_n_f64_x(pg,a11,x,L[(size_t)11*lda+k]);
        a12=svmla_n_f64_x(pg,a12,x,L[(size_t)12*lda+k]);
        a13=svmla_n_f64_x(pg,a13,x,L[(size_t)13*lda+k]);
        a14=svmla_n_f64_x(pg,a14,x,L[(size_t)14*lda+k]);
        a15=svmla_n_f64_x(pg,a15,x,L[(size_t)15*lda+k]);
    }
    svst1_f64(pg,C+(size_t)0*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)0*ldc),a0));
    svst1_f64(pg,C+(size_t)1*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)1*ldc),a1));
    svst1_f64(pg,C+(size_t)2*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)2*ldc),a2));
    svst1_f64(pg,C+(size_t)3*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)3*ldc),a3));
    svst1_f64(pg,C+(size_t)4*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)4*ldc),a4));
    svst1_f64(pg,C+(size_t)5*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)5*ldc),a5));
    svst1_f64(pg,C+(size_t)6*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)6*ldc),a6));
    svst1_f64(pg,C+(size_t)7*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)7*ldc),a7));
    svst1_f64(pg,C+(size_t)8*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)8*ldc),a8));
    svst1_f64(pg,C+(size_t)9*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)9*ldc),a9));
    svst1_f64(pg,C+(size_t)10*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)10*ldc),a10));
    svst1_f64(pg,C+(size_t)11*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)11*ldc),a11));
    svst1_f64(pg,C+(size_t)12*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)12*ldc),a12));
    svst1_f64(pg,C+(size_t)13*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)13*ldc),a13));
    svst1_f64(pg,C+(size_t)14*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)14*ldc),a14));
    svst1_f64(pg,C+(size_t)15*ldc,svsub_f64_x(pg,svld1_f64(pg,C+(size_t)15*ldc),a15));
}
#endif
static void solve_blocked(int m,int n,const double *L,int lda,double *B,int ldb)
{
    if(m<=0 || n<=0) return;
    /* Shared solved RHS panels: [ceil(n/RHS)][KB][RHS]. Packing once
     * per diagonal block lets every lower row tile read X contiguously.
     * Keep the original strided path available if allocation fails. */
    double *packed=NULL;
    size_t panels=((size_t)n+RHS-1)/RHS;
    if(posix_memalign((void**)&packed,64,panels*KB*RHS*sizeof(double))!=0)
        packed=NULL;
#if TRSM_CAN_DISPATCH_SVE
    const int have_sve=(getauxval(AT_HWCAP)&HWCAP_SVE)!=0;
#endif
#pragma omp parallel
    {
#if TRSM_CAN_DISPATCH_SVE
        const int use_sve=have_sve && trsm_sve_has_eight_doubles();
#endif
        for(int kk=0;kk<m;kk+=KB) {
            int end=m-kk<KB?m:kk+KB;
            // 对角块内的列彼此独立，但每一列的行必须按前代顺序。
#pragma omp for schedule(static)
            for(int jb=0;jb<n;jb+=8) {
                int w=n-jb<8?n-jb:8;
                if(packed) {
                    /* Solve in the shared compact panel. The omp-for barrier
                     * publishes both solved B and X for the update phase. */
                    int count=end-kk;
                    double *x=packed+(size_t)(jb/RHS)*KB*RHS;
                    for(int i=0;i<count;++i) {
                        for(int j=0;j<w;++j)x[(size_t)i*RHS+j]=B[(size_t)(kk+i)*ldb+jb+j];
                        for(int j=w;j<RHS;++j)x[(size_t)i*RHS+j]=0;
                    }
                    for(int ii=0;ii<count;ii+=ROWS) {
                        int h=count-ii<ROWS?count-ii:ROWS;
                        double sums[ROWS*RHS]={0};
#if defined(__aarch64__)
                        if(h==ROWS)panel_sums(ii,lda,L+(size_t)(kk+ii)*lda+kk,x,sums);
                        else
#endif
                        {
                            for(int k=0;k<ii;++k)for(int r=0;r<h;++r) {
                                double a=L[(size_t)(kk+ii+r)*lda+kk+k];
#pragma omp simd
                                for(int j=0;j<RHS;++j)sums[r*RHS+j]+=a*x[(size_t)k*RHS+j];
                            }
                        }
                        for(int r=0;r<h;++r) {
                            double *row=x+(size_t)(ii+r)*RHS;
                            for(int q=0;q<r;++q) {
                                double a=L[(size_t)(kk+ii+r)*lda+kk+ii+q];
#pragma omp simd
                                for(int j=0;j<RHS;++j)sums[r*RHS+j]+=a*x[(size_t)(ii+q)*RHS+j];
                            }
                            double diag=L[(size_t)(kk+ii+r)*lda+kk+ii+r];
#pragma omp simd
                            for(int j=0;j<RHS;++j)row[j]=(row[j]-sums[r*RHS+j])/diag;
                        }
                    }
                    for(int i=0;i<count;++i)for(int j=0;j<w;++j)
                        B[(size_t)(kk+i)*ldb+jb+j]=x[(size_t)i*RHS+j];
                    continue;
                }
                for(int i=kk;i<end;++i) {
                    double sum[8]={0};
                    for(int k=kk;k<i;++k) {
                        double a=L[(size_t)i*lda+k];
#pragma omp simd
                        for(int j=0;j<w;++j)sum[j]+=a*B[(size_t)k*ldb+jb+j];
                    }
                    double diag=L[(size_t)i*lda+i];
#pragma omp simd
                    for(int j=0;j<w;++j)B[(size_t)i*ldb+jb+j]=(B[(size_t)i*ldb+jb+j]-sum[j])/diag;
                }
            }
            /* The diagonal solve already filled packed; its implicit barrier
             * publishes those panels. Allocation failure keeps strided X. */
            // B[下面,:] -= L[下面,当前块] * X[当前块,:]。
#pragma omp for collapse(2) schedule(static)
            for(int ib=end;ib<m;ib+=CT)for(int jb=0;jb<n;jb+=CT) {
                int ie=m-ib<CT?m:ib+CT,je=n-jb<CT?n:jb+CT;
                int first_row=ib;
#if TRSM_CAN_DISPATCH_SVE
                if(use_sve) {
                    for(;ie-first_row>=16;first_row+=16) {
                        for(int j=jb;j<je;j+=8) {
                            int cols=je-j<8?je-j:8;
                            const double *xp=packed?packed+(size_t)(j/RHS)*KB*RHS:B+(size_t)kk*ldb+j;
                            int xstride=packed?RHS:ldb;
                            if(cols==8) {
                                update16x8_sve(end-kk,L+(size_t)first_row*lda+kk,lda,xp,xstride,B+(size_t)first_row*ldb+j,ldb);
                            } else {
                                for(int r=0;r<16;++r) {
                                    double sum[8]={0};
                                    for(int k=kk;k<end;++k) {
                                        double a=L[(size_t)(first_row+r)*lda+k];
#pragma omp simd
                                        for(int c=0;c<cols;++c)sum[c]+=a*xp[(size_t)(k-kk)*xstride+c];
                                    }
#pragma omp simd
                                    for(int c=0;c<cols;++c)B[(size_t)(first_row+r)*ldb+j+c]-=sum[c];
                                }
                            }
                        }
                    }
                    for(;first_row+8<=ie;first_row+=8) {
                        for(int j=jb;j<je;j+=8) {
                            int cols=je-j<8?je-j:8;
                            const double *xp=packed?packed+(size_t)(j/RHS)*KB*RHS:B+(size_t)kk*ldb+j;
                            int xstride=packed?RHS:ldb;
                            if(cols==8) {
                                update8x8_sve(end-kk,L+(size_t)first_row*lda+kk,lda,xp,xstride,B+(size_t)first_row*ldb+j,ldb);
                            } else {
                                for(int r=0;r<8;++r) {
                                    double sum[8]={0};
                                    for(int k=kk;k<end;++k) {
                                        double a=L[(size_t)(first_row+r)*lda+k];
#pragma omp simd
                                        for(int c=0;c<cols;++c)sum[c]+=a*xp[(size_t)(k-kk)*xstride+c];
                                    }
#pragma omp simd
                                    for(int c=0;c<cols;++c)B[(size_t)(first_row+r)*ldb+j+c]-=sum[c];
                                }
                            }
                        }
                    }
                }
#endif
                for(int i=first_row;i<ie;i+=4)for(int j=jb;j<je;j+=8) {
                    int rows=ie-i<4?ie-i:4,cols=je-j<8?je-j:8;
                    const double *xp=packed?packed+(size_t)(j/RHS)*KB*RHS:B+(size_t)kk*ldb+j;
                    int xstride=packed?RHS:ldb;
#if defined(__aarch64__)
                    if(rows==4 && cols==8) {
#if TRSM_CAN_DISPATCH_SVE
                        if(use_sve)update4x8_sve(end-kk,L+(size_t)i*lda+kk,lda,xp,xstride,B+(size_t)i*ldb+j,ldb);
                        else
#endif
                        update4x8(end-kk,L+(size_t)i*lda+kk,lda,xp,xstride,B+(size_t)i*ldb+j,ldb);
                    }
                    else
#endif
                    for(int r=0;r<rows;++r) {
                        double sum[8]={0};
                        for(int k=kk;k<end;++k) {
                            double a=L[(size_t)(i+r)*lda+k];
#pragma omp simd
                            for(int c=0;c<cols;++c)sum[c]+=a*xp[(size_t)(k-kk)*xstride+c];
                        }
#pragma omp simd
                        for(int c=0;c<cols;++c)B[(size_t)(i+r)*ldb+j+c]-=sum[c];
                    }
                }
            }
        }
    }
    free(packed);
}

/* 用三角矩阵工作集估计选择通用算法，不对公开测试尺寸作等值分支。
 * 小工作集：多行窄面板前代，避免全矩阵更新与频繁 barrier。
 * 大工作集：分块前代，避免每组右端项重复扫描整个大 L。
 * 64 MiB 是实现选择的缓存预算，不是对运行硬件缓存容量的承诺。
 */
void l_trsm(int m,int n,const double *L,int lda,double *B,int ldb)
{
    if(m<=0 || n<=0)return;
    size_t triangular_entries=(size_t)m*((size_t)m+1)/2;
    if(triangular_entries > (64u*1024u*1024u)/sizeof(double))
        solve_blocked(m,n,L,lda,B,ldb);
    else
        solve_panel(m,n,L,lda,B,ldb);
}
