#include <stddef.h>
#include <errno.h>
int trsm_test_alloc_fail(void **ptr,size_t alignment,size_t bytes)
{
    (void)ptr;(void)alignment;(void)bytes;
    return ENOMEM;
}
