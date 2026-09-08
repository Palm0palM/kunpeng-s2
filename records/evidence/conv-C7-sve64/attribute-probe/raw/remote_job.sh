#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
exec > >(tee probe.log) 2>&1
set -x
gcc --version
gcc -O3 -std=c11 -fno-fast-math -ffp-contract=off -mcpu=generic attribute_probe.c -o attribute_probe
objdump -d attribute_probe > attribute_probe.asm
./attribute_probe 2.0
printf 'PROBE_COMPLETE=1\n'
printf '0\n' > exit-code.txt
