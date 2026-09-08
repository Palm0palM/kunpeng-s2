#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../source/trsm.c"

#if !defined(__aarch64__)
#error This check directly exercises the AArch64 update4x8 microkernel.
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
    int cases=0;
    for(size_t ci=0;ci<sizeof(counts)/sizeof(counts[0]);++ci)
    for(size_t si=0;si<sizeof(strides)/sizeof(strides[0]);++si) {
        int count=counts[ci],lda=count+3,ldb=strides[si];
        size_t nl=(size_t)4*lda,nx=(size_t)(count?count:1)*ldb,nc=(size_t)4*ldb;
        double *l=malloc(nl*sizeof(double)),*lsave=malloc(nl*sizeof(double));
        double *x=malloc(nx*sizeof(double)),*xsave=malloc(nx*sizeof(double));
        double *c=malloc(nc*sizeof(double)),*expected=malloc(nc*sizeof(double));
        if(!l||!lsave||!x||!xsave||!c||!expected) { puts("Allocation FAIL"); return 1; }
        for(size_t i=0;i<nl;++i)l[i]=random_value();
        for(size_t i=0;i<nx;++i)x[i]=random_value();
        for(size_t i=0;i<nc;++i)c[i]=random_value();
        memcpy(lsave,l,nl*sizeof(double));
        memcpy(xsave,x,nx*sizeof(double));
        memcpy(expected,c,nc*sizeof(double));
        for(int r=0;r<4;++r)for(int j=0;j<8;++j) {
            double sum=0;
            for(int k=0;k<count;++k)
                sum=fma(l[(size_t)r*lda+k],x[(size_t)k*ldb+j],sum);
            expected[(size_t)r*ldb+j]-=sum;
        }
        update4x8(count,l,lda,x,ldb,c);
        if(memcmp(c,expected,nc*sizeof(double)) || memcmp(l,lsave,nl*sizeof(double)) || memcmp(x,xsave,nx*sizeof(double))) {
            printf("update4x8 FAIL count=%d ldb=%d: expected ordered FMA result, output padding, and unchanged inputs\n",count,ldb);
            return 1;
        }
        ++cases;
        free(l);free(lsave);free(x);free(xsave);free(c);free(expected);
    }
    printf("update4x8: %d cases PASS; count 0/1/even/odd, ordered scalar FMA bitwise equality, output padding and inputs unchanged\n",cases);
    return 0;
}
