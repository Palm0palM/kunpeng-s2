#!/usr/bin/env python3
"""Download this known job's logs and register them without any digest checks."""
from pathlib import Path
import json,shlex,subprocess,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
cfg=cluster.load_config(HERE/'cluster.local.json')
g=cluster.read_json(HERE/'cohort-submission.json')
names=list(cluster.read_json(HERE/'cohort-config.json')['members'])
commands=[]
status=cluster.remote(cfg,'djob -ll '+g['job_id'])
(HERE/'scheduler-status.txt').write_bytes(status.stdout+status.stderr)
if status.returncode:raise SystemExit('Scheduler query failed')
sys.path.insert(0,str(ROOT/'tools'))
import experiment
if not experiment.scheduler_ok(cluster.output_text(status)):raise SystemExit('Job is not successfully complete; no results registered')
for name in names:
    folder=ROOT/'.runs/trsm'/name
    (folder/'scheduler-status.txt').write_bytes(status.stdout+status.stderr)
    for artifact in ['benchmark.log','environment.log','exit-code.txt','wrapper.stdout.log']:
        r=cluster.remote(cfg,'cat '+shlex.quote(g['remote_dir']+'/'+name+'/'+artifact))
        if r.returncode:raise SystemExit('Download failed: '+name+'/'+artifact)
        (folder/artifact).write_bytes(r.stdout)
    print('Downloaded raw log files for',name,flush=True)
for remote,local in [('preflight.log','preflight.log'),('wrapper.stdout.log','cohort.stdout.log'),('preflight/environment-probe.log','reference-environment.log'),('preflight/trsm-24rows.s','trsm-24rows.s'),('preflight/trsm-diagpanel.s','trsm-diagpanel.s')]:
    r=cluster.remote(cfg,'cat '+shlex.quote(g['remote_dir']+'/'+remote))
    if r.returncode:raise SystemExit('Download failed: '+remote)
    (HERE/local).write_bytes(r.stdout)
profile=(ROOT/'.runs/trsm'/names[0]/'environment.log').read_text()
fields={l.split('=',1)[0]:l.split('=',1)[1] for l in profile.splitlines() if '=' in l and not l.startswith(' ')}
env=fields['HOST']+'-numa'+fields['NUMA_NODE']+'-compiler-recorded-generic38-openblas028-test3-job'+g['job_id']
probe=(HERE/'reference-environment.log').read_text()
kml_link=next((line for line in probe.splitlines() if line.startswith('OFFICIAL_HEADER_AND_LINK_EXIT=')), 'OFFICIAL_HEADER_AND_LINK_EXIT=unknown')
ref='OpenBLAS 0.3.28 static USE_OPENMP ARMV8 MAX_THREADS=38; '+kml_link+'; this benchmark used OpenBLAS, not official KML revalidation'
if not (ROOT/'.runs/trsm/nohash-tools/records.py').is_file():
    for name in names:
        parsed=experiment.parse_log('trsm',(ROOT/'.runs/trsm'/name/'benchmark.log').read_text(),3)
        print(name,parsed['total_median_ms'],[(c['dims'],c['median_ms'],c['spread_pct']) for c in parsed['cases']])
    raise SystemExit(0)
for name in names:
    argv=[sys.executable,str(ROOT/'.runs/trsm/nohash-tools/records.py'),'record',str(ROOT/'.runs/trsm'/name),'--environment',env,'--reference',ref]
    p=subprocess.run(argv,cwd=ROOT,capture_output=True,text=True)
    (HERE/(name+'-record.log')).write_text(p.stdout+p.stderr)
    commands.append({'argv':argv,'exit_code':p.returncode,'output':p.stdout+p.stderr})
    print(p.stdout+p.stderr,flush=True)
    if p.returncode:raise SystemExit(p.returncode)
for name in names[1:]:
    argv=[sys.executable,str(ROOT/'.runs/trsm/nohash-tools/records.py'),'compare',names[0],name]
    p=subprocess.run(argv,cwd=ROOT,capture_output=True,text=True)
    (HERE/(names[0]+'-vs-'+name+'.json')).write_text(p.stdout)
    commands.append({'argv':argv,'exit_code':p.returncode,'output':p.stdout+p.stderr})
    print(p.stdout+p.stderr,flush=True)
(HERE/'record-compare-commands.json').write_text(json.dumps(commands,ensure_ascii=False,indent=2)+'\n')
