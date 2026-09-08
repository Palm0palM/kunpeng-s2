#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec > >(tee probe.log) 2>&1
set -x
date -u
gcc --version
sha256sum conv2d.c check_conv_guard.c check_sve_dispatch.c remote_job.sh
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check_conv_guard.c conv2d.c -o check_conv_guard
OMP_NUM_THREADS=1 ./check_conv_guard
OMP_NUM_THREADS=4 ./check_conv_guard
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -finstrument-functions check_sve_dispatch.c -o check_sve_dispatch
OMP_NUM_THREADS=4 ./check_sve_dispatch
gcc -O3 -std=c11 -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -S conv2d.c -o conv2d-sve.s
printf 'PROBE_COMPLETE=1\n'
printf '0\n' > exit-code.txt
