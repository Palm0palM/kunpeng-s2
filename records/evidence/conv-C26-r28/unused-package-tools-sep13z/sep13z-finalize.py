"""Root-only C52 finalization after independent W/Y and exact original ZIP.

Without --apply this reads saved evidence only. No operator, network, Git,
submission, or package generation. The package record remains reference-only.
"""
import argparse
import importlib.util
import io
import json
from pathlib import Path
import re
import shutil
import stat
import sys
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('sep13z_contract', Path(__file__).with_name('sep13z-submit-package.py'))
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
e, c = contract.e, contract.c
STRATEGY = 'Seven adjacent output rows with three SVE vectors and 21 accumulators; shared kernel columns unrolled in ordered pairs with a single-column odd remainder, twelve other phases remain single-column; strict separate multiply/add and original tails/fallbacks'


def verified_package(context):
    run = ROOT / '.runs/conv' / contract.VERSION
    rec = e.get_record('conv', contract.VERSION)
    manifest = e.read_json(run / 'cluster.json')
    confirmation = context['y_records'][contract.CONFIRMATION]
    assert rec['problem'] == 'conv' and rec['version'] == contract.VERSION
    assert rec['status'] == 'passed' and rec['verified'] is True and rec['repeats'] == 3
    assert set(rec['checks']) == contract.CHECKS and all(v is True for v in rec['checks'].values())
    assert rec['reference_only'] is True and rec['promotion_allowed'] is False
    assert rec['package_validation_only'] is True and rec['parent'] == rec['source_parent'] == contract.CONFIRMATION
    assert rec['source_origin'] == contract.SOURCE_VERSION and rec['initial_performance_job'] == '1582256'
    assert rec['package_confirmation_job'] == context['y']['performance_job'] == contract.CONFIRMATION_JOB
    assert rec['diagnostic_source_version'] == contract.SOURCE_VERSION
    assert rec['diagnostic_job_id'] == '1582134' and rec['diagnostic_evidence_directory'] == contract.T_DIRECTORY
    assert rec['diagnostic_source_sha256'] == contract.SOURCE_SHA256
    assert rec['expected_benchmark_cases'] == 12 and rec['expected_compiler_banners'] == ['gcc (GCC) 10.3.1']
    assert rec['settings'] == manifest['settings'] == context['settings']
    assert rec['reference'] == confirmation['reference']
    assert rec['job_id'] == manifest['job_id'] and str(rec['job_id']).isdigit()
    assert len({rec['job_id'], context['y']['performance_job'], '1582256', '1582134', '1582067', '1582372'}) == 6
    status = manifest['scheduler_status']
    assert status == c.parse_scheduler_status((run/'scheduler-status.txt').read_text(), rec['job_id'])
    assert status['status'] == 'SUCCEEDED' and str(status['jobId']) == rec['job_id']
    assert type(status['jobExitCode']) is int and type(status['systemExitCode']) is int
    assert status['jobExitCode'] == status['systemExitCode'] == 0
    assert manifest['fetch_state'] == 'complete' and (run/'exit-code.txt').read_text().strip() == '0'
    for name in ('benchmark.log', 'environment.log', 'exit-code.txt', 'source-sha256.txt'):
        assert e.digest(run/name) == manifest['artifacts_sha256'][name]
    assert e.source_files(run/'source') == rec['source_hashes'] == manifest['source_hashes'] == context['source']
    remote = {}
    for line in (run/'source-sha256.txt').read_text().splitlines():
        m = re.fullmatch(r'([0-9a-f]{64})\s+\*?(?:\./)?(?:source/)?(.+)', line)
        if m:
            assert m[2] not in remote
            remote[m[2]] = m[1]
    assert all(remote.get(name) == digest for name, digest in context['source'].items())
    log = (run/'benchmark.log').read_text()
    parsed = e.parse_log('conv', log, 3)
    assert parsed['cases'] == rec['cases'] and parsed['total_median_ms'] == rec['total_median_ms']
    assert [x['dims'] for x in rec['cases']] == contract.DIMS
    assert all(len(x['times_ms']) == 3 and x['max_error'] == 0 for x in rec['cases'])
    assert re.findall(r'^BENCH_REPEAT ([1-3])/3 (BEGIN|END)$', log, re.M) == [(str(i), event) for i in (1,2,3) for event in ('BEGIN','END')]
    assert len(re.findall(r'^BENCH_JOB_BEGIN .+$', log, re.M)) == len(re.findall(r'^BENCH_JOB_END .+$', log, re.M)) == 1
    machine = e.machine_profile(run, log)
    assert machine == rec['machine'] and machine['compiler_banners'] == ['gcc (GCC) 10.3.1']
    assert machine['ARCH'] == 'aarch64' and machine['CPU_TARGET'] == 'generic' and machine['OMP_NUM_THREADS'] == '38'
    cpus = machine['ALLOWED_CPUS'].split(',')
    assert len(cpus) == len(set(cpus)) == 38 and all(x.isdigit() for x in cpus)
    assert machine['HOST'] and machine['NUMA_NODE']
    archive = (run/'conv.zip').read_bytes()
    package = e.read_json(run/'package-manifest.json')
    assert package == manifest['package_verification']
    assert package['source_hashes'] == context['source'] and package['zip_sha256'] == e.digest(run/'conv.zip')
    marker = 'PACKAGE_SHA256_VERIFIED=' + package['zip_sha256']
    assert (run/'wrapper.stdout.log').read_text().splitlines().count(marker) == 1
    with zipfile.ZipFile(io.BytesIO(archive)) as z:
        infos = z.infolist()
        assert len(infos) == 4 and {i.filename for i in infos} == {'conv/'+name for name in contract.SOURCE_NAMES}
        for info in infos:
            name = info.filename.removeprefix('conv/')
            assert stat.S_ISREG(info.external_attr >> 16)
            assert z.read(info.filename) == (run/'source'/name).read_bytes() == (ROOT/'.runs/conv'/contract.CONFIRMATION/'source'/name).read_bytes()
            if name == 'run.sh':
                assert (info.external_attr >> 16) & 0o111
    submitted = e.read_json(run/'package-submit-exit.json')
    assert submitted['exit_code'] == 0 and submitted['automatic_retry'] is False
    assert submitted['argv'] == e.read_json(run/'package-submit-command.json')['argv']
    gates = e.read_json(run/'package-gates.json')
    assert gates['initial_job'] == '1582256' and gates['confirmation_job'] == context['y']['performance_job']
    assert gates['w_gates'] == context['w_gates'] and gates['y_gates'] == context['y_gates']
    assert gates['diagnostic_job'] == '1582134' and gates['source_version'] == contract.SOURCE_VERSION
    assert gates['package_source_parent'] == contract.CONFIRMATION
    assert gates['reference_only'] is True and gates['promotion_allowed'] is False
    assert gates['prior_decisions'] == context['prior_decisions'] and gates['original_evidence_unchanged'] is True
    return rec, package, archive


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    context, cfg = contract.preflight()
    pack, package, archive = verified_package(context)
    old = e.read_json(ROOT/'outputs/conv-best.json')
    lineage = e.read_json(ROOT/'records/conv-lineage.json')
    assert lineage['current_label'] == old['label'] == 'C6'
    assert lineage['current_measurement'] == 'C26-r1'
    assert not any(x['label'] == 'C7' for x in lineage['versions'])
    old_entry = [x for x in lineage['versions'] if x['label'] == 'C6']
    assert len(old_entry) == 1 and old_entry[0]['kernel_sha256'] == old['source_hashes']['conv2d.c']
    assert old_entry[0]['package_verification']['sha256'] == old['package_sha256']
    assert old['zip_verification']['all_pass'] is True and e.digest(ROOT/'outputs/conv-best.zip') == old['package_sha256']
    rec = context['y_records'][contract.CONFIRMATION]
    base, opening = context['y_records']['C26-r29'], context['y_records']['C26-r28']
    initial = context['w_records'][contract.SOURCE_VERSION]
    assert base['parent'] is None and opening['parent'] is None
    gain = context['y_gates'][1]['total_gain_pct']
    summary = dict(mode='apply' if args.apply else 'read-only preflight', old='C6', new='C7',
        experiment=contract.CONFIRMATION, source=contract.SOURCE_VERSION, initial_job='1582256',
        confirmation_job=rec['job_id'], package_job=pack['job_id'], total_median_ms=rec['total_median_ms'],
        baseline_total_median_ms=base['total_median_ms'], time_reduction_pct=gain,
        package_total_median_ms=pack['total_median_ms'], diagnostic_checks=37128)
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    if not args.apply:
        return
    with e.locked():
        latest, latest_cfg = contract.preflight()
        assert latest == context and latest_cfg == cfg
        assert verified_package(latest) == (pack, package, archive)
        assert e.read_json(ROOT/'outputs/conv-best.json') == old and e.read_json(ROOT/'records/conv-lineage.json') == lineage
        # Standard promote updates only best['conv'] and retains other problems.
        other_best = {key:value for key,value in e.read_json(ROOT/'records/best.json').items() if key != 'conv'}
        # Refresh the measured unchanged baseline, then promote only the
        # independently confirmed source through the standard workflow.
        e.promote(argparse.Namespace(problem='conv', version='C26-r29'))
        e.promote(argparse.Namespace(problem='conv', version=contract.CONFIRMATION))
        assert {key:value for key,value in e.read_json(ROOT/'records/best.json').items() if key != 'conv'} == other_best
        assert e.source_files(ROOT/'conv') == context['source']
        rec = e.get_record('conv', contract.CONFIRMATION)
        rec['decision_note'] = 'Selected as C7 after W initial qualification, one independent Y confirmation and a third exact-ZIP validation allocation. All samples and case gates retained.'
        e.write_json(e.record_path('conv', contract.CONFIRMATION), rec)
        zipcheck = dict(experiment=contract.VERSION, job_id=pack['job_id'], total_median_ms=pack['total_median_ms'],
            suites=3, cases_per_suite=4, all_pass=True, max_error=0,
            archive_verified_and_extracted_on_compute_node=True, same_source_as_promoted=True)
        metadata = dict(label='C7', experiment=contract.CONFIRMATION, source_experiment=contract.SOURCE_VERSION,
            source_hashes=context['source'], package_sha256=package['zip_sha256'],
            total_median_ms=rec['total_median_ms'], metric='sum of four per-case medians across three independent suites; not official score',
            controlled_comparison=dict(baseline=base['version'], baseline_total_median_ms=base['total_median_ms'],
                candidate_total_median_ms=rec['total_median_ms'], time_reduction_pct=gain,
                opening_baseline=opening['version'], opening_baseline_total_median_ms=opening['total_median_ms'],
                opening_time_reduction_pct=context['y_gates'][0]['total_gain_pct'],
                initial_candidate=contract.SOURCE_VERSION, initial_candidate_job=initial['job_id'],
                initial_candidate_total_median_ms=initial['total_median_ms'], initial_candidate_qualified=True,
                confirmation_job=rec['job_id'], samples_mixed_with_initial_round=False),
            verification=rec['checks'], zip_verification=zipcheck,
            specialized_correctness=dict(source_experiment=contract.SOURCE_VERSION, job_id='1582134', checks=37128,
                all_pass=True, threads=[1,4], sve_bits=[128,256,512]), official_submission=False)
        shutil.copy2(ROOT/'.runs/conv'/contract.VERSION/'conv.zip', ROOT/'outputs/conv-best.zip')
        e.write_json(ROOT/'outputs/conv-best.json', metadata)
        (ROOT/'outputs/conv-best.zip.sha256').write_text(package['zip_sha256']+'  conv-best.zip\n')
        lineage['versions'].append(dict(label='C7', experiment=contract.CONFIRMATION, source_experiment=contract.SOURCE_VERSION,
            parent_label='C6', comparison_baseline=base['version'], kernel_sha256=context['source']['conv2d.c'],
            total_median_ms=rec['total_median_ms'], time_reduction_pct=gain, strategy=STRATEGY,
            promoted_at=rec['promoted_at'], official_score=None,
            repeat_measurements=[dict(experiment=contract.SOURCE_VERSION, job_id=initial['job_id'], total_median_ms=initial['total_median_ms'], qualified=True)],
            package_verification=dict(zipcheck, sha256=package['zip_sha256'])))
        lineage.update(current_label='C7', current_measurement=contract.CONFIRMATION, current_total_median_ms=rec['total_median_ms'])
        e.write_json(ROOT/'records/conv-lineage.json', lineage)
        assert e.digest(ROOT/'outputs/conv-best.zip') == package['zip_sha256']
        assert e.get_record('conv', contract.VERSION) == pack, 'Reference-only package record must remain unchanged'
    print('Finalized raw C7 from the same original verified ZIP. Public export, Git and official submission remain separate root decisions.')


if __name__ == '__main__':
    main()
