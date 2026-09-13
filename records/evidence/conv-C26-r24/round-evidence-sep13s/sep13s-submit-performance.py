"""Prepared one-time S confirmation; explicit root --go only.

Definition reuse from reviewed R creates no campaign/source/job on import.
Never repeat a saved reservation or combine R and S measurement samples.
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

spec = importlib.util.spec_from_file_location('sep13s_prior_r_checks', Path(__file__).with_name('sep13r-record-group.py'))
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
r = prior.contract

ORDER = ['C26-r24', 'C51-r1', 'C26-r25']
CANDIDATES = ['C51-r1']
CONTROLS = ['C26-r24', 'C26-r25']
REFERENCES = []
SOURCE_VERSION = 'C51-row7x3u1'
# Source lineage and diagnostic identity have separate roles even when the
# same original candidate name supplies both the bytes and frozen Q evidence.
SOURCE_PARENTS = {'C51-r1': SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {'C51-r1': 'C51-row7x3u1'}
DIAGNOSTICS = {'C51-r1': r.DIAGNOSTICS['C51-row7x3u1']}
RESOURCES = r.RESOURCES
ENVIRONMENT = r.ENVIRONMENT
TERMINAL = r.TERMINAL
verify_settings = r.verify_settings


def old_c40_decisions():
    decisions = r.old_c40_decisions()
    record = e.get_record('conv', 'C40-r4')
    plan = e.read_json(ROOT / '.runs/conv/sep13r-campaign.json')
    assert record['job_id'] == plan['performance_job'] == '1581911'
    assert record['reference_only'] is True and record['promotion_allowed'] is False
    assert record['qualified_for_confirmation'] is False
    assert plan['reference_only_versions'] == ['C40-r4']
    assert 'C40-r4' not in plan['confirmation_pending']
    assert record['source_hashes'] == e.get_record('conv', 'C40-row6x3u1')['source_hashes']
    return dict(decisions, R_reference_only=True, R_promotion_allowed=False,
                R_qualified=False, R_reference_job='1581911')


def previous_gate():
    plan = e.read_json(ROOT / '.runs/conv/sep13r-campaign.json')
    prior.verify_plan(plan)
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1581911'
    assert plan['measurement_order'] == ['C26-r22', SOURCE_VERSION, 'C40-r4', 'C26-r23']
    assert plan['confirmation_pending'] == [SOURCE_VERSION]
    assert plan['automatic_confirmation'] is False and plan['automatic_promotion'] is False
    assert plan['automatic_packaging'] is False and plan['prior_c40_decisions_unchanged'] is True
    records = {name: e.get_record('conv', name) for name in plan['measurement_order']}
    assert len(plan['results']) == 4 and [row['version'] for row in plan['results']] == plan['measurement_order']
    baseline = records['C26-r23']
    opening = records['C26-r22']
    for index, (name, record) in enumerate(records.items()):
        run = ROOT / '.runs/conv' / name
        prior.verify_record(record, plan, run)
        assert record['machine'] == baseline['machine']
        manifest = e.read_json(run / 'cluster.json')
        prior.verify_manifest(manifest, plan, name)
        assert manifest['source_hashes'] == record['source_hashes']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1581911' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert plan['results'][index]['total_median_ms'] == record['total_median_ms']
        assert plan['results'][index]['qualified_for_confirmation'] == record['qualified_for_confirmation']
    assert sum(len(case['times_ms']) for record in records.values() for case in record['cases']) == 48
    assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    candidate = records[SOURCE_VERSION]
    assert candidate['qualified_for_confirmation'] is True
    assert candidate['opening_control_comparison']['eligible'] is True and candidate['comparison']['eligible'] is True
    assert candidate['opening_control_comparison']['baseline'] == 'C26-r22'
    assert candidate['comparison']['baseline'] == 'C26-r23'
    # Re-evaluate the standard rule on the complete original R arrays only.
    assert e.comparison(opening, candidate)['eligible'] and e.comparison(baseline, candidate)['eligible']
    assert candidate.get('confirmation_passed') is not False, 'Do not repeat a failed confirmation'
    old_c40_decisions()
    return plan, records


def diagnostic_gate(name, source):
    assert name in CANDIDATES
    assert source == e.get_record('conv', SOURCE_PARENTS[name])['source_hashes']
    return r.diagnostic_gate(DIAGNOSTIC_SOURCE_VERSIONS[name], source)


def serial_gate(cfg):
    # Reuse the bounded R inventory, including the actual R job and original Q.
    gate = r.serial_gate(cfg)
    jobs = {row['job_id']: row for row in gate['jobs']}
    unresolved = list(gate['unresolved_submissions'])
    additions = [(ROOT / '.runs/conv/sep13t-checks/C52-row7x3shared2/job.json', 'job_id')]
    additions += [(ROOT / '.runs/conv' / name / 'cluster.json', 'job_id') for name in ORDER]
    additions += [(ROOT / '.runs/conv/sep13s-campaign.json', 'performance_job')]
    for path, field in additions:
        if not path.exists():
            continue
        origin = str(path.relative_to(ROOT))
        job = str(e.read_json(path).get(field) or '')
        if not job.isdigit():
            unresolved.append(dict(path=origin, reason='Existing S/T reservation has no reconciled job ID'))
        elif job in jobs:
            jobs[job]['origins'].append(origin)
        else:
            jobs[job] = r.query_job(cfg, job, [origin])
    evidence = list(jobs.values())
    clear = not unresolved and all(row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(gate, checked_at=datetime.now(timezone.utc).isoformat(),
                jobs=evidence, unresolved_submissions=unresolved, clear=clear)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before S writes or SSH'
    path = ROOT / '.runs/conv/sep13s-campaign.json'
    assert not path.exists(), 'S already reserved; reconcile the original job and never resubmit'
    for name in ORDER:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    old_decisions = old_c40_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == old_records['C26-r23']['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    settings = previous['settings']
    verify_settings(settings)
    cfg = c.load_config(ROOT / 'config/conv-sep12.local.json')
    assert c.effective_settings(cfg, {'settings': settings}) == settings
    source = e.source_files(ROOT / '.runs/conv' / SOURCE_VERSION / 'source')
    assert source == old_records[SOURCE_VERSION]['source_hashes']
    assert set(source) == set(current) and all(source[key] == current[key] for key in ('README.md', 'bench_conv.c', 'run.sh'))
    diag, frozen = diagnostic_gate('C51-r1', source)
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13s-performance-gate-' + stamp + '.json'), gate)
    assert gate['clear'], 'Existing CONV/S/T work active or unknown; no S reservation or submission'
    plan = dict(round='sep13s', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=[],
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1],
        suites_per_member=3, expected_benchmark_cases=36, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'],
        record_environment='kunpeng-gcc10-generic-38-sep13s', record_reference=previous['record_reference'],
        best_label='C6', source_parents=SOURCE_PARENTS, candidate_source_hashes={'C51-r1': source},
        diagnostic_jobs={'C51-r1': diag['job_id']}, diagnostic_evidence_directories={'C51-r1': frozen},
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS, diagnostic_expected_checks={'C51-r1': 37128},
        prior_job='1581911', prior_campaign='.runs/conv/sep13r-campaign.json',
        initial_qualification_version=SOURCE_VERSION, initial_qualification_passed=True,
        confirmation_only=True, prior_c40_decisions=old_decisions,
        selection_rule='Use only the36 S samples. C51-r1 must independently pass both unchanged S C6 controls: total median gain strictly exceeds max(1%, all compared case spreads), and no individual case regresses over1%. No R/S sample pooling or selection; preserve every slow sample.',
        local_compilation_or_tests_run=False, official_score=None, submitted=False, submit_attempted=False,
        automatic_confirmation=False, automatic_promotion=False, automatic_packaging=False,
        failed_confirmation_retry_allowed=False)
    with e.locked():
        assert not path.exists()
        latest, latest_records = previous_gate()
        assert latest == previous and latest_records == old_records and old_c40_decisions() == old_decisions
        assert e.source_files(ROOT / 'conv') == current and e.read_json(ROOT / 'outputs/conv-best.json')['label'] == 'C6'
        assert e.source_files(ROOT / '.runs/conv' / SOURCE_VERSION / 'source') == source
        for name in ORDER:
            assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
        # Reserve the campaign before creating any member; never auto-retry.
        e.write_json(path, plan)
        for name in CONTROLS:
            e.new(argparse.Namespace(problem='conv', version=name, parent=None, strategy='Unchanged C6 S-round confirmation control'))
        e.new(argparse.Namespace(problem='conv', version='C51-r1', parent=SOURCE_VERSION,
            strategy='One independent confirmation of unchanged R-qualified C51 source; same frozen Q, new S controls, no pooled R/S samples or relaxed case gate'))
        for name in ORDER:
            meta_path = ROOT / '.runs/conv' / name / 'experiment.json'
            meta = e.read_json(meta_path)
            meta['settings'] = settings
            assert e.source_files(meta_path.parent / 'source') == (current if name in CONTROLS else source)
            if name in CANDIDATES:
                meta.update(parent=CONTROLS[1], comparison_baseline=CONTROLS[1],
                    source_parent=SOURCE_PARENTS[name], reference_only=False, promotion_allowed=True,
                    diagnostic_source_version=DIAGNOSTIC_SOURCE_VERSIONS[name],
                    diagnostic_evidence_directory=frozen, diagnostic_job_id=diag['job_id'],
                    diagnostic_source_sha256=source['conv2d.c'], reused_identical_source_diagnostic=True,
                    initial_qualification_version=SOURCE_VERSION, initial_performance_job='1581911',
                    confirmation_only=True, failed_confirmation_retry_allowed=False)
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv', version=name,
                note='S one independent confirmation, fixed C6/C51-r1/C6 order, three original suites each,36 cases. C51 source unchanged from R; own Q37128 reused. No R/S sample mixing or relaxed per-case1% gate; no auto retry/promote/ZIP.'))
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
