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
date -u
python3 - <<'CHECK_ALLOCATION'
import os,pathlib
allowed=set(os.sched_getaffinity(0))
assert len(allowed)==38, ('Expected38CPUs', sorted(allowed))
def cpus(s):
    answer=set()
    for p in s.strip().split(','):
        if not p: continue
        ends=p.split('-'); answer.update(range(int(ends[0]),int(ends[-1])+1))
    return answer
nodes=[p.parent.name for p in pathlib.Path('/sys/devices/system/node').glob('node[0-9]*/cpulist') if allowed<=cpus(p.read_text())]
assert len(nodes)==1, ('ExpectedSingleNUMA', nodes)
print('ALLOWED_CPUS='+','.join(map(str,sorted(allowed))))
print('NUMA_NODE='+nodes[0])
CHECK_ALLOCATION
gcc --version
sha256sum conv2d.c check_conv_guard.c check_sve_dispatch.c remote_job.sh
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp check_conv_guard.c conv2d.c -o check_conv_guard
OMP_NUM_THREADS=1 ./check_conv_guard
OMP_NUM_THREADS=4 ./check_conv_guard
gcc -O3 -std=c11 -D_DEFAULT_SOURCE -Wall -Wextra -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -finstrument-functions check_sve_dispatch.c -o check_sve_dispatch
OMP_NUM_THREADS=4 ./check_sve_dispatch
gcc -O3 -std=c11 -fno-fast-math -ffp-contract=off -mcpu=generic -fopenmp -S conv2d.c -o conv2d-sve.s
printf 'PROBE_COMPLETE=1\n'

