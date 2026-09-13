#ifndef CONV_COPY_PROBE_H
#define CONV_COPY_PROBE_H
#include <stddef.h>
void copy_probe_set_failure(int enabled);
void copy_probe_begin(const float *input, int height, int width,
                      const float *kernel, int kh, int kw,
                      float *output, const float *reference, size_t count);
int copy_probe_end(void);
int copy_probe_report(size_t cases, size_t eligible, size_t copies);
void *candidate_malloc(size_t bytes);
void candidate_free(void *pointer);
void *candidate_memcpy(void *destination, const void *source, size_t bytes);
#endif
