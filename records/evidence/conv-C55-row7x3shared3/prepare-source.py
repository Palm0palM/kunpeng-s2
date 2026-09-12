"""One-shot C55 text preparation/checkpoint; no compiler, operator, SSH or job."""
from pathlib import Path
import argparse
import difflib
import hashlib
import json
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools'))
import experiment as e

BASE = Path(__file__).resolve().parent
VERSION = 'C55-row7x3shared3'
PARENT = 'C52-row7x3shared2'
PARENT_SHA = '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'
FROZEN = ROOT / '.runs/conv' / PARENT / 'sve-correctness-sep13t'


def brace_end(text, opening):
    assert text[opening] == '{'
    depth, cursor = 1, opening + 1
    while depth:
        depth += (text[cursor] == '{') - (text[cursor] == '}')
        cursor += 1
    return cursor


with e.locked():
    prior = e.read_json(e.record_path('conv', VERSION))
    assert prior['status'] == 'planned', 'One-shot only: preserve prepared/measured source'
    validation = e.read_json(FROZEN / 'validation.json')
    freeze = e.read_json(FROZEN / 'freeze-source.json')
    assert validation['candidate'] == PARENT and validation['job_id'] == '1582134'
    assert validation['status'] == 'passed' and validation['complete'] is True
    assert validation['total_cases'] == 37128 and validation['source_hashes_verified'] is True
    assert validation['assembly']['review_complete'] is True
    assert freeze['candidate'] == PARENT and freeze['job_id'] == '1582134' and freeze['mode'] == 'passed'
    parent_bytes = (FROZEN / 'source/conv2d.c').read_bytes()
    assert hashlib.sha256(parent_bytes).hexdigest() == validation['source_hashes']['conv2d.c'] == PARENT_SHA
    parent = parent_bytes.decode()
    before = e.source_files(BASE / 'source')
    assert before == e.source_files(ROOT / '.runs/conv' / PARENT / 'source') == e.get_record('conv', PARENT)['source_hashes']
    candidate = BASE / 'source/conv2d.c'
    assert candidate.read_bytes() == parent_bytes, 'Initial candidate must be actual frozen T kernel'

    anchor = parent.index('        /* Shared input rows advance all seven outputs in strict kernel-column order. */')
    old_comment = '            /* Preserve each accumulator order: column ik, then column ik+1. */'
    begin = parent.index(old_comment, anchor)
    loop = parent.index('            for (; kw - ik >= 2; ik += 2) {', begin)
    loop_open = parent.index('{', loop)
    end = brace_end(parent, loop_open)
    first_start = parent.index('                {\n', loop_open)
    first_end = brace_end(parent, parent.index('{', first_start))
    first = parent[first_start:first_end]
    second_start = parent.index('                {\n', first_end)
    second_end = brace_end(parent, parent.index('{', second_start))
    second = parent[second_start:second_end]
    assert second == first.replace('const int column = ik;', 'const int column = ik + 1;')
    assert parent[first_end:second_start] == '\n'
    assert parent[second_end:end] == '\n            }'
    assert first.count('const int column = ik;') == 1
    assert first.count('svdup_n_f32(') == 7 and first.count('svld1(') == 3
    assert first.count('svmul_f32_x(') == first.count('svadd_f32_x(') == 21
    # Duplicate the complete original column body, not an algebraic rewrite.
    # Scopes are lexical only; actual scheduling, live ranges and spills need C55 assembly.
    columns = [first.replace('const int column = ik;', 'const int column = ' + expression + ';')
               for expression in ('ik', 'ik + 1', 'ik + 2')]
    replacement = ('            /* Preserve each accumulator order: columns ik, ik+1, ik+2. */\n'
                   '            for (; kw - ik >= 3; ik += 3) {\n'
                   + '\n'.join(columns) + '\n            }')
    result = parent[:begin] + replacement + parent[end:]
    assert result[:begin] == parent[:begin] and result[begin + len(replacement):] == parent[end:]
    assert '            for (; ik < kw; ++ik) {' in parent[end:]
    assert result.count('for (; kw - ik >= 3; ik += 3)') == 1
    assert 'for (; kw - ik >= 2; ik += 2)' not in result
    assert replacement.count('svmul_f32_x(') == replacement.count('svadd_f32_x(') == 63
    assert replacement.count('svld1(') == 9 and replacement.count('svdup_n_f32(') == 21
    candidate.write_bytes(result.encode())
    after = e.source_files(BASE / 'source')
    assert {k: v for k, v in before.items() if k != 'conv2d.c'} == {k: v for k, v in after.items() if k != 'conv2d.c'}
    (BASE / 'candidate.patch').write_text(''.join(difflib.unified_diff(
        parent.splitlines(keepends=True), result.splitlines(keepends=True),
        fromfile='C52-T-frozen/source/conv2d.c', tofile=VERSION + '/source/conv2d.c')))
    meta = e.read_json(BASE / 'experiment.json')
    # Keep experiment.json source_hashes as the standard immutable creation snapshot.
    meta.update(source_parent=PARENT, source_parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
        source_parent_diagnostic_job_id='1582134', source_parent_source_hashes=before,
        rows_per_group=7, vectors_per_row=3, total_accumulators=21, stage_count=13,
        shared_kernel_columns_per_iteration=3, other_stage_kernel_columns_per_iteration=1,
        shared_remainder_columns_per_iteration=1, shared_remainder_max_columns=2,
        shared_paired_remainder_layer=False, formal_best_label='C6',
        source_scope='Only shared main loop factor2 to factor3; all other12 stages, original u1 remainder, dispatch, tails, fallback and other submission files unchanged.',
        source_hypothesis='Amortize shared loop/address control with three sequential complete column scopes; actual scheduling, spills, code size and speed unknown.',
        runtime_validation_status='Source prepared only; own C55 diagnostic required. Parent T PASS cannot cover the new factor3 main loop.',
        required_future_kernel_widths=[1, 2, 3, 4, 5, 6, 7, 8, 15, 81],
        historical_decisions_preserved={'S_C51_confirmation_passed': False, 'Y_C52_confirmation_passed': False},
        prepared_execution_policy='No compiler/operator/SSH/diagnostic/job/performance/ZIP/promotion/publication. New source hypothesis, not a retry of failed S or Y confirmation.')
    e.write_json(BASE / 'experiment.json', meta)
    e.checkpoint(argparse.Namespace(problem='conv', version=VERSION,
        note='Source-only shared3 from frozen T/C52. Three complete original column bodies in ik/+1/+2 order; safe kw-ik>=3, ik+=3 and unchanged u1 remainder0..2. Other12 stages/dispatch/tail/fallback/submission bytes unchanged. Await own source review and future C55 diagnostic; no correctness or speed claim.'))
    audit = dict(candidate=VERSION, parent=PARENT, parent_job_id='1582134',
        parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
        source_hashes=after, parent_source_hashes=before, changed_files=['conv2d.c'],
        unchanged_submission_files=[k for k in before if k != 'conv2d.c'],
        changed_parent_line_start=parent[:begin].count('\n') + 1,
        changed_parent_line_end=parent[:end].count('\n') + 1,
        changed_candidate_line_start=result[:begin].count('\n') + 1,
        changed_candidate_line_end=result[:begin + len(replacement)].count('\n') + 1,
        entire_prefix_and_suffix_unchanged=True, other_12_stages_unchanged=True,
        original_u1_remainder_retained_verbatim=True, shared_paired_remainder_layer=False,
        main_column_body_order=['ik', 'ik+1', 'ik+2'],
        three_column_bodies_equal_original_modulo_column_declaration=True,
        scopes_are_lexical_only=True,
        statements_per_column=dict(coefficient_broadcasts=7, input_loads=3, multiplies=21, adds=21),
        statements_per_main_iteration=dict(coefficient_broadcasts=21, input_loads=9, multiplies=63, adds=63),
        compiled=False, executed=False, diagnostic_pass=False, performance_measured=False)
    e.write_json(BASE / 'source-audit.json', audit)
    print(json.dumps(dict(candidate=VERSION, source_sha256=after['conv2d.c'],
        changed_parent_lines=[audit['changed_parent_line_start'], audit['changed_parent_line_end']],
        changed_candidate_lines=[audit['changed_candidate_line_start'], audit['changed_candidate_line_end']],
        status='prepared_source_only'), indent=2))
