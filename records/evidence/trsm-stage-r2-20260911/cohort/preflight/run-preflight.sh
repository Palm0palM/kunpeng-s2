#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
bash ./environment-probe.sh
grep -q "OPENBLAS_CONFIG=OpenBLAS 0.3.28" environment-probe.log
grep -q "OPENBLAS_THREADS=38" environment-probe.log
flags=(-O3 -ffp-contract=off -fopenmp -mcpu=generic)
gcc "${flags[@]}" -finstrument-functions check-sve.c -lm -o check-sve-16rows
OMP_NUM_THREADS=1 ./check-sve-16rows
OMP_NUM_THREADS=4 ./check-sve-16rows
source=../T5-sve16rows/source/trsm.c
gcc "${flags[@]}" -Dposix_memalign=trsm_test_alloc_fail -c "$source" -o trsm-fail.o
gcc "${flags[@]}" check-trsm.c fail-alloc.c trsm-fail.o -lm -o check-fail
OMP_NUM_THREADS=4 ./check-fail
gcc "${flags[@]}" -Dgetauxval=trsm_test_no_sve -c "$source" -o trsm-no-sve.o
gcc "${flags[@]}" check-trsm.c no-sve.c trsm-no-sve.o -lm -o check-no-sve
OMP_NUM_THREADS=4 ./check-no-sve
gcc "${flags[@]}" -S "$source" -o trsm-16rows.s
source=../T5-panelpair/source/trsm.c
gcc "${flags[@]}" -DCHECK_PANELPAIR check-trsm.c "$source" -lm -o check-panelpair
OMP_NUM_THREADS=1 ./check-panelpair
OMP_NUM_THREADS=4 ./check-panelpair
OMP_NUM_THREADS=38 ./check-panelpair
gcc "${flags[@]}" -Dposix_memalign=trsm_test_alloc_fail -c "$source" -o panelpair-fail.o
gcc "${flags[@]}" -DCHECK_PANELPAIR check-trsm.c fail-alloc.c panelpair-fail.o -lm -o check-panelpair-fail
OMP_NUM_THREADS=1 ./check-panelpair-fail
OMP_NUM_THREADS=4 ./check-panelpair-fail
gcc "${flags[@]}" -S "$source" -o trsm-panelpair.s
echo TRSM_PREFLIGHT_COMPLETE=1
