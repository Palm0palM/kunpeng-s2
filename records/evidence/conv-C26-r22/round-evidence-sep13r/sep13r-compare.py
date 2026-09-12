"""Compare only all four saved R records; never confirm, promote or package.

C51 requires both unchanged C6 gates. C40-r4 remains reference-only regardless
of its numerical comparisons; all G/J/K/N decisions and samples are preserved.
"""
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import experiment as e

spec = importlib.util.spec_from_file_location('sep13r_record_checks', Path(__file__).with_name('sep13r-record-group.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def comparison(base, candidate):
    # The shared experiment rule is authoritative; these fields expose the
    # same all-sample threshold for review without changing that decision.
    verdict = e.comparison(base, candidate)
    return dict(baseline=base['version'], **verdict,
        total_gain_pct=(base['total_median_ms'] - candidate['total_median_ms']) / base['total_median_ms'] * 100,
        threshold_pct=max([1.0] + [case['spread_pct'] for case in base['cases'] + candidate['cases']]))


def main():
    path = ROOT / '.runs/conv/sep13r-campaign.json'
    with e.locked():
        plan = e.read_json(path)
        checks.verify_plan(plan)
        old_decisions = checks.contract.old_c40_decisions()
        records = {name: e.get_record('conv', name) for name in checks.ORDER}
        baseline = records[plan['primary_baseline']]
        opening = records[plan['opening_control']]
        for name, rec in records.items():
            run = ROOT / '.runs/conv' / name
            checks.verify_record(rec, plan, run)
            assert rec['machine'] == baseline['machine'], (name, 'Different actual same-group machine/compiler')
            manifest = e.read_json(run / 'cluster.json')
            checks.verify_manifest(manifest, plan, name)
            assert rec['source_hashes'] == manifest['source_hashes']
            status = manifest.get('scheduler_status') or {}
            assert str(status.get('jobId')) == str(plan['performance_job'])
            assert status.get('state', status.get('status')) == 'SUCCEEDED'
            assert str(status.get('jobExitCode')) == str(status.get('systemExitCode')) == '0'
            assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 48
        assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
        for name, rec in records.items():
            rec['qualified_for_confirmation'] = False
            if name in checks.contract.CONTROLS:
                rec['decision_note'] = 'Unchanged C6 control; not a new candidate.'
                continue
            rec['comparison_baseline'] = baseline['version']
            rec['comparison'] = comparison(baseline, rec)
            rec['opening_control_comparison'] = comparison(opening, rec)
            if name in checks.contract.REFERENCES:
                assert rec['reference_only'] is True and rec['promotion_allowed'] is False
                rec['decision_note'] = 'Same-source C40 reference-only for C51 context. Never qualifies or promotes; Gfalse/Jtrue/Kfalse and Nreference remain unchanged. Not a C40 confirmation.'
                continue
            assert name == 'C51-row7x3u1' and rec['promotion_allowed'] is True and rec['reference_only'] is False
            rec['qualified_for_confirmation'] = bool(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
            rec['decision_note'] = ('Initial C51 candidate qualifies versus both same-job C6 controls; return to root for an independent next-step decision. No automatic confirmation, promotion or ZIP.'
                if rec['qualified_for_confirmation'] else 'C51 does not meet both C6 gates; retain every sample and C6. No automatic confirmation, promotion or ZIP.')
        candidate = records['C51-row7x3u1']
        candidate['rowsix_reference_comparison'] = comparison(records['C40-r4'], candidate)
        candidate['rowsix_comparison_supported_in_initial_group'] = candidate['rowsix_reference_comparison']['eligible']
        candidate['rowsix_attribution_note'] = 'Separate whole-implementation comparison between seven-row/three-vector C51 and unchanged six-row/three-vector C40 source in this allocation. Scheduling, tails and dispatch may contribute; this cannot isolate spill cost and does not replace C6 usefulness.'
        rows = []
        extra = ('comparison', 'opening_control_comparison', 'rowsix_reference_comparison',
                 'rowsix_comparison_supported_in_initial_group')
        for name, rec in records.items():
            rows.append(dict(version=name, total_median_ms=rec['total_median_ms'],
                cases_ms=[case['median_ms'] for case in rec['cases']],
                all_samples_ms=[case['times_ms'] for case in rec['cases']],
                case_spreads_pct=[case['spread_pct'] for case in rec['cases']],
                max_spread_pct=max(case['spread_pct'] for case in rec['cases']),
                gain_pct=(1 - rec['total_median_ms'] / baseline['total_median_ms']) * 100,
                reference_only=name in checks.contract.REFERENCES,
                qualified_for_confirmation=rec['qualified_for_confirmation'],
                decision_note=rec['decision_note'], **{key: rec.get(key) for key in extra}))
        assert checks.contract.old_c40_decisions() == old_decisions
        assert records['C40-r4']['qualified_for_confirmation'] is False
        # These four R records and R campaign alone receive comparison fields.
        for name, rec in records.items():
            e.write_json(e.record_path('conv', name), rec)
        plan.update(status='performance_complete', results=rows, final_selection=None,
            confirmation_pending=[name for name in checks.contract.CANDIDATES if records[name]['qualified_for_confirmation']],
            prior_c40_decisions_unchanged=True, automatic_confirmation=False,
            automatic_promotion=False, automatic_packaging=False)
        e.write_json(path, plan)
    print(json.dumps(dict(round='sep13r', results=rows, prior_c40_decisions_unchanged=True), ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
