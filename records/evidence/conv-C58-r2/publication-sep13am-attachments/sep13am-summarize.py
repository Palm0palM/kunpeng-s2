"""Summarize already-recorded original AM logs; no operator/network execution."""
from pathlib import Path
import datetime,json,re
R=Path(__file__).resolve().parents[2]
def read(p):return json.loads(p.read_text())
p=read(R/'.runs/conv/sep13am-campaign.json');order=p['measurement_order']
assert p['performance_job']=='1589364' and p['status']=='complete'
records=[read(R/'records/experiments/conv'/f'{n}.json') for n in order]
rows=[]
for n,r in zip(order,records):
 run=R/'.runs/conv'/n;m=read(run/'cluster.json');s=m['scheduler_status'];raw=(run/'scheduler-status.txt').read_text()
 resource={k:int(re.findall(r'^\s*'+k+r'\s+(\d+)\s*$',raw,re.M)[0]) for k in ('reqCPU','reqMem','allocCPU','allocMem','timeout')}
 resource['reqAffinity']=re.findall(r'^\s*reqAffinity\s+(numa\[.+\])\s*$',raw,re.M)[0]
 assert r['job_id']==m['job_id']==s['jobId']=='1589364' and s['status']=='SUCCEEDED' and s['jobExitCode']==s['systemExitCode']==0
 assert r['status']=='passed' and r['verified'] and all(r['checks'].values()) and r['repeats']==3
 assert (run/'exit-code.txt').read_text().strip()=='0' and len(r['cases'])==4 and all(len(x['times_ms'])==3 and x['max_error']==0 for x in r['cases'])
 rows.append(dict(version=n,total_median_ms=r['total_median_ms'],cases=r['cases'],checks=r['checks'],scheduler=s,wrapper_exit=0,scheduler_resources=resource,settings=r['settings'],machine=r['machine']))
c=records[1];assert c['qualified_for_confirmation'] is False and p['confirmation_pending']==[]
events=[read(x) for x in sorted((R/'.runs/conv').glob('sep13am-agent-status-*.command.json'))]
events.append(read(R/'.runs/conv/sep13am-agent-record-compare-001.command.json'))
assert all(x['exit_code']==0 for x in events)
intervals=[(datetime.datetime.fromisoformat(b['started_at'])-datetime.datetime.fromisoformat(a['started_at'])).total_seconds() for a,b in zip(events[:3],events[1:4])]
assert all(x>=45 for x in intervals)
summary=dict(created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),job_id=p['performance_job'],measurement_order=order,total_samples=36,results=rows,qualified_for_confirmation=c['qualified_for_confirmation'],closing_comparison=c['comparison'],opening_comparison=c['opening_control_comparison'],confirmation_pending=p['confirmation_pending'],current_best='C7',decision='Retain C7: C59 does not pass either initial performance gate.',outer_events=events,status_intervals_seconds=intervals,record_compare_exit=0,issues=[],local_operator_execution=False,confirmation_run=False,promotion_performed=False,packaging_performed=False,reset_card_used=False)
with (R/'.runs/conv/sep13am-lifecycle-summary.json').open('x') as f:json.dump(summary,f,indent=2);f.write('\n')
lines=['# AM 原作业1589364结果','', 'C59 两端比较均未通过，qualified_for_confirmation=false；保留C7，不启动确认或打包。', '', '三版本同一组原作业，36/36 PASS、最大误差0，scheduler/job/system及三个wrapper均成功退出0。GCC10.3.1、aarch64、38CPU、24576MiB、单packed NUMA3、CPU114–151、1800秒，generic及既定OpenMP绑定。', '', 'LOCAL_USER版本|A原3样本 ms|B原3样本 ms|C原3样本 ms|D原3样本 ms|中位数合计 ms|','LOCAL_USER---LOCAL_USER---LOCAL_USER---LOCAL_USER---LOCAL_USER---LOCAL_USER---:LOCAL_USER']
for r in records:lines.append('LOCAL_USER'+r['version']+'LOCAL_USER'+'LOCAL_USER'.join(', '.join(f'{v:.2f}' for v in x['times_ms']) for x in r['cases'])+'LOCAL_USER'+f"{r['total_median_ms']:.2f}"+'LOCAL_USER')
lines += ['', 'C59合计437.94ms，相对开端437.58ms和结束437.66ms分别慢约0.082%和0.064%，不超过最低1%提速门槛。全部慢样本原样保留；这是内部耗时比较，不是官方分数。', '', '首次record-compare退出0；四次status退出0，查询间隔均≥45秒。完整原样本、实际资源/退出、标准比较理由与outer argv/UTC见同名JSON及原记录。未重提交、未用reset、未进行本机算子执行。']
with (R/'.runs/conv/sep13am-lifecycle-summary.md').open('x') as f:f.write('\n'.join(lines)+'\n')
print(json.dumps(dict(job_id=p['performance_job'],qualified_for_confirmation=c['qualified_for_confirmation'],totals_ms=[r['total_median_ms'] for r in records],samples=36,issues=[]),indent=2))
