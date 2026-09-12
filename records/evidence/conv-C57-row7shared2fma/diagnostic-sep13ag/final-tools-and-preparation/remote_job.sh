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
import os, pathlib, platform, ctypes
assert platform.system() == 'Linux' and platform.machine() == 'aarch64'
libc = ctypes.CDLL(None)
libc.getauxval.restype = ctypes.c_ulong
assert libc.getauxval(16) & (1 << 22), 'SVE hardware capability is required'
print('HWCAP_SVE=1')
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
printf 'CANDIDATE=C57-row7shared2fma\n'
stage compiler bash -c 'gcc --version; test "$(gcc -dumpfullversion -dumpversion)" = 10.3.1'
stage manifest bash -o pipefail -c 'sha256sum conv2d.c bench_conv.c run.sh README.md remote_job.sh | tee source-sha256.txt'
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
flags=(-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2)
# Original official benchmark remains unedited and noncontracting. Explicit
# candidate intrinsics alone may fuse; never globally enable fast-math.
stage build gcc "${flags[@]}" bench_conv.c conv2d.c -o conv2d_test -lm
stage assembly-candidate gcc "${flags[@]}" -S conv2d.c -o conv2d-sve.s
stage assembly-reference gcc "${flags[@]}" -S bench_conv.c -o bench-reference.s
: > case-exits.txt
: > numerical-summary.txt
failed=0
run_original() {
    local suite=$1 number=$2 code check
    shift 2
    local log="suite-${suite}-case-${number}.log"
    # Unlike the production early-stop runner, retain every predetermined case.
    # The executable and its arguments, reference, tolerance and timer are original.
    if ./conv2d_test "$@" 1 > "$log" 2>&1; then code=0; else code=$?; fi
    cat "$log"
    printf 'SUITE=%s CASE=%s EXIT=%s\n' "$suite" "$number" "$code" >> case-exits.txt
    if awk '$NF=="PASS" {pass++} $NF=="FAIL" {fail++} END {exit !(pass==1 && fail==0)}' "$log"; then check=0; else check=1; fi
    printf 'SUITE=%s CASE=%s PROCESS_EXIT=%s PASS_CHECK=%s\n' "$suite" "$number" "$code" "$check" >> numerical-summary.txt
    if (( code != 0 || check != 0 )); then failed=1; fi
    return 0
}
for suite in 1 2 3; do
    run_original "$suite" 1 4096 6144 39 39
    run_original "$suite" 2 6144 4096 41 41
    run_original "$suite" 3 4256 6390 55 55
    run_original "$suite" 4 6390 4256 81 81
done
cat numerical-summary.txt
printf 'OFFICIAL_CASES_PLANNED=12\nNUMERICAL_FAILURE=%s\n' "$failed"
# Numerical FAIL is an actual failure; keep all 12 raw logs and a nonzero wrapper.
stage numerical-check test "$failed" -eq 0
stage complete printf 'FMA_FEASIBILITY_COMPLETE=1\n'
