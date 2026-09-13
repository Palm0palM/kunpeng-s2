"""Publishable AN/AO evidence preparation after original comparison; no Git writes."""
from pathlib import Path
import json,shutil,subprocess,sys,re
ROOT=Path(__file__).resolve().parents[2];DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
plan=read(ROOT/'.runs/conv/sep13ao-campaign.json');assert plan['status']=='complete'
names=plan['measurement_order'];records=[read(ROOT/'records/experiments/conv'/(n+'.json')) for n in names];rec=records[1]
assert all(r['verified'] for r in records) and read(DST/'records/best.json')['conv']=='C58-r1'
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
a=ROOT/'.runs/conv'/names[0]/'publication-sep13ao-attachments';a.mkdir(exist_ok=True);origins={}
for pattern in ['sep13ao-*.py','sep13ao-*.md','sep13ao-*.json','sep13ao-*.txt']:
 for p in (ROOT/'.runs/conv').glob(pattern):shutil.copy2(p,a/p.name);origins[p.name]=str(p.relative_to(ROOT))
(a/'ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
exp=ROOT/'exports/conv-sep13an-ao-final';subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions',*names],cwd=ROOT,check=True)
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AN_AO_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13an-ao.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AN-AO.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists();q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AN-AO.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13an-ao.json'))
totals=[r['total_median_ms'] for r in records];gain=(totals[-1]-totals[1])/totals[-1]*100
change=f'减少{gain:.4f}%' if gain>=0 else f'增加{-gain:.4f}%'
decision='初筛通过，仍须独立确认，当前继续提交C7' if rec['qualified_for_confirmation'] else '未通过初筛，保留C7'
doc=f'''# C60 相邻列输入向量复用：AN专项与AO性能

C60-row7shared2ext只调整共享两列的输入加载：3个完整向量和一个仅首元素活跃的tail，通过3次EXT构造第二列。全部12条边界提示、余一列、每输出的原始乘加顺序、benchmark和runner保持原样。

AN原作业1589554通过44328项（六配置：SVE16/32/64字节×1/4线程），19阶段、job/system/wrapper全0。GCC10.3.1 strict/generic。实际共享两列主循环为127指令、4LD1W、14LD1RW、42FMUL/42FADD、3EXT与3MOVPRFX，主循环无Zspill；tail用仅第一float活跃的p1。父C7主循环123指令、6LD1W。helper含ret2432条，父2448条；帧704B+3VL，父720B+3VL；全helper仍有9读15写Z栈访问，均为静态数。目标汇编原件、独立及root分析随记录保存，未宣称全部spill消失。

AO原作业{plan['performance_job']}：同一38CPU、24576MiB、单packed NUMA，GCC10.3.1/generic/38线程。C7前控 / C60 / C7后控三套完整官方测试各12例，合计36/36 PASS、误差0。合计中位数依次{totals[0]:.2f} / {totals[1]:.2f} / {totals[2]:.2f} ms，较结束控制耗时{change}。{decision}。

LOCAL_USER 版本 LOCAL_USER A三次ms LOCAL_USER B三次ms LOCAL_USER C三次ms LOCAL_USER D三次ms LOCAL_USER 合计中位ms LOCAL_USER
LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER --- LOCAL_USER ---: LOCAL_USER
'''
for r in records:doc+='LOCAL_USER '+r['version']+' LOCAL_USER '+' LOCAL_USER '.join('/'.join(f'{x:.2f}' for x in case['times_ms']) for case in r['cases'])+f' LOCAL_USER {r["total_median_ms"]:.2f} LOCAL_USER\n'
doc+='\n两端分别调用未修改的标准比较：总收益须严格超过max(1%,全部逐例波动)，任一例不可退化超过1%。全部样本保留，没有与其他分配混算；不是官方分数。\n\n'
for field,label in [('opening_control_comparison','前控'),('comparison','后控')]:
 verdict=rec[field];doc+=label+'结论：'+str(verdict['eligible'])+'；'+('; '.join(verdict['reasons']) or '全部原门槛通过')+'。\n\n'
doc+='AO沿用已验证AM工作流；提交前审查补齐本候选creation-experiment-original.json识别，保留标准new原件并将扩展meta另存pre-ao快照。本轮没有因此提交失败或重跑。官方规则与数值门槛未改。本机未编译或运行算子，未使用重置卡。\n\n[逐版本记录](CONV_SEP13AN_AO_ROUND_RECORDS.md) · [原始数值公开副本](../records/experiments/conv/C60-row7shared2ext.json) · [当前C7提交包](../conv/result/C7/conv.zip)\n'
(DST/'docs/CONV_SEP13AN_AO.md').write_text(doc)
notice=f'\nCONV C60 相邻列输入复用：AN44328项通过，AO36/36 PASS，合计{totals[1]:.2f}ms，相对结束C7控制{totals[-1]:.2f}ms耗时{change}。{decision}。目标输入加载确实减少，但晋级仍以完整测量门槛为准。[本轮记录](docs/CONV_SEP13AN_AO.md)。\n'
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
(ROOT/'.runs/conv/sep13ao-publication-prepared.json').write_text(json.dumps(dict(base_head=head,paths=sorted(paths),files=len(paths),best_retained='C7'),indent=2)+'\n')
print('Prepared',len(paths),'AN/AO paths; best C7/Z1/T19 retained unchanged.')
