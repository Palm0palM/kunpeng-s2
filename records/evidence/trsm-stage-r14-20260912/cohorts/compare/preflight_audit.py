"""Read-only r14 preflight contract shared by target driver and local collector."""
import json
import math
from pathlib import Path


MEMBERS = {
    'T8-control12-repeat-r14': (False, False, False),
    'T10-lhistbarrier-repeat-r14': (True, False, False),
    'T17-lhistbudget4': (True, True, False),
    'T18-budgetwide': (True, True, True),
}


def audit_general(folder, source, member):
    folder, source = Path(folder), Path(source)
    packed, budget, wide = MEMBERS[member]
    text = source.read_text()
    actual = ('static void solve16x8_panel_sve(' in text,
              'static void solve16x8_panel_packedL_sve(' in text,
              'TRSM_PACKED_HISTORY_BUDGET_BYTES' in text,
              'static void update4x32_sve(' in text)
    if actual != (True, packed, budget, wide):
        raise RuntimeError('Unexpected preflight source features: ' + member)
    features = dict(has_panel16=True, has_packed_history=packed,
                    has_history_budget=budget,
                    history_budget_bytes=4194304 if budget else 0 if packed else None)
    whole, noop, micro = (518, 64, 28) if packed else (433, 52, 14)
    budget_cases, injections = (32, 3 if budget else 5) if packed else (27, 0)
    shared = 80 + injections if packed else 0
    expected = ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES={} WHOLE_CASES={} NOOP_CASES={} '
                'OLD_MICRO_CASES=14 PACKED_MICRO_CASES={} SHARED_FAIL_CASES={} '
                'ALLOCATION_CASES={} BUDGET_CASES={} BUDGET_SHARED_INJECTIONS={}').format(
                    micro, whole, noop, 14 if packed else 0, shared,
                    whole, budget_cases, injections)
    completion = (folder / 'completion.txt').read_text().strip()
    if completion != expected:
        raise RuntimeError('Incomplete general/budget preflight: ' + member)
    summary = json.loads((folder / 'summary.json').read_text())
    wanted = dict(schema='trsm-r14-preflight-v1', complete=True, source_features=features,
                  micro_cases=micro, old_micro_cases=14, packed_micro_cases=14 if packed else 0,
                  whole_cases=whole, noop_cases=noop, shared_fail_cases=shared,
                  allocation_checked_cases=whole, budget_cases=budget_cases,
                  budget_shared_injections=injections, process_count=18 if packed else 14)
    if any(summary.get(key) != value for key, value in wanted.items()):
        raise RuntimeError('General preflight summary contract differs: ' + member)
    processes = summary.get('processes')
    if not isinstance(processes, list) or len(processes) != (16 if packed else 13):
        raise RuntimeError('Missing whole-process summaries: ' + member)
    if len({p['label'] for p in processes}) != len(processes):
        raise RuntimeError('Duplicate whole-process labels: ' + member)
    for field, total in (('whole_cases', whole), ('noop_cases', noop),
                         ('allocation_checked_cases', whole), ('budget_cases', budget_cases),
                         ('shared_fail_cases', shared)):
        if sum(p[field] for p in processes) != total:
            raise RuntimeError('Process totals differ for ' + field + ': ' + member)
    errors = [summary['max_error']] + [p['max_error'] for p in processes]
    if any(not isinstance(value, (int, float)) or not math.isfinite(value)
           or value < 0 or value > 1e-12 for value in errors):
        raise RuntimeError('Invalid preflight precision: ' + member)
    detail = json.loads((folder / 'budget-summary.json').read_text())
    wanted = dict(schema='trsm-packed-history-budget-v1', complete=True,
                  source_features=features, budget_cases=budget_cases,
                  budget_processes=7 if packed else 6, budget_shared_injections=injections,
                  budget_x_fail_cases=5, budget_no_sve_cases=5, budget_narrow_vl_cases=5)
    if any(detail.get(key) != value for key, value in wanted.items()):
        raise RuntimeError('Budget allocation summary differs: ' + member)
    small_dims = [(m, 9) for m in (1023, 1024, 1039, 1040, 1041)]
    groups = [('budget-t1', 1, 'none', False, small_dims),
              ('budget-t4', 4, 'none', False, small_dims),
              ('budget-t38', 38, 'none', False, [(1039, 313), (1040, 313)]),
              ('budget-x-fail-t4', 4, 'x', False, small_dims),
              ('budget-no-sve-t4', 4, 'no-sve', False, small_dims),
              ('budget-narrow-vl-t4', 4, 'none', True, small_dims)]
    if packed:
        groups.append(('budget-shared-fail-t4', 4, 'shared', False, small_dims))
    identities = [(label, threads, injection, narrow, m, n)
                  for label, threads, injection, narrow, dims in groups for m, n in dims]
    rows = detail.get('allocation_rows')
    if not isinstance(rows, list) or len(rows) != len(identities):
        raise RuntimeError('Missing allocation observations: ' + member)
    for row, (label, threads, injection, narrow, m, n) in zip(rows, identities):
        identity = dict(label=label, threads=threads, injection=injection,
                        narrow_vl=narrow, m=m, n=n)
        if any(row.get(key) != value for key, value in identity.items()):
            raise RuntimeError('Budget case identity differs: ' + member)
        blocks, panels = m // 16, (n + 7) // 8
        history_bytes = 1024 * blocks * (blocks - 1)
        history = packed and injection != 'no-sve' and (not budget or history_bytes <= 4194304)
        sve = injection not in ('x', 'no-sve') and not narrow
        packed_entries = (blocks - 1) * panels if sve and history and injection != 'shared' else 0
        old_entries = blocks * panels - packed_entries if sve else 0
        history_fail = int(history and injection == 'shared')
        x_fail = threads if injection == 'x' else 0
        observed = dict(small=1, history_expected=int(history), history_calls=int(history),
                        history_bytes=history_bytes if history else 0,
                        history_success=int(history) - history_fail, history_fail=history_fail,
                        x_calls=threads, x_bytes=threads * m * 8 * 8,
                        x_success=threads - x_fail, x_fail=x_fail,
                        kb_calls=0, kb_bytes=0, kb_success=0, kb_fail=0,
                        total=threads + int(history), injected=history_fail + x_fail,
                        history_level=0 if history else -1, x_level=1, kb_level=-1,
                        shape_bad=0, x_each_worker_once=1,
                        old_entries=old_entries, packed_entries=packed_entries)
        if any(row.get(key) != value for key, value in observed.items()):
            raise RuntimeError('Budget allocation/entry evidence differs: ' + member + '/' + label)
    return dict(completion=completion, summary=summary, budget_summary=detail)


def audit_wide(folder):
    folder = Path(folder)
    completion = (folder / 'completion.txt').read_text().strip()
    expected = ('TRSM_WIDE32_PREFLIGHT_COMPLETE=1 MICRO_CASES=28 WHOLE_CASES=28 '
                'SHARED_FAIL_CASES=1 NO_SVE_CASES=1 NARROW_VL_CASES=1')
    if completion != expected:
        raise RuntimeError('T18 wide32 preflight incomplete')
    summary = json.loads((folder / 'summary.json').read_text())
    wanted = dict(complete=True, micro_cases=28, whole_cases=28, argument_checked_cases=56,
                  kernel_argument_mismatches=0, original_candidate_modified=False,
                  expected_CT=64, KB=256, tile_config_processes=7)
    if (any(summary.get(key) != value for key, value in wanted.items())
            or not isinstance(summary.get('argument_observations'), int)
            or summary['argument_observations'] <= 0):
        raise RuntimeError('T18 wide32 argument evidence differs')
    return dict(completion=completion, summary=summary)
