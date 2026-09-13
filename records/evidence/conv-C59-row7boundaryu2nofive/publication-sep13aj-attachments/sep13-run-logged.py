"""Lightweight local command evidence wrapper; never pass authentication secrets."""
import subprocess,sys,json,datetime
from pathlib import Path
label=sys.argv[1];argv=sys.argv[2:]
assert label.replace('-','').isalnum() and argv
root=Path(__file__).resolve().parents[2];base=root/'.runs/conv'/label
command=base.with_suffix('.command.json')
data=dict(argv=argv,started_at=datetime.datetime.now(datetime.timezone.utc).isoformat())
with command.open('x') as f:json.dump(data,f,indent=2)
with base.with_suffix('.stdout.txt').open('x') as out,base.with_suffix('.stderr.txt').open('x') as err:
 result=subprocess.run(argv,cwd=root,stdout=out,stderr=err)
data.update(ended_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),exit_code=result.returncode)
command.write_text(json.dumps(data,indent=2)+'\n');base.with_suffix('.exit.txt').write_text(str(result.returncode)+'\n')
print(label,'exit',result.returncode)
print(base.with_suffix('.stdout.txt').read_text()[-1600:])
print(base.with_suffix('.stderr.txt').read_text()[-1600:])
sys.exit(result.returncode)
