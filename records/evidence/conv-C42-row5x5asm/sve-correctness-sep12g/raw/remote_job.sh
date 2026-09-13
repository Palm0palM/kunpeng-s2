#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec 3>&1 4>&2
exec > >(tee probe.log) 2>&1
LOG_PID=$!
finish() {
    local code=$? log_code=0
    trap - EXIT
    exec 1>&3 2>&4 3>&- 4>&-
    wait "$LOG_PID" || log_code=$?
    if (( code == 0 && log_code != 0 )); then code=$log_code; fi
    printf '%s\n' "$code" > exit-code.txt
    exit "$code"
}
trap finish EXIT
set -x
# Root/checks must launch this file through the scheduler, never on the laptop
# or login node. Validate the expected allocation before compiling anything.
python3 - <<'CHECK_ALLOCATION'
import os,pathlib,platform
assert platform.system()=='Linux' and platform.machine()=='aarch64'
allowed=set(os.sched_getaffinity(0))
assert len(allowed)==38, ('Expected38CPUs',sorted(allowed))
def cpus(text):
    result=set()
    for part in text.strip().split(','):
        if not part: continue
        ends=part.split('-'); result.update(range(int(ends[0]),int(ends[-1])+1))
    return result
nodes=[p.parent.name for p in pathlib.Path('/sys/devices/system/node').glob('node[0-9]*/cpulist') if allowed<=cpus(p.read_text())]
assert len(nodes)==1, ('ExpectedSingleNUMA',nodes)
print('ALLOWED_CPUS='+','.join(map(str,sorted(allowed))))
print('NUMA_NODE='+nodes[0])
CHECK_ALLOCATION
source candidate.env
[[ "$EXPECTED_ACC" == 5 && "$EXPECTED_FULL" == 3776 && "$EXPECTED_DISPATCH" == 504 && "$EXPECTED_DIRECT" == 288 ]]
[[ "$EXPECTED_DISPATCH_ROWQUINT_ENTRIES" == 528 && "$EXPECTED_DIRECT_ROWQUINT_ENTRIES" == 720 ]]
date -u
hostname
gcc --version
gcc -dumpfullversion -dumpversion > compiler-version.txt
[[ "$(cat compiler-version.txt)" == 10.3.1 ]]
sha256sum conv2d.c check_conv_guard.c check_sve_dispatch.c remote_job.sh candidate.env > source-sha256.txt
cat source-sha256.txt
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
flags=(-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp "-DEXPECTED_ACC=$EXPECTED_ACC")
# Production translation unit is unchanged, separately compiled without instrumentation.
gcc "${flags[@]}" check_conv_guard.c conv2d.c -o check_conv_guard > build-guard.log 2>&1
for bytes in 16 32 64; do
    for threads in 1 4; do
        OMP_NUM_THREADS="$threads" ./check_conv_guard "$bytes" | tee "guard-vl${bytes}-t${threads}.log"
    done
done
# Only this diagnostic executable receives function-entry instrumentation.
gcc "${flags[@]}" -finstrument-functions check_sve_dispatch.c -o check_sve_dispatch > build-dispatch.log 2>&1
for bytes in 16 32 64; do
    for threads in 1 4; do
        OMP_NUM_THREADS="$threads" ./check_sve_dispatch "$bytes" | tee "dispatch-vl${bytes}-t${threads}.log"
    done
done
gcc "${flags[@]}" -S conv2d.c -o conv2d-sve.s > build-assembly.log 2>&1
printf 'SANITIZER_STATUS=NOT_RUN; guarded allocation edges and bitwise reference are used\n'
printf 'EXPECTED_TOTAL_CHECKS=27408\n'
printf 'PROBE_COMPLETE=1\n'
