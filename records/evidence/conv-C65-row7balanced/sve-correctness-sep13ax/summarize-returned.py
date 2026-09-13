"""Read original AX logs and write a lifecycle summary; no network/operator import."""
from pathlib import Path
import datetime, hashlib, json, re, shlex
B=Path(__file__).resolve().parent
ROOT=B.parents[3]
RAW=B/'raw'
def read(p): return json.loads(p.read_text())
def relative(p): return str(p.relative_to(ROOT))
issues=[]
def check(ok,why):
    if not ok: issues.append(why)
def one(pattern,text):
    values=re.findall(pattern,text,re.M)
    if len(values)!=1: raise ValueError('Expected exactly one match: '+pattern)
    return values[0]
j=read(B/'job.json'); probe=(RAW/'probe.log').read_text(); scheduler=(B/'scheduler.log').read_text()
check(j['job_id']=='1591086' and j['version']=='C65-row7balanced','Original AX identity')
status=j['scheduler_status']; check(status['jobId']==j['job_id'] and status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Actual terminal exits')
wrapper=int((RAW/'exit-code.txt').read_text()); check(wrapper==0,'Wrapper exit')
stages=[dict(stage=n,exit_code=int(c)) for n,c in re.findall(r'^STAGE=(\S+) EXIT=(-?\d+)$',(RAW/'stage-exits.txt').read_text(),re.M)]
expected=['allocation','compiler','manifest','build-guard']+[f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4,38)]+['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4,38)]+['build-assembly','complete']
check(stages==[dict(stage=n,exit_code=0) for n in expected],'25 ordered successful stages')
configs=[]
for v in (16,32,64):
    for t in (1,4,38):
        gp=RAW/f'guard-vl{v}-t{t}.log'; dp=RAW/f'dispatch-vl{v}-t{t}.log'; g=gp.read_text(); d=dp.read_text()
        header=tuple(map(int,one(r'^SVE_BYTES=(\d+) SVE_LANES=(\d+) BLOCK_OUTPUTS=(\d+) THREADS=(\d+)$',g)))
        dh=tuple(map(int,one(r'^SVE_BYTES=(\d+) SVE_LANES=(\d+) BLOCK_OUTPUTS=(\d+) THREADS=(\d+)$',d)))
        check(header==dh==(v,v//4,3*v//4,t),f'Actual VL/thread {v}/{t}')
        full=int(one(r'^PASS: (\d+) convolution cases;',g)); dispatch=int(one(r'^PASS: (\d+) dispatch cases;',d)); direct=int(one(r'^PASS: (\d+) direct fallback cases;',d))
        check((full,dispatch,direct)==(5744,2724,432),f'Case counts {v}/{t}')
        normal_coverage=re.compile(r'OUTPUT_EXACT_ONCE_CASES=3156 EXPECTED=3156 OUTPUT_VALUES=[1-9][0-9]* ADDRESS_ERRORS=0')
        bad_lines=[line for line in (g+d).splitlines() if re.search(r'FAIL|ERROR',line) and not normal_coverage.fullmatch(line)]
        check(not bad_lines,f'Failure marker {v}/{t}')
        families=lambda pattern,text:{k:int(x) for k,x in re.findall(r'(\w+)=(\d+)',one(pattern,text))}
        ff=families(r'^FULL_MATRIX_COUNTS (.+)$',g); df=families(r'^DISPATCH_MATRIX_COUNTS (.+)$',d)
        check(ff==dict(core=3888,narrow=144,small=720,larger=32,quad_boundary=960) and df==dict(core=972,quad_boundary=240,balance=1512),f'Matrix families {v}/{t}')
        fixed={1:dict(core=756,quad_boundary=480,balance=2772,total=4008),4:dict(core=1020,quad_boundary=660,balance=4488,total=6168),38:dict(core=1386,quad_boundary=880,balance=21744,total=24010)}[t]
        computed=families(r'^DISPATCH_EXPECTED_FAMILIES (.+)$',d)
        check(computed=={k:fixed[k] for k in ('core','quad_boundary','balance')},f'Independent fixed entry table {v}/{t}')
        entries={}
        for name,n,mask in [('DISPATCH',fixed['total'],(1<<t)-1),('DIRECT',1080,1 if t==1 else 15)]:
            vals=tuple(map(int,one(r'^'+name+r'_ROWSEVEN_ACTUAL_ENTRIES=(\d+) EXPECTED=(\d+) WORKER_MASK=(\d+) EXPECTED_MASK=(\d+)$',d)))
            check(vals==(n,n,mask,mask),f'Entries/mask {name}/{v}/{t}')
            entries[name.lower()]=dict(zip(['actual','expected','worker_mask','expected_mask'],vals))
        coverage=tuple(map(int,one(r'^OUTPUT_EXACT_ONCE_CASES=(\d+) EXPECTED=(\d+) OUTPUT_VALUES=(\d+) ADDRESS_ERRORS=(\d+)$',d)))
        # Independent shape-count algebra: sum of oh*ow across dispatch/direct cases.
        expected_values=436617*(3*v//4)
        check(coverage==(3156,3156,expected_values,0),f'Exactly-once SVE writes and independent output count {v}/{t}')
        coverage_result=dict(zip(['actual_cases','expected_cases','actual_output_values','address_errors'],coverage));coverage_result['independent_expected_output_values']=expected_values
        legacy={n:int(x) for n,x in re.findall(r'SVE_(PREFIX|TAIL|ROWPAIR|ROWTRIPLE|ROWQUAD)_ACTUAL_ENTRIES=(\d+)',d)}
        check(set(legacy)=={'PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'} and all(x>0 for x in legacy.values()),f'Original checker nonzero legacy coverage {v}/{t}')
        configs.append(dict(sve_bytes=header[0],sve_lanes=header[1],threads=header[3],full_cases=full,dispatch_cases=dispatch,direct_cases=direct,total=full+dispatch+direct,full_families=ff,dispatch_families=df,rowseven_entries=entries,independent_entry_families=computed,exact_once_coverage=coverage_result,legacy_suite_entries=legacy,guard_log=relative(gp),dispatch_log=relative(dp)))
argv=[shlex.split(x) for x in re.findall(r'^\+ (gcc -O3 .+)$',probe,re.M)]
flags=['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra','-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp','-DEXPECTED_ACC=3']
check(argv==[flags+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],flags+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],flags+['-S','conv2d.c','-o','conv2d-sve.s']],'Actual three compiler commands')
compiler=(RAW/'compiler-version.txt').read_text().strip(); check(compiler=='10.3.1' and 'gcc (GCC) 10.3.1' in probe,'Actual compiler')
omp={k:one(r'^\+ '+k+r'=(\S+)$',probe) for k in ('OMP_DYNAMIC','OMP_PROC_BIND','OMP_PLACES')}; check(omp==dict(OMP_DYNAMIC='FALSE',OMP_PROC_BIND='close',OMP_PLACES='cores'),'Actual OMP binding')
resources={k:int(one(r'^\s*'+k+r'\s+(\d+)\s*$',scheduler)) for k in ('reqCPU','reqMem','allocCPU','allocMem','timeout','jobExitCode','systemExitCode')}
resources['reqAffinity']=one(r'^\s*reqAffinity\s+(numa\[.+\])\s*$',scheduler)
check(resources==dict(reqCPU=38,reqMem=24576,allocCPU=38,allocMem=24576,timeout=1800,jobExitCode=0,systemExitCode=0,reqAffinity='numa[count=1, distribution=pack]'),'Actual scheduler allocation')
check(j['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800),'Requested allocation')
cpus=list(map(int,one(r'^ALLOWED_CPUS=([0-9,]+)$',probe).split(','))); numa=one(r'^NUMA_NODE=(\S+)$',probe)
check(len(cpus)==len(set(cpus))==38 and re.fullmatch(r'node[0-9]+',numa),'Actual affinity shape')
affinity_block=one(r'(?s)allocAffinity\s+(.*?)Runtime Details:',scheduler)
allocated_rows=re.findall(r'^\s*(\S+)\s+(\d+)\s+(\S+)\s+([0-9,-]+)\s+-\s+-\s*$',affinity_block,re.M)
check(len(allocated_rows)==1,'One scheduler affinity row')
def expand_cpus(value):
    result=[]
    for part in value.split(','):
        bounds=list(map(int,part.split('-')))
        result.extend(range(bounds[0],bounds[-1]+1))
    return result
scheduler_node,res_group,res_index,scheduler_cpu_text=allocated_rows[0]
scheduler_cpus=expand_cpus(scheduler_cpu_text)
probe_node=one(r'^\+ hostname\n(\S+)$',probe)
check(scheduler_cpus==cpus and len(set(scheduler_cpus))==38,'Scheduler/probe CPU agreement')
check(probe_node==scheduler_node==one(r'^\s*execNodes\s+(\S+)\s*$',scheduler),'Scheduler/probe node agreement')
check('aarch64' in scheduler and one(r'^\s*execNodeCnt\s+(\d+)\s*$',scheduler)=='1','Scheduler architecture/single node')
# The returned allocation stage validates these actual allowed CPUs against sysfs
# NUMA membership. Node numbering is read from the probe, never assumed.
allocation_source=(RAW/'remote_job.sh').read_text().split('CHECK_ALLOCATION\n',1)[0]
check('assert len(nodes) == 1' in allocation_source and 'allowed <= cpus(p.read_text())' in allocation_source and 'os.sched_getaffinity(0)' in allocation_source,'Actual single-NUMA allocation check retained')
hashes=read(B/'source-hashes.json'); prep=read(B/'prepared.json'); sizes=read(B/'source-manifest.json')
remote={n:h for h,n in re.findall(r'^([0-9a-f]{64})  (\S+)$',(RAW/'source-sha256.txt').read_text(),re.M)}
check(set(hashes)==set(remote)=={'conv2d.c','candidate.env','check_conv_guard.c','check_sve_dispatch.c','remote_job.sh'},'Five transport sources')
source=[]
for name,h in sorted(hashes.items()):
    original=(B/'source'/name).read_bytes(); returned=(RAW/name).read_bytes(); actual=hashlib.sha256(returned).hexdigest()
    ok=original==returned and actual==h==remote.get(name)==j['source_hashes'].get(name)==prep['source_hashes'].get(name) and sizes[name]==dict(bytes=len(original),sha256=h)
    check(ok,'Source association '+name); source.append(dict(name=name,bytes=len(returned),sha256=actual,all_manifests_and_transport_bytes_equal=ok))
check(one(r'^CANDIDATE=(\S+)$',probe)==j['version'],'Returned candidate identity')
check(one(r'^PROBE_COMPLETE=(\d+)$',probe)=='1','Completion marker')
check('SANITIZER_STATUS=NOT_RUN;' in probe,'Sanitizer status')
outer=[]
status_commands=sorted((ROOT/'.runs/conv').glob('sep13ax-lifecycle-status-*.command.json'))
fetch_commands=sorted((ROOT/'.runs/conv').glob('sep13ax-lifecycle-fetch-*.command.json'))
check(bool(status_commands) and bool(fetch_commands),'Actual status and fetch event logs')
for command_file in status_commands+fetch_commands:
    label=command_file.name.removesuffix('.command.json');p=ROOT/'.runs/conv'/label;event=read(command_file)
    check(event['exit_code']==int(p.with_suffix('.exit.txt').read_text()),'Outer exit recorded '+label)
    event.update(stdout_file=relative(p.with_suffix('.stdout.txt')),stderr_file=relative(p.with_suffix('.stderr.txt')),exit_file=relative(p.with_suffix('.exit.txt')));outer.append(event)
check(read(status_commands[-1])['exit_code']==read(fetch_commands[-1])['exit_code']==0,'Final successful status/fetch')

summary=dict(created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),candidate=j['version'],job_id=j['job_id'],scope='Original AX numerical/lifecycle logs only; no acceptance, freeze or performance.',legacy_coverage_rule='Each named legacy helper must be nonzero, exactly as the original AX checker; reported counts are observed values, not expected values.',scheduler=status,wrapper_exit=wrapper,stage_count=len(stages),stages=stages,configurations=configs,total_cases=sum(x['total'] for x in configs),full_cases=sum(x['full_cases'] for x in configs),dispatch_cases=sum(x['dispatch_cases'] for x in configs),direct_cases=sum(x['direct_cases'] for x in configs),actual_compile_argv=argv,compiler_version=compiler,omp=omp,scheduler_resources=resources,requested_resources=j['resources'],allowed_cpus=cpus,numa_node=numa,scheduler_node=scheduler_node,probe_node=probe_node,scheduler_cpu_text=scheduler_cpu_text,scheduler_cpus=scheduler_cpus,source_files=source,source_sha256=hashes['conv2d.c'],raw_files=[dict(path=relative(p),bytes=p.stat().st_size) for p in sorted(RAW.iterdir()) if p.is_file()],outer_events=outer,status_call_count=len(status_commands),status_wait_note='Original1591086 polled at bounded intervals; final actual terminal status required. Earlier query errors, if any, are preserved without classifying the job terminal.',numerical_logs_complete=not issues,issues=issues,accept_executed=False,freeze_executed=False,assembly_review_performed=False,performance_measured=False,new_job_submitted_by_lifecycle_agent=False,reset_card_used=False)
check(summary['total_cases']==80100 and summary['full_cases']==51696 and summary['dispatch_cases']==24516 and summary['direct_cases']==3888,'Actual aggregate counts')
summary['exact_once_cases']=sum(x['exact_once_coverage']['actual_cases'] for x in configs)
summary['exact_once_output_values']=sum(x['exact_once_coverage']['actual_output_values'] for x in configs)
check(summary['exact_once_cases']==28404 and summary['exact_once_output_values']==110027484,'Actual full exactly-once observed coverage aggregate')
summary['numerical_logs_complete']=not issues
with (B/'AX_SUMMARY.json').open('x') as f: json.dump(summary,f,indent=2);f.write('\n')
lines=['# AX 原作业数值与生命周期摘要','',f"候选 {j['version']}，原作业 {j['job_id']}。共查询 {len(status_commands)} 次，末次 status/fetch 均退出0，调度器 {status['status']}，job/system/wrapper = {status['jobExitCode']}/{status['systemExitCode']}/{wrapper}。",'',f"实际 {len(stages)} 个有序阶段退出0；九配置总 {summary['total_cases']} 例，full/dispatch/direct = {summary['full_cases']}/{summary['dispatch_cases']}/{summary['direct_cases']}。issues = {issues}。",'','|SVE字节LOCAL_USER线程|full|dispatch|direct|','LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER']
lines += [f"LOCAL_USER{x['sve_bytes']}LOCAL_USER{x['threads']}LOCAL_USER{x['full_cases']}LOCAL_USER{x['dispatch_cases']}LOCAL_USER{x['direct_cases']}LOCAL_USER" for x in configs]
lines += ['', '每配置3156个dispatch/direct用例全部输出通过predicate-aware SVE store恰写一次检查；共28404个用例、110027484个输出值。写计数观察原predicate活跃lane并执行原svst1_f32；非instrumented fullguard另行保留。', '|SVE字节LOCAL_USER线程|Dispatch入口|Direct入口LOCAL_USER恰写一次用例LOCAL_USER输出值LOCAL_USER', 'LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER']
lines += ['LOCAL_USER'+str(x['sve_bytes'])+'LOCAL_USER'+str(x['threads'])+'LOCAL_USER'+str(x['rowseven_entries']['dispatch']['actual'])+'LOCAL_USER'+str(x['rowseven_entries']['direct']['actual'])+'LOCAL_USER'+str(x['exact_once_coverage']['actual_cases'])+'LOCAL_USER'+str(x['exact_once_coverage']['actual_output_values'])+'LOCAL_USER' for x in configs]
lines += ['', '旧fallback计数仅按原AX checker要求五类均非零；以下为实际观测，不是预期值。没有沿用AP或其他轮次观测作为固定预期。', '|SVE字节LOCAL_USER线程|PREFIX|TAIL|ROWPAIR|ROWTRIPLE|ROWQUAD|', 'LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER']
lines += ['LOCAL_USER'+str(x['sve_bytes'])+'LOCAL_USER'+str(x['threads'])+'LOCAL_USER'+'LOCAL_USER'.join(str(x['legacy_suite_entries'][k]) for k in ['PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'])+'LOCAL_USER' for x in configs]
lines += ['',f'实际 GCC {compiler}，三条完整 gcc argv 来自 probe.log 的 xtrace，strict/generic/关闭FP融合；38CPU、24576MiB、单packed NUMA、1800秒，允许CPU {cpus[0]}–{cpus[-1]}，{numa}。九配置实际线程1/4/38，close/cores绑定。','', '五份运输源的返回字节、远端manifest、原件、prepared/job与本地清单一致。未运行sanitizer或官方runner；汇编原件已返回，目标spill分析由独立审查者处理。此摘要不执行接受/归档，不填性能或提速。','', '原始日志在 raw/；完整逐配置、source关联、资源及所有status/fetch外层argv/UTC/输出路径见 AX_SUMMARY.json。用户已取消40%停止阈值；未使用reset。此子任务只读取日志，不执行本机题目或提交新作业。']
with (B/'AX_SUMMARY.md').open('x') as f:f.write('\n'.join(lines)+'\n')
print(json.dumps(dict(job_id=j['job_id'],total_cases=summary['total_cases'],stages=len(stages),issues=issues),indent=2))
