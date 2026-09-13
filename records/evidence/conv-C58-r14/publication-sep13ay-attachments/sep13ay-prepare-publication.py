"""Publishable AX/AY evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
# Preparation only after original AY has actually completed and standard records exist.
# No submit, promotion, packaging, Git commit or push is performed by this script.
plan=read(ROOT/'.runs/conv/sep13ay-campaign.json')
names=['C58-r14','C65-row7balanced','C58-r15'];candidate=names[1]
assert plan['status']=='complete' and plan['measurement_order']==names
assert plan['candidate']==candidate and plan['diagnostic_job']=='1591086'
assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit()
assert plan['performance_job']!='1591086' and plan['expected_benchmark_cases']==36
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
assert rec['source_parent']=='C58-r1' and rec['diagnostic_job_id']=='1591086'
assert rec['qualified_for_confirmation']==(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
assert plan['comparison']==rec['comparison'] and plan['opening_control_comparison']==rec['opening_control_comparison']
machine=records[0]['machine']
assert machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64'
assert machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic'
assert len(set(machine['ALLOWED_CPUS'].split(',')))==38 and machine['NUMA_NODE']
diag=ROOT/'.runs/conv'/candidate/'sve-correctness-sep13ax'
ax=read(diag/'AX_SUMMARY.json');validation=read(diag/'validation.json');axjob=read(diag/'job.json')
assert ax['candidate']==validation['candidate']==candidate
assert ax['job_id']==validation['job_id']==axjob['job_id']=='1591086'
assert ax['numerical_logs_complete'] is True and ax['total_cases']==80100 and ax['stage_count']==25 and ax['issues']==[]
assert validation['status']=='passed' and validation['complete'] is True and validation['total_cases']==80100
assert validation['source_hashes']['conv2d.c']==rec['source_hashes']['conv2d.c']=='a855c14b81c00f3d398ac36c5ece6726e15235f18ebf3fe4746570da25a7f874'
assert ax['wrapper_exit']==0 and ax['scheduler']['jobExitCode']==ax['scheduler']['systemExitCode']==0
assert ax['scheduler']['status']=='SUCCEEDED' and ax['compiler_version']=='10.3.1'
assert axjob['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
assembly=read(diag/'root-assembly-counts.json')
assert assembly['shared']['instructions']==123 and assembly['remainder']['instructions']==63 and assembly['helper']['instructions']==2448
assert all(assembly['shared']['counts'][k]==v for k,v in dict(ld1w=6,ld1rw=14,fmul=42,fadd=42).items())
assert all(assembly['remainder']['counts'][k]==v for k,v in dict(ld1w=3,ld1rw=7,fmul=21,fadd=21).items())
assert assembly['remainder']['vector_stack']==[]
def z_counts(section):
 rows=assembly[section]['vector_stack']
 assert all(re.match(r'^\s*(?:ldr|str)\s+z\d+\b',x) for x in rows)
 return {op:sum(bool(re.match(r'^\s*'+op+r'\s+z\d+\b',x)) for x in rows) for op in ('ldr','str')}
assert z_counts('shared')==dict(ldr=0,str=0) and z_counts('helper')==dict(ldr=9,str=15)
assert len(ax['configurations'])==9
assert {(x['sve_bytes'],x['threads']) for x in ax['configurations']}=={(v,t) for v in (16,32,64) for t in (1,4,38)}
for config in ax['configurations']:
 legacy=config['legacy_suite_entries']
 assert set(legacy)=={'PREFIX','TAIL','ROWPAIR','ROWTRIPLE','ROWQUAD'} and all(v>0 for v in legacy.values())
 assert config['rowseven_entries']['dispatch']['actual']==config['rowseven_entries']['dispatch']['expected']=={1:4008,4:6168,38:24010}[config['threads']]
 assert config['rowseven_entries']['dispatch']['worker_mask']==config['rowseven_entries']['dispatch']['expected_mask']==(1<<config['threads'])-1
 coverage=config['exact_once_coverage']
 assert coverage['actual_cases']==coverage['expected_cases']==3156 and coverage['address_errors']==0
 assert coverage['actual_output_values']==coverage['independent_expected_output_values']>0
 assert config['rowseven_entries']['direct']['actual']==config['rowseven_entries']['direct']['expected']==1080
 assert config['rowseven_entries']['direct']['worker_mask']==config['rowseven_entries']['direct']['expected_mask']==(1 if config['threads']==1 else 15)
assert ax['exact_once_cases']==28404 and ax['exact_once_output_values']==110027484
assert assembly['metadata']['instructions']==2 and assembly['metadata']['counts']==dict(cntw=1,ret=1)
assert assembly['dispatcher']['instructions']==205 and assembly['dispatcher']['counts']['udiv']==3 and assembly['fused_count']==0
assert all('-DEXPECTED_ACC=3' in argv for argv in ax['actual_compile_argv'])
assert len(ax['actual_compile_argv'])==3 and all(all(flag in argv for flag in ['-O3','-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp']) for argv in ax['actual_compile_argv'])
for name in ['TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','AX_SUMMARY.md','raw/conv2d-sve.s','raw/conv2d-sve.assembly.txt']:
 assert (diag/name).is_file(),name
assert read(ROOT/'records/best.json')['conv']==read(DST/'records/best.json')['conv']=='C58-r1'
assert read(ROOT/'outputs/conv-best.json')['label']=='C7'
expected_packages=['conv/result/C7/conv.zip','zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']
assert sorted(str(p.relative_to(DST)) for p in DST.glob('*/result/**/*.zip'))==sorted(expected_packages)
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13ay-attachments';a.mkdir(exist_ok=True);origins={}
for prefix in ('sep13ax','sep13ay','sep13-c65'):
 for suffix in ('py','md','json','txt','patch'):
  for p in (ROOT/'.runs/conv').glob(prefix+'-*.'+suffix):
   shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
assert any(n.startswith('sep13ax-lifecycle-status-') and n.endswith('.command.json') for n in origins)
assert any(n.startswith('sep13ax-lifecycle-fetch-') and n.endswith('.command.json') for n in origins)
# Include AX preparation/count derivation and its source/transport diffs as text.
# Original C65 generator/new/checkpoint events are collected; its C7 source patch remains in its run.
ax_template=ROOT/'.runs/conv/sep13ax-checks'
for p in ax_template.iterdir():
 if p.is_file() and p.suffix in {'.py','.md','.json','.txt','.patch'}:
  key='AX-template-'+p.name
  shutil.copy2(p,a/key);origins[key]=str(p.relative_to(ROOT))
for p in (ax_template/'templates').iterdir():
 if p.is_file() and p.suffix=='.c':
  key='AX-template-'+p.name;shutil.copy2(p,a/key);origins[key]=str(p.relative_to(ROOT))
assert 'sep13-c65-prepare.py' in origins
for name in ['sep13-c65-new.command.json','sep13-c65-checkpoint.command.json','sep13ay-performance.unbound.py.txt','sep13ay-performance.bound.patch','sep13ay-performance.from-aw.patch']:
 assert name in origins,name
assert (ROOT/'.runs/conv'/candidate/'candidate.patch').is_file()
assert 'AX-template-EXPECTED_ENTRY_TABLE.json' in origins
assert all('AX-template-'+n in origins for n in ['ROOT_INDEPENDENT_ENTRY_DERIVATION.json','initial-accept_and_freeze.py.txt','acceptor-error-marker-fix.patch','INDEPENDENT_TOOLS_REVIEW.md','ROOT_REVIEW.md'])
assert 'sep13ax-prepare.py' in origins
for name in ['sep13-c65-prepare-driver.command.json','sep13-c65-prepare-driver.exit.txt','sep13ax-root-submit.command.json','sep13ax-root-accept.command.json','sep13ax-root-entry-derivation.json','sep13ax-root-design-review.md','sep13ax-lifecycle-summary-001.command.json','sep13ay-root-submit.command.json','sep13ay-performance.py']:
 assert name in origins,name
assert all('AX-template-'+n in origins for n in ['check_conv_guard.c','check_sve_dispatch.c'])
assert any(n.startswith('sep13ay-') and 'record-compare' in n and n.endswith('.command.json') for n in origins)
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13ax-ay-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
assert sorted(p.stem for p in (exp/'records/experiments/conv').glob('*.json'))==sorted(names)
public_diag=exp/'records/evidence'/('conv-'+candidate)/'sve-correctness-sep13ax'
for name in ['AX_SUMMARY.json','AX_SUMMARY.md','TARGETED_ASSEMBLY_REVIEW.md','ROOT_RETURNED_REVIEW.md','root-assembly-counts.json','raw/conv2d-sve.assembly.txt']:
 assert (public_diag/name).is_file(),name
for name in ['candidate.patch','SOURCE_AUDIT.json','STATIC_REVIEW.md','INDEPENDENT_REVIEW.md','ROOT_SOURCE_REVIEW.md','prepare-source.py','creation-experiment-original.json','creation-record-original.json']:
 assert (exp/'records/evidence'/('conv-'+candidate)/name).is_file(),name
public_attachments=exp/'records/evidence'/('conv-'+names[0])/'publication-sep13ay-attachments'
for name in ['AX-template-EXPECTED_ENTRY_TABLE.json','AX-template-ROOT_INDEPENDENT_ENTRY_DERIVATION.json','AX-template-initial-accept_and_freeze.py.txt','AX-template-acceptor-error-marker-fix.patch','AX-template-check_conv_guard.c','AX-template-check_sve_dispatch.c','AX-template-driver.py','AX-template-accept_and_freeze.py','sep13ax-prepare.py','sep13-c65-prepare.py','sep13-c65-new.command.json','sep13-c65-checkpoint.command.json','sep13ay-performance.unbound.py.txt','sep13ay-performance.bound.patch','sep13ay-performance.from-aw.patch']:
 assert (public_attachments/name).is_file(),name
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AX_AY_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13ax-ay.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AX-AY.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AX-AY.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13ax-ay.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
change=f'减少{gain:.4f}%' if gain>=0 else f'增加{-gain:.4f}%'
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C65 七行组与列片负载均分：AX 专项与 AY 性能

C65-row7balanced 的标准源父版本是当前 C7/C58-r1。本轮只改变七行分派：把七行组和 ceil(ow/3VL) 列片展平，以实际 OpenMP 团队的商与余数分配连续区间，再合并同组内相邻片。一个 omp single 的隐式屏障发布公共列片宽度；目标 SVE 查询受已有 HWCAP 分派保护。所有计算 helper、逐链乘加顺序、其他分派、官方 benchmark 和 runner 保持 C7 字节。源码逆转换与独立分区证明保留。

AX 原作业 1591086 通过 80100 项，九配置 SVE 16/32/64 字节 × 1/4/38 实际线程；25 阶段、job/system/wrapper 全 0。GCC 10.3.1 strict/generic、EXPECTED_ACC=3。每配置 5744 full + 2724 dispatch + 432 direct；独立逐 case 入口与 worker mask 校验通过，dispatch 入口分别为 4008/6168/24010，direct 为 1080。诊断 observer 按实际 predicate 逐输出计数，每配置 3156 例恰好写一次，九配置共 28404 例、110027484 个输出，地址错误为零；原 bitwise/guard 检查保留。observer 不进入正式源或性能测试。

实际 shared2 循环 123 指令、42 FMUL/42 FADD、6 LD1W/14 LD1RW；余列 63 指令、21 FMUL/21 FADD、3 LD1W/7 LD1RW，两循环均无 Z 栈访问。完整 helper 含 ret 2448 指令、静态路径 9 次 Z 读/15 次 Z 写、帧 720B+3VL，与 C7 原计算 helper 相同。metadata 查询仅 CNTW/RET 两指令，新 dispatcher 205 指令含 3 UDIV，整个汇编未见融合算术。这些静态计数不证明提速。

AY 原作业 {plan['performance_job']}：同一 38 CPU、24576 MiB、单 packed NUMA、1800 秒，GCC 10.3.1/generic/38 线程。C7 前控/C65/C7 后控各三套完整官方测试，每版本 12 例，合计 36/36 PASS、误差 0。合计中位数 {totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时{change}。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='本轮保留标准 new/checkpoint 原命令、C65 生成脚本和相对 C7 补丁、AX checker 源码/预期表/独立推导/源与工具审查、acceptor 初稿及误匹配修复、原诊断全日志、AY 原作业和全部样本。AY 未绑定模板、实际 AX 身份绑定补丁及最终脚本留档。本机未运行算子，未使用重置卡。本次只发布记录：初筛通过也仍须独立确认，不自动晋级或打包；当前 C7 及 Z1/T19 提交包保持原字节。\n\n[逐版本记录](CONV_SEP13AX_AY_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C65-row7balanced.json) · [当前 C7 提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AX_AY.md').write_text(doc)
notice=f'\nCONV C65 七行组与列片负载均分：AX 80100 项及实际输出恰好一次检查通过，AY 36/36 PASS，合计 {totals[1]:.2f} ms，相对结束 C7 控制 {totals[-1]:.2f} ms 耗时{change}。{decision}。计算 helper 保持 C7，速度判断以两端完整测量为准。[本轮记录](docs/CONV_SEP13AX_AY.md)。\n'
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
(ROOT/'.runs/conv/sep13ay-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AX/AY evidence paths; all conv files and C7/Z1/T19 ZIP bytes unchanged.')
