"""One-shot C53 text/source preparation; no compiler, operator, SSH or job."""
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
VERSION = 'C53-row7cursors'
PARENT = 'C51-row7x3u1'
PARENT_SHA = '5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff'
FROZEN = ROOT / '.runs/conv' / PARENT / 'sve-correctness-sep13q'


def main():
    with e.locked():
        prior = e.get_record('conv', VERSION)
        assert prior['status'] == 'planned', 'One-shot only; never overwrite a prepared or measured candidate'
        validation = e.read_json(FROZEN / 'validation.json')
        assert validation['candidate'] == PARENT and validation['job_id'] == '1581822'
        assert validation['status'] == 'passed' and validation['complete'] is True
        assert validation['source_hashes']['conv2d.c'] == PARENT_SHA
        parent_bytes = (FROZEN / 'source/conv2d.c').read_bytes()
        assert hashlib.sha256(parent_bytes).hexdigest() == PARENT_SHA
        candidate = BASE / 'source/conv2d.c'
        assert candidate.read_bytes() == parent_bytes, 'Initial source must equal the actual frozen Q source'
        before = e.source_files(BASE / 'source')
        assert before == prior['source_hashes'] == e.get_record('conv', PARENT)['source_hashes']
        assert set(before) == {'README.md', 'bench_conv.c', 'conv2d.c', 'run.sh'}
        parent = parent_bytes.decode('utf-8')
        marker = '        /* Shared input rows advance all seven outputs in strict kernel-column order. */\n'
        trailing = '        /* Trailing input row kh+0: finish output 1 and advance later outputs. */'
        assert parent.count(marker) == parent.count(trailing) == 1
        begin = parent.index(marker)
        end = parent.index(trailing, begin)
        original = parent[begin:end]
        loop = original[len(marker):]
        assert loop.startswith('        for (int t = 6; t < kh; ++t) {\n')
        pointers = 'abcdefg'
        for r, letter in enumerate(pointers):
            row = '((size_t)t)' if r == 0 else f'((size_t)t - {r})'
            declaration = f'            const float *k{letter} = kernel + {row} * (size_t)kw;\n'
            assert loop.count(declaration) == 1
            loop = loop.replace(declaration, '', 1)
            old = f'svdup_n_f32(k{letter}[ik])'
            new = f'svdup_n_f32(*k{letter}++)'
            assert loop.count(old) == 1
            loop = loop.replace(old, new, 1)
        # One shared-only scope keeps the cursors private and resets them on
        # every enclosing output-column tile. Arithmetic is only reindented.
        declarations = ''
        for r, letter in enumerate(pointers):
            rhs = f'kernel + (size_t){6-r} * (size_t)kw' if r != 6 else 'kernel'
            declarations += f'            const float *k{letter} = {rhs};\n'
        shifted_loop = ''.join('    ' + line if line.strip() else line for line in loop.splitlines(keepends=True))
        replacement = marker + '        {\n' + declarations + shifted_loop + '        }\n'
        result = parent[:begin] + replacement + parent[end:]
        assert result[:begin] == parent[:begin] and result[begin+len(replacement):] == parent[end:]
        original_ops = [line.lstrip() for line in original.splitlines() if 'svld1(' in line or '= svadd_f32_x(' in line]
        result_ops = [line.lstrip() for line in replacement.splitlines() if 'svld1(' in line or '= svadd_f32_x(' in line]
        assert result_ops == original_ops and len(result_ops) == 24
        assert replacement.count('svld1(') == 3
        assert replacement.count('svadd_f32_x(') == replacement.count('svmul_f32_x(') == 21
        assert replacement.count('svdup_n_f32(') == 7
        assert replacement.count('for (int ik = 0; ik < kw; ++ik)') == 1
        assert all(replacement.count(f'svdup_n_f32(*k{letter}++)') == 1 for letter in pointers)
        assert all(f'k{letter}[ik]' not in replacement for letter in pointers)
        candidate.write_bytes(result.encode('utf-8'))
        after = e.source_files(BASE / 'source')
        assert {k:v for k,v in before.items() if k != 'conv2d.c'} == {k:v for k,v in after.items() if k != 'conv2d.c'}
        patch = ''.join(difflib.unified_diff(parent.splitlines(keepends=True), result.splitlines(keepends=True),
            fromfile='C51-Q-frozen/source/conv2d.c', tofile=VERSION+'/source/conv2d.c'))
        (BASE / 'candidate.patch').write_text(patch)
        meta = e.read_json(BASE / 'experiment.json')
        assert meta['source_hashes'] == before, 'Preserve the standard creation-time snapshot'
        meta.update(source_parent=PARENT, source_parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
            source_parent_diagnostic_job_id='1581822', source_parent_source_hashes=before,
            rows_per_group=7, vectors_per_row=3, total_accumulators=21, stage_count=13,
            kernel_columns_per_iteration=1, formal_best_label='C6',
            source_scope='Only shared coefficient address induction changed: seven per-tile cursors replace row-base plus ik and advance across t. Other12 stages,input indices,21 updates,stores,all fallback/dispatch and other submission files are unchanged.',
            source_hypothesis='Observe whether seven continuous coefficient cursors remove the actual Q shared standalone LSL and outer coefficient row steps, or instead canonicalize/increase address or scalar-stack work. No codegen or speed conclusion.',
            runtime_validation_status='Source preparation only; parent Q and R/S do not validate C53. No compilation, diagnostics or performance.',
            prepared_execution_policy='Stop for root independent source review. No diagnostic directory/tools,compiler,operator,benchmark,SSH,job,ZIP,promotion or publication.')
        e.write_json(BASE / 'experiment.json', meta)
        e.checkpoint(argparse.Namespace(problem='conv', version=VERSION,
            note='Prepared C53 from actual frozen Q/C51 source. Seven coefficient cursors reset per output tile, progress once per ik across shared t, final ka may be one-past but is not read. Original input indexing and21 ordered updates unchanged; other12 stages/stores/dispatch/fallback/runner preserved. Await root review; no inherited PASS or compute GO.'))
        prepared = e.get_record('conv', VERSION)
        assert prepared['source_hashes'] == after and prepared['status'] == 'prepared' and prepared['verified'] is False
        assert e.read_json(BASE / 'experiment.json')['source_hashes'] == before
        audit = dict(candidate=VERSION, parent=PARENT, parent_job_id='1581822',
            parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
            source_hashes=after, parent_source_hashes=before, creation_source_hashes=before,
            creation_metadata_hashes_preserved=True, prepared_record_matches_current_source=True,
            changed_files=['conv2d.c'], unchanged_submission_files=['README.md','bench_conv.c','run.sh'],
            changed_parent_line_start=parent[:begin].count('\n')+1,
            changed_parent_line_end=parent[:end].count('\n'),
            changed_candidate_line_start=result[:begin].count('\n')+1,
            changed_candidate_line_end=result[:begin+len(replacement)].count('\n'),
            before_shared_bytes_unchanged=True, after_shared_bytes_unchanged=True,
            original_input_and_arithmetic_lines_identical_except_scope_indent=True,
            original_ik_loop_unchanged=True, shared_scope_resets_each_output_tile=True,
            cursor_initial_kernel_rows=[6,5,4,3,2,1,0], cursor_step_elements=1,
            cursor_address_invariant='At output row r, shared(t,ik): kernel+(6-r)*kw+(t-6)*kw+ik == kernel+(t-r)*kw+ik',
            statements_per_column=dict(coefficient_broadcasts=7,input_loads=3,multiplies=21,adds=21),
            compiled=False, executed=False, diagnostic_pass=False, performance_measured=False)
        e.write_json(BASE / 'source-audit.json', audit)
        print(json.dumps(dict(candidate=VERSION, source_sha256=after['conv2d.c'],
            changed_parent_lines=[audit['changed_parent_line_start'],audit['changed_parent_line_end']],
            changed_candidate_lines=[audit['changed_candidate_line_start'],audit['changed_candidate_line_end']],
            status='prepared_source_only'), indent=2))


if __name__ == '__main__':
    main()
