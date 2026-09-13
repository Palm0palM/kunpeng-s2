"""Prepare reviewed C8 files after actual promotion; no Git mutation or tests."""
from pathlib import Path
import json,shutil,subprocess,sys,zipfile,re,hashlib
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
def write(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
meta=read(ROOT/'outputs/conv-best.json');assert meta['label']=='C8' and meta['experiment']=='C65-r1' and meta['source_experiment']=='C65-row7balanced'
assert read(ROOT/'records/best.json')['conv']=='C65-r1'
lineage=read(ROOT/'records/conv-lineage.json');assert lineage['current_label']=='C8' and lineage['current_measurement']=='C65-r1'
rec=read(ROOT/'records/experiments/conv/C65-r1.json');pack=read(ROOT/'records/experiments/conv/C65-package.json')
plan=read(ROOT/'.runs/conv/sep13az-campaign.json');initial=read(ROOT/'.runs/conv/sep13ay-campaign.json')
assert plan['status']=='complete' and plan['performance_job']=='1591241' and plan['confirmation_passed'] is True
assert initial['status']=='complete' and initial['performance_job']=='1591187'
assert rec['confirmation_passed'] is True and rec['promoted_at'] and rec['job_id']=='1591241'
assert rec['source_hashes']==pack['source_hashes']==meta['source_hashes']
assert rec['source_hashes']['conv2d.c']=='a855c14b81c00f3d398ac36c5ece6726e15235f18ebf3fe4746570da25a7f874'
sys.path.insert(0,str(ROOT/'tools'));import experiment as e
for campaign,order in [(initial,['C58-r14','C65-row7balanced','C58-r15']),(plan,['C58-r16','C65-r1','C58-r17'])]:
 assert campaign['measurement_order']==order and campaign['expected_benchmark_cases']==36
 records=[read(ROOT/'records/experiments/conv'/(n+'.json')) for n in order]
 for index,(n,r) in enumerate(zip(order,records)):
  folder=ROOT/'.runs/conv'/n;m=read(folder/'cluster.json');status=m['scheduler_status'];raw=(folder/'benchmark.log').read_text();parsed=e.parse_log('conv',raw,3)
  assert r['status']=='passed' and r['verified'] and all(r['checks'].values()) and r['repeats']==3
  assert r['job_id']==m['job_id']==str(status['jobId'])==campaign['performance_job'] and status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0
  assert m['group']==campaign['performance_group'] and m['group_index']==index and m['measurement_order']==order
  assert r['settings']==m['settings']==campaign['settings'] and r['machine']==records[0]['machine']
  assert r['source_hashes']==m['source_hashes']==e.source_files(folder/'source')
  assert (folder/'exit-code.txt').read_text().strip()=='0' and parsed['cases']==r['cases'] and parsed['total_median_ms']==r['total_median_ms']
  assert len(r['cases'])==4 and all(len(c['times_ms'])==3 and c['max_error']==0 for c in r['cases'])
 assert campaign['results']==[dict(version=r['version'],total_median_ms=r['total_median_ms'],cases=r['cases']) for r in records]
 assert records[0]['source_hashes']==records[-1]['source_hashes']==campaign['baseline_source']
 assert records[1]['source_hashes']==meta['source_hashes']
 for base,field in [(records[0],'opening_control_comparison'),(records[-1],'comparison')]:
  verdict=dict(e.comparison(base,records[1]),baseline=base['version']);assert verdict['eligible'] and verdict==records[1][field]==campaign[field]
opening,ending=records[0],records[-1]
assert initial['settings']==plan['settings']==pack['settings'] and pack['status']=='passed' and pack['verified'] and all(pack['checks'].values()) and pack['repeats']==3
assert pack['reference_only'] and pack['package_validation_only'] and not pack['promotion_allowed'] and pack['source_parent']=='C65-r1'
pkg_run=ROOT/'.runs/conv/C65-package';pm=read(pkg_run/'cluster.json');manifest=read(pkg_run/'package-manifest.json');status=pm['scheduler_status']
assert pack['job_id']==pm['job_id']==str(status['jobId'])=='1591477'
assert status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0 and (pkg_run/'exit-code.txt').read_text().strip()=='0'
assert pm['settings']==pack['settings'] and pm['source_hashes']==pack['source_hashes']==e.source_files(pkg_run/'source')==e.source_files(ROOT/'conv')
parsed=e.parse_log('conv',(pkg_run/'benchmark.log').read_text(),3)
assert parsed['cases']==pack['cases'] and parsed['total_median_ms']==pack['total_median_ms']
assert len(pack['cases'])==4 and all(len(c['times_ms'])==3 and c['max_error']==0 for c in pack['cases'])
archive=(pkg_run/'conv.zip').read_bytes();sha=hashlib.sha256(archive).hexdigest()
assert manifest==pm['package_verification'] and manifest['zip_sha256']==meta['package_sha256']==sha and manifest['source_hashes']==meta['source_hashes']
assert (pkg_run/'wrapper.stdout.log').read_text().splitlines().count('PACKAGE_SHA256_VERIFIED='+sha)==1
assert (ROOT/'outputs/conv-best.zip').read_bytes()==archive
assert meta['zip_verification']['experiment']=='C65-package' and meta['zip_verification']['job_id']==pack['job_id'] and meta['zip_verification']['all_pass']
assert meta['specialized_correctness']['job_id']=='1591086' and meta['specialized_correctness']['checks']==80100 and meta['specialized_correctness']['all_pass']
with zipfile.ZipFile(pkg_run/'conv.zip') as z:
 assert len(z.infolist())==4 and set(z.namelist())=={'conv/'+n for n in meta['source_hashes']}
 for n,h in meta['source_hashes'].items():assert hashlib.sha256(z.read('conv/'+n)).hexdigest()==h and z.read('conv/'+n)==(pkg_run/'source'/n).read_bytes()
 assert (z.getinfo('conv/run.sh').external_attr>>16)&0o111
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
oldhead=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
others={k:v for k,v in read(DST/'records/best.json').items() if k!='conv'}
attach=ROOT/'.runs/conv/C65-package/publication-sep13ba-attachments';attach.mkdir(exist_ok=True)
origins={}
for pattern in [prefix+'-*.'+suffix for prefix in ('sep13az','sep13ba') for suffix in ('py','md','json','txt','patch')]:
 for p in (ROOT/'.runs/conv').glob(pattern):
  shutil.copy2(p,attach/p.name);origins[p.name]=str(p.relative_to(ROOT))
for name in ['sep13az-confirmation.py','sep13az-confirmation.unbound.py.txt','sep13az-confirmation.bound.patch','sep13az-root-submit.command.json','sep13az-root-record-compare.command.json','sep13ba-submit-package.py','sep13ba-finalize.py','sep13ba-root-submit.command.json','sep13ba-root-fetch.command.json','sep13ba-root-record.command.json','sep13ba-root-finalize.command.json']:
 assert name in origins,name
write(attach/'ORIGINS.json',origins)
exp=ROOT/'exports/conv-sep13az-ba-final'
subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions','C58-r16','C65-r1','C58-r17','C65-package'],cwd=ROOT,check=True)
assert sorted(p.stem for p in (exp/'records/experiments/conv').glob('*.json'))==sorted(['C58-r16','C65-r1','C58-r17','C65-package'])
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AZ_BA_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13az-ba.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AZ-BA.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists(),q;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AZ-BA.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13az-ba.json'))
for name in ['conv/conv2d.c','outputs/conv-best.zip','outputs/conv-best.json','outputs/conv-best.zip.sha256','records/conv-lineage.json']:
 shutil.copy2(ROOT/name,DST/name)
best=read(DST/'records/best.json');best['conv']='C65-r1';write(DST/'records/best.json',best);assert {k:v for k,v in best.items() if k!='conv'}==others
out=DST/'conv/result/C8';out.mkdir()
shutil.copy2(ROOT/'.runs/conv/C65-package/conv.zip',out/'conv.zip')
with zipfile.ZipFile(out/'conv.zip') as z:
 members={i.filename:dict(sha256=meta['source_hashes'][i.filename.split('/')[-1]],bytes=i.file_size,mode=oct(i.external_attr>>16)) for i in z.infolist()}
package=dict(meta,schema_version=1,problem='conv',version='C8',archive='conv.zip',archive_sha256=meta['package_sha256'],archive_bytes=(out/'conv.zip').stat().st_size,archive_root='conv/',entrypoint='conv/run.sh',archive_members=members,ready_for_manual_submission=True,official_score=None)
write(out/'package.json',package)
write(out/'metadata.json',dict(package,measurement_cases=rec['cases'],package_verification_cases=pack['cases'],competition_feedback=dict(score=None,submitted_at=None,passed=None,notes=None)))
(out/'SHA256SUMS').write_text(meta['package_sha256']+'  conv.zip\n')
gain=(ending['total_median_ms']-rec['total_median_ms'])/ending['total_median_ms']*100
report=f'''# CONV C8：独立确认与原 ZIP 提交包

C8 = C65-r1，源码来自 C65-row7balanced。只将七行组与列片展平，按实际 OpenMP 团队商余数分配连续区间，合并同组连续片；所有 C7 计算 helper 和独立乘加顺序、官方 benchmark/runner 保持原样。公共列片宽度由 single 隐式屏障发布。专项 AX1591086 已通过80100项，九配置SVE16/32/64字节×1/4/38线程；每配置3156例检查逐输出恰好写一次，累计110027484个输出无地址错误。实际helper仍2448指令、9读15写Z栈访问、720B+3VL；不宣称无spill。

AY1591187初筛与AZ1591241独立确认各36/36 PASS、最大误差0，两轮分别比较，不混用样本。独立确认前控/候选/后控合计中位数为 {opening['total_median_ms']:.2f} / {rec['total_median_ms']:.2f} / {ending['total_median_ms']:.2f} ms；相对后控耗时减少 {gain:.4f}%。两端原标准比较均通过：总收益严格超过max(1%,所有逐例波动)，每例退化不超过1%。所有慢样本保留。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:report+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in c['times_ms']) for c in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
report+='\nLOCAL_USER 用例 LOCAL_USER 后控 C7 中位 ms LOCAL_USER C8 中位 ms LOCAL_USER 耗时减少 LOCAL_USER\nLOCAL_USER --- LOCAL_USER ---: LOCAL_USER ---: LOCAL_USER ---: LOCAL_USER\n'
for label,base_case,case in zip('ABCD',ending['cases'],rec['cases']):
 report+=f'LOCAL_USER {label} LOCAL_USER {base_case["median_ms"]:.2f} LOCAL_USER {case["median_ms"]:.2f} LOCAL_USER {(base_case["median_ms"]-case["median_ms"])/base_case["median_ms"]*100:.4f}% LOCAL_USER\n'
report+=f'\n后控比较原波动/最低收益门槛为 {max([1.0]+[x["spread_pct"] for x in ending["cases"]+rec["cases"]]):.4f}%；负的逐例收益表示该例退化，仍保留并按原门槛判断。\n'
report+=f'''
最终原 ZIP 在独立计算节点作业 {pack['job_id']} 核对哈希、解压后三套官方测试12/12 PASS、最大误差0，合计 {pack['total_median_ms']:.2f} ms；job/system/wrapper全0。沿用 GCC10.3.1、generic、38线程、24576MiB、单packed NUMA和1800秒以及严格乘加设置。包复验不用于跨分配推算收益；耗时为内部指标，不是官方分数。

直接下载 [C8/conv.zip](../conv/result/C8/conv.zip) 原样提交，无需重新压缩。当前只保留每题最佳 ZIP，旧 C7 包可从 Git 历史取回，[C7历史确认与原包报告](CONV_SEP13AK_AL.md) 保留。正式平台由队友手动提交，分数及反馈等待实际返回。

[AX/AY记录](CONV_SEP13AX_AY.md) · [AZ/BA逐版本记录](CONV_SEP13AZ_BA_ROUND_RECORDS.md) · [独立确认原记录](../records/experiments/conv/C65-r1.json) · [原ZIP验证记录](../records/experiments/conv/C65-package.json) · [公开证据说明](../PUBLICATION-CONV-SEP13AZ-BA.md)
'''
(DST/'docs/CONV_SEP13AZ_BA.md').write_text(report)
(out/'README.md').write_text(f'''# CONV C8 提交包

下载 [conv.zip](conv.zip) 原样提交，无需重新压缩。C8 = C65-r1（源码 C65-row7balanced），只改变七行组/列片的线程分派，C7计算helper保持不变。

独立同分配确认 {ending['total_median_ms']:.2f} → {rec['total_median_ms']:.2f} ms，耗时减少 {gain:.4f}%；AY/AZ各36/36 PASS，专项80100项通过。最终原 ZIP 作业 {pack['job_id']} 解压后三轮12/12 PASS、最大误差0，合计 {pack['total_median_ms']:.2f} ms。耗时不是官方分数。

[完整报告](../../../docs/CONV_SEP13AZ_BA.md) · [元数据与反馈](metadata.json) · [成员清单](package.json)

正式平台由队友提交，请反馈C8版本、分数、时间、通过状态和错误信息。
''')
(DST/'conv/result/README.md').write_text(f'''# CONV 当前最佳提交包

当前版本 **C8 = C65-r1**（源码 C65-row7balanced）。直接下载 [C8/conv.zip](C8/conv.zip) 原样提交，无需重新压缩。

独立确认 **{ending['total_median_ms']:.2f} → {rec['total_median_ms']:.2f} ms**，耗时减少 **{gain:.4f}%**；最终原ZIP计算节点解压后三轮 **12/12 PASS、最大误差0**，包验证合计 **{pack['total_median_ms']:.2f} ms**。内部指标，非官方分数。

[C8版本说明](C8/README.md) · [元数据与反馈](C8/metadata.json) · [完整报告](../../docs/CONV_SEP13AZ_BA.md) · [C7历史报告](../../docs/CONV_SEP13AK_AL.md)。历史策略与样本保留，当前仅交付C8包。
''')
shutil.rmtree(DST/'conv/result/C7')
p=DST/'SUBMISSIONS.md';text=p.read_text();oldrow='LOCAL_USER CONV LOCAL_USER C7 / C58-r1（来源 C58-row7boundaryu2）'
assert oldrow in text
text=text.replace(oldrow,'LOCAL_USER CONV LOCAL_USER C8 / C65-r1（来源 C65-row7balanced）').replace('conv/result/C7/','conv/result/C8/')
text,n=re.subn(r'CONV C7 独立确认[^；]+；最终 ZIP[^；]+；',f'CONV C8 独立确认较 C7 耗时减少{gain:.4f}%；最终 ZIP 三轮复验12/12 PASS、最大误差0，合计中位耗时{pack["total_median_ms"]:.2f} ms；',text);assert n==1;p.write_text(text)
p=DST/'README.md';text=p.read_text();assert '当前仅提供 CONV C7、ZGEMM Z1、TRSM T19' in text
text=text.replace('当前仅提供 CONV C7、ZGEMM Z1、TRSM T19','当前仅提供 CONV C8、ZGEMM Z1、TRSM T19').replace('conv/result/C7/','conv/result/C8/').replace('**当前 C7 直接提交','**当前 C8 直接提交')
start=text.index('## 当前 CONV C7');end=text.index('## 先把环境跑通',start)
text=text[:start]+f'## 当前 CONV C8\n\n独立确认{ending["total_median_ms"]:.2f} → {rec["total_median_ms"]:.2f} ms，耗时减少 **{gain:.4f}%**；最终原ZIP三轮12/12 PASS、误差0。此前C7报告为历史记录，当前以C8为准。[提交包](conv/result/C8/conv.zip) · [完整报告](docs/CONV_SEP13AZ_BA.md)。\n\n'+text[end:]
text=text.replace('[C7完整报告]','[C7历史完整报告]').replace('[C7逐版本记录]','[C7历史逐版本记录]')
text+='\n当前最佳 CONV 已晋级 C8；本文此前各轮“保留C7/提交C7”均为历史结论，当前提交入口以C8为准。[C8完整确认与原ZIP](docs/CONV_SEP13AZ_BA.md)。\n';p.write_text(text)
p=DST/'records/SUMMARY.md';p.write_text(p.read_text()+f'\nCONV 2026-09-13 晋级 **C8 = C65-r1**：独立确认{ending["total_median_ms"]:.2f}→{rec["total_median_ms"]:.2f} ms，减少{gain:.4f}%，36/36 PASS；最终原ZIP作业{pack["job_id"]}三轮12/12 PASS、误差0，合计{pack["total_median_ms"]:.2f} ms。此前C7为历史最佳；仅交付C8，ZGEMM Z1/TRSM T19保留。[完整报告](../docs/CONV_SEP13AZ_BA.md)。\n')
# Restrict staged candidates and verify other problems by bytes, never TRSM hashes.
paths=set(subprocess.check_output(['git','diff','--name-only'],cwd=DST,text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=DST,text=True).splitlines())
paths.add('conv/result/C8/conv.zip')
for name in paths:
 assert not name.startswith(('trsm/','zgemm/','tools/','config/','tests/')),name
 assert not name.startswith('conv/') or name=='conv/conv2d.c' or name.startswith(('conv/result/C7/','conv/result/C8/')) or name=='conv/result/README.md',name
 assert not name.startswith('outputs/') or name in ['outputs/conv-best.zip','outputs/conv-best.json','outputs/conv-best.zip.sha256'],name
 p=DST/name
 if p.is_file() and p.suffix!='.zip':
  txt=p.read_text();assert not re.search(r'LOCAL_USER_HOMECLUSTER_USER_HOME\b10\.44\.9\.4\b|\bhuzhenghong\b|\blingsu011900\b|\bcn\d{4,}\b|\blogin\d+\b',txt),name
  assert not re.search(r'(?i)(?:password|passwd|api_key|access_token)\s*[:=]LOCAL_USER-----BEGIN (?:OPENSSH|RSA|EC) PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}',txt),name
for name in ['zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']:
 assert (DST/name).read_bytes()==subprocess.check_output(['git','show',oldhead+':'+name],cwd=DST)
for name in ['docs/CONV_SEP13AK_AL.md','docs/CONV_SEP13AK_AL_ROUND_RECORDS.md']:
 assert (DST/name).read_bytes()==subprocess.check_output(['git','show',oldhead+':'+name],cwd=DST)
assert sorted(str(p.relative_to(DST)) for p in DST.glob('*/result/**/*.zip'))==['conv/result/C8/conv.zip','trsm/result/T19/trsm.zip','zgemm/result/Z1/zgemm.zip']
assert (out/'conv.zip').read_bytes()==(ROOT/'.runs/conv/C65-package/conv.zip').read_bytes()==(DST/'outputs/conv-best.zip').read_bytes()
write(ROOT/'.runs/conv/sep13ba-publication-prepared.json',dict(base_head=oldhead,paths=sorted(paths),files=len(paths),other_best_preserved=others,official_submission=False))
print('Prepared C8 publication:',len(paths),'exact paths; other packages retained byte-for-byte.')
