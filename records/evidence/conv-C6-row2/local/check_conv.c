#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
void conv2d(const float*,int,int,const float*,int,int,float*);
static uint32_t rng=7;
static float sample(void) { rng=rng*1664525u+1013904223u; return ((int)(rng>>16)-32768)*0.000030517578125f; }
int main(void) {
 const int outs[]={1,2,3,4,7,8,15,16,17,31,32,33,47,63,64,65,95,96,97};
 const int kernels[]={1,2,3,4,7,8,15,39,41,55,81};
 int count=0;
 for(unsigned a=0;a<sizeof(outs)/sizeof(*outs);a++)
 for(unsigned b=0;b<sizeof(kernels)/sizeof(*kernels);b++)
 for(int pad=0;pad<2;pad++) {
  int kw=kernels[b],kh=(b%4)+1,ow=outs[a],oh=3,W=ow+kw-1,H=oh+kh-1;
  size_t ni=(size_t)W*H,nk=(size_t)kw*kh,no=(size_t)ow*oh;
  float *raw=malloc((ni+pad)*sizeof(float)),*in=raw+pad,*k=malloc(nk*sizeof(float));
  float *out=malloc(no*sizeof(float)),*ref=malloc(no*sizeof(float));
  if(!raw||!k||!out||!ref) return 2;
  for(size_t i=0;i<ni;i++) in[i]=sample();
  for(size_t i=0;i<nk;i++) k[i]=sample();
  for(int y=0;y<oh;y++) for(int x=0;x<ow;x++) {
   float sum=0;
   for(int ky=0;ky<kh;ky++) for(int kx=0;kx<kw;kx++) sum+=in[(y+ky)*W+x+kx]*k[ky*kw+kx];
   ref[y*ow+x]=sum;
  }
  conv2d(in,H,W,k,kh,kw,out);
  if(memcmp(ref,out,no*sizeof(float))) { fprintf(stderr,"mismatch ow=%d kh=%d kw=%d pad=%d\n",ow,kh,kw,pad); return 1; }
  free(raw);free(k);free(out);free(ref);count++;
 }
 printf("PASS: %d convolution cases, bitwise equal to scalar reference\n",count);
 return 0;
}
