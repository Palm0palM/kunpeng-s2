"""One-time lightweight source generator; no compiler, tests, jobs or network.

Only rewrites this new C48 candidate's conv2d.c and metadata under experiment lock.
Parent bytes outside its specialized helper and initial specialized dispatch are retained.
"""
from pathlib import Path
from types import SimpleNamespace
import difflib
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools'))
import experiment as e
D = ROOT / '.runs/conv/C48-row8x2u1'
P = ROOT / '.runs/conv/C40-row6x3u1/source/conv2d.c'
parent = P.read_text()
start = parent.index('#if CONV_CAN_DISPATCH_SVE\n/* Six outputs share')
end = parent.index('\nvoid conv2d(', start)
oldhelper = parent[start:end]
letters = 'abcdefgh'
lines = [
 '#if CONV_CAN_DISPATCH_SVE',
 '/* Eight outputs share input row t; output r consumes kernel row t-r.',
 ' * Each output retains the original kernel-row/column order and separate mul/add. */',
 '__attribute__((target("arch=armv8-a+sve"), noinline))',
 'static void conv_sve_roweight(const float *restrict base, size_t stride,',
 '                               const float *restrict kernel, int kh, int kw,',
 '                               float *restrict dst0, float *restrict dst1,',
 '                               float *restrict dst2, float *restrict dst3,',
 '                               float *restrict dst4, float *restrict dst5,',
 '                               float *restrict dst6, float *restrict dst7, int ow)',
 '{',
 '    if (kh < 8) {',
 '        conv_sve_rowquad(base, stride, kernel, kh, kw, dst0, dst1, dst2, dst3, ow);',
 '        conv_sve_rowquad(base + (size_t)4 * stride, stride, kernel, kh, kw,',
 '                         dst4, dst5, dst6, dst7, ow);',
 '        return;',
 '    }',
 '    const int lanes = (int)svcntw();',
 '    const int block = 2 * lanes;',
 '    const svbool_t pg = svptrue_b32();',
 '    int i = 0;',
 '    for (; ow - i >= block; i += block) {'
]
for r in letters:
 for n in range(2): lines.append(f'        svfloat32_t {r}{n} = svdup_n_f32(0.0f);')

def stage(comment, opening, rowexpr, active, krows):
 lines.extend(['        /* '+comment+' */', '        '+opening, '            const float *row = '+rowexpr+';'])
 for r,k in zip(active,krows):
  expr='kernel' if k=='0' else 'kernel + ('+k+') * (size_t)kw'
  kp = 'krow_h' if r == 7 else 'k' + letters[r]
  lines.append(f'            const float *{kp} = {expr};')
 lines.append('            for (int ik = 0; ik < kw; ++ik) {')
 for r in active:
  kp = 'krow_h' if r == 7 else 'k' + letters[r]
  lines.append(f'                const svfloat32_t {letters[r]}k = svdup_n_f32({kp}[ik]);')
 lines.append('                /* One source-level input window; GCC may reschedule. */')
 for n in range(2):
  lines.extend(['                {',f'                    const svfloat32_t v = svld1(pg, row + ik + {n} * lanes);'])
  for r in active:
   z=letters[r]
   lines.append(f'                    {z}{n} = svadd_f32_x(pg, {z}{n}, svmul_f32_x(pg, v, {z}k));')
  lines.append('                }')
 lines.extend(['            }','        }'])
for t in range(7):
 stage(f'Input row {t}: start output {t} and advance earlier outputs.', '{',
       'base + i' if t==0 else f'base + (size_t){t} * stride + i',
       list(range(t+1)), ['0' if t-r==0 else f'(size_t){t-r}' for r in range(t+1)])
stage('Shared input rows advance all eight outputs in strict kernel-column order.',
      'for (int t = 7; t < kh; ++t) {', 'base + (size_t)t * stride + i',
      list(range(8)), ['(size_t)t' if r==0 else f'(size_t)t - {r}' for r in range(8)])
for q in range(7):
 active=list(range(q+1,8))
 stage(f'Trailing input row kh+{q}: finish output {q+1} and advance later outputs.', '{',
       'base + (size_t)kh * stride + i' if q==0 else f'base + ((size_t)kh + {q}) * stride + i',
       active, [f'(size_t)kh - {r-q}' for r in active])
for r,z in enumerate(letters):
 for n in range(2): lines.append(f'        svst1(pg, dst{r} + i + {n} * lanes, {z}{n});')
lines.extend([
 '    }',
 '    if (i < ow) {',
 '        conv_sve_rowquad(base + i, stride, kernel, kh, kw,',
 '                         dst0 + i, dst1 + i, dst2 + i, dst3 + i, ow - i);',
 '        conv_sve_rowquad(base + (size_t)4 * stride + i, stride, kernel, kh, kw,',
 '                         dst4 + i, dst5 + i, dst6 + i, dst7 + i, ow - i);',
 '    }',
 '}',
 '#endif',
 ''
])
newhelper='\n'.join(lines)
ds=parent.index('    if (use_sve && kernelHeight >= 6 && oh >= 6) {')
de=parent.index('    if (use_sve) {',ds)
olddispatch=parent[ds:de]
newdispatch=olddispatch.replace('kernelHeight >= 6 && oh >= 6','kernelHeight >= 8 && oh >= 8').replace('output_rows / 6 + (output_rows % 6 != 0)','output_rows / 8 + (output_rows % 8 != 0)').replace('first_row = group * 6','first_row = group * 8')
a=newdispatch.index('            if (remaining >= 6) {')
b=newdispatch.index('            } else if (remaining == 5) {',a)
newdispatch=newdispatch[:a]+'''            if (remaining >= 8) {
                conv_sve_roweight(base, stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + output_stride, dst + 2 * output_stride,
                                 dst + 3 * output_stride, dst + 4 * output_stride,
                                 dst + 5 * output_stride, dst + 6 * output_stride,
                                 dst + 7 * output_stride, ow);
            } else if (remaining == 7) {
                conv_sve_rowquad(base, stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + output_stride, dst + 2 * output_stride,
                                 dst + 3 * output_stride, ow);
                conv_sve_rowtriple(base + (size_t)4 * stride, stride, kernel,
                                   kernelHeight, kernelWidth, dst + 4 * output_stride,
                                   dst + 5 * output_stride, dst + 6 * output_stride, ow);
            } else if (remaining == 6) {
                conv_sve_rowquad(base, stride, kernel, kernelHeight, kernelWidth,
                                 dst, dst + output_stride, dst + 2 * output_stride,
                                 dst + 3 * output_stride, ow);
                conv_sve_rowpair(base + (size_t)4 * stride, stride, kernel,
                                 kernelHeight, kernelWidth, dst + 4 * output_stride,
                                 dst + 5 * output_stride, ow);
'''+newdispatch[b:]
source=parent[:start]+newhelper+parent[end:ds]+newdispatch+parent[de:]
with e.locked():
 current=(D/'source/conv2d.c').read_text()
 if current != parent:
  raise SystemExit('Refuse to overwrite a candidate that differs from its original C40 parent')
 (D/'source/conv2d.c').write_text(source)
 (D/'candidate.patch').write_text(''.join(difflib.unified_diff(parent.splitlines(True),source.splitlines(True),fromfile='C40-row6x3u1/source/conv2d.c',tofile='C48-row8x2u1/source/conv2d.c')))
 meta=e.read_json(D/'experiment.json')
 meta.update(source_parent='C40-row6x3u1',rows_per_group=8,vectors_per_row=2,total_accumulators=16,kernel_columns_per_iteration=1,stage_count=15,formal_best_label='C6',reference_only=False,
   source_hypothesis='Replace the specialized 6x3VL tile by8x2VL; source-level lower input loads/output trades for50% more coefficient broadcasts/output; no measured claim',
   source_scope='Specialized helper and initial row-group dispatch only; all C6 helpers/legacy dispatch/nonSVE and other submission files preserved',
   parent_measurement_context='C40 G failed noise gates; J independent repeat qualified; K confirmation failed own C-case spread gate. C40 is not promoted; C6 remains formal.',
   prepared_execution_policy='Source only. No diagnostic package, local compile/tests, SSH, job, reset, or publication. Root independent review required.')
 e.write_json(D/'experiment.json',meta)
print(D/'source/conv2d.c')
