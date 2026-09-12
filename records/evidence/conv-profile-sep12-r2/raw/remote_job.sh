#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec 3>&1 4>&2
exec > >(tee probe.log) 2>&1
LOG_PID=$!
phase=allocation
finish() {
    local code=$? log_code=0
    trap - EXIT
    if (( code != 0 )); then
        python3 profile_state.py failed "Unexpected exit $code during $phase; inspect original logs." || true
    fi
    exec 1>&3 2>&4 3>&- 4>&-
    wait "$LOG_PID" || log_code=$?
    if (( code == 0 && log_code != 0 )); then code=$log_code; fi
    printf '%s\n' "$code" > exit-code.txt
    exit "$code"
}
trap finish EXIT
set -x
python3 - <<'ALLOCATION'
import os,pathlib,platform,json
assert platform.system()=='Linux' and platform.machine()=='aarch64'
allowed=set(os.sched_getaffinity(0));assert len(allowed)==38
nodes=[]
for p in pathlib.Path('/sys/devices/system/node').glob('node[0-9]*/cpulist'):
    cpus=set()
    for part in p.read_text().strip().split(','):
        if not part: continue
        ends=part.split('-');cpus.update(range(int(ends[0]),int(ends[-1])+1))
    if allowed<=cpus:nodes.append(p.parent.name[4:])
assert len(nodes)==1
pathlib.Path('allocation.json').write_text(json.dumps(dict(allowed_cpus=sorted(allowed),numa_node=int(nodes[0])),indent=2)+'\n')
pathlib.Path('allocation.env').write_text('PROFILE_CPUS='+','.join(map(str,sorted(allowed)))+'\nNUMA_NODE='+nodes[0]+'\n')
ALLOCATION
source allocation.env
python3 profile_state.py running 'Allocated compute-node profile; no benchmark performance result will be recorded.'
sha256sum conv2d.c bench_conv.c run.sh build_c6.sh remote_job.sh profile_state.py analyze_profile.py > source-sha256.txt
export COMPILER=gcc CC=gcc CPU_TARGET=generic CONV_BLOCK=32 CONV_KERNEL_UNROLL=2
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores NUMA_NODE
phase=build
# This file is the byte-preserved original C6 runner prefix through compilation.
# Source it so its module/compiler/NUMA/OMP setup applies to the later capture.
source ./build_c6.sh > build.stdout.log 2>&1
cp "$RUN_DIR/build.log" build.log
cp "$RUN_DIR/environment.log" environment.log
cp "$RUN_DIR/conv2d_test" conv2d_profile
"$CC" -dumpfullversion -dumpversion > compiler-version.txt
if [[ "$(cat compiler-version.txt)" != 10.3.1 ]]; then
    python3 profile_state.py inconclusive 'Compiler differs from recorded C6 GCC10.3.1; profile not run.'
    exit 0
fi
phase=tools
if ! command -v perf > perf-path.txt; then
    python3 profile_state.py unsupported 'perf command unavailable; profile not run.'
    exit 0
fi
perf --version > perf-version.txt
cat /proc/sys/kernel/perf_event_paranoid > perf-event-paranoid.txt
if ! nm -an ./conv2d_profile > symbols.txt 2> symbols.stderr.log; then
    python3 profile_state.py inconclusive 'Cannot read exact ELF symbols; profile not run.'
    exit 0
fi
if ! awk '$NF == "conv_sve_rowquad" {found++} END {exit found != 1}' symbols.txt; then
    python3 profile_state.py inconclusive 'Expected unique quad symbol missing; profile not run.'
    exit 0
fi
readelf -n ./conv2d_profile > build-id.txt
set +e
objdump -d --disassemble=conv_sve_rowquad ./conv2d_profile > quad.disassembly.txt 2> objdump.stderr.log
objdump_code=$?
set -e
printf '%s\n' "$objdump_code" > objdump.exit.txt
phase=record
printf '%q ' perf record -e cycles:u -F 99 -m 128 -T -P -o perf.data -- "${RUN_PREFIX[@]}" ./conv2d_profile 6390 4256 81 81 1 > record-command.txt
printf '\n' >> record-command.txt
set +e
perf record -e cycles:u -F 99 -m 128 -T -P -o perf.data -- \
    "${RUN_PREFIX[@]}" ./conv2d_profile 6390 4256 81 81 1 > benchmark.log 2> record.log
record_code=$?
set -e
printf '%s\n' "$record_code" > record.exit.txt
if (( record_code != 0 )); then
    if grep -Eiq 'permission|not supported|unsupported|operation not permitted' record.log; then
        python3 profile_state.py unsupported 'cycles:u sampling rejected; retain record.log, no fallback whole-process metric.'
    else
        python3 profile_state.py inconclusive 'perf record failed; retain original benchmark/record logs.'
    fi
    exit 0
fi
phase=reports
set +e
perf report -i perf.data --stdio --no-children -n --sort dso,symbol > symbols.report.txt 2> report-all.stderr.log
printf '%s\n' "$?" > report-all.exit.txt
perf report -i perf.data --stdio --no-children -n --symbols conv_sve_rowquad --percentage absolute --sort pid,dso,symbol > quad.report.txt 2> report-quad.stderr.log
printf '%s\n' "$?" > report-quad.exit.txt
perf annotate -i perf.data --stdio --no-source --symbol conv_sve_rowquad --percent-type local-period > quad.annotate.txt 2> annotate.stderr.log
printf '%s\n' "$?" > annotate.exit.txt
set -e
phase=analysis
python3 analyze_profile.py
printf 'PROFILE_CAPTURE_FINISHED=1\n'
