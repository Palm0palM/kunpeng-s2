#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../source/trsm.c"

#if !defined(__aarch64__)
#error This test directly exercises the AArch64 update4x8 microkernel.
#endif

static unsigned rng=123456789u;
static double random_value(void)
{
    rng=rng*1664525u+1013904223u;
    return (double)(rng >> 8)/16777216.0-0.5;
}

int main(void)
{
    const int counts[]={0,1,2,3,7,31,63,127,255,256,257};
    const int strides[]={8,9,17,65,512};
    int cases=0,sve_cases=0;
#if TRSM_CAN_DISPATCH_SVE
    const int have_sve=(getauxval(AT_HWCAP)&HWCAP_SVE)!=0;
    const int use_sve=have_sve && trsm_sve_has_eight_doubles();
#endif
    for(size_t ci=0;ci<sizeof(counts)/sizeof(counts[0]);++ci)
    for(size_t xi=0;xi<sizeof(strides)/sizeof(strides[0]);++xi)
    for(size_t di=0;di<sizeof(strides)/sizeof(strides[0]);++di) {
        int count=counts[ci],lda=count+3,ldx=strides[xi],ldc=strides[di];
        size_t nl=(size_t)4*lda,nx=(size_t)(count?count:1)*ldx,nc=(size_t)4*ldc;
        double *l=malloc(nl*sizeof(double)),*lsave=malloc(nl*sizeof(double));
        double *x=malloc(nx*sizeof(double)),*xsave=malloc(nx*sizeof(double));
        double *c=malloc(nc*sizeof(double)),*initial=malloc(nc*sizeof(double));
        double *expected=malloc(nc*sizeof(double));
        if(!l||!lsave||!x||!xsave||!c||!initial||!expected) {
            puts("Allocation FAIL");return 1;
        }
        for(size_t i=0;i<nl;++i)l[i]=random_value();
        for(size_t i=0;i<nx;++i)x[i]=random_value();
        for(size_t i=0;i<nc;++i)c[i]=random_value();
        memcpy(lsave,l,nl*sizeof(double));
        memcpy(xsave,x,nx*sizeof(double));
        memcpy(initial,c,nc*sizeof(double));
        memcpy(expected,c,nc*sizeof(double));
        for(int r=0;r<4;++r)for(int j=0;j<8;++j) {
            double sum=0;
            for(int k=0;k<count;++k)
                sum=fma(l[(size_t)r*lda+k],x[(size_t)k*ldx+j],sum);
            expected[(size_t)r*ldc+j]-=sum;
        }
        update4x8(count,l,lda,x,ldx,c,ldc);
        if(memcmp(c,expected,nc*sizeof(double)) || memcmp(l,lsave,nl*sizeof(double)) || memcmp(x,xsave,nx*sizeof(double))) {
            printf("NEON update4x8 FAIL count=%d ldx=%d ldc=%d\n",count,ldx,ldc);
            return 1;
        }
        ++cases;
#if TRSM_CAN_DISPATCH_SVE
        if(use_sve) {
            memcpy(c,initial,nc*sizeof(double));
            update4x8_sve(count,l,lda,x,ldx,c,ldc);
            if(memcmp(c,expected,nc*sizeof(double)) || memcmp(l,lsave,nl*sizeof(double)) || memcmp(x,xsave,nx*sizeof(double))) {
                printf("SVE update4x8 FAIL count=%d ldx=%d ldc=%d\n",count,ldx,ldc);
                return 1;
            }
            ++sve_cases;
        }
#endif
        free(l);free(lsave);free(x);free(xsave);free(c);free(initial);free(expected);
    }
    printf("NEON update4x8: %d cases PASS; ordered scalar FMA bitwise equality; independent ldx/ldc; padding and inputs unchanged\n",cases);
    printf("SVE update4x8: %d cases executed (zero means SVE path was NOT validated)\n",sve_cases);
    return 0;
}
