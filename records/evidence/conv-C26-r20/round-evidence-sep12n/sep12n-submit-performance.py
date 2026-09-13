"""Prepared N eight-member comparison; explicit root --go only.

No campaign, control, reference source or job is created during preparation or
import. C40-r3 is reference-only; G false / J true / K false remain untouched.
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

ORDER = ['C26-r20', 'C45-row4dup4', 'C49-row4dup4fence', 'C46-row5x5asmfix',
         'C40-r3', 'C47-row6x4u1', 'C48-row8x2u1', 'C26-r21']
CANDIDATES = ['C45-row4dup4', 'C49-row4dup4fence', 'C46-row5x5asmfix',
              'C47-row6x4u1', 'C48-row8x2u1']
REFERENCES = ['C40-r3']
CONTROLS = ['C26-r20', 'C26-r21']
SOURCE_VERSION = 'C40-row6x3u1'
SOURCE_PARENTS = {'C45-row4dup4': 'C26-row4loads', 'C49-row4dup4fence': 'C45-row4dup4',
    'C46-row5x5asmfix': 'C42-row5x5asm', 'C47-row6x4u1': SOURCE_VERSION,
    'C48-row8x2u1': SOURCE_VERSION, 'C40-r3': SOURCE_VERSION}
# round/full/dispatch/direct/total/rows/vectors/stages/dispatch entries/direct entries
DIAGNOSTICS = {
    'C45-row4dup4': ('sep12i', 20164, 96, 0, 121560, 4, 4, 7, None, None),
    'C49-row4dup4fence': ('sep12o', 20164, 96, 0, 121560, 4, 4, 7, None, None),
    'C46-row5x5asmfix': ('sep12i', 3776, 504, 288, 27408, 5, 5, 9, 528, 720),
    'C47-row6x4u1': ('sep12l', 3560, 432, 360, 26112, 6, 4, 11, 432, 900),
    'C48-row8x2u1': ('sep12m', 5360, 1080, 504, 41664, 8, 2, 15, 792, 1260),
    'C40-r3': ('sep12g', 3560, 432, 360, 26112, 6, 3, 11, 432, 900),
}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
                 numa_distribution='pack', walltime_seconds=1800)
ENVIRONMENT = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
                   OMP_PLACES='cores', CPU_TARGET='generic')
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}
H_ORDER = ['C26-r14', 'C44-copyinput', 'C43-padinput', 'C26-r15']


def old_c40_decisions():
    g = e.get_record('conv', SOURCE_VERSION)
    j = e.get_record('conv', 'C40-r1')
    k = e.get_record('conv', 'C40-r2')
    assert g['qualified_for_confirmation'] is False
    assert g['comparison']['eligible'] is False and g['opening_control_comparison']['eligible'] is False
    assert j['qualified_for_confirmation'] is True
    assert k['confirmation_passed'] is False
    assert e.read_json(ROOT / '.runs/conv/sep12k-campaign.json')['confirmation_passed'] is False
    assert g['source_hashes'] == j['source_hashes'] == k['source_hashes']
    return dict(G_qualified=False, J_qualified=True, K_confirmation_passed=False,
                original_versions=[SOURCE_VERSION, 'C40-r1', 'C40-r2'])


def verify_settings(settings):
    assert settings['bench_repeats'] == 3
    assert all(settings['environment'][key] == value for key, value in ENVIRONMENT.items())
    assert all(settings['scheduler_resources'][key] == value for key, value in RESOURCES.items())


def previous_gate():
    plan = e.read_json(ROOT / '.runs/conv/sep12h-campaign.json')
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1579748'
    assert plan['measurement_order'] == H_ORDER and plan['candidate_versions'] == ['C43-padinput']
    assert plan['reference_only_versions'] == ['C44-copyinput']
    assert len(plan['results']) == 4 and [x['version'] for x in plan['results']] == H_ORDER
    records = {name: e.get_record('conv', name) for name in H_ORDER}
    base = records['C26-r15']
    verify_settings(plan['settings'])
    for index, name in enumerate(H_ORDER):
        rec = records[name]
        assert rec['status'] == 'passed' and rec.get('verified') is True
        assert rec['job_id'] == '1579748' and rec['repeats'] == plan['suites_per_member'] == 3
        assert rec['settings'] == base['settings'] == plan['settings']
        assert rec['environment'] == base['environment'] == plan['record_environment']
        assert rec['reference'] == base['reference'] == plan['record_reference']
        assert rec['machine'] == base['machine'] and all(rec['checks'].values())
        assert rec['machine']['compiler_banners'] == ['gcc (GCC) 10.3.1']
        assert len(rec['cases']) == 4 and all(len(x['times_ms']) == 3 for x in rec['cases'])
        run = ROOT / '.runs/conv' / name
        manifest = e.read_json(run / 'cluster.json')
        assert manifest['job_id'] == '1579748' and manifest['group'] == plan['performance_group']
        assert manifest['group_index'] == index and manifest['measurement_order'] == H_ORDER
        assert manifest['settings'] == plan['settings']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1579748' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert rec['source_hashes'] == manifest['source_hashes'] == e.source_files(run / 'source')
        assert plan['results'][index]['total_median_ms'] == rec['total_median_ms']
        assert plan['results'][index]['qualified_for_confirmation'] is False
        assert rec['qualified_for_confirmation'] is False
    assert records['C43-padinput']['padding_contribution_supported_in_initial_group'] is False
    assert records['C26-r14']['source_hashes'] == base['source_hashes']
    return plan, records


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
    identities = {'1579748': ['H performance'], '1579660': ['J performance'], '1579677': ['K confirmation']}
    unresolved, ignored = [], []
    paths = []
    for round_name, names in {'sep12h': ['C43-padinput', 'C44-copyinput'],
        'sep12i': ['C45-row4dup4', 'C46-row5x5asmfix'], 'sep12l': ['C47-row6x4u1'],
        'sep12m': ['C48-row8x2u1'], 'sep12o': ['C49-row4dup4fence']}.items():
        paths += [ROOT / '.runs/conv' / (round_name + '-checks') / name / 'job.json' for name in names]
    paths += [ROOT / '.runs/conv' / name / 'cluster.json'
              for name in dict.fromkeys(ORDER + H_ORDER + ['C26-r18', 'C40-r2', 'C26-r19', 'C40-package'])]
    for path in paths:
        if not path.exists():
            continue
        row = e.read_json(path)
        job = str(row.get('job_id') or '')
        origin = str(path.relative_to(ROOT))
        if not job.isdigit():
            unresolved.append(dict(path=origin, reason='Existing reservation has no reconciled job ID'))
        else:
            identities.setdefault(job, []).append(origin)
    known = {'sep12h': '1579748', 'sep12j': '1579660', 'sep12k': '1579677'}
    for rnd in ('sep12h', 'sep12i', 'sep12j', 'sep12k', 'sep12l', 'sep12m', 'sep12o', 'sep12n'):
        path = ROOT / '.runs/conv' / (rnd + '-campaign.json')
        if not path.exists():
            continue
        row = e.read_json(path)
        job = str(row.get('performance_job') or '')
        origin = str(path.relative_to(ROOT))
        if not job.isdigit():
            if (rnd not in known and rnd != 'sep12n' and row.get('status') in ('prepared', 'planned')
                    and row.get('submitted') is False and row.get('submit_attempted') is False):
                ignored.append(origin)
            else:
                unresolved.append(dict(path=origin, reason='Unreconciled campaign reservation'))
        else:
            if rnd in known and job != known[rnd]:
                unresolved.append(dict(path=origin, reason='Known H/J/K identity changed'))
            identities.setdefault(job, []).append(origin)
    evidence = [query_job(cfg, job, origins) for job, origins in identities.items()]
    clear = not unresolved and all(x['query_exit'] == 0 and x['scheduler'] is not None
        and str(x['scheduler'].get('jobId')) == x['job_id'] and x['scheduler'].get('status') in TERMINAL
        and type(x['scheduler'].get('jobExitCode')) is int and type(x['scheduler'].get('systemExitCode')) is int
        for x in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), clear=clear, jobs=evidence,
                unresolved_submissions=unresolved, ignored_unsubmitted_prepared_campaigns=ignored)


def diagnostic_gate(name, source):
    rnd, full, dispatch, direct, total, rows, vectors, stages, entries, direct_entries = DIAGNOSTICS[name]
    source_version = SOURCE_VERSION if name == 'C40-r3' else name
    frozen = ROOT / '.runs/conv' / source_version / ('sve-correctness-' + rnd)
    diag = e.read_json(frozen / 'validation.json')
    assert diag['candidate'] == source_version and diag['status'] == 'passed' and diag['complete'] is True
    assert diag['exit_code'] == 0 and diag['compiler_version'] == '10.3.1'
    assert (diag['total_cases'], diag['full_cases'], diag['dispatch_cases'], diag['direct_cases']) == (total, 6*full, 6*dispatch, 6*direct)
    assert diag.get('runner_cases', 0) == 0
    scheduler = diag['scheduler']
    assert str(scheduler['jobId']) == str(diag['job_id']) and str(diag['job_id']).isdigit()
    assert scheduler.get('status') == 'SUCCEEDED' and scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
    job = e.read_json(frozen / 'job.json')
    assert job['scheduler_status'] == scheduler and job['version'] == source_version
    assert len(diag['allocation']['cpus']) == len(set(diag['allocation']['cpus'])) == 38
    assert diag['allocation']['numa_node']
    if name != 'C40-r3':
        assert job['source_hashes'] == diag['source_hashes'] and job['resources'] == RESOURCES
    assert str(job['job_id']) == str(diag['job_id'])
    assert c.parse_scheduler_status((frozen / 'scheduler.log').read_text(), str(diag['job_id'])) == scheduler
    assert (frozen / 'raw/exit-code.txt').read_text().strip() == '0'
    assert diag['source_hashes_verified'] is True and diag['source_manifest_remote_matches'] is True
    assert diag['source_hashes']['conv2d.c'] == source['conv2d.c'] == e.digest(frozen / 'raw/conv2d.c')
    if name != 'C40-r3':
        expected_stages = ['allocation','compiler','manifest','build-guard']
        expected_stages += [f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
        expected_stages += ['build-dispatch']
        expected_stages += [f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
        expected_stages += ['build-assembly','complete']
        assert diag['stage_exits'] == [dict(stage=s, exit_code=0) for s in expected_stages]
        assert (frozen / 'raw/stage-exits.txt').read_text().splitlines() == ['STAGE='+s+' EXIT=0' for s in expected_stages]
        assert diag['expected_checks'] == dict(full_per_configuration=full, dispatch_per_configuration=dispatch,
            direct_per_configuration=direct, configurations=6, total=total)
    else:
        assert str(diag['job_id']) == '1579597', 'C40 reference reuses only the same original frozen source'
    # Historical G stores argv directly; later frozen rounds store commands plus trace locations.
    common = ['gcc','-O3','-std=c11','-D_DEFAULT_SOURCE','-Wall','-Wextra',
              '-fno-fast-math','-ffp-contract=off','-mcpu=generic','-fopenmp',f'-DEXPECTED_ACC={vectors}']
    if name in ('C45-row4dup4','C49-row4dup4fence'):
        common += ['-DCHECK_ROWTRIPLE=1','-DCHECK_ROWQUAD=1']
    expected_argv = [common+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],
        common+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],
        common+['-S','conv2d.c','-o','conv2d-sve.s']]
    actual_argv = diag['build_commands'] if name == 'C40-r3' else diag['build_commands']['commands']
    assert actual_argv == expected_argv
    configs = diag['configurations']
    assert len(configs) == 6 and {(x['sve_bytes'], x['threads']) for x in configs} == {(v,t) for v in (16,32,64) for t in (1,4)}
    for item in configs:
        assert item['passed'] is True and item['lanes'] == item['sve_bytes']//4
        assert item['block_outputs_per_row'] == vectors*item['lanes']
        assert (item['full_cases'], item['dispatch_cases'], item['direct_cases']) == (full, dispatch, direct)
        required = ('rowpair','rowtriple','rowquad') if direct == 0 else ('prefix','tail','rowpair','rowtriple','rowquad')
        assert all(item['helper_entries'][key] > 0 for key in required)
        if entries is not None:
            assert item['dispatch_entries'] == entries and item['direct_entries'] == direct_entries
            assert item['dispatch_worker_mask'] == item['direct_worker_mask'] == (1 << item['threads'])-1
    assembly = diag['assembly']
    assert assembly['review_complete'] is True and assembly['production_uninstrumented'] is True
    assert assembly['whole_helper_stack_reviewed'] is True and assembly['transitions_reviewed'] is True
    assert assembly['stage_count'] == stages and assembly['fma_count'] == assembly['whole_source_fma_count'] == 0
    if name != 'C40-r3':
        assert assembly['candidate'] == source_version and str(assembly['job_id']) == str(diag['job_id'])
        assert assembly['source_sha256'] == source['conv2d.c']
        assert assembly['assembly_sha256'] == e.digest(frozen/'raw/conv2d-sve.s')
        assert assembly['all_stages_and_transitions_reviewed'] is True and assembly['dispatch_reviewed'] is True
        assert assembly['abi_saves_distinguished'] is True and assembly['dispatch_functions']
        assert assembly['helpers'] and all(len(h['stages']) == stages for h in assembly['helpers'])
    if name == 'C45-row4dup4':
        cmp = assembly['codegen_comparison']
        assert cmp['review_complete'] is True and cmp['distinct_from_prior_machine_arrangements'] is True
        assert set(cmp['prior_versions']) == {'C29-row4lane4','C32-row4lane4staged'}
    elif name == 'C46-row5x5asmfix':
        proof = assembly['explicit_asm_review']
        assert all(proof[key] is True for key in ('compiler_accepted','concrete_operands_reviewed',
            'scratch_disjoint_from_inputs_and_accumulators','accumulator_order_reviewed'))
        assert [b['input_vector'] for b in proof['blocks']] == list(range(5))
        for block in proof['blocks']:
            assert len(block['accumulator_registers']) == len(set(block['accumulator_registers'])) == 5
            assert len(block['coefficient_registers']) == 5
            live = set(block['live_accumulator_registers'])
            inputs = set(block['coefficient_registers']) | {block['input_register']}
            assert len(live) == 25 and not live.intersection(inputs)
            assert set(block['accumulator_registers']).issubset(live)
            assert block['scratch_register'] not in live | inputs
            assert block['line_start'] > 0 and block['line_end'] >= block['line_start']
            assert block['source_asm_line'] > 0 and block['liveness_and_spill_notes']
    elif name in ('C47-row6x4u1','C48-row8x2u1'):
        assert assembly['shape'] == dict(rows_per_group=rows, vectors_per_row=vectors, accumulators=rows*vectors)
    elif name == 'C49-row4dup4fence':
        # Mathematical PASS alone can be true with identical machine scheduling.
        # O preserves that truthful result; the fixed N plan must stop, not drop C49.
        cmp = assembly['codegen_comparison']
        assert diag['performance_codegen_eligible'] is True, 'C49 has no distinct actual codegen; stop N for root review'
        assert assembly['performance_codegen_eligible'] is True
        assert cmp['review_complete'] is True and cmp['distinct_from_prior_machine_arrangements'] is True
        assert cmp['prior_versions'] == ['C45-row4dup4']
        assert diag['automatic_performance_submission'] is False and diag['performance_measured'] is False
        assert diag['performance_requires_root_review'] is True and diag['kh5_dynamic_coverage'] is False
        assert all(cmp[k] for k in ('normalization','notes','spill_and_schedule_difference_notes'))
        prior_dir = ROOT/'.runs/conv/C45-row4dup4/sve-correctness-sep12i'
        prior = e.read_json(prior_dir/'validation.json')
        assert prior['candidate'] == 'C45-row4dup4' and prior['job_id'] == '1579762'
        assert prior['status'] == 'passed' and prior['complete'] is True and prior['source_hashes_verified'] is True
        prior_asm = prior['assembly']
        identity = {k:prior_asm[k] for k in ('candidate','job_id','source_sha256','assembly_sha256')}
        assert cmp['prior_identity'] == identity
        assert identity['source_sha256'] == prior['source_hashes']['conv2d.c']
        assert identity['assembly_sha256'] == e.digest(prior_dir/'raw/conv2d-sve.s')
        prior_shared = [dict(symbol=h['symbol'],line_start=s['line_start'],line_end=s['line_end'],
            kernel_columns_per_iteration=s['kernel_columns_per_iteration'],counts=s['derived_counts'],
            vector_spill_loads=s['vector_spill_loads'],vector_spill_stores=s['vector_spill_stores'])
            for h in prior_asm['helpers'] for s in h['stages'] if s['stage']=='shared']
        assert cmp['prior_shared'] == prior_shared and len(prior_shared) == 1
        assert prior_shared[0]['kernel_columns_per_iteration'] == 4
        assert prior_shared[0]['counts']['instructions'] == 185
        assert prior_shared[0]['vector_spill_loads'] == prior_shared[0]['vector_spill_stores'] == 6
        fence = assembly['fence_review']
        assert all(fence[k] is True for k in ('review_complete','compiler_accepted','source_contract_reviewed',
            'empty_templates_emit_no_instruction','does_not_claim_hardware_fence'))
        assert fence['source_fence_count'] == 3
        raw_source = (frozen/'raw/conv2d.c').read_text()
        sites = list(re.finditer(r'__asm__\s+__volatile__\s*\(\s*""',raw_source))
        assert len(sites) == 3
        observations = fence['observations']
        assert len(observations) == 3 and [o['after_kernel_lane'] for o in observations] == [0,1,2]
        shared = [s for h in assembly['helpers'] for s in h['stages'] if s['stage']=='shared']
        assert shared and all(s['kernel_columns_per_iteration'] == 4 for s in shared)
        for h in assembly['helpers']:
            assert [(s['loop'],s['kernel_columns_per_iteration']) for s in h['shared_remainders']] == [('remainder2',2),('remainder1',1)]
        for site, observation in zip(sites,observations):
            assert observation['source_asm_line'] == raw_source[:site.start()].count('\n')+1
            assert observation['mapping_status'] in ('reconstructed','not_separately_identifiable')
            assert observation['instruction_address_claimed'] is False
            assert all(observation[k] for k in ('packed_value_notes','accumulator_readiness_notes',
                'scheduling_notes','register_and_spill_notes'))
            assert observation['evidence_ranges']
            for span in observation['evidence_ranges']:
                assert type(span['line_start']) is int and type(span['line_end']) is int
                assert any(s['line_start'] <= span['line_start'] <= span['line_end'] <= s['line_end'] for s in shared)
    return diag, str(frozen.relative_to(ROOT))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before any N writes or SSH'
    path = ROOT / '.runs/conv/sep12n-campaign.json'
    assert not path.exists(), 'N already reserved; reconcile saved group and never resubmit'
    for name in CONTROLS + REFERENCES:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    old_decisions = old_c40_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == e.get_record('conv','C26-row4loads')['source_hashes'] == old_records['C26-r15']['source_hashes']
    settings = old_records['C26-r15']['settings']
    verify_settings(settings)
    cfg = c.load_config(ROOT / 'config/conv-sep12.local.json')
    assert c.effective_settings(cfg, {'settings':settings}) == settings
    sources, jobs, frozen_paths = {}, {}, {}
    for name in CANDIDATES + REFERENCES:
        origin = SOURCE_VERSION if name in REFERENCES else name
        run = ROOT / '.runs/conv' / origin
        record = e.get_record('conv', origin)
        if name in CANDIDATES:
            assert not (run / 'cluster.json').exists(), name
            assert record['status'] == 'prepared' and record['verified'] is False
            assert record['source_parent'] == SOURCE_PARENTS[name] and record.get('reference_only',False) is False
        source = e.source_files(run / 'source')
        assert source == record['source_hashes'] and set(source) == set(current)
        assert all(source[f] == current[f] for f in ('README.md','bench_conv.c','run.sh'))
        diag, frozen_paths[name] = diagnostic_gate(name, source)
        sources[name], jobs[name] = source, diag['job_id']
    gate = serial_gate(cfg)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    e.write_json(ROOT / '.runs/conv' / ('sep12n-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Current CONV work active/unknown; no N reservation or submission allowed'
    plan = dict(round='sep12n', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], rowsix_reference='C40-r3',
        suites_per_member=3, expected_benchmark_cases=96, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep12n',
        record_reference=previous['record_reference'], best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions={n:SOURCE_VERSION if n in REFERENCES else n for n in sources},
        diagnostic_expected_checks={n:DIAGNOSTICS[n][4] for n in sources}, prior_job='1579748',
        prior_campaign='.runs/conv/sep12h-campaign.json', prior_c40_decisions=old_decisions,
        auxiliary_comparisons={'C47-row6x4u1':'C40-r3','C48-row8x2u1':'C40-r3','C49-row4dup4fence':'C45-row4dup4'},
        selection_rule='Each of five candidates must qualify versus both unchanged same-job C6 controls: gain in sum of case medians exceeds max(1%, compared per-case spreads), no case regression over1%. Every slow sample retained. Initial qualifiers require root independent confirmation and exact original ZIP verification; no automatic promotion.',
        attribution_rule='C47/C48 versus C40-r3 and C49 versus C45 are separate whole-implementation/compiler-scheduling comparisons. They do not replace C6 usefulness and cannot isolate spill cost. C40-r3 is reference-only, promotion_allowed=false; G false/J true/K false remain unchanged and no C40 confirmation is attempted.',
        local_compilation_or_tests_run=False, official_score=None, submitted=False, submit_attempted=False)
    with e.locked():
        assert not path.exists()
        assert e.source_files(ROOT/'conv') == current and e.read_json(ROOT/'outputs/conv-best.json')['label'] == 'C6'
        latest, latest_records = previous_gate()
        assert latest == previous and latest_records == old_records and old_c40_decisions() == old_decisions
        for name in CONTROLS + REFERENCES:
            assert not (ROOT/'.runs/conv'/name).exists() and not e.record_path('conv',name).exists(), name
        for name, source in sources.items():
            origin = SOURCE_VERSION if name in REFERENCES else name
            assert e.source_files(ROOT/'.runs/conv'/origin/'source') == source
            if name in CANDIDATES:
                assert not (ROOT/'.runs/conv'/name/'cluster.json').exists()
        e.write_json(path, plan)
        for name in CONTROLS:
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 N-round matched control'))
        e.new(argparse.Namespace(problem='conv',version='C40-r3',parent=SOURCE_VERSION,
            strategy='Same-source C40 reference-only context for C47/C48; promotion forbidden, not a confirmation repeat'))
        for name in ORDER:
            meta_path = ROOT/'.runs/conv'/name/'experiment.json'
            meta = e.read_json(meta_path)
            meta['settings'] = settings
            assert e.source_files(meta_path.parent/'source') == (current if name in CONTROLS else sources[name])
            if name not in CONTROLS:
                meta.update(parent=CONTROLS[1],comparison_baseline=CONTROLS[1],source_parent=SOURCE_PARENTS[name],
                    reference_only=name in REFERENCES,promotion_allowed=name in CANDIDATES,
                    diagnostic_source_version=plan['diagnostic_source_versions'][name],
                    diagnostic_evidence_directory=frozen_paths[name],diagnostic_job_id=jobs[name],
                    diagnostic_source_sha256=sources[name]['conv2d.c'],reused_identical_source_diagnostic=name in REFERENCES)
            e.write_json(meta_path, meta)
            e.checkpoint(argparse.Namespace(problem='conv',version=name,
                note='N fixed eight-member order, three independent original official suites each, total96 cases. Five candidates passed independent diagnostics; C40-r3 is same-source reference-only and cannot promote. Both C6 controls unchanged; all prior samples and decisions preserved. No local operator execution.'))
        plan.update(status='prepared', submit_attempted=True)
        e.write_json(path, plan)
    cluster_group.submit_group(cfg, [ROOT/'.runs/conv'/name for name in ORDER])
    manifests = [c.read_json(ROOT/'.runs/conv'/name/'cluster.json') for name in ORDER]
    job, group = manifests[0]['job_id'], manifests[0]['group']
    assert str(job).isdigit() and all(x['job_id']==job and x['group']==group for x in manifests)
    plan.update(status='performance_running',performance_job=job,performance_group=group,submitted=True)
    with e.locked():
        e.write_json(path, plan)


if __name__ == '__main__':
    main()
