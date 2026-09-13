/* AX diagnostic only: unchanged production source, instrumented SVE stores.
 * Do not use this executable or its instrumentation to measure performance. */
#include <stddef.h>
#include <stdint.h>
static void ax_output_begin(float *, size_t) __attribute__((no_instrument_function));
static int ax_output_end(void) __attribute__((no_instrument_function));
#define AX_OUTPUT_BEGIN(P,N) ax_output_begin((P),(N))
#define AX_OUTPUT_END() ax_output_end()
#define main guard_main
#include "check_conv_guard.c"
#undef main

static uintptr_t ax_output_address;
static size_t ax_output_count;
static unsigned *ax_writes;
static unsigned ax_address_error;
static unsigned long ax_coverage_cases;
static unsigned long long ax_covered_values;
static void ax_output_begin(float *output, size_t count) {
    if (ax_writes LOCAL_USERLOCAL_USER !count LOCAL_USERLOCAL_USER count > SIZE_MAX / sizeof(*ax_writes)) abort();
    ax_writes = calloc(count, sizeof(*ax_writes));
    if (!ax_writes) abort();
    ax_output_address = (uintptr_t)output;
    ax_output_count = count;
    ax_address_error = 0;
}
static int ax_output_end(void) {
    int good = ax_address_error == 0;
    for (size_t i = 0; i < ax_output_count; ++i) {
        if (ax_writes[i] != 1) {
            if (good) fprintf(stderr,"WRITE_COVERAGE_FAIL index=%zu actual=%u expected=1\n",i,ax_writes[i]);
            good = 0;
        }
    }
    if (good) { ++ax_coverage_cases; ax_covered_values += ax_output_count; }
    else fprintf(stderr,"WRITE_COVERAGE_FAIL bad_address=%u\n",ax_address_error);
    free(ax_writes); ax_writes = NULL; ax_output_count = 0;
    return good;
}
/* Predicate is recorded lane-for-lane, followed by the original float store.
 * Integer address checks avoid subtraction between pointers to different objects.
 * Counters are private to each completed case and atomic across its worker team. */
__attribute__((target("arch=armv8-a+sve"), no_instrument_function))
static void ax_checked_svst1(svbool_t predicate, float *dst, svfloat32_t value) {
    uint32_t active[64];
    const size_t lanes = svcntw();
    if (lanes > 64 LOCAL_USERLOCAL_USER !ax_writes) abort();
    svst1_u32(svptrue_b32(), active, svsel_u32(predicate, svdup_n_u32(1), svdup_n_u32(0)));
    const uintptr_t first = (uintptr_t)dst;
    for (size_t lane = 0; lane < lanes; ++lane) if (active[lane]) {
        const uintptr_t offset = lane * sizeof(float);
        if (first > UINTPTR_MAX-offset) {
            __atomic_store_n(&ax_address_error,1,__ATOMIC_RELAXED); continue;
        }
        const uintptr_t address = first+offset;
        if (address < ax_output_address LOCAL_USERLOCAL_USER (address-ax_output_address)%sizeof(float) != 0 LOCAL_USERLOCAL_USER
            (address-ax_output_address)/sizeof(float) >= ax_output_count) {
            __atomic_store_n(&ax_address_error,1,__ATOMIC_RELAXED); continue;
        }
        __atomic_fetch_add(&ax_writes[(address-ax_output_address)/sizeof(float)],1,__ATOMIC_RELAXED);
    }
    svst1_f32(predicate,dst,value);
}
#define svst1 ax_checked_svst1
#include "conv2d.c"
#undef svst1

static unsigned long prefix_entries, tail_entries, rowpair_entries;
static unsigned long rowtriple_entries, rowquad_entries, rowseven_entries;
static uint64_t rowseven_worker_mask;
void __cyg_profile_func_enter(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *, void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn, void *caller) {
    (void)caller;
    if (fn == (void *)conv_sve_rowseven) {
        __atomic_fetch_add(&rowseven_entries,1,__ATOMIC_RELAXED);
        const int worker=omp_get_thread_num();
        if (worker<0 LOCAL_USERLOCAL_USER worker>=38) abort();
        __atomic_fetch_or(&rowseven_worker_mask,UINT64_C(1)<<worker,__ATOMIC_RELAXED);
    }
    if(fn==(void*)conv_sve_rowquad)__atomic_fetch_add(&rowquad_entries,1,__ATOMIC_RELAXED);
    if(fn==(void*)conv_sve_rowtriple)__atomic_fetch_add(&rowtriple_entries,1,__ATOMIC_RELAXED);
    if(fn==(void*)conv_sve_rowpair)__atomic_fetch_add(&rowpair_entries,1,__ATOMIC_RELAXED);
    if(fn==(void*)conv_sve_prefix)__atomic_fetch_add(&prefix_entries,1,__ATOMIC_RELAXED);
    if(fn==(void*)conv_sve_tail)__atomic_fetch_add(&tail_entries,1,__ATOMIC_RELAXED);
}
void __cyg_profile_func_exit(void *fn,void *caller){(void)fn;(void)caller;}

/* Retained direct kh<7 helper check, using distinct valid seven-row groups. */
static void direct_rowseven(const float *input,int height,int width,const float *kernel,int kh,int kw,float *output) {
    const int oh=height-kh+1,ow=width-kw+1;
    if((oh!=7&&oh!=28)LOCAL_USER|kh<1||kh>=7||kw<1)exit(7);
    const size_t stride=(size_t)width,outstride=(size_t)ow,groups=(size_t)oh/7;
#pragma omp parallel for schedule(static)
    for(size_t group=0;group<groups;++group){
        const size_t row=group*7;
        float *dst=output+row*outstride;
        conv_sve_rowseven(input+row*stride,stride,kernel,kh,kw,
            dst,dst+outstride,dst+2*outstride,dst+3*outstride,
            dst+4*outstride,dst+5*outstride,dst+6*outstride,ow);
    }
}
struct expected_entries { unsigned long entries; uint64_t mask; };
/* Independent inverse owner map: enumerate tiles, not production cursor ranges.
 * Empty-team partitions never appear as owners. q==0 reaches only the first arm. */
static struct expected_entries balanced_expectation(int ow,int kh,int oh,int lanes,int workers){
    struct expected_entries out={0,0};
    if(kh<7||oh<7)return out;
    const size_t tile=(size_t)3*lanes,cols=((size_t)ow+tile-1)/tile;
    const size_t groups=((size_t)oh+6)/7,n=groups*cols;
    const size_t q=n/(size_t)workers,r=n%(size_t)workers,cut=r*(q+1);
    for(size_t g=0;g<(size_t)oh/7;++g){
        size_t previous=SIZE_MAX;
        for(size_t col=0;col<cols;++col){
            const size_t k=g*cols+col;
            size_t owner;
            if(k<cut)owner=k/(q+1);
            else { if(q==0)abort(); owner=r+(k-cut)/q; }
            if(owner>=(size_t)workers)abort();
            if(owner!=previous){++out.entries;out.mask|=UINT64_C(1)<<owner;previous=owner;}
        }
    }
    return out;
}
static struct expected_entries direct_expectation(int oh,int workers){
    const unsigned long groups=(unsigned long)oh/7;
    const unsigned active=groups<(unsigned)workers?(unsigned)groups:(unsigned)workers;
    return (struct expected_entries){groups,(UINT64_C(1)<<active)-1};
}
static uint64_t dispatch_mask,direct_mask;
static unsigned long family_expected[3];
static int checked_entry_case(int ow,int kh,int kw,int oh,int pad,int leading,
                              struct expected_entries expected,uint64_t *aggregate){
    const unsigned long before=__atomic_load_n(&rowseven_entries,__ATOMIC_RELAXED);
    __atomic_store_n(&rowseven_worker_mask,0,__ATOMIC_RELAXED);
    if(!one_case(ow,kh,kw,oh,pad,leading))return 0;
    const unsigned long actual=__atomic_load_n(&rowseven_entries,__ATOMIC_RELAXED)-before;
    const uint64_t mask=__atomic_load_n(&rowseven_worker_mask,__ATOMIC_RELAXED);
    if(actual!=expected.entries||mask!=expected.mask){
        fprintf(stderr,"ENTRY_FAIL ow=%d kh=%d kw=%d oh=%d actual=%lu expected=%lu mask=%llu expected_mask=%llu\n",
            ow,kh,kw,oh,actual,expected.entries,(unsigned long long)mask,(unsigned long long)expected.mask);return 0;
    }
    *aggregate|=mask;return 1;
}
int main(int argc,char **argv){
    const int lanes=setup_config(argc,argv),workers=omp_get_max_threads();
    const int index=workers==1?0:workers==4?1:workers==38?2:-1;
    if(index<0)exit(5);
    /* Fixed before remote execution from independent owner-map enumeration. */
    const unsigned long expected_core[3]={756,1020,1386};
    const unsigned long expected_quad[3]={480,660,880};
    const unsigned long expected_balance[3]={2772,4488,21744};
    const unsigned long expected_total[3]={4008,6168,24010};
    const uint64_t expected_dispatch_mask=(UINT64_C(1)<<workers)-1;
    const uint64_t expected_direct_mask=workers==1?UINT64_C(1):UINT64_C(15);
    const int widths[]={3*lanes-1,3*lanes,3*lanes+1,6*lanes-1,6*lanes,6*lanes+1};
    const int heights[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,21,22,28};
    unsigned core=0,quad=0,balance=0,direct=0;
    checked_conv=conv2d;
    for(unsigned w=0;w<6;++w)for(int kh=6;kh<=8;++kh)for(int kw=1;kw<=3;++kw)for(unsigned h=0;h<18;++h){
        const struct expected_entries e=balanced_expectation(widths[w],kh,heights[h],lanes,workers);
        if(!checked_entry_case(widths[w],kh,kw,heights[h],1,0,e,&dispatch_mask))return 1;
        family_expected[0]+=e.entries;++core;
    }
    const int quad_heights[]={7,8,14,28};
    for(unsigned w=0;w<6;++w)for(int kh=7;kh<=8;++kh)for(int kw=4;kw<=8;++kw)for(unsigned h=0;h<4;++h){
        const struct expected_entries e=balanced_expectation(widths[w],kh,quad_heights[h],lanes,workers);
        if(!checked_entry_case(widths[w],kh,kw,quad_heights[h],1,0,e,&dispatch_mask))return 1;
        family_expected[1]+=e.entries;++quad;
    }
    const int tiles[]={1,2,3,4,37,38,39};
    const int balance_heights[]={7,8,9,10,11,12,13,14,15,27,28,29};
    const int balance_kw[]={1,4,7};
    for(unsigned t=0;t<7;++t)for(int delta=-1;delta<=1;++delta)for(unsigned h=0;h<12;++h)for(int kh=7;kh<=8;++kh)for(unsigned k=0;k<3;++k){
        const int ow=tiles[t]*3*lanes+delta,oh=balance_heights[h],kw=balance_kw[k];
        const struct expected_entries e=balanced_expectation(ow,kh,oh,lanes,workers);
        if(!checked_entry_case(ow,kh,kw,oh,1,0,e,&dispatch_mask))return 1;
        family_expected[2]+=e.entries;++balance;
    }
    const unsigned long dispatch_entries=__atomic_load_n(&rowseven_entries,__ATOMIC_RELAXED);
    printf("SVE_PREFIX_ACTUAL_ENTRIES=%lu SVE_TAIL_ACTUAL_ENTRIES=%lu\n",prefix_entries,tail_entries);
    printf("SVE_ROWPAIR_ACTUAL_ENTRIES=%lu SVE_ROWTRIPLE_ACTUAL_ENTRIES=%lu SVE_ROWQUAD_ACTUAL_ENTRIES=%lu\n",rowpair_entries,rowtriple_entries,rowquad_entries);
    printf("DISPATCH_MATRIX_COUNTS core=%u quad_boundary=%u balance=%u\n",core,quad,balance);
    printf("DISPATCH_EXPECTED_FAMILIES core=%lu quad_boundary=%lu balance=%lu\n",family_expected[0],family_expected[1],family_expected[2]);
    printf("DISPATCH_ROWSEVEN_ACTUAL_ENTRIES=%lu EXPECTED=%lu WORKER_MASK=%llu EXPECTED_MASK=%llu\n",dispatch_entries,expected_total[index],(unsigned long long)dispatch_mask,(unsigned long long)expected_dispatch_mask);
    if(core!=972||quad!=240||balance!=1512||family_expected[0]!=expected_core[index]LOCAL_USER|family_expected[1]!=expected_quad[index]LOCAL_USER|family_expected[2]!=expected_balance[index]LOCAL_USER|dispatch_entries!=expected_total[index]LOCAL_USER|dispatch_mask!=expected_dispatch_mask|LOCAL_USER!prefix_entries|LOCAL_USER!tail_entries|LOCAL_USER!rowpair_entries|LOCAL_USER!rowtriple_entries|LOCAL_USER!rowquad_entries)return 4;
    printf("PASS: %u dispatch cases; independent owner-map entries, bitwise reference and exactly-once SVE writes\n",core+quad+balance);
    checked_conv=direct_rowseven;
    const int direct_widths[]={3*lanes-1,3*lanes,3*lanes+1},direct_heights[]={7,28};
    for(unsigned w=0;w<3;++w)for(int kh=1;kh<=6;++kh)for(int kw=1;kw<=3;++kw)for(unsigned h=0;h<2;++h)for(int pad=0;pad<=1;++pad)for(int leading=0;leading<=1;++leading){
        const struct expected_entries e=direct_expectation(direct_heights[h],workers);
        if(!checked_entry_case(direct_widths[w],kh,kw,direct_heights[h],pad,leading,e,&direct_mask))return 1;
        ++direct;
    }
    const unsigned long direct_entries=__atomic_load_n(&rowseven_entries,__ATOMIC_RELAXED)-dispatch_entries;
    printf("DIRECT_ROWSEVEN_ACTUAL_ENTRIES=%lu EXPECTED=1080 WORKER_MASK=%llu EXPECTED_MASK=%llu\n",direct_entries,(unsigned long long)direct_mask,(unsigned long long)expected_direct_mask);
    if(direct!=432||direct_entries!=1080||direct_mask!=expected_direct_mask)return 4;
    printf("PASS: %u direct fallback cases; original guarded shapes, bitwise and exactly-once SVE writes\n",direct);
    printf("OUTPUT_EXACT_ONCE_CASES=%lu EXPECTED=3156 OUTPUT_VALUES=%llu ADDRESS_ERRORS=%u\n",ax_coverage_cases,ax_covered_values,ax_address_error);
    if(ax_coverage_cases!=3156||ax_address_error)return 4;
    return 0;
}
