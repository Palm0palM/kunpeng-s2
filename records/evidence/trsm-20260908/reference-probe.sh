hostname
uname -a
for d in /home/HPC/HPCKit/latest/modulefiles /home/HPC /opt /usr/local; do
  if [ -d "$d" ]; then ls -ld "$d"; ls "$d"; else printf 'MISSING %s\n' "$d"; fi
done
if ! type module >/dev/null 2>&1 && [ -f /etc/profile.d/modules.sh ]; then . /etc/profile.d/modules.sh; fi
if type module >/dev/null 2>&1; then module -t avail 2>&1; module list 2>&1; else echo MODULE_COMMAND_UNAVAILABLE; fi
for d in /home/HPC /opt/HPCKit /opt/huawei /usr/local/kml /usr/local/HPCKit; do
  if [ -d "$d" ]; then find "$d" -maxdepth 8 \( -name '*kml*' -o -name 'libkblas*' -o -name 'kblas.h' \) -print 2>/dev/null; fi
done
ldconfig -p 2>/dev/null | grep -E 'kblas|kml' || true
lib=/CLUSTER_USER_HOME/other-20260907/blas-verified/libopenblas.a
stat "$lib"
sha256sum "$lib"
strings "$lib" | grep -m 5 -E 'OpenBLAS 0\.|USE_OPENMP|DYNAMIC_ARCH'
