#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir unpacked trsm-package
unzip -q trsm.zip -d unpacked
mv unpacked/trsm trsm-package/source
exec python3 ./cohort_driver.py
