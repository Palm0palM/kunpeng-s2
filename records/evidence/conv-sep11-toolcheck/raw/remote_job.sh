#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
finish() {
    local code=$?
    trap - EXIT
    printf '%s\n' "$code" > exit-code.txt
    exit "$code"
}
trap finish EXIT
# Never run unittest unless this is the scheduled Linux/AArch64 allocation.
python3 - <<'CHECK_ALLOCATION' > environment.log
import os, pathlib, platform, sys
assert platform.system() == 'Linux' and platform.machine() == 'aarch64'
allowed = set(os.sched_getaffinity(0))
assert len(allowed) == 38, ('Expected38CPUs', sorted(allowed))
def cpus(text):
    result = set()
    for part in text.strip().split(','):
        if not part: continue
        bounds = part.split('-')
        result.update(range(int(bounds[0]), int(bounds[-1]) + 1))
    return result
nodes = [p.parent.name for p in pathlib.Path('/sys/devices/system/node').glob('node[0-9]*/cpulist')
         if allowed <= cpus(p.read_text())]
assert len(nodes) == 1, ('ExpectedSingleNUMA', nodes)
print('HOST=' + platform.node())
print('ARCH=' + platform.machine())
print('PYTHON=' + sys.version.replace('\n', ' '))
print('ALLOWED_CPUS=' + ','.join(map(str, sorted(allowed))))
print('NUMA_NODE=' + nodes[0])
CHECK_ALLOCATION
sha256sum -c source-sha256.txt > source-verification.log
cd repo
python3 -B -m unittest discover -s tests -p 'test_*.py' -v > ../test.log 2>&1
cd ..
printf 'TOOL_TEST_COMPLETE=1\n'
