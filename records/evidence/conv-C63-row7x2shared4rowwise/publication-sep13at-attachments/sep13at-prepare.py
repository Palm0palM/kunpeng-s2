"""Prepare AT C63 diagnostics as text only; no operator/network execution."""
from pathlib import Path
import ast,datetime,difflib,hashlib,json,re,shutil
R=Path(__file__).resolve().parents[2];A=R/'.runs/conv/sep13ar-checks';B=R/'.runs/conv/sep13at-checks'
OLD='C62-row7x2shared4';V='C63-row7x2shared4rowwise';D=B/V
OLDSHA='e6cc9bdb4c14e9f6982f687123379ebf5dfb2013777f7bb076c04edd4827dc8a';SHA='d78a863eb49c85d415420819e4b6ef8379260a34ad9f118da5bab1bdca7e94a8'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
B.mkdir();(D/'source').mkdir(parents=True)
record=read(R/'records/experiments/conv'/f'{V}.json');production=R/'.runs/conv'/V/'source'
assert record['status']=='prepared' and record['verified'] is False and record['source_parent']=='C58-r1'
assert sha(production/'conv2d.c')==record['source_hashes']['conv2d.c']==SHA
for name in ['check_conv_guard.c','check_sve_dispatch.c']:shutil.copy2(A/OLD/'source'/name,D/'source'/name)
for name in ['candidate.env','remote_job.sh']:
 text=(A/OLD/'source'/name).read_text().replace(OLD,V).replace(OLDSHA,SHA)
 (D/'source'/name).write_text(text)
shutil.copy2(production/'conv2d.c',D/'source/conv2d.c')
def adapt(text):
 text=text.replace('sep13ar','sep13at').replace(OLD,V).replace(OLDSHA,SHA)
 text=re.sub(r'\bAR\b','AT',text).replace('AR_SUMMARY','AT_SUMMARY').replace("'AR'+job_id","'AT'+job_id")
 text=text.replace('C62 transport','C63 transport').replace('C62 checkpoint','C63 checkpoint').replace('C62 reviewed','C63 reviewed').replace('for C62;','for C63;')
 text=text.replace('AQ_JOB_ID','AS_JOB_ID').replace('completed_aq_evidence','completed_as_evidence').replace('aq_evidence','as_evidence').replace('sep13aq','sep13as').replace('1590254','1590550').replace('Original AQ','Original AS')
 text=text.replace("['C58-r6', 'C61-row7shared2rowwise', 'C58-r7']","['C58-r8', 'C62-row7x2shared4', 'C58-r9']")
 text=text.replace('actual 7-row 2VL shared4 load/broadcast schedule','actual 7-row 2VL shared4 rowwise load/broadcast schedule')
 return text
for name in ['driver.py','accept_and_freeze.py']:
 text=adapt((A/name).read_text());ast.parse(text);(B/name).write_text(text)
hashes={p.name:sha(p) for p in sorted((D/'source').iterdir())}
manifest={p.name:dict(bytes=p.stat().st_size,sha256=hashes[p.name]) for p in sorted((D/'source').iterdir())}
prep=read(A/OLD/'prepared.json')
prep.update(candidate=V,source_experiment=V,source_parent='C58-r1',status='prepared',complete=False,actual_job_id=None,compiled=False,executed=False,verified=False,performance_measured=False,executed_locally=False,source_hashes=hashes,production_source_hashes=record['source_hashes'],prepared_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_sha256=SHA,assembly_review='Pending own 7-row2VL/shared4 rowwise schedule, spill/frame/FMA; no result inherited from AR.',scheduling_scope='Only original AS1590550 with complete recorded36 and live terminal state plus own AT reservation; preparation does not run or submit.',root_review_status='NOT_REVIEWED',independent_tools_review_status='NOT_REVIEWED',review_archive_files=['ROOT_REVIEW.md','INDEPENDENT_TOOLS_REVIEW.md'])
for name,data in [('source-hashes.json',hashes),('source-manifest.json',manifest),('prepared.json',prep)]: (D/name).write_text(json.dumps(data,indent=2)+'\n')
shutil.copy2(A/'CHECKER_COUNTS.md',B/'CHECKER_COUNTS.md')
readme='''# AT C63 prepared diagnostic

Own unexecuted diagnostics for C63-row7x2shared4rowwise, source parent C58-r1=currentC7. Only C62 shared4 internal scheduling changed to two input vectors followed by one scoped weight per row. Source count remains56mul/56add/8loads/28broadcast; no actual spill reduction or speed claim.

Both checker files are byte-identical to the executed AR package, including EXPECTED_ACC2 and all2VL/4VL width boundaries. CHECKER_COUNTS.md is the original AR derivation copied verbatim as reusable coverage documentation, not C63 results. Wrapper only substitutes candidate and source identity; candidate.env only substitutes candidate. Matrix44328 and19 stages, GCC10.3.1 strict/generic,38CPU24576MiBsingle packed NUMA1800,VL16/32/64 bytes x threads1/4 unchanged.

The driver requires original AS1590550 complete with order C58-r8/C62-row7x2shared4/C58-r9 and36 recorded samples, plus live terminal status and integer job/system exits. AS was running when preparation was requested; this preparation never queries it. Unknown reservation, missing results, query failure or nonterminal status blocks root GO. Root remains sole submitter. Current C63 four production files, frozen five transport files, creation identity and confirmed C7 source are checked without rewriting metadata or inheriting AR PASS.

No job.json, raw, summary or numerical acceptance exists. Archive names include ROOT_REVIEW.md and INDEPENDENT_TOOLS_REVIEW.md; both are currently NOT_REVIEWED and deliberately absent, not fabricated approvals. Root/independent review must create actual reports before acceptance. Real AT_SUMMARY, targeted shared4 rowwise/u1 assembly and ROOT_RETURNED_REVIEW can only be made from original returned evidence. Acceptance remains one-shot44328 validation and freeze; no performance, confirmation, promotion or ZIP.

Prepared interfaces, NOT EXECUTED:
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json submit --go
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json status
python3 .runs/conv/sep13at-checks/driver.py C63-row7x2shared4rowwise config/conv-sep12.local.json fetch
python3 .runs/conv/sep13at-checks/accept_and_freeze.py --job-id <actual_original_AT_ID>

All future calls retain argv/UTC/stdout/stderr/exit via sep13-run-logged.py. No local operator execution or reset card. The user cancelled the old40-percent threshold; do not treat historical stop metadata as current policy.
'''
(B/'README.md').write_text(readme)
patch=''
for name in ['driver.py','accept_and_freeze.py']:
 patch+=''.join(difflib.unified_diff((A/name).read_text().splitlines(True),(B/name).read_text().splitlines(True),fromfile='AR/'+name,tofile='AT/'+name))
for name in ['candidate.env','remote_job.sh']:
 patch+=''.join(difflib.unified_diff((A/OLD/'source'/name).read_text().splitlines(True),(D/'source'/name).read_text().splitlines(True),fromfile='AR/source/'+name,tofile='AT/source/'+name))
(B/'AR-to-AT.patch').write_text(patch)
assert all((A/OLD/'source'/n).read_bytes()==(D/'source'/n).read_bytes() for n in ['check_conv_guard.c','check_sve_dispatch.c'])
for n in ['candidate.env','remote_job.sh']:assert (D/'source'/n).read_text().replace(V,OLD).replace(SHA,OLDSHA)==(A/OLD/'source'/n).read_text()
assert 'AS_JOB_ID' in (B/'driver.py').read_text() and '1590550' in (B/'driver.py').read_text()
(B/'PREPARATION.md').write_text('# AT preparation only\n\nGenerated by .runs/conv/sep13at-prepare.py from executed AR transport. Lightweight ast.parse syntax parsing only, no imports of diagnostic tools, network, operator execution or submission. Checked exact checker bytes, inverse identity-only wrapper/env substitution, own prepared C63 source and standard record. Root and independent tools review remain NOT_REVIEWED/absent; actual root will read AR-to-AT.patch. Original C63 and all earlier experiments untouched.\n')
files={str(p.relative_to(B)):dict(bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(B.rglob('*')) if p.is_file()}
(B/'PREPARED_FILES.json').write_text(json.dumps(files,indent=2)+'\n')
print(json.dumps(dict(candidate=V,source_sha256=SHA,files=len(files),checker_bytes_unchanged=True,root_review='NOT_REVIEWED',independent_review='NOT_REVIEWED',job_exists=(D/'job.json').exists(),executed=False),indent=2))
