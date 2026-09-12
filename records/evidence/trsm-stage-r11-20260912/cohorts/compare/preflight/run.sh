#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 2 ]]; then
    echo 'usage: bash preflight/run.sh /absolute/candidate/source/ /absolute/outputdir' >&2
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
has_panel16=0
if grep -Fq 'static void solve16x8_panel_sve(' "$source_dir/trsm.c"; then has_panel16=1; fi
has_packedl16=0
if grep -Fq 'static void solve16x8_panel_packedL_sve(' "$source_dir/trsm.c"; then has_packedl16=1; fi
[[ $has_packedl16 == 0 || $has_panel16 == 1 ]] || { echo 'PREFLIGHT_BLOCKED packed kernel lacks original fallback'; exit 2; }
test_flags=(-finstrument-functions "-DTEST_HAS_PANEL16=$has_panel16" "-DTEST_HAS_PACKEDL16=$has_packedl16" "-DTRSM_SOURCE=\"$source_dir/trsm.c\"")
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
run_step build-normal "$cc" "${flags[@]}" "${test_flags[@]}" "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-normal"
run_step build-no-sve "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_NO_SVE "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-no-sve"
run_step build-fail-alloc "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-alloc"
if [[ $has_packedl16 == 1 ]]; then
    run_step build-fail-shared "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_SHARED_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-shared"
fi
run_step assembly "$cc" "${flags[@]}" -S "$source_dir/trsm.c" -o "$output_dir/trsm-panel16.s"
if [[ $has_panel16 == 1 ]]; then
    run_step micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" micro
fi
if [[ $has_packedl16 == 1 ]]; then
    run_step packed-micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" packed-micro
fi
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
python3 - "$output_dir" "$has_panel16" "$has_packedl16" <<'PY'
from pathlib import Path
import re
import sys

folder = Path(sys.argv[1])
has_panel, has_packed = map(int, sys.argv[2:])
expected = {'normal-t1': 80, 'normal-t4': 80, 'normal-t38': 4, 'boundary-t1': 2,
            'no-sve-t4': 80, 'fail-alloc-t4': 80, 'narrow-vl-t4': 80}
if has_packed:
    expected.update({'shared-fail-t1': 40, 'shared-fail-t4': 40})
whole, noop, shared_fail = 0, 0, 0
for label, count in expected.items():
    text = (folder / (label + '.log')).read_text()
    results = re.findall(r'^PASS whole_cases=(\d+) noop_cases=(\d+) '
                         r'non_dyadic_long_double_RHS=1 padding_L_unchanged=1 max_error=\S+$', text, re.M)
    if results != [(str(count), '4')] or re.search(r'^FAIL\b', text, re.M):
        raise SystemExit('PREFLIGHT_BLOCKED missing or invalid actual whole-case summary: ' + label)
    if len(re.findall(r'^CASE_PASS ', text, re.M)) != count:
        raise SystemExit('PREFLIGHT_BLOCKED case count differs from actual rows: ' + label)
    whole += int(results[0][0]); noop += int(results[0][1])
    if label.startswith('shared-fail-'):
        injections = re.findall(r'^SHARED_ALLOC_PASS m=\d+ n=\d+ calls=(\d+) injected=1 shared_first=1 later_X_success=(\d+)$', text, re.M)
        if len(injections) != count or any(int(calls) < 2 or int(successes) != int(calls) - 1
                                           for calls, successes in injections):
            raise SystemExit('PREFLIGHT_BLOCKED first-shared-allocation injection evidence missing: ' + label)
        shared_fail += len(injections)
micro, packed_micro = 0, 0
for enabled, label, field in ((has_panel, 'micro-t1', 'micro_cases'),
                               (has_packed, 'packed-micro-t1', 'packed_micro_cases')):
    if enabled:
        text = (folder / (label + '.log')).read_text()
        results = re.findall(r'^PASS ' + field + r'=(\d+) ordered_FMA_bitwise=1 '
                             r'prefix_padding_L_unchanged=1 history_unchanged=1$', text, re.M)
        if results != ['14'] or re.search(r'^FAIL\b', text, re.M):
            raise SystemExit('PREFLIGHT_BLOCKED missing direct micro evidence: ' + label)
        if field == 'micro_cases': micro = int(results[0])
        else: packed_micro = int(results[0])
line = ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES={} WHOLE_CASES={} NOOP_CASES={} '
        'OLD_MICRO_CASES={} PACKED_MICRO_CASES={} SHARED_FAIL_CASES={}\n').format(
            micro + packed_micro, whole, noop, micro, packed_micro, shared_fail)
with (folder / 'completion.txt').open('x') as handle:
    handle.write(line)
print(line, end='')
PY
