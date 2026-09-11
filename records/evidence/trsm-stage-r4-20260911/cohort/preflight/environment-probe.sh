#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"
exec > environment-probe.log 2>&1
date -u +%FT%TZ
hostname
uname -a
awk '/^Cpus_allowed_list:/ {print}' /proc/self/status
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
if ! type module >/dev/null 2>&1 && [[ -f /etc/profile.d/modules.sh ]]; then
    source /etc/profile.d/modules.sh
fi
if type module >/dev/null 2>&1; then
    module -t avail 2>&1
    module list 2>&1
fi
if [[ -d /home/HPC/HPCKit/latest/modulefiles ]]; then
    module use /home/HPC/HPCKit/latest/modulefiles
    module load gcc/compiler12.3.1/gccmodule
    printf 'OFFICIAL_GCC_MODULE_EXIT=%s\n' "$?"
    module load gcc/kml25.2.0/kblas/multi
    printf 'OFFICIAL_KML_MODULE_EXIT=%s\n' "$?"
    module list 2>&1
else
    echo OFFICIAL_MODULE_ROOT_MISSING=/home/HPC/HPCKit/latest/modulefiles
fi
for folder in /opt /usr/local /usr/lib64 /usr/include /home/HPC /home/share/apps /home/share/software /home/share/HPCKit /public/software /apps; do
    if [[ -d "$folder" ]]; then
        printf "SEARCH_ROOT=%s\n" "$folder"
        timeout 15 find "$folder" -maxdepth 8 \( -iname '*kml*' -o -name 'libkblas*' -o -name 'kblas.h' \) -print 2>/dev/null
    fi
done
ldconfig -p 2>/dev/null | grep -E 'kblas|kml' || true
command -v gcc
gcc --version
cat > kml-probe.c <<'EOF'
#include <kblas.h>
int main(void) { return 0; }
EOF
gcc -O3 -ffp-contract=off -fopenmp -mcpu=generic kml-probe.c -o kml-probe -lm -lkblas
printf 'OFFICIAL_HEADER_AND_LINK_EXIT=%s\n' "$?"
printf 'int main(void){return 0;}\n' > kml-link-probe.c
gcc kml-link-probe.c -o kml-link-probe -Wl,--no-as-needed -lkblas
printf 'OFFICIAL_LIBRARY_LINK_EXIT=%s\n' "$?"
lib=/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a
stat "$lib"
cat > openblas-probe.c <<'EOF'
#include <stdio.h>
extern char *openblas_get_config(void);
extern int openblas_get_parallel(void);
extern int openblas_get_num_threads(void);
int main(void) {
    printf("OPENBLAS_CONFIG=%s\n",openblas_get_config());
    printf("OPENBLAS_PARALLEL=%d\n",openblas_get_parallel());
    printf("OPENBLAS_THREADS=%d\n",openblas_get_num_threads());
    return 0;
}
EOF
gcc -O2 -fopenmp openblas-probe.c "$lib" -lm -o openblas-probe
compile_exit=$?
printf 'OPENBLAS_PROBE_COMPILE_EXIT=%s\n' "$compile_exit"
if ((compile_exit == 0)); then
    ./openblas-probe
    printf 'OPENBLAS_PROBE_EXIT=%s\n' "$?"
fi
date -u +%FT%TZ
echo ENVIRONMENT_PROBE_END
