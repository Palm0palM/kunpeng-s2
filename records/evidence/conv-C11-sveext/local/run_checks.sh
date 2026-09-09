#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
clang --version > environment.log
uname -sm >> environment.log
{
set -x
clang -O3 -g -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off -fsanitize=undefined -fno-sanitize-recover=all -Xpreprocessor -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -Wl,-rpath,/opt/homebrew/opt/libomp/lib -lomp -lm -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2 check_conv_guard_extended.c ../source/conv2d.c -o check_conv_guard_extended
} > build.log 2>&1
for threads in 1 4; do
 OMP_NUM_THREADS="$threads" OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1 ./check_conv_guard_extended > "guard-extended-${threads}thread.log" 2>&1
done
