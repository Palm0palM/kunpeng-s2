#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
bash ./environment-probe.sh
grep -q "OPENBLAS_CONFIG=OpenBLAS 0.3.28" environment-probe.log
grep -q "OPENBLAS_THREADS=38" environment-probe.log
echo PACKAGE_REFERENCE_PREFLIGHT_COMPLETE=1
