import json,re
from pathlib import Path
b=Path('.')
d=json.loads((b/'profile-status.json').read_text())
bench=(b/'benchmark.log').read_text()
d['benchmark_passes']=len(re.findall(r'^.*\bPASS\s*$',bench,re.M))
d['benchmark_failures']=len(re.findall(r'^.*\bFAIL\s*$',bench,re.M))
d['benchmark_numeric_pass']=d['benchmark_passes']==1 and d['benchmark_failures']==0
exits={name:int((b/(name+'.exit.txt')).read_text()) for name in ('record','report-all','report-quad','annotate','objdump') if (b/(name+'.exit.txt')).exists()}
d['tool_exit_codes']=exits
text=(b/'symbols.report.txt').read_text() if (b/'symbols.report.txt').exists() else ''
counts=re.findall(r'^\s*[0-9]+(?:\.[0-9]+)?%\s+([0-9,]+)\s+.*?\[.\]\s+conv_sve_rowquad\s*$',text,re.M)
d['quad_samples']=sum(int(x.replace(',','')) for x in counts) if counts else None
d['sample_threshold_for_region_review']=1000
warnings=[]
for p in (b/'record.log',b/'report-all.stderr.log',b/'report-quad.stderr.log',b/'annotate.stderr.log'):
    if p.exists():
        warnings.extend(line for line in p.read_text().splitlines() if re.search(r'lost|throttl|warning|error',line,re.I))
d['sampling_warnings']=warnings
asm=(b/'quad.disassembly.txt').read_text() if (b/'quad.disassembly.txt').exists() else ''
d['undecoded_instruction_present']=bool(re.search(r'\.inst|<unknown>',asm,re.I))
if not d['benchmark_numeric_pass']:
    d.update(status='failed',reason='Official benchmark did not report exactly one PASS and zero FAIL.')
elif any(exits.get(k)!=0 for k in ('record','report-all','report-quad','annotate','objdump')):
    d.update(status='inconclusive',reason='Collection or symbol/annotation tool failed; inspect retained logs.')
elif d['quad_samples'] is None or d['quad_samples']<1000 or d['undecoded_instruction_present']:
    d.update(status='inconclusive',reason='Insufficient attributable quad samples, unparsed sample count, or incomplete disassembly.')
else:
    d.update(status='ready_for_review',reason='Attributable quad IP samples collected; manually review annotations, sample loss/skid and denominator before drawing conclusions.')
d['complete']=False
d['manual_review_required']=True
(b/'profile-status.json').write_text(json.dumps(d,indent=2)+'\n')
print(json.dumps(d,indent=2))
