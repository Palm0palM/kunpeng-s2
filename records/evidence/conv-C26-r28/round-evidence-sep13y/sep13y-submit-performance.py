"""Prepared one-time Y confirmation; explicit root --go only.

Definition reuse from reviewed W creates no campaign/source/job on import.
Never repeat a saved reservation or combine W and Y measurement samples.
"""
import argparse
from datetime import datetime, timezone
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster as c
import cluster_group
import experiment as e

spec = importlib.util.spec_from_file_location('sep13y_prior_w_checks', Path(__file__).with_name('sep13w-record-group.py'))
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
w = prior.contract

ORDER = ['C26-r28', 'C52-r1', 'C26-r29']
CANDIDATES = ['C52-r1']
CONTROLS = ['C26-r28', 'C26-r29']
REFERENCES = []
SOURCE_VERSION = 'C52-row7x3shared2'
# Source lineage and diagnostic identity have separate roles even when the
# same original candidate name supplies both the bytes and its frozen T evidence.
SOURCE_PARENTS = {'C52-r1': SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {'C52-r1': 'C52-row7x3shared2'}
DIAGNOSTIC_JOBS = {'C52-r1': '1582134'}
SOURCE_SHA256 = '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'
RESOURCES = w.RESOURCES
ENVIRONMENT = w.ENVIRONMENT
TERMINAL = w.TERMINAL
verify_settings = w.verify_settings


def old_decisions():
    decisions = w.old_decisions()
    plan = e.read_json(ROOT / '.runs/conv/sep13w-campaign.json')
    reference = e.get_record('conv', 'C51-r2')
    assert plan['performance_job'] == reference['job_id'] == '1582256'
    assert plan['reference_only_versions'] == ['C51-r2']
    assert reference['reference_only'] is True and reference['promotion_allowed'] is False
    assert reference['qualified_for_confirmation'] is False and 'C51-r2' not in plan['confirmation_pending']
    assert reference['prior_confirmation_passed'] is False and reference['prior_confirmation_job'] == '1582067'
    assert reference['source_hashes'] == e.get_record('conv', 'C51-row7x3u1')['source_hashes']
    return dict(decisions, W_C51_reference_only=True, W_C51_promotion_allowed=False,
                W_C51_qualified=False, W_reference_job='1582256', C51_confirmation_retried=False)


def previous_gate():
    plan = e.read_json(ROOT / '.runs/conv/sep13w-campaign.json')
    prior.verify_plan(plan)
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1582256'
    assert plan['measurement_order'] == ['C26-r26', SOURCE_VERSION, 'C51-r2', 'C26-r27']
    assert plan['confirmation_pending'] == [SOURCE_VERSION]
    assert plan['automatic_confirmation'] is False and plan['automatic_promotion'] is False
    assert plan['automatic_packaging'] is False and plan['prior_decisions_unchanged'] is True
    records = {name: e.get_record('conv', name) for name in plan['measurement_order']}
    assert len(plan['results']) == 4 and [row['version'] for row in plan['results']] == plan['measurement_order']
    baseline = records['C26-r27']
    opening = records['C26-r26']
    for index, (name, record) in enumerate(records.items()):
        run = ROOT / '.runs/conv' / name
        prior.verify_record(record, plan, run)
        assert record['machine'] == baseline['machine']
        manifest = e.read_json(run / 'cluster.json')
        prior.verify_manifest(manifest, plan, name)
        assert manifest['source_hashes'] == record['source_hashes']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1582256' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert plan['results'][index]['total_median_ms'] == record['total_median_ms']
        assert plan['results'][index]['all_samples_ms'] == [case['times_ms'] for case in record['cases']]
        assert plan['results'][index]['qualified_for_confirmation'] == record['qualified_for_confirmation']
    assert sum(len(case['times_ms']) for record in records.values() for case in record['cases']) == 48
    assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    candidate = records[SOURCE_VERSION]
    assert candidate['qualified_for_confirmation'] is True
    assert candidate['opening_control_comparison']['eligible'] is True and candidate['comparison']['eligible'] is True
    assert candidate['opening_control_comparison']['baseline'] == 'C26-r26'
    assert candidate['comparison']['baseline'] == 'C26-r27'
    # Re-evaluate complete original W arrays only; never pool them with Y.
    for base, field in ((opening, 'opening_control_comparison'), (baseline, 'comparison')):
        actual = e.comparison(base, candidate)
        assert actual['eligible'] is True
        assert all(candidate[field][key] == value for key, value in actual.items())
    assert candidate.get('confirmation_passed') is not False, 'Do not repeat a failed confirmation'
    old_decisions()
    return plan, records


def diagnostic_gate(name, source):
    assert name == 'C52-r1' and source['conv2d.c'] == SOURCE_SHA256
    assert source == e.get_record('conv', SOURCE_PARENTS[name])['source_hashes']
    # Reuse reviewed W's exact C52 T gate, including actual 13 stages/14 regions.
    diag, frozen = w.diagnostic_gate(DIAGNOSTIC_SOURCE_VERSIONS[name], source)
    assert str(diag['job_id']) == DIAGNOSTIC_JOBS[name]
    return diag, frozen


def serial_gate(cfg):
    # Only W/T/S and actual existing P/X/Y reservations. No historical scan.
    paths = [(ROOT / '.runs/conv/sep13w-campaign.json', 'performance_job', '1582256', True, None),
             (ROOT / '.runs/conv/sep13t-checks/C52-row7x3shared2/job.json', 'job_id', '1582134', True, 'C52-row7x3shared2'),
             (ROOT / '.runs/conv/sep13s-campaign.json', 'performance_job', '1582067', True, None),
             (ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json', 'job_id', None, False, 'C50-row4dupfencenomem'),
             (ROOT / '.runs/conv/sep13x-checks/C53-row7cursors/job.json', 'job_id', None, False, 'C53-row7cursors'),
             (ROOT / '.runs/conv/sep13y-campaign.json', 'performance_job', None, False, None)]
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
        if not job.isdigit() or (expected is not None and job != expected):
            unresolved.append(dict(path=origin, reason='Unreconciled reservation or changed known job ID'))
            continue
        if version is not None and row.get('version') != version:
            unresolved.append(dict(path=origin, reason='Unexpected diagnostic reservation identity'))
            continue
        identities.setdefault(job, []).append(origin)
    evidence = [w.r.query_job(cfg, job, origins) for job, origins in identities.items()]
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
    assert args.go, 'Prepared only; root explicit GO required before Y writes or SSH'
    path = ROOT / '.runs/conv/sep13y-campaign.json'
    assert not path.exists(), 'Y already reserved; reconcile the original job and never resubmit'
    for name in ORDER:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    decisions = old_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == old_records['C26-r27']['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    settings = previous['settings']
    verify_settings(settings)
    cfg = c.load_config(ROOT / 'config/conv-sep12.local.json')
    assert c.effective_settings(cfg, {'settings': settings}) == settings
    source = e.source_files(ROOT / '.runs/conv' / SOURCE_VERSION / 'source')
    assert source == old_records[SOURCE_VERSION]['source_hashes']
    assert set(source) == set(current) and all(source[key] == current[key] for key in ('README.md', 'bench_conv.c', 'run.sh'))
    diag, frozen = diagnostic_gate('C52-r1', source)
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13y-performance-gate-' + stamp + '.json'), gate)
    assert gate['clear'], 'Existing W/T/S/P/X/Y work active or unknown; no Y reservation or submission'
    plan = dict(round='sep13y', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=[],
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1],
        suites_per_member=3, expected_benchmark_cases=36, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'],
        record_environment='kunpeng-gcc10-generic-38-sep13y', record_reference=previous['record_reference'],
        best_label='C6', source_parents=SOURCE_PARENTS, candidate_source_hashes={'C52-r1': source},
        diagnostic_jobs={'C52-r1': diag['job_id']}, diagnostic_evidence_directories={'C52-r1': frozen},
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS, diagnostic_expected_checks={'C52-r1': 37128},
        prior_job='1582256', prior_campaign='.runs/conv/sep13w-campaign.json',
        initial_qualification_version=SOURCE_VERSION, initial_qualification_passed=True,
        confirmation_only=True, prior_decisions=decisions,
        selection_rule='Use only the36 Y samples. C52-r1 must independently pass both unchanged Y C6 controls: total median gain strictly exceeds max(1%, all compared case spreads), and no individual case regresses over1%. No W/Y sample pooling or selection; preserve every slow sample.',
        local_compilation_or_tests_run=False, official_score=None, submitted=False, submit_attempted=False,
        automatic_confirmation=False, automatic_promotion=False, automatic_packaging=False,
        failed_confirmation_retry_allowed=False)
    with e.locked():
        assert not path.exists()
        latest, latest_records = previous_gate()
        assert latest == previous and latest_records == old_records and old_decisions() == decisions
        assert e.source_files(ROOT / 'conv') == current and e.read_json(ROOT / 'outputs/conv-best.json')['label'] == 'C6'
        assert e.source_files(ROOT / '.runs/conv' / SOURCE_VERSION / 'source') == source
        for name in ORDER:
            assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
        # Reserve the campaign before creating any member; never auto-retry.
        e.write_json(path, plan)
        for name in CONTROLS:
            e.new(argparse.Namespace(problem='conv', version=name, parent=None, strategy='Unchanged C6 Y-round confirmation control'))
        e.new(argparse.Namespace(problem='conv', version='C52-r1', parent=SOURCE_VERSION,
            strategy='One independent confirmation of unchanged W-qualified C52 source; same own frozen T, new Y controls, no pooled W/Y samples or relaxed case gate'))
        for name in ORDER:
            meta_path = ROOT / '.runs/conv' / name / 'experiment.json'
            meta = e.read_json(meta_path)
            meta['settings'] = settings
            assert e.source_files(meta_path.parent / 'source') == (current if name in CONTROLS else source)
            if name in CANDIDATES:
                meta.update(parent=CONTROLS[1], comparison_baseline=CONTROLS[1],
                    source_parent=SOURCE_PARENTS[name], reference_only=False, promotion_allowed=True,
                    qualified_for_confirmation=False,
                    diagnostic_source_version=DIAGNOSTIC_SOURCE_VERSIONS[name],
                    diagnostic_evidence_directory=frozen, diagnostic_job_id=diag['job_id'],
                    diagnostic_source_sha256=source['conv2d.c'], reused_identical_source_diagnostic=True,
                    initial_qualification_version=SOURCE_VERSION, initial_performance_job='1582256',
                    confirmation_only=True, failed_confirmation_retry_allowed=False)
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv', version=name,
                note='Y one independent confirmation, fixed C6/C52-r1/C6 order, three original suites each,36 cases. C52 source unchanged from W; own T1582134/37128 reused. Sfalse and C51 reference-only preserved. No W/Y sample mixing or relaxed per-case1% gate; no auto retry/promote/ZIP.'))
        plan.update(status='prepared', submit_attempted=True)
        e.write_json(path, plan)
    cluster_group.submit_group(cfg, [ROOT / '.runs/conv' / name for name in ORDER])
    manifests = [c.read_json(ROOT / '.runs/conv' / name / 'cluster.json') for name in ORDER]
    job, group = manifests[0]['job_id'], manifests[0]['group']
    assert str(job).isdigit() and all(row['job_id'] == job and row['group'] == group for row in manifests)
    plan.update(status='performance_running', performance_job=job, performance_group=group, submitted=True)
    with e.locked():
        e.write_json(path, plan)


if __name__ == '__main__':
    main()
