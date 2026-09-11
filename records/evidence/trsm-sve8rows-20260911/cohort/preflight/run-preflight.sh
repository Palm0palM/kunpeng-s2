#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
bash ./environment-probe.sh
grep -q "OPENBLAS_CONFIG=OpenBLAS 0.3.28" environment-probe.log
grep -q "OPENBLAS_THREADS=38" environment-probe.log
flags=(-O3 -ffp-contract=off -fopenmp -mcpu=generic)
gcc "${flags[@]}" -finstrument-functions check-sve.c -lm -o check-sve-8rows
OMP_NUM_THREADS=1 ./check-sve-8rows
OMP_NUM_THREADS=4 ./check-sve-8rows
source=../T4-sve8rows/source/trsm.c
gcc "${flags[@]}" -Dposix_memalign=trsm_test_alloc_fail -c "$source" -o trsm-fail.o
gcc "${flags[@]}" check-trsm.c fail-alloc.c trsm-fail.o -lm -o check-fail
OMP_NUM_THREADS=4 ./check-fail
gcc "${flags[@]}" -Dgetauxval=trsm_test_no_sve -c "$source" -o trsm-no-sve.o
gcc "${flags[@]}" check-trsm.c no-sve.c trsm-no-sve.o -lm -o check-no-sve
OMP_NUM_THREADS=4 ./check-no-sve
gcc "${flags[@]}" -S "$source" -o trsm-8rows.s
echo TRSM_PREFLIGHT_COMPLETE=1
