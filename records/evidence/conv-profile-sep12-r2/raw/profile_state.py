import json,sys
from pathlib import Path
status,reason=sys.argv[1:3]
Path('profile-status.json').write_text(json.dumps(dict(status=status,reason=reason,complete=False,profile_is_benchmark=False,source_version='C26-r1',formal_version='C6',event='cycles:u',frequency_hz=99,case=[6390,4256,81,81,1],scope='All conv invocations in this official case, including validation/warmup/timed call; sampled IPs filtered to quad, not whole-process CPI.'),indent=2)+'\n')
