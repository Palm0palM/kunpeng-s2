"""Prepare reviewed C7 files after actual promotion; no Git mutation or tests."""
from pathlib import Path
import json,shutil,subprocess,sys,zipfile,re
ROOT=Path(__file__).resolve().parents[2]
DST=ROOT/'.runs/conv/publish-sep12'
def read(p):return json.loads(p.read_text())
def write(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
meta=read(ROOT/'outputs/conv-best.json');assert meta['label']=='C7'
rec=read(ROOT/'records/experiments/conv/C58-r1.json');pack=read(ROOT/'records/experiments/conv/C58-package.json')
assert rec['confirmation_passed'] and rec['promoted_at'] and pack['verified']
assert subprocess.check_output(['git','status','--porcelain'],cwd=DST)==b''
oldhead=subprocess.check_output(['git','rev-parse','HEAD'],cwd=DST,text=True).strip()
others={k:v for k,v in read(DST/'records/best.json').items() if k!='conv'}
attach=ROOT/'.runs/conv/C58-package/publication-sep13al-attachments';attach.mkdir(exist_ok=True)
origins={}
for pattern in ['sep13al-*.py','sep13al-*.md','sep13al-*.json','sep13al-*.txt']:
 for p in (ROOT/'.runs/conv').glob(pattern):
  shutil.copy2(p,attach/p.name);origins[p.name]=str(p.relative_to(ROOT))
write(attach/'ORIGINS.json',origins)
exp=ROOT/'exports/conv-sep13ak-al-final'
subprocess.run([sys.executable,'tools/export_conv_records.py','--output',str(exp),'--versions','C26-r38','C58-r1','C26-r39','C58-package'],cwd=ROOT,check=True)
renames={'docs/CONV_ROUND_RECORDS.md':'docs/CONV_SEP13AK_AL_ROUND_RECORDS.md','records/conv-publication.json':'records/conv-publication-sep13ak-al.json','PUBLICATION-CONV.md':'PUBLICATION-CONV-SEP13AK-AL.md'}
for p in exp.rglob('*'):
 if p.is_file():
  name=p.relative_to(exp).as_posix();q=DST/renames.get(name,name);assert not q.exists(),q;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
p=DST/'PUBLICATION-CONV-SEP13AK-AL.md';p.write_text(p.read_text().replace('records/conv-publication.json','records/conv-publication-sep13ak-al.json'))
for name in ['conv/conv2d.c','outputs/conv-best.zip','outputs/conv-best.json','outputs/conv-best.zip.sha256','records/conv-lineage.json']:
 shutil.copy2(ROOT/name,DST/name)
best=read(DST/'records/best.json');best['conv']='C58-r1';write(DST/'records/best.json',best);assert {k:v for k,v in best.items() if k!='conv'}==others
out=DST/'conv/result/C7';out.mkdir()
shutil.copy2(ROOT/'.runs/conv/C58-package/conv.zip',out/'conv.zip')
with zipfile.ZipFile(out/'conv.zip') as z:
 members={i.filename:dict(sha256=meta['source_hashes'][i.filename.split('/')[-1]],bytes=i.file_size,mode=oct(i.external_attr>>16)) for i in z.infolist()}
package=dict(meta,schema_version=1,problem='conv',version='C7',archive='conv.zip',archive_sha256=meta['package_sha256'],archive_bytes=(out/'conv.zip').stat().st_size,archive_root='conv/',entrypoint='conv/run.sh',archive_members=members,ready_for_manual_submission=True,official_score=None)
write(out/'package.json',package)
write(out/'metadata.json',dict(package,measurement_cases=rec['cases'],package_verification_cases=pack['cases'],competition_feedback=dict(score=None,submitted_at=None,passed=None,notes=None)))
(out/'SHA256SUMS').write_text(meta['package_sha256']+'  conv.zip\n')
report=f'''# CONV C7：独立确认与最终提交包

C7 = C58-r1，源码来自 C58-row7boundaryu2。七行共享、三个 SVE 向量累加，共享区按两列展开，十二处边界循环要求 GCC 展开两列。保留参考的逐项乘法和加法顺序，未启用 FMA；官方 benchmark、runner、输入和精度条件保持原样。

初筛作业1583408：C6 / C58 / C6 合计中位数452.41 / 437.56 / 452.42 ms。独立确认1583680：452.26 / 437.56 / 452.27 ms；相对两端控制分别减少3.2503% / 3.2525%。两轮各36/36 PASS、最大误差0，分开判断，不混用样本。确认最大样本波动0.9645%，两端比较均通过原有1%最低收益门槛。

LOCAL_USER 用例 LOCAL_USER 确认结束 C6 ms LOCAL_USER C7 ms LOCAL_USER 耗时减少 LOCAL_USER
LOCAL_USER --- LOCAL_USER ---: LOCAL_USER ---: LOCAL_USER ---: LOCAL_USER
LOCAL_USER A LOCAL_USER 51.43 LOCAL_USER 51.84 LOCAL_USER -0.80% LOCAL_USER
LOCAL_USER B LOCAL_USER 61.91 LOCAL_USER 58.39 LOCAL_USER 5.69% LOCAL_USER
LOCAL_USER C LOCAL_USER 107.27 LOCAL_USER 104.15 LOCAL_USER 2.91% LOCAL_USER
LOCAL_USER D LOCAL_USER 231.66 LOCAL_USER 223.18 LOCAL_USER 3.66% LOCAL_USER
LOCAL_USER 合计 LOCAL_USER 452.27 LOCAL_USER 437.56 LOCAL_USER 3.25% LOCAL_USER

A略有退化，未超过原规则1%上限；所有52.24ms等慢样本保留。耗时为四组独立三轮套件的逐用例中位数合计，是内部指标，不是官方分数或排名。

最终原 ZIP 在计算节点作业{pack['job_id']}校验、解压后运行三轮，12/12 PASS、最大误差0，合计{pack['total_median_ms']:.2f} ms；调度器、系统和wrapper退出码均0。沿用 GCC10.3.1、generic、38线程、单NUMA、24576MiB与严格乘加设置。提交包验证不用于跨分配推算收益。

此前专项作业1583350已通过44328项，覆盖三种SVE长度和1/4线程。实际汇编有边界路径向量寄存器栈访问，未宣称无spill；细节见 [专项报告](CONV_SEP13AH.md)。历史C51/C52确认失败和C54/C55/C56退化、C57数值失败记录保留。

本轮首次取回因SSH会话过期失败，恢复已有账号会话后只取回原1583680，没有重复运行确认。保留原命令输出及失败记录。本机仅编辑、连接、传输、打包与整理日志，没有编译或运行算子。

直接下载 [conv/result/C7/conv.zip](../conv/result/C7/conv.zip) 原样提交。只保留当前最佳包；旧C6包可从Git历史取回。正式比赛由队友提交，分数与平台状态待反馈。

[逐版本记录](CONV_SEP13AK_AL_ROUND_RECORDS.md) · [确认原始样本公开副本](../records/experiments/conv/C58-r1.json) · [最终包验证记录](../records/experiments/conv/C58-package.json) · [公开证据说明](../PUBLICATION-CONV-SEP13AK-AL.md)
'''
(DST/'docs/CONV_SEP13AK_AL.md').write_text(report)
(out/'README.md').write_text(f'''# CONV C7 提交包

下载 [conv.zip](conv.zip) 原样提交，无需重新压缩。

C7 = C58-r1（源码 C58-row7boundaryu2）：七行共享、两列展开、边界循环展开。独立同分配确认452.27 → 437.56 ms，耗时减少3.25%；A退化0.80%，其余三例改善。两轮各36/36 PASS，专项44328项通过。

最终原 ZIP 作业{pack['job_id']}独立解压三轮12/12 PASS，最大误差0，合计{pack['total_median_ms']:.2f} ms。GCC10.3.1，38线程单NUMA。耗时为内部指标，非官方分数。

[完整报告](../../../docs/CONV_SEP13AK_AL.md) · [元数据与平台反馈](metadata.json) · [成员清单](package.json)

正式平台由队友提交；请反馈版本C7、分数、时间、通过状态和错误信息。
''')
shutil.rmtree(DST/'conv/result/C6')
p=DST/'SUBMISSIONS.md';s=p.read_text().replace('C6 / C26-r1（来源 C26-row4loads）','C7 / C58-r1（来源 C58-row7boundaryu2）').replace('conv/result/C6/','conv/result/C7/').replace('CONV C6 的最终 ZIP 三轮复验 12/12 PASS、最大误差 0，合计中位耗时 452.66 ms',f'CONV C7 独立确认较 C6 耗时减少3.25%；最终 ZIP 三轮复验12/12 PASS、最大误差0，合计中位耗时{pack["total_median_ms"]:.2f} ms');p.write_text(s)
p=DST/'README.md';s=p.read_text().replace('当前仅提供 CONV C6、ZGEMM Z1、TRSM T19','当前仅提供 CONV C7、ZGEMM Z1、TRSM T19');s=s.replace('conv/result/C6/','conv/result/C7/');s=s.replace('2026-09-12 最新 CONV 为 **C6','2026-09-12 历史 CONV 为 **C6');s=s.replace('**直接提交 [conv/result/C7/conv.zip]', '**当前 C7 直接提交 [conv/result/C7/conv.zip]');s=s.replace('## 先把环境跑通','## 当前 CONV C7\n\n独立确认452.27 → 437.56 ms，耗时减少 **3.25%**；最终原ZIP三轮12/12 PASS、误差0。上面的C6结论为历史记录，当前以C7为准。[提交包](conv/result/C7/conv.zip) · [完整报告](docs/CONV_SEP13AK_AL.md)。\n\n## 先把环境跑通',1);p.write_text(s)
p=DST/'records/SUMMARY.md';p.write_text(p.read_text()+f'\nCONV 2026-09-13 晋级 **C7 = C58-r1**：独立确认452.27→437.56 ms，减少3.25%，36/36 PASS；最终原ZIP作业{pack["job_id"]}三轮12/12 PASS、误差0，合计{pack["total_median_ms"]:.2f} ms。此前C6为历史最佳；仅交付C7，ZGEMM Z1/TRSM T19保留。[完整报告](../docs/CONV_SEP13AK_AL.md)。\n')
# Restrict staged candidates and verify other problems by bytes, never TRSM hashes.
paths=set(subprocess.check_output(['git','diff','--name-only'],cwd=DST,text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=DST,text=True).splitlines())
paths.add('conv/result/C7/conv.zip')
for name in paths:
 assert not name.startswith(('trsm/','zgemm/','tools/','config/','tests/')),name
 p=DST/name
 if p.is_file() and p.suffix!='.zip':
  txt=p.read_text();assert not re.search(r'LOCAL_USER_HOMECLUSTER_USER_HOME\b10\.44\.9\.4\b|\bhuzhenghong\b|\blingsu011900\b|\bcn\d{4,}\b|\blogin\d+\b',txt),name
  assert not re.search(r'(?i)(?:password|passwd|api_key|access_token)\s*[:=]LOCAL_USER-----BEGIN (?:OPENSSH|RSA|EC) PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{20,}',txt),name
for name in ['zgemm/result/Z1/zgemm.zip','trsm/result/T19/trsm.zip']:
 assert (DST/name).read_bytes()==subprocess.check_output(['git','show',oldhead+':'+name],cwd=DST)
assert (out/'conv.zip').read_bytes()==(ROOT/'.runs/conv/C58-package/conv.zip').read_bytes()==(DST/'outputs/conv-best.zip').read_bytes()
write(ROOT/'.runs/conv/sep13al-publication-prepared.json',dict(base_head=oldhead,paths=sorted(paths),files=len(paths),other_best_preserved=others,official_submission=False))
print('Prepared C7 publication:',len(paths),'exact paths; other packages retained byte-for-byte.')
