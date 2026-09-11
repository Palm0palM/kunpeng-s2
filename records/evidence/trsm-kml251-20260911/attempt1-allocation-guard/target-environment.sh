#!/usr/bin/env bash
# Source only within an allocated 38-CPU Linux/aarch64 computation job.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo 'Source target-environment.sh; do not execute it directly.' >&2
    exit 2
fi
if [[ $(uname -s) != Linux || $(uname -m) != aarch64 ]]; then
    echo 'KML251_BLOCKED: Linux aarch64 compute node required' >&2
    return 2
fi
kml251_identity=$(python3 - <<'PY'
import os
from pathlib import Path
allowed=set(os.sched_getaffinity(0))
if len(allowed)!=38:raise SystemExit('KML251_BLOCKED: expected exactly 38 allocated CPUs')
def cpus(text):
    result=set()
    for part in text.strip().split(','):
        ends=list(map(int,part.split('-')))
        result.update(range(ends[0],ends[-1]+1))
    return result
nodes=[p.parent.name[4:] for p in Path('/sys/devices/system/node').glob('node[0-9]*/cpulist') if allowed<=cpus(p.read_text())]
if len(nodes)!=1:raise SystemExit('KML251_BLOCKED: CPUs must belong to one NUMA node')
print(nodes[0]+'|'+','.join(map(str,sorted(allowed))))
PY
) || return 2
export NUMA_NODE=${kml251_identity%%|*}
export KML251_ALLOWED_CPUS=${kml251_identity#*|}
export KML251_ROOT=/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/KunpengHPCKit-kml.25.1.0
kml251_implementer=$(awk '/CPU implementer/ {print $4;exit}' /proc/cpuinfo)
kml251_part=$(awk '/CPU part/ {print $4;exit}' /proc/cpuinfo)
# Match this package's kblas/multi modulefile and env/setvars.sh CPU mapping.
case "$kml251_implementer-$kml251_part" in
    0x48-0xd02|0x48-0xd03|0x48-0xd06) KML251_ARCH=sve ;;
    0x48-0xd22) KML251_ARCH=sme ;;
    *) KML251_ARCH=neon ;;
esac
export KML251_ARCH
export KML251_LIBDIR="$KML251_ROOT/gcclib/$KML251_ARCH/kblas/multi"
if [[ ! -f "$KML251_ROOT/include/kblas.h" || ! -f "$KML251_LIBDIR/libkblas.so" ]]; then
    echo "KML251_BLOCKED: real header or library unavailable: $KML251_LIBDIR" >&2
    return 2
fi
if [[ -d /home/HPC/HPCKit/latest/modulefiles ]]; then
    echo 'KML251_BLOCKED: unmodified run.sh would auto-load another official module tree; inspect before running.' >&2
    return 2
fi
unset KBLAS_LIB
export CPATH="$KML251_ROOT/include${CPATH:+:$CPATH}"
export LIBRARY_PATH="$KML251_LIBDIR:$KML251_ROOT/gcclib/$KML251_ARCH:$KML251_ROOT/gcclib/noarch:$KML251_ROOT/gcclib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$KML251_LIBDIR:$KML251_ROOT/gcclib/$KML251_ARCH:$KML251_ROOT/gcclib/noarch:$KML251_ROOT/gcclib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
export CPU_TARGET=generic TEST_RUNS=3 CC=gcc
