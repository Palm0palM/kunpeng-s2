#define _GNU_SOURCE
#include <kblas.h>
#include <omp.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
_Static_assert(sizeof(BLASINT)==sizeof(int), "Official benchmark requires default LP64 BLAS integers");
int main(void)
{
    KBLASVersion version={0};
    int version_status=KBLASGetVersion(&version);
    printf("KML_VERSION_QUERY_EXIT=%d\n",version_status);
    printf("KML_SOFTWARE_NAME=%.*s\n",(int)sizeof(version.softwareName),version.softwareName);
    printf("KML_SOFTWARE_VERSION=%.*s\n",(int)sizeof(version.softwareVersion),version.softwareVersion);
    printf("KML_CONFIGURED_THREADS=%d\n",BlasGetNumThreads());
    int actual_threads=0;
#pragma omp parallel
    {
#pragma omp single
        actual_threads=omp_get_num_threads();
    }
    printf("OMP_ACTUAL_TEAM_THREADS=%d\n",actual_threads);
    if(actual_threads!=38 || BlasGetNumThreads()!=38) return 2;
    Dl_info info;
    if(!dladdr((void *)cblas_dgemm,&info))return 3;
    printf("DGEMM_PROVIDER=%s\n",info.dli_fname);
    if(!dladdr((void *)cblas_domatcopy,&info))return 3;
    printf("DOMATCOPY_PROVIDER=%s\n",info.dli_fname);
    double a[4]={1,2,3,4},b[4]={5,6,7,8},c[4]={0,0,0,0};
    const double want[4]={19,22,43,50};
    cblas_dgemm(CblasRowMajor,CblasNoTrans,CblasNoTrans,2,2,2,1,a,2,b,2,0,c,2);
    for(int i=0;i<4;++i)if(c[i]!=want[i])return 4;
    double x[10]={1,2,3,91,92,4,5,6,93,94};
    double y[12];for(int i=0;i<12;++i)y[i]=97;
    cblas_domatcopy(CblasRowMajor,CblasNoTrans,2,3,1,x,5,y,6);
    for(int r=0;r<2;++r)for(int j=0;j<6;++j)
        if(y[r*6+j]!=(j<3?x[r*5+j]:97))return 5;
    printf("KML_CONFIGURED_THREADS_AFTER_CALLS=%d\n",BlasGetNumThreads());
    puts("KML251_REQUIRED_SYMBOLS_SMOKE_PASS=1");
    return BlasGetNumThreads()==38?0:2;
}
