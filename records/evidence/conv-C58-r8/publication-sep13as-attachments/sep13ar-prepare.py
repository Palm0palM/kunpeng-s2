"""Lightweight C62 AR file preparation only; never imports/executes diagnostic tools."""
from pathlib import Path
import ast,datetime,difflib,hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
OLD=ROOT/'.runs/conv/sep13ap-checks'
BASE=ROOT/'.runs/conv/sep13ar-checks'
VERSION='C62-row7x2shared4';PREVIOUS='C61-row7shared2rowwise'
PRODUCTION=ROOT/'.runs/conv'/VERSION/'source'
SOURCE_SHA=hashlib.sha256((PRODUCTION/'conv2d.c').read_bytes()).hexdigest()
OLD_SHA='40a3184f346983864593de73b3e3ade7973b1af9d2d273d566432e882a6904fa'
assert not BASE.exists(), 'Do not overwrite a prepared template'
BASE.mkdir();B=BASE/VERSION;S=B/'source';S.mkdir(parents=True)
def write(path,text):
 with path.open('x') as f:f.write(text)
def dump(path,value):write(path,json.dumps(value,indent=2)+'\n')
def adapt(text):
 text=text.replace(PREVIOUS,VERSION).replace(OLD_SHA,SOURCE_SHA)
 text=text.replace('sep13ap','sep13ar').replace('sep13ao','sep13aq')
 # Restrict round tokens so SOURCE_NAMES, CANCELLED, OMP_DYNAMIC and SVE_LANES survive.
 text=re.sub(r'\bAP\b','AR',text);text=re.sub(r'\bAO\b','AQ',text)
 text=re.sub(r'\bC61\b','C62',text)
 text=text.replace('AO_JOB_ID','AQ_JOB_ID').replace('completed_ao_evidence','completed_aq_evidence').replace('ao_evidence','aq_evidence')
 text=text.replace('AP_SUMMARY','AR_SUMMARY').replace("'AP'+job_id", "'AR'+job_id")
 text=text.replace('1589611','1590254')
 return text
def changed(name,text,original):
 write(BASE/name,text)
 write(BASE/(name+'.from-ap.patch'),''.join(difflib.unified_diff(original.splitlines(True),text.splitlines(True),fromfile='AP/'+name,tofile='AR/'+name)))
driver_old=(OLD/'driver.py').read_text();driver=adapt(driver_old)
old="order = ['C58-r4', 'C60-row7shared2ext', 'C58-r5']"
assert old in driver
driver=driver.replace(old,"order = ['C58-r6', 'C61-row7shared2rowwise', 'C58-r7']")
assert "AQ_JOB_ID = '1590254'" in driver
assert all(x in driver for x in ['SOURCE_NAMES','PRODUCTION_NAMES','CANCELLED','CANCELED'])
ast.parse(driver);changed('driver.py',driver,driver_old)
accept_old=(OLD/'accept_and_freeze.py').read_text();accept=adapt(accept_old)
assert 'BLOCK_OUTPUTS={3*v//4}' in accept and '-DEXPECTED_ACC=3' in accept
accept=accept.replace('BLOCK_OUTPUTS={3*v//4}','BLOCK_OUTPUTS={2*v//4}').replace('-DEXPECTED_ACC=3','-DEXPECTED_ACC=2')
accept=accept.replace('actual row-wise shared2 load/broadcast schedule','actual 7-row 2VL shared4 load/broadcast schedule')
ast.parse(accept);changed('accept_and_freeze.py',accept,accept_old)
for name in ['check_conv_guard.c','check_sve_dispatch.c']:
 old=(OLD/PREVIOUS/'source'/name).read_text()
 text=old.replace('3*lanes','2*lanes').replace('6*lanes','4*lanes')
 text=text.replace('/* C54: actual four-column work,','/* C62: actual four-column work,')
 assert '3*lanes' not in text and '6*lanes' not in text
 if name=='check_conv_guard.c':
  # Enforce own two-vector contract while preserving all correctness operations.
  anchor='struct guarded {'
  text=text.replace(anchor,'#if EXPECTED_ACC != 2\n#error "C62 AR checker requires exactly two vectors per output row."\n#endif\n'+anchor,1)
  assert 'memcmp(ref, output.data, no * sizeof(float)) == 0' in text
  assert 'const int small_widths[] = {1,2*lanes-1,2*lanes+1};' in text
  assert 'one_case(2*lanes+1,larger_kernels' in text
  assert 'kh<=8' in text and 'kw=4; kw<=8' in text
 else:
  assert 'const int direct_widths[] = {2*lanes-1,2*lanes,2*lanes+1};' in text
  assert 'expected_entries' in text and 'dispatch_entries!=1236' in text and 'direct_entries!=1080' in text
 write(S/name,text)
 write(BASE/(name+'.from-ap.patch'),''.join(difflib.unified_diff(old.splitlines(True),text.splitlines(True),fromfile='AP/source/'+name,tofile='AR/source/'+name)))
for name in ['candidate.env','remote_job.sh']:
 old=(OLD/PREVIOUS/'source'/name).read_text();text=adapt(old)
 if name=='candidate.env':
  assert 'EXPECTED_ACC=3' in text;text=text.replace('EXPECTED_ACC=3','EXPECTED_ACC=2')
 else:
  assert '"$EXPECTED_ACC" == 3' in text;text=text.replace('"$EXPECTED_ACC" == 3','"$EXPECTED_ACC" == 2')
  assert 'OMP_DYNAMIC=FALSE' in text and 'EXPECTED_ACC=$EXPECTED_ACC' in text
 write(S/name,text)
 write(BASE/(name+'.from-ap.patch'),''.join(difflib.unified_diff(old.splitlines(True),text.splitlines(True),fromfile='AP/source/'+name,tofile='AR/source/'+name)))
(S/'conv2d.c').write_bytes((PRODUCTION/'conv2d.c').read_bytes())
hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in S.iterdir()}
manifest={p.name:dict(bytes=p.stat().st_size,sha256=hashes[p.name]) for p in S.iterdir()}
production_hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in PRODUCTION.iterdir()}
record=json.loads((ROOT/'records/experiments/conv'/f'{VERSION}.json').read_text())
assert record['source_hashes']==production_hashes and record['status']=='prepared' and record['verified'] is False
counts=dict(full_per_configuration=5744,dispatch_per_configuration=1212,direct_per_configuration=432,configurations=6,total=44328)
stages=['allocation','compiler','manifest','build-guard']+[f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-assembly','complete']
resources=dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
dump(B/'source-hashes.json',hashes);dump(B/'source-manifest.json',manifest)
dump(B/'prepared.json',dict(candidate=VERSION,source_experiment=VERSION,source_parent='C58-r1',source_parent_label='C7',status='prepared',complete=False,actual_job_id=None,compiled=False,executed=False,verified=False,performance_measured=False,executed_locally=False,source_hashes=hashes,production_source_hashes=production_hashes,expected_checks=counts,expected_stages=stages,prepared_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_sha256=SOURCE_SHA,resources=resources,expected_acc=2,assembly_review='Pending actual 7-row2VL/shared4 and u1 schedule, spill, frame and strict arithmetic; no performance claim',scheduling_scope='Original AQ1590254 completely recorded plus live terminal status and own AR reservation; never repeat submit',checker_count_derivation='CHECKER_COUNTS.md'))
write(BASE/'CHECKER_COUNTS.md','''# AR checker dimensions and expected entries: static derivation only

C62 jointly changes seven-row width from 3VL to 2VL and shared kernel-column unroll from two to four. These new diagnostics have not been compiled or run. The unmodified bitwise scalar reference, memcmp, read-only input/kernel, guard pages, canaries, poisoned output, worker VL/thread checks and numerical acceptance stay in place.

The six width choices are now 2L-1, 2L, 2L+1, 4L-1, 4L, 4L+1 for each L=4/8/16. All six are distinct and positive. They exercise zero/one/two full 2L tiles, exact tiles and width remainders. small widths are 1/2L-1/2L+1, larger-kernel width is 2L+1, direct-helper widths are 2L-1/2L/2L+1. Every checker width tied to the candidate tile was adapted, not only BLOCK_OUTPUTS.

Per configuration, full core=6 widths*3 kh(6..8)*3 kw(1..3)*18 heights*2 pads*2 guard orientations=3888. narrow=3*3*4*2*2=144. small=3 widths*5 kh(1..5)*3 kw*4 heights*2*2=720. larger=4 kernel pairs*2 heights*2*2=32. quad boundary=6 widths*2 kh(7..8)*5 kw(4..8)*4 heights(7,8,14,28)*2*2=960. Total=5744. kw4..8 covers one quad plus zero/one/two/three residual columns and two full quads. The last group has exact and partial width tiles and t transitions; larger kernels retain kh/kw81.

Dispatch cases have no pad/orientation repetition: core=6*3*3*18=972; quad=6*2*5*4=240; total1212. Production dispatch into rowseven depends on kh>=7 and oh>=7, not output width. Sum floor(h/7) over h=1..15,21,22,28 is21. Therefore core rowseven entries=6 widths*2 kh*3 kw*21=756. Quad heights sum1+1+2+4=8; quad entries=6*2*5*8=480. Total1236. Each case still checks its own expected delta, and the aggregate1236 is not substituted from observed output. Widths below2L still enter rowseven and then take width fallback.

Direct kh<7 cases=3 widths*6 kh(1..6)*3 kw*2 heights(7,28)*2 pads*2 orientations=432. Every call explicitly enters rowseven regardless of tile width. Expected entry sum=3*6*3*(1+4)*2*2=1080. Both dispatch and direct sets include oh28 with four independent static groups, requiring worker mask1 at one thread and15 at four threads. This remains a runtime check.

Six VL/thread configurations yield (5744+1212+432)*6=44328. Wrapper retains19 ordered stages and strict GCC10.3.1/generic/FP-contract-off, resources38CPU/24576MiB/one packed NUMA/1800s.

Legacy PREFIX/TAIL/ROWPAIR/ROWTRIPLE/ROWQUAD counts can change because widths now cross the unchanged 4L fallback tiles. AR keeps the exercised checker requirement that each is nonzero; exact per-case rowseven deltas and1236/1080 remain mandatory. Do not copy AP summary expectations10850/10850/234/2746/1778 into a future AR summarizer. Report original observed legacy counts separately, with nonzero coverage; never set expected counts from actual output. No AR job, runtime count or acceptance exists at preparation time.
''')
write(BASE/'README.md','''# AR C62 prepared diagnostic

Own unexecuted diagnostic for C62-row7x2shared4, parent C58-r1=currentC7. Joint tile hypothesis: seven rows*two SVE vectors and four shared kernel columns; no measured spill reduction, correctness or speed claim. Source width2L and checker EXPECTED_ACC2 are consistent. Read CHECKER_COUNTS.md for the independent cardinality and per-case dispatch-entry reasoning; checkers retain44328 expected bitwise cases and19 stages while adapting every relevant width to2L/4L boundaries.

The driver requires original AQ job1590254 campaign complete with order C58-r6/C61-row7shared2rowwise/C58-r7 and36 samples, plus its live terminal status; AR's own reservation is also checked. Preparation does not query AQ and does not mean it is complete. No submit/gate/status/fetch has been executed, and no AR job.json exists. Root must review checker diffs and actual code before the explicit one-shot --go. Acceptance later requires real AR_SUMMARY, exact original logs, a targeted actual shared4/u1 assembly review and root review. Do not inherit AP acceptance, assembly counts or fixed legacy fallback counts.

Unchanged resource envelope:38CPU,24576MiB,one packed NUMA,1800 seconds; GCC10.3.1 strict/generic,VL16/32/64 bytes x1/4 threads. All operator compilation and execution must occur only on scheduled supercomputer compute nodes. No local operator execution, reset card, automatic promotion or packaging. User explicitly revoked40% quota threshold; historical stop records remain historical.
''')
write(BASE/'ROOT_REVIEW.md','''# AR root review pending

Template preparation only. Root has not yet reviewed this new AR template in this file. It must review actual C62 source, both checker diffs, CHECKER_COUNTS.md, driver serial gate and acceptor before deciding whether to execute one explicit submission. No runtime validation or performance is claimed.
''')
write(BASE/'INDEPENDENT_TOOLS_REVIEW.md','''# AR preparation review scope

The lifecycle agent adapted exercised AP transport and acceptance with exact candidate/SHA and bounded round-token replacements. This file is not a claim that another independent reviewer has approved the new checker dimensions. The agent re-derived unchanged family cardinalities and rowseven entry totals in CHECKER_COUNTS.md. Actual C62 operator/checkers/driver have not been executed or imported. Root or another reviewer must independently read source and transport diffs before GO; actual returned numerical and assembly evidence is still absent.
''')
assert set(hashes)=={'conv2d.c','candidate.env','remote_job.sh','check_conv_guard.c','check_sve_dispatch.c'}
assert not (B/'job.json').exists() and not (B/'AR_SUMMARY.json').exists()
print('Prepared AR text and five-file source package; no driver import/execution, network or operator test.')
print('C62 source SHA256 '+SOURCE_SHA)
