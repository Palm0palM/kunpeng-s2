#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
bash ./environment-probe.sh
grep -q "OPENBLAS_CONFIG=OpenBLAS 0.3.28" environment-probe.log
grep -q "OPENBLAS_THREADS=38" environment-probe.log
flags=(-O3 -ffp-contract=off -fopenmp -mcpu=generic)
gcc "${flags[@]}" -finstrument-functions check-sve.c -lm -o check-sve-24rows
OMP_NUM_THREADS=1 ./check-sve-24rows
OMP_NUM_THREADS=4 ./check-sve-24rows
for candidate in T7-sve24rows T7-diagpanel; do
    source=../"$candidate"/source/trsm.c
    gcc "${flags[@]}" check-trsm.c "$source" -lm -o check-normal
    OMP_NUM_THREADS=38 ./check-normal
    if [[ "$candidate" == T7-diagpanel ]]; then
        OMP_NUM_THREADS=1 ./check-normal
        OMP_NUM_THREADS=4 ./check-normal
    fi
    gcc "${flags[@]}" -Dposix_memalign=trsm_test_alloc_fail -c "$source" -o trsm-fail.o
    gcc "${flags[@]}" check-trsm.c fail-alloc.c trsm-fail.o -lm -o check-fail
    OMP_NUM_THREADS=4 ./check-fail
    gcc "${flags[@]}" -Dgetauxval=trsm_test_no_sve -c "$source" -o trsm-no-sve.o
    gcc "${flags[@]}" check-trsm.c no-sve.c trsm-no-sve.o -lm -o check-no-sve
    OMP_NUM_THREADS=4 ./check-no-sve
done
gcc "${flags[@]}" -S ../T7-sve24rows/source/trsm.c -o trsm-24rows.s
gcc "${flags[@]}" -S ../T7-diagpanel/source/trsm.c -o trsm-diagpanel.s
gcc "${flags[@]}" check-diag.c -lm -o check-diag
OMP_NUM_THREADS=1 ./check-diag
OMP_NUM_THREADS=4 ./check-diag
echo TRSM_PREFLIGHT_COMPLETE=1
