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
# Optional read-only metadata; failure cannot affect numerical validation.
(
    set +e
    python3 - > hardware-metadata.log 2>&1 <<'HARDWARE_METADATA'
import os,pathlib,subprocess
print('COMMAND=lscpu',flush=True)
try:
    result=subprocess.run(['lscpu'],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,timeout=10)
    print('LSCPU_EXIT='+str(result.returncode))
    print('LSCPU_STDOUT_BEGIN');print(result.stdout,end='');print('LSCPU_STDOUT_END')
    print('LSCPU_STDERR_BEGIN');print(result.stderr,end='');print('LSCPU_STDERR_END')
except Exception as exc:
    print('LSCPU_UNAVAILABLE='+type(exc).__name__+': '+str(exc))
def read_file(path):
    print('FILE='+str(path))
    try:
        value=path.read_text();print(value,end='' if value.endswith('\n') else '\n')
        print('READ_STATUS=ok')
    except OSError as exc:
        print('READ_STATUS=missing_or_unreadable '+type(exc).__name__+': '+str(exc))
read_file(pathlib.Path('/proc/sys/abi/sve_default_vector_length'))
first=min(os.sched_getaffinity(0))
print('FIRST_ALLOWED_CPU='+str(first))
indices=sorted(pathlib.Path('/sys/devices/system/cpu/cpu'+str(first)+'/cache').glob('index[0-9]*'))
print('CACHE_INDEX_COUNT='+str(len(indices)))
for index in indices:
    for name in ('level','type','size','coherency_line_size','number_of_sets','ways_of_associativity'):
        read_file(index/name)
print('METADATA_SCOPE=read_only; missing fields are not correctness failures; no geometry inferred from model name')
HARDWARE_METADATA
    metadata_code=$?
    printf '%s\n' "$metadata_code" > hardware-metadata.exit.txt
) || true
source candidate.env
[[ "$EXPECTED_ACC" == 3 && "$EXPECTED_FULL" == 3560 && "$EXPECTED_DISPATCH" == 432 && "$EXPECTED_DIRECT" == 360 ]]
[[ "$EXPECTED_DISPATCH_ROWSIX_ENTRIES" == 432 && "$EXPECTED_DIRECT_ROWSIX_ENTRIES" == 900 ]]
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
printf 'EXPECTED_TOTAL_CHECKS=26112\n'
printf 'PROBE_COMPLETE=1\n'
