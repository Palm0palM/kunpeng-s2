#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 2 ]]; then
    echo 'usage: bash preflight-panel8x16/run.sh /absolute/candidate/source/ /absolute/outputdir' >&2
    exit 2
fi
preflight_dir=$(cd "$(dirname "$0")" && pwd)
source_dir=$1
output_dir=$2
[[ "$source_dir" = /* && "$output_dir" = /* && -f "$source_dir/trsm.c" ]] || exit 2
mkdir -p "$output_dir"
[[ ! -e "$output_dir/summary.tsv" ]] || { echo 'PREFLIGHT_BLOCKED output already used'; exit 2; }
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
cc=${CC:-gcc}
flags=(-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic)
has_panel16=1
has_packedl16=1
has_history_budget=1
test_flags=(-finstrument-functions -DTEST_HAS_PANEL16=1 -DTEST_HAS_PACKEDL16=1 -DTEST_HAS_HISTORY_BUDGET=1 -DTEST_HAS_PANEL8X16=1 "-DTRSM_SOURCE=\"$output_dir/instrumented-trsm.c\"")
printf 'label\texit_code\telapsed_seconds\n' > "$output_dir/summary.tsv"
run_step() {
    local label=$1
    shift
    local started=$SECONDS rc
    printf '%q ' "$@" >> "$output_dir/commands.txt"
    printf '\n' >> "$output_dir/commands.txt"
    set +e
    "$@" > "$output_dir/$label.log" 2>&1
    rc=$?
    set -e
    printf '%s\t%d\t%d\n' "$label" "$rc" "$((SECONDS-started))" >> "$output_dir/summary.tsv"
    cat "$output_dir/$label.log"
    if [[ $rc != 0 ]]; then
        printf 'TRSM_PREFLIGHT_FAILED=%s EXIT_CODE=%d\n' "$label" "$rc"
        exit "$rc"
    fi
}
run_step guard python3 "$preflight_dir/guard.py"
cp "$output_dir/guard.log" "$output_dir/guard.json"
run_step compiler "$cc" --version
run_step instrument-source python3 - "$source_dir/trsm.c" "$output_dir/instrumented-trsm.c" <<'PYGEN'
from pathlib import Path
import re
import sys
source, destination = map(Path, sys.argv[1:])
if source.is_symlink() or not source.is_file():
    raise SystemExit('PREFLIGHT_BLOCKED regular source required')
text = source.read_text()
pattern = (r'static\s+void\s+solve8x16_panel_sve\s*\('
           r'int\s+start\s*,\s*int\s+lda\s*,\s*const\s+double\s*\*\s*L\s*,'
           r'\s*double\s*\*\s*x0\s*,\s*double\s*\*\s*x1\s*\)\s*\{')
matches = list(re.finditer(pattern,text))
if len(matches) != 1 or 'trsm_test_wide_arguments' in text:
    raise SystemExit('PREFLIGHT_BLOCKED expected one original kernel body without test hook')
for name in ('solve16x8_panel_sve','solve16x8_panel_packedL_sve','solve_panel_wide8x16'):
    if len(re.findall(r'static\s+void\s+'+name+r'\s*\(',text)) != 1:
        raise SystemExit('PREFLIGHT_BLOCKED missing/duplicate required source feature '+name)
point = matches[0].end()
copy = text[:point] + '\n    trsm_test_wide_arguments(start,lda,L,x0,x1);' + text[point:]
with destination.open('x') as handle:
    handle.write(copy)
print('INSTRUMENTED_SOURCE_PASS kernel_hook=1 original_modified=0')
PYGEN
run_step build-normal "$cc" "${flags[@]}" "${test_flags[@]}" "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-normal"
run_step build-no-sve "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_NO_SVE "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-no-sve"
run_step build-fail-alloc "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-alloc"
run_step build-fail-x "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_X_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-x"
if [[ $has_packedl16 == 1 ]]; then
    run_step build-fail-shared "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_SHARED_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-shared"
fi
run_step assembly "$cc" "${flags[@]}" -S "$source_dir/trsm.c" -o "$output_dir/trsm-panel8x16.s"
if [[ $has_panel16 == 1 ]]; then
    run_step micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" micro
fi
if [[ $has_packedl16 == 1 ]]; then
    run_step packed-micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" packed-micro
fi
run_step wide-micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" wide-micro
run_step normal-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" full
run_step normal-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" full
run_step normal-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" smoke
run_step boundary-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" boundary
run_step no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" full
run_step fail-alloc-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-alloc" full
run_step narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl full
if [[ $has_packedl16 == 1 ]]; then
    # All cases enter the small-path m>=32 shared-history allocation before X allocation.
    run_step shared-fail-t1 env OMP_NUM_THREADS=1 "$output_dir/check-fail-shared" shared-fail
    run_step shared-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-shared" shared-fail
fi
run_step budget-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" budget
run_step budget-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" budget
run_step budget-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" budget-smoke
run_step budget-x-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-x" budget
run_step budget-no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" budget
run_step budget-narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl budget
if [[ $has_packedl16 == 1 ]]; then
    run_step budget-shared-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-shared" budget
fi
run_step wide-normal-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" wide-grid
run_step wide-normal-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" wide-grid
run_step wide-normal-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" wide-grid-tail
run_step wide-no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" wide-grid
run_step wide-narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl wide-grid
run_step wide-shared-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-shared" wide-grid
run_step wide-x-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-x" wide-grid
run_step wide-all-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-alloc" wide-grid
run_step verify-results python3 "$preflight_dir/audit_panel8x16.py" finalize "$output_dir" "$source_dir/trsm.c"
