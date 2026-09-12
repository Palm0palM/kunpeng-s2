# KML 25.1.0 target-node probe and three-suite driver

Prepared on 2026-09-11; no script, compiler, library call, benchmark or hash operation has been run locally. Four saved login-*-readonly.log files contain authorized SSH directory/file/ELF metadata reads only. No scheduling or payload modification was performed.

## Confirmed package layout from read-only inspection

Root: /opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/KunpengHPCKit-kml.25.1.0

The real header is include/kblas.h and declares cblas_dgemm, cblas_domatcopy, BlasGetNumThreads and KBLASGetVersion. Default BLASINT is int unless USE64BITINT is defined. The GCC SVE multi-threaded entry is gcclib/sve/kblas/multi/libkblas.so -> libkblas.so.25.1.0; NEON and SME variants also exist. The SVE library exports both benchmark-required CBLAS symbols and has SONAME libkblas.so.25.1.0. ELF dependencies observed are libm.so.6, libgomp.so.1, libc.so.6 and ld-linux-aarch64.so.1. No OpenBLAS fallback or libkml_rt wrapper is needed for these two symbols.

modulefiles/kml, modulefiles/kblas/multi and env/setvars.sh refer to an installed root/lib layout, whereas this unpacked distribution uses root/gcclib. The driver therefore follows the package CPU-architecture selection and exports real paths directly; it does not modify the package or create shared symlinks. No README/release-note file was found within five directory levels during the read-only query; the target probe repeats that search and saves the module/environment script contents.

## Entry point

Copy these five text/source files together into the unique remote task directory: run-three-suites.sh, probe.sh, target-environment.sh, required-symbols.c, audit-dependencies.py. The parent controller should unpack the final validated-source ZIP into a task-local directory, allocate exactly 38 CPUs in one NUMA node, then call:

```bash
bash /task/kml-probe/run-three-suites.sh /task/unpacked/trsm /task/kml251-results
```

The source directory must contain the original run.sh, bench_trsm.c and trsm.c. The output directory must not already exist and must be outside source. The final kernel may be T7-diagpanel from the parent's new exact ZIP; these scripts impose no candidate name and never substitute kernel or benchmark files. Original run.sh still creates its ordinary binary/results in source, while all added probe, environment, wrapper-control, dependency and aggregate benchmark logs are outside source.

For the observed package's SVE selection, the essential exports are:

```bash
KML251_ROOT=/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/KunpengHPCKit-kml.25.1.0
KML251_LIBDIR=$KML251_ROOT/gcclib/sve/kblas/multi
unset KBLAS_LIB
export CPATH="$KML251_ROOT/include${CPATH:+:$CPATH}"
export LIBRARY_PATH="$KML251_LIBDIR:$KML251_ROOT/gcclib/sve:$KML251_ROOT/gcclib/noarch:$KML251_ROOT/gcclib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$KML251_LIBDIR:$KML251_ROOT/gcclib/sve:$KML251_ROOT/gcclib/noarch:$KML251_ROOT/gcclib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export OMP_NUM_THREADS=38 OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
export CPU_TARGET=generic TEST_RUNS=3 CC=gcc
```

Use the driver's target-environment.sh in practice: it checks Linux/aarch64, 38 allowed CPUs and one NUMA node, and reproduces the package's CPU mapping (0x48-0xd02/d03/d06 -> sve, d22 -> sme, otherwise neon). It records the choice and refuses to continue if real files are absent. It also stops if the standard /home/HPC/HPCKit/latest/modulefiles tree appears, because the unchanged runner would otherwise auto-load the separate required-version module tree.

## What the target execution checks

probe.sh takes SOURCE_DIR OUTPUT_DIR and only performs reference-library inspection and a tiny symbol smoke test. It logs real header selection through gcc -H, package text/layout, ELF metadata, library dependencies and exported symbols. The smoke source includes the real KML header; it checks LP64 BLAS integers, KML configured threads=38 and an actual OpenMP team of 38, queries KML version, reports the two symbol-provider paths, and checks small exact DGEMM and padded DOMATCOPY outputs. No OpenBLAS symbol substitute or local compat header is used.

run-three-suites.sh invokes that probe, then calls unmodified run.sh exactly three times with TEST_RUNS=3. benchmark.log contains BENCH_JOB_BEGIN/END and BENCH_REPEAT i/3 BEGIN/END markers, and is compatible with experiment.parse_log('trsm', text, 3). It rejects missing/incorrect ordered cases, FAIL, invalid timing metrics or error >1e-12. After every run, ldd of the runner-built source/trsm_test is saved and must resolve the selected versioned libkblas path with no missing dependency or OpenBLAS library. exit-code.txt records the driver exit; the parent must independently save and inspect scheduler success and its job/system exit codes. environment.log has HOST, ARCH, NUMA_NODE, ALLOWED_CPUS, OMP_NUM_THREADS, CPU_TARGET, compiler, binding and exact library environment.

This is a standalone KML 25.1.0 validation environment. Even if all suites pass, it is not the contest-specified KML 25.2.0 revalidation and its times must not be mixed into previous OpenBLAS A/B comparisons. The original runner prints its generic default-kblas banner; the driver's explicit version, package path and loader records establish the actual 25.1.0 environment.

The scripts were prepared and read statically only. Parent owns final scheduler submission, result collection, promotion decisions, and publication. No competition submission is performed.
