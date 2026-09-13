"""Prepare C64 AV diagnostic text only from executed AP three-vector checks."""
from pathlib import Path
import ast,datetime,difflib,hashlib,json,re,shutil
R=Path(__file__).resolve().parents[2]
A=R/'.runs/conv/sep13ap-checks';B=R/'.runs/conv/sep13av-checks'
OLD='C61-row7shared2rowwise';V='C64-row7boundaryrowwise';D=B/V
OLDSHA='40a3184f346983864593de73b3e3ade7973b1af9d2d273d566432e882a6904fa'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,text):
 with p.open('x') as f:f.write(text)
def dump(p,data):write(p,json.dumps(data,indent=2)+'\n')
# Validate the real standard candidate before creating any AV files.
record=read(R/'records/experiments/conv'/f'{V}.json')
production=R/'.runs/conv'/V/'source'
assert record['status']=='prepared' and record['verified'] is False
assert record.get('source_parent',record.get('parent'))=='C58-r1'
assert set(record['source_hashes'])=={'conv2d.c','bench_conv.c','run.sh','README.md'}
assert {p.name:sha(p) for p in production.iterdir()}==record['source_hashes']
SHA=record['source_hashes']['conv2d.c']
assert re.fullmatch(r'[0-9a-f]{64}',SHA) and SHA!=OLDSHA
creation=read(R/'.runs/conv'/V/'creation-experiment-original.json')
assert creation['version']==V and creation['problem']=='conv' and creation['parent']=='C58-r1'
assert creation['created_at']==record['created_at']
assert read(R/'records/best.json')['conv']=='C58-r1' and read(R/'outputs/conv-best.json')['label']=='C7'
for n in ['STRATEGY.md','STATIC_REVIEW.md']:assert (R/'.runs/conv'/V/n).is_file()
assert not B.exists(),'Never overwrite a prepared diagnostic'
B.mkdir();(D/'source').mkdir(parents=True)
for name in ['check_conv_guard.c','check_sve_dispatch.c']:
 shutil.copy2(A/OLD/'source'/name,D/'source'/name)
for name in ['candidate.env','remote_job.sh']:
 text=(A/OLD/'source'/name).read_text().replace(OLD,V).replace(OLDSHA,SHA)
 write(D/'source'/name,text)
shutil.copy2(production/'conv2d.c',D/'source/conv2d.c')
def adapt(text):
 # Only named path/identifier and whole-word round tokens, never ASSEMBLY/PASS.
 text=text.replace('sep13ap','sep13av').replace(OLD,V).replace(OLDSHA,SHA)
 text=re.sub(r'\bAP\b','AV',text).replace('AP_SUMMARY','AV_SUMMARY').replace("'AP'+job_id","'AV'+job_id")
 text=re.sub(r'\bC61\b','C64',text)
 text=text.replace('AO_JOB_ID','AU_JOB_ID').replace('completed_ao_evidence','completed_au_evidence').replace('ao_evidence','au_evidence').replace('sep13ao','sep13au').replace('1589611','1590659')
 text=re.sub(r'\bAO\b','AU',text)
 text=text.replace("['C58-r4', 'C60-row7shared2ext', 'C58-r5']","['C58-r10', 'C63-row7x2shared4rowwise', 'C58-r11']")
 text=text.replace('actual row-wise shared2 load/broadcast schedule','actual 7-row3VL boundary-rowwise and shared2 load/broadcast schedule')
 return text
for name in ['driver.py','accept_and_freeze.py']:
 text=adapt((A/name).read_text());ast.parse(text);write(B/name,text)
 assert 'SOURCE_NAOES' not in text and 'CAPCELLED' not in text and 'PAUS' not in text
hashes={p.name:sha(p) for p in sorted((D/'source').iterdir())}
manifest={p.name:dict(bytes=p.stat().st_size,sha256=hashes[p.name]) for p in sorted((D/'source').iterdir())}
prep=read(A/OLD/'prepared.json')
prep.update(candidate=V,source_experiment=V,source_parent='C58-r1',source_parent_label='C7',status='prepared',complete=False,actual_job_id=None,compiled=False,executed=False,verified=False,performance_measured=False,executed_locally=False,source_hashes=hashes,production_source_hashes=record['source_hashes'],prepared_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_sha256=SHA,expected_acc=3,assembly_review='Pending actual C64 boundary-rowwise and shared2/u1 schedule, stack/frame/FMA; no AP result inherited.',scheduling_scope='Only original AU1590659 complete recorded36 plus live terminal state and own AV reservation; preparation does not submit or query.',root_review_status='NOT_REVIEWED',independent_tools_review_status='NOT_REVIEWED',review_archive_files=['ROOT_REVIEW.md','INDEPENDENT_TOOLS_REVIEW.md'])
assert prep['expected_checks']==dict(full_per_configuration=5744,dispatch_per_configuration=1212,direct_per_configuration=432,configurations=6,total=44328)
assert len(prep['expected_stages'])==19
assert prep['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
for name,data in [('source-hashes.json',hashes),('source-manifest.json',manifest),('prepared.json',prep)]:dump(D/name,data)
write(B/'CHECKER_COUNTS.md','''# AV checker scope: unchanged executed AP bytes

Both checker source files come byte-for-byte from AP C61, not AR/AT. EXPECTED_ACC=3 and BLOCK_OUTPUTS=3L. Full and dispatch main widths remain3L-1,3L,3L+1,6L-1,6L,6L+1; small widths1/3L-1/3L+1, larger-kernel width3L+1, direct widths3L-1/3L/3L+1. VL16/32/64 bytes x1/4 threads gives six configurations. No new C64 result is inferred from checker reuse.

Per configuration full core=6 widths*3 kh*3 kw*18 heights*2 pads*2 orientations=3888; narrow=3*3*4*2*2=144; small=3*5*3*4*2*2=720; larger=4 kernel pairs*2 heights*2*2=32; kw4..8 extra coverage=6*2*5*4*2*2=960. Total5744. Dispatch core6*3*3*18=972 plus quad coverage6*2*5*4=240 gives1212. Direct3 widths*6 kh*3 kw*2 heights*2*2=432. Combined(5744+1212+432)*6=44328.

Per-case rowseven entry expectations remain independent of width. For core heights1..15,21,22,28, sum floor(h/7)=21. Thus dispatch entries=6 widths*2 kh*3 kw*21 +6 widths*2 kh*5 kw*(1+1+2+4)=756+480=1236. Direct entries=3 widths*6 kh*3 kw*(1+4)*2*2=1080. Each case checks its delta, plus aggregate totals and worker mask1 or15. The five legacy helpers must remain nonzero per original checker; runtime observation is recorded separately, never copied into an expected value.

All bitwise scalar memcmp, readonly input/kernel, guard pages, canaries, poisoned output, strict FP order and actual worker VL/thread checks are unchanged AP code. Wrapper retains19 ordered stages, GCC10.3.1/generic, no fast math and FP contraction disabled;38CPU/24576MiB/one packed NUMA/1800s. No local operator runs. This document states expected coverage, not C64 validation.
''')
write(B/'README.md','''# AV C64 prepared diagnostic

Own unexecuted diagnostic for C64-row7boundaryrowwise, standard parent C58-r1=currentC7. Read the candidate STRATEGY.md and STATIC_REVIEW.md for the actual source hypothesis; this template does not claim numerical correctness, generated instruction counts, spill improvement or performance.

Both checker files are byte-identical to executed AP C61 three-vector diagnostics. EXPECTED_ACC3,3VL/6VL main widths, all corresponding small/larger/direct widths,44328 expected cases and19 stages remain AP rules. This is deliberately not the two-vector AR/AT package. The wrapper changes only candidate/source identity; candidate.env changes only candidate name. Current source SHA comes from the real prepared C64 standard record and is checked against all four production files. CHECKER_COUNTS.md re-states cardinalities and per-case1236/1080 entry reasoning.

The driver gates original AU1590659, order C58-r10/C63-row7x2shared4rowwise/C58-r11, complete36-sample campaign plus live terminal scheduler exits and own unique AV reservation. Preparation performs no remote queries; actual status must be checked at GO. No job.json, raw, summary or validation is created by preparation. No automatic submission, confirmation, promotion or packaging.

Root and independent tools review are NOT_REVIEWED and their named archive files are deliberately absent until actual reviewers create them. Root must read AP-to-AV.patch and the prepared C64 source before explicit one-shot --go. Acceptance needs real AV_SUMMARY, original actual job/logs, targeted C64 boundary/shared2/u1 assembly and ROOT_RETURNED_REVIEW. No AP pass or assembly result is inherited.

Future calls retain argv/UTC/stdout/stderr/exit using sep13-run-logged.py. No local operator compilation/test, reset card, shutdown or teammate intervention. User explicitly cancelled40% quota threshold; do not revive the historical stop policy.
''')
patch=''
for name in ['driver.py','accept_and_freeze.py']:
 patch+=''.join(difflib.unified_diff((A/name).read_text().splitlines(True),(B/name).read_text().splitlines(True),fromfile='AP/'+name,tofile='AV/'+name))
for name in ['candidate.env','remote_job.sh']:
 patch+=''.join(difflib.unified_diff((A/OLD/'source'/name).read_text().splitlines(True),(D/'source'/name).read_text().splitlines(True),fromfile='AP/source/'+name,tofile='AV/source/'+name))
write(B/'AP-to-AV.patch',patch)
assert all((A/OLD/'source'/n).read_bytes()==(D/'source'/n).read_bytes() for n in ['check_conv_guard.c','check_sve_dispatch.c'])
for n in ['candidate.env','remote_job.sh']:
 assert (D/'source'/n).read_text().replace(V,OLD).replace(SHA,OLDSHA)==(A/OLD/'source'/n).read_text()
assert 'EXPECTED_ACC=3' in (D/'source/candidate.env').read_text()
accept=(B/'accept_and_freeze.py').read_text();driver=(B/'driver.py').read_text()
assert '-DEXPECTED_ACC=3' in accept and 'BLOCK_OUTPUTS={3*v//4}' in accept and 'TARGETED_ASSEMBLY_REVIEW.md' in accept
assert "AU_JOB_ID = '1590659'" in driver and "['C58-r10', 'C63-row7x2shared4rowwise', 'C58-r11']" in driver
assert all(t in driver for t in ['SOURCE_NAMES','PRODUCTION_NAMES','CANCELLED','CANCELED'])
assert not (D/'job.json').exists() and not (D/'AV_SUMMARY.json').exists()
write(B/'PREPARATION.md','''# AV prepared text only

Generated from original AP diagnostics by .runs/conv/sep13av-prepare.py. Both checkers are unchanged bytes and wrapper/env changes invert exactly to AP. Lightweight ast.parse checked generated Python syntax without importing diagnostic tools. No driver execution, network, compilation or operator run occurred. Current C64 source association and standard prepared state were checked before creating AV files. Review files remain absent/NOT_REVIEWED. Original candidate and prior records remain untouched.
''')
files={str(p.relative_to(B)):dict(bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(B.rglob('*')) if p.is_file()}
dump(B/'PREPARED_FILES.json',files)
print(json.dumps(dict(candidate=V,source_sha256=SHA,files=len(files),expected_acc=3,checker_bytes_unchanged=True,root_review='NOT_REVIEWED',independent_review='NOT_REVIEWED',job_exists=False,executed=False),indent=2))
