#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir unpacked
unzip -q trsm.zip -d unpacked
exec bash ./run-three-suites.sh ./unpacked/trsm ./results
