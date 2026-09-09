#!/usr/bin/env python3
"""Archive captured text and record this stopped cohort without any hashing."""
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import shutil

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
ARCHIVE=ROOT/'records/evidence/trsm-sve-20260909/parameter-guard-stopped'
NAMES=['T1-control4','T3-svepanel-r1','T3-sveupdate-r1']
now=datetime.now(timezone.utc).isoformat()
ARCHIVE.mkdir(parents=True,exist_ok=True)
for relative in json.loads((HERE/'remote-text-inventory.json').read_text()):
    target=ARCHIVE/relative
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(HERE/'retrieved-text'/relative,target)
for name in ['cohort-submission.json','cohort-config.json','cohort_driver.py','submit_cohort.py',
             'submit.log','upload.log','scheduler-status.txt','scheduler-status-parsed.json',
             'scheduler-status-command.json','scheduler-status-initial-sandbox-denied.txt',
             'remote-text-inventory.json','text-collection-commands.json',
             'collect-stopped-text-nohash.py','archive-stopped-nohash.py']:
    source=HERE/name
    if source.exists():shutil.copy2(source,ARCHIVE/name)

preflight=(ARCHIVE/'preflight.log').read_text()
wrapper=(ARCHIVE/'wrapper.stdout.log').read_text()
summary={
 'job_id':'1492058','cohort_id':'trsm-cohort-c5c8ab4768a3',
 'scheduler':json.loads((HERE/'scheduler-status-parsed.json').read_text()),
 'preflight_complete':'TRSM_PREFLIGHT_COMPLETE=1' in preflight,
 'microkernel_invocations':len(re.findall(r'^PASS 30 direct SVE',preflight,re.M)),
 'microkernel_combinations_per_invocation':30,
 'known_solution_suites':len(re.findall(r'^TRSM 10 known-solution cases and 4 no-op boundaries PASS;',preflight,re.M)),
 'known_solution_cases_per_suite':10,'no_op_boundaries_per_suite':4,
 'sve_kernel_actual_entries':[int(x) for x in re.findall(r'^SVE_KERNEL_ACTUAL_ENTRIES=(\d+)$',preflight,re.M)],
 'entry_order':['panel_threads1','panel_threads4','update_threads1','update_threads4'],
 'official_rounds_started':len(re.findall(r'^BENCH_REPEAT ',wrapper,re.M)),
 'official_measurements':[],
 'stop_reason':"All members require TEST_RUNS=3",
 'hash_policy':{'calculation_performed':False,'verification_performed':False,
                'existing_hash_values':'Historical metadata retained without revalidation'},
 'recorded_at':now
}
(ARCHIVE/'preflight-summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
(HERE/'preflight-summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
failure='1492058 的两候选 SVE 实机预检查全部 PASS，但 cohort 在官方计时前因 TEST_RUNS 未显式设置为 3 被参数检查拒绝；调度器 FAILED，退出码 125，零官方成绩。'
for name in NAMES:
    path=ROOT/'records/experiments/trsm'/f'{name}.json'
    record=json.loads(path.read_text())
    if record.get('status') not in ['prepared','planned']:
        raise SystemExit('Refusing to overwrite already finalized record: '+name)
    before=ARCHIVE/'records-before'/path.name
    before.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(path,before)
    record.update(status='failed',verified=False,recorded_at=now,updated_at=now,
                  job_id='1492058',failure=failure,
                  note='预检查完成后在官方计时前停止；按用户新要求直接登记 no-hash 失败 JSON，未调用会计算哈希的 experiment.py record。',
                  environment='COMPUTE_NODE_1-cpu342-379-single-numa-gcc10.3.1-generic-38-preflight-only-job1492058',
                  reference='TRSM preflight uses standalone known solutions and ordered scalar FMA; OpenBLAS 0.3.28 static USE_OPENMP ARMV8 MAX_THREADS=38 availability probe passed. Official KML module root/header/library unavailable. No official benchmark or KML revalidation occurred.',
                  log='records/evidence/trsm-sve-20260909/parameter-guard-stopped/wrapper.stdout.log',
                  scheduler_status='records/evidence/trsm-sve-20260909/parameter-guard-stopped/scheduler-status.txt',
                  preflight_summary='records/evidence/trsm-sve-20260909/parameter-guard-stopped/preflight-summary.json',
                  official_benchmark_started=False,official_measurements=[],
                  registration_method='direct-json-no-hash-per-user-instruction',
                  hash_policy={'calculation_performed':False,'verification_performed':False,
                               'source_hashes':'Preserved from existing prepared record; not recomputed or checked against current/remote files'})
    path.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
    after=ARCHIVE/'experiment-records'/path.name
    after.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(path,after)
(ARCHIVE/'file-inventory-nohash.json').write_text(json.dumps({
 'policy':'Path inventory only. No hashes calculated or verified; old digest fields in original metadata are historical.',
 'files':[str(p.relative_to(ARCHIVE)) for p in sorted(ARCHIVE.rglob('*')) if p.is_file()]},indent=2)+'\n')
print(json.dumps(summary,ensure_ascii=False,indent=2))
print('Recorded failed:',', '.join(NAMES))
