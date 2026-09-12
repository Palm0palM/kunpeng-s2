"""Prepared AF four-member comparison; root review and explicit --go required.

C56 requires its own actual frozen AE diagnostic. C55-r1 is reference-only,
never a confirmation retry after failed AD initial qualification. No work happens on import beyond loading definitions.
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

spec = importlib.util.spec_from_file_location('sep13af_prior_ad_checks', Path(__file__).with_name('sep13ad-record-group.py'))
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
ad = prior.contract
r = ad.r

ORDER = ['C26-r34', 'C56-row7shared3fence', 'C55-r1', 'C26-r35']
CANDIDATES = ['C56-row7shared3fence']
REFERENCES = ['C55-r1']
CONTROLS = ['C26-r34', 'C26-r35']
SOURCE_VERSION = 'C55-row7x3shared3'
SOURCE_PARENTS = {'C56-row7shared3fence': SOURCE_VERSION, 'C55-r1': SOURCE_VERSION}
DIAGNOSTIC_SOURCE_VERSIONS = {'C56-row7shared3fence': 'C56-row7shared3fence', 'C55-r1': SOURCE_VERSION}
DIAGNOSTIC_EXPECTED_CHECKS = {'C56-row7shared3fence': 44328, 'C55-r1': 44328}
AE_JOB_PATH = ROOT / '.runs/conv/sep13ae-checks/C56-row7shared3fence/job.json'
AE_JOB_ID = '1583102'  # Root's one actual AE submission, read from its saved job.json.
SOURCE_SHA = {'C56-row7shared3fence': '6c48bff4086a137d5fa425936a96e776b08ffdbd86f8a9e2816feda0f673224c',
              'C55-r1': 'cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138'}
FENCE_CONTRACT = dict(source_fences_per_main_iteration=3, input_accumulators_per_fence=21,
    output_operands=0, memory_clobber=True, empty_template=True)
RESOURCES = r.RESOURCES
ENVIRONMENT = r.ENVIRONMENT
TERMINAL = r.TERMINAL
verify_settings = r.verify_settings


def diagnostic_jobs():
    # Require AE's actual saved original reservation and later
    # bind that exact ID to C56 validation/freeze/raw evidence.
    job = e.read_json(AE_JOB_PATH)
    assert job['version'] == 'C56-row7shared3fence' and str(job.get('job_id', '')) == AE_JOB_ID
    assert job['source_hashes']['conv2d.c'] == SOURCE_SHA['C56-row7shared3fence']
    return {'C56-row7shared3fence': str(job['job_id']), 'C55-r1': '1582860'}


def old_decisions():
    decisions = ad.old_decisions()  # Reviewed historical decision identities, not new samples.
    plan = e.read_json(ROOT / '.runs/conv/sep13ad-campaign.json')
    candidate = e.get_record('conv', SOURCE_VERSION)
    reference = e.get_record('conv', 'C52-r3')
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == candidate['job_id'] == reference['job_id'] == '1582956'
    assert plan['confirmation_pending'] == [] and candidate['qualified_for_confirmation'] is False
    assert candidate['comparison']['eligible'] is candidate['opening_control_comparison']['eligible'] is False
    assert plan['reference_only_versions'] == ['C52-r3']
    assert reference['reference_only'] is True and reference['promotion_allowed'] is False
    assert reference['qualified_for_confirmation'] is False and reference['prior_confirmation_passed'] is False
    assert reference['prior_confirmation_version'] == 'C52-r1' and reference['prior_confirmation_job'] == '1582410'
    assert reference['source_hashes'] == e.get_record('conv', ad.SOURCE_VERSION)['source_hashes']
    return dict(decisions, AD_job='1582956', AD_C55_qualified=False,
                AD_C52_reference_only=True, AD_C52_promotion_allowed=False, AD_C52_qualified=False)

def previous_gate():
    # Validate only the latest complete AD48 with its reviewed record/machine/source
    # definitions. Do not recursively revalidate older campaign sample arrays.
    plan = e.read_json(ROOT / '.runs/conv/sep13ad-campaign.json')
    assert plan['round'] == 'sep13ad' and plan['measurement_order'] == prior.ORDER
    assert plan['candidate_versions'] == ad.CANDIDATES and plan['reference_only_versions'] == ad.REFERENCES
    assert plan['opening_control'] == 'C26-r32' and plan['primary_baseline'] == 'C26-r33'
    assert plan['source_parent_reference'] == 'C52-r3'
    assert plan['suites_per_member'] == 3 and plan['expected_benchmark_cases'] == 48
    assert plan['expected_compiler_banners'] == ['gcc (GCC) 10.3.1']
    assert plan['source_parents'] == ad.SOURCE_PARENTS
    assert plan['diagnostic_source_versions'] == ad.DIAGNOSTIC_SOURCE_VERSIONS
    assert plan['diagnostic_expected_checks'] == ad.DIAGNOSTIC_EXPECTED_CHECKS
    assert plan['diagnostic_jobs'] == ad.diagnostic_jobs()
    assert plan['auxiliary_comparisons'] == {'C55-row7x3shared3':'C52-r3'}
    assert plan['confirmation_only'] is False and plan['failed_confirmation_retry_allowed'] is False
    assert all(plan[key] is False for key in ('automatic_confirmation','automatic_promotion','automatic_packaging'))
    assert plan['submitted'] is True and plan['submit_attempted'] is True and plan['performance_group']
    verify_settings(plan['settings'])
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1582956'
    assert plan['confirmation_pending'] == [] and plan['prior_decisions_unchanged'] is True
    records = {name: e.get_record('conv', name) for name in prior.ORDER}
    baseline, opening = records['C26-r33'], records['C26-r32']
    assert len(plan['results']) == 4 and [row['version'] for row in plan['results']] == prior.ORDER
    for index, (name, rec) in enumerate(records.items()):
        run = ROOT / '.runs/conv' / name
        prior.verify_record(rec, plan, run)
        manifest = e.read_json(run / 'cluster.json')
        prior.verify_manifest(manifest, plan, name)
        assert manifest['source_hashes'] == rec['source_hashes']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1582956' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert rec['machine'] == baseline['machine']
        row = plan['results'][index]
        assert row['total_median_ms'] == rec['total_median_ms']
        assert row['all_samples_ms'] == [case['times_ms'] for case in rec['cases']]
        assert row['qualified_for_confirmation'] is rec['qualified_for_confirmation'] is False
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 48
    assert opening['source_hashes'] == baseline['source_hashes'] == e.get_record('conv', 'C26-row4loads')['source_hashes']
    candidate = records['C55-row7x3shared3']
    assert candidate['qualified_for_confirmation'] is False
    for base, field in ((opening, 'opening_control_comparison'), (baseline, 'comparison'),
                        (records['C52-r3'], 'source_parent_reference_comparison')):
        actual = e.comparison(base, candidate)
        saved = candidate[field]
        assert saved['baseline'] == base['version']
        assert all(saved[key] == value for key, value in actual.items())
    assert not (candidate['comparison']['eligible'] and candidate['opening_control_comparison']['eligible'])
    old_decisions()
    return plan, records

def serial_gate(cfg):
    # Bounded original AE/AD/AC/AB/AA/Y/X/T identities and explicit P/AF reservations only.
    # An unknown P ID is not adopted automatically; root must reconcile it.
    paths = [(AE_JOB_PATH, 'job_id', diagnostic_jobs()['C56-row7shared3fence'], True, 'C56-row7shared3fence'),
             (ROOT / '.runs/conv/sep13ad-campaign.json', 'performance_job', '1582956', True, None),
             (ROOT / '.runs/conv/sep13ac-checks/C55-row7x3shared3/job.json', 'job_id', '1582860', True, SOURCE_VERSION),
             (ROOT / '.runs/conv/sep13ab-campaign.json', 'performance_job', '1582814', True, None),
             (ROOT / '.runs/conv/sep13aa-checks/C54-row7x3shared4/job.json', 'job_id', '1582656', True, 'C54-row7x3shared4'),
             (ROOT / '.runs/conv/sep13y-campaign.json', 'performance_job', '1582410', True, None),
             (ROOT / '.runs/conv/sep13x-checks/C53-row7cursors/job.json', 'job_id', '1582372', True, 'C53-row7cursors'),
             (ROOT / '.runs/conv/sep13t-checks/C52-row7x3shared2/job.json', 'job_id', '1582134', True, 'C52-row7x3shared2'),
             (ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json', 'job_id', None, False, 'C50-row4dupfencenomem'),
             (ROOT / '.runs/conv/sep13af-campaign.json', 'performance_job', None, False, None)]
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
        diag, frozen = ad.diagnostic_gate(DIAGNOSTIC_SOURCE_VERSIONS[name], source)
        assert str(diag['job_id']) == '1582860'
        return diag, frozen
    # C56 adds compiler fences: original C55/AC cannot supply its correctness/codegen.
    frozen = ROOT / '.runs/conv/C56-row7shared3fence/sve-correctness-sep13ae'
    diag = e.read_json(frozen / 'validation.json')
    assert diag['candidate'] == name and diag['status'] == 'passed' and diag['complete'] is True
    assert str(diag['job_id']) == diagnostic_jobs()[name]
    assert diag['exit_code'] == 0 and diag['compiler_version'] == '10.3.1'
    expected_checks = dict(full_per_configuration=5744, dispatch_per_configuration=1212,
        direct_per_configuration=432, configurations=6, total=44328)
    assert diag['expected_checks'] == expected_checks
    assert (diag['total_cases'], diag['full_cases'], diag['dispatch_cases'], diag['direct_cases'], diag['runner_cases']) == (44328,34464,7272,2592,0)
    scheduler = diag['scheduler']
    assert str(scheduler['jobId']) == str(diag['job_id']) and scheduler['status'] == 'SUCCEEDED'
    assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
    job = e.read_json(frozen / 'job.json')
    assert job['version'] == name and str(job['job_id']) == str(diag['job_id'])
    original_job = e.read_json(AE_JOB_PATH)
    assert original_job['source_hashes'] == job['source_hashes']
    assert original_job['expected_checks'] == job['expected_checks'] == expected_checks
    assert job['scheduler_status'] == scheduler and job['resources'] == RESOURCES
    assert job['expected_checks'] == expected_checks
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
        assert (item['full_cases'], item['dispatch_cases'], item['direct_cases']) == (5744,1212,432)
        assert item['full_matrix_counts'] == dict(core=3888,narrow=144,small=720,larger=32,quad_boundary=960)
        assert item['dispatch_matrix_counts'] == dict(core=972,quad_boundary=240)
        assert all(item['helper_entries'][key] > 0 for key in ('prefix','tail','rowpair','rowtriple','rowquad'))
        assert (item['dispatch_entries'], item['direct_entries']) == (1236,1080)
        assert item['dispatch_worker_mask'] == item['direct_worker_mask'] == (1 << item['threads'])-1
    assembly = diag['assembly']
    assert assembly['candidate'] == name and str(assembly['job_id']) == str(diag['job_id'])
    assert assembly['source_sha256'] == source['conv2d.c'] and assembly['compiler_version'] == '10.3.1'
    assert assembly['assembly_sha256'] == e.digest(frozen / 'raw/conv2d-sve.s')
    assert assembly['schema'] == 'ae-shared3-fence-paths-v1'
    assert all(assembly[key] is True for key in ('review_complete','production_uninstrumented',
        'whole_helper_stack_reviewed','transitions_reviewed','all_stages_and_transitions_reviewed',
        'abi_saves_distinguished','dispatch_reviewed','shared_triple_and_remainder_reviewed','column_fences_reviewed'))
    assert assembly['shape'] == dict(rows_per_group=7, vectors_per_row=3, accumulators=21)
    assert assembly['shared_unroll'] == dict(main_columns=3,remainder_source_columns=1,remainder_max_columns=2,other_stage_columns=1)
    assert assembly['stage_count'] == 13
    assert assembly['fma_count'] == assembly['whole_source_fma_count'] == 0
    assert assembly['whole_machine_code_identical_claimed'] is False and assembly['dispatch_functions']
    assert diag['performance_measured'] is False and diag['automatic_performance_submission'] is False
    assert diag['performance_requires_root_review'] is True and diag['executed_locally'] is False
    assert diag['executed_remotely'] is True and assembly['performance_submission_automatic'] is False
    phases = [f'input_{i}' for i in range(6)] + ['shared'] + [f'trailing_{i}' for i in range(6)]
    assert assembly['helpers']
    helper_symbols = [helper['symbol'] for helper in assembly['helpers']]
    assert len(set(helper_symbols)) == len(helper_symbols)
    assert set(assembly['arithmetic_region_counts']) == set(helper_symbols)
    for helper in assembly['helpers']:
        assert helper['symbol'] == 'conv_sve_rowseven' or helper['symbol'].startswith('conv_sve_rowseven.')
        assert [item['stage'] for item in helper['stages']] == phases
        assert helper['line_start'] > 0 and helper['line_end'] >= helper['line_start']
        assert all(helper.get(key) for key in ('stack_frame_description','spill_notes',
            'transition_spill_review','tail_and_fallback_review','arithmetic_and_load_review',
            'shared_index_reset_review','input_kernel_bounds_review','scalar_address_stack_review'))
        assert all(type(helper[key]) is int and helper[key] >= 0 for key in ('vector_spill_loads','vector_spill_stores'))
        ranges = []
        for stage in helper['stages']:
            if stage['stage'] == 'shared':
                fence = stage['column_fence_review']
                assert fence['source_contract'] == FENCE_CONTRACT
                assert type(fence['schedule_tightened']) is bool  # A reviewed false effect is valid evidence.
                assert all(isinstance(fence.get(key),str) and fence[key].strip() for key in
                    ('actual_schedule_review','cross_column_motion_review','loop_boundary_review','spill_relocation_review'))
                boundaries = fence['boundaries']
                assert isinstance(boundaries,list) and [item['column_index'] for item in boundaries] == [0,1,2]
                assert all(type(item['column_index']) is int
                    and isinstance(item.get('actual_evidence'),str) and item['actual_evidence'].strip()
                    and type(item['all_accumulators_ready_before_next_column_loads']) is bool for item in boundaries)
                assert all(stage.get(key) for key in ('source_mapping','control_flow_notes',
                    'accumulator_order_review','triple_to_remainder_review','transition_spill_review',
                    't_and_tile_reset_review'))
                blocks = stage['blocks']
                assert blocks and {block['role'] for block in blocks} == {'triple_main','u1_remainder'}
                ids = [block['block_id'] for block in blocks]
                assert all(isinstance(x,str) and x for x in ids) and len(set(ids)) == len(ids)
                regions = []
                for block in blocks:
                    work = block['kernel_columns_per_iteration']
                    role, kind = block['role'], block['region_kind']
                    assert kind in ('loop','straight_line')
                    assert type(work) is int and (work == 3 if role == 'triple_main' else 1 <= work <= 2)
                    assert role != 'u1_remainder' or kind != 'loop' or work == 1
                    assert all(block.get(key) for key in ('source_mapping','spill_notes','entry_exit_notes',
                        'column_order_review','control_flow_evidence'))
                    assert all(type(block[key]) is int and block[key] >= 0 for key in ('vector_spill_loads','vector_spill_stores'))
                    counts = block['derived_counts']
                    assert counts['fmul'] == counts['fadd'] == 21*work
                    assert block['derived_counts_per_kernel_column'] == {key:value/work for key,value in counts.items()}
                    assert block['ranges']
                    for part in block['ranges']:
                        regions.append((dict(block,line_start=part['line_start'],line_end=part['line_end']),work))
                assert any(block['role'] == 'triple_main' and block['region_kind'] == 'loop' for block in blocks)
                assert stage['actual_arithmetic_region_count'] == len(regions)
                paths = stage['remainder_paths']
                assert paths and {path['remainder_columns'] for path in paths} == {0,1,2}
                path_ids = [path['path_id'] for path in paths]
                assert all(isinstance(x,str) and x for x in path_ids) and len(set(path_ids)) == len(path_ids)
                lookup = {block['block_id']:block for block in blocks}
                used = set()
                for path in paths:
                    assert type(path['remainder_columns']) is int
                    assert path['path_condition'] and path['execution_order_review']
                    assert isinstance(path['sequence'],list)
                    work = 0
                    for step in path['sequence']:
                        block = lookup[step['block_id']]
                        repeat = step['executions']
                        assert block['role'] == 'u1_remainder' and type(repeat) is int and 1 <= repeat <= 2
                        assert block['region_kind'] == 'loop' or repeat == 1
                        work += repeat * block['kernel_columns_per_iteration']
                        used.add(block['block_id'])
                    assert work == path['remainder_columns']
                assert used == {block['block_id'] for block in blocks if block['role'] == 'u1_remainder'}
            else:
                regions = [(stage,1)]
            for region, work in regions:
                a, z = region['line_start'], region['line_end']
                assert type(a) is int and type(z) is int
                assert helper['line_start'] <= a <= z < helper['line_end']
                assert all(z < x or a > y for x, y in ranges)
                ranges.append((a,z))
                assert region['kernel_columns_per_iteration'] == work
                assert region['source_mapping'] and region['spill_notes']
                assert all(type(region[key]) is int and region[key] >= 0 for key in ('vector_spill_loads','vector_spill_stores'))
                if stage['stage'] != 'shared':
                    counts = region['derived_counts']
                    assert counts['fmul'] > 0 and counts['fadd'] > 0
                    assert region['derived_counts_per_kernel_column'] == {key:value/work for key,value in counts.items()}
        assert helper['actual_arithmetic_region_count'] == assembly['arithmetic_region_counts'][helper['symbol']] == len(ranges)
    parent_codegen = assembly['parent_codegen_comparison']
    assert parent_codegen['candidate'] == SOURCE_VERSION and str(parent_codegen['job_id']) == '1582860'
    assert parent_codegen['source_sha256'] == SOURCE_SHA['C55-r1']
    assert parent_codegen['assembly_sha256'] == e.digest(ROOT / '.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac/raw/conv2d-sve.s')
    assert parent_codegen['shared_work_and_schedule_review'] and parent_codegen['stack_and_spill_review']
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
    assert prepared['source_parent'] == SOURCE_VERSION and prepared['column_fence_contract'] == FENCE_CONTRACT
    assert prepared['expected_checks'] == expected_checks and prepared['total_cases_planned'] == 44328
    assert prepared['runner_cases_planned'] == 0 and prepared['expected_semantic_stage_count'] == 13
    assert prepared['expected_stages'] == job['expected_stages'] == stages
    assert prepared['assembly_review_schema'] == 'ae-shared3-fence-paths-v1'
    assert prepared['shared_kernel_columns_per_iteration'] == 3
    assert prepared['shared_remainder_source_columns_per_iteration'] == prepared['other_stage_kernel_columns_per_iteration'] == 1
    assert prepared['shared_remainder_max_columns'] == 2
    assert prepared['expected_rowseven_entries'] == dict(dispatch_per_configuration=1236, direct_per_configuration=1080)
    assert prepared['full_matrix_counts'] == dict(core=3888,narrow=144,small=720,larger=32,quad_boundary=960)
    assert prepared['dispatch_matrix_counts'] == dict(core=972,quad_boundary=240)
    assert prepared['quad_boundary'] == dict(widths_in_lanes=['3L-1','3L','3L+1','6L-1','6L','6L+1'],
        kernel_heights=[7,8],kernel_widths=[4,5,6,7,8],output_heights=[7,8,14,28],
        full_allocations=4,dispatch_pad=1,dispatch_leading=0)
    assert set(manifest) == set(hashes)
    assert all(manifest[key]['sha256'] == hashes[key] and manifest[key]['bytes'] > 0 for key in hashes)
    assert e.digest(frozen / 'raw/conv2d-sve.assembly.txt') == assembly['assembly_sha256']
    return diag, str(frozen.relative_to(ROOT))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before AF writes or SSH'
    path = ROOT / '.runs/conv/sep13af-campaign.json'
    assert not path.exists(), 'AF already reserved; reconcile original job and never resubmit'
    for name in CONTROLS + REFERENCES:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    decisions = old_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == old_records['C26-r33']['source_hashes'] == e.get_record('conv','C26-row4loads')['source_hashes']
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
            assert rec.get('source_parent', rec.get('parent')) == SOURCE_PARENTS[name] and rec.get('reference_only',False) is False
        source = e.source_files(run / 'source')
        assert source == rec['source_hashes'] and set(source) == set(current)
        assert all(source[key] == current[key] for key in ('README.md','bench_conv.c','run.sh'))
        diag, frozen_paths[name] = diagnostic_gate(name, source)
        sources[name], jobs[name] = source, diag['job_id']
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep13af-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Known AE/AD/AC/AB/AA/Y/X/T or explicit P/AF work active/unknown; no AF reservation or submission'
    plan = dict(round='sep13af', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], source_parent_reference='C55-r1',
        suites_per_member=3, expected_benchmark_cases=48, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep13af',
        record_reference=previous['record_reference'], best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions=DIAGNOSTIC_SOURCE_VERSIONS,
        diagnostic_expected_checks=DIAGNOSTIC_EXPECTED_CHECKS, prior_job='1582956',
        prior_campaign='.runs/conv/sep13ad-campaign.json', prior_decisions=decisions,
        auxiliary_comparisons={'C56-row7shared3fence':'C55-r1'}, confirmation_only=False,
        failed_confirmation_retry_allowed=False,
        selection_rule='Use only all48 AF samples. C56 must independently pass both unchanged same-job C6 controls: total median gain strictly exceeds max(1%, all compared case spreads), and no individual case regresses over1%. Keep every slow sample. Initial qualification is only a flag for root review.',
        attribution_rule='C56 versus same-source C55-r1 is a separate whole-implementation background comparison and never replaces either C6 gate. C55-r1 is reference-only, promotion_allowed=false, qualified_for_confirmation=false. Original C55 AD initial qualification and Y/S confirmations remain false; no confirmation retry.',
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
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 AF-round matched control'))
        e.new(argparse.Namespace(problem='conv',version='C55-r1',parent=SOURCE_VERSION,
            strategy='Same-source C55 parent reference for C56; promotion forbidden, AD initial false preserved, no confirmation retry'))
        for name in ORDER:
            meta_path = ROOT/'.runs/conv'/name/'experiment.json'
            # Freeze the exact creation metadata before its first association update.
            # Existing C56 author snapshots stay byte-identical; never refresh source hashes.
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
                if name in REFERENCES:
                    meta.update(prior_initial_version=SOURCE_VERSION,prior_initial_qualified_for_confirmation=False,
                                prior_initial_job='1582956')
            assert meta['source_hashes'] == e.read_json(creation_path)['source_hashes']
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv',version=name,
                note='AF fixed four-member order, three independent original official suites each, total48 cases. C56 requires its own actual frozen AE44328. C55-r1 copies original C55 with AC44328 as parent reference-only; AD C55false/Yfalse/Sfalse preserved, not a confirmation repeat. Both C6 controls unchanged. No local operator execution.'))
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
