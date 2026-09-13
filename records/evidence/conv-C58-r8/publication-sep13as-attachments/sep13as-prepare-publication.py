"""Publishable AR/AS evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
# Preparation only after original AS has actually completed and standard records exist.
# No submit, promotion, packaging, Git commit or push is performed by this script.
plan=read(ROOT/'.runs/conv/sep13as-campaign.json')
names=['C58-r8','C62-row7x2shared4','C58-r9'];candidate=names[1]
assert plan['status']=='complete' and plan['measurement_order']==names
assert plan['candidate']==candidate and plan['diagnostic_job']=='1590510'
assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit()
assert plan['performance_job']!='1590510' and plan['expected_benchmark_cases']==36
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
assert rec['source_parent']=='C58-r1' and rec['diagnostic_job_id']=='1590510'
assert rec['qualified_for_confirmation']==(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
assert plan['comparison']==rec['comparison'] and plan['opening_control_comparison']==rec['opening_control_comparison']
machine=records[0]['machine']
assert machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64'
assert machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic'
assert len(set(machine['ALLOWED_CPUS'].split(',')))==38 and machine['NUMA_NODE']
diag=ROOT/'.runs/conv'/candidate/'sve-correctness-sep13ar'
ar=read(diag/'AR_SUMMARY.json');validation=read(diag/'validation.json');arjob=read(diag/'job.json')
assert ar['candidate']==validation['candidate']==candidate
assert ar['job_id']==validation['job_id']==arjob['job_id']=='1590510'
assert ar['numerical_logs_complete'] is True and ar['total_cases']==44328 and ar['stage_count']==19 and ar['issues']==[]
assert validation['status']=='passed' and validation['complete'] is True and validation['total_cases']==44328
assert validation['source_hashes']['conv2d.c']==rec['source_hashes']['conv2d.c']
assert ar['wrapper_exit']==0 and ar['scheduler']['jobExitCode']==ar['scheduler']['systemExitCode']==0
assert ar['scheduler']['status']=='SUCCEEDED' and ar['compiler_version']=='10.3.1'
assert arjob['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
assembly=read(diag/'root-assembly-counts.json')
assert assembly['shared']['instructions']==211 and assembly['remainder']['instructions']==48 and assembly['helper']['instructions']==2260
assert all(assembly['shared']['counts'][k]==v for k,v in dict(ld1w=8,ld1rw=28,fmul=56,fadd=56).items())
assert all(assembly['remainder']['counts'][k]==v for k,v in dict(ld1w=2,ld1rw=7,fmul=14,fadd=14).items())
assert assembly['remainder']['vector_stack']==[]
def z_counts(section):
 rows=assembly[section]['vector_stack']
 assert all(re.match(r'^\s*(?:ldr|str)\s+z\d+\b',x) for x in rows)
 return {op:sum(bool(re.match(r'^\s*'+op+r'\s+z\d+\b',x)) for x in rows) for op in ('ldr','str')}
assert z_counts('shared')==dict(ldr=17,str=17) and z_counts('helper')==dict(ldr=98,str=86)
assert len(ar['configurations'])==6
for config in ar['configurations']:
 legacy=config['legacy_suite_entries']
 assert set(legacy)=={'PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'} and all(v>0 for v in legacy.values())
 assert config['rowseven_entries']['dispatch']['actual']==config['rowseven_entries']['dispatch']['expected']==1236
 assert config['rowseven_entries']['direct']['actual']==config['rowseven_entries']['direct']['expected']==1080
assert all('-DEXPECTED_ACC=2' in argv for argv in ar['actual_compile_argv'])
for name in ['TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','AR_SUMMARY.md','raw/conv2d-sve.s','raw/conv2d-sve.assembly.txt']:
 assert (diag/name).is_file(),name
assert '688B+17VL' in (diag/'ROOT_RETURNED_REVIEW.md').read_text()
assert read(ROOT/'records/best.json')['conv']==read(DST/'records/best.json')['conv']=='C58-r1'
assert read(ROOT/'outputs/conv-best.json')['label']=='C7'
expected_packages=['conv/result/C7/conv.zip','zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']
assert sorted(str(p.relative_to(DST)) for p in DST.glob('*/result/**/*.zip'))==sorted(expected_packages)
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13as-attachments';a.mkdir(exist_ok=True);origins={}
for prefix in ('sep13ar','sep13as'):
 for suffix in ('py','md','json','txt'):
  for p in (ROOT/'.runs/conv').glob(prefix+'-*.'+suffix):
   shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
assert any(n.startswith('sep13ar-lifecycle-status-') and n.endswith('.command.json') for n in origins)
assert any(n.startswith('sep13ar-lifecycle-fetch-') and n.endswith('.command.json') for n in origins)
# Include AR preparation/count derivation and its source/transport diffs as text.
# The candidate's own prepare-source.py and source patch are exported from its run.
ar_template=ROOT/'.runs/conv/sep13ar-checks'
for p in ar_template.iterdir():
 if p.is_file() and p.suffix in {'.py','.md','.json','.txt','.patch'}:
  key='AR-template-'+p.name
  shutil.copy2(p,a/key);origins[key]=str(p.relative_to(ROOT))
assert (ROOT/'.runs/conv'/candidate/'prepare-source.py').is_file()
assert (ROOT/'.runs/conv'/candidate/'candidate.patch').is_file()
assert 'AR-template-CHECKER_COUNTS.md' in origins
assert 'sep13ar-prepare.py' in origins
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13ar-as-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
assert sorted(p.stem for p in (exp/'records/experiments/conv').glob('*.json'))==sorted(names)
public_diag=exp/'records/evidence'/('conv-'+candidate)/'sve-correctness-sep13ar'
for name in ['AR_SUMMARY.json','AR_SUMMARY.md','TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','root-assembly-counts.json','raw/conv2d-sve.assembly.txt']:
 assert (public_diag/name).is_file(),name
assert (exp/'records/evidence'/('conv-'+candidate)/'prepare-source.py').is_file()
public_attachments=exp/'records/evidence'/('conv-'+names[0])/'publication-sep13as-attachments'
for name in ['AR-template-CHECKER_COUNTS.md','AR-template-driver.py','AR-template-accept_and_freeze.py','sep13ar-prepare.py']:
 assert (public_attachments/name).is_file(),name
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AR_AS_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13ar-as.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AR-AS.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AR-AS.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13ar-as.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
change=f'减少{gain:.4f}%' if gain>=0 else f'增加{-gain:.4f}%'
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C62 七行双向量与四列共享：AR专项与AS性能

C62-row7x2shared4从当前C7派生，联合改变rowseven输出块宽度和共享列数：每输出行由3VL变为2VL，21个累加器减少为14个，并将共享 kernel 列由两列展开为四列。每输出保持原始kernel行列次序与独立乘法/加法，四列后由单列循环处理零到三列余数；七输出行分派、12条边界unroll2提示、其他helper、benchmark和runner保持原样。这是联合tile假设，不能把表现单独归因于某一个参数。

AR原作业1590510通过44328项（六配置：SVE16/32/64字节×1/4线程），19阶段、job/system/wrapper全0。GCC10.3.1 strict/generic，EXPECTED_ACC=2，checker全套相关宽度调整到2L/4L边界，并保留kw4..8的四列余数覆盖。dispatch/direct实际rowseven入口仍按每个用例及总数1236/1080验证；legacy五类按原checker各非零要求核对，实际值见AR_SUMMARY，不套用AP旧固定值。

实际共享四列主循环为211指令，56FMUL/56FADD、8LD1W、28LD1RW，并有17次Z读取和17次Z写入栈派生地址。单列余数循环48指令、14FMUL/14FADD、2LD1W、7LD1RW，循环内部无Z栈访问。完整helper含ret为2260条，帧688B+17VL，全静态路径有98次Z读取、86次Z写入。C62并未消除scalable spill。输出tile从3VL变成2VL，共享列数也改变，每次循环处理的工作量不同，不能直接比较原始指令数并宣称提速。独立与root分析、汇编原件公开副本随本轮记录保留。

AS原作业{plan['performance_job']}：同一38CPU、24576MiB、单packed NUMA，GCC10.3.1/generic/38线程。C7前控 / C62 / C7后控三套完整官方测试各12例，合计36/36 PASS、误差0。合计中位数依次{totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时{change}。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='本轮保留标准new创建原件、候选源码生成与差异、AR诊断生成与数目推导、独立汇编审查、原作业证据、AS完整命令与全部样本。官方规则与数值门槛未改，本机未编译或运行算子，未使用重置卡。无论初筛结果如何，本次证据发布均不自动晋级、确认或打包；C7及Z1/T19提交包保持原字节。\n\n[逐版本记录](CONV_SEP13AR_AS_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C62-row7x2shared4.json) · [当前C7提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AR_AS.md').write_text(doc)
notice=f'\nCONV C62 七行双向量/共享四列联合tile：AR44328项通过，AS36/36 PASS，合计{totals[1]:.2f}ms，相对结束C7控制{totals[-1]:.2f}ms耗时{change}。{decision}。实际四列循环仍有17读17写Z栈访问；变化后的tile原始指令数不代表加速。[本轮记录](docs/CONV_SEP13AR_AS.md)。\n'
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
(ROOT/'.runs/conv/sep13as-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AR/AS paths; best C7/Z1/T19 retained unchanged.')
