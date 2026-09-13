"""Publishable AJ/AM evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
plan=read(ROOT/'.runs/conv/sep13am-campaign.json');assert plan['status']=='complete'
names=plan['measurement_order'];records=[read(ROOT/'records/experiments/conv'/(n+'.json')) for n in names];rec=records[1]
assert all(r['verified'] for r in records) and read(DST/'records/best.json')['conv']=='C58-r1'
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13am-attachments';a.mkdir(exist_ok=True);origins={}
for pattern in ['sep13am-*.py','sep13am-*.md','sep13am-*.json','sep13am-*.txt']:
 for p in (ROOT/'.runs/conv').glob(pattern):shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13aj-am-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AJ_AM_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13aj-am.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AJ-AM.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AJ-AM.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13aj-am.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C59 单处边界展开调整：AJ专项与AM性能

C59-row7boundaryu2nofive只撤掉C7源码input_5前的一条unroll2提示，其余11条边界提示、共享两列/余一列、每输出的原始乘加顺序、benchmark和runner保持原样。

AJ原作业1589289通过44328项（六配置：SVE16/32/64字节×1/4线程），19阶段、job/system/wrapper全0。GCC10.3.1 strict/generic。实际input_5成为单列55指令、18FMUL/18FADD，原成对迭代3次Z读3次Z写消失；共享2列/余1列仍无Zspill。helper含ret2270条，父2448条；帧720B+2VL，父720B+3VL；全helper仍有6读12写Z栈访问，均为静态数。目标汇编原件、独立及root分析随记录保存，未宣称全部spill消失。

AM原作业{plan['performance_job']}：同一38CPU、24576MiB、单packed NUMA，GCC10.3.1/generic/38线程。C7前控 / C59 / C7后控三套完整官方测试各12例，合计36/36 PASS、误差0。合计中位数依次{totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时减少{gain:.4f}%。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='创建元数据初审发现AM工具会错误要求creation与后续扩展meta逐字相同，已在提交前修复：保留creation原件并新增pre-am快照。本轮没有因此提交失败或重跑。官方规则与数值门槛未改。本机未编译或运行算子，未使用重置卡。\n\n[逐版本记录](CONV_SEP13AJ_AM_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C59-row7boundaryu2nofive.json) · [当前C7提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AJ_AM.md').write_text(doc)
notice=f'\nCONV C59 撤掉一处边界展开提示：AJ44328项通过，AM36/36 PASS，合计{totals[1]:.2f}ms，相对结束C7控制{totals[-1]:.2f}ms减少{gain:.4f}%。{decision}。目标spill确实减少，但晋级仍以完整测量门槛为准。[本轮记录](docs/CONV_SEP13AJ_AM.md)。\n'
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
(ROOT/'.runs/conv/sep13am-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AJ/AM paths; best C7/Z1/T19 retained unchanged.')
