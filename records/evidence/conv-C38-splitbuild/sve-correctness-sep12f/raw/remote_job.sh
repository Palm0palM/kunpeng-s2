#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec 3>&1 4>&2
exec > >(tee probe.log) 2>&1
LOG_PID=$!
STAGE=initialization
RUN_DIR=
copy_runner_logs() {
    [[ -n "${RUN_DIR:-}" && -d "$RUN_DIR" ]] || return 0
    local name
    for name in build.log environment.log summary.log case-1.log case-2.log case-3.log case-4.log; do
        if [[ -f "$RUN_DIR/$name" ]]; then cp "$RUN_DIR/$name" "runner-$name"; fi
    done
}
finish() {
    local code=$? log_code=0 copy_code=0
    trap - EXIT
    set +e
    copy_runner_logs
    copy_code=$?
    if (( code == 0 && copy_code != 0 )); then code=$copy_code; fi
    printf 'STAGE=%s EXIT=%s\n' "$STAGE" "$code" >> stage-exits.txt
    exec 1>&3 2>&4 3>&- 4>&-
    wait "$LOG_PID" || log_code=$?
    if (( code == 0 && log_code != 0 )); then code=$log_code; fi
    printf '%s\n' "$code" > exit-code.txt
    exit "$code"
}
trap finish EXIT
complete_stage() { printf 'STAGE=%s EXIT=0\n' "$STAGE" >> stage-exits.txt; }
set -x
STAGE=allocation
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
case "$CANDIDATE" in
    C38-splitbuild) [[ "$GUARD_MODE" == smoke && "$EXPECTED_GUARD_CASES" == 96 && "$DISPATCH_SMOKE" == 0 ]]; TUNE_FLAGS=() ;;
    C39-tunehip11) [[ "$GUARD_MODE" == full && "$EXPECTED_GUARD_CASES" == 7108 && "$DISPATCH_SMOKE" == 1 ]]; TUNE_FLAGS=(-mtune=hip11) ;;
    *) exit 2 ;;
esac
STAGE=source-manifest
sha256sum README.md bench_conv.c conv2d.c run.sh check_conv_guard.c check_sve_dispatch.c candidate.env remote_job.sh > source-sha256.txt
cat source-sha256.txt
date -u
hostname
complete_stage
# Nonfatal task-only event-open probe; no CPU-wide/dummy sideband selector.
# Samples (including zero samples) are not operator metrics.
(
    set +e
    printf '%q ' perf record -e cycles:u -F 99 -m 128 -T -P -o task-perf-probe.data -- /bin/true > task-perf-probe-command.txt
    printf '\n' >> task-perf-probe-command.txt
    perf record -e cycles:u -F 99 -m 128 -T -P -o task-perf-probe.data -- /bin/true > task-perf-probe.stdout.log 2> task-perf-probe.stderr.log
    probe_code=$?
    printf '%s\n' "$probe_code" > task-perf-probe.exit.txt
) || true
# Source the immutable original runner directly; never wrap it in a condition
# that could disable errexit. Its actual BUILD_FLAGS, CC and RUN_DIR survive.
STAGE=production-runner
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores CPU_TARGET=generic
source ./run.sh
printf 'RUNNER_RESULTS=%s\n' "$RUN_DIR" > runner-results.txt
copy_runner_logs
printf 'RUNNER_CASES=4 RUNNER_PASS=4 TIMINGS_NOT_PERFORMANCE_RECORD=1\n' > runner-status.txt
complete_stage
STAGE=production-object
[[ -f "$RUN_DIR/conv2d.o" && -f "$RUN_DIR/bench_conv.o" ]]
cp "$RUN_DIR/conv2d.o" production-conv2d.o
sha256sum "$RUN_DIR/conv2d.o" "$RUN_DIR/bench_conv.o" "$RUN_DIR/conv2d_test" production-conv2d.o > production-artifacts-sha256.txt
command -v objdump > objdump-command.txt
objdump -d production-conv2d.o > production-conv2d-objdump.log
complete_stage
# Query the same explicit tune and public build flags. No generic retry.
STAGE=target-query
run_build_command "$CC" "${BUILD_FLAGS[@]}" "${TUNE_FLAGS[@]}" \
    -Q --help=target -c -x c /dev/null -o "$PWD/target-query.o" > target-query.log 2>&1
if [[ "$CANDIDATE" == C39-tunehip11 ]]; then
    awk '$1 == "-mtune=" && $2 == "hip11" {found=1} END {exit !found}' target-query.log
fi
complete_stage
# Generate assembly using the exact production kernel flags, without
# diagnostic macros or instrumentation. The real object is retained above.
STAGE=production-assembly
run_build_command "$CC" "${BUILD_FLAGS[@]}" "${TUNE_FLAGS[@]}" \
    -S conv2d.c -o conv2d-sve.s > build-assembly.log 2>&1
complete_stage
# Strict reference/guard TU is deliberately NOT tuned, including for C39.
GUARD_FLAGS=("${BUILD_FLAGS[@]}" -D_DEFAULT_SOURCE \
    "-DEXPECTED_ACC=$EXPECTED_ACC" "-DCHECK_ROWTRIPLE=$CHECK_ROWTRIPLE" "-DCHECK_ROWQUAD=$CHECK_ROWQUAD")
STAGE=guard-compile
run_build_command "$CC" "${GUARD_FLAGS[@]}" \
    -c check_conv_guard.c -o "$PWD/check_conv_guard.o" > build-guard.log 2>&1
complete_stage
STAGE=guard-link-production-object
run_build_command "$CC" "${BUILD_FLAGS[@]}" \
    "$PWD/check_conv_guard.o" "$RUN_DIR/conv2d.o" \
    -o "$PWD/check_conv_guard" "${LINK_FLAGS[@]}" >> build-guard.log 2>&1
complete_stage
GUARD_ARGS=()
if [[ "$GUARD_MODE" == smoke ]]; then GUARD_ARGS=(smoke); fi
for bytes in 16 32 64; do
    for threads in 1 4; do
        STAGE="production-guard-vl${bytes}-t${threads}"
        OMP_NUM_THREADS="$threads" ./check_conv_guard "$bytes" "${GUARD_ARGS[@]}" | tee "guard-vl${bytes}-t${threads}.log"
        complete_stage
    done
done
if [[ "$DISPATCH_SMOKE" == 1 ]]; then
    # Includes the source only for actual-entry instrumentation. This tuned
    # diagnostic TU is distinct from the production-object guard/benchmark.
    STAGE=dispatch-build
    run_build_command "$CC" "${GUARD_FLAGS[@]}" "${TUNE_FLAGS[@]}" \
        -finstrument-functions check_sve_dispatch.c -o check_sve_dispatch \
        "${LINK_FLAGS[@]}" > build-dispatch.log 2>&1
    complete_stage
    for bytes in 16 32 64; do
        for threads in 1 4; do
            STAGE="dispatch-vl${bytes}-t${threads}"
            OMP_NUM_THREADS="$threads" ./check_sve_dispatch "$bytes" smoke | tee "dispatch-vl${bytes}-t${threads}.log"
            complete_stage
        done
    done
fi
STAGE=complete
printf 'SANITIZER_STATUS=NOT_RUN; this job uses guard pages and bitwise reference checks\n'
printf 'DIAGNOSTIC_CHECKS=%s RUNNER_CASES_SEPARATE=4\n' "$EXPECTED_CHECKS"
printf 'PROBE_COMPLETE=1\n'
