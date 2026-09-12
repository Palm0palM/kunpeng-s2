"""Archive accepted local evidence only. Never compiles or runs operator code."""
import hashlib
import json
import shutil
import sys
from pathlib import Path

base = Path(__file__).resolve().parent
version = sys.argv[1]
assert version in ('C37-row4u1', 'C38-splitbuild', 'C39-tunehip11')
source = base / version
validation = json.loads((source / 'validation.json').read_text())
assert validation['complete'] is True and validation['status'] == 'passed'
target = base.parent / version / 'sve-correctness-sep12f'
assert not target.exists(), 'Refusing to overwrite frozen evidence'
final_target = target
target = target.with_name('.sve-correctness-sep12f.preparing')
assert not target.exists(), 'Refusing to overwrite an interrupted archive'
shutil.copytree(source, target)
for name in ('README.md', 'driver.py', 'accept_returned.py', 'accept_runner_returned.py', 'freeze_returned.py'):
    shutil.copy2(base / name, target / ('diagnostic-' + name))
assembly = target / 'raw' / 'conv2d-sve.s'
public = assembly.with_suffix('.assembly.txt')
assert not public.exists()
shutil.copy2(assembly, public)
digest = hashlib.sha256(assembly.read_bytes()).hexdigest()
(target / 'assembly-source.json').write_text(json.dumps(dict(
    source='raw/conv2d-sve.s', public_copy='raw/conv2d-sve.assembly.txt',
    source_sha256=digest, public_sha256=digest, byte_identical=True,
    note='New same-byte text export beside original compiler assembly; original evidence unchanged.'), indent=2)+'\n')
target.rename(final_target)
print(str(final_target))
