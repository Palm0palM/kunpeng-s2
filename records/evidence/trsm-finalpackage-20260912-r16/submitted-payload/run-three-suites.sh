#!/usr/bin/env bash
set -euo pipefail
kml251_here=$(cd "$(dirname "$0")" && pwd)
[[ $# == 2 ]] || { echo 'Usage: run-three-suites.sh SOURCE_DIR OUTPUT_DIR' >&2; exit 2; }
kml251_source=$(cd "$1" && pwd)
kml251_out=$(python3 - "$2" "$kml251_source" <<'PY'
from pathlib import Path
import sys
out = Path(sys.argv[1]).resolve()
source = Path(sys.argv[2]).resolve()
if out == source or source in out.parents:
    raise SystemExit('Run logs must be outside source directory')
print(out)
PY
)
source "$kml251_here/target-environment.sh"
export KBLAS_LIB='' BENCH_REPEATS=3
[[ $("$CC" -dumpfullversion) == 12.3.1 ]]
mkdir "$kml251_out"
trap 'kml251_exit=$?; printf "%s\n" "$kml251_exit" > "$kml251_out/exit-code.txt"' EXIT
python3 - "$kml251_out" <<'PY'
from pathlib import Path
import json
import os
import platform
import socket
import sys
out = Path(sys.argv[1])
keys = ('OMP_NUM_THREADS', 'OMP_DYNAMIC', 'OMP_PROC_BIND', 'OMP_PLACES', 'CPU_TARGET',
        'TEST_RUNS', 'KBLAS_LIB', 'CC', 'KML251_ROOT', 'KML251_ARCH', 'KML251_LIBDIR',
        'COMPILER_ROOT', 'GOMP_LIBRARY', 'CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH', 'COMPILER_VERSION')
env = {key: os.environ[key] for key in keys}
settings = dict(bench_repeats=3, environment=env)
with (out / 'runtime-settings.json').open('x') as handle:
    handle.write(json.dumps(settings, indent=2) + '\n')
fields = dict(HOST=socket.gethostname(), ARCH=platform.machine(),
              NUMA_NODE=os.environ['NUMA_NODE'], ALLOWED_CPUS=os.environ['KML251_ALLOWED_CPUS'],
              JOB_ID=os.environ['TRSM_SCHEDULER_JOB_ID'], BENCH_REPEATS='3', **env)
with (out / 'environment.log').open('x') as handle:
    handle.write(''.join('{}={}\n'.format(key, value) for key, value in fields.items()))
    handle.write('REFERENCE=Huawei KML 25.1.0; not specified KML 25.2.0\n')
    handle.write('VALIDATION_POLICY=no_hash_at_user_request\n')
PY
{
    "$CC" --version
    lscpu
    numactl --show
} >> "$kml251_out/environment.log" 2>&1
if bash "$kml251_here/probe.sh" "$kml251_source" "$kml251_out"; then
    cat "$kml251_out/probe.log"
else
    kml251_exit=$?
    [[ ! -f "$kml251_out/probe.log" ]] || cat "$kml251_out/probe.log"
    exit "$kml251_exit"
fi
printf 'BENCH_JOB_BEGIN %s\n' "$(date -u +%FT%TZ)" > "$kml251_out/benchmark.log"
tee -a "$kml251_out/benchmark.log" < "$kml251_out/environment.log"
for kml251_round in 1 2 3; do
    printf '\nBENCH_REPEAT %s/3 BEGIN\n' "$kml251_round" | tee -a "$kml251_out/benchmark.log"
    (cd "$kml251_source" && bash ./run.sh) 2>&1 | tee -a "$kml251_out/benchmark.log"
    python3 "$kml251_here/audit-dependencies.py" "$kml251_source/trsm_test" \
        "$kml251_out/benchmark-ldd-$kml251_round.log" "$kml251_round" "$kml251_out/linkage.log"
    printf 'BENCH_REPEAT %s/3 END\n' "$kml251_round" | tee -a "$kml251_out/benchmark.log"
done
python3 - "$kml251_out/benchmark.log" <<'PY'
from pathlib import Path
import math
import re
import sys
text = Path(sys.argv[1]).read_text()
if re.search(r'\bFAIL\b', text):
    raise SystemExit('Official log contains FAIL')
blocks = re.findall(r'^BENCH_REPEAT ([123])/3 BEGIN\n(.*?)^BENCH_REPEAT \1/3 END$', text, re.M | re.S)
if [repeat for repeat, block in blocks] != ['1', '2', '3']:
    raise SystemExit('Missing or invalid official suite boundaries')
rows = []
for line in text.splitlines():
    match = re.fullmatch(r'\s*(\d+)\s*x\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+PASS\s*', line)
    if match:
        m, n, ms, gflops, error = match.groups()
        values = list(map(float, (ms, gflops, error)))
        if not all(map(math.isfinite, values)) or values[0] <= 0 or values[1] <= 0 or not 0 <= values[2] <= 1e-12:
            raise SystemExit('Invalid official metric or original precision')
        rows.append((int(m), int(n)))
if rows != [(512, 19968), (2432, 17024), (17024, 512)] * 3:
    raise SystemExit('Expected exactly three complete ordered official suites')
print('KML251_OFFICIAL_ROWS_PASS=9')
PY
printf 'BENCH_JOB_END %s\n' "$(date -u +%FT%TZ)" | tee -a "$kml251_out/benchmark.log"
printf 'KML251_THREE_SUITES_COMPLETE=1\n'
