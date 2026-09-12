#!/usr/bin/env python3
"""Read-only progress/assembly collection for the known TRSM cohort."""
from pathlib import Path
import json
import re
import shlex
import sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
cfg=cluster.load_config(HERE/'cluster.local.json')
group=json.loads((HERE/'cohort-submission.json').read_text())
assert group['state'] in ('submitted','collected') and re.fullmatch(r'\d+',group['job_id'])
program='''from pathlib import Path
import sys
root=Path(sys.argv[1])
for p in sorted(root.glob("preflight-panel8x16-results/*/summary.tsv")):
    print(str(p.relative_to(root)),p.read_text()[-180:])
for p in sorted(root.glob("*/benchmark.log")):
    text=p.read_text()
    print(str(p.relative_to(root)),"completed suites",text.count(" END"),text[-400:])
print("COHORT_TAIL",(root/"wrapper.stdout.log").read_text()[-250:])
'''
result=cluster.remote(cfg,shlex.join(['python3','-c',program,group['remote_dir']]))
(HERE/'progress-latest.log').write_text(cluster.output_text(result))
print(cluster.output_text(result))
if result.returncode:raise SystemExit(result.returncode)
if sys.argv[1:]==['assembly']:
    for name in json.loads((HERE/'cohort-config.json').read_text())['members']:
        assert re.fullmatch(r'[A-Za-z0-9_-]+',name)
        remote=group['remote_dir']+'/preflight-panel8x16-results/'+name+'/trsm-panel8x16.s'
        result=cluster.remote(cfg,shlex.join(['cat',remote]))
        if result.returncode:print(name,'assembly pending')
        else:
            (HERE/('target-assembly-preview-'+name+'.s')).write_bytes(result.stdout)
            print(name,'assembly available',len(result.stdout),'bytes')
