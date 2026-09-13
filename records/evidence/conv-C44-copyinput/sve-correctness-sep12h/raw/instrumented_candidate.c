/* Diagnostic only: include standard headers before redirecting names so
 * their declarations and all allocations in the separate guard stay original. */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <arm_sve.h>
#include <sys/auxv.h>
#include <asm/hwcap.h>
#include "copy_probe.h"
#define malloc candidate_malloc
#define free candidate_free
#define memcpy candidate_memcpy
#include "conv2d.c"
#undef memcpy
#undef free
#undef malloc
