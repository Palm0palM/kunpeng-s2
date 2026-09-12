#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
# This guard must precede compiler extraction, compilation or test execution.
source ./reference/target-environment.sh
export COMPILER_ROOT=/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f6110e522b93/compiler-private/gcc-12.3.1-2025.03-aarch64-linux
if [[ ! -x "$COMPILER_ROOT/bin/gcc" ]]; then
    compiler_archive=/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/gcc-12.3.1-2025.03-aarch64-linux.tar.gz
    [[ -f "$compiler_archive" ]]
    mkdir compiler-private
    tar -xzf "$compiler_archive" -C compiler-private
    export COMPILER_ROOT="$PWD/compiler-private/gcc-12.3.1-2025.03-aarch64-linux"
fi
[[ -x "$COMPILER_ROOT/bin/gcc" && -f "$COMPILER_ROOT/lib64/libgomp.so.1.0.0" ]]
export PATH="$COMPILER_ROOT/bin:$PATH"
export LIBRARY_PATH="$COMPILER_ROOT/lib64:$COMPILER_ROOT/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$COMPILER_ROOT/lib64:$COMPILER_ROOT/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GOMP_LIBRARY="$COMPILER_ROOT/lib64/libgomp.so.1.0.0"
export COMPILER_VERSION
[[ $(gcc -dumpfullversion) == 12.3.1 ]]
COMPILER_VERSION=$(gcc --version | head -1)
export CC=gcc KBLAS_LIB=''
{ gcc --version; gcc -print-file-name=libgomp.so.1; } > compiler-environment.log 2>&1
readelf --dyn-syms --wide "$GOMP_LIBRARY" | grep omp_get_supported_active_levels > omp-runtime-symbol.log
exec python3 ./cohort_driver.py
