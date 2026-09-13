"""Compare all N records within one allocation; never promote or package.

C40-r3 is a declared reference, not another confirmation. Auxiliary comparisons
never replace the five independent candidate-versus-C6 eligibility decisions.
"""
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
import experiment as e

spec = importlib.util.spec_from_file_location('sep12n_record_checks',Path(__file__).with_name('sep12n-record-group.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def main():
    path = ROOT/'.runs/conv/sep12n-campaign.json'
    with e.locked():
        plan = e.read_json(path)
        checks.verify_plan(plan)
        old_decisions = checks.contract.old_c40_decisions()
        records = {n:e.get_record('conv',n) for n in checks.ORDER}
        baseline, opening = records[plan['primary_baseline']], records[plan['opening_control']]
        for name, rec in records.items():
            run = ROOT/'.runs/conv'/name
            checks.verify_record(rec, plan, run)
            assert rec['machine'] == baseline['machine'], (name,'Different actual same-group machine/compiler')
            manifest = e.read_json(run/'cluster.json')
            checks.verify_manifest(manifest, plan, name)
            assert rec['source_hashes'] == manifest['source_hashes']
            status = manifest.get('scheduler_status') or {}
            assert str(status.get('jobId')) == str(plan['performance_job'])
            assert status.get('state',status.get('status')) == 'SUCCEEDED'
            assert str(status.get('jobExitCode')) == str(status.get('systemExitCode')) == '0'
            assert (run/'exit-code.txt').read_text().strip() == '0'
        assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 96
        assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv','C26-row4loads')['source_hashes']
        for name, rec in records.items():
            rec['qualified_for_confirmation'] = False
            if name in checks.contract.CONTROLS:
                rec['decision_note'] = 'Unchanged C6 control; not a new candidate.'
                continue
            rec['comparison_baseline'] = baseline['version']
            rec['comparison'] = e.comparison(baseline, rec)
            rec['opening_control_comparison'] = {'baseline':opening['version'],**e.comparison(opening,rec)}
            if name in checks.contract.REFERENCES:
                assert rec['reference_only'] is True and rec['promotion_allowed'] is False
                rec['decision_note'] = 'C40 same-source reference-only for C47/C48 context. Never qualifies or promotes; original G false/J true/K false unchanged. Not a C40 confirmation.'
                continue
            assert rec['promotion_allowed'] is True and rec['reference_only'] is False
            rec['qualified_for_confirmation'] = bool(rec['comparison']['eligible'] and rec['opening_control_comparison']['eligible'])
            rec['decision_note'] = ('Initial candidate qualifies versus both same-job C6 controls; root independent confirmation and exact original ZIP remain required.'
                if rec['qualified_for_confirmation'] else 'Does not meet both C6 gates; retain every sample and C6. No automatic exclusion or promotion.')
        for name in ('C47-row6x4u1','C48-row8x2u1'):
            rec = records[name]
            reference = records['C40-r3']
            rec['rowsix_reference_comparison'] = {'baseline':'C40-r3',**e.comparison(reference,rec)}
            rec['rowsix_comparison_supported_in_initial_group'] = rec['rowsix_reference_comparison']['eligible']
            rec['rowsix_attribution_note'] = 'Separate whole-implementation comparison with unchanged C40 source in this allocation. Rows/vector shape, instruction scheduling, tails and dispatch may all contribute; this cannot isolate spill cost and does not replace usefulness against C6.'
        fenced = records['C49-row4dup4fence']
        fenced['compiler_scheduling_comparison'] = {'baseline':'C45-row4dup4',**e.comparison(records['C45-row4dup4'],fenced)}
        fenced['compiler_scheduling_supported_in_initial_group'] = fenced['compiler_scheduling_comparison']['eligible']
        fenced['compiler_scheduling_attribution_note'] = 'Whole compiler-scheduling result of three empty source barriers versus C45 in this allocation; no hardware fence or isolated spill-cost measurement. The C6 usefulness gate remains independent.'
        rows = []
        extra = ('comparison','opening_control_comparison','rowsix_reference_comparison',
                 'rowsix_comparison_supported_in_initial_group','compiler_scheduling_comparison',
                 'compiler_scheduling_supported_in_initial_group')
        for name, rec in records.items():
            rows.append(dict(version=name,total_median_ms=rec['total_median_ms'],
                cases_ms=[x['median_ms'] for x in rec['cases']],max_spread_pct=max(x['spread_pct'] for x in rec['cases']),
                gain_pct=(1-rec['total_median_ms']/baseline['total_median_ms'])*100,
                reference_only=name in checks.contract.REFERENCES,
                qualified_for_confirmation=rec['qualified_for_confirmation'],decision_note=rec['decision_note'],
                **{k:rec.get(k) for k in extra}))
        assert checks.contract.old_c40_decisions() == old_decisions
        assert records['C40-r3']['qualified_for_confirmation'] is False
        # These eight new N records and N campaign alone receive comparison fields.
        for name, rec in records.items():
            e.write_json(e.record_path('conv',name),rec)
        plan.update(status='performance_complete',results=rows,final_selection=None,
            confirmation_pending=[n for n in checks.contract.CANDIDATES if records[n]['qualified_for_confirmation']],
            prior_c40_decisions_unchanged=True,automatic_promotion=False,automatic_packaging=False)
        e.write_json(path,plan)
    print(json.dumps(dict(round='sep12n',results=rows,prior_c40_decisions_unchanged=True),ensure_ascii=False,indent=2))


if __name__ == '__main__':
    main()
