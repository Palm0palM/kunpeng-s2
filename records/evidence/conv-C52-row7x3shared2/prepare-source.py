"""One-shot C52 source preparation only. No compiler, operator, SSH or scheduler."""
from pathlib import Path
import argparse
import difflib
import hashlib
import json
import sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'tools'))
import experiment as e
BASE=Path(__file__).resolve().parent
VERSION='C52-row7x3shared2'
PARENT='C51-row7x3u1'
FROZEN=ROOT/'.runs/conv'/PARENT/'sve-correctness-sep13q'
with e.locked():
    prior=e.read_json(e.record_path('conv',VERSION))
    assert prior['status']=='planned', 'One-shot preparation only; preserve existing prepared/measured candidate'
    validation=e.read_json(FROZEN/'validation.json')
    assert validation['candidate']==PARENT and validation['job_id']=='1581822'
    assert validation['status']=='passed' and validation['complete'] is True
    parent=(FROZEN/'source/conv2d.c').read_text()
    assert hashlib.sha256(parent.encode()).hexdigest()==validation['source_hashes']['conv2d.c']
    candidate=BASE/'source/conv2d.c'
    assert candidate.read_text()==parent, 'Initial source must match actual frozen Q parent'
    before=e.source_files(BASE/'source')
    anchor=parent.index('        /* Shared input rows advance all seven outputs in strict kernel-column order. */')
    begin=parent.index('            for (int ik = 0; ik < kw; ++ik) {',anchor)
    open_brace=parent.index('{',begin)
    depth=1; cursor=open_brace+1
    while depth:
        depth += (parent[cursor]=='{')-(parent[cursor]=='}')
        cursor+=1
    end=cursor
    body=parent[open_brace+1:end-1]
    assert body.count('const svfloat32_t ') == 10
    assert body.count('svadd_f32_x(') == body.count('svmul_f32_x(') == 21
    assert body.count('svld1(') == 3
    original='            for (int ik = 0; ik < kw; ++ik) {'+body+'}'
    assert parent[begin:end]==original
    # All work for column ik precedes all work for column ik+1. Lexical scopes
    # are source intent, not a claim about target GCC scheduling/live ranges.
    column_body=body.replace('[ik]', '[column]').replace('row + ik +', 'row + column +')
    assert '[ik]' not in column_body and 'row + ik +' not in column_body
    nested='\n'.join('    '+line if line.strip() else line for line in column_body.split('\n')).rstrip(' ')
    paired=('            int ik = 0;\n'
        '            /* Preserve each accumulator order: column ik, then column ik+1. */\n'
        '            for (; kw - ik >= 2; ik += 2) {\n'
        '                {\n'
        '                    const int column = ik;'+nested+'                }\n'
        '                {\n'
        '                    const int column = ik + 1;'+nested+'                }\n'
        '            }\n'
        '            for (; ik < kw; ++ik) {'+body+'}')
    result=parent[:begin]+paired+parent[end:]
    assert result[:begin]==parent[:begin] and result[begin+len(paired):]==parent[end:]
    assert result.count('for (; kw - ik >= 2; ik += 2)')==1
    candidate.write_text(result)
    after=e.source_files(BASE/'source')
    assert {k:v for k,v in before.items() if k!='conv2d.c'}=={k:v for k,v in after.items() if k!='conv2d.c'}
    patch=''.join(difflib.unified_diff(parent.splitlines(keepends=True),result.splitlines(keepends=True),fromfile='C51-Q-frozen/source/conv2d.c',tofile=VERSION+'/source/conv2d.c'))
    (BASE/'candidate.patch').write_text(patch)
    meta=e.read_json(BASE/'experiment.json')
    meta.update(source_parent=PARENT,source_parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
        source_parent_diagnostic_job_id='1581822',source_parent_source_hashes=before,
        rows_per_group=7,vectors_per_row=3,total_accumulators=21,stage_count=13,
        shared_kernel_columns_per_iteration=2,other_stage_kernel_columns_per_iteration=1,
        shared_odd_remainder_columns_per_iteration=1,formal_best_label='C6',
        source_scope='Only the shared inner kernel-column loop changed; original other12 stages,21 output stores,all fallback/dispatch and other submission files unchanged.',
        source_hypothesis='Amortize Q shared63-instruction loop control/address cost with two sequential column bodies; target scheduling,live ranges,spills,code size and speed remain unmeasured.',
        runtime_validation_status='Not compiled or run; parent Q PASS does not imply C52 correctness or performance.',
        prepared_execution_policy='Source preparation only. No compiler,diagnostic,SSH,job,benchmark,ZIP or promotion. R1581911 remains root-owned and no result is inferred.')
    e.write_json(BASE/'experiment.json',meta)
    e.checkpoint(argparse.Namespace(problem='conv',version=VERSION,note='Source-only shared2 candidate from actual frozen Q/C51. Each accumulator processes ik then ik+1, separate lexical scopes; safe kw-ik>=2 and original-body u1 remainder. Other12 stages/dispatch/fallback/submission files unchanged. Await root independent source review; no target correctness or speed result.'))
    audit=dict(candidate=VERSION,parent=PARENT,parent_job_id='1581822',parent_frozen_directory=str(FROZEN.relative_to(ROOT)),
        source_hashes=after,parent_source_hashes=before,changed_files=['conv2d.c'],
        unchanged_submission_files=[k for k in before if k!='conv2d.c'],
        changed_parent_line_start=parent[:begin].count('\n')+1,changed_parent_line_end=parent[:end].count('\n')+1,
        changed_candidate_line_start=result[:begin].count('\n')+1,changed_candidate_line_end=result[:begin+len(paired)].count('\n')+1,
        original_one_column_body_retained_verbatim_in_remainder=True,
        paired_column_body_order=['ik','ik+1'],paired_column_scopes_are_lexical_only=True,
        statements_per_column=dict(coefficient_broadcasts=7,input_loads=3,multiplies=21,adds=21),
        compiled=False,executed=False,diagnostic_pass=False,performance_measured=False)
    e.write_json(BASE/'source-audit.json',audit)
    print(json.dumps(dict(candidate=VERSION,source_sha256=after['conv2d.c'],changed_parent_lines=[audit['changed_parent_line_start'],audit['changed_parent_line_end']],changed_candidate_lines=[audit['changed_candidate_line_start'],audit['changed_candidate_line_end']],status='prepared_source_only'),indent=2))
