"""Publishable AP/AQ evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
# Preparation only after original AQ has actually completed and standard records exist.
# No submit, promotion, packaging, Git commit or push is performed by this script.
plan=read(ROOT/'.runs/conv/sep13aq-campaign.json')
names=['C58-r6','C61-row7shared2rowwise','C58-r7'];candidate=names[1]
assert plan['status']=='complete' and plan['measurement_order']==names
assert plan['candidate']==candidate and plan['diagnostic_job']=='1590209'
assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit()
assert plan['performance_job']!='1590209' and plan['expected_benchmark_cases']==36
assert plan['automatic_promotion'] is False and plan['automatic_packaging'] is False
records=[read(ROOT/'records/experiments/conv'/(n+'.json')) for n in names];rec=records[1]
for name,r in zip(names,records):
 assert r['version']==name and r['status']=='passed' and r['verified'] is True
 assert r['checks'] and all(r['checks'].values()) and r['repeats']==3
 assert r['job_id']==plan['performance_job'] and r['settings']==plan['settings']
 assert r['machine']==records[0]['machine']
 assert len(r['cases'])==4 and all(len(c['times_ms'])==3 and c['max_error']==0 for c in r['cases'])
 cluster=read(ROOT/'.runs/conv'/name/'cluster.json');status=cluster['scheduler_status']
 assert cluster['job_id']==r['job_id'] and status['jobId']==r['job_id']
 assert status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0
 assert (ROOT/'.runs/conv'/name/'exit-code.txt').read_text().strip()=='0'
 assert cluster['source_hashes']==r['source_hashes']
assert plan['results']==[dict(version=r['version'],total_median_ms=r['total_median_ms'],cases=r['cases']) for r in records]
assert records[0]['source_hashes']==records[-1]['source_hashes']==plan['baseline_source']
assert rec['source_parent']=='C58-r1' and rec['diagnostic_job_id']=='1590209'
assert rec['qualified_for_confirmation']==(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
assert plan['comparison']==rec['comparison'] and plan['opening_control_comparison']==rec['opening_control_comparison']
machine=records[0]['machine']
assert machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64'
assert machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic'
assert len(set(machine['ALLOWED_CPUS'].split(',')))==38 and machine['NUMA_NODE']
diag=ROOT/'.runs/conv'/candidate/'sve-correctness-sep13ap'
ap=read(diag/'AP_SUMMARY.json');validation=read(diag/'validation.json');apjob=read(diag/'job.json')
assert ap['candidate']==validation['candidate']==candidate
assert ap['job_id']==validation['job_id']==apjob['job_id']=='1590209'
assert ap['numerical_logs_complete'] is True and ap['total_cases']==44328 and ap['stage_count']==19 and ap['issues']==[]
assert validation['status']=='passed' and validation['complete'] is True and validation['total_cases']==44328
assert validation['source_hashes']['conv2d.c']==rec['source_hashes']['conv2d.c']
assert ap['wrapper_exit']==0 and ap['scheduler']['jobExitCode']==ap['scheduler']['systemExitCode']==0
assert ap['scheduler']['status']=='SUCCEEDED' and ap['compiler_version']=='10.3.1'
assert apjob['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
assembly=read(diag/'root-assembly-counts.json')
assert assembly['pair']['instructions']==123 and assembly['remainder']['instructions']==63 and assembly['helper']['instructions']==2449
assert all(assembly['pair']['counts'][k]==v for k,v in dict(ld1w=6,ld1rw=14,fmul=42,fadd=42).items())
assert assembly['pair']['vector_stack']==assembly['remainder']['vector_stack']==[]
for name in ['TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','AP_SUMMARY.md','raw/conv2d-sve.s','raw/conv2d-sve.assembly.txt']:
 assert (diag/name).is_file(),name
assert '720B+3VL' in (diag/'ROOT_RETURNED_REVIEW.md').read_text()
assert read(ROOT/'records/best.json')['conv']==read(DST/'records/best.json')['conv']=='C58-r1'
assert read(ROOT/'outputs/conv-best.json')['label']=='C7'
expected_packages=['conv/result/C7/conv.zip','zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']
assert sorted(str(p.relative_to(DST)) for p in DST.glob('*/result/**/*.zip'))==sorted(expected_packages)
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13aq-attachments';a.mkdir(exist_ok=True);origins={}
for prefix in ('sep13ap','sep13aq'):
 for suffix in ('py','md','json','txt'):
  for p in (ROOT/'.runs/conv').glob(prefix+'-*.'+suffix):
   shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
assert any(n.startswith('sep13ap-lifecycle-status-') and n.endswith('.command.json') for n in origins)
assert any(n.startswith('sep13ap-lifecycle-fetch-') and n.endswith('.command.json') for n in origins)
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13ap-aq-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
assert sorted(p.stem for p in (exp/'records/experiments/conv').glob('*.json'))==sorted(names)
public_diag=exp/'records/evidence'/('conv-'+candidate)/'sve-correctness-sep13ap'
for name in ['AP_SUMMARY.json','AP_SUMMARY.md','TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','root-assembly-counts.json','raw/conv2d-sve.assembly.txt']:
 assert (public_diag/name).is_file(),name
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AP_AQ_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13ap-aq.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AP-AQ.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AP-AQ.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13ap-aq.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
change=f'减少{gain:.4f}%' if gain>=0 else f'增加{-gain:.4f}%'
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C61 逐行调度共享两列系数：AP专项与AQ性能

C61-row7shared2rowwise从当前C7派生，仅调整共享两列主循环的源代码调度：每列加载3个原始完整输入向量，再逐输出行以单个系数广播完成3个向量的更新，尝试缩短系数生命周期。每输出的乘法与加法顺序保持，全部12条边界提示、余一列、benchmark和runner保持原样。源码层面的生命周期变化不代表编译后一定更快。

AP原作业1590209通过44328项（六配置：SVE16/32/64字节×1/4线程），19阶段、job/system/wrapper全0。GCC10.3.1 strict/generic。实际共享两列主循环为123指令、6LD1W、14LD1RW、42FMUL/42FADD，余列为63指令；两段主循环没有Z栈访问。完整helper含ret为2449条，帧720B+3VL，父C7对应2448条及720B+3VL。完整helper仍有9读15写Z栈访问，不能将局部循环无spill说成整个helper无spill。这些均为静态汇编计数，独立与root分析、汇编原件公开副本随本轮记录保留。

AQ原作业{plan['performance_job']}：同一38CPU、24576MiB、单packed NUMA，GCC10.3.1/generic/38线程。C7前控 / C61 / C7后控三套完整官方测试各12例，合计36/36 PASS、误差0。合计中位数依次{totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时{change}。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='本轮保留标准new创建原件、AP原作业证据、AQ完整命令与全部样本。C61/AP此前因40%额度规则保留待执行，用户随后明确取消阈值才继续；历史停止记录不改写。官方规则与数值门槛未改，本机未编译或运行算子，未使用重置卡。无论初筛结果如何，本次证据发布均不自动晋级、确认或打包；C7及Z1/T19提交包保持原字节。\n\n[逐版本记录](CONV_SEP13AP_AQ_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C61-row7shared2rowwise.json) · [当前C7提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AP_AQ.md').write_text(doc)
notice=f'\nCONV C61 逐行共享两列系数调度：AP44328项通过，AQ36/36 PASS，合计{totals[1]:.2f}ms，相对结束C7控制{totals[-1]:.2f}ms耗时{change}。{decision}。实际主循环指令数保持123，性能结论以完整测量门槛为准。[本轮记录](docs/CONV_SEP13AP_AQ.md)。\n'
p=DST/'README.md';p.write_text(p.read_text()+notice)
p=DST/'records/SUMMARY.md';p.write_text(p.read_text()+notice.replace('(docs/','(../docs/'))
paths=set(subprocess.check_output(['git','diff','--name-only'],cwd=DST,text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=DST,text=True).splitlines())
for name in paths:
 assert not name.startswith(('conv/','trsm/','zgemm/','outputs/','tools/','config/','tests/')) and name!='records/best.json',name
 p=DST/name
 if p.is_file():
  s=p.read_text();assert not re.search(r'LOCAL_USER_HOMECLUSTER_USER_HOME\b10\.44\.9\.4\b|\bhuzhenghong\b|\blingsu011900\b|\bcn\d{4,}\b|\blogin\d+\b',s),name
  assert not re.search(r'(?i)(?:password|passwd|api_key|access_token)\s*[:=]LOCAL_USER-----BEGIN (?:OPENSSH|RSA|EC) PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}',s),name
for name in ['conv/result/C7/conv.zip','zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip','records/best.json']:
 assert (DST/name).read_bytes()==subprocess.check_output(['git','show',head+':'+name],cwd=DST)
(ROOT/'.runs/conv/sep13aq-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AP/AQ paths; best C7/Z1/T19 retained unchanged.')
