#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec 3>&1 4>&2
exec > >(tee probe.log) 2>&1
LOG_PID=$!
STAGE=allocation
finish() {
    local code=$? log_code=0
    trap - EXIT
    printf 'STAGE=%s EXIT=%s\n' "$STAGE" "$code" >> stage-exits.txt
    exec 1>&3 2>&4 3>&- 4>&-
    wait "$LOG_PID" || log_code=$?
    if (( code == 0 && log_code != 0 )); then code=$log_code; fi
    printf '%s\n' "$code" > exit-code.txt
    exit "$code"
}
trap finish EXIT
complete_stage() { printf 'STAGE=%s EXIT=0\n' "$STAGE" >> stage-exits.txt; }
run_build_command() { printf 'BUILD_COMMAND:'; printf ' %q' "$@"; printf '\n'; "$@"; }
set -x
# Reject local/login-node execution before any compile or convolution work.
python3 - <<'CHECK_ALLOCATION'
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

complete_stage
source candidate.env
[[ "$EXPECTED_ACC" == 4 && "$CHECK_ROWTRIPLE" == 1 && "$CHECK_ROWQUAD" == 1 ]]
case "$CANDIDATE:$COPY_EXPECT_PADDED" in C43-padinput:1|C44-copyinput:0) ;; *) exit 2;; esac
STAGE=source-manifest
sha256sum README.md bench_conv.c conv2d.c run.sh check_conv_guard.c copy_probe.h copy_probe.c instrumented_candidate.c candidate.env remote_job.sh > source-sha256.txt
cat source-sha256.txt
date -u
hostname
gcc --version
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
KERNEL_FLAGS=(-O3 -std=c11 -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -DCONV_BLOCK=32 -DCONV_KERNEL_UNROLL=2)
GUARD_FLAGS=("${KERNEL_FLAGS[@]}" -D_DEFAULT_SOURCE -DEXPECTED_ACC=4 -DCHECK_ROWTRIPLE=1 -DCHECK_ROWQUAD=1)
printf 'Threads=%s Bind=%s Places=%s CPU_TARGET=generic\n' "$OMP_NUM_THREADS" "$OMP_PROC_BIND" "$OMP_PLACES" > environment.log
gcc --version >> environment.log
complete_stage
STAGE=production-kernel
run_build_command gcc "${KERNEL_FLAGS[@]}" -c conv2d.c -o production-conv2d.o > build-production.log 2>&1
complete_stage
STAGE=production-guard
run_build_command gcc "${GUARD_FLAGS[@]}" -c check_conv_guard.c -o production-guard.o > build-guard.log 2>&1
run_build_command gcc "${KERNEL_FLAGS[@]}" production-guard.o production-conv2d.o -o check_conv_guard -lm >> build-guard.log 2>&1
complete_stage
STAGE=production-assembly
run_build_command gcc "${KERNEL_FLAGS[@]}" -S conv2d.c -o conv2d-sve.s > build-assembly.log 2>&1
objdump -d production-conv2d.o > production-conv2d-objdump.log
sha256sum production-conv2d.o > production-object-sha256.txt
complete_stage
for bytes in 16 32 64; do
    for threads in 1 4; do
        STAGE="production-guard-vl${bytes}-t${threads}"
        OMP_NUM_THREADS="$threads" ./check_conv_guard "$bytes" | tee "guard-vl${bytes}-t${threads}.log"
        complete_stage
    done
done
# Only this separate TU macro-wraps candidate malloc/free/memcpy.
STAGE=instrumented-kernel
run_build_command gcc "${KERNEL_FLAGS[@]}" -c instrumented_candidate.c -o instrumented-conv2d.o > build-copy-probe.log 2>&1
complete_stage
STAGE=instrumented-guard
run_build_command gcc "${GUARD_FLAGS[@]}" -DCOPY_PATH_PROBE -c check_conv_guard.c -o copy-guard.o >> build-copy-probe.log 2>&1
run_build_command gcc "${KERNEL_FLAGS[@]}" "-DCOPY_EXPECT_PADDED=$COPY_EXPECT_PADDED" -c copy_probe.c -o copy-probe.o >> build-copy-probe.log 2>&1
run_build_command gcc "${KERNEL_FLAGS[@]}" copy-guard.o instrumented-conv2d.o copy-probe.o -o check_input_copy -lm >> build-copy-probe.log 2>&1
complete_stage
for bytes in 16 32 64; do
    for threads in 1 4; do
        for mode in success failure; do
            STAGE="copy-${mode}-vl${bytes}-t${threads}"
            OMP_NUM_THREADS="$threads" ./check_input_copy "$bytes" "copy-$mode" | tee "copy-${mode}-vl${bytes}-t${threads}.log"
            complete_stage
        done
    done
done
STAGE=complete
printf 'PRODUCTION_GUARD_CASES=144600 COPY_SUCCESS_CASES=36288 COPY_FAILURE_CASES=36288 TOTAL_CASES=217176\n'
printf 'RUNNER_CASES=0 SANITIZER_STATUS=NOT_RUN LARGE_ALLOCATION_EXTREMES=STATIC_ONLY\n'
printf 'PROBE_COMPLETE=1\n'
