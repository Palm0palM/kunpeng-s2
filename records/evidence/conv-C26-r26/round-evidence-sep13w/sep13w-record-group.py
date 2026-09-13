"""Record only the saved W group; preserve all 48 original measurements.

No sources/campaigns/jobs are created. Actual matching terminal evidence is
required; failed measurements are not overwritten or silently excluded.
"""
import argparse
import contextlib
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import cluster
import experiment as e

# Definition reuse only: the submit module has an explicit main guard.
spec = importlib.util.spec_from_file_location('sep13w_submission_contract', Path(__file__).with_name('sep13w-submit-performance.py'))
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
ORDER = contract.ORDER
CHECKS = contract.prior.CHECKS
DIMS = contract.prior.DIMS
verify_machine = contract.prior.verify_machine


def verify_plan(plan):
    assert plan['round'] == 'sep13w' and plan['status'] in ('performance_running','performance_complete')
    assert plan['measurement_order'] == ORDER and plan['candidate_versions'] == contract.CANDIDATES
    assert plan['reference_only_versions'] == contract.REFERENCES
    assert plan['opening_control'] == ORDER[0] and plan['primary_baseline'] == ORDER[-1]
    assert plan['source_parent_reference'] == 'C51-r2'
    assert plan['suites_per_member'] == 3 and plan['expected_benchmark_cases'] == 48
    assert plan['expected_compiler_banners'] == ['gcc (GCC) 10.3.1']
    assert plan['source_parents'] == contract.SOURCE_PARENTS
    assert plan['diagnostic_expected_checks'] == {name:37128 for name in contract.SOURCE_PARENTS}
    assert plan['diagnostic_source_versions'] == contract.DIAGNOSTIC_SOURCE_VERSIONS
    assert {name:str(job) for name,job in plan['diagnostic_jobs'].items()} == contract.DIAGNOSTIC_JOBS
    assert plan['auxiliary_comparisons'] == {'C52-row7x3shared2':'C51-r2'}
    assert plan['prior_job'] == '1582067' and plan['prior_campaign'] == '.runs/conv/sep13s-campaign.json'
    assert plan['prior_decisions'] == contract.old_decisions()
    assert plan['confirmation_only'] is False and plan['failed_confirmation_retry_allowed'] is False
    assert all(plan[key] is False for key in ('automatic_confirmation','automatic_promotion','automatic_packaging'))
    assert str(plan.get('performance_job','')).isdigit() and plan.get('performance_group')
    assert plan['submitted'] is True and plan['submit_attempted'] is True
    contract.verify_settings(plan['settings'])
    previous, records = contract.previous_gate()
    assert plan['settings'] == previous['settings']
    assert plan['candidate_source_hashes']['C51-r2'] == records['C51-r1']['source_hashes']


def verify_source_association(rec, plan):
    name = rec['version']
    assert name in ORDER
    baseline = e.get_record('conv','C26-row4loads')['source_hashes']
    if name in contract.CONTROLS:
        assert rec['source_hashes'] == baseline
        return
    assert rec['source_parent'] == contract.SOURCE_PARENTS[name]
    assert rec['parent'] == rec['comparison_baseline'] == plan['primary_baseline']
    assert rec['reference_only'] is (name in contract.REFERENCES)
    assert rec['promotion_allowed'] is (name in contract.CANDIDATES)
    assert rec['confirmation_only'] is False and rec['failed_confirmation_retry_allowed'] is False
    assert rec['source_hashes'] == plan['candidate_source_hashes'][name]
    assert all(rec['source_hashes'][key] == baseline[key] for key in ('README.md','bench_conv.c','run.sh'))
    assert rec['diagnostic_source_version'] == contract.DIAGNOSTIC_SOURCE_VERSIONS[name]
    assert rec['diagnostic_evidence_directory'] == plan['diagnostic_evidence_directories'][name]
    assert str(rec['diagnostic_job_id']) == str(plan['diagnostic_jobs'][name])
    assert rec['diagnostic_source_sha256'] == rec['source_hashes']['conv2d.c']
    assert rec['reused_identical_source_diagnostic'] is (name in contract.REFERENCES)
    # Independently associate changed C52 with T and byte-identical C51 with Q.
    diag, frozen = contract.diagnostic_gate(name, rec['source_hashes'])
    assert frozen == rec['diagnostic_evidence_directory']
    assert str(diag['job_id']) == str(rec['diagnostic_job_id'])
    if name in contract.REFERENCES:
        assert rec['source_hashes'] == e.get_record('conv',contract.SOURCE_VERSION)['source_hashes']
        assert rec['qualified_for_confirmation'] is False
        assert rec['prior_confirmation_version'] == 'C51-r1'
        assert rec['prior_confirmation_passed'] is False and rec['prior_confirmation_job'] == '1582067'


def verify_record(rec, plan, run):
    assert rec['version'] == run.name and rec['status'] == 'passed' and rec.get('verified') is True
    assert rec['repeats'] == plan['suites_per_member'] == 3
    assert rec['job_id'] == plan['performance_job'] and rec['settings'] == plan['settings']
    assert rec['environment'] == plan['record_environment'] and rec['reference'] == plan['record_reference']
    assert set(rec['checks']) == CHECKS and all(rec['checks'].values())
    assert [x['dims'] for x in rec['cases']] == DIMS and all(len(x['times_ms']) == 3 for x in rec['cases'])
    assert rec['source_hashes'] == e.source_files(run/'source')
    verify_machine(rec['machine'], plan)
    verify_source_association(rec, plan)


def verify_manifest(manifest, plan, name):
    assert manifest['job_id'] == plan['performance_job'] and manifest['group'] == plan['performance_group']
    assert manifest['group_index'] == ORDER.index(name) and manifest['measurement_order'] == ORDER
    assert manifest['settings'] == plan['settings']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('versions', nargs='*')
    args = parser.parse_args()
    plan = e.read_json(ROOT/'.runs/conv/sep13w-campaign.json')
    verify_plan(plan)
    names = args.versions or ORDER
    assert len(set(names)) == len(names) and all(n in ORDER for n in names)
    cfg = cluster.load_config(ROOT/'config/conv-sep12.local.json')
    assert cluster.effective_settings(cfg, {'settings':plan['settings']}) == plan['settings']
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    for name in ORDER:
        verify_manifest(cluster.read_json(ROOT/'.runs/conv'/name/'cluster.json'), plan, name)
    for name in names:
        run = ROOT/'.runs/conv'/name
        with (run/('status-driver-sep13w-'+stamp+'.log')).open('x') as output, contextlib.redirect_stdout(output):
            cluster.status(cfg, run)
        manifest = cluster.read_json(run/'cluster.json')
        verify_manifest(manifest, plan, name)
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == str(plan['performance_job'])
        assert status.get('state',status.get('status')) == 'SUCCEEDED'
        assert str(status.get('jobExitCode')) == str(status.get('systemExitCode')) == '0'
    for name in names:
        run = ROOT/'.runs/conv'/name
        previous = e.get_record('conv', name)
        if previous['status'] == 'passed':
            verify_record(previous, plan, run)
            print(name, 'already recorded; preserving all matching original measurements')
            continue
        assert previous['status'] in ('planned','prepared','unverified'), (name,'Failed/immutable evidence must remain unchanged')
        with (run/('fetch-driver-sep13w-'+stamp+'.log')).open('x') as output, contextlib.redirect_stdout(output):
            cluster.fetch(cfg, run)
        verify_machine(e.machine_profile(run,(run/'benchmark.log').read_text(errors='replace')), plan)
        metadata = e.read_json(run/'experiment.json')
        # experiment.json preserves the creation-time source snapshot;
        # checkpoint updates the prepared record, and record uses current source.
        # Require the prepared and actually submitted identities before adapting
        # only this in-memory view; leave creation metadata and samples intact.
        source = e.source_files(run/'source')
        manifest = cluster.read_json(run/'cluster.json')
        assert previous['source_hashes'] == source == manifest['source_hashes']
        verify_source_association(previous, plan)
        verify_source_association(dict(metadata, source_hashes=source), plan)
        args_record = argparse.Namespace(problem='conv',version=name,log=str(run/'benchmark.log'),
            environment=plan['record_environment'],reference=plan['record_reference'],repeats=3,
            scheduler_status=None,failure=None)
        with e.locked():
            e.record(args_record)
        result = e.get_record('conv', name)
        verify_record(result, plan, run)
        print(json.dumps(dict(version=name,status=result['status'],verified=result['verified'],
            total_median_ms=result['total_median_ms'],cases_ms=[x['median_ms'] for x in result['cases']],
            max_spread_pct=max(x['spread_pct'] for x in result['cases'])),ensure_ascii=False))


if __name__ == '__main__':
    main()
