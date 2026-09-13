"""Prepared W four-member comparison; root review and explicit --go required.

C52 uses only its own frozen T diagnostic. C51-r2 is background reference-only,
never a retry of failed S. No work happens on import beyond loading definitions.
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

spec = importlib.util.spec_from_file_location('sep13w_prior_s_checks', Path(__file__).with_name('sep13s-record-group.py'))
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
s = prior.contract
r = s.r

ORDER = ['C26-r26', 'C52-row7x3shared2', 'C51-r2', 'C26-r27']
CANDIDATES = ['C52-row7x3shared2']
REFERENCES = ['C51-r2']
CONTROLS = ['C26-r26', 'C26-r27']
SOURCE_VERSION = 'C51-row7x3u1'
SOURCE_PARENTS = {'C52-row7x3shared2': SOURCE_VERSION, 'C51-r2': SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {'C52-row7x3shared2': 'C52-row7x3shared2', 'C51-r2': SOURCE_VERSION}
DIAGNOSTIC_JOBS = {'C52-row7x3shared2': '1582134', 'C51-r2': '1581822'}
SOURCE_SHA = {'C52-row7x3shared2': '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7',
              'C51-r2': '5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff'}
RESOURCES = r.RESOURCES
ENVIRONMENT = r.ENVIRONMENT
TERMINAL = r.TERMINAL
verify_settings = r.verify_settings


def old_decisions():
    decisions = s.old_c40_decisions()
    plan = e.read_json(ROOT / '.runs/conv/sep13s-campaign.json')
    candidate = e.get_record('conv', 'C51-r1')
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == candidate['job_id'] == '1582067'
    assert plan['confirmation_passed'] is candidate['confirmation_passed'] is False
    assert plan['confirmation_pending'] == [] and candidate['qualified_for_confirmation'] is False
    assert candidate['source_hashes'] == e.get_record('conv', SOURCE_VERSION)['source_hashes']
    return dict(decisions, S_confirmation_passed=False, S_confirmation_job='1582067',
                C51_reference_only=True, C51_promotion_allowed=False, C51_qualified=False,
                failed_S_confirmation_retried=False)


def previous_gate():
    # Reuse reviewed S checks: they verify the complete original R48 as well.
    # These arrays are evidence of historical decisions, never W timing samples.
    plan = e.read_json(ROOT / '.runs/conv/sep13s-campaign.json')
    prior.verify_plan(plan)
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1582067'
    assert plan['confirmation_passed'] is False and plan['confirmation_pending'] == []
    records = {name: e.get_record('conv', name) for name in prior.ORDER}
    baseline, opening = records['C26-r25'], records['C26-r24']
    assert len(plan['results']) == 3 and [row['version'] for row in plan['results']] == prior.ORDER
    for index, (name, rec) in enumerate(records.items()):
        run = ROOT / '.runs/conv' / name
        prior.verify_record(rec, plan, run)
        manifest = e.read_json(run / 'cluster.json')
        prior.verify_manifest(manifest, plan, name)
        assert manifest['source_hashes'] == rec['source_hashes']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1582067' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert rec['machine'] == baseline['machine']
        row = plan['results'][index]
        assert row['total_median_ms'] == rec['total_median_ms']
        assert row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        assert row['qualified_for_confirmation'] is rec['qualified_for_confirmation'] is False
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 36
    assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    candidate = records['C51-r1']
    assert candidate['confirmation_passed'] is False
    for base, field in ((opening, 'opening_control_comparison'), (baseline, 'comparison')):
        actual = e.comparison(base, candidate)
        saved = candidate[field]
        assert saved['baseline'] == base['version']
        assert all(saved[key] == value for key, value in actual.items())
    assert not (candidate['comparison']['eligible'] and candidate['opening_control_comparison']['eligible'])
    old_decisions()
    return plan, records


def serial_gate(cfg):
    # Fixed bounded inventory, not the older broad R/S serial scan. Missing P
    # is unreserved; an existing file with an unknown ID always blocks.
    paths = [(ROOT / '.runs/conv/sep13r-campaign.json', 'performance_job', '1581911', True),
             (ROOT / '.runs/conv/sep13s-campaign.json', 'performance_job', '1582067', True),
             (ROOT / '.runs/conv/sep13t-checks/C52-row7x3shared2/job.json', 'job_id', '1582134', True),
             (ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json', 'job_id', None, False),
             (ROOT / '.runs/conv/sep13w-campaign.json', 'performance_job', None, False)]
    paths += [(ROOT / '.runs/conv' / name / 'cluster.json', 'job_id', None, False) for name in ORDER]
    identities, unresolved = {}, []
    for path, field, expected, required in paths:
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
        if 'sep13p-checks' in str(path) and row.get('version') != 'C50-row4dupfencenomem':
            unresolved.append(dict(path=origin, reason='Unexpected P reservation identity'))
            continue
        identities.setdefault(job, []).append(origin)
    evidence = [r.query_job(cfg, job, origins) for job, origins in identities.items()]
    clear = not unresolved and all(row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), clear=clear,
                jobs=evidence, unresolved_submissions=unresolved)


def diagnostic_gate(name, source):
    assert name in CANDIDATES + REFERENCES and source['conv2d.c'] == SOURCE_SHA[name]
    if name in REFERENCES:
        assert source == e.get_record('conv', SOURCE_VERSION)['source_hashes']
        diag, frozen = r.diagnostic_gate(DIAGNOSTIC_SOURCE_VERSIONS[name], source)
        assert str(diag['job_id']) == DIAGNOSTIC_JOBS[name]
        return diag, frozen
    # C52 has a changed shared loop: Q cannot supply C52 correctness/codegen.
    frozen = ROOT / '.runs/conv/C52-row7x3shared2/sve-correctness-sep13t'
    diag = e.read_json(frozen / 'validation.json')
    assert diag['candidate'] == name and diag['status'] == 'passed' and diag['complete'] is True
    assert str(diag['job_id']) == DIAGNOSTIC_JOBS[name]
    assert diag['exit_code'] == 0 and diag['compiler_version'] == '10.3.1'
    expected_checks = dict(full_per_configuration=4784, dispatch_per_configuration=972,
        direct_per_configuration=432, configurations=6, total=37128)
    assert diag['expected_checks'] == expected_checks
    assert (diag['total_cases'], diag['full_cases'], diag['dispatch_cases'], diag['direct_cases'], diag['runner_cases']) == (37128,28704,5832,2592,0)
    scheduler = diag['scheduler']
    assert str(scheduler['jobId']) == str(diag['job_id']) and scheduler['status'] == 'SUCCEEDED'
    assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
    job = e.read_json(frozen / 'job.json')
    assert job['version'] == name and str(job['job_id']) == str(diag['job_id'])
    assert job['scheduler_status'] == scheduler and job['resources'] == RESOURCES
    assert c.parse_scheduler_status((frozen / 'scheduler.log').read_text(), str(diag['job_id'])) == scheduler
    assert len(diag['allocation']['cpus']) == len(set(diag['allocation']['cpus'])) == 38 and diag['allocation']['numa_node']
    assert (frozen / 'raw/exit-code.txt').read_text().strip() == '0'
    assert diag['source_hashes_verified'] is True and diag['source_manifest_remote_matches'] is True
    assert diag['source_hashes']['conv2d.c'] == source['conv2d.c'] == e.digest(frozen / 'raw/conv2d.c')
    stages = ['allocation','compiler','manifest','build-guard']
    stages += [f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-dispatch'] + [f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-assembly','complete']
    assert diag['stage_exits'] == [dict(stage=stage, exit_code=0) for stage in stages]
    assert (frozen / 'raw/stage-exits.txt').read_text().splitlines() == ['STAGE='+stage+' EXIT=0' for stage in stages]
    common = ['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra',
              '-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp','-DEXPECTED_ACC=3']
    expected_argv = [common+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],
        common+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],
        common+['-S','conv2d.c','-o','conv2d-sve.s']]
    assert diag['build_commands']['commands'] == expected_argv
    assert diag['build_commands']['actual_trace_locations']
    configs = diag['configurations']
    assert len(configs) == 6 and {(x['sve_bytes'], x['threads']) for x in configs} == {(v,t) for v in (16,32,64) for t in (1,4)}
    for item in configs:
        assert item['passed'] is True and item['lanes'] == item['sve_bytes']//4
        assert item['block_outputs_per_row'] == 3*item['lanes']
        assert (item['full_cases'], item['dispatch_cases'], item['direct_cases']) == (4784,972,432)
        assert all(item['helper_entries'][key] > 0 for key in ('prefix','tail','rowpair','rowtriple','rowquad'))
        assert (item['dispatch_entries'], item['direct_entries']) == (756,1080)
        assert item['dispatch_worker_mask'] == item['direct_worker_mask'] == (1 << item['threads'])-1
    assembly = diag['assembly']
    assert assembly['candidate'] == name and str(assembly['job_id']) == str(diag['job_id'])
    assert assembly['source_sha256'] == source['conv2d.c'] and assembly['compiler_version'] == '10.3.1'
    assert assembly['assembly_sha256'] == e.digest(frozen / 'raw/conv2d-sve.s')
    assert all(assembly[key] is True for key in ('review_complete','production_uninstrumented',
        'whole_helper_stack_reviewed','transitions_reviewed','all_stages_and_transitions_reviewed',
        'abi_saves_distinguished','dispatch_reviewed','shared_pair_and_remainder_reviewed'))
    assert assembly['shape'] == dict(rows_per_group=7, vectors_per_row=3, accumulators=21)
    assert assembly['shared_unroll'] == dict(paired_columns=2, odd_remainder_columns=1, other_stage_columns=1)
    assert assembly['stage_count'] == 13 and assembly['arithmetic_region_count_per_helper'] == 14
    assert assembly['fma_count'] == assembly['whole_source_fma_count'] == 0
    assert assembly['whole_machine_code_identical_claimed'] is False and assembly['dispatch_functions']
    assert diag['performance_measured'] is False and diag['automatic_performance_submission'] is False
    assert diag['performance_requires_root_review'] is True and diag['executed_locally'] is False
    assert diag['executed_remotely'] is True and assembly['performance_submission_automatic'] is False
    phases = [f'input_{i}' for i in range(6)] + ['shared'] + [f'trailing_{i}' for i in range(6)]
    assert assembly['helpers']
    for helper in assembly['helpers']:
        assert helper['symbol'] == 'conv_sve_rowseven' or helper['symbol'].startswith('conv_sve_rowseven.')
        assert [item['stage'] for item in helper['stages']] == phases
        assert helper['line_start'] > 0 and helper['line_end'] >= helper['line_start']
        assert all(helper.get(key) for key in ('stack_frame_description','spill_notes',
            'transition_spill_review','tail_and_fallback_review','arithmetic_and_load_review'))
        assert all(type(helper[key]) is int and helper[key] >= 0 for key in ('vector_spill_loads','vector_spill_stores'))
        ranges = []
        for stage in helper['stages']:
            if stage['stage'] == 'shared':
                assert all(stage.get(key) for key in ('source_mapping','control_flow_notes',
                    'accumulator_order_review','pair_to_remainder_review','transition_spill_review'))
                blocks = stage['blocks']
                assert [block['block'] for block in blocks] == ['paired','odd_remainder']
                regions = list(zip(blocks, (2,1)))
                assert blocks[0]['region_kind'] == 'loop'
                assert blocks[1]['region_kind'] in ('loop','straight_line')
                assert all(block['entry_exit_notes'] for block in blocks)
            else:
                regions = [(stage,1)]
            for region, work in regions:
                a, z = region['line_start'], region['line_end']
                assert helper['line_start'] <= a <= z < helper['line_end']
                assert all(z < x or a > y for x, y in ranges)
                ranges.append((a,z))
                assert region['kernel_columns_per_iteration'] == work
                assert region['source_mapping'] and region['spill_notes']
                assert all(type(region[key]) is int and region[key] >= 0 for key in ('vector_spill_loads','vector_spill_stores'))
                counts = region['derived_counts']
                assert counts['fmul'] > 0 and counts['fadd'] > 0
                assert region['derived_counts_per_kernel_column'] == {key:value/work for key,value in counts.items()}
                if stage['stage'] == 'shared':
                    assert counts['fmul'] == counts['fadd'] == 21*work
        assert len(ranges) == 14
    freeze = e.read_json(frozen / 'freeze-source.json')
    assert freeze['candidate'] == name and str(freeze['job_id']) == str(diag['job_id'])
    assert freeze['mode'] == 'passed' and freeze['assembly_available'] is True
    assert all(freeze[key] is True for key in ('original_metadata_preserved',
        'original_source_and_raw_preserved','original_source_manifest_preserved'))
    assert freeze['validation_rewritten'] is False and freeze['operator_executed'] is False
    prepared = e.read_json(frozen / 'prepared.json')
    hashes = e.read_json(frozen / 'source-hashes.json')
    manifest = e.read_json(frozen / 'source-manifest.json')
    assert hashes == prepared['source_hashes'] == job['source_hashes'] == diag['source_hashes']
    assert set(hashes) == {'conv2d.c','check_conv_guard.c','check_sve_dispatch.c','remote_job.sh','candidate.env'}
    assert prepared['candidate'] == name and prepared['source_sha256'] == source['conv2d.c']
    assert prepared['expected_checks'] == expected_checks and prepared['total_cases_planned'] == 37128
    assert prepared['runner_cases_planned'] == 0 and prepared['expected_semantic_stage_count'] == 13
    assert prepared['shared_kernel_columns_per_iteration'] == 2
    assert prepared['shared_odd_remainder_columns_per_iteration'] == prepared['other_stage_kernel_columns_per_iteration'] == 1
    assert prepared['expected_rowseven_entries'] == dict(dispatch_per_configuration=756, direct_per_configuration=1080)
    assert set(manifest) == set(hashes)
    assert all(manifest[key]['sha256'] == hashes[key] and manifest[key]['bytes'] > 0 for key in hashes)
    assert e.digest(frozen / 'raw/conv2d-sve.assembly.txt') == assembly['assembly_sha256']
    return diag, str(frozen.relative_to(ROOT))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before W writes or SSH'
    path = ROOT / '.runs/conv/sep13w-campaign.json'
    assert not path.exists(), 'W already reserved; reconcile original job and never resubmit'
    for name in CONTROLS + REFERENCES:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    decisions = old_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == old_records['C26-r25']['source_hashes'] == e.get_record('conv','C26-row4loads')['source_hashes']
    settings = previous['settings']
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
            assert rec['source_parent'] == SOURCE_PARENTS[name] and rec.get('reference_only',False) is False
        source = e.source_files(run / 'source')
        assert source == rec['source_hashes'] and set(source) == set(current)
        assert all(source[key] == current[key] for key in ('README.md','bench_conv.c','run.sh'))
        diag, frozen_paths[name] = diagnostic_gate(name, source)
        sources[name], jobs[name] = source, diag['job_id']
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13w-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Known R/S/T/P or W work active/unknown; no W reservation or submission'
    plan = dict(round='sep13w', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], source_parent_reference='C51-r2',
        suites_per_member=3, expected_benchmark_cases=48, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep13w',
        record_reference=previous['record_reference'], best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS,
        diagnostic_expected_checks={name:37128 for name in sources}, prior_job='1582067',
        prior_campaign='.runs/conv/sep13s-campaign.json', prior_decisions=decisions,
        auxiliary_comparisons={'C52-row7x3shared2':'C51-r2'}, confirmation_only=False,
        failed_confirmation_retry_allowed=False,
        selection_rule='Use only all48 W samples. C52 must independently pass both unchanged same-job C6 controls: total median gain strictly exceeds max(1%, all compared case spreads), and no individual case regresses over1%. Keep every slow sample. Initial qualification is only a flag for root review.',
        attribution_rule='C52 versus same-source C51-r2 is a separate whole-implementation background comparison and never replaces either C6 gate. C51-r2 is reference-only, promotion_allowed=false, qualified_for_confirmation=false. S confirmation remains false; this is not a retry of S.',
        local_compilation_or_tests_run=False, official_score=None, automatic_confirmation=False,
        automatic_promotion=False, automatic_packaging=False, submitted=False, submit_attempted=False)
    with e.locked():
        assert not path.exists()
        latest, latest_records = previous_gate()
        assert latest == previous and latest_records == old_records and old_decisions() == decisions
        assert e.source_files(ROOT/'conv') == current and e.read_json(ROOT/'outputs/conv-best.json')['label'] == 'C6'
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
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 W-round matched control'))
        e.new(argparse.Namespace(problem='conv',version='C51-r2',parent=SOURCE_VERSION,
            strategy='Same-source C51 background reference for C52; promotion forbidden, not a failed S confirmation retry'))
        for name in ORDER:
            meta_path = ROOT/'.runs/conv'/name/'experiment.json'
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
                if name in REFERENCES:
                    meta.update(prior_confirmation_version='C51-r1',prior_confirmation_passed=False,
                                prior_confirmation_job='1582067')
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv',version=name,
                note='W fixed four-member order, three independent original official suites each, total48 cases. C52 requires its own actual frozen T37128. C51-r2 copies original C51 with Q37128 as background reference-only; Sfalse preserved, not a confirmation repeat. Both C6 controls unchanged. No local operator execution.'))
        plan.update(status='prepared', submit_attempted=True)
        e.write_json(path, plan)
    cluster_group.submit_group(cfg, [ROOT/'.runs/conv'/name for name in ORDER])
    manifests = [c.read_json(ROOT/'.runs/conv'/name/'cluster.json') for name in ORDER]
    job, group = manifests[0]['job_id'], manifests[0]['group']
    assert str(job).isdigit() and all(item['job_id']==job and item['group']==group for item in manifests)
    plan.update(status='performance_running',performance_job=job,performance_group=group,submitted=True)
    with e.locked():
        e.write_json(path, plan)


if __name__ == '__main__':
    main()
