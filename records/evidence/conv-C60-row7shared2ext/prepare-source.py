from pathlib import Path
import datetime,difflib,json,shutil,subprocess,sys,hashlib
ROOT=Path.cwd(); V='C60-row7shared2ext'; P='C58-r1'; D=ROOT/'.runs/conv'/V
R=ROOT/'records/experiments/conv'/f'{V}.json'
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def save(path,obj): path.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
def command(label,args):
 start=now(); p=subprocess.run(args,cwd=ROOT,capture_output=True)
 out=ROOT/'.runs/conv'/f'sep13-c60-{label}'
 save(out.with_suffix('.command.json'),dict(argv=args,cwd=str(ROOT),started_at=start,finished_at=now(),exit_code=p.returncode))
 out.with_suffix('.stdout.txt').write_bytes(p.stdout); out.with_suffix('.stderr.txt').write_bytes(p.stderr); out.with_suffix('.exit.txt').write_text(str(p.returncode)+'\n')
 sys.stdout.buffer.write(p.stdout);sys.stderr.buffer.write(p.stderr)
 if p.returncode: raise SystemExit(p.returncode)
 return out
assert not D.exists() and not R.exists()
pr=json.loads((ROOT/'records/experiments/conv'/f'{P}.json').read_text())
assert pr['status']=='passed' and pr['verified'] and pr.get('promoted_at')
assert json.loads((ROOT/'outputs/conv-best.json').read_text())['experiment']==P
parent=ROOT/'.runs/conv'/P/'source'; original=(parent/'conv2d.c').read_text()
a=original.index('            for (; kw - ik >= 2; ik += 2) {', original.index('static void conv_sve_rowseven('))
b=original.index('            for (; ik < kw; ++ik) {',a)
old=original[a:b]
assert old.count('const svfloat32_t v = svld1(pg, row + column + ')==6
head='            for (; kw - ik >= 2; ik += 2) {\n'
insert='''                /* Reuse the first-column windows; tail activates only its first float. */
                const svfloat32_t v0 = svld1(pg, row + ik + 0 * lanes);
                const svfloat32_t v1 = svld1(pg, row + ik + 1 * lanes);
                const svfloat32_t v2 = svld1(pg, row + ik + 2 * lanes);
                const svfloat32_t tail = svld1(svwhilelt_b32((uint64_t)0, (uint64_t)1),
                                               row + ik + 3 * lanes);
'''
new=old.replace(head,head+insert,1)
for n in range(3):
 line=f'const svfloat32_t v = svld1(pg, row + column + {n} * lanes);'
 new=new.replace(line,f'const svfloat32_t v = v{n};',1)
 nextv=f'v{n+1}' if n<2 else 'tail'
 new=new.replace(line,f'const svfloat32_t v = svext_f32(v{n}, {nextv}, 1);',1)
assert 'const svfloat32_t v = svld1(pg, row + column +' not in new
# Reverse precisely this local edit to prove the arithmetic and other source stayed identical.
reverse=new.replace(insert,'',1)
for n in range(3):
 line=f'const svfloat32_t v = svld1(pg, row + column + {n} * lanes);'
 reverse=reverse.replace(f'const svfloat32_t v = v{n};',line,1)
 nextv=f'v{n+1}' if n<2 else 'tail'
 reverse=reverse.replace(f'const svfloat32_t v = svext_f32(v{n}, {nextv}, 1);',line,1)
assert reverse==old
changed=original[:a]+new+original[b:]
strategy='C7/C58-r1 shared two-column rowseven loop: reuse three first-column SVE windows using EXT for column two; load only one required tail float under a one-lane predicate; preserve every separate mul/add and all other code. Hypothesis only; register pressure may regress.'
command('new',[sys.executable,'tools/experiment.py','new','conv',V,'--parent',P,'--strategy',strategy])
shutil.copy2(D/'experiment.json',D/'creation-experiment-original.json');shutil.copy2(R,D/'creation-record-original.json')
assert (D/'source/conv2d.c').read_text()==original
(D/'source/conv2d.c').write_text(changed)
meta=json.loads((D/'experiment.json').read_text());meta.update(source_parent=P,source_parent_label='C7',source_origin='C58-row7boundaryu2',own_diagnostic_passed=False,performance_measured=False,executed_locally=False,prepared_only=True)
save(D/'experiment.json',meta)
(D/'candidate.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),changed.splitlines(True),fromfile=P+'/source/conv2d.c',tofile=V+'/source/conv2d.c')))
for name in ['README.md','bench_conv.c','run.sh']: assert (parent/name).read_bytes()==(D/'source'/name).read_bytes()
assert changed.count('#pragma GCC unroll 2')==original.count('#pragma GCC unroll 2')
command('checkpoint',[sys.executable,'tools/experiment.py','checkpoint','conv',V,'--note','Prepared only: exact shared2 input-load edit and textual reversal checked; companions and all arithmetic unchanged. No compile, correctness, diagnostic or performance run. Own scheduled-node validation required.'])
for label in ['new','checkpoint']:
 for suffix in ['command.json','stdout.txt','stderr.txt','exit.txt']:
  shutil.copy2(ROOT/'.runs/conv'/f'sep13-c60-{label}.{suffix}',D/f'preparation-{label}.{suffix}')
shutil.copy2(Path(__file__),D/'prepare-source.py')
save(D/'SOURCE_AUDIT.json',dict(version=V,source_parent=P,source_parent_label='C7',prepared_at=now(),source_hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((D/'source').iterdir()) if p.is_file()},only_shared2_input_load_edit=True,local_edit_reverse_equals_parent=True,companions_byte_identical=True,arithmetic_lines_unchanged=True,boundary_pragmas_unchanged=True,own_diagnostic_passed=False,performance_measured=False,executed_locally=False))
print('Prepared '+V+'; no operator execution or SSH.')
