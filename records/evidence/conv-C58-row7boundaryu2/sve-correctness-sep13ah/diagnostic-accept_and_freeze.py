"""AH returned-log acceptance/archive only; no operator or network execution."""
from pathlib import Path
import json,re,shlex,shutil,datetime
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
VERSION='C58-row7boundaryu2'
B=BASE/VERSION
RAW=B/'raw'
FROZEN=ROOT/'.runs/conv'/VERSION/'sve-correctness-sep13ah'
def read(p):return json.loads(p.read_text())
def need(ok,why):
    if not ok:raise ValueError(why)
def main():
    need(not FROZEN.exists() and not (B/'validation.json').exists(),'Already accepted/frozen; do not overwrite')
    s=read(B/'AH_SUMMARY.json');j=read(B/'job.json');prepared=read(B/'prepared.json')
    need(s['candidate']==j['version']==VERSION and s['job_id']==j['job_id']=='1583350','Original job identity')
    status=j['scheduler_status'];need(status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Actual terminal exits')
    need(int((RAW/'exit-code.txt').read_text())==0 and s['wrapper_exit']==0 and s['issues']==[],'Wrapper/summary issues')
    stages=['allocation','compiler','manifest','build-guard']+[f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]+['build-assembly','complete']
    need(re.findall(r'^STAGE=(\S+) EXIT=(-?\d+)$',(RAW/'stage-exits.txt').read_text(),re.M)==[(x,'0') for x in stages],'All19 actual ordered stages')
    configs=[]
    for v in (16,32,64):
        for t in (1,4):
            g=(RAW/f'guard-vl{v}-t{t}.log').read_text();d=(RAW/f'dispatch-vl{v}-t{t}.log').read_text()
            header=f'SVE_BYTES={v} SVE_LANES={v//4} BLOCK_OUTPUTS={3*v//4} THREADS={t}'
            need(g.splitlines()[0]==d.splitlines()[0]==header,'Actual VL/thread')
            need(not re.search(r'FAIL|ERROR',g+d),'Numerical failure present')
            need(re.findall(r'^PASS: (\d+) convolution cases;',g,re.M)==['5744'],'Full count')
            need(re.findall(r'^PASS: (\d+) dispatch cases;',d,re.M)==['1212'],'Dispatch count')
            need(re.findall(r'^PASS: (\d+) direct fallback cases;',d,re.M)==['432'],'Direct count')
            need('FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32 quad_boundary=960' in g,'Full families')
            need('DISPATCH_MATRIX_COUNTS core=972 quad_boundary=240' in d,'Dispatch families')
            for name,n in [('DISPATCH',1236),('DIRECT',1080)]:
                mask=1 if t==1 else 15
                need(f'{name}_ROWSEVEN_ACTUAL_ENTRIES={n} EXPECTED={n} WORKER_MASK={mask} EXPECTED_MASK={mask}' in d,'Entries/workers')
            configs.append(dict(sve_bytes=v,threads=t,full_cases=5744,dispatch_cases=1212,direct_cases=432))
    flags=['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra','-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp','-DEXPECTED_ACC=3']
    expected=[flags+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],flags+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],flags+['-S','conv2d.c','-o','conv2d-sve.s']]
    probe=(RAW/'probe.log').read_text()
    observed=[shlex.split(x) for x in re.findall(r'^\+ (gcc -O3 .+)$',probe,re.M)]
    need(observed==expected==s['actual_compile_argv'],'Three actual compile argv')
    need((RAW/'compiler-version.txt').read_text().strip()==s['compiler_version']=='10.3.1','Actual compiler')
    for k,v in [('OMP_DYNAMIC','FALSE'),('OMP_PROC_BIND','close'),('OMP_PLACES','cores')]:need(f'+ {k}={v}' in probe,'Actual OMP')
    need(len(s['allowed_cpus'])==38 and s['requested_resources']==j['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800),'Allocation')
    hashes=read(B/'source-hashes.json');need(hashes==prepared['source_hashes']==j['source_hashes'],'Source association')
    need({row['name']:row['sha256'] for row in s['source_files']}==hashes and all(row['all_manifests_and_transport_bytes_equal'] for row in s['source_files']),'Completed lifecycle source verification')
    # Lifecycle already verified remote manifest; require the exact returned bytes still match originals.
    for name in hashes:need((RAW/name).read_bytes()==(B/'source'/name).read_bytes(),'Returned source changed')
    assembly=(RAW/'conv2d-sve.s').read_text()
    need(not re.search(r'^\s*(?:fmla|fmls|fmad|fmsb|fnmla|fnmls|fnmad|fnmsb|fmadd|fmsub|fnmadd|fnmsub|fmlal2?|fmlsl2?|fmmla)\b',assembly,re.M),'Unexpected fused arithmetic')
    review=B/'TARGETED_ASSEMBLY_REVIEW.md'
    need(review.is_file() and (B/'ROOT_RETURNED_REVIEW.md').is_file(),'Root must first read targeted actual review')
    result=dict(status='passed',complete=True,candidate=VERSION,job_id='1583350',scheduler=status,exit_code=0,total_cases=44328,full_cases=34464,dispatch_cases=7272,direct_cases=2592,runner_cases=0,configurations=configs,source_hashes=hashes,source_hashes_verified=True,compiler_version='10.3.1',build_commands=expected,stage_exits=s['stages'],allocation=s['scheduler_resources'],assembly=dict(fused_instructions=0,review='TARGETED_ASSEMBLY_REVIEW.md'),performance_measured=False,executed_locally=False,executed_remotely=True,sanitizer='NOT_RUN',issues=[],note='Original AH own numerical evidence; root-read targeted pragma review. No speed claim or automatic promotion.')
    # Archive existing evidence without altering raw/prepared/creation metadata.
    temp=FROZEN.with_name(FROZEN.name+'.tmp');need(not temp.exists(),'Pending archive exists')
    shutil.copytree(B,temp)
    (temp/'validation.json').write_text(json.dumps(result,indent=2)+'\n')
    for name in ['driver.py','accept_and_freeze.py','README.md','ROOT_REVIEW.md','INDEPENDENT_TOOLS_REVIEW.md']:
        shutil.copy2(BASE/name,temp/('diagnostic-'+name))
    (temp/'raw/conv2d-sve.assembly.txt').write_bytes((RAW/'conv2d-sve.s').read_bytes())
    freeze=dict(candidate=VERSION,job_id='1583350',mode='passed',frozen_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_directory=str(B.relative_to(ROOT)),original_metadata_preserved=True,original_source_and_raw_preserved=True,operator_executed=False,assembly_available=True)
    (temp/'freeze-source.json').write_text(json.dumps(freeze,indent=2)+'\n')
    temp.rename(FROZEN)
    (B/'validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print('AH1583350 accepted/frozen44328; performance unmeasured.')
if __name__=='__main__':main()
