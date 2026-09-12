#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
# Identity/allocation checks precede extraction of the compiler or any test build.
source ./target-environment.sh
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
[[ $(gcc -dumpfullversion) == 12.3.1 ]]
export COMPILER_VERSION
COMPILER_VERSION=$(gcc --version | head -1)
export CC=gcc KBLAS_LIB=''
{ gcc --version; gcc -print-file-name=libgomp.so.1; } > compiler-environment.log 2>&1
readelf --dyn-syms --wide "$GOMP_LIBRARY" | grep omp_get_supported_active_levels > omp-runtime-symbol.log
# Keep the exact received ZIP bytes in this supervising process throughout testing.
exec python3 - <<'PY'
from pathlib import Path
import io
import json
import os
import stat
import subprocess
import sys
import zipfile

root = Path.cwd()
archive_path = root / 'trsm.zip'
metadata_path = root / 'package-metadata.json'
if archive_path.is_symlink() or metadata_path.is_symlink():
    raise RuntimeError('Package ZIP and metadata must be regular files')
frozen_zip = archive_path.read_bytes()
frozen_metadata = metadata_path.read_bytes()
metadata = json.loads(frozen_metadata)
names = ['trsm/README.md', 'trsm/bench_trsm.c', 'trsm/compat/kblas.h', 'trsm/run.sh', 'trsm/trsm.c']
if (metadata.get('problem') != 'trsm' or metadata.get('version') != 'T19-panel8x16budget'
        or metadata.get('archive') != 'trsm.zip' or metadata.get('archive_bytes') != len(frozen_zip)
        or sorted(item['path'] for item in metadata['files']) != names):
    raise RuntimeError('Received private package identity or manifest invalid')
expected_sizes = {item['path']: item['bytes'] for item in metadata['files']}
members = {}
with zipfile.ZipFile(io.BytesIO(frozen_zip)) as archive:
    entries = archive.infolist()
    if sorted(item.filename for item in entries) != names:
        raise RuntimeError('ZIP must contain exactly five unique source/README members')
    for entry in entries:
        mode = entry.external_attr >> 16
        if entry.is_dir() or stat.S_ISLNK(mode) or (stat.S_IFMT(mode) and not stat.S_ISREG(mode)):
            raise RuntimeError('ZIP contains a non-regular member')
        value = archive.read(entry.filename)
        if len(value) != expected_sizes[entry.filename]:
            raise RuntimeError('ZIP member size differs from metadata')
        members[entry.filename] = value
unpacked = root / 'unpacked'
unpacked.mkdir()
for name in names:
    destination = unpacked / name
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('xb') as handle:
        handle.write(members[name])


def source_matches():
    return all((unpacked / name).is_file() and not (unpacked / name).is_symlink()
               and (unpacked / name).read_bytes() == members[name] for name in names)


audit = dict(schema='trsm-private-zip-check-v1', source_version='T19-panel8x16budget',
             job_id=os.environ['TRSM_SCHEDULER_JOB_ID'], archive_bytes=len(frozen_zip),
             members=names, extracted_members_match_before=source_matches(),
             extracted_members_match_after=False, zip_unchanged=False)
if not audit['extracted_members_match_before'] or archive_path.read_bytes() != frozen_zip:
    raise RuntimeError('ZIP or extracted sources changed before execution')
code = 125
try:
    code = subprocess.run(['/bin/bash', './run-three-suites.sh', str(unpacked / 'trsm'), str(root / 'results')]).returncode
finally:
    audit.update(extracted_members_match_after=source_matches(),
                 zip_unchanged=(archive_path.is_file() and not archive_path.is_symlink()
                                and archive_path.read_bytes() == frozen_zip),
                 metadata_unchanged=(metadata_path.is_file() and not metadata_path.is_symlink()
                                     and metadata_path.read_bytes() == frozen_metadata),
                 runner_exit_code=code)
    with (root / 'zip-validation.json').open('x') as handle:
        handle.write(json.dumps(audit, indent=2) + '\n')
    if not all(audit[key] for key in ('extracted_members_match_after', 'zip_unchanged', 'metadata_unchanged')):
        code = 125
    if (root / 'results').is_dir():
        (root / 'results/exit-code.txt').write_text(str(code) + '\n')
if code:
    raise SystemExit(code)
print('TRSM_PRIVATE_ZIP_THREE_SUITES_COMPLETE=1')
PY
