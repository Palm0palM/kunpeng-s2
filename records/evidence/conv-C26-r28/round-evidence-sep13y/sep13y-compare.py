"""Judge only the independent Y confirmation; keep all original36 samples.

No pooled W/Y measurements, failed-confirmation retry, promotion or packaging.
"""
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import experiment as e

spec = importlib.util.spec_from_file_location('sep13y_record_checks', Path(__file__).with_name('sep13y-record-group.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)
prior_spec = importlib.util.spec_from_file_location('sep13y_w_comparison_definition', Path(__file__).with_name('sep13w-compare.py'))
prior_comparison = importlib.util.module_from_spec(prior_spec)
prior_spec.loader.exec_module(prior_comparison)
comparison = prior_comparison.comparison


def main():
    path = ROOT / '.runs/conv/sep13y-campaign.json'
    with e.locked():
        plan = e.read_json(path)
        checks.verify_plan(plan)
        old_decisions = checks.contract.old_decisions()
        records = {name: e.get_record('conv', name) for name in checks.ORDER}
        opening = records[plan['opening_control']]
        baseline = records[plan['primary_baseline']]
        for name, record in records.items():
            run = ROOT / '.runs/conv' / name
            checks.verify_record(record, plan, run)
            assert record['machine'] == baseline['machine']
            manifest = e.read_json(run / 'cluster.json')
            checks.verify_manifest(manifest, plan, name)
            assert record['source_hashes'] == manifest['source_hashes']
            status = manifest.get('scheduler_status') or {}
            assert str(status.get('jobId')) == str(plan['performance_job'])
            assert status.get('state', status.get('status')) == 'SUCCEEDED'
            assert str(status.get('jobExitCode')) == str(status.get('systemExitCode')) == '0'
            assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert sum(len(case['times_ms']) for record in records.values() for case in record['cases']) == 36
        assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
        candidate = records['C52-r1']
        assert candidate['source_hashes'] == e.get_record('conv', checks.contract.SOURCE_VERSION)['source_hashes']
        candidate['comparison'] = comparison(baseline, candidate)
        candidate['opening_control_comparison'] = comparison(opening, candidate)
        passed = bool(candidate['comparison']['eligible'] and candidate['opening_control_comparison']['eligible'])
        candidate['confirmation_passed'] = passed
        candidate['confirmation_samples_scope'] = 'Only36 original Y samples; W initial qualification remains separate.'
        candidate['decision_note'] = ('Independent Y confirmation passed both current Y C6 gates. Return to root; no automatic promotion or ZIP.'
            if passed else 'Independent Y confirmation failed at least one current Y C6 gate. Preserve every original sample and C6; do not repeat failed confirmation or combine W/Y samples.')
        for name in checks.contract.CONTROLS:
            records[name]['decision_note'] = 'Unchanged C6 confirmation control; not a candidate.'
        rows = []
        for name, record in records.items():
            # Confirmation is a terminal decision of this experiment, not a new
            # initial qualifier that can trigger another automatic confirmation.
            record['qualified_for_confirmation'] = False
            rows.append(dict(version=name, total_median_ms=record['total_median_ms'],
                cases_ms=[case['median_ms'] for case in record['cases']],
                all_samples_ms=[case['times_ms'] for case in record['cases']],
                case_spreads_pct=[case['spread_pct'] for case in record['cases']],
                max_spread_pct=max(case['spread_pct'] for case in record['cases']),
                gain_pct=(1 - record['total_median_ms'] / baseline['total_median_ms']) * 100,
                confirmation_passed=record.get('confirmation_passed'),
                qualified_for_confirmation=False, decision_note=record['decision_note'],
                comparison=record.get('comparison'), opening_control_comparison=record.get('opening_control_comparison')))
        assert checks.contract.old_decisions() == old_decisions
        # Only the three Y records and Y campaign are written. W/S/reference history is untouched.
        for name, record in records.items():
            e.write_json(e.record_path('conv', name), record)
        plan.update(status='performance_complete', results=rows, confirmation_passed=passed,
            final_selection=None, confirmation_pending=[], prior_decisions_unchanged=True,
            samples_mixed_with_initial_round=False, failed_confirmation_retry_allowed=False,
            automatic_confirmation=False, automatic_promotion=False, automatic_packaging=False)
        e.write_json(path, plan)
    print(json.dumps(dict(round='sep13y', confirmation_passed=passed, results=rows,
        samples_mixed_with_initial_round=False, prior_decisions_unchanged=True), ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
