#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
void l_trsm(int,int,const double*,int,double*,int);
static unsigned rng=17;
static double rnd(void){rng=rng*1664525u+1013904223u;return ((rng>>8)%10001)/10001.0-0.5;}
int main(void){
 double te=0;
 int td[][2]={{1,1},{3,19},{33,17},{129,53},{513,65},{4095,3},{4097,3},{4,7},{4,8},{5,9},{31,15},{32,16}};
 for(int d=0;d<12;++d){int m=td[d][0],n=td[d][1],la=m+3,lb=n+7;size_t nl=(size_t)m*la,nb=(size_t)m*lb;double *l=calloc(nl,sizeof(double)),*save=malloc(nl*sizeof(double)),*x=malloc(nb*sizeof(double)),*b=malloc(nb*sizeof(double));
 for(int i=0;i<m;++i){double s=1;for(int j=0;j<i;++j){l[(size_t)i*la+j]=rnd();s+=fabs(l[(size_t)i*la+j]);}l[(size_t)i*la+i]=s;}
 memcpy(save,l,nl*sizeof(double));for(size_t q=0;q<nb;++q)x[q]=b[q]=37;
 for(int i=0;i<m;++i)for(int j=0;j<n;++j)x[(size_t)i*lb+j]=rnd();
 for(int i=0;i<m;++i)for(int j=0;j<n;++j){long double s=0;for(int p=0;p<=i;++p)s+=(long double)l[(size_t)i*la+p]*x[(size_t)p*lb+j];b[(size_t)i*lb+j]=(double)s;}
 l_trsm(m,n,l,la,b,lb);
 for(int i=0;i<m;++i)for(int j=0;j<lb;++j){double e=fabs(b[(size_t)i*lb+j]-x[(size_t)i*lb+j]);if(!isfinite(e)||e>1e-12){printf("TRSM FAIL %d %d err=%g\n",i,j,e);return 1;}if(e>te)te=e;}
 if(memcmp(l,save,nl*sizeof(double))){puts("TRSM L modified");return 1;}free(l);free(save);free(x);free(b);}
 printf("TRSM-only normal/tails: 12 cases PASS; known solution max error %.3e; padding and L unchanged\n",te);
 return 0;
}
