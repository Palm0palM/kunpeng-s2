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
test_flags=(-finstrument-functions "-DTEST_HAS_PANEL16=$has_panel16" "-DTRSM_SOURCE=\"$source_dir/trsm.c\"")
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
run_step assembly "$cc" "${flags[@]}" -S "$source_dir/trsm.c" -o "$output_dir/trsm-panel16.s"
micro_cases=0
if [[ $has_panel16 == 1 ]]; then
    run_step micro-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" micro
    micro_cases=14
fi
run_step normal-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" full
run_step normal-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" full
run_step normal-t38 env OMP_NUM_THREADS=38 "$output_dir/check-normal" smoke
run_step boundary-t1 env OMP_NUM_THREADS=1 "$output_dir/check-normal" boundary
run_step no-sve-t4 env OMP_NUM_THREADS=4 "$output_dir/check-no-sve" full
run_step fail-alloc-t4 env OMP_NUM_THREADS=4 "$output_dir/check-fail-alloc" full
run_step narrow-vl-t4 env OMP_NUM_THREADS=4 "$output_dir/check-normal" --narrow-vl full
printf 'TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES=%d WHOLE_CASES=406 NOOP_CASES=28\n' "$micro_cases" | tee "$output_dir/completion.txt"
