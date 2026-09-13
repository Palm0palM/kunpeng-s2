"""Prepare only C61 row-wise weight lifetime; no compilation or remote work."""
from pathlib import Path
import subprocess,sys,json,difflib,datetime,re
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'));sys.dont_write_bytecode=True
import experiment as e
VERSION='C61-row7shared2rowwise';PARENT='C58-r1';run=ROOT/'.runs/conv'/VERSION
assert not run.exists() and not e.record_path('conv',VERSION).exists()
assert e.read_json(ROOT/'outputs/conv-best.json')['label']=='C7' and e.read_json(ROOT/'records/best.json')['conv']==PARENT
parent=ROOT/'.runs/conv'/PARENT/'source';s=(parent/'conv2d.c').read_text()
start=s.index('            for (; kw - ik >= 2; ik += 2) {',s.index('static void conv_sve_rowseven('))
end=s.index('            for (; ik < kw; ++ik) {',start);old=s[start:end]
lines=['            for (; kw - ik >= 2; ik += 2) {']
for column in ['ik','ik + 1']:
 lines+=['                {',f'                    const int column = {column};']
 for n in range(3):lines.append(f'                    const svfloat32_t v{n} = svld1(pg, row + column + {n} * lanes);')
 for row in 'abcdefg':
  lines+=['                    {',f'                        const svfloat32_t weight = svdup_n_f32(k{row}[column]);']
  for n in range(3):lines.append(f'                        {row}{n} = svadd_f32_x(pg, {row}{n}, svmul_f32_x(pg, v{n}, weight));')
  lines.append('                    }')
 lines.append('                }')
lines.append('            }');new='\n'.join(lines)+'\n';candidate=s[:start]+new+s[end:]
assert old.count('svmul_f32_x(')==new.count('svmul_f32_x(')==42
assert old.count('svadd_f32_x(')==new.count('svadd_f32_x(')==42
assert old.count('svld1(')==new.count('svld1(')==6
assert old.count('svdup_n_f32(')==new.count('svdup_n_f32(')==14
assert candidate.count('#pragma GCC unroll 2')==s.count('#pragma GCC unroll 2')
for row in 'abcdefg':
 for n in range(3):assert len(re.findall(rf'\b{row}{n} =',new))==len(re.findall(rf'\b{row}{n} =',old))==2
strategy='Within each shared pair column, load three original input vectors then update each output row across all three vectors using one scoped coefficient broadcast. Shorten source-level coefficient lifetimes; preserve per-output arithmetic order,6 direct loads,14 broadcasts,all boundary hints,remainder and runner. No EXT, prefetch or fast math.'
def command(label,argv):
 prefix=ROOT/'.runs/conv'/('sep13-c61-'+label);info=dict(argv=argv,started_at=datetime.datetime.now(datetime.timezone.utc).isoformat())
 with prefix.with_suffix('.command.json').open('x') as f:json.dump(info,f,indent=2)
 r=subprocess.run(argv,cwd=ROOT,capture_output=True,text=True);prefix.with_suffix('.stdout.txt').write_text(r.stdout);prefix.with_suffix('.stderr.txt').write_text(r.stderr);prefix.with_suffix('.exit.txt').write_text(str(r.returncode)+'\n');assert r.returncode==0,(label,r.stderr)
command('new',[sys.executable,'tools/experiment.py','new','conv',VERSION,'--parent',PARENT,'--strategy',strategy])
(run/'creation-experiment-original.json').write_bytes((run/'experiment.json').read_bytes())
(run/'creation-record-original.json').write_bytes(e.record_path('conv',VERSION).read_bytes())
(run/'source/conv2d.c').write_text(candidate)
for name in ['README.md','bench_conv.c','run.sh']:assert (run/'source'/name).read_bytes()==(parent/name).read_bytes()
(run/'candidate.patch').write_text(''.join(difflib.unified_diff(s.splitlines(True),candidate.splitlines(True),fromfile=PARENT+'/conv2d.c',tofile=VERSION+'/conv2d.c')))
(run/'STRATEGY.md').write_text('# C61 row-wise coefficient lifetime\n\n'+strategy+'\n\nHypothesis: three vector inputs plus one current coefficient may give GCC a better schedule than seven simultaneously scoped coefficients. GCC may already reorder similarly; no improvement is assumed. C59 and C60 regressions are retained; this candidate starts from measured C7, not either rejected source.\n')
(run/'STATIC_REVIEW.md').write_text('''# Static scope and semantics

Only shared-pair body changes. For each of two columns, the same three full input windows and same seven coefficients are loaded. Each of21 accumulator chains still receives columnik thenik+1, each as separate multiplication followed by addition. The change reorders independent outputs/lanes within one column; it does not reassociate a sum. No additional address or tail access exists. The seven output pointers come from separate output rows in the existing helper; local accumulator variables are independent. Shared row order,12boundaryhints,odd remainder,dispatch and all three companion files are unchanged. The text count checks42multiply/add,6loads,14broadcasts andtwo updates perchain; these are static checks, not hardware correctness or performance evidence. Own remote diagnostic and controlled performance remain required.
''')
command('checkpoint',[sys.executable,'tools/experiment.py','checkpoint','conv',VERSION,'--note','Prepared row-wise coefficient lifetime only; no compilation/diagnostic/performance executed, no promotion or ZIP.'])
(run/'prepare-source.py').write_bytes(Path(__file__).read_bytes())
print(VERSION,'prepared only; C7 unchanged; no operator compiled or run')
