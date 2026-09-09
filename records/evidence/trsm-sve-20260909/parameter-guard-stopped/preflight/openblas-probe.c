#include <stdio.h>
extern char *openblas_get_config(void);
extern int openblas_get_parallel(void);
extern int openblas_get_num_threads(void);
int main(void) {
    printf("OPENBLAS_CONFIG=%s\n",openblas_get_config());
    printf("OPENBLAS_PARALLEL=%d\n",openblas_get_parallel());
    printf("OPENBLAS_THREADS=%d\n",openblas_get_num_threads());
    return 0;
}
