#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
void l_trsm(int,int,const double*,int,double*,int);
static unsigned rng=17;
static double rnd(void)
{
    rng=rng*1664525u+1013904223u;
    return ((rng>>8)%10001)/10001.0-0.5;
}
int main(void)
{
    double max_error=0;
    const int dims[][2]={{1,1},{3,7},{4,8},{5,9},{65,17},{257,1},
                         {4095,9},{4096,8},{4097,9},{4355,65}};
    l_trsm(0,8,NULL,0,NULL,0);
    l_trsm(8,0,NULL,0,NULL,0);
    l_trsm(-1,8,NULL,0,NULL,0);
    l_trsm(8,-1,NULL,0,NULL,0);
    for(size_t d=0;d<sizeof(dims)/sizeof(dims[0]);++d) {
        int m=dims[d][0],n=dims[d][1],lda=m+3,ldb=n+7;
        size_t nl=(size_t)m*lda,nb=(size_t)m*ldb;
        double *l=calloc(nl,sizeof(double)),*saved_l=malloc(nl*sizeof(double));
        double *x=malloc(nb*sizeof(double)),*b=malloc(nb*sizeof(double));
        if(!l||!saved_l||!x||!b){puts("Allocation FAIL");return 1;}
        for(int i=0;i<m;++i) {
            double diag=1;
            for(int k=0;k<i;++k){l[(size_t)i*lda+k]=rnd();diag+=fabs(l[(size_t)i*lda+k]);}
            l[(size_t)i*lda+i]=diag;
        }
        memcpy(saved_l,l,nl*sizeof(double));
        for(size_t q=0;q<nb;++q)x[q]=b[q]=37;
        for(int i=0;i<m;++i)for(int j=0;j<n;++j)x[(size_t)i*ldb+j]=rnd();
        for(int i=0;i<m;++i)for(int j=0;j<n;++j) {
            long double sum=0;
            for(int k=0;k<=i;++k)sum+=(long double)l[(size_t)i*lda+k]*x[(size_t)k*ldb+j];
            b[(size_t)i*ldb+j]=(double)sum;
        }
        l_trsm(m,n,l,lda,b,ldb);
        double case_error=0;
        for(int i=0;i<m;++i)for(int j=0;j<ldb;++j) {
            double error=fabs(b[(size_t)i*ldb+j]-x[(size_t)i*ldb+j]);
            if(!isfinite(error)||error>1e-12) {
                printf("TRSM FAIL m=%d n=%d row=%d col=%d error=%.17g\n",m,n,i,j,error);return 1;
            }
            if(error>case_error)case_error=error;
        }
        if(memcmp(l,saved_l,nl*sizeof(double))){puts("TRSM L modified FAIL");return 1;}
        if(case_error>max_error)max_error=case_error;
        printf("TRSM m=%d n=%d PASS known-solution max-error=%.3e; padding and L unchanged\n",m,n,case_error);
        fflush(stdout);
        free(l);free(saved_l);free(x);free(b);
    }
    printf("TRSM 10 known-solution cases and 4 no-op boundaries PASS; max-error=%.3e\n",max_error);
    return 0;
}
