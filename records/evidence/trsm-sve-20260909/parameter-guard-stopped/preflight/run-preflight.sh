#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
bash ./environment-probe.sh
grep -q "OPENBLAS_CONFIG=OpenBLAS 0.3.28" environment-probe.log
grep -q "OPENBLAS_THREADS=38" environment-probe.log
flags=(-O3 -ffp-contract=off -fopenmp -mcpu=generic)
for kind in panel update; do
    extra=()
    [[ $kind != panel ]] || extra=(-DCHECK_PANEL)
    gcc "${flags[@]}" -finstrument-functions "${extra[@]}" check-sve.c -lm -o "check-sve-$kind"
    OMP_NUM_THREADS=1 "./check-sve-$kind"
    OMP_NUM_THREADS=4 "./check-sve-$kind"
    gcc "${flags[@]}" -Dposix_memalign=trsm_test_alloc_fail -c "../T3-sve$kind-r1/source/trsm.c" -o "trsm-$kind-fail.o"
    gcc "${flags[@]}" check-trsm.c fail-alloc.c "trsm-$kind-fail.o" -lm -o "check-$kind-fail"
    OMP_NUM_THREADS=4 "./check-$kind-fail"
    gcc "${flags[@]}" -S "../T3-sve$kind-r1/source/trsm.c" -o "trsm-$kind.s"
done
echo TRSM_PREFLIGHT_COMPLETE=1
