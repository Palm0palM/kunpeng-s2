#!/usr/bin/env python3
"""Lightweight C28 source generation only. Never compiles or runs the operator."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PARENT = HERE.parent / 'C24-row4x4/source/conv2d.c'
TARGET = HERE / 'source/conv2d.c'
RECORD = ROOT / 'records/experiments/conv/C28-row4x6u1.json'
record = json.loads(RECORD.read_text())
if record.get('status') not in ('planned', 'prepared') or record.get('verified'):
    raise SystemExit('Refuse to regenerate a measured C28 candidate')
parent = PARENT.read_text()
start = parent.index('static void conv_sve_rowquad(')
end = parent.index('\n}\n#endif', start) + 2
original = parent[start:end]
body_start = original.index('        svfloat32_t a0 =')
header = original[:body_start]
if header.count('const int block = 4 * lanes;') != 1:
    raise SystemExit('Unexpected C24 quad block declaration')
header = header.replace('const int block = 4 * lanes;', 'const int block = 6 * lanes;')
tail = original[original.index('    if (i < ow) {'):]
lines = [header]


def emit(text=''):
    lines.append(text + '\n')


def stage(comment, input_row, outputs, middle=False):
    """outputs is an ordered list of (a/b/c/d, kernel row expression)."""
    emit('        /* ' + comment + ' */')
    emit('        for (int t = 3; t < kh; ++t) {' if middle else '        {')
    emit('            const float *row = ' + input_row + ';')
    for letter, kernel_row in outputs:
        expr = 'kernel' if kernel_row == '0' else 'kernel + (' + kernel_row + ') * kw'
        emit('            const float *k' + letter + ' = ' + expr + ';')
    emit('            for (int ik = 0; ik < kw; ++ik) {')
    for letter, _ in outputs:
        emit('                const svfloat32_t ' + letter + 'k = svdup_n_f32(k' + letter + '[ik]);')
    emit('                /* One source-level input lifetime at a time; GCC may reschedule. */')
    for vector in range(6):
        emit('                {')
        emit('                    const svfloat32_t v = svld1(pg, row + ik + ' + str(vector) + ' * lanes);')
        for letter, _ in outputs:
            acc = letter + str(vector)
            emit('                    ' + acc + ' = svadd_f32_x(pg, ' + acc + ', svmul_f32_x(pg, v, ' + letter + 'k));')
        emit('                }')
    emit('            }')
    emit('        }')


for letter in 'abcd':
    for vector in range(6):
        emit('        svfloat32_t ' + letter + str(vector) + ' = svdup_n_f32(0.0f);')
stage('Input row 0 starts output 0.', 'base + i', [('a', '0')])
stage('Input row 1 advances output 0 and starts output 1.',
      'base + stride + i', [('a', '(size_t)1'), ('b', '0')])
stage('Input row 2 advances outputs 0/1 and starts output 2.',
      'base + 2 * stride + i', [('a', '(size_t)2'), ('b', '(size_t)1'), ('c', '0')])
stage('Each middle input row advances all four outputs in strict kernel-column order.',
      'base + (size_t)t * stride + i',
      [('a', '(size_t)t'), ('b', '(size_t)(t - 1)'), ('c', '(size_t)(t - 2)'), ('d', '(size_t)(t - 3)')],
      middle=True)
stage('Input row kh finishes output 1 and advances outputs 2/3.',
      'base + (size_t)kh * stride + i',
      [('b', '(size_t)(kh - 1)'), ('c', '(size_t)(kh - 2)'), ('d', '(size_t)(kh - 3)')])
stage('Input row kh+1 finishes output 2 and advances output 3; widen before addition.',
      'base + ((size_t)kh + 1) * stride + i',
      [('c', '(size_t)(kh - 1)'), ('d', '(size_t)(kh - 2)')])
stage('Input row kh+2 finishes output 3; widen before addition.',
      'base + ((size_t)kh + 2) * stride + i', [('d', '(size_t)(kh - 1)')])
for output, letter in enumerate('abcd'):
    for vector in range(6):
        emit('        svst1(pg, dst' + str(output) + ' + i + ' + str(vector) + ' * lanes, ' + letter + str(vector) + ');')
emit('    }')
lines.append(tail)
generated = parent[:start] + ''.join(lines) + parent[end:]
current = TARGET.read_text()
if current not in (parent, generated):
    raise SystemExit('C28 has other edits; refusing to overwrite them')
TARGET.write_text(generated)
print('Generated C28 quad only: 24 accumulators, seven single-column stages, unchanged fallback/dispatch.')
