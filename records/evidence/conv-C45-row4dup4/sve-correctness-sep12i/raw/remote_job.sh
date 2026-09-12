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
: > stage-exits.txt
stage() {
    local name=$1 code
    shift
    set +e
    "$@"
    code=$?
    set -e
    printf 'STAGE=%s EXIT=%s\n' "$name" "$code" | tee -a stage-exits.txt
    return "$code"
}
# Do not compile or execute on the laptop or login node.
stage allocation python3 - <<'CHECK_ALLOCATION'
import os, pathlib, platform
assert platform.system() == 'Linux' and platform.machine() == 'aarch64'
allowed = set(os.sched_getaffinity(0))
assert len(allowed) == 38, ('Expected38CPUs', sorted(allowed))
def cpus(text):
    result = set()
    for part in text.strip().split(','):
        if not part: continue
        bounds = part.split('-')
        result.update(range(int(bounds[0]), int(bounds[-1]) + 1))
    return result
nodes = [p.parent.name for p in pathlib.Path('/sys/devices/system/node').glob('node[0-9]*/cpulist')
         if allowed <= cpus(p.read_text())]
assert len(nodes) == 1, ('ExpectedSingleNUMA', nodes)
print('ALLOWED_CPUS=' + ','.join(map(str, sorted(allowed))))
print('NUMA_NODE=' + nodes[0])
CHECK_ALLOCATION
source candidate.env
[[ "$CANDIDATE" == C45-row4dup4 && "$EXPECTED_ACC" == 4 && "$CHECK_ROWTRIPLE" == 1 && "$CHECK_ROWQUAD" == 1 ]]
[[ "$EXPECTED_FULL" == 20164 && "$EXPECTED_DISPATCH" == 96 && "$EXPECTED_TOTAL" == 121560 ]]
printf 'CANDIDATE=%s\n' "$CANDIDATE"
date -u
hostname
compiler_check() {
    gcc --version || return "$?"
    gcc -dumpfullversion -dumpversion > compiler-version.txt || return "$?"
    [[ "$(cat compiler-version.txt)" == 10.3.1 ]]
}
stage compiler compiler_check
write_manifest() {
    sha256sum conv2d.c check_conv_guard.c check_sve_dispatch.c remote_job.sh candidate.env > source-sha256.txt || return "$?"
    cat source-sha256.txt
}
stage manifest write_manifest
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
flags=(-O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp "-DEXPECTED_ACC=$EXPECTED_ACC" "-DCHECK_ROWTRIPLE=$CHECK_ROWTRIPLE" "-DCHECK_ROWQUAD=$CHECK_ROWQUAD")
build_logged() {
    local logfile=$1
    shift
    printf 'BUILD_COMMAND:'
    printf ' %q' "$@"
    printf '\n'
    "$@" > "$logfile" 2>&1
}
run_guard() {
    local bytes=$1 threads=$2
    OMP_NUM_THREADS="$threads" ./check_conv_guard "$bytes" | tee "guard-vl${bytes}-t${threads}.log"
}
run_dispatch() {
    local bytes=$1 threads=$2
    OMP_NUM_THREADS="$threads" ./check_sve_dispatch "$bytes" smoke | tee "dispatch-vl${bytes}-t${threads}.log"
}
# Uninstrumented candidate and scalar guard are separate translation units.
stage build-guard build_logged build-guard.log gcc "${flags[@]}" check_conv_guard.c conv2d.c -o check_conv_guard
for bytes in 16 32 64; do
    for threads in 1 4; do
        stage "guard-vl${bytes}-t${threads}" run_guard "$bytes" "$threads"
    done
done
# This separate executable alone receives entry instrumentation; never time it.
stage build-dispatch build_logged build-dispatch.log gcc "${flags[@]}" -finstrument-functions check_sve_dispatch.c -o check_sve_dispatch
for bytes in 16 32 64; do
    for threads in 1 4; do
        stage "dispatch-vl${bytes}-t${threads}" run_dispatch "$bytes" "$threads"
    done
done
stage build-assembly build_logged build-assembly.log gcc "${flags[@]}" -S conv2d.c -o conv2d-sve.s
printf 'SANITIZER_STATUS=NOT_RUN; guard pages and bitwise reference checks only\n'
printf 'EXPECTED_TOTAL_CHECKS=%s\n' "$EXPECTED_TOTAL"
stage complete printf 'PROBE_COMPLETE=1\n'
