#include <complex.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
void cblas_zgemm(int,int,int,int,int,int,const void*,const void*,int,const void*,int,const void*,void*,int);
void l_trsm(int,int,const double*,int,double*,int);
static unsigned rng=17;
static double rnd(void){rng=rng*1664525u+1013904223u;return ((rng>>8)%10001)/10001.0-0.5;}
static size_t idx(int o,int ld,int i,int j){return o==101?(size_t)i*ld+j:(size_t)j*ld+i;}
static double complex val(const double complex*a,int o,int t,int ld,int i,int j){if(t!=111){int x=i;i=j;j=x;}double complex v=a[idx(o,ld,i,j)];return t==113?conj(v):v;}
int main(void){
 double ze=0,te=0;int count=0;
 int dims[][3]={{1,1,1},{3,7,5},{33,17,19},{65,35,257},{7,9,0}};
 for(int d=0;d<5;++d)for(int o=101;o<=102;++o)for(int ta=111;ta<=113;++ta)for(int tb=111;tb<=113;++tb)for(int mode=0;mode<3;++mode){
  int m=dims[d][0],n=dims[d][1],k=dims[d][2];
  int ar=ta==111?m:k,ac=ta==111?k:m,br=tb==111?k:n,bc=tb==111?n:k;
  int la=(o==101?ac:ar)+3,lb=(o==101?bc:br)+5,lc=(o==101?n:m)+7;
  size_t na=(size_t)(o==101?ar:ac)*la+1,nb=(size_t)(o==101?br:bc)*lb+1,nc=(size_t)(o==101?m:n)*lc;
  double complex *a=malloc(na*sizeof(*a)),*b=malloc(nb*sizeof(*b)),*c=malloc(nc*sizeof(*c)),*old=malloc(nc*sizeof(*old));
  for(size_t q=0;q<na;++q)a[q]=rnd()+rnd()*I;
  for(size_t q=0;q<nb;++q)b[q]=rnd()+rnd()*I;
  for(size_t q=0;q<nc;++q)c[q]=old[q]=93+17*I;
  for(int i=0;i<m;++i)for(int j=0;j<n;++j)c[idx(o,lc,i,j)]=old[idx(o,lc,i,j)]=rnd()+rnd()*I;
  double complex alpha=mode==2?0:1+.5*I,beta=mode==1?0:.2-.3*I;
  cblas_zgemm(o,ta,tb,m,n,k,&alpha,a,la,b,lb,&beta,c,lc);
  for(int i=0;i<m;++i)for(int j=0;j<n;++j){long double complex s=0;for(int p=0;p<k;++p)s+=(long double complex)val(a,o,ta,la,i,p)*val(b,o,tb,lb,p,j);long double complex ref=(long double complex)alpha*s+(long double complex)beta*old[idx(o,lc,i,j)];double e=cabsl((long double complex)c[idx(o,lc,i,j)]-ref);if(!isfinite(e)||e>1e-10){printf("ZGEMM FAIL d=%d order=%d ta=%d tb=%d err=%g\n",d,o,ta,tb,e);return 1;}if(e>ze)ze=e;old[idx(o,lc,i,j)]=c[idx(o,lc,i,j)];}
  if(memcmp(c,old,nc*sizeof(*c))){puts("ZGEMM padding corrupted");return 1;}
  free(a);free(b);free(c);free(old);++count;
 }
 printf("ZGEMM: %d cases PASS; long-double reference max error %.3e\n",count,ze);
 int td[][2]={{1,1},{3,19},{33,17},{129,53},{513,65},{4095,3},{4097,3}};
 for(int d=0;d<7;++d){int m=td[d][0],n=td[d][1],la=m+3,lb=n+7;size_t nl=(size_t)m*la,nb=(size_t)m*lb;double *l=calloc(nl,sizeof(double)),*save=malloc(nl*sizeof(double)),*x=malloc(nb*sizeof(double)),*b=malloc(nb*sizeof(double));
 for(int i=0;i<m;++i){double s=1;for(int j=0;j<i;++j){l[(size_t)i*la+j]=rnd();s+=fabs(l[(size_t)i*la+j]);}l[(size_t)i*la+i]=s;}
 memcpy(save,l,nl*sizeof(double));for(size_t q=0;q<nb;++q)x[q]=b[q]=37;
 for(int i=0;i<m;++i)for(int j=0;j<n;++j)x[(size_t)i*lb+j]=rnd();
 for(int i=0;i<m;++i)for(int j=0;j<n;++j){long double s=0;for(int p=0;p<=i;++p)s+=(long double)l[(size_t)i*la+p]*x[(size_t)p*lb+j];b[(size_t)i*lb+j]=(double)s;}
 l_trsm(m,n,l,la,b,lb);
 for(int i=0;i<m;++i)for(int j=0;j<lb;++j){double e=fabs(b[(size_t)i*lb+j]-x[(size_t)i*lb+j]);if(!isfinite(e)||e>1e-12){printf("TRSM FAIL %d %d err=%g\n",i,j,e);return 1;}if(e>te)te=e;}
 if(memcmp(l,save,nl*sizeof(double))){puts("TRSM L modified");return 1;}free(l);free(save);free(x);free(b);}
 printf("TRSM: 7 cases PASS; known solution max error %.3e; padding and L unchanged\n",te);
 return 0;
}
