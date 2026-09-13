"""Verify one exact C65 ZIP only after real AY and AZ success. No auto promotion."""
import argparse
from pathlib import Path
import datetime,json,shlex,subprocess,sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import experiment as e
import cluster as c
SOURCE='C65-row7balanced'
CONFIRMATION='C65-r1'
VERSION='C65-package'

def need(ok,why):
    if not ok:raise ValueError(why)

def preflight():
    initial=e.read_json(ROOT/'.runs/conv/sep13ay-campaign.json')
    confirm=e.read_json(ROOT/'.runs/conv/sep13az-campaign.json')
    need(initial['performance_job']=='1591187' and confirm['performance_job']=='1591241','Original AY/AZ identities')
    need(initial['status']==confirm['status']=='complete','Both real measurements complete')
    need(confirm['confirmation_only'] is True and confirm['confirmation_passed'] is True,'Original AZ must pass; never retry through packaging')
    need(initial['performance_job']!=confirm['performance_job'],'Independent confirmation job')
    current=e.source_files(ROOT/'conv')
    need(e.read_json(ROOT/'outputs/conv-best.json')['label']=='C7','Unexpected current best')
    need(e.read_json(ROOT/'records/best.json')['conv']=='C58-r1','Unexpected best measurement')
    parent=e.get_record('conv','C58-r1')
    need(parent['verified'] and parent['confirmation_passed'] and current==parent['source_hashes']==e.source_files(ROOT/'.runs/conv/C58-r1/source'),'Confirmed current C7 source')
    source=e.source_files(ROOT/'.runs/conv'/SOURCE/'source')
    need(source==e.source_files(ROOT/'.runs/conv'/CONFIRMATION/'source'),'Confirmation must use identical source')
    need(all(source[k]==v for k,v in current.items() if k!='conv2d.c'),'Official companion bytes unchanged')
    need(source['conv2d.c']=='a855c14b81c00f3d398ac36c5ece6726e15235f18ebf3fe4746570da25a7f874','C65 identity')
    for plan,order,candidate in [(initial,['C58-r14',SOURCE,'C58-r15'],SOURCE),(confirm,['C58-r16',CONFIRMATION,'C58-r17'],CONFIRMATION)]:
        need(plan['measurement_order']==order and plan['expected_benchmark_cases']==36,'Complete fixed36 round')
        records=[e.get_record('conv',n) for n in order]
        need(all(r['status']=='passed' and r['verified'] is True and r['repeats']==3 and all(r['checks'].values()) for r in records),'Fully verified original records')
        need(all(len(r['cases'])==4 and all(len(case['times_ms'])==3 and case['max_error']==0 for case in r['cases']) for r in records),'Each original12 PASS/error zero')
        need(all(r['settings']==plan['settings'] and r['job_id']==plan['performance_job'] and r['machine']==records[0]['machine'] for r in records),'Same job/settings/machine within each round')
        need(records[0]['source_hashes']==records[-1]['source_hashes']==plan['baseline_source']==current,'Both C7 controls')
        need(plan['results']==[dict(version=r['version'],total_median_ms=r['total_median_ms'],cases=r['cases']) for r in records],'All original campaign samples')
        for index,(name,r) in enumerate(zip(order,records)):
            folder=ROOT/'.runs/conv'/name;m=e.read_json(folder/'cluster.json');status=m['scheduler_status']
            need(m['job_id']==str(status['jobId'])==plan['performance_job'] and status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Original terminal job/exits')
            need(m['group']==plan['performance_group'] and m['group_index']==index and m['measurement_order']==order,'Original ordered same-group allocation')
            need(m['settings']==r['settings'] and m['source_hashes']==r['source_hashes']==e.source_files(folder/'source'),'Submitted source/settings')
            need((folder/'exit-code.txt').read_text().strip()=='0','Original wrapper exit0')
            need(all(e.digest(folder/f)==m['artifacts_sha256'][f] for f in ['benchmark.log','environment.log','exit-code.txt','source-sha256.txt']),'Original fetched artifacts')
            raw=(folder/'benchmark.log').read_text();parsed=e.parse_log('conv',raw,3)
            need(parsed['cases']==r['cases'] and parsed['total_median_ms']==r['total_median_ms'] and e.machine_profile(folder,raw)==r['machine'],'Original samples/derived medians/machine')
        machine=records[0]['machine']
        need(machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64' and machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic' and len(set(machine['ALLOWED_CPUS'].split(',')))==38 and machine['NUMA_NODE'],'Actual GCC/allocation')
        rec=records[1];need(rec['version']==candidate and rec['source_hashes']==source,'Candidate association')
        for base,field in [(records[0],'opening_control_comparison'),(records[-1],'comparison')]:
            verdict=dict(e.comparison(base,rec),baseline=base['version'])
            need(rec[field]==plan[field]==verdict and verdict['eligible'] is True,'Both original comparisons recomputed unchanged')
        if candidate==SOURCE:need(rec['qualified_for_confirmation'] is True,'Initial qualification')
        else:need(rec['confirmation_passed'] is True,'Confirmation result')
    need(initial['settings']==confirm['settings']==parent['settings'],'Same initial/confirmation/C7 settings')
    need(confirm['initial_qualification_job']=='1591187' and confirm['candidate_source_hashes']==source,'AZ confirms original AY source')
    settings=confirm['settings'];need(settings['bench_repeats']==3 and all(settings['scheduler_resources'].get(k)==v for k,v in dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800).items()),'Exact package resources/three suites')
    diag=ROOT/'.runs/conv'/SOURCE/'sve-correctness-sep13ax';val=e.read_json(diag/'validation.json');dj=e.read_json(diag/'job.json')
    need(val['status']=='passed' and val['complete'] and val['total_cases']==80100 and val['candidate']==SOURCE,'Own complete AX80100')
    need(val['job_id']==dj['job_id']=='1591086' and dj['scheduler_status']['status']=='SUCCEEDED' and dj['scheduler_status']['jobExitCode']==dj['scheduler_status']['systemExitCode']==0,'Original AX successful exits')
    need(val['source_hashes']['conv2d.c']==source['conv2d.c'],'AX/AY/AZ same source')
    need((diag/'TARGETED_ASSEMBLY_REVIEW.md').is_file() and (diag/'ROOT_RETURNED_REVIEW.md').is_file(),'Own actual assembly reviewed')
    cfg=c.load_config(ROOT/'config/conv-sep12.local.json')
    need(c.effective_settings(cfg,{'settings':confirm['settings']})==confirm['settings'],'Package environment differs')
    return initial,confirm,source,cfg

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--go',action='store_true');args=parser.parse_args()
    need(args.go,'Explicit root GO required')
    run=ROOT/'.runs/conv'/VERSION
    need(not run.exists() and not e.record_path('conv',VERSION).exists(),'Existing package reservation: reconcile, never replace/retry')
    initial,confirm,source,cfg=preflight()
    job=str(confirm['performance_job']);need(job.isdigit(),'Actual confirmation ID')
    command=shlex.join(x.replace('{job_id}',job) for x in cfg['scheduler']['status_argv'])
    gate_path=ROOT/'.runs/conv'/('sep13ba-terminal-gate-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')+'.json')
    try:
        result=c.remote(cfg,command,timeout=min(45,cfg['command_timeout']))
        text=c.output_text(result);status=c.parse_scheduler_status(text,job) if result.returncode==0 else None
        e.write_json(gate_path,dict(job_id=job,command=command,query_exit=result.returncode,raw_status=text,scheduler=status))
    except (subprocess.TimeoutExpired,OSError,c.ClusterError) as exc:
        def decode(value):return value.decode('utf-8',errors='replace') if isinstance(value,bytes) else str(value or '')
        e.write_json(gate_path,dict(job_id=job,command=command,query_exit=None,error_type=type(exc).__name__,error=str(exc),stdout=decode(getattr(exc,'stdout',None)),stderr=decode(getattr(exc,'stderr',None))))
        raise
    need(status and str(status.get('jobId'))==job and status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Latest AZ live terminal status required')
    with e.locked():
        need(not run.exists() and not e.record_path('conv',VERSION).exists(),'Concurrent package reservation')
        need(preflight()[2]==source,'Revalidate source/qualification before reservation')
        e.new(argparse.Namespace(problem='conv',version=VERSION,parent=CONFIRMATION,strategy='Exact original ZIP correctness verification after AY initial and independent AZ confirmation; no automatic promotion'))
        meta=e.read_json(run/'experiment.json')
        (run/'creation-experiment.json').write_bytes((run/'experiment.json').read_bytes())
        meta.update(settings=confirm['settings'],source_parent=CONFIRMATION,source_origin=SOURCE,reference_only=True,promotion_allowed=False,package_validation_only=True,initial_performance_job='1591187',package_confirmation_job=job,diagnostic_job_id='1591086',expected_benchmark_cases=12,automatic_promotion=False,automatic_retry=False)
        e.write_json(run/'experiment.json',meta)
        e.checkpoint(argparse.Namespace(problem='conv',version=VERSION,note='Only this exact ZIP: three full official suites on allocated compute. InitialAY and independentAZ pass both C7 gates. Package-only; no local operator or auto promotion.'))
        need(e.source_files(run/'source')==source,'Package source differs')
        (run/'pre-package-scheduler.log').write_text(text)
        e.write_json(run/'package-gates.json',dict(initial_job='1591187',confirmation_job=job,confirmation_passed=True,source_version=SOURCE,source_hashes=source,best_retained='C7',package_only=True))
    argv=[sys.executable,'-B',str(ROOT/'.runs/conv/sep12-submit-package.py'),str(run)]
    e.write_json(run/'package-submit-command.json',dict(argv=argv,started_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),automatic_retry=False))
    with (run/'package-submit.stdout.log').open('x') as out,(run/'package-submit.stderr.log').open('x') as err:r=subprocess.run(argv,cwd=ROOT,stdout=out,stderr=err)
    e.write_json(run/'package-submit-exit.json',dict(argv=argv,exit_code=r.returncode,automatic_retry=False))
    need(r.returncode==0,'Package submission uncertain/failed; preserve original reservation')
    manifest=e.read_json(run/'cluster.json');need(manifest['source_hashes']==source and manifest['settings']==confirm['settings'],'Actual package association')
    need(str(manifest['job_id']) not in ['1591187','1591086',job],'Independent package job')
    print(json.dumps(dict(package=VERSION,job_id=manifest['job_id'],validation_pending=True,automatic_promotion=False)))
if __name__=='__main__':main()
