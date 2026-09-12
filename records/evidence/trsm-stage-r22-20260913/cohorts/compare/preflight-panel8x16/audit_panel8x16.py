#!/usr/bin/env python3
"""Read-only T19 original-log audit; explicit finalize CLI alone writes summaries.

Import has no task execution, file reads, writes or subprocess side effects.
"""
from pathlib import Path
import csv
import json
import math
import re
import sys


def check_source(source):
    source = Path(source)
    if source.is_symlink() or not source.is_file():
        raise ValueError('PREFLIGHT_BLOCKED missing regular frozen source')
    text = source.read_text()
    for name in ('solve16x8_panel_sve','solve16x8_panel_packedL_sve','solve8x16_panel_sve','solve_panel_wide8x16'):
        if len(re.findall(r'static\s+void\s+'+name+r'\s*\(',text)) != 1:
            raise ValueError('PREFLIGHT_BLOCKED missing/duplicate expected source function '+name)
    if 'TRSM_PACKED_HISTORY_BUDGET_BYTES' not in text:
        raise ValueError('PREFLIGHT_BLOCKED missing source history budget')
    return text


def check_artifacts(folder, original):
    folder = Path(folder)
    instrumented = folder/'instrumented-trsm.c'
    hook = '\n    trsm_test_wide_arguments(start,lda,L,x0,x1);'
    if instrumented.is_symlink() or not instrumented.is_file():
        raise ValueError('PREFLIGHT_BLOCKED missing regular instrumented source')
    copy = instrumented.read_text()
    if copy.count(hook) != 1 or copy.replace(hook,'',1) != original:
        raise ValueError('PREFLIGHT_BLOCKED instrumented source differs beyond the declared hook')
    assembly = folder/'trsm-panel8x16.s'
    if assembly.is_symlink() or not assembly.is_file():
        raise ValueError('PREFLIGHT_BLOCKED missing original-source assembly')
    text = assembly.read_text()
    if ('solve8x16_panel_sve' not in text or 'trsm_test_wide_arguments' in text
            or '__cyg_profile_func_' in text):
        raise ValueError('PREFLIGHT_BLOCKED assembly absent or contains test instrumentation')


def _parse(folder, include_verify):
    folder = Path(folder)
    guard = json.loads((folder/'guard.json').read_text())
    cpus = guard.get('allowed_cpus', [])
    if (guard != json.loads((folder/'guard.log').read_text())
            or guard.get('guard_pass') is not True
            or not re.fullmatch(r'[0-9]+', str(guard.get('scheduler_job_id','')))
            or guard.get('allowed_cpu_count') != 38 or len(cpus) != 38
            or len(set(cpus)) != 38 or any(type(cpu) is not int or cpu < 0 for cpu in cpus)
            or len(guard.get('numa_nodes', [])) != 1):
        raise ValueError('PREFLIGHT_BLOCKED compute guard evidence differs')
    if (folder/'instrument-source.log').read_text().splitlines() != [
            'INSTRUMENTED_SOURCE_PASS kernel_hook=1 original_modified=0']:
        raise ValueError('PREFLIGHT_BLOCKED missing instrumented source generation evidence')
    has_panel = has_packed = has_budget = 1
    budget_bytes = 4194304 if has_budget else 0
    features = dict(panel16=has_panel, packedL16=has_packed, has_budget=has_budget,
                    history_budget_bytes=budget_bytes, panel8x16=1)
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
    wide_grid = [(m,n) for m in (1039,1040) for n in (15,16,17,31,32,33)]
    specs += [('wide-normal-t1',1,'wide-grid',wide_grid,'none',False),
              ('wide-normal-t4',4,'wide-grid',wide_grid,'none',False),
              ('wide-normal-t38',38,'wide-grid-tail',wide_grid+[(1047,33)],'none',False),
              ('wide-no-sve-t4',4,'wide-grid',wide_grid,'no-sve',False),
              ('wide-narrow-vl-t4',4,'wide-grid',wide_grid,'none',True),
              ('wide-shared-fail-t4',4,'wide-grid',wide_grid,'shared',False),
              ('wide-x-fail-t4',4,'wide-grid',wide_grid,'x',False),
              ('wide-all-fail-t4',4,'wide-grid',wide_grid,'all',False)]


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
        observed = rows(data, marker)
        if any(not re.fullmatch(r'-?(?:0|[1-9][0-9]*)', value)
               for row in observed for value in row.values()):
            block('noninteger ' + marker)
        return [{key: int(value) for key, value in row.items()} for row in observed]


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


    build_steps = ['guard', 'compiler', 'instrument-source', 'build-normal', 'build-no-sve', 'build-fail-alloc', 'build-fail-x']
    if has_packed:
        build_steps.append('build-fail-shared')
    build_steps.append('assembly')
    micro_steps = ['micro-t1','packed-micro-t1','wide-micro-t1']
    with (folder / 'summary.tsv').open() as handle:
        reader = csv.DictReader(handle, delimiter='\t')
        if reader.fieldnames != ['label', 'exit_code', 'elapsed_seconds']:
            block('step summary header')
        steps = list(reader)
    if ([row['label'] for row in steps] != build_steps + micro_steps + [s[0] for s in specs] + (['verify-results'] if include_verify else [])
            or any(row['exit_code'] != '0' or not re.fullmatch(r'\d+', row['elapsed_seconds']) for row in steps)):
        block('missing/failed/duplicate steps')

    whole = noop = shared_fail = budget_cases = budget_shared_injections = 0
    budget_allocations = []
    argument_rows = []
    wrapper_calls = wide_kernel_calls = 0
    processes = []
    max_error = 0.0
    for label, threads, mode, dims, injection, narrow in specs:
        data, can_enter, packed_enter = read_process(label, threads, mode, injection, narrow)
        cases = int_rows(data, 'CASE_PASS')
        allocations = int_rows(data, 'ALLOC_PASS')
        arguments = int_rows(data, 'ARGUMENTS_PASS')
        if ([(row.get('m'), row.get('n')) for row in cases] != dims
                or [(row.get('m'), row.get('n')) for row in allocations] != dims
                or [(row.get('m'), row.get('n')) for row in arguments] != dims):
            block('case/allocation identity mismatch: ' + label)
        injections = []
        for (m, n), case, allocation, argument in zip(dims, cases, allocations, arguments):
            small = m * (m + 1) // 2 * 8 <= 64 * 1024 * 1024
            blocks = m // 16
            history_bytes = 1024 * blocks * (blocks - 1) if blocks >= 2 else 0
            history = int(bool(small and has_packed and injection != 'no-sve' and blocks >= 2
                               and (not has_budget or history_bytes <= budget_bytes)))
            wide_path = int(bool(small and injection != 'no-sve' and blocks >= 2 and history_bytes > budget_bytes))
            xcalls = threads if small else 0
            kbcalls = int(not small)
            hf = history if injection in ('all', 'shared') else 0
            xf = xcalls if injection in ('all', 'x') else 0
            kf = kbcalls if injection == 'all' else 0
            expected_allocation = dict(m=m, n=n, small=int(small), wide_path=wide_path, history_expected=history,
                history_calls=history, history_bytes=history * history_bytes,
                history_success=history-hf, history_fail=hf,
                x_calls=xcalls, x_bytes=xcalls*m*(128 if wide_path else 64), x_success=xcalls-xf, x_fail=xf,
                kb_calls=kbcalls, kb_bytes=kbcalls*((n+7)//8)*256*64,
                kb_success=kbcalls-kf, kb_fail=kf, total=history+xcalls+kbcalls,
                injected=hf+xf+kf, history_level=0 if history else -1,
                x_level=1 if xcalls else -1, kb_level=0 if kbcalls else -1,
                shape_bad=0, x_each_worker_once=1)
            if allocation != expected_allocation:
                block('actual allocations/bytes/levels/successes differ: ' + label + ' ' + str((m,n)))
            total_entries = blocks * ((n+7)//8) if small and can_enter else 0
            if wide_path:
                total_entries = blocks * (((n%16)+7)//8) if can_enter else 0
            new_entries = (m//8)*(n//16) if wide_path and can_enter else 0
            packed_entries = (blocks-1)*((n+7)//8) if total_entries and packed_enter and history else 0
            if case != dict(m=m, n=n, sve16_entries=total_entries, expected=total_entries,
                            old_entries=total_entries-packed_entries, packed_entries=packed_entries,
                            packed_expected=packed_entries, wide_entries=new_entries, wide_expected=new_entries,
                            wrapper_entries=wide_path, wrapper_expected=wide_path):
                block('actual original/packed/wide/wrapper entries differ: ' + label)
            if argument != dict(m=m,n=n,calls=new_entries,bad=0,expected_panel_stride=m*8):
                block('actual new-kernel argument observation differs: ' + label)
            argument_rows.append(dict(label=label,threads=threads,injection=injection,narrow_vl=narrow,
                                      **argument,wrapper_entries=wide_path))
            wrapper_calls += wide_path
            wide_kernel_calls += new_entries
            if injection == 'shared' and history:
                injections.append(dict(m=m, n=n, calls=threads+1, injected=1, shared_first=1, later_X_success=threads))
            if label.startswith('budget-'):
                budget_allocations.append(dict(label=label, threads=threads, injection=injection,
                                               narrow_vl=narrow, **allocation,
                                               old_entries=case['old_entries'], packed_entries=case['packed_entries'],
                                               wide_entries=case['wide_entries'], wrapper_entries=case['wrapper_entries']))
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
            if (results != ['14'] or rows(text,'PASS') != [{field:'14',
                    'ordered_FMA_bitwise':'1','prefix_padding_L_unchanged':'1','history_unchanged':'1'}]
                    or re.search(r'^FAIL\b', text, re.M)):
                raise SystemExit('PREFLIGHT_BLOCKED missing direct micro evidence: ' + label)
            if field == 'micro_cases': micro = int(results[0])
            else: packed_micro = int(results[0])
    text, _, _ = read_process('wide-micro-t1',1,'wide-micro')
    wide_micro_rows = int_rows(text,'WIDE_MICRO_PASS')
    expected_micro_rows = [dict(start=start,lda=start+8+pad,calls=1,arguments=1,bad=0,panel_stride=(start+8)*8)
                         for start in (0,1,7,8,9,15,16,255,256) for pad in (1,7)]
    if wide_micro_rows != expected_micro_rows or rows(text,'PASS') != [dict(wide_micro_cases='18',
            ordered_FMA_bitwise='1',prefix_padding_L_unchanged='1',two_panels_unchanged_outside_rows='1')]:
        block('missing or incorrect direct wide micro/argument evidence')
    wide_micro = len(wide_micro_rows)
    expected_totals = (615,96,89,32)
    if (whole, noop, shared_fail, budget_cases) != expected_totals:
        block('aggregate coverage differs from fixed T19 protocol')
    source_features = dict(has_panel16=bool(has_panel), has_packed_history=bool(has_packed),
                           has_history_budget=bool(has_budget),
                           history_budget_bytes=budget_bytes, has_panel8x16=True)
    budget_summary = dict(schema='trsm-packed-history-budget-panel8x16-v1', complete=True,
                          source_features=source_features, budget_cases=budget_cases,
                          budget_processes=sum(p['budget_cases'] > 0 for p in processes),
                          budget_shared_injections=budget_shared_injections,
                          budget_x_fail_cases=5, budget_no_sve_cases=5, budget_narrow_vl_cases=5,
                          allocation_rows=budget_allocations)
    summary = dict(schema='trsm-panel8x16-preflight-v1', complete=True, source_features=source_features,
                   micro_cases=micro+packed_micro+wide_micro, old_micro_cases=micro, packed_micro_cases=packed_micro, wide_micro_cases=wide_micro,
                   whole_cases=whole, noop_cases=noop, shared_fail_cases=shared_fail,
                   allocation_checked_cases=whole, budget_cases=budget_cases,
                   budget_shared_injections=budget_shared_injections,
                   process_count=len(processes)+len(micro_steps), max_error=max_error, processes=processes)
    parameters = dict(schema='trsm-panel8x16-arguments-v1',complete=True,source_features=source_features,
        whole_argument_checked_cases=len(argument_rows),micro_argument_checked_cases=wide_micro,
        argument_checked_cases=len(argument_rows)+wide_micro,argument_observations=wide_kernel_calls+wide_micro,
        whole_wide_kernel_calls=wide_kernel_calls,wrapper_calls=wrapper_calls,kernel_argument_mismatches=0,
        test_copy_instrumented=True,original_candidate_modified=False,
        whole_argument_rows=argument_rows,micro_argument_rows=wide_micro_rows)
    line = ('TRSM_PANEL8X16_PREFLIGHT_COMPLETE=1 MICRO_CASES={} WHOLE_CASES={} NOOP_CASES={} '
            'OLD_MICRO_CASES={} PACKED_MICRO_CASES={} WIDE_MICRO_CASES={} SHARED_FAIL_CASES={} '
            'ALLOCATION_CASES={} BUDGET_CASES={} BUDGET_SHARED_INJECTIONS={} '
            'ARGUMENT_CHECKED_CASES={} ARGUMENT_OBSERVATIONS={} WRAPPER_CALLS={}\n').format(
            micro+packed_micro+wide_micro,whole,noop,micro,packed_micro,wide_micro,shared_fail,
            whole,budget_cases,budget_shared_injections,parameters['argument_checked_cases'],
            parameters['argument_observations'],wrapper_calls)
    return dict(completion=line.strip(),summary=summary,budget_summary=budget_summary,
                parameters_summary=parameters,guard=guard)


def audit_panel8x16(folder, source):
    """Reparse raw logs and compare stored results; returns JSON-serializable evidence."""
    folder = Path(folder)
    original = check_source(source)
    check_artifacts(folder, original)
    expected = _parse(folder, True)
    for key, name in [('summary','summary.json'),('budget_summary','budget-summary.json'),
                      ('parameters_summary','panel8x16-summary.json')]:
        path = folder/name
        if path.is_symlink() or not path.is_file() or json.loads(path.read_text()) != expected[key]:
            raise ValueError('PREFLIGHT_BLOCKED stored result differs from actual logs: '+name)
    path = folder/'completion.txt'
    if path.is_symlink() or not path.is_file() or path.read_text() != expected['completion']+'\n':
        raise ValueError('PREFLIGHT_BLOCKED completion differs from actual logs')
    return expected


def main():
    if len(sys.argv) != 4 or sys.argv[1] != 'finalize':
        raise SystemExit('usage: audit_panel8x16.py finalize OUTPUT_DIR ORIGINAL_SOURCE')
    folder = Path(sys.argv[2])
    original = check_source(sys.argv[3])
    check_artifacts(folder, original)
    result = _parse(folder, False)
    for key,name in [('summary','summary.json'),('budget_summary','budget-summary.json'),
                     ('parameters_summary','panel8x16-summary.json')]:
        with (folder/name).open('x') as handle:
            json.dump(result[key],handle,indent=2);handle.write('\n')
    with (folder/'completion.txt').open('x') as handle:
        handle.write(result['completion']+'\n')
    print(result['completion'])


if __name__ == '__main__':
    main()
