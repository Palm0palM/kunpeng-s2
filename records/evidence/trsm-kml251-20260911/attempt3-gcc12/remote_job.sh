#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir unpacked
unzip -q trsm.zip -d unpacked
# Use the supplied HPCKit compiler in this private job directory only.
compiler_archive=/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/gcc-12.3.1-2025.03-aarch64-linux.tar.gz
[[ -f "$compiler_archive" ]]
mkdir compiler-private
tar -xzf "$compiler_archive" -C compiler-private
compiler_exe=$(find "$PWD/compiler-private" -path '*/bin/gcc' -print -quit)
[[ -n "$compiler_exe" && -x "$compiler_exe" ]]
compiler_bin=$(dirname "$compiler_exe")
compiler_root=$(dirname "$compiler_bin")
export PATH="$compiler_bin:$PATH"
export LIBRARY_PATH="$compiler_root/lib64:$compiler_root/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$compiler_root/lib64:$compiler_root/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
{ gcc --version; gcc -print-file-name=libgomp.so.1; } > compiler-environment.log 2>&1
readelf --dyn-syms --wide "$compiler_root/lib64/libgomp.so.1" | grep omp_get_supported_active_levels > omp-runtime-symbol.log
exec bash ./run-three-suites.sh ./unpacked/trsm ./results
