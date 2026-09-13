"""Prepared R four-member comparison; explicit root --go only.

No campaign, control, reference source or job is created during preparation or
import. C40-r4 is reference-only; G false / J true / K false remain untouched.
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

ORDER = ['C26-r22', 'C51-row7x3u1', 'C40-r4', 'C26-r23']
CANDIDATES = ['C51-row7x3u1']
REFERENCES = ['C40-r4']
CONTROLS = ['C26-r22', 'C26-r23']
SOURCE_VERSION = 'C40-row6x3u1'
SOURCE_PARENTS = {'C51-row7x3u1': SOURCE_VERSION, 'C40-r4': SOURCE_VERSION}
# Actual Q package contract; author-suggested matrices are not acceptance counts.
# round/full/dispatch/direct/total/rows/vectors/stages/dispatch entries/direct entries
DIAGNOSTICS = {
    'C51-row7x3u1': ('sep13q', 4784, 972, 432, 37128, 7, 3, 13, 756, 1080),
    'C40-r4': ('sep12g', 3560, 432, 360, 26112, 6, 3, 11, 432, 900),
}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
                 numa_distribution='pack', walltime_seconds=1800)
ENVIRONMENT = dict(OMP_NUM_THREADS='38', OMP_DYNAMIC='FALSE', OMP_PROC_BIND='close',
                   OMP_PLACES='cores', CPU_TARGET='generic')
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}
N_ORDER = ['C26-r20', 'C45-row4dup4', 'C49-row4dup4fence', 'C46-row5x5asmfix',
           'C40-r3', 'C47-row6x4u1', 'C48-row8x2u1', 'C26-r21']


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
    nr = e.get_record('conv', 'C40-r3')
    np = e.read_json(ROOT / '.runs/conv/sep12n-campaign.json')
    assert nr['job_id'] == np['performance_job'] == '1581459'
    assert nr['reference_only'] is True and nr['promotion_allowed'] is False
    assert nr['qualified_for_confirmation'] is False
    assert nr['source_hashes'] == g['source_hashes']
    assert np['status'] == 'performance_complete' and np['prior_c40_decisions_unchanged'] is True
    assert np['reference_only_versions'] == ['C40-r3']
    assert 'C40-r3' not in np['confirmation_pending']
    return dict(G_qualified=False, J_qualified=True, K_confirmation_passed=False,
                N_reference_only=True, N_promotion_allowed=False, N_qualified=False,
                N_reference_job='1581459',
                original_versions=[SOURCE_VERSION, 'C40-r1', 'C40-r2', 'C40-r3'])


def verify_settings(settings):
    assert settings['bench_repeats'] == 3
    assert all(settings['environment'][key] == value for key, value in ENVIRONMENT.items())
    assert all(settings['scheduler_resources'][key] == value for key, value in RESOURCES.items())


def previous_gate():
    plan = e.read_json(ROOT / '.runs/conv/sep12n-campaign.json')
    assert plan['status'] == 'performance_complete' and plan['performance_job'] == '1581459'
    assert plan['measurement_order'] == N_ORDER and plan['reference_only_versions'] == ['C40-r3']
    assert plan['candidate_versions'] == ['C45-row4dup4', 'C49-row4dup4fence',
        'C46-row5x5asmfix', 'C47-row6x4u1', 'C48-row8x2u1']
    assert plan['confirmation_pending'] == [] and len(plan['results']) == 8
    assert [x['version'] for x in plan['results']] == N_ORDER
    records = {name: e.get_record('conv', name) for name in N_ORDER}
    baseline = records['C26-r21']
    verify_settings(plan['settings'])
    for index, name in enumerate(N_ORDER):
        rec = records[name]
        assert rec['status'] == 'passed' and rec.get('verified') is True
        assert rec['job_id'] == '1581459' and rec['repeats'] == plan['suites_per_member'] == 3
        assert rec['settings'] == baseline['settings'] == plan['settings']
        assert rec['environment'] == baseline['environment'] == plan['record_environment']
        assert rec['reference'] == baseline['reference'] == plan['record_reference']
        assert rec['machine'] == baseline['machine'] and all(rec['checks'].values())
        assert rec['machine']['compiler_banners'] == ['gcc (GCC) 10.3.1']
        assert len(rec['cases']) == 4 and all(len(x['times_ms']) == 3 for x in rec['cases'])
        run = ROOT / '.runs/conv' / name
        manifest = e.read_json(run / 'cluster.json')
        assert manifest['job_id'] == '1581459' and manifest['group'] == plan['performance_group']
        assert manifest['group_index'] == index and manifest['measurement_order'] == N_ORDER
        assert manifest['settings'] == plan['settings']
        status = manifest.get('scheduler_status') or {}
        assert str(status.get('jobId')) == '1581459' and status.get('status') == 'SUCCEEDED'
        assert status.get('jobExitCode') == status.get('systemExitCode') == 0
        assert (run / 'exit-code.txt').read_text().strip() == '0'
        assert rec['source_hashes'] == manifest['source_hashes'] == e.source_files(run / 'source')
        assert plan['results'][index]['total_median_ms'] == rec['total_median_ms']
        assert plan['results'][index]['qualified_for_confirmation'] is False
        assert rec['qualified_for_confirmation'] is False
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases']) == 96
    assert records['C26-r20']['source_hashes'] == baseline['source_hashes']
    old_c40_decisions()
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
    identities = {'1579748': ['H performance'], '1579660': ['J performance'],
                  '1579677': ['K confirmation'], '1581459': ['N performance']}
    unresolved, ignored = [], []
    paths = []
    diagnostic_rounds = {'sep12h': ['C43-padinput', 'C44-copyinput'],
        'sep12i': ['C45-row4dup4', 'C46-row5x5asmfix'], 'sep12l': ['C47-row6x4u1'],
        'sep12m': ['C48-row8x2u1'], 'sep12o': ['C49-row4dup4fence'],
        'sep13p': ['C50-row4dupfencenomem'], 'sep13q': ['C51-row7x3u1']}
    for rnd, names in diagnostic_rounds.items():
        paths += [ROOT / '.runs/conv' / (rnd + '-checks') / name / 'job.json' for name in names]
    paths += [ROOT / '.runs/conv/C51-row7x3u1/sve-correctness-sep13q/job.json',
              ROOT / '.runs/conv/C40-row6x3u1/sve-correctness-sep12g/job.json']
    prior_members = N_ORDER + ['C26-r14', 'C44-copyinput', 'C43-padinput', 'C26-r15',
                              'C26-r18', 'C40-r2', 'C26-r19', 'C40-package']
    paths += [ROOT / '.runs/conv' / name / 'cluster.json'
              for name in dict.fromkeys(ORDER + prior_members)]
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
    known = {'sep12h': '1579748', 'sep12j': '1579660',
             'sep12k': '1579677', 'sep12n': '1581459'}
    for rnd in ('sep12h', 'sep12i', 'sep12j', 'sep12k', 'sep12l', 'sep12m',
                'sep12o', 'sep12n', 'sep13p', 'sep13q', 'sep13r'):
        path = ROOT / '.runs/conv' / (rnd + '-campaign.json')
        if not path.exists():
            continue
        row = e.read_json(path)
        job = str(row.get('performance_job') or '')
        origin = str(path.relative_to(ROOT))
        if not job.isdigit():
            if (rnd not in known and rnd != 'sep13r' and row.get('status') in ('prepared', 'planned')
                    and row.get('submitted') is False and row.get('submit_attempted') is False):
                ignored.append(origin)
            else:
                unresolved.append(dict(path=origin, reason='Unreconciled campaign reservation'))
        else:
            if rnd in known and job != known[rnd]:
                unresolved.append(dict(path=origin, reason='Known prior identity changed'))
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
    source_version = SOURCE_VERSION if name == 'C40-r4' else name
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
    if name != 'C40-r4':
        assert job['source_hashes'] == diag['source_hashes'] and job['resources'] == RESOURCES
    assert str(job['job_id']) == str(diag['job_id'])
    assert c.parse_scheduler_status((frozen / 'scheduler.log').read_text(), str(diag['job_id'])) == scheduler
    assert (frozen / 'raw/exit-code.txt').read_text().strip() == '0'
    assert diag['source_hashes_verified'] is True and diag['source_manifest_remote_matches'] is True
    assert diag['source_hashes']['conv2d.c'] == source['conv2d.c'] == e.digest(frozen / 'raw/conv2d.c')
    if name != 'C40-r4':
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
    expected_argv = [common+['check_conv_guard.c','conv2d.c','-o','check_conv_guard'],
        common+['-finstrument-functions','check_sve_dispatch.c','-o','check_sve_dispatch'],
        common+['-S','conv2d.c','-o','conv2d-sve.s']]
    actual_argv = diag['build_commands'] if name == 'C40-r4' else diag['build_commands']['commands']
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
    if name != 'C40-r4':
        assert assembly['candidate'] == source_version and str(assembly['job_id']) == str(diag['job_id'])
        assert assembly['source_sha256'] == source['conv2d.c']
        assert assembly['assembly_sha256'] == e.digest(frozen/'raw/conv2d-sve.s')
        assert assembly['all_stages_and_transitions_reviewed'] is True and assembly['dispatch_reviewed'] is True
        assert assembly['abi_saves_distinguished'] is True and assembly['dispatch_functions']
        assert assembly['helpers'] and all(len(h['stages']) == stages for h in assembly['helpers'])
    if name == 'C51-row7x3u1':
        assert source['conv2d.c'] == '5c8a861915d9b172f2cbf7b1b45e028e2d8afab2a44e01dd328424fc6c1012ff'
        assert assembly['shape'] == dict(rows_per_group=7, vectors_per_row=3, accumulators=21)
        assert assembly['whole_machine_code_identical_claimed'] is False
        assert diag['performance_measured'] is False and diag['automatic_performance_submission'] is False
        assert diag['performance_requires_root_review'] is True
        assert diag['executed_locally'] is False and diag['executed_remotely'] is True
        assert assembly['performance_submission_automatic'] is False
        phases = [f'input_{i}' for i in range(6)] + ['shared'] + [f'trailing_{i}' for i in range(6)]
        for helper in assembly['helpers']:
            assert helper['symbol'] == 'conv_sve_rowseven' or helper['symbol'].startswith('conv_sve_rowseven.')
            assert [s['stage'] for s in helper['stages']] == phases
            assert helper['line_start'] > 0 and helper['line_end'] >= helper['line_start']
            assert all(helper.get(k) for k in ('stack_frame_description', 'spill_notes',
                'transition_spill_review', 'tail_and_fallback_review', 'arithmetic_and_load_review'))
            for stage in helper['stages']:
                assert helper['line_start'] <= stage['line_start'] <= stage['line_end'] <= helper['line_end']
                assert stage['kernel_columns_per_iteration'] == 1
                assert stage['derived_counts']['fmul'] > 0 and stage['derived_counts']['fadd'] > 0
        frozen_meta = e.read_json(frozen / 'freeze-source.json')
        assert frozen_meta['candidate'] == name and str(frozen_meta['job_id']) == str(diag['job_id'])
        assert frozen_meta['mode'] == 'passed' and frozen_meta['assembly_available'] is True
        assert frozen_meta['original_metadata_preserved'] is True
        assert frozen_meta['original_source_and_raw_preserved'] is True
        assert frozen_meta['original_source_manifest_preserved'] is True
        assert frozen_meta['validation_rewritten'] is False and frozen_meta['operator_executed'] is False
        prepared = e.read_json(frozen / 'prepared.json')
        hashes = e.read_json(frozen / 'source-hashes.json')
        manifest = e.read_json(frozen / 'source-manifest.json')
        assert hashes == prepared['source_hashes'] == job['source_hashes'] == diag['source_hashes']
        assert set(hashes) == {'conv2d.c', 'check_conv_guard.c', 'check_sve_dispatch.c', 'remote_job.sh', 'candidate.env'}
        assert prepared['candidate'] == name and prepared['source_sha256'] == source['conv2d.c']
        assert prepared['expected_checks'] == diag['expected_checks']
        assert prepared['total_cases_planned'] == 37128 and prepared['runner_cases_planned'] == 0
        assert prepared['expected_rowseven_entries'] == dict(dispatch_per_configuration=756, direct_per_configuration=1080)
        assert set(manifest) == set(hashes)
        assert all(manifest[key]['sha256'] == hashes[key] and manifest[key]['bytes'] > 0 for key in hashes)
        assert e.digest(frozen / 'raw/conv2d-sve.assembly.txt') == assembly['assembly_sha256']
    return diag, str(frozen.relative_to(ROOT))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--go', action='store_true')
    args = parser.parse_args()
    assert args.go, 'Prepared only; root explicit GO required before any R writes or SSH'
    path = ROOT / '.runs/conv/sep13r-campaign.json'
    assert not path.exists(), 'R already reserved; reconcile saved group and never resubmit'
    for name in CONTROLS + REFERENCES:
        assert not (ROOT / '.runs/conv' / name).exists() and not e.record_path('conv', name).exists(), name
    previous, old_records = previous_gate()
    old_decisions = old_c40_decisions()
    current = e.source_files(ROOT / 'conv')
    best = e.read_json(ROOT / 'outputs/conv-best.json')
    assert best['label'] == 'C6' and best['source_hashes'] == current
    assert current == e.get_record('conv','C26-row4loads')['source_hashes'] == old_records['C26-r21']['source_hashes']
    settings = old_records['C26-r21']['settings']
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
    e.write_json(ROOT / '.runs/conv' / ('sep13r-performance-gate-'+stamp+'.json'), gate)
    assert gate['clear'], 'Current CONV work active/unknown; no R reservation or submission allowed'
    plan = dict(round='sep13r', status='preparing', measurement_order=ORDER,
        candidate_versions=CANDIDATES, reference_only_versions=REFERENCES,
        opening_control=CONTROLS[0], primary_baseline=CONTROLS[1], rowsix_reference='C40-r4',
        suites_per_member=3, expected_benchmark_cases=48, settings=settings,
        expected_compiler_banners=['gcc (GCC) 10.3.1'], record_environment='kunpeng-gcc10-generic-38-sep13r',
        record_reference=previous['record_reference'], best_label='C6', source_parents=SOURCE_PARENTS,
        candidate_source_hashes=sources, diagnostic_jobs=jobs, diagnostic_evidence_directories=frozen_paths,
        diagnostic_source_versions={n:SOURCE_VERSION if n in REFERENCES else n for n in sources},
        diagnostic_expected_checks={n:DIAGNOSTICS[n][4] for n in sources}, prior_job='1581459',
        prior_campaign='.runs/conv/sep12n-campaign.json', prior_c40_decisions=old_decisions,
        auxiliary_comparisons={'C51-row7x3u1':'C40-r4'},
        selection_rule='C51 must qualify versus both unchanged same-job C6 controls: gain in sum of case medians exceeds max(1%, all compared per-case spreads), no case regression over1%. Every slow sample retained. Initial qualification is a flag for root review only; no automatic confirmation, promotion or ZIP.',
        attribution_rule='C51 versus C40-r4 is a separate whole-implementation comparison. It does not replace C6 usefulness or isolate spill cost. C40-r4 is reference-only, promotion_allowed=false; Gfalse/Jtrue/Kfalse and Nreference remain unchanged. No C40 confirmation is attempted.',
        local_compilation_or_tests_run=False, official_score=None, automatic_confirmation=False,
        automatic_promotion=False, automatic_packaging=False, submitted=False, submit_attempted=False)
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
            e.new(argparse.Namespace(problem='conv',version=name,parent=None,strategy='Unchanged C6 R-round matched control'))
        e.new(argparse.Namespace(problem='conv',version='C40-r4',parent=SOURCE_VERSION,
            strategy='Same-source C40 reference-only context for C51; promotion forbidden, not a confirmation repeat'))
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
                note='R fixed four-member order, three independent original official suites each, total48 cases. C51 passed its actual frozen Q diagnostic; C40-r4 is same-source reference-only and cannot promote. Both C6 controls unchanged; all prior samples and decisions preserved. No local operator execution.'))
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
