#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../T7-diagpanel/source/trsm.c"
/* Direct blocked-path unit check below the public dispatch budget. Non-dyadic
 * inputs and a long-double RHS construction exercise the new FMA rounding. */
int main(void) {
    const int ms[]={1,3,4,7,255,256,257,511,512,513};
    const int ns[]={1,7,8,9,17};
    double worst=0;
    int checked=0;
    for(size_t mi=0;mi<sizeof(ms)/sizeof(ms[0]);++mi)
    for(size_t ni=0;ni<sizeof(ns)/sizeof(ns[0]);++ni) {
        int m=ms[mi],n=ns[ni],lda=m+3,ldb=n+5;
        size_t nl=(size_t)m*lda,nb=(size_t)m*ldb;
        double *l=calloc(nl,sizeof(double)),*saved=malloc(nl*sizeof(double));
        double *b=malloc(nb*sizeof(double)),*x=malloc(nb*sizeof(double));
        if(!l||!saved||!b||!x)return 1;
        for(int i=0;i<m;++i) {
            double diag=1.031;
            for(int k=0;k<i;++k) {
                double a=((i*19+k*31)%97-48)/997.0;
                l[(size_t)i*lda+k]=a;diag+=fabs(a);
            }
            l[(size_t)i*lda+i]=diag;
        }
        memcpy(saved,l,nl*sizeof(double));
        for(size_t q=0;q<nb;++q)x[q]=b[q]=37.0;
        for(int i=0;i<m;++i)for(int j=0;j<n;++j)
            x[(size_t)i*ldb+j]=((i*13+j*17)%101-50)/103.0;
        for(int i=0;i<m;++i)for(int j=0;j<n;++j) {
            long double acc=0;
            for(int k=0;k<=i;++k)acc+=(long double)l[(size_t)i*lda+k]*x[(size_t)k*ldb+j];
            b[(size_t)i*ldb+j]=(double)acc;
        }
        solve_blocked(m,n,l,lda,b,ldb);
        for(int i=0;i<m;++i)for(int j=0;j<ldb;++j) {
            double e=fabs(b[(size_t)i*ldb+j]-x[(size_t)i*ldb+j]);
            if(!isfinite(e)||e>1e-12) {printf("FAIL non-dyadic blocked m=%d n=%d i=%d j=%d error=%.17g\n",m,n,i,j,e);return 1;}
            if(e>worst)worst=e;
        }
        if(memcmp(l,saved,nl*sizeof(double))){puts("FAIL non-dyadic L modified");return 1;}
        free(l);free(saved);free(b);free(x);++checked;
    }
    printf("PASS %d non-dyadic direct-blocked cases, long-double RHS, padding and L unchanged; max-error=%.3e\n",checked,worst);
    return 0;
}
