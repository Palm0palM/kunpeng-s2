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
has_history_budget=0
if grep -Fq 'TRSM_PACKED_HISTORY_BUDGET_BYTES' "$source_dir/trsm.c"; then has_history_budget=1; fi
[[ $has_history_budget == 0 || $has_packedl16 == 1 ]] || { echo 'PREFLIGHT_BLOCKED history budget lacks packed kernel'; exit 2; }
test_flags=(-finstrument-functions "-DTEST_HAS_PANEL16=$has_panel16" "-DTEST_HAS_PACKEDL16=$has_packedl16" "-DTEST_HAS_HISTORY_BUDGET=$has_history_budget" "-DTRSM_SOURCE=\"$source_dir/trsm.c\"")
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
run_step build-fail-x "$cc" "${flags[@]}" "${test_flags[@]}" -DTEST_X_ALLOC_FAIL "$preflight_dir/check-panel.c" -lm -o "$output_dir/check-fail-x"
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
run_step budget-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" budget
run_step budget-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" budget
run_step budget-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" budget-smoke
run_step budget-x-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-x" budget
run_step budget-no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" budget
run_step budget-narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl budget
if [[ $has_packedl16 == 1 ]]; then
    run_step budget-shared-fail-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-shared" budget
fi
run_step verify-results python3 - "$output_dir" "$has_panel16" "$has_packedl16" "$has_history_budget" <<'PY'
from pathlib import Path
import csv
import json
import math
import re
import sys

folder = Path(sys.argv[1])
has_panel, has_packed, has_budget = map(int, sys.argv[2:])
if any(value not in (0, 1) for value in (has_panel, has_packed, has_budget)) or has_budget > has_packed or has_packed > has_panel:
    raise SystemExit('PREFLIGHT_BLOCKED invalid detected source features')
budget_bytes = 4194304 if has_budget else 0
features = dict(panel16=has_panel, packedL16=has_packed, has_budget=has_budget,
                history_budget_bytes=budget_bytes)
full = [(m, n) for m in (1, 3, 4, 5, 15, 16, 17, 31, 32, 33, 63, 64, 65, 255, 256, 257)
        for n in (1, 7, 8, 9, 17)]
shared = [(m, n) for m in (32, 33, 63, 64, 65, 255, 256, 257) for n in (1, 7, 8, 9, 17)]
boundary = [(m, 9) for m in (1023, 1024, 1039, 1040, 1041)]
# label, thread count, CLI mode, dimensions, injection, narrow VL
specs = [('normal-t1', 1, 'full', full, 'none', False),
         ('normal-t4', 4, 'full', full, 'none', False),
         ('normal-t38', 38, 'smoke', [(15,9),(16,17),(33,313),(257,313)], 'none', False),
         ('boundary-t1', 1, 'boundary', [(4095,9),(4097,9)], 'none', False),
         ('no-sve-t4', 4, 'full', full, 'no-sve', False),
         ('fail-alloc-t4', 4, 'full', full, 'all', False),
         ('narrow-vl-t4', 4, 'full', full, 'none', True)]
if has_packed:
    specs += [('shared-fail-t1', 1, 'shared-fail', shared, 'shared', False),
              ('shared-fail-t4', 4, 'shared-fail', shared, 'shared', False)]
specs += [('budget-t1', 1, 'budget', boundary, 'none', False),
          ('budget-t4', 4, 'budget', boundary, 'none', False),
          ('budget-t38', 38, 'budget-smoke', [(1039,313),(1040,313)], 'none', False),
          ('budget-x-fail-t4', 4, 'budget', boundary, 'x', False),
          ('budget-no-sve-t4', 4, 'budget', boundary, 'no-sve', False),
          ('budget-narrow-vl-t4', 4, 'budget', boundary, 'none', True)]
if has_packed:
    specs += [('budget-shared-fail-t4', 4, 'budget', boundary, 'shared', False)]


def block(reason):
    raise SystemExit('PREFLIGHT_BLOCKED ' + reason)


def rows(data, marker):
    result = []
    for line in data.splitlines():
        if not re.match(r'^' + re.escape(marker) + r'\b', line):
            continue
        tokens = line.split()
        if tokens[0] != marker or any(token.count('=') != 1 for token in tokens[1:]):
            block('malformed ' + marker)
        pairs = [token.split('=', 1) for token in tokens[1:]]
        if len({key for key, value in pairs}) != len(pairs):
            block('duplicate field in ' + marker)
        result.append(dict(pairs))
    return result


def int_rows(data, marker):
    try:
        return [{key: int(value) for key, value in row.items()} for row in rows(data, marker)]
    except ValueError:
        block('noninteger ' + marker)


def read_process(label, threads, mode, injection='none', narrow=False):
    data = (folder / (label + '.log')).read_text()
    if re.search(r'^(?:FAIL\b|PREFLIGHT_BLOCKED\b)', data, re.M):
        block('failure marker: ' + label)
    if int_rows(data, 'SOURCE_FEATURES_PASS') != [features]:
        block('source feature evidence mismatch: ' + label)
    can_enter = int(bool(has_panel and not narrow and injection not in ('no-sve', 'all', 'x')))
    packed_enter = int(bool(has_packed and can_enter and injection != 'shared'))
    mode_line = 'MODE={} THREADS={} NARROW_VL={} EXPECT_SVE16={} EXPECT_PACKEDL16={}'.format(
        mode, threads, int(narrow), can_enter, packed_enter)
    if re.findall(r'^MODE=.*$', data, re.M) != [mode_line]:
        block('mode/worker/vector dispatch differs: ' + label)
    return data, can_enter, packed_enter


build_steps = ['guard', 'compiler', 'build-normal', 'build-no-sve', 'build-fail-alloc', 'build-fail-x']
if has_packed:
    build_steps.append('build-fail-shared')
build_steps.append('assembly')
micro_steps = (['micro-t1'] if has_panel else []) + (['packed-micro-t1'] if has_packed else [])
with (folder / 'summary.tsv').open() as handle:
    reader = csv.DictReader(handle, delimiter='\t')
    if reader.fieldnames != ['label', 'exit_code', 'elapsed_seconds']:
        block('step summary header')
    steps = list(reader)
if ([row['label'] for row in steps] != build_steps + micro_steps + [s[0] for s in specs]
        or any(row['exit_code'] != '0' or not re.fullmatch(r'\d+', row['elapsed_seconds']) for row in steps)):
    block('missing/failed/duplicate steps')

whole = noop = shared_fail = budget_cases = budget_shared_injections = 0
budget_allocations = []
processes = []
max_error = 0.0
for label, threads, mode, dims, injection, narrow in specs:
    data, can_enter, packed_enter = read_process(label, threads, mode, injection, narrow)
    cases = int_rows(data, 'CASE_PASS')
    allocations = int_rows(data, 'ALLOC_PASS')
    if ([(row.get('m'), row.get('n')) for row in cases] != dims
            or [(row.get('m'), row.get('n')) for row in allocations] != dims):
        block('case/allocation identity mismatch: ' + label)
    injections = []
    for (m, n), case, allocation in zip(dims, cases, allocations):
        small = m * (m + 1) // 2 * 8 <= 64 * 1024 * 1024
        blocks = m // 16
        history_bytes = 1024 * blocks * (blocks - 1) if blocks >= 2 else 0
        history = int(bool(small and has_packed and injection != 'no-sve' and blocks >= 2
                           and (not has_budget or history_bytes <= budget_bytes)))
        xcalls = threads if small else 0
        kbcalls = int(not small)
        hf = history if injection in ('all', 'shared') else 0
        xf = xcalls if injection in ('all', 'x') else 0
        kf = kbcalls if injection == 'all' else 0
        expected_allocation = dict(m=m, n=n, small=int(small), history_expected=history,
            history_calls=history, history_bytes=history * history_bytes,
            history_success=history-hf, history_fail=hf,
            x_calls=xcalls, x_bytes=xcalls*m*64, x_success=xcalls-xf, x_fail=xf,
            kb_calls=kbcalls, kb_bytes=kbcalls*((n+7)//8)*256*64,
            kb_success=kbcalls-kf, kb_fail=kf, total=history+xcalls+kbcalls,
            injected=hf+xf+kf, history_level=0 if history else -1,
            x_level=1 if xcalls else -1, kb_level=0 if kbcalls else -1,
            shape_bad=0, x_each_worker_once=1)
        if allocation != expected_allocation:
            block('actual allocations/bytes/levels/successes differ: ' + label + ' ' + str((m,n)))
        total_entries = blocks * ((n+7)//8) if small and can_enter else 0
        packed_entries = (blocks-1)*((n+7)//8) if total_entries and packed_enter and history else 0
        if case != dict(m=m, n=n, sve16_entries=total_entries, expected=total_entries,
                        old_entries=total_entries-packed_entries, packed_entries=packed_entries,
                        packed_expected=packed_entries):
            block('actual original/packed entries differ: ' + label)
        if injection == 'shared' and history:
            injections.append(dict(m=m, n=n, calls=threads+1, injected=1, shared_first=1, later_X_success=threads))
        if label.startswith('budget-'):
            budget_allocations.append(dict(label=label, threads=threads, injection=injection,
                                           narrow_vl=narrow, **allocation,
                                           old_entries=case['old_entries'], packed_entries=case['packed_entries']))
    if int_rows(data, 'SHARED_ALLOC_PASS') != injections:
        block('actual shared-only injection evidence: ' + label)
    budget_count = len(dims) if label.startswith('budget-') else 0
    if int_rows(data, 'ALLOCATION_SUMMARY_PASS') != [dict(cases=len(dims), budget_cases=budget_count,
                                                        shared_injection_cases=len(injections))]:
        block('allocation summary differs: ' + label)
    summaries = rows(data, 'PASS')
    if len(summaries) != 1:
        block('missing or duplicate whole summary: ' + label)
    result = summaries[0]
    try:
        error = float(result.pop('max_error'))
    except (KeyError, ValueError):
        block('missing/nonnumeric error: ' + label)
    if (not math.isfinite(error) or not 0 <= error <= 1e-12
            or result != dict(whole_cases=str(len(dims)), noop_cases='4',
                              non_dyadic_long_double_RHS='1', padding_L_unchanged='1')):
        block('whole summary precision or evidence: ' + label)
    max_error = max(max_error, error)
    whole += len(dims); noop += 4; shared_fail += len(injections); budget_cases += budget_count
    if budget_count:
        budget_shared_injections += len(injections)
    processes.append(dict(label=label, threads=threads, whole_cases=len(dims),
                          noop_cases=4, allocation_checked_cases=len(allocations),
                          budget_cases=budget_count, shared_fail_cases=len(injections), max_error=error))

micro, packed_micro = 0, 0
for enabled, label, field in ((has_panel, 'micro-t1', 'micro_cases'),
                               (has_packed, 'packed-micro-t1', 'packed_micro_cases')):
    if enabled:
        text, _, _ = read_process(label, 1, 'packed-micro' if field == 'packed_micro_cases' else 'micro')
        results = re.findall(r'^PASS ' + field + r'=(\d+) ordered_FMA_bitwise=1 '
                             r'prefix_padding_L_unchanged=1 history_unchanged=1$', text, re.M)
        if results != ['14'] or re.search(r'^FAIL\b', text, re.M):
            raise SystemExit('PREFLIGHT_BLOCKED missing direct micro evidence: ' + label)
        if field == 'micro_cases': micro = int(results[0])
        else: packed_micro = int(results[0])
expected_totals = (518, 64, 83 if has_budget else 85, 32) if has_packed else (433, 52, 0, 27)
if (whole, noop, shared_fail, budget_cases) != expected_totals:
    block('aggregate coverage differs from fixed r14 protocol')
source_features = dict(has_panel16=bool(has_panel), has_packed_history=bool(has_packed),
                       has_history_budget=bool(has_budget),
                       history_budget_bytes=None if not has_packed else budget_bytes)
budget_summary = dict(schema='trsm-packed-history-budget-v1', complete=True,
                      source_features=source_features, budget_cases=budget_cases,
                      budget_processes=sum(p['budget_cases'] > 0 for p in processes),
                      budget_shared_injections=budget_shared_injections,
                      budget_x_fail_cases=5, budget_no_sve_cases=5, budget_narrow_vl_cases=5,
                      allocation_rows=budget_allocations)
summary = dict(schema='trsm-r14-preflight-v1', complete=True, source_features=source_features,
               micro_cases=micro+packed_micro, old_micro_cases=micro, packed_micro_cases=packed_micro,
               whole_cases=whole, noop_cases=noop, shared_fail_cases=shared_fail,
               allocation_checked_cases=whole, budget_cases=budget_cases,
               budget_shared_injections=budget_shared_injections,
               process_count=len(processes)+len(micro_steps), max_error=max_error, processes=processes)
for filename, value in [('budget-summary.json', budget_summary), ('summary.json', summary)]:
    with (folder / filename).open('x') as handle:
        json.dump(value, handle, indent=2)
        handle.write('\n')
line = ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES={} WHOLE_CASES={} NOOP_CASES={} '
        'OLD_MICRO_CASES={} PACKED_MICRO_CASES={} SHARED_FAIL_CASES={} '
        'ALLOCATION_CASES={} BUDGET_CASES={} BUDGET_SHARED_INJECTIONS={}\n').format(
            micro + packed_micro, whole, noop, micro, packed_micro, shared_fail,
            whole, budget_cases, budget_shared_injections)
with (folder / 'completion.txt').open('x') as handle:
    handle.write(line)
print(line, end='')
PY
