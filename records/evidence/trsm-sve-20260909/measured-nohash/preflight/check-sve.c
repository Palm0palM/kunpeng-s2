#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <omp.h>
#ifdef CHECK_PANEL
#include "../T3-svepanel-r3/source/trsm.c"
#else
#include "../T3-sveupdate-r3/source/trsm.c"
#endif
#if !TRSM_CAN_DISPATCH_SVE
#error This preflight must compile the actual Linux GCC SVE dispatch path.
#endif
static unsigned long sve_entries;
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
#ifdef CHECK_PANEL
    if(fn==(void *)panel_sums_sve)
#else
    if(fn==(void *)update4x8_sve)
#endif
        __atomic_fetch_add(&sve_entries,1,__ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn,void *caller){(void)fn;(void)caller;}
#define main known_solution_main
#include "check-trsm.c"
#undef main
static int microcheck(void) {
    int counts[]={0,1,2,3,7,63,128,255,256,257};
    int strides[]={8,11,65};
    int checked=0;
    for(size_t t=0;t<sizeof(counts)/sizeof(counts[0]);++t)
    for(size_t q=0;q<sizeof(strides)/sizeof(strides[0]);++q) {
        int count=counts[t],lda=count+7,ldx=strides[q],ldc=ldx+5;
#ifdef CHECK_PANEL
        ldx=8;
#endif
        size_t nl=(size_t)4*lda,nx=(size_t)(count+1)*ldx,nc=(size_t)4*ldc;
        double *l=malloc(nl*sizeof(double)),*x=malloc(nx*sizeof(double));
        double *c=malloc(nc*sizeof(double)),*want=malloc(nc*sizeof(double));
        double sums[36],expected[36];
        if(!l||!x||!c||!want)return 1;
        for(size_t i=0;i<nl;++i)l[i]=((int)(i%37)-18)*0.03125;
        for(size_t i=0;i<nx;++i)x[i]=((int)(i%53)-26)*0.021;
        for(size_t i=0;i<nc;++i)c[i]=want[i]=((int)(i%23)-11)*0.17;
        for(int i=0;i<36;++i)sums[i]=expected[i]=839;
        for(int r=0;r<4;++r)for(int j=0;j<8;++j) {
            double acc=0;
            for(int k=0;k<count;++k)acc=fma(l[(size_t)r*lda+k],x[(size_t)k*ldx+j],acc);
            expected[2+r*8+j]=acc;
            want[(size_t)r*ldc+j]-=acc;
        }
#ifdef CHECK_PANEL
        panel_sums_sve(count,lda,l,x,sums+2);
        int bad=memcmp(sums,expected,sizeof(sums));
#else
        update4x8_sve(count,l,lda,x,ldx,c,ldc);
        int bad=memcmp(c,want,nc*sizeof(double));
#endif
        free(l);free(x);free(c);free(want);
        if(bad){printf("FAIL micro count=%d ldx=%d ldc=%d\n",count,ldx,ldc);return 1;}
        ++checked;
    }
    printf("PASS %d direct SVE microkernel count/stride combinations; bitwise ordered-FMA match and output padding preserved\n",checked);
    return 0;
}
int main(void) {
    if((getauxval(AT_HWCAP)&HWCAP_SVE)==0){puts("PREFLIGHT_BLOCKED: SVE unavailable");return 2;}
    int correct_width=1;
#pragma omp parallel reduction(&:correct_width)
    {
        correct_width &= trsm_sve_has_eight_doubles();
    }
    if(!correct_width){puts("PREFLIGHT_BLOCKED: per-thread SVE width differs from 8 doubles");return 2;}
    if(microcheck())return 1;
    sve_entries=0;
    if(known_solution_main())return 1;
    printf("SVE_KERNEL_ACTUAL_ENTRIES=%lu\n",sve_entries);
    if(!sve_entries){puts("FAIL: whole-operator test did not enter SVE kernel");return 1;}
    puts("PASS actual SVE dispatch preflight");
    return 0;
}
