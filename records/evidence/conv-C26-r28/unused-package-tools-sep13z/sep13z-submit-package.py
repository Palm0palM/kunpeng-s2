"""Prepared C52 exact-ZIP verification; explicit root --go only.

No source/run/reservation/ZIP/SSH at preparation or import. W48 initial and
Y36 confirmation must separately pass their own two unchanged C6 controls.
A missing, incomplete or failed Y blocks package creation. No retry, follow-up,
recording, promotion, publication or official submission is performed here.
"""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster as c
import experiment as e

# Definition reuse from reviewed W only; never import or execute U.
# W supplies C52's actual T gate, settings and bounded query definitions.
spec = importlib.util.spec_from_file_location('sep13z_w_definitions', Path(__file__).with_name('sep13w-submit-performance.py'))
w = importlib.util.module_from_spec(spec)
spec.loader.exec_module(w)
VERSION = 'C52-package'
SOURCE_VERSION = 'C52-row7x3shared2'
CONFIRMATION = 'C52-r1'
CONFIRMATION_JOB = '1582410'  # Actual original Y reservation, independently read after root submit.
W_ORDER = ['C26-r26', SOURCE_VERSION, 'C51-r2', 'C26-r27']
Y_ORDER = ['C26-r28', CONFIRMATION, 'C26-r29']
DIMS = [[4096,6144,39,39], [6144,4096,41,41], [4256,6390,55,55], [6390,4256,81,81]]
CHECKS = {'scheduler','fetched_log','benchmark','wrapper','source_hashes','machine'}
SOURCE_NAMES = {'README.md','bench_conv.c','conv2d.c','run.sh'}
T_DIRECTORY = '.runs/conv/C52-row7x3shared2/sve-correctness-sep13t'
SOURCE_SHA256 = '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'


def unchanged_best():
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    current = e.source_files(ROOT / 'conv')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert e.read_json(ROOT / 'records/best.json')['conv'] == 'C26-r1'
    assert current == e.get_record('conv','C26-r1')['source_hashes']
    assert current == e.get_record('conv','C26-row4loads')['source_hashes']
    assert set(current) == SOURCE_NAMES
    return current


def verify_original_record(name, plan, order):
    """Read every original sample and saved artifact; never rewrite a record."""
    run = ROOT / '.runs/conv' / name
    rec = e.get_record('conv', name)
    manifest = e.read_json(run / 'cluster.json')
    assert rec['problem'] == 'conv' and rec['version'] == name
    assert rec['status'] == 'passed' and rec['verified'] is True and rec['repeats'] == 3
    assert set(rec['checks']) == CHECKS and all(value is True for value in rec['checks'].values())
    assert rec['settings'] == manifest['settings'] == plan['settings']
    assert rec['environment'] == plan['record_environment'] and rec['reference'] == plan['record_reference']
    assert rec['job_id'] == manifest['job_id'] == plan['performance_job']
    assert manifest['group'] == plan['performance_group']
    assert manifest['group_index'] == order.index(name) and manifest['measurement_order'] == order
    scheduler = manifest['scheduler_status']
    assert scheduler['status'] == 'SUCCEEDED' and str(scheduler['jobId']) == plan['performance_job']
    assert type(scheduler['jobExitCode']) is int and type(scheduler['systemExitCode']) is int
    assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
    assert c.parse_scheduler_status((run/'scheduler-status.txt').read_text(), plan['performance_job']) == scheduler
    assert manifest['fetch_state'] == 'complete' and (run/'exit-code.txt').read_text().strip() == '0'
    # Normal fetched-artifact identity checks, not a repository-wide hash audit.
    for filename in ('benchmark.log','environment.log','exit-code.txt','source-sha256.txt'):
        assert e.digest(run/filename) == manifest['artifacts_sha256'][filename], (name, filename)
    source = e.source_files(run/'source')
    assert source == rec['source_hashes'] == manifest['source_hashes'] and set(source) == SOURCE_NAMES
    remote = {}
    for line in (run/'source-sha256.txt').read_text().splitlines():
        m = re.fullmatch(r'([0-9a-f]{64})\s+\*?(?:\./)?(?:source/)?(.+)', line)
        if m:
            assert m[2] not in remote
            remote[m[2]] = m[1]
    assert all(remote.get(filename) == digest for filename,digest in source.items())
    text = (run/'benchmark.log').read_text()
    parsed = e.parse_log('conv', text, 3)
    assert parsed['cases'] == rec['cases'] and parsed['total_median_ms'] == rec['total_median_ms']
    assert [x['dims'] for x in rec['cases']] == DIMS and all(len(x['times_ms']) == 3 for x in rec['cases'])
    assert re.findall(r'^BENCH_REPEAT ([1-3])/3 (BEGIN|END)$', text, re.M) == [(str(i), event) for i in (1,2,3) for event in ('BEGIN','END')]
    assert len(re.findall(r'^BENCH_JOB_BEGIN .+$',text,re.M)) == len(re.findall(r'^BENCH_JOB_END .+$',text,re.M)) == 1
    machine = e.machine_profile(run, text)
    assert machine == rec['machine'] and machine['compiler_banners'] == ['gcc (GCC) 10.3.1']
    assert machine['ARCH'] == 'aarch64' and machine['OMP_NUM_THREADS'] == '38' and machine['CPU_TARGET'] == 'generic'
    assert machine['HOST'] and machine['NUMA_NODE']
    cpus = machine['ALLOWED_CPUS'].split(',')
    assert len(cpus) == len(set(cpus)) == 38 and all(x.isdigit() for x in cpus)
    return rec


def strict_gate(control, candidate, field):
    """Recompute full saved arrays using the unchanged standard comparison."""
    stored = candidate[field]
    assert stored['baseline'] == control['version'] and stored['eligible'] is True
    actual = e.comparison(control, candidate)
    assert actual['eligible'] is True and actual['reasons'] == []
    assert stored['cases'] == actual['cases'] and stored['reasons'] == actual['reasons']
    gain = (control['total_median_ms']-candidate['total_median_ms'])/control['total_median_ms']*100
    threshold = max([1.0]+[case['spread_pct'] for case in control['cases']+candidate['cases']])
    assert gain > threshold and all(case['gain_pct'] >= -1.0 for case in actual['cases'])
    assert stored['total_gain_pct'] == gain and stored['threshold_pct'] == threshold
    return dict(baseline=control['version'],eligible=True,total_gain_pct=gain,threshold_pct=threshold,cases=actual['cases'])


def verified_campaign(round_name, order, candidate_name, expected_cases, baseline_source):
    plan = e.read_json(ROOT / '.runs/conv' / (round_name+'-campaign.json'))
    assert plan['round'] == round_name and plan['status'] == 'performance_complete'
    assert plan['submitted'] is True and plan['submit_attempted'] is True
    assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit() and plan['performance_group']
    assert plan['measurement_order'] == order and plan['candidate_versions'] == [candidate_name]
    assert plan['opening_control'] == order[0] and plan['primary_baseline'] == order[-1]
    assert plan['suites_per_member'] == 3 and plan['expected_benchmark_cases'] == expected_cases
    assert plan['expected_compiler_banners'] == ['gcc (GCC) 10.3.1'] and plan['best_label'] == 'C6'
    assert plan['automatic_confirmation'] is False
    assert plan['automatic_promotion'] is False and plan['automatic_packaging'] is False
    w.verify_settings(plan['settings'])
    records = {name:verify_original_record(name,plan,order) for name in order}
    opening,closing,candidate = records[order[0]],records[order[-1]],records[candidate_name]
    assert all(rec['machine'] == closing['machine'] for rec in records.values())
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == expected_cases
    assert opening['source_hashes'] == closing['source_hashes'] == baseline_source
    assert candidate['reference_only'] is False and candidate['promotion_allowed'] is True
    assert candidate['source_hashes'] == plan['candidate_source_hashes'][candidate_name]
    assert candidate['source_parent'] == plan['source_parents'][candidate_name]
    assert candidate['parent'] == candidate['comparison_baseline'] == order[-1]
    assert all(candidate['source_hashes'][f] == baseline_source[f] for f in ('README.md','bench_conv.c','run.sh'))
    assert candidate['diagnostic_source_version'] == plan['diagnostic_source_versions'][candidate_name] == SOURCE_VERSION
    assert candidate['diagnostic_evidence_directory'] == T_DIRECTORY
    assert str(candidate['diagnostic_job_id']) == '1582134'
    assert candidate['diagnostic_source_sha256'] == candidate['source_hashes']['conv2d.c'] == SOURCE_SHA256
    assert plan['diagnostic_jobs'][candidate_name] == '1582134'
    assert plan['diagnostic_expected_checks'][candidate_name] == 37128
    assert plan['diagnostic_evidence_directories'][candidate_name] == T_DIRECTORY
    gates = [strict_gate(opening,candidate,'opening_control_comparison'), strict_gate(closing,candidate,'comparison')]
    rows = plan['results']
    assert len(rows) == len(order) and [row['version'] for row in rows] == order
    for row in rows:
        rec = records[row['version']]
        assert row['total_median_ms'] == rec['total_median_ms']
        assert row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        if row['version'] == candidate_name:
            assert row['comparison'] == candidate['comparison']
            assert row['opening_control_comparison'] == candidate['opening_control_comparison']
    return plan,records,gates


def preflight():
    baseline = unchanged_best()
    # The original single Y reservation must already have a successful final
    # result. Neither an absent job nor failed confirmation can reach new/ZIP.
    saved_y = e.read_json(ROOT / '.runs/conv/sep13y-campaign.json')
    assert saved_y['performance_job'] == CONFIRMATION_JOB, 'Y identity changed; preserve the original confirmation'
    assert saved_y['status'] == 'performance_complete' and saved_y['confirmation_passed'] is True, 'Original Y is absent/incomplete/failed; never retry confirmation through packaging'
    wp,wr,wg = verified_campaign('sep13w',W_ORDER,SOURCE_VERSION,48,baseline)
    yp,yr,yg = verified_campaign('sep13y',Y_ORDER,CONFIRMATION,36,baseline)
    assert yp == saved_y
    assert wp['performance_job'] == '1582256'
    assert wp['confirmation_pending'] == [SOURCE_VERSION] and wr[SOURCE_VERSION]['qualified_for_confirmation'] is True
    assert wp['prior_decisions_unchanged'] is True and wp['reference_only_versions'] == ['C51-r2']
    reference = wr['C51-r2']
    assert reference['reference_only'] is True and reference['promotion_allowed'] is False
    assert reference['qualified_for_confirmation'] is False and reference['prior_confirmation_passed'] is False
    assert reference['prior_confirmation_job'] == '1582067'
    assert reference['source_hashes'] == e.get_record('conv','C51-row7x3u1')['source_hashes']
    assert wr[SOURCE_VERSION]['source_parent'] == wp['source_parents'][SOURCE_VERSION] == 'C51-row7x3u1'
    assert yp['reference_only_versions'] == [] and yp['confirmation_only'] is True
    assert yp['confirmation_passed'] is True and yr[CONFIRMATION]['confirmation_passed'] is True
    assert yp['samples_mixed_with_initial_round'] is False and yp['confirmation_pending'] == []
    assert yp['prior_decisions_unchanged'] is True and yr[CONFIRMATION]['qualified_for_confirmation'] is False
    assert yp['prior_job'] == '1582256' and yp['prior_campaign'] == '.runs/conv/sep13w-campaign.json'
    assert yp['initial_qualification_version'] == SOURCE_VERSION and yp['initial_qualification_passed'] is True
    assert yp['failed_confirmation_retry_allowed'] is False
    assert yp['performance_job'] not in ('1582256','1582134','1582067','1582372')
    assert yp['performance_group'] != wp['performance_group']
    confirmation = yr[CONFIRMATION]
    assert confirmation['source_parent'] == yp['source_parents'][CONFIRMATION] == SOURCE_VERSION
    assert confirmation['confirmation_only'] is True and confirmation['initial_performance_job'] == '1582256'
    assert confirmation['failed_confirmation_retry_allowed'] is False
    assert confirmation['initial_qualification_version'] == SOURCE_VERSION
    assert confirmation['source_hashes'] == wr[SOURCE_VERSION]['source_hashes']
    assert confirmation['settings'] == yp['settings'] == wp['settings'] == e.get_record('conv','C26-r1')['settings']
    assert confirmation['reused_identical_source_diagnostic'] is True
    assert wr[SOURCE_VERSION]['reused_identical_source_diagnostic'] is False
    diag,frozen = w.diagnostic_gate(SOURCE_VERSION,confirmation['source_hashes'])
    assert str(diag['job_id']) == '1582134' and frozen == T_DIRECTORY
    decisions = w.old_decisions()  # Preserves Sfalse/C51 reference and older conclusions.
    assert decisions['S_confirmation_passed'] is False and decisions['failed_S_confirmation_retried'] is False
    cfg = c.load_config(ROOT/'config/conv-sep12.local.json')
    assert c.effective_settings(cfg,{'settings':yp['settings']}) == yp['settings']
    return dict(w=wp,y=yp,w_records=wr,y_records=yr,w_gates=wg,y_gates=yg,
        prior_decisions=decisions,baseline_source=baseline,source=confirmation['source_hashes'],
        settings=yp['settings'],diagnostic_directory=frozen),cfg


def live_gate(cfg,context):
    # Only the explicitly known W/T/S and existing P/X/Y/Z reservations.
    # Original X1582372 is fixed; an altered/missing known identity blocks.
    paths = [('sep13w-campaign.json','performance_job','1582256',True,None),
             ('sep13t-checks/C52-row7x3shared2/job.json','job_id','1582134',True,SOURCE_VERSION),
             ('sep13s-campaign.json','performance_job','1582067',True,None),
             ('sep13p-checks/C50-row4dupfencenomem/job.json','job_id',None,False,'C50-row4dupfencenomem'),
             ('sep13x-checks/C53-row7cursors/job.json','job_id','1582372',True,'C53-row7cursors'),
             ('sep13y-campaign.json','performance_job',context['y']['performance_job'],True,None),
             ('sep13z-campaign.json','performance_job',None,False,None),
             ('C52-package/cluster.json','job_id',None,False,None)]
    paths += [(name+'/cluster.json','job_id',context['y']['performance_job'],True,None) for name in Y_ORDER]
    identities,unresolved = {},[]
    for relative,field,expected,required,version in paths:
        path = ROOT/'.runs/conv'/relative
        if not path.exists():
            if required:
                unresolved.append(dict(path=relative,reason='Required known reservation missing'))
            continue
        row = e.read_json(path)
        job = str(row.get(field) or '')
        if not job.isdigit() or (expected is not None and job != expected):
            unresolved.append(dict(path=relative,reason='Unknown or changed known job ID'))
            continue
        if version is not None and row.get('version') != version:
            unresolved.append(dict(path=relative,reason='Diagnostic reservation identity changed'))
            continue
        identities.setdefault(job,[]).append(relative)
    evidence = [w.r.query_job(cfg,job,origins) for job,origins in identities.items()]
    clear = not unresolved and all(row['query_exit']==0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId'))==row['job_id'] and row['scheduler'].get('status') in w.TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    for row in evidence:
        if row['job_id'] in ('1582256','1582134','1582067',context['y']['performance_job']):
            clear = clear and row['scheduler'] is not None and row['scheduler'].get('status')=='SUCCEEDED'
            clear = clear and row['scheduler'].get('jobExitCode')==row['scheduler'].get('systemExitCode')==0
    return dict(checked_at=datetime.now(timezone.utc).isoformat(),clear=bool(clear),jobs=evidence,unresolved_reservations=unresolved)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go',action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only: explicit root --go is required before any package creation or SSH'
    run = ROOT/'.runs/conv'/VERSION
    assert not run.exists() and not e.record_path('conv',VERSION).exists(), 'Existing package/reservation must be preserved; never resubmit'
    assert not (ROOT/'.runs/conv/sep13z-campaign.json').exists(), 'Existing Z reservation must be reconciled, never recreated'
    context,cfg = preflight()
    gate = live_gate(cfg,context)
    print(json.dumps(dict(package=VERSION,serial_gate=gate),indent=2),flush=True)
    assert gate['clear'], 'W/T/S/P/X/Y/Z work active/unresolved; no package reservation'
    with e.locked():
        assert not run.exists() and not e.record_path('conv',VERSION).exists()
        assert not (ROOT/'.runs/conv/sep13z-campaign.json').exists()
        latest,latest_cfg = preflight()
        assert latest == context and latest_cfg == cfg, 'Evidence or settings changed during gate; stop without reservation'
        e.new(argparse.Namespace(problem='conv',version=VERSION,parent=CONFIRMATION,
            strategy='Exact original ZIP validation of unchanged C52 after W initial qualification and one independent Y confirmation; package-only, no automatic promotion'))
        meta = e.read_json(run/'experiment.json')
        meta.update(settings=context['settings'],source_parent=CONFIRMATION,source_origin=SOURCE_VERSION,
            reference_only=True,promotion_allowed=False,package_validation_only=True,
            initial_performance_job='1582256',package_confirmation_job=context['y']['performance_job'],
            diagnostic_job_id='1582134',diagnostic_source_version=SOURCE_VERSION,
            diagnostic_source_sha256=SOURCE_SHA256,diagnostic_evidence_directory=T_DIRECTORY,
            expected_benchmark_cases=12,expected_compiler_banners=['gcc (GCC) 10.3.1'],
            explicit_root_go=True,automatic_promotion=False,automatic_publication=False)
        e.write_json(run/'experiment.json',meta)
        e.checkpoint(argparse.Namespace(problem='conv',version=VERSION,note='Three complete original suites from this exact ZIP, extracted and compiled only on a scheduled compute node. W48 and Y36 independently pass both C6 controls; Sfalse and C51 reference restrictions preserved; no pooled samples. Reference-only package validation, no auto promote/publish/retry.'))
        assert e.source_files(run/'source') == context['source']
        e.write_json(run/'package-gates.json',dict(initial_job='1582256',confirmation_job=context['y']['performance_job'],
            diagnostic_job='1582134',source_version=SOURCE_VERSION,package_source_parent=CONFIRMATION,
            w_gates=context['w_gates'],y_gates=context['y_gates'],serial_gate=gate,
            prior_decisions=context['prior_decisions'],unchanged_best='C6',reference_only=True,promotion_allowed=False,original_evidence_unchanged=True))
    # Reuse the reviewed original-ZIP transport without importing its top-level
    # submit code. It reserves cluster.json exclusively before any upload, stores
    # conv.zip, and unpacks only inside the scheduled remote_job.sh allocation.
    command = [sys.executable,'-B',str(ROOT/'.runs/conv/sep12-submit-package.py'),str(run)]
    e.write_json(run/'package-submit-command.json',dict(argv=command,executed_locally='file packing/SSH transport only; no local operator',automatic_retry=False))
    with (run/'package-submit.stdout.log').open('x') as out, (run/'package-submit.stderr.log').open('x') as err:
        submitted = subprocess.run(command,cwd=ROOT,stdout=out,stderr=err)
    e.write_json(run/'package-submit-exit.json',dict(argv=command,exit_code=submitted.returncode,
        stdout='package-submit.stdout.log',stderr='package-submit.stderr.log',automatic_retry=False))
    assert submitted.returncode == 0, 'Original package submission failed/uncertain; retain reservation and log, never rerun'
    manifest = e.read_json(run/'cluster.json')
    assert manifest['source_hashes'] == context['source'] and manifest['settings'] == context['settings']
    assert str(manifest['job_id']).isdigit() and str(manifest['job_id']) not in ('1582256',context['y']['performance_job'],'1582134','1582067','1582372')
    assert manifest['package_verification'] == e.read_json(run/'package-manifest.json')
    assert manifest['package_verification']['source_hashes'] == context['source']
    assert e.digest(run/'conv.zip') == manifest['package_verification']['zip_sha256']
    print(json.dumps(dict(package=VERSION,job_id=manifest['job_id'],source=CONFIRMATION,reference_only=True,
        promotion_allowed=False,validation_pending=True,automatic_followup=False),indent=2))


if __name__ == '__main__':
    main()
