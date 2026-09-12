#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 3 ]]; then
    echo 'usage: bash preflight-t9/run.sh /absolute/T7/source /absolute/T9/source /absolute/output' >&2
    exit 2
fi
preflight_dir=$(cd "$(dirname "$0")" && pwd)
t7_source=$1
t9_source=$2
output_dir=$3
[[ "$t7_source" = /* && "$t9_source" = /* && "$output_dir" = /* ]] || exit 2
[[ -f "$t7_source/trsm.c" && -f "$t9_source/trsm.c" ]] || exit 2
mkdir -p "$output_dir"
[[ ! -e "$output_dir/summary.tsv" ]] || { echo 'PREFLIGHT_BLOCKED output already used'; exit 2; }
trap 'rc=$?; printf "%d\n" "$rc" > "$output_dir/exit-code.txt"' EXIT
printf 'label\texit_code\telapsed_seconds\n' > "$output_dir/summary.tsv"
: > "$output_dir/commands.txt"
[[ -n "${TRSM_SCHEDULER_JOB_ID:-}" ]] || { echo 'PREFLIGHT_BLOCKED TRSM_SCHEDULER_JOB_ID is required'; exit 2; }
export OMP_DYNAMIC=FALSE OMP_PROC_BIND=close OMP_PLACES=cores
cc=${CC:-gcc}
flags=(-O3 -fno-fast-math -ffp-contract=off -fopenmp -mcpu="${CPU_TARGET:-generic}")
{
    printf 'TRSM_SCHEDULER_JOB_ID=%s\nCC=%s\nCPU_TARGET=%s\n' "$TRSM_SCHEDULER_JOB_ID" "$cc" "${CPU_TARGET:-generic}"
    printf 'OMP_NUM_THREADS=1\nOMP_DYNAMIC=%s\nOMP_PROC_BIND=%s\nOMP_PLACES=%s\n' "$OMP_DYNAMIC" "$OMP_PROC_BIND" "$OMP_PLACES"
    printf 'T7_SOURCE=%s\nT9_SOURCE=%s\n' "$t7_source" "$t9_source"
    printf 'NUMERIC_REFERENCE=T7-diagpanel\nPERFORMANCE_BASELINE=T8-svepanel16\nBLAS_LINKED=none\n'
} > "$output_dir/environment.log"
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
        printf 'TRSM_T9_PREFLIGHT_FAILED=%s EXIT_CODE=%d\n' "$label" "$rc"
        exit "$rc"
    fi
}
run_step guard python3 "$preflight_dir/guard.py"
cp "$output_dir/guard.log" "$output_dir/guard.json"
run_step compiler "$cc" --version
run_step build-t7 "$cc" "${flags[@]}" -Dl_trsm=trsm_t7_reference -c "$t7_source/trsm.c" -o "$output_dir/trsm-t7.o"
run_step build-t9 "$cc" "${flags[@]}" -Dl_trsm=trsm_t9_candidate -c "$t9_source/trsm.c" -o "$output_dir/trsm-t9.o"
run_step build-check "$cc" "${flags[@]}" "$preflight_dir/check-t7-t9.c" "$output_dir/trsm-t7.o" "$output_dir/trsm-t9.o" -lm -o "$output_dir/check-t7-t9"
run_step assembly-t9 "$cc" "${flags[@]}" -S "$t9_source/trsm.c" -o "$output_dir/trsm-t9.s"
run_step numeric-t1 env OMP_NUM_THREADS=1 "$output_dir/check-t7-t9"
run_step verify-summary grep -Fx 'TRSM_T9_NUMERIC_COMPLETE=1 CASES=105 ELEMENTS=62853 SOLVES=210 FINITE_NUMERIC_BITWISE=1 TOLERANCE=1e-12 PADDING_L_UNCHANGED=1' "$output_dir/numeric-t1.log"
cp "$output_dir/verify-summary.log" "$output_dir/completion.txt"
printf 'ASSEMBLY_REVIEW_REQUIRED=1 FILE=%s\n' "$output_dir/trsm-t9.s" | tee "$output_dir/assembly-review-required.txt"
