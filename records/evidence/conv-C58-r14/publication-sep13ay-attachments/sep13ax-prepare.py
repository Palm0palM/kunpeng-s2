"""Generate AX diagnostic transport as text only; no network or operator execution."""
from pathlib import Path
import ast,datetime,difflib,hashlib,json,re,shutil
R=Path(__file__).resolve().parents[2];A=R/'.runs/conv/sep13av-checks';B=R/'.runs/conv/sep13ax-checks'
OLD='C64-row7boundaryrowwise';V='C65-row7balanced';D=B/V
OLDSHA='fcbfaf198157718355bee19a5cf9cab5e567508e69f38050595e146b3d57e421'
def read(p):return json.loads(p.read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,text):
 with p.open('x') as f:f.write(text)
def dump(p,data):write(p,json.dumps(data,indent=2)+'\n')
record=read(R/'records/experiments/conv'/f'{V}.json');source=R/'.runs/conv'/V/'source'
assert record['status']=='prepared' and record['verified'] is False
assert record.get('source_parent',record.get('parent'))=='C58-r1'
assert {p.name:sha(p) for p in source.iterdir()}==record['source_hashes']
SHA=record['source_hashes']['conv2d.c']
assert not D.exists(),'No overwrite/repeat preparation'
(D/'source').mkdir(parents=True)
for name in ['check_conv_guard.c','check_sve_dispatch.c']:shutil.copy2(B/'templates'/name,D/'source'/name)
shutil.copy2(source/'conv2d.c',D/'source/conv2d.c')
env=(A/OLD/'source/candidate.env').read_text().replace(OLD,V).replace('EXPECTED_DISPATCH=1212','EXPECTED_DISPATCH=2724').replace('EXPECTED_TOTAL=44328','EXPECTED_TOTAL=80100').replace('EXPECTED_DISPATCH_ROWSEVEN_ENTRIES=1236','EXPECTED_DISPATCH_ROWSEVEN_T1=4008\nEXPECTED_DISPATCH_ROWSEVEN_T4=6168\nEXPECTED_DISPATCH_ROWSEVEN_T38=24010')
write(D/'source/candidate.env',env)
wrapper=(A/OLD/'source/remote_job.sh').read_text().replace(OLD,V).replace(OLDSHA,SHA)
wrapper=wrapper.replace('"$EXPECTED_DISPATCH" == 1212','"$EXPECTED_DISPATCH" == 2724').replace('"$EXPECTED_TOTAL" == 44328','"$EXPECTED_TOTAL" == 80100')
wrapper=wrapper.replace('[[ "$EXPECTED_DISPATCH_ROWSEVEN_ENTRIES" == 1236 && "$EXPECTED_DIRECT_ROWSEVEN_ENTRIES" == 1080 ]]','[[ "$EXPECTED_DISPATCH_ROWSEVEN_T1" == 4008 && "$EXPECTED_DISPATCH_ROWSEVEN_T4" == 6168 && "$EXPECTED_DISPATCH_ROWSEVEN_T38" == 24010 && "$EXPECTED_DIRECT_ROWSEVEN_ENTRIES" == 1080 ]]')
wrapper=wrapper.replace('for threads in 1 4; do','for threads in 1 4 38; do')
write(D/'source/remote_job.sh',wrapper)
def adapt(text):
 for old,new in [('sep13av','sep13ax'),(OLD,V),(OLDSHA,SHA),('AV_SUMMARY','AX_SUMMARY'),('AU_JOB_ID','AW_JOB_ID'),('completed_au_evidence','completed_aw_evidence'),('au_evidence','aw_evidence'),('sep13au','sep13aw'),('1590659','1590883')]:text=text.replace(old,new)
 for old,new in [('AV','AX'),('AU','AW'),('C64','C65')]:text=re.sub(r'\b'+old+r'\b',new,text)
 text=text.replace("'AV'+job_id","'AX'+job_id")
 text=text.replace("['C58-r10', 'C63-row7x2shared4rowwise', 'C58-r11']","['C58-r12', 'C64-row7boundaryrowwise', 'C58-r13']")
 return text
s=adapt((A/'driver.py').read_text())
s=s.replace('dispatch_per_configuration=1212','dispatch_per_configuration=2724').replace('configurations=6, total=44328','configurations=9, total=80100').replace('for threads in (1, 4)]','for threads in (1, 4, 38)]')
assert "AW_JOB_ID = '1590883'" in s and 'configurations=9, total=80100' in s
assert 'SOURCE_NAMES' in s and 'CANCELLED' in s
ast.parse(s);write(B/'driver.py',s)
s=adapt((A/'accept_and_freeze.py').read_text())
s=s.replace('for t in (1,4)','for t in (1,4,38)').replace('All19 actual ordered stages','All25 actual ordered stages')
s=s.replace("==['1212'],'Dispatch count'","==['2724'],'Dispatch count'")
s=s.replace("'DISPATCH_MATRIX_COUNTS core=972 quad_boundary=240'","'DISPATCH_MATRIX_COUNTS core=972 quad_boundary=240 balance=1512'")
old="""            for name,n in [('DISPATCH',1236),('DIRECT',1080)]:
                mask=1 if t==1 else 15
                need(f'{name}_ROWSEVEN_ACTUAL_ENTRIES={n} EXPECTED={n} WORKER_MASK={mask} EXPECTED_MASK={mask}' in d,'Entries/workers')
            configs.append(dict(sve_bytes=v,threads=t,full_cases=5744,dispatch_cases=1212,direct_cases=432))"""
new="""            totals={1:4008,4:6168,38:24010};families={1:(756,480,2772),4:(1020,660,4488),38:(1386,880,21744)}
            core,quad,balance=families[t]
            need(f'DISPATCH_EXPECTED_FAMILIES core={core} quad_boundary={quad} balance={balance}' in d,'Fixed independently derived entry totals')
            for name,n,mask in [('DISPATCH',totals[t],(1<<t)-1),('DIRECT',1080,1 if t==1 else 15)]:
                need(f'{name}_ROWSEVEN_ACTUAL_ENTRIES={n} EXPECTED={n} WORKER_MASK={mask} EXPECTED_MASK={mask}' in d,'Per-case validated entries/workers and aggregate')
            coverage=re.findall(r'^OUTPUT_EXACT_ONCE_CASES=(\\d+) EXPECTED=(\\d+) OUTPUT_VALUES=(\\d+) ADDRESS_ERRORS=(\\d+)$',d,re.M)
            need(len(coverage)==1 and tuple(map(int,coverage[0][:2]))==(3156,3156) and int(coverage[0][2])>0 and coverage[0][3]=='0','Actual predicate-aware exactly-once SVE output coverage')
            legacy={k:int(n) for k,n in re.findall(r'SVE_(PREFIX|TAIL|ROWPAIR|ROWTRIPLE|ROWQUAD)_ACTUAL_ENTRIES=(\\d+)',d)}
            need(set(legacy)=={'PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'} and all(n>0 for n in legacy.values()),'Original legacy nonzero coverage')
            configs.append(dict(sve_bytes=v,threads=t,full_cases=5744,dispatch_cases=2724,direct_cases=432,exact_once_cases=3156))"""
assert old in s;s=s.replace(old,new)
s=s.replace('total_cases=44328,full_cases=34464,dispatch_cases=7272,direct_cases=2592','total_cases=80100,full_cases=51696,dispatch_cases=24516,direct_cases=3888')
s=s.replace('actual 7-row3VL boundary-rowwise and shared2 load/broadcast schedule','actual balanced group/column dispatch with unchanged C7 helpers and diagnostic predicate-aware stores')
s=s.replace('accepted/frozen44328','accepted/frozen80100')
ast.parse(s);write(B/'accept_and_freeze.py',s)
hashes={p.name:sha(p) for p in (D/'source').iterdir()};manifest={p.name:dict(bytes=p.stat().st_size,sha256=hashes[p.name]) for p in (D/'source').iterdir()}
stages=['allocation','compiler','manifest','build-guard']+[f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4,38)]+['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4,38)]+['build-assembly','complete']
counts=dict(full_per_configuration=5744,dispatch_per_configuration=2724,direct_per_configuration=432,configurations=9,total=80100)
prep=dict(candidate=V,source_experiment=V,source_parent='C58-r1',source_parent_label='C7',status='prepared',complete=False,actual_job_id=None,compiled=False,executed=False,verified=False,performance_measured=False,executed_locally=False,source_hashes=hashes,production_source_hashes=record['source_hashes'],expected_checks=counts,expected_stages=stages,prepared_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_sha256=SHA,resources=dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800),expected_acc=3,assembly_review='Pending own balanced-dispatch generated code and unchanged-helper review',root_review_status='NOT_REVIEWED',independent_tools_review_status='NOT_REVIEWED',scheduling_scope='Only AW1590883 complete recorded36/live terminal plus own AX reservation; no submit by preparation')
for name,data in [('source-hashes.json',hashes),('source-manifest.json',manifest),('prepared.json',prep)]:dump(D/name,data)
table={str(t):dict(core=c,quad_boundary=q,balance=b,total=c+q+b,dispatch_mask=(1<<t)-1,direct_entries=1080,direct_mask=1 if t==1 else 15) for t,c,q,b in [(1,756,480,2772),(4,1020,660,4488),(38,1386,880,21744)]}
dump(B/'EXPECTED_ENTRY_TABLE.json',dict(scope='Pre-execution independent mathematical owner-map counts, not actual results',threads=table,vector_bytes=[16,32,64],per_configuration=counts,extra_balance_cases=1512,total_cases=80100,stage_count=25))
shutil.copy2(R/'.runs/conv/sep13ax-root-entry-derivation.json',B/'ROOT_INDEPENDENT_ENTRY_DERIVATION.json')
patch=''
for name in ['driver.py','accept_and_freeze.py']:
 patch+=''.join(difflib.unified_diff((A/name).read_text().splitlines(True),(B/name).read_text().splitlines(True),fromfile='AV/'+name,tofile='AX/'+name))
for name in ['check_conv_guard.c','check_sve_dispatch.c','candidate.env','remote_job.sh']:
 patch+=''.join(difflib.unified_diff((A/OLD/'source'/name).read_text().splitlines(True),(D/'source'/name).read_text().splitlines(True),fromfile='AV/source/'+name,tofile='AX/source/'+name))
write(B/'AV-to-AX.patch',patch)
write(B/'README.md','''# AX C65 balanced dispatch: prepared only

Own source C65-row7balanced parentC58-r1/currentC7. Production flattens7-row groups andceil(ow/3VL) column tiles, partitions by actual OpenMP team, and merges same-group contiguous pieces. All C7 helpers remain unchanged. No operator execution, job or result is created by this preparation.

Nine configurations:VL16/32/64 bytes x1/4/38 actual threads. Original noninstrumented full5744 shapes retained. Instrumented dispatch retains original972+240 shapes and adds exactly1512 balance shapes:nominal tiles1/2/3/4/37/38/39, widthT*3L-1/T*3L/T*3L+1;oh7/8/9/10/11/12/13/14/15/27/28/29;kh7/8;kw1/4/7. Direct432 original guarded kh1..6 shapes retained. Per configuration5744+2724+432=8900; nine configs80100. 25 stages, fixed1800s hard limit,38CPU/24576MiB/one packed NUMA, GCC10.3.1 strict/generic/ACC3. No extra combinations or enlarged resources.

Entry expectations are independent of production cursor loop: inverse tile-owner map enumerates each full group's tiles, counts owner transitions and builds expected worker mask. q=0 only uses the nonzero first branch. Fixed pre-remote table EXPECTED_ENTRY_TABLE.json has dispatch4008/6168/24010 for1/4/38threads, masks1/15/274877906943; direct1080 and masks1/15/15. Each case checks its actual delta and mask, including zero full-group work; aggregates also compare the fixed table. Root separately derived the same counts by nonempty interval intersections in ROOT_INDEPENDENT_ENTRY_DERIVATION.json. Neither file contains observed operator results.

Exactly-once coverage is diagnostic-only:before including unchanged conv2d.c, svst1 is mapped to no_instrument SVE observer, then unmapped. The observer materializes the actual predicate per32-bit lane, checks integer uintptr_t addresses and atomically increments an independent counter per active output lane; it then calls the original svst1_f32 with unchanged predicate/address/value. one_case initializes counters before the team and checks all outputs count1 after team join, then frees them. It catches identical duplicate stores that memcmp alone cannot. Original scalar bitwise reference, guards/canaries/readonly input and kernel remain. This observes SVE output stores only; original setup requires actual SVE on every worker and conv2d's supported positive shapes take SVE paths. The separate fullguard executable does not wrap stores. No observer is used for performance or in the submission source.

All observer functions use no_instrument_function. Expected owner logic uses fixed shapes and actual validated team size, never writes an expectation from observed counts. Direct38-thread cases have at mostfour groups and do not require38 active helpers. Legacy helper counts retain original nonzero coverage checks and are separately observed, not forced to prior totals.

The driver requires original AW1590883 complete36-sample campaign(C58-r12/C64-row7boundaryrowwise/C58-r13), its live terminal status and own unique reservation. Unknown/nonterminal or failed query blocks explicit root GO; no automatic submission/retry, acceptance, promotion or ZIP. Actual AX_SUMMARY/targeted assembly/root returned review are required before any acceptance. ROOT_REVIEW and INDEPENDENT_TOOLS_REVIEW are currently absent/NOT_REVIEWED until actual reviewers write them. User revoked old40% stop; no reset card, local operator test, shutdown or teammate intervention.
''')
write(B/'PREPARATION.md','''# AX preparation scope

Generated transport/checker/acceptor text with source identity from the real standard prepared C65 record. Python ast.parse only; no diagnostic imports, compilation, test, network, submission or acceptance. Source conv2d.c copied byte-for-byte. The new checker has not yet been compiled or run; fixed mathematical counts are expected values only. Read AV-to-AX.patch, observer and independent entry derivation before explicit GO. Root and independent review reports remain pending; do not infer approval from prepared status.
''')
assert len(stages)==25 and 'EXPECTED_ACC=3' in env
assert 'TARGETED_ASSEMBLY_REVIEW.md' in (B/'accept_and_freeze.py').read_text()
assert 'for threads in (1, 4, 38)' in (B/'driver.py').read_text()
assert not (D/'job.json').exists()
print(json.dumps(dict(candidate=V,source_sha256=SHA,expected_cases=80100,stages=25,actual_job_id=None,compiled=False,executed=False),indent=2))
