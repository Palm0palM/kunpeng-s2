"""Publishable AT/AU evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
# Preparation only after original AU has actually completed and standard records exist.
# No submit, promotion, packaging, Git commit or push is performed by this script.
plan=read(ROOT/'.runs/conv/sep13au-campaign.json')
names=['C58-r10','C63-row7x2shared4rowwise','C58-r11'];candidate=names[1]
assert plan['status']=='complete' and plan['measurement_order']==names
assert plan['candidate']==candidate and plan['diagnostic_job']=='1590603'
assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit()
assert plan['performance_job']!='1590603' and plan['expected_benchmark_cases']==36
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
assert rec['source_parent']=='C58-r1' and rec['diagnostic_job_id']=='1590603'
assert rec['qualified_for_confirmation']==(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
assert plan['comparison']==rec['comparison'] and plan['opening_control_comparison']==rec['opening_control_comparison']
machine=records[0]['machine']
assert machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64'
assert machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic'
assert len(set(machine['ALLOWED_CPUS'].split(',')))==38 and machine['NUMA_NODE']
diag=ROOT/'.runs/conv'/candidate/'sve-correctness-sep13at'
at=read(diag/'AT_SUMMARY.json');validation=read(diag/'validation.json');atjob=read(diag/'job.json')
assert at['candidate']==validation['candidate']==candidate
assert at['job_id']==validation['job_id']==atjob['job_id']=='1590603'
assert at['numerical_logs_complete'] is True and at['total_cases']==44328 and at['stage_count']==19 and at['issues']==[]
assert validation['status']=='passed' and validation['complete'] is True and validation['total_cases']==44328
assert validation['source_hashes']['conv2d.c']==rec['source_hashes']['conv2d.c']
assert at['wrapper_exit']==0 and at['scheduler']['jobExitCode']==at['scheduler']['systemExitCode']==0
assert at['scheduler']['status']=='SUCCEEDED' and at['compiler_version']=='10.3.1'
assert atjob['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
assembly=read(diag/'root-assembly-counts.json')
assert assembly['shared']['instructions']==161 and assembly['remainder']['instructions']==48 and assembly['helper']['instructions']==1990
assert all(assembly['shared']['counts'][k]==v for k,v in dict(ld1w=8,ld1rw=28,fmul=56,fadd=56).items())
assert all(assembly['remainder']['counts'][k]==v for k,v in dict(ld1w=2,ld1rw=7,fmul=14,fadd=14).items())
assert assembly['remainder']['vector_stack']==[]
def z_counts(section):
 rows=assembly[section]['vector_stack']
 assert all(re.match(r'^\s*(?:ldr|str)\s+z\d+\b',x) for x in rows)
 return {op:sum(bool(re.match(r'^\s*'+op+r'\s+z\d+\b',x)) for x in rows) for op in ('ldr','str')}
assert z_counts('shared')==dict(ldr=1,str=1) and z_counts('helper')==dict(ldr=1,str=1)
assert len(at['configurations'])==6
for config in at['configurations']:
 legacy=config['legacy_suite_entries']
 assert set(legacy)=={'PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'} and all(v>0 for v in legacy.values())
 assert config['rowseven_entries']['dispatch']['actual']==config['rowseven_entries']['dispatch']['expected']==1236
 assert config['rowseven_entries']['direct']['actual']==config['rowseven_entries']['direct']['expected']==1080
assert all('-DEXPECTED_ACC=2' in argv for argv in at['actual_compile_argv'])
for name in ['TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','AT_SUMMARY.md','raw/conv2d-sve.s','raw/conv2d-sve.assembly.txt']:
 assert (diag/name).is_file(),name
assert '688B+1VL' in (diag/'ROOT_RETURNED_REVIEW.md').read_text()
assert read(ROOT/'records/best.json')['conv']==read(DST/'records/best.json')['conv']=='C58-r1'
assert read(ROOT/'outputs/conv-best.json')['label']=='C7'
expected_packages=['conv/result/C7/conv.zip','zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']
assert sorted(str(p.relative_to(DST)) for p in DST.glob('*/result/**/*.zip'))==sorted(expected_packages)
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13au-attachments';a.mkdir(exist_ok=True);origins={}
for prefix in ('sep13at','sep13au','sep13-c63'):
 for suffix in ('py','md','json','txt','patch'):
  for p in (ROOT/'.runs/conv').glob(prefix+'-*.'+suffix):
   shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
assert any(n.startswith('sep13at-lifecycle-status-') and n.endswith('.command.json') for n in origins)
assert any(n.startswith('sep13at-lifecycle-fetch-') and n.endswith('.command.json') for n in origins)
# Include AT preparation/count derivation and its source/transport diffs as text.
# Original C63 generator and new/checkpoint events are collected by sep13-c63; both source patches remain in its run.
at_template=ROOT/'.runs/conv/sep13at-checks'
for p in at_template.iterdir():
 if p.is_file() and p.suffix in {'.py','.md','.json','.txt','.patch'}:
  key='AT-template-'+p.name
  shutil.copy2(p,a/key);origins[key]=str(p.relative_to(ROOT))
assert 'sep13-c63-prepare.py' in origins
for name in ['sep13-c63-new.command.json','sep13-c63-checkpoint.command.json','sep13au-performance.initial-adaptation.py.txt','sep13au-performance.final-from-as.patch']:
 assert name in origins,name
assert (ROOT/'.runs/conv'/candidate/'delta-from-C62.patch').is_file()
assert (ROOT/'.runs/conv'/candidate/'candidate.patch').is_file()
assert 'AT-template-CHECKER_COUNTS.md' in origins
assert 'sep13at-prepare.py' in origins
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13at-au-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
assert sorted(p.stem for p in (exp/'records/experiments/conv').glob('*.json'))==sorted(names)
public_diag=exp/'records/evidence'/('conv-'+candidate)/'sve-correctness-sep13at'
for name in ['AT_SUMMARY.json','AT_SUMMARY.md','TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','root-assembly-counts.json','raw/conv2d-sve.assembly.txt']:
 assert (public_diag/name).is_file(),name
for name in ['candidate.patch','delta-from-C62.patch','SOURCE_AUDIT.json','creation-experiment-original.json','creation-record-original.json']:
 assert (exp/'records/evidence'/('conv-'+candidate)/name).is_file(),name
public_attachments=exp/'records/evidence'/('conv-'+names[0])/'publication-sep13au-attachments'
for name in ['AT-template-CHECKER_COUNTS.md','AT-template-driver.py','AT-template-accept_and_freeze.py','sep13at-prepare.py','sep13-c63-prepare.py','sep13-c63-new.command.json','sep13-c63-checkpoint.command.json','sep13au-performance.initial-adaptation.py.txt','sep13au-performance.final-from-as.patch']:
 assert (public_attachments/name).is_file(),name
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AT_AU_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13at-au.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AT-AU.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AT-AU.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13at-au.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
change=f'减少{gain:.4f}%' if gain>=0 else f'增加{-gain:.4f}%'
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C63 四列共享逐行权重调度：AT专项与AU性能

C63-row7x2shared4rowwise标准父版本为当前C7/C58-r1，C62是2VL/14累加器/共享四列的设计来源，不作为本候选的性能比较基线。相对C62，仅将共享四列主循环改为每列先加载两个输入向量，再逐输出行广播一个权重并更新两个累加器，以缩短权重生命周期。保持每输出的四列次序及独立乘法/加法，所有其他C62字节、12条边界提示、余列与分派不变；benchmark和runner来自C7。

AT原作业1590603通过44328项（六配置：SVE16/32/64字节×1/4线程），19阶段、job/system/wrapper全0。GCC10.3.1 strict/generic，EXPECTED_ACC=2。checker沿用AR的2L/4L边界及kw4..8余数覆盖；dispatch/direct逐用例及总数1236/1080验证。legacy五类仍按原checker各非零要求检查并单独报告实际计数，不复制上轮观测作为预期。

实际四列主循环161指令，56FMUL/56FADD、8LD1W、28LD1RW，仅1次Z读取与1次Z写入栈派生地址；余列循环48指令、14FMUL/14FADD、2LD1W、7LD1RW，循环内无Z栈访问。完整helper含ret1990指令，完整静态路径同样仅1次Z读、1次Z写；帧688B+1VL。C62相应四列循环211指令、17次Z读/17次Z写、帧688B+17VL。权重调度减少了实际生成汇编的栈访问，但这并不能证明相对C7提速。C7的tile与共享列数不同，原始指令数不能直接用作速度结论。独立与root实际汇编审查随证据保存。

AU原作业{plan['performance_job']}：同一38CPU、24576MiB、单packed NUMA，GCC10.3.1/generic/38线程。C7前控 / C63 / C7后控三套完整官方测试各12例，合计36/36 PASS、误差0。合计中位数依次{totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时{change}。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='本轮保留标准new/checkpoint原始命令、候选生成脚本、相对C7和C62的两份补丁、AT模板/数目推导/独立审查、原作业证据与AU全部样本。AU性能脚本初次适配曾误改ASSEMBLY/PASS等包含轮次字母的标识；错误初稿在执行前被发现并修复，初稿和修复差异按真实记录保存，它没有被执行或提交为作业。官方规则与数值门槛未改，本机未编译或运行算子，未使用重置卡。无论初筛结果如何，本次证据发布均不自动晋级、确认或打包；C7及Z1/T19提交包保持原字节。\n\n[逐版本记录](CONV_SEP13AT_AU_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C63-row7x2shared4rowwise.json) · [当前C7提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AT_AU.md').write_text(doc)
notice=f'\nCONV C63 四列共享逐行权重调度：AT44328项通过，AU36/36 PASS，合计{totals[1]:.2f}ms，相对结束C7控制{totals[-1]:.2f}ms耗时{change}。{decision}。实际四列循环与全helper仅1读1写Z栈访问，速度判断仍以两端完整测量门槛为准。[本轮记录](docs/CONV_SEP13AT_AU.md)。\n'
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
(ROOT/'.runs/conv/sep13au-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AT/AU paths; best C7/Z1/T19 retained unchanged.')
