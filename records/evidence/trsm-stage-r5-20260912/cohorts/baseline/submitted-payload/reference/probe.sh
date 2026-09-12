#!/usr/bin/env bash
set -euo pipefail
kml251_here=$(cd "$(dirname "$0")" && pwd)
[[ $# == 2 ]] || { echo 'Usage: probe.sh SOURCE_DIR OUTPUT_DIR' >&2; exit 2; }
kml251_source=$(cd "$1" && pwd)
kml251_out=$(python3 - "$2" "$kml251_source" <<'PY'
from pathlib import Path
import sys
out=Path(sys.argv[1]).resolve();source=Path(sys.argv[2]).resolve()
if out==source or source in out.parents:raise SystemExit('Probe logs must be outside source directory')
print(out)
PY
)
source "$kml251_here/target-environment.sh"
mkdir -p "$kml251_out"
[[ ! -e "$kml251_out/probe.log" ]] || { echo 'Existing probe log: use a fresh output directory' >&2; exit 2; }
exec > "$kml251_out/probe.log" 2>&1
printf 'KML251_PROBE_BEGIN=%s\n' "$(date -u +%FT%TZ)"
printf 'REFERENCE=Huawei KML 25.1.0 GCC kblas multi; not required KML 25.2.0\n'
printf 'ROOT=%s\nARCH_SELECTION=%s\nLIBDIR=%s\n' "$KML251_ROOT" "$KML251_ARCH" "$KML251_LIBDIR"
printf 'KBLAS_LIB_IS_UNSET=1\n'
[[ -f "$kml251_source/bench_trsm.c" && -f "$kml251_source/trsm.c" && -f "$kml251_source/run.sh" ]]
for file in "$KML251_ROOT/modulefiles/kml" "$KML251_ROOT/modulefiles/kblas/multi" "$KML251_ROOT/env/setvars.sh"; do
    printf '\nPACKAGE_TEXT=%s\n' "$file"
    sed -n '1,240p' "$file"
done
printf '\nPACKAGE_README_FILES\n'
find "$KML251_ROOT" -maxdepth 5 -type f \( -iname 'readme*' -o -iname '*release*note*' \) -print
printf '\nPACKAGE_KBLAS_LAYOUT\n'
find "$KML251_ROOT/gcclib" -maxdepth 5 -name 'libkblas*' -printf '%y %p -> %l\n'
printf '\nREQUIRED_HEADER_DECLARATIONS\n'
grep -n -A 4 -B 3 -E 'cblas_dgemm|cblas_domatcopy|BlasGetNumThreads|KBLASGetVersion|softwareVersion' "$KML251_ROOT/include/kblas.h"
printf '\nELF_DYNAMIC\n'
readelf -d "$KML251_LIBDIR/libkblas.so.25.1.0"
printf '\nREQUIRED_DYNAMIC_SYMBOLS\n'
readelf --dyn-syms --wide "$KML251_LIBDIR/libkblas.so.25.1.0" | grep -E 'cblas_dgemm|cblas_domatcopy|BlasGetNumThreads|KBLASGetVersion'
printf '\nACTUAL_COMPILER\n'
"$CC" --version
# -H records the real KML header selected through CPATH; no compat header or OpenBLAS.
"$CC" -O3 -ffp-contract=off -fopenmp -mcpu=generic -H "$kml251_here/required-symbols.c" -o "$kml251_out/required-symbols" -lm -ldl -lkblas
python3 "$kml251_here/audit-dependencies.py" "$kml251_out/required-symbols" "$kml251_out/probe-ldd.log"
numactl --cpunodebind="$NUMA_NODE" --membind="$NUMA_NODE" "$kml251_out/required-symbols"
printf 'KML251_PROBE_COMPLETE=1\n'
