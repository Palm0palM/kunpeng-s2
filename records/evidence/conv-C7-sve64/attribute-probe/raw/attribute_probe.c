#include <arm_sve.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/auxv.h>
#include <asm/hwcap.h>
__attribute__((target("arch=armv8-a+sve"),noinline))
static int helper(float seed) {
 size_t n=svcntw(); float a[n],b[n],c[n];
 for(size_t i=0;i<n;++i){a[i]=seed+(float)i;b[i]=3.0f;}
 svbool_t p=svptrue_b32();
 svfloat32_t av=svld1(p,a),bv=svld1(p,b);
 svst1(p,c,svadd_f32_x(p,svmul_f32_x(p,av,bv),av));
 int errors=0;for(size_t i=0;i<n;++i)if(c[i]!=a[i]*4.0f)++errors;
 printf("TARGET_HELPER_EXECUTED=1 SVE_FLOAT_LANES=%zu ERRORS=%d\n",n,errors);
 return errors;
}
int main(int argc,char**argv) {
 if(!(getauxval(AT_HWCAP)&HWCAP_SVE)) return 2;
 return helper(argc>1?strtof(argv[1],0):2.0f);
}
