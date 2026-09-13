"""Prepared AI three-member performance comparison; explicit root --go only.

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

ORDER = ['C26-r36', 'C58-row7boundaryu2', 'C26-r37']
CANDIDATES = ['C58-row7boundaryu2']
REFERENCES = []
CONTROLS = [ORDER[0], ORDER[-1]]
SOURCE_VERSION = 'C52-row7x3shared2'
SOURCE_PARENTS = {ORDER[1]: SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {ORDER[1]: ORDER[1]}
DIAGNOSTIC_EXPECTED_CHECKS = {ORDER[1]: 44328}
SOURCE_SHA = 'c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751'
BASELINE_SHA = '0f71c88fb8898ff71bc4067abfd86ebbf29edd254e36ec57daf8924bd1727a21'
AH_JOB_PATH = ROOT / '.runs/conv/sep13ah-checks/C58-row7boundaryu2/job.json'
AH_JOB_ID = '1583350'
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
    # Bounded latest lifecycle decisions only; no previous round tool imports,
    # historical sample recomputation, or writes to earlier experiments.
    af = e.read_json(ROOT / '.runs/conv/sep13af-campaign.json')
    assert af['round'] == 'sep13af' and af['status'] == 'performance_complete'
    assert af['performance_job'] == '1583230' and af['expected_benchmark_cases'] == 48
    assert af['confirmation_pending'] == []
    assert [row['version'] for row in af['results']] == af['measurement_order']
    assert sum(len(a) for row in af['results'] for a in row['all_samples_ms']) == 48
    assert all(row['qualified_for_confirmation'] is False for row in af['results'])
    ag_path = ROOT / '.runs/conv/C57-row7shared2fma/AG_FAILURE_ASSOCIATION.json'
    ag = e.read_json(ag_path)
    assert ag['candidate'] == 'C57-row7shared2fma' and ag['diagnostic_job_id'] == '1583276'
    assert ag['status'] == 'failed' and ag['complete_collection'] is True
    assert ag['passes'] == 0 and ag['fails'] == 12 and ag['record_exit'] == 0
    assert e.get_record('conv', 'C57-row7shared2fma')['status'] == 'failed'
    paths = [ROOT / '.runs/conv/sep13af-campaign.json', ag_path,
             e.record_path('conv', 'C57-row7shared2fma')]
    return {str(path.relative_to(ROOT)): e.digest(path) for path in paths}


def diagnostic_jobs():
    job = e.read_json(AH_JOB_PATH)
    assert job['version'] == ORDER[1] and str(job['job_id']) == AH_JOB_ID
    assert job['source_hashes']['conv2d.c'] == SOURCE_SHA
    return {ORDER[1]: AH_JOB_ID}


def diagnostic_gate(name, source):
    assert name == ORDER[1] and source['conv2d.c'] == SOURCE_SHA
    diag = e.read_json(FROZEN / 'validation.json')
    frozen = e.read_json(FROZEN / 'freeze-source.json')
    assert diag['candidate'] == frozen['candidate'] == name
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
    assert job['version'] == name and str(job['job_id']) == AH_JOB_ID
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
    # Query only these three actual jobs. Existing P/AI reservations without
    # a reconciled root identity block; a prepared directory alone does not.
    paths = [(AH_JOB_PATH, 'job_id', AH_JOB_ID, True, ORDER[1]),
             (ROOT / '.runs/conv/sep13af-campaign.json', 'performance_job', '1583230', True, None),
             (ROOT / '.runs/conv/sep13ag-fma/C57-row7shared2fma/job.json', 'job_id', '1583276', True, 'C57-row7shared2fma'),
             (ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json', 'job_id', None, False, 'C50-row4dupfencenomem'),
             (ROOT / '.runs/conv/sep13ai-campaign.json', 'performance_job', None, False, None)]
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
    assert args.go, 'Prepared only; root explicit GO required before AI writes or SSH'
    path = ROOT / '.runs/conv/sep13ai-campaign.json'
    assert not path.exists(), 'AI already reserved; reconcile original job and never resubmit'
    for name in CONTROLS + REFERENCES:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    decisions = recent_evidence()
    current = baseline_gate()
    settings = SETTINGS
    verify_settings(settings)
    cfg = c.load_config(ROOT / 'config/conv-sep12.local.json')
    assert c.effective_settings(cfg, {'settings':settings}) == settings
    sources, jobs, frozen_paths = {}, {}, {}
    for name in CANDIDATES + REFERENCES:
        origin = SOURCE_VERSION if name in REFERENCES else name
        run = ROOT / '.runs/conv' / origin
        rec = e.get_record('conv', origin)
        if name in CANDIDATES:
            assert not (run / 'cluster.json').exists(), name
            assert rec['status'] == 'prepared' and rec['verified'] is False
            assert rec['settings'] == settings
            assert rec.get('source_parent', rec.get('parent')) == SOURCE_PARENTS[name] and rec.get('reference_only',False) is False
        source = e.source_files(run / 'source')
        assert source == rec['source_hashes'] and set(source) == set(current)
        assert all(source[key] == current[key] for key in ('README.md','bench_conv.c','run.sh'))
        diag, frozen_paths[name] = diagnostic_gate(name, source)
        sources[name], jobs[name] = source, diag['job_id']
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13ai-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Known AH/AF/AG or explicit P/AI work active/unknown; no AI reservation or submission'
    plan = dict(round='sep13ai', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], source_parent_reference=None,
        suites_per_member=3, expected_benchmark_cases=36, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep13ai',
        record_reference='官方内置参考', best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS,
        diagnostic_expected_checks=DIAGNOSTIC_EXPECTED_CHECKS,
        recent_evidence_sha256=decisions, auxiliary_comparisons={}, confirmation_only=False,
        failed_confirmation_retry_allowed=False,
        selection_rule='All36 AI samples: C58 must pass both same-job C6 controls. Total gain strictly exceeds max(1%, all compared case spreads); every case gain >= -1%. Keep slow samples. Initial eligibility only; root decides separately.',
        attribution_rule='C58 is new boundary-unroll source from original C52. No parent reference measured; do not claim same-job parent attribution. AF initial false, AG numerical failure and all earlier decisions remain untouched; no failed confirmation retry.',
        local_compilation_or_tests_run=False, official_score=None, automatic_confirmation=False,
        automatic_promotion=False, automatic_packaging=False, submitted=False, submit_attempted=False)
    with e.locked():
        assert not path.exists()
        assert recent_evidence() == decisions and baseline_gate() == current
        for name in CONTROLS + REFERENCES:
            assert not (ROOT/'.runs/conv'/name).exists() and not e.record_path('conv',name).exists(), name
        for name, source in sources.items():
            origin = SOURCE_VERSION if name in REFERENCES else name
            assert e.source_files(ROOT/'.runs/conv'/origin/'source') == source
            if name in CANDIDATES:
                assert not (ROOT/'.runs/conv'/name/'cluster.json').exists()
        # A saved reservation is irreversible for this submit entry point.
        e.write_json(path, plan)
        for name in CONTROLS:
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 AI-round matched control'))
        for name in ORDER:
            meta_path = ROOT/'.runs/conv'/name/'experiment.json'
            # Freeze the exact creation metadata before its first association update.
            # Existing C58 author snapshots stay byte-identical; never refresh source hashes.
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
                meta.update(parent=CONTROLS[1],comparison_baseline=CONTROLS[1],source_parent=SOURCE_PARENTS[name],
                    reference_only=name in REFERENCES,promotion_allowed=name in CANDIDATES,
                    qualified_for_confirmation=False,confirmation_only=False,failed_confirmation_retry_allowed=False,
                    diagnostic_source_version=DIAGNOSTIC_SOURCE_VERSIONS[name],
                    diagnostic_evidence_directory=frozen_paths[name],diagnostic_job_id=jobs[name],
                    diagnostic_source_sha256=sources[name]['conv2d.c'],reused_identical_source_diagnostic=name in REFERENCES)
            assert meta['source_hashes'] == e.read_json(creation_path)['source_hashes']
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv',version=name,
                note='AI fixed C6/C58/C6 order, three original official suites each, total36. C58 requires its own frozen AH44328. No parent reference, local operator execution, automatic confirmation, promotion or ZIP. All history preserved.'))
        plan.update(status='prepared', submit_attempted=True)
        e.write_json(path, plan)
    cluster_group.submit_group(cfg, [ROOT/'.runs/conv'/name for name in ORDER])
    manifests = [c.read_json(ROOT/'.runs/conv'/name/'cluster.json') for name in ORDER]
    job, group = manifests[0]['job_id'], manifests[0]['group']
    assert str(job).isdigit() and re.fullmatch(r'kp-conv-group-[0-9a-f]+', group or '')
    assert all(item['job_id']==job and item['group']==group for item in manifests)
    assert str(job) not in {'1583350','1583230','1583276'}, 'Must be an independent new AI job'
    plan.update(status='performance_running',performance_job=job,performance_group=group,submitted=True)
    with e.locked():
        e.write_json(path, plan)


if __name__ == '__main__':
    main()
