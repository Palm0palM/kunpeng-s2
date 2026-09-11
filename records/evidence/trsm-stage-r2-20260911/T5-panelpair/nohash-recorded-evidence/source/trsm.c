#include <stddef.h>
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
static void solve_panel(int m,int n,const double *L,int lda,double *B,int ldb)
{
    if(m<=0 || n<=0) return;
#pragma omp parallel
    {
        /* Pair adjacent panels only when at least two groups per actual worker
         * remain. Both panels finish a row block while its L rows are warm. */
        const int panel_count=(n-1)/RHS+1;
        const int panels_per_group=panel_count/omp_get_num_threads()>=4?2:1;
        const int group_count=(panel_count-1)/panels_per_group+1;
        const size_t panel_stride=(size_t)m*RHS;
        double *packed=NULL;
        if(posix_memalign((void**)&packed,64,panel_stride*panels_per_group*sizeof(double))!=0) packed=NULL;
#pragma omp for schedule(static)
        for(int group=0;group<group_count;++group) {
            int jb=group*panels_per_group*RHS;
            int width=n-jb<panels_per_group*RHS?n-jb:panels_per_group*RHS;
            int active_panels=(width-1)/RHS+1;
            if(!packed) {
                for(int j=jb;j<jb+width;++j)for(int i=0;i<m;++i) {
                    double s=0;for(int k=0;k<i;++k)s+=L[(size_t)i*lda+k]*B[(size_t)k*ldb+j];
                    B[(size_t)i*ldb+j]=(B[(size_t)i*ldb+j]-s)/L[(size_t)i*lda+i];
                }
                continue;
            }
            for(int panel=0;panel<active_panels;++panel) {
                double *x=packed+(size_t)panel*panel_stride;
                int col=jb+panel*RHS;
                int w=n-col<RHS?n-col:RHS;
                for(int i=0;i<m;++i) {
                    for(int j=0;j<w;++j)x[(size_t)i*RHS+j]=B[(size_t)i*ldb+col+j];
                    for(int j=w;j<RHS;++j)x[(size_t)i*RHS+j]=0;
                }
            }
            for(int ii=0;ii<m;ii+=ROWS) {
                int h=m-ii<ROWS?m-ii:ROWS;
                for(int panel=0;panel<active_panels;++panel) {
                    double *x=packed+(size_t)panel*panel_stride;
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
            }
            for(int panel=0;panel<active_panels;++panel) {
                const double *x=packed+(size_t)panel*panel_stride;
                int col=jb+panel*RHS;
                int w=n-col<RHS?n-col:RHS;
                for(int i=0;i<m;++i)for(int j=0;j<w;++j)B[(size_t)i*ldb+col+j]=x[(size_t)i*RHS+j];
            }
        }
        free(packed);
    }
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
            /* The preceding barrier finishes the diagonal solve. The
             * packing barrier publishes all panels before their consumers. */
            if(packed) {
#pragma omp for schedule(static)
                for(int jb=0;jb<n;jb+=RHS) {
                    int width=n-jb<RHS?n-jb:RHS;
                    double *panel=packed+(size_t)(jb/RHS)*KB*RHS;
                    for(int k=kk;k<end;++k) {
                        for(int j=0;j<width;++j)
                            panel[(size_t)(k-kk)*RHS+j]=B[(size_t)k*ldb+jb+j];
                        for(int j=width;j<RHS;++j)
                            panel[(size_t)(k-kk)*RHS+j]=0;
                    }
                }
            }
            // B[下面,:] -= L[下面,当前块] * X[当前块,:]。
#pragma omp for collapse(2) schedule(static)
            for(int ib=end;ib<m;ib+=CT)for(int jb=0;jb<n;jb+=CT) {
                int ie=m-ib<CT?m:ib+CT,je=n-jb<CT?n:jb+CT;
                int first_row=ib;
#if TRSM_CAN_DISPATCH_SVE
                if(use_sve) {
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
