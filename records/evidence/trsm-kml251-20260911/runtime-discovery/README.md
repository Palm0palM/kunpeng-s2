# KML 25.1 / GCC runtime discovery, 2026-09-11

Only authorized remote directory/file metadata and ELF dynamic-symbol reads were performed. No compiler/library/test execution, installation, archive extraction, local computation of the problem, or hash computation/verification occurred. Existing probe scripts and failed experiment directories were left unchanged.

The KML 25.1 GCC multi-threaded libraries for all three architectures (sme, sve, neon) reference `omp_get_supported_active_levels@OMP_5.0.1` and `GOMP_parallel@GOMP_4.0`. Switching architecture cannot remove this runtime requirement. The inspected /usr/lib64/libgomp.so.1 did not show the OMP_5.0.1 symbol.

An installed GCC 12 path was not established. A broad search under /opt/apps, /usr/local and /opt/donaudata timed out after 45 seconds and is not evidence of absence. Focused searches within the HPCKit package tree and /opt/compiler and /opt/buildtools found no expanded GCC executable/libgomp path within their specified depths.

The available compiler archive is:

`/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/gcc-12.3.1-2025.03-aarch64-linux.tar.gz`

Archive size from stat: 326006887 bytes. Its metadata lists the following paths below top-level `gcc-12.3.1-2025.03-aarch64-linux/`:

|Member|Metadata|
|---|---|
|bin/aarch64-linux-gnu-gcc-12.3.1|1381872 bytes, executable|
|bin/gcc|hardlink to bin/aarch64-linux-gnu-gcc-12.3.1|
|lib64/libgomp.so.1.0.0|330360 bytes|
|lib64/libgomp.so|symlink to libgomp.so.1.0.0|
|lib64/libgomp.so.1|symlink to libgomp.so.1.0.0|
|lib64/libgcc_s.so.1|132960 bytes|
|env/setvars.sh|280 bytes|
|modulefiles/gccmodule|1453 bytes|

The parent can unpack the complete archive into a fresh scheduler-job private directory on the allocated compute node, without a system installation. With GCCROOT pointing to its extracted top-level directory, use:

```bash
export PATH="$GCCROOT/bin:$PATH"
export LIBRARY_PATH="$GCCROOT/lib64${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$GCCROOT/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export CC="$GCCROOT/bin/gcc"
```

The original prepared KML target-environment.sh sets CC=gcc; ensure the new job preserves the PATH prefix or changes only its fresh private script copy to retain the explicit CC. Keep the KML SME multi-threaded library chosen by the package's observed 0x48-0xd22 CPU mapping. Do not replace the missing runtime symbol with OpenBLAS or a stub.

Before compiling any target probe, inspect on the compute node:

```bash
readelf --dyn-syms --wide "$GCCROOT/lib64/libgomp.so.1.0.0" | grep 'omp_get_supported_active_levels'
readelf --version-info "$GCCROOT/lib64/libgomp.so.1.0.0" | grep 'OMP_5.0.1'
ldd "$GCCROOT/bin/gcc"
```

The new libgomp's symbol support has not yet been checked with readelf: only archive directory metadata was read, without extracting its contents onto the login node or Mac. The compute-node job must establish that support and capture the actual compiler version and loaded runtime dependencies before continuing. This remains KML 25.1.0, not the required KML 25.2.0 environment; replacing GCC10 with GCC12 also changes compiler conditions, so its performance cannot be mixed into the prior GCC10/OpenBLAS A/B results.
