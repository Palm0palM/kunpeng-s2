"""Prepared AK independent three-member C58 confirmation; explicit root --go only.

C58 must have its own accepted/frozen AH44328. This module loads definitions
only. No automatic confirmation, promotion, packaging or retry.
"""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import re
import shlex
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster as c
import cluster_group
import experiment as e

ORDER = ['C26-r38', 'C58-r1', 'C26-r39']
CANDIDATES = [ORDER[1]]
REFERENCES = []
CONTROLS = [ORDER[0], ORDER[-1]]
SOURCE_VERSION = 'C58-row7boundaryu2'
SOURCE_PARENTS = {ORDER[1]: SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {ORDER[1]: SOURCE_VERSION}
DIAGNOSTIC_EXPECTED_CHECKS = {ORDER[1]: 44328}
SOURCE_SHA = 'c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751'
BASELINE_SHA = '0f71c88fb8898ff71bc4067abfd86ebbf29edd254e36ec57daf8924bd1727a21'
AH_JOB_PATH = ROOT / '.runs/conv/sep13ah-checks/C58-row7boundaryu2/job.json'
AH_JOB_ID = '1583350'
AI_JOB_ID = '1583408'
AI_ORDER = ['C26-r36', SOURCE_VERSION, 'C26-r37']
FROZEN = ROOT / '.runs/conv/C58-row7boundaryu2/sve-correctness-sep13ah'
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
                 numa_distribution='pack', walltime_seconds=1800)
ENVIRONMENT = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
                   OMP_PLACES='cores', CPU_TARGET='generic')
SETTINGS = dict(bench_repeats=3, environment=ENVIRONMENT,
    scheduler_resources=dict(queue='q_kunpeng', **RESOURCES),
    numa_policy='38 allowed CPUs within one NUMA node')
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}


def verify_settings(settings):
    assert settings == SETTINGS


def baseline_gate():
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_experiment'] == 'C26-row4loads'
    assert best['source_hashes'] == current == e.get_record('conv', 'C26-row4loads')['source_hashes']
    assert current['conv2d.c'] == BASELINE_SHA and current['bench_conv.c'] == e.BENCH_SHA['conv']
    return current


def recent_evidence():
    # Recheck only the complete original AI36; do not import AI or recurse
    # through its historical eligibility dependencies.
    path = ROOT / '.runs/conv/sep13ai-campaign.json'
    plan = e.read_json(path)
    assert plan['round'] == 'sep13ai' and plan['status'] == 'performance_complete'
    assert plan['performance_job'] == AI_JOB_ID and plan['measurement_order'] == AI_ORDER
    assert plan['candidate_versions'] == [SOURCE_VERSION] and plan['reference_only_versions'] == []
    assert plan['opening_control'] == AI_ORDER[0] and plan['primary_baseline'] == AI_ORDER[-1]
    assert plan['suites_per_member'] == 3 and plan['expected_benchmark_cases'] == 36
    assert plan['settings'] == SETTINGS and plan['confirmation_only'] is False
    assert plan['confirmation_pending'] == [SOURCE_VERSION]
    assert all(plan[k] is False for k in ('automatic_confirmation','automatic_promotion','automatic_packaging'))
    assert len(plan['results']) == 3 and [x['version'] for x in plan['results']] == AI_ORDER
    assert re.fullmatch(r'kp-conv-group-[0-9a-f]+', plan['performance_group'])
    records = {name:e.get_record('conv',name) for name in AI_ORDER}
    paths = [path]
    for index,name in enumerate(AI_ORDER):
        rec = records[name]; run = ROOT/'.runs/conv'/name
        manifest = e.read_json(run/'cluster.json'); row = plan['results'][index]
        assert rec['status'] == 'passed' and rec['verified'] is True and rec['repeats'] == 3
        assert rec['job_id'] == manifest['job_id'] == AI_JOB_ID
        assert rec['settings'] == manifest['settings'] == SETTINGS
        assert manifest['group'] == plan['performance_group'] and manifest['group_index'] == index
        assert manifest['measurement_order'] == AI_ORDER
        assert set(rec['checks']) == {'scheduler','fetched_log','benchmark','wrapper','source_hashes','machine'}
        assert all(rec['checks'].values())
        assert rec['source_hashes'] == manifest['source_hashes'] == e.source_files(run/'source')
        assert rec['source_hashes']['conv2d.c'] == (SOURCE_SHA if name == SOURCE_VERSION else BASELINE_SHA)
        status = manifest['scheduler_status']
        assert str(status['jobId']) == AI_JOB_ID and status['status'] == 'SUCCEEDED'
        assert type(status['jobExitCode']) is type(status['systemExitCode']) is int
        assert status['jobExitCode'] == status['systemExitCode'] == 0
        assert (run/'exit-code.txt').read_text().strip() == '0'
        for filename in ('benchmark.log','environment.log','exit-code.txt','source-sha256.txt'):
            assert e.digest(run/filename) == manifest['artifacts_sha256'][filename]
        parsed = e.parse_log('conv',(run/'benchmark.log').read_text(),3)
        assert parsed['cases'] == rec['cases'] and parsed['total_median_ms'] == rec['total_median_ms']
        assert row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        assert row['cases_ms'] == [case['median_ms'] for case in rec['cases']]
        assert row['case_spreads_pct'] == [case['spread_pct'] for case in rec['cases']]
        assert row['total_median_ms'] == rec['total_median_ms']
        assert row['qualified_for_confirmation'] is rec['qualified_for_confirmation']
        assert rec['machine'] == records[AI_ORDER[-1]]['machine']
        machine = rec['machine']
        assert machine['compiler_banners'] == ['gcc (GCC) 10.3.1']
        assert machine['ARCH'] == 'aarch64' and machine['OMP_NUM_THREADS'] == '38' and machine['CPU_TARGET'] == 'generic'
        cpus = machine['ALLOWED_CPUS'].split(',')
        assert len(cpus) == len(set(cpus)) == 38 and all(cpu.isdigit() for cpu in cpus)
        assert machine['HOST'] and machine['NUMA_NODE']
        assert rec['environment'] == plan['record_environment'] == 'kunpeng-gcc10-generic-38-sep13ai'
        assert rec['reference'] == plan['record_reference']
        paths += [e.record_path('conv',name),run/'cluster.json']
    candidate = records[SOURCE_VERSION]
    assert candidate['qualified_for_confirmation'] is True and candidate.get('confirmation_passed') is not False
    assert candidate['reference_only'] is False and candidate['promotion_allowed'] is True
    assert candidate['source_hashes'] == plan['candidate_source_hashes'][SOURCE_VERSION]
    baseline_source = e.get_record('conv','C26-row4loads')['source_hashes']
    assert records[AI_ORDER[0]]['source_hashes'] == records[AI_ORDER[-1]]['source_hashes'] == baseline_source
    assert all(candidate['source_hashes'][key] == baseline_source[key] for key in ('README.md','bench_conv.c','run.sh'))
    for key,name in [('opening_control_comparison',AI_ORDER[0]),('comparison',AI_ORDER[-1])]:
        base = records[name]
        actual = dict(baseline=name,**e.comparison(base,candidate),
            total_gain_pct=(base['total_median_ms']-candidate['total_median_ms'])/base['total_median_ms']*100,
            threshold_pct=max([1.0]+[case['spread_pct'] for case in base['cases']+candidate['cases']]))
        assert actual['eligible'] is True
        assert candidate[key] == plan['results'][1][key] == actual
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 36
    return {str(item.relative_to(ROOT)):e.digest(item) for item in paths}


def diagnostic_jobs():
    job = e.read_json(AH_JOB_PATH)
    assert job['version'] == SOURCE_VERSION and str(job['job_id']) == AH_JOB_ID
    assert job['source_hashes']['conv2d.c'] == SOURCE_SHA
    return {ORDER[1]: AH_JOB_ID}


def diagnostic_gate(name, source):
    assert name == ORDER[1] and source['conv2d.c'] == SOURCE_SHA
    assert source == e.get_record('conv', SOURCE_VERSION)['source_hashes']
    diag = e.read_json(FROZEN / 'validation.json')
    frozen = e.read_json(FROZEN / 'freeze-source.json')
    assert diag['candidate'] == frozen['candidate'] == SOURCE_VERSION
    assert str(diag['job_id']) == str(frozen['job_id']) == diagnostic_jobs()[name]
    assert diag['status'] == frozen['mode'] == 'passed' and diag['complete'] is True
    assert frozen['original_metadata_preserved'] is frozen['original_source_and_raw_preserved'] is True
    assert diag['exit_code'] == 0 and diag['compiler_version'] == '10.3.1'
    assert (diag['total_cases'], diag['full_cases'], diag['dispatch_cases'], diag['direct_cases']) == (44328,34464,7272,2592)
    assert len(diag['configurations']) == 6
    assert {(x['sve_bytes'],x['threads']) for x in diag['configurations']} == {(v,t) for v in (16,32,64) for t in (1,4)}
    assert all((x['full_cases'],x['dispatch_cases'],x['direct_cases']) == (5744,1212,432) for x in diag['configurations'])
    stages = ['allocation','compiler','manifest','build-guard']
    stages += [f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-dispatch'] + [f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-assembly','complete']
    assert diag['stage_exits'] == [dict(stage=x,exit_code=0) for x in stages]
    job = e.read_json(FROZEN / 'job.json')
    original = e.read_json(AH_JOB_PATH)
    assert job['version'] == SOURCE_VERSION and str(job['job_id']) == AH_JOB_ID
    assert job['source_hashes'] == original['source_hashes'] == diag['source_hashes']
    assert job['resources'] == RESOURCES and diag['source_hashes_verified'] is True
    assert diag['source_hashes']['conv2d.c'] == source['conv2d.c'] == e.digest(FROZEN / 'raw/conv2d.c')
    status = diag['scheduler']
    assert status == job['scheduler_status'] and str(status['jobId']) == AH_JOB_ID
    assert status['status'] == 'SUCCEEDED' and status['jobExitCode'] == status['systemExitCode'] == 0
    assert (FROZEN / 'raw/exit-code.txt').read_text().strip() == '0'
    assert diag['assembly']['fused_instructions'] == 0 and diag['assembly']['review'] == 'TARGETED_ASSEMBLY_REVIEW.md'
    assert (FROZEN / 'TARGETED_ASSEMBLY_REVIEW.md').is_file() and (FROZEN / 'ROOT_RETURNED_REVIEW.md').is_file()
    assert diag['performance_measured'] is False and diag['executed_locally'] is False
    assert diag['executed_remotely'] is True and diag['issues'] == []
    return diag, str(FROZEN.relative_to(ROOT))


def query_job(cfg, job_id, origins):
    command = shlex.join(part.replace('{job_id}', job_id) for part in cfg['scheduler']['status_argv'])
    try:
        result = c.remote(cfg, command, timeout=min(45, cfg['command_timeout']))
        output = c.output_text(result)
        scheduler = c.parse_scheduler_status(output, job_id) if result.returncode == 0 else None
        return dict(job_id=job_id, origins=origins, command=command, query_exit=result.returncode,
                    raw_status=output, scheduler=scheduler)
    except (subprocess.TimeoutExpired, OSError, c.ClusterError) as exc:
        return dict(job_id=job_id, origins=origins, command=command, query_exit=None,
                    raw_status=str(exc), scheduler=None, query_error=type(exc).__name__)


def serial_gate(cfg):
    # Fixed latest AI/AH only. A prepared P/AJ directory without job.json
    # does not block; any unapproved P/AJ or any AK reservation blocks.
    paths = [(AH_JOB_PATH, 'job_id', AH_JOB_ID, True, SOURCE_VERSION),
             (ROOT / '.runs/conv/sep13ai-campaign.json', 'performance_job', AI_JOB_ID, True, None),
             (ROOT / '.runs/conv/sep13aj-checks/C59-row7boundaryu2nofive/job.json', 'job_id', None, False, 'C59-row7boundaryu2nofive'),
             (ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json', 'job_id', None, False, 'C50-row4dupfencenomem'),
             (ROOT / '.runs/conv/sep13ak-campaign.json', 'performance_job', None, False, None)]
    paths += [(ROOT / '.runs/conv' / name / 'cluster.json', 'job_id', None, False, None) for name in ORDER]
    identities, unresolved = {}, []
    for path, field, expected, required, version in paths:
        origin = str(path.relative_to(ROOT))
        if not path.exists():
            if required:
                unresolved.append(dict(path=origin, reason='Required known job evidence missing'))
            continue
        row = e.read_json(path)
        job = str(row.get(field) or '')
        if expected is None or not job.isdigit() or job != expected:
            unresolved.append(dict(path=origin, reason='Unreconciled reservation or changed known job ID'))
            continue
        if version is not None and row.get('version') != version:
            unresolved.append(dict(path=origin, reason='Unexpected diagnostic reservation identity'))
            continue
        identities.setdefault(job, []).append(origin)
    evidence = [query_job(cfg, job, origins) for job, origins in identities.items()]
    clear = not unresolved and all(row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), clear=clear,
                jobs=evidence, unresolved_submissions=unresolved)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before AK writes or SSH'
    path = ROOT / '.runs/conv/sep13ak-campaign.json'
    assert not path.exists(), 'AK already reserved; reconcile original job and never resubmit'
    for name in ORDER:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    decisions = recent_evidence()
    current = baseline_gate()
    settings = SETTINGS
    verify_settings(settings)
    cfg = c.load_config(ROOT / 'config/conv-sep12.local.json')
    assert c.effective_settings(cfg, {'settings':settings}) == settings
    sources, jobs, frozen_paths = {}, {}, {}
    for name in CANDIDATES + REFERENCES:
        origin = SOURCE_VERSION
        run = ROOT / '.runs/conv' / origin
        rec = e.get_record('conv', origin)
        if name in CANDIDATES:
            assert rec['status'] == 'passed' and rec['verified'] is True
            assert rec['job_id'] == AI_JOB_ID and rec['qualified_for_confirmation'] is True
            assert rec['settings'] == settings
            assert rec.get('reference_only',False) is False
        source = e.source_files(run / 'source')
        assert source == rec['source_hashes'] and set(source) == set(current)
        assert all(source[key] == current[key] for key in ('README.md','bench_conv.c','run.sh'))
        diag, frozen_paths[name] = diagnostic_gate(name, source)
        sources[name], jobs[name] = source, diag['job_id']
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13ak-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Known AI/AH or explicit AJ/P/AK work active/unknown; no AK reservation or submission'
    plan = dict(round='sep13ak', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], source_parent_reference=None,
        suites_per_member=3, expected_benchmark_cases=36, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep13ak',
        record_reference='官方内置参考', best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS,
        diagnostic_expected_checks=DIAGNOSTIC_EXPECTED_CHECKS,
        recent_evidence_sha256=decisions, auxiliary_comparisons={}, confirmation_only=True,
        initial_qualification_round='sep13ai', initial_qualification_job=AI_JOB_ID,
        failed_confirmation_retry_allowed=False,
        selection_rule='Only original36 AK samples: C58-r1 must pass both current same-job C6 gates. Total gain strictly exceeds max(1%, all compared case spreads); every case gain >= -1%. Write confirmation_passed separately; keep all slow samples.',
        attribution_rule='C58-r1 is byte-identical to AI C58 and reuses its own frozen AH1583350. This is first independent confirmation of AI-qualified C58, not a retry of Y/S. No mixing AI/AK samples, failed-confirmation retry or parent attribution.',
        local_compilation_or_tests_run=False, official_score=None, automatic_confirmation=False,
        automatic_promotion=False, automatic_packaging=False, submitted=False, submit_attempted=False)
    with e.locked():
        assert not path.exists()
        assert recent_evidence() == decisions and baseline_gate() == current
        for name in ORDER:
            assert not (ROOT/'.runs/conv'/name).exists() and not e.record_path('conv',name).exists(), name
        for name, source in sources.items():
            origin = SOURCE_VERSION
            assert e.source_files(ROOT/'.runs/conv'/origin/'source') == source
            assert e.get_record('conv',origin)['status'] == 'passed'
        # A saved reservation is irreversible for this submit entry point.
        e.write_json(path, plan)
        for name in CONTROLS:
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 AK independent confirmation control'))
        e.new(argparse.Namespace(problem='conv',version=ORDER[1],parent=SOURCE_VERSION,
            strategy='First independent confirmation of AI-qualified C58; identical source, own C58 AH diagnostic reuse, no failed-confirmation retry.'))
        for name in ORDER:
            meta_path = ROOT/'.runs/conv'/name/'experiment.json'
            # Freeze the exact creation metadata before its first association update.
            # All three members are new; preserve creation bytes before associations.
            original_metadata = meta_path.read_bytes()
            creation_path = meta_path.with_name('creation-experiment.json')
            if creation_path.exists():
                assert creation_path.read_bytes() == original_metadata
            else:
                with creation_path.open('xb') as output:
                    output.write(original_metadata)
            plan.setdefault('creation_experiment_sha256', {})[name] = e.digest(creation_path)
            meta = e.read_json(meta_path)
            meta['settings'] = settings
            assert e.source_files(meta_path.parent/'source') == (current if name in CONTROLS else sources[name])
            if name not in CONTROLS:
                meta.update(parent=CONTROLS[1],comparison_baseline=CONTROLS[1],comparison_parent=CONTROLS[1],source_parent=SOURCE_PARENTS[name],
                    reference_only=name in REFERENCES,promotion_allowed=name in CANDIDATES,
                    qualified_for_confirmation=False,confirmation_only=True,failed_confirmation_retry_allowed=False,
                    diagnostic_source_version=DIAGNOSTIC_SOURCE_VERSIONS[name],
                    diagnostic_evidence_directory=frozen_paths[name],diagnostic_job_id=jobs[name],
                    diagnostic_source_sha256=sources[name]['conv2d.c'],reused_identical_source_diagnostic=True)
            assert meta['source_hashes'] == e.read_json(creation_path)['source_hashes']
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv',version=name,
                note='AK fixed C6/C58-r1/C6 order, three original suites each,total36. Alias source_parent=C58 and comparison_parent=closing C26-r39; identical source reuses original C58 AH44328. Independent confirmation only; no AI/AK sample mixing, retry, automatic promotion or ZIP.'))
        plan.update(status='prepared', submit_attempted=True)
        e.write_json(path, plan)
    cluster_group.submit_group(cfg, [ROOT/'.runs/conv'/name for name in ORDER])
    manifests = [c.read_json(ROOT/'.runs/conv'/name/'cluster.json') for name in ORDER]
    job, group = manifests[0]['job_id'], manifests[0]['group']
    assert str(job).isdigit() and re.fullmatch(r'kp-conv-group-[0-9a-f]+', group or '')
    assert all(item['job_id']==job and item['group']==group for item in manifests)
    assert str(job) not in {AH_JOB_ID,AI_JOB_ID}, 'Must be an independent new AK job'
    plan.update(status='performance_running',performance_job=job,performance_group=group,submitted=True)
    with e.locked():
        e.write_json(path, plan)


if __name__ == '__main__':
    main()
