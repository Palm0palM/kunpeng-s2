"""One-time source preparation from frozen C40; no operator execution/network.

Owns only C51 source/conv2d.c, its patch and preparation metadata. Requires the
new experiment to exist with an unchanged parent snapshot; never overwrites a
prepared or measured candidate. All writes occur under the experiment lock.
"""
from pathlib import Path
from types import SimpleNamespace
import difflib
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools'))
import experiment as e

NAME = 'C51-row7x3u1'
D = ROOT / '.runs/conv' / NAME
PARENT = ROOT / '.runs/conv/C40-row6x3u1'
FROZEN = PARENT / 'sve-correctness-sep12g'
parent = (FROZEN / 'raw/conv2d.c').read_text()
start = parent.index('#if CONV_CAN_DISPATCH_SVE\n/* Six outputs share')
end = parent.index('\nvoid conv2d(', start)
letters = 'abcdefg'
lines = [
    '#if CONV_CAN_DISPATCH_SVE',
    '/* Seven outputs share input row t; output r consumes kernel row t-r.',
    ' * Each output retains the original kernel-row/column order and separate mul/add. */',
    '__attribute__((target("arch=armv8-a+sve"), noinline))',
    'static void conv_sve_rowseven(const float *restrict base, size_t stride,',
    '                                const float *restrict kernel, int kh, int kw,',
    '                                float *restrict dst0, float *restrict dst1,',
    '                                float *restrict dst2, float *restrict dst3,',
    '                                float *restrict dst4, float *restrict dst5,',
    '                                float *restrict dst6, int ow)',
    '{',
    '    if (kh < 7) {',
    '        conv_sve_rowquad(base, stride, kernel, kh, kw, dst0, dst1, dst2, dst3, ow);',
    '        conv_sve_rowtriple(base + (size_t)4 * stride, stride, kernel, kh, kw,',
    '                           dst4, dst5, dst6, ow);',
    '        return;',
    '    }',
    '    const int lanes = (int)svcntw();',
    '    const int block = 3 * lanes;',
    '    const svbool_t pg = svptrue_b32();',
    '    int i = 0;',
    '    for (; ow - i >= block; i += block) {'
]
for letter in letters:
    for vector in range(3):
        lines.append(f'        svfloat32_t {letter}{vector} = svdup_n_f32(0.0f);')


def stage(comment, opening, row_expression, active, kernel_rows):
    lines.extend(['        /* ' + comment + ' */', '        ' + opening,
                  '            const float *row = ' + row_expression + ';'])
    for row, kernel_row in zip(active, kernel_rows):
        expression = ('kernel' if kernel_row == '0' else
                      'kernel + (' + kernel_row + ') * (size_t)kw')
        lines.append(f'            const float *k{letters[row]} = {expression};')
    lines.append('            for (int ik = 0; ik < kw; ++ik) {')
    for row in active:
        letter = letters[row]
        lines.append(f'                const svfloat32_t {letter}k = svdup_n_f32(k{letter}[ik]);')
    lines.append('                /* One source-level input window; GCC may reschedule. */')
    for vector in range(3):
        lines.extend(['                {',
                      f'                    const svfloat32_t v = svld1(pg, row + ik + {vector} * lanes);'])
        for row in active:
            letter = letters[row]
            lines.append(f'                    {letter}{vector} = svadd_f32_x(pg, {letter}{vector}, svmul_f32_x(pg, v, {letter}k));')
        lines.append('                }')
    lines.extend(['            }', '        }'])


for t in range(6):
    stage(f'Input row {t}: start output {t} and advance earlier outputs.', '{',
          'base + i' if t == 0 else f'base + (size_t){t} * stride + i',
          list(range(t + 1)),
          ['0' if t - row == 0 else f'(size_t){t - row}' for row in range(t + 1)])
stage('Shared input rows advance all seven outputs in strict kernel-column order.',
      'for (int t = 6; t < kh; ++t) {', 'base + (size_t)t * stride + i',
      list(range(7)),
      ['(size_t)t' if row == 0 else f'(size_t)t - {row}' for row in range(7)])
for q in range(6):
    active = list(range(q + 1, 7))
    stage(f'Trailing input row kh+{q}: finish output {q + 1} and advance later outputs.', '{',
          'base + (size_t)kh * stride + i' if q == 0 else f'base + ((size_t)kh + {q}) * stride + i',
          active, [f'(size_t)kh - {row - q}' for row in active])
for row, letter in enumerate(letters):
    for vector in range(3):
        lines.append(f'        svst1(pg, dst{row} + i + {vector} * lanes, {letter}{vector});')
lines.extend([
    '    }',
    '    if (i < ow) {',
    '        conv_sve_rowquad(base + i, stride, kernel, kh, kw,',
    '                         dst0 + i, dst1 + i, dst2 + i, dst3 + i, ow - i);',
    '        conv_sve_rowtriple(base + (size_t)4 * stride + i, stride, kernel, kh, kw,',
    '                           dst4 + i, dst5 + i, dst6 + i, ow - i);',
    '    }',
    '}',
    '#endif',
    ''
])
new_helper = '\n'.join(lines)
dispatch_start = parent.index('    if (use_sve && kernelHeight >= 6 && oh >= 6) {')
dispatch_end = parent.index('    if (use_sve) {', dispatch_start)
old_dispatch = parent[dispatch_start:dispatch_end]
new_dispatch = (old_dispatch
    .replace('kernelHeight >= 6 && oh >= 6', 'kernelHeight >= 7 && oh >= 7')
    .replace('output_rows / 6 + (output_rows % 6 != 0)', 'output_rows / 7 + (output_rows % 7 != 0)')
    .replace('first_row = group * 6', 'first_row = group * 7'))
branch_start = new_dispatch.index('            if (remaining >= 6) {')
branch_end = new_dispatch.index('            } else if (remaining == 5) {', branch_start)
new_dispatch = new_dispatch[:branch_start] + '''            if (remaining >= 7) {
                conv_sve_rowseven(base, stride, kernel, kernelHeight, kernelWidth,
                                  dst, dst + output_stride, dst + 2 * output_stride,
                                  dst + 3 * output_stride, dst + 4 * output_stride,
                                  dst + 5 * output_stride, dst + 6 * output_stride, ow);
            } else if (remaining == 6) {
                conv_sve_rowquad(base, stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + output_stride, dst + 2 * output_stride,
                                 dst + 3 * output_stride, ow);
                conv_sve_rowpair(base + (size_t)4 * stride, stride, kernel,
                                 kernelHeight, kernelWidth, dst + 4 * output_stride,
                                 dst + 5 * output_stride, ow);
''' + new_dispatch[branch_end:]
source = (parent[:start] + new_helper + parent[end:dispatch_start] +
          new_dispatch + parent[dispatch_end:])

with e.locked():
    validation = e.read_json(FROZEN / 'validation.json')
    assert validation['status'] == 'passed' and validation['complete'] is True
    assert validation['job_id'] == '1579597'
    assert e.digest(FROZEN / 'raw/conv2d.c') == validation['source_hashes']['conv2d.c']
    assert (PARENT / 'source/conv2d.c').read_text() == parent
    assert e.get_record('conv', NAME)['status'] == 'planned'
    assert (D / 'source/conv2d.c').read_text() == parent
    assert not (D / 'cluster.json').exists() and not (D / 'candidate.patch').exists()
    (D / 'source/conv2d.c').write_text(source)
    (D / 'candidate.patch').write_text(''.join(difflib.unified_diff(
        parent.splitlines(True), source.splitlines(True),
        fromfile='C40-row6x3u1/source/conv2d.c', tofile=NAME + '/source/conv2d.c')))
    metadata = e.read_json(D / 'experiment.json')
    metadata.update(
        source_parent='C40-row6x3u1', rows_per_group=7, vectors_per_row=3,
        total_accumulators=21, kernel_columns_per_iteration=1, stage_count=13,
        formal_best_label='C6', reference_only=False,
        source_parent_frozen_directory='.runs/conv/C40-row6x3u1/sve-correctness-sep12g',
        source_parent_diagnostic_job_id='1579597',
        source_hypothesis='Change only the specialized6x3VL output group to7x3VL; shared source-level input loads per output decrease while coefficient broadcasts per output remain equal to C40, with21 rather than18 live accumulators. Actual scheduling, spills and performance are unmeasured.',
        source_scope='Specialized helper and initial row-group dispatch only; original four/three/two/one-row helpers, fallback dispatcher, nonSVE and submission files preserved.',
        parent_measurement_context='N same-group medians: C40-r3 reference444.44ms, C47 450.63ms, C48 448.13ms. C40 is reference-only and not promoted; original Gfalse/Jtrue/Kfalse preserved; formal best C6.',
        prepared_execution_policy='Preparation only. No compilation, operator tests, diagnostics, benchmark, SSH, job, reset, ZIP or promotion. Stop for root independent review.')
    e.write_json(D / 'experiment.json', metadata)
    e.checkpoint(SimpleNamespace(problem='conv', version=NAME,
        note='Prepared from frozen C40 as7rows x3VL/21acc/13stages, separate per-column mul/add. Only specialized helper and its initial dispatcher changed. Source-only; no local or remote operator execution, diagnostic or performance claim. Root independent review pending.'))
print(D / 'source/conv2d.c')
