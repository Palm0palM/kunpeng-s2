#!/usr/bin/env bash
set -euo pipefail
kml251_here=$(cd "$(dirname "$0")" && pwd)
[[ $# == 1 || $# == 2 ]] || { echo 'Usage: run-three-suites.sh SOURCE_DIR [OUTPUT_DIR]' >&2; exit 2; }
kml251_source=$(cd "$1" && pwd)
kml251_out=$(python3 - "${2:-$kml251_here/results}" "$kml251_source" <<'PY'
from pathlib import Path
import sys
out=Path(sys.argv[1]).resolve();source=Path(sys.argv[2]).resolve()
if out==source or source in out.parents:raise SystemExit('Run logs must be outside source directory')
print(out)
PY
)
source "$kml251_here/target-environment.sh"
mkdir "$kml251_out"
trap 'kml251_exit=$?; printf "%s\n" "$kml251_exit" > "$kml251_out/exit-code.txt"' EXIT
{
    printf 'HOST=%s\nARCH=%s\nNUMA_NODE=%s\nALLOWED_CPUS=%s\n' "$(hostname)" "$(uname -m)" "$NUMA_NODE" "$KML251_ALLOWED_CPUS"
    printf 'OMP_NUM_THREADS=38\nOMP_DYNAMIC=FALSE\nOMP_PROC_BIND=close\nOMP_PLACES=cores\nCPU_TARGET=generic\nTEST_RUNS=3\nBENCH_REPEATS=3\n'
    printf 'REFERENCE=Huawei KML 25.1.0 GCC kblas multi; not required KML 25.2.0\n'
    printf 'KML251_ROOT=%s\nKML251_ARCH=%s\nKML251_LIBDIR=%s\n' "$KML251_ROOT" "$KML251_ARCH" "$KML251_LIBDIR"
    printf 'CPATH=%s\nLIBRARY_PATH=%s\nLD_LIBRARY_PATH=%s\n' "$CPATH" "$LIBRARY_PATH" "$LD_LIBRARY_PATH"
    printf 'KBLAS_LIB=unset\nVALIDATION_POLICY=user-requested-no-hash\n'
    "$CC" --version
    lscpu
    numactl --show
} > "$kml251_out/environment.log" 2>&1
if bash "$kml251_here/probe.sh" "$kml251_source" "$kml251_out"; then
    cat "$kml251_out/probe.log"
else
    kml251_exit=$?
    [[ ! -f "$kml251_out/probe.log" ]] || cat "$kml251_out/probe.log"
    exit "$kml251_exit"
fi
printf 'BENCH_JOB_BEGIN %s\n' "$(date -u +%FT%TZ)" > "$kml251_out/benchmark.log"
cat "$kml251_out/environment.log" | tee -a "$kml251_out/benchmark.log"
for kml251_round in 1 2 3; do
    printf '\nBENCH_REPEAT %s/3 BEGIN\n' "$kml251_round" | tee -a "$kml251_out/benchmark.log"
    (cd "$kml251_source" && bash ./run.sh) 2>&1 | tee -a "$kml251_out/benchmark.log"
    # Audit the binary emitted by the unmodified runner; all evidence stays outside source.
    python3 "$kml251_here/audit-dependencies.py" "$kml251_source/trsm_test" "$kml251_out/benchmark-ldd-$kml251_round.log"
    printf 'BENCH_REPEAT %s/3 END\n' "$kml251_round" | tee -a "$kml251_out/benchmark.log"
done
python3 - "$kml251_out/benchmark.log" <<'PY'
from pathlib import Path
import re,sys
text=Path(sys.argv[1]).read_text()
if re.search(r'\bFAIL\b',text):raise SystemExit('Official log contains FAIL')
rows=[]
for line in text.splitlines():
    m=re.fullmatch(r'\s*(\d+)\s*x\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+PASS\s*',line)
    if m:
        a,b,ms,gf,err=m.groups()
        if not (0<float(ms)<float('inf') and 0<float(gf)<float('inf') and 0<=float(err)<=1e-12):raise SystemExit('Invalid official metric or precision')
        rows.append((int(a),int(b)))
if rows!=[(512,19968),(2432,17024),(17024,512)]*3:raise SystemExit('Expected exactly three ordered official suites')
print('KML251_OFFICIAL_ROWS_PASS=9')
PY
printf 'BENCH_JOB_END %s\n' "$(date -u +%FT%TZ)" | tee -a "$kml251_out/benchmark.log"
printf 'KML251_THREE_SUITES_COMPLETE=1\n'
