"""Verify one exact C58 ZIP only after real AI and AK success. No auto promotion."""
import argparse
from pathlib import Path
import datetime,json,shlex,subprocess,sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import experiment as e
import cluster as c
SOURCE='C58-row7boundaryu2'
CONFIRMATION='C58-r1'
VERSION='C58-package'

def need(ok,why):
    if not ok:raise ValueError(why)

def preflight():
    initial=e.read_json(ROOT/'.runs/conv/sep13ai-campaign.json')
    confirm=e.read_json(ROOT/'.runs/conv/sep13ak-campaign.json')
    need(initial['performance_job']=='1583408','Original AI identity')
    need(initial['status']==confirm['status']=='performance_complete','Both real measurements complete')
    need(confirm['confirmation_only'] is True and confirm['confirmation_passed'] is True,'Original AK must pass; never retry through packaging')
    need(initial['performance_job']!=confirm['performance_job'],'Independent confirmation job')
    current=e.source_files(ROOT/'conv')
    need(e.read_json(ROOT/'outputs/conv-best.json')['label']=='C6','Unexpected current best')
    need(e.read_json(ROOT/'records/best.json')['conv']=='C26-r1','Unexpected best measurement')
    need(current==e.get_record('conv','C26-r1')['source_hashes'],'Current baseline source')
    source=e.source_files(ROOT/'.runs/conv'/SOURCE/'source')
    need(source==e.source_files(ROOT/'.runs/conv'/CONFIRMATION/'source'),'Confirmation must use identical source')
    need(source['conv2d.c']=='c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751','C58 identity')
    for plan,order,candidate in [(initial,['C26-r36',SOURCE,'C26-r37'],SOURCE),(confirm,['C26-r38',CONFIRMATION,'C26-r39'],CONFIRMATION)]:
        need(plan['measurement_order']==order and plan['expected_benchmark_cases']==36,'Complete fixed36 round')
        records=[e.get_record('conv',n) for n in order]
        need(all(r['status']=='passed' and r['verified'] is True and r['repeats']==3 and all(r['checks'].values()) for r in records),'Fully verified original records')
        need(sum(len(case['times_ms']) for r in records for case in r['cases'])==36,'No missing samples')
        need(all(r['settings']==plan['settings'] and r['job_id']==plan['performance_job'] and r['machine']==records[0]['machine'] for r in records),'Same job/settings/machine within each round')
        need(records[0]['source_hashes']==records[-1]['source_hashes']==current,'Both C6 controls')
        rec=records[1];need(rec['version']==candidate and rec['source_hashes']==source,'Candidate association')
        for base,field in [(records[0],'opening_control_comparison'),(records[-1],'comparison')]:
            need(rec[field]['baseline']==base['version'] and rec[field]['eligible'] is True and e.comparison(base,rec)['eligible'] is True,'Both unchanged gates must pass')
        if candidate==SOURCE:need(rec['qualified_for_confirmation'] is True,'Initial qualification')
        else:need(rec['confirmation_passed'] is True,'Confirmation result')
    need(initial['settings']==confirm['settings'],'Same initial/confirmation settings')
    cfg=c.load_config(ROOT/'config/conv-sep12.local.json')
    need(c.effective_settings(cfg,{'settings':confirm['settings']})==confirm['settings'],'Package environment differs')
    return initial,confirm,source,cfg

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--go',action='store_true');args=parser.parse_args()
    need(args.go,'Explicit root GO required')
    run=ROOT/'.runs/conv'/VERSION
    need(not run.exists() and not e.record_path('conv',VERSION).exists(),'Existing package reservation: reconcile, never replace/retry')
    initial,confirm,source,cfg=preflight()
    for reservation in ['.runs/conv/sep13aj-checks/C59-row7boundaryu2nofive/job.json','.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json']:
        need(not (ROOT/reservation).exists(),'Another diagnostic has a reservation; root must reconcile it first')
    job=str(confirm['performance_job']);need(job.isdigit(),'Actual confirmation ID')
    command=shlex.join(x.replace('{job_id}',job) for x in cfg['scheduler']['status_argv'])
    gate_path=ROOT/'.runs/conv'/('sep13al-terminal-gate-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')+'.json')
    try:
        result=c.remote(cfg,command,timeout=min(45,cfg['command_timeout']))
        text=c.output_text(result);status=c.parse_scheduler_status(text,job) if result.returncode==0 else None
        e.write_json(gate_path,dict(job_id=job,command=command,query_exit=result.returncode,raw_status=text,scheduler=status))
    except (subprocess.TimeoutExpired,OSError,c.ClusterError) as exc:
        def decode(value):return value.decode('utf-8',errors='replace') if isinstance(value,bytes) else str(value or '')
        e.write_json(gate_path,dict(job_id=job,command=command,query_exit=None,error_type=type(exc).__name__,error=str(exc),stdout=decode(getattr(exc,'stdout',None)),stderr=decode(getattr(exc,'stderr',None))))
        raise
    need(status and status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Latest AK live terminal status required')
    with e.locked():
        need(not run.exists() and not e.record_path('conv',VERSION).exists(),'Concurrent package reservation')
        e.new(argparse.Namespace(problem='conv',version=VERSION,parent=CONFIRMATION,strategy='Exact original ZIP correctness verification after AI initial and independent AK confirmation; no automatic promotion'))
        meta=e.read_json(run/'experiment.json')
        (run/'creation-experiment.json').write_bytes((run/'experiment.json').read_bytes())
        meta.update(settings=confirm['settings'],source_parent=CONFIRMATION,source_origin=SOURCE,reference_only=True,promotion_allowed=False,package_validation_only=True,initial_performance_job='1583408',package_confirmation_job=job,diagnostic_job_id='1583350',expected_benchmark_cases=12,automatic_promotion=False)
        e.write_json(run/'experiment.json',meta)
        e.checkpoint(argparse.Namespace(problem='conv',version=VERSION,note='Only this exact ZIP: three full official suites on allocated compute. InitialAI and independentAK pass both C6 gates. Package-only; no local operator or auto promotion.'))
        need(e.source_files(run/'source')==source,'Package source differs')
        (run/'pre-package-scheduler.log').write_text(text)
        e.write_json(run/'package-gates.json',dict(initial_job='1583408',confirmation_job=job,confirmation_passed=True,source_version=SOURCE,source_hashes=source,best_retained='C6',package_only=True))
    argv=[sys.executable,'-B',str(ROOT/'.runs/conv/sep12-submit-package.py'),str(run)]
    e.write_json(run/'package-submit-command.json',dict(argv=argv,started_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),automatic_retry=False))
    with (run/'package-submit.stdout.log').open('x') as out,(run/'package-submit.stderr.log').open('x') as err:r=subprocess.run(argv,cwd=ROOT,stdout=out,stderr=err)
    e.write_json(run/'package-submit-exit.json',dict(argv=argv,exit_code=r.returncode,automatic_retry=False))
    need(r.returncode==0,'Package submission uncertain/failed; preserve original reservation')
    manifest=e.read_json(run/'cluster.json');need(manifest['source_hashes']==source and manifest['settings']==confirm['settings'],'Actual package association')
    need(str(manifest['job_id']) not in ['1583408','1583350',job],'Independent package job')
    print(json.dumps(dict(package=VERSION,job_id=manifest['job_id'],validation_pending=True,automatic_promotion=False)))
if __name__=='__main__':main()
