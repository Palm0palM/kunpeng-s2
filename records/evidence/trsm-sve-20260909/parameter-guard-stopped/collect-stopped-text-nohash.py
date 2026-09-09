#!/usr/bin/env python3
"""Read only job 1492058 and its text artifacts over existing SSH; no hashes."""
import io
import json
from pathlib import Path, PurePosixPath
import shlex
import sys
import tarfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster

group=json.loads((HERE/'cohort-submission.json').read_text())
if group['job_id']!='1492058':
    raise SystemExit('This collector is restricted to stopped job 1492058')
cfg=cluster.load_config(ROOT/'config/cluster.local.json')
commands=[]

def remote(command,label):
    result=cluster.remote(cfg,command,timeout=60)
    commands.append({'command':command,'returncode':result.returncode,
                     'retrieved_at':cluster.now(),'label':label})
    (HERE/'text-collection-commands.json').write_text(json.dumps(commands,indent=2)+'\n')
    (HERE/(label+'.stderr.log')).write_bytes(result.stderr)
    if result.returncode:
        raise SystemExit('Remote read failed: '+label+' exit '+str(result.returncode))
    return result.stdout

command=shlex.join([x.replace('{job_id}',group['job_id']) for x in cfg['scheduler']['status_argv']])
raw=remote(command,'scheduler-status')
previous=HERE/'scheduler-status.txt'
if previous.exists() and not (HERE/'scheduler-status-initial-sandbox-denied.txt').exists():
    (HERE/'scheduler-status-initial-sandbox-denied.txt').write_bytes(previous.read_bytes())
previous.write_bytes(raw)
status=cluster.parse_scheduler_status(raw.decode('utf-8','replace'),group['job_id'])
(HERE/'scheduler-status-parsed.json').write_text(json.dumps(status,indent=2)+'\n')
script='import json; from pathlib import Path; p=Path('+repr(group['remote_dir'])+'); names=["wrapper.stdout.log","preflight.log"]; names += [str(f.relative_to(p)) for f in (p/"preflight").rglob("*") if f.is_file() and not f.is_symlink() and f.suffix in {".c",".h",".s",".sh",".log",".txt",".md",".json",".py"}]; print(json.dumps(sorted(names)))'
raw=remote(shlex.join(['python3','-c',script]),'text-inventory')
(HERE/'remote-text-inventory.json').write_bytes(raw)
names=json.loads(raw)
for name in names:
    parts=PurePosixPath(name).parts
    if name.startswith('/') or '..' in parts:
        raise SystemExit('Unsafe remote path')
command='cd '+shlex.quote(group['remote_dir'])+' && '+shlex.join(['tar','-czf','-','--']+names)
raw=remote(command,'text-download')
destination=HERE/'retrieved-text'
destination.mkdir(exist_ok=True)
with tarfile.open(fileobj=io.BytesIO(raw),mode='r:gz') as archive:
    for member in archive:
        if not member.isfile() or member.name not in names:
            raise SystemExit('Unexpected archive member: '+member.name)
        content=archive.extractfile(member).read()
        content.decode('utf-8')
        if b'\0' in content:
            raise SystemExit('Non-text content rejected: '+member.name)
        target=destination/member.name
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_bytes(content)
print('Job status:',json.dumps(status))
print('Text files retrieved:',len(names))
print('No hash calculation or verification was performed.')
