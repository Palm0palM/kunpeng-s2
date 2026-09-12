#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 2 ]]; then
    echo 'usage: bash preflight-wide32/run.sh /absolute/candidate/source/ /absolute/outputdir' >&2
    exit 2
fi
preflight_dir=$(cd "$(dirname "$0")" && pwd)
source_dir=$1
output_dir=$2
[[ "$source_dir" = /* && "$output_dir" = /* && -f "$source_dir/trsm.c" ]] || exit 2
mkdir -p "$output_dir"
[[ ! -e "$output_dir/summary.tsv" && ! -e "$output_dir/completion.txt" ]] || {
    echo 'PREFLIGHT_BLOCKED output already used'; exit 2;
}
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
cc=${CC:-gcc}
flags=(-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu=generic)
test_flags=(-finstrument-functions "-DTRSM_SOURCE=\"$output_dir/instrumented-trsm.c\"")
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
        printf 'TRSM_WIDE32_PREFLIGHT_FAILED=%s EXIT_CODE=%d\n' "$label" "$rc"
        exit "$rc"
    fi
}
run_step guard python3 "$preflight_dir/guard.py"
cp "$output_dir/guard.log" "$output_dir/guard.json"
run_step compiler "$cc" --version
run_step instrument-source python3 - "$source_dir/trsm.c" "$output_dir/instrumented-trsm.c" <<'INSTRUMENT_PY'
from pathlib import Path
import sys
original_path, output_path = map(Path, sys.argv[1:])
original = original_path.read_bytes()
signature = (b'static void update4x32_sve(int count,const double *L,int lda,const double *X0,'
             b'int ldx,int panel_stride,double *C,int ldc)\n{\n')
observer = b'    trsm_test_wide_arguments(ldx,panel_stride);\n'
if original.count(signature) != 1 or b'trsm_test_wide_arguments' in original:
    raise SystemExit('PREFLIGHT_BLOCKED unique original 4x32 signature missing')
instrumented = original.replace(signature, signature + observer, 1)
with output_path.open('xb') as handle:
    handle.write(instrumented)
if original_path.read_bytes() != original:
    raise SystemExit('PREFLIGHT_BLOCKED source changed during test-copy creation')
print('SOURCE_INSTRUMENTATION_PASS copies=1 insertions=1 original_untouched=1')
INSTRUMENT_PY
run_step build-normal "$cc" "${flags[@]}" "${test_flags[@]}" "$preflight_dir/check-wide32.c" -lm -o "$output_dir/check-normal"
run_step build-no-sve "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_NO_SVE "$preflight_dir/check-wide32.c" -lm -o "$output_dir/check-no-sve"
run_step build-fail-shared "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_SHARED_ALLOC_FAIL "$preflight_dir/check-wide32.c" -lm -o "$output_dir/check-fail-shared"
run_step assembly "$cc" "${flags[@]}" -S "$source_dir/trsm.c" -o "$output_dir/trsm-wide4x32.s"
run_step micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" micro
run_step normal-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" full
run_step normal-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" full
run_step normal-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" smoke
run_step shared-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-shared" smoke
run_step no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" smoke
run_step narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl smoke
run_step verify-results python3 - "$output_dir" <<'PY'
from collections import Counter
from pathlib import Path
import csv
import json
import math
import re
import sys

folder = Path(sys.argv[1])


def blocked(message):
    raise SystemExit('PREFLIGHT_BLOCKED ' + message)


steps = ['guard', 'compiler', 'instrument-source', 'build-normal', 'build-no-sve', 'build-fail-shared',
         'assembly', 'micro-t1', 'normal-t1', 'normal-t4', 'normal-t38',
         'shared-fail-t4', 'no-sve-t4', 'narrow-vl-t4']
with (folder / 'summary.tsv').open() as handle:
    reader = csv.DictReader(handle, delimiter='\t')
    if reader.fieldnames != ['label', 'exit_code', 'elapsed_seconds']:
        blocked('invalid step summary header')
    rows = list(reader)
if [row['label'] for row in rows] != steps:
    blocked('missing, duplicate or unexpected completed steps')
for row in rows:
    if row['exit_code'] != '0' or not re.fullmatch(r'\d+', row['elapsed_seconds']):
        blocked('failed step or invalid timing: ' + row['label'])


def read_log(label):
    data = (folder / (label + '.log')).read_text()
    if re.search(r'^(?:FAIL\b|PREFLIGHT_BLOCKED\b|TRSM_WIDE32_PREFLIGHT_FAILED=)', data, re.M):
        blocked('failure marker in ' + label)
    return data


instrumentation = read_log('instrument-source')
if instrumentation.splitlines() != [
        'SOURCE_INSTRUMENTATION_PASS copies=1 insertions=1 original_untouched=1']:
    blocked('missing or invalid test-only source instrumentation evidence')


def argument_rows(label, data, count):
    rows = re.findall(r'^ARGUMENTS_PASS calls=(\d+) bad=0 expected_ldx=(\d+) '
                      r'expected_panel_stride=(\d+)$', data, re.M)
    if len(rows) != count or len(re.findall(r'^ARGUMENTS_PASS\b', data, re.M)) != count:
        blocked('missing, malformed or failed argument observations: ' + label)
    return [tuple(map(int, row)) for row in rows]


def check_dispatch(label, data, threads, wide, narrow=False, no_sve=False):
    matches = re.findall(r'^DISPATCH workers=(\d+) hwcap_sve=([01]) '
                         r'min_vl=(\d+) max_vl=(\d+) expected_wide=([01])$', data, re.M)
    if len(matches) != 1 or len(re.findall(r'^DISPATCH\b', data, re.M)) != 1:
        blocked('missing or malformed dispatch evidence: ' + label)
    workers, hwcap, low, high, actual_wide = map(int, matches[0])
    if workers != threads or actual_wide != wide or low != high:
        blocked('dispatch differs from required worker configuration: ' + label)
    if no_sve:
        if hwcap != 0 or low != 64:
            blocked('SVE masking not demonstrated: ' + label)
    elif hwcap != 1 or low != (16 if narrow else 64):
        blocked('required SVE vector length unavailable: ' + label)
    narrow_rows = re.findall(r'^NARROW_VL_PASS requested=16 actual=16$', data, re.M)
    if len(narrow_rows) != int(narrow) or len(re.findall(r'^NARROW_VL_PASS\b', data, re.M)) != int(narrow):
        blocked('invalid actual narrow-VL evidence: ' + label)


data = read_log('micro-t1')
check_dispatch('micro-t1', data, 1, 1)
micro_rows = re.findall(r'^MICRO_PASS count=(\d+) lda=(\d+) '
                        r'layout=(packed|strided) calls=1$', data, re.M)
if (len(micro_rows) != 28 or len(set(micro_rows)) != 28
        or len(re.findall(r'^MICRO_PASS\b', data, re.M)) != 28):
    blocked('direct micro case count, identity or actual entries invalid')
counts = (0, 1, 2, 7, 31, 255, 256)
groups = Counter((int(count), layout) for count, lda, layout in micro_rows)
if groups != Counter({(count, layout): 2 for count in counts for layout in ('packed', 'strided')}):
    blocked('direct micro count/layout coverage incomplete')
expected_micro = {(str(count), str(count + padding), layout)
                  for count in counts for padding in (3, 11)
                  for layout in ('packed', 'strided')}
if set(micro_rows) != expected_micro:
    blocked('direct micro leading dimension coverage incomplete')
micro_arguments = argument_rows('micro-t1', data, 28)
for (count, lda, layout), observation in zip(micro_rows, micro_arguments):
    pad_index = 0 if int(lda) - int(count) == 3 else 1
    expected_ldx = 8 if layout == 'packed' else 47 + pad_index * 2
    expected_stride = 2048 if layout == 'packed' else 8
    if observation != (1, expected_ldx, expected_stride):
        blocked('direct actual entry arguments differ from required layout')
if re.findall(r'^PASS .*$', data, re.M) != [
        'PASS micro_cases=28 ordered_FMA_bitwise=1 L_X_guards_unchanged=1']:
    blocked('missing or invalid direct micro summary')

# Recompute expectations from KB=256 and the number of complete 4-row/32-column
# regions below each solved block, independently of the candidate CT task loop.
def expected_entries(m, n):
    return sum(((m - min(kk + 256, m)) // 4) * (n // 32)
               for kk in range(0, m, 256))


full = [(4100, 31), (4100, 32), (4100, 33),
        (4105, 63), (4105, 64), (4105, 65),
        (4111, 95), (4111, 96), (4111, 97)]
specs = [('normal-t1', 1, full, 1), ('normal-t4', 4, full, 1),
         ('normal-t38', 38, full[-1:], 1), ('shared-fail-t4', 4, full[-1:], 1),
         ('no-sve-t4', 4, full[-1:], 0), ('narrow-vl-t4', 4, full[-1:], 0)]
whole = shared_fail = no_sve_cases = narrow_cases = 0
argument_checked_cases = len(micro_arguments)
argument_observations = sum(row[0] for row in micro_arguments)
case_pattern = (r'^CASE_PASS m=(\d+) n=(\d+) threads=(\d+) calls=(\d+) expected=(\d+) '
                r'max_error=(\S+) max_residual=(\S+) padding_L_unchanged=1 shared_fail=([01])$')
for label, threads, cases, wide in specs:
    data = read_log(label)
    shared = label == 'shared-fail-t4'
    narrow = label == 'narrow-vl-t4'
    no_sve = label == 'no-sve-t4'
    check_dispatch(label, data, threads, wide, narrow=narrow, no_sve=no_sve)
    case_rows = re.findall(case_pattern, data, re.M)
    if (len(case_rows) != len(cases)
            or len(re.findall(r'^CASE_PASS\b', data, re.M)) != len(cases)
            or [(int(row[0]), int(row[1])) for row in case_rows] != cases):
        blocked('missing or invalid whole-case identities: ' + label)
    observed_arguments = argument_rows(label, data, len(cases))
    for row, observation in zip(case_rows, observed_arguments):
        m, n, actual_threads, calls, declared = map(int, row[:5])
        expected = expected_entries(m, n) if wide else 0
        if actual_threads != threads or calls != expected or declared != expected or int(row[7]) != int(shared):
            blocked('actual entry count or failure mode differs: ' + label)
        expected_ldx, expected_stride = (n + 7, 8) if shared else (8, 2048)
        if observation != (calls, expected_ldx, expected_stride):
            blocked('actual kernel argument observations differ: ' + label)
        for value in row[5:7]:
            try:
                error = float(value)
            except ValueError:
                blocked('non-numeric error/residual: ' + label)
            if not math.isfinite(error) or not 0.0 <= error <= 1e-12:
                blocked('non-finite or excessive error/residual: ' + label)
    expected_summary = 'PASS whole_cases={} padding_L_unchanged=1 actual_entry_counts=1'.format(len(cases))
    if re.findall(r'^PASS .*$', data, re.M) != [expected_summary]:
        blocked('missing or invalid whole-case summary: ' + label)
    injections = re.findall(r'^SHARED_ALLOC_PASS calls=1 injected=1$', data, re.M)
    if (len(injections) != (len(cases) if shared else 0)
            or len(re.findall(r'^SHARED_ALLOC_PASS\b', data, re.M)) != len(injections)):
        blocked('missing or unexpected shared allocation injection: ' + label)
    whole += len(case_rows)
    shared_fail += len(injections)
    no_sve_cases += len(case_rows) if no_sve else 0
    narrow_cases += len(case_rows) if narrow else 0
    argument_checked_cases += len(observed_arguments)
    argument_observations += sum(row[0] for row in observed_arguments)

if (len(micro_rows), whole, shared_fail, no_sve_cases, narrow_cases,
        argument_checked_cases) != (28, 22, 1, 1, 1, 50):
    blocked('aggregate coverage differs from the fixed 4x32 validation plan')
summary = dict(schema='trsm-wide32-preflight-v1', complete=True,
               micro_cases=len(micro_rows), whole_cases=whole,
               shared_fail_cases=shared_fail, no_sve_cases=no_sve_cases,
               narrow_vl_cases=narrow_cases, argument_checked_cases=argument_checked_cases,
               argument_observations=argument_observations, kernel_argument_mismatches=0,
               test_copy_instrumented=True, original_candidate_modified=False)
with (folder / 'summary.json').open('x') as handle:
    json.dump(summary, handle, indent=2)
    handle.write('\n')
line = ('TRSM_WIDE32_PREFLIGHT_COMPLETE=1 MICRO_CASES={} WHOLE_CASES={} '
        'SHARED_FAIL_CASES={} NO_SVE_CASES={} NARROW_VL_CASES={}\n').format(
            len(micro_rows), whole, shared_fail, no_sve_cases, narrow_cases)
with (folder / 'completion.txt').open('x') as handle:
    handle.write(line)
print(line, end='')
PY
