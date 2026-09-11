#!/usr/bin/env python3
"""TRSM-only records under an explicit user-requested no-hash policy.

Only the existing pure parsers, status predicate, workflow lock and JSON writer
are reused. Historical hash fields are retained as unchecked metadata. No hash
is computed or verified, and remote source/transfer identity is not asserted.
"""
import argparse
import copy
import datetime
import importlib.util
import json
import math
from pathlib import Path
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[3]
RUNS = ROOT / '.runs' / 'trsm'
RECORDS = ROOT / 'records' / 'experiments' / 'trsm'
POLICY = 'user-requested-no-hash'
ARTIFACTS = ('benchmark.log', 'environment.log', 'exit-code.txt',
             'scheduler-status.txt', 'cluster.json')
SOURCES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h')
CASE_DIMS = [[512, 19968], [2432, 17024], [17024, 512]]
COMPARE_ENV = ('TEST_RUNS', 'KBLAS_LIB', 'CC', 'COMPILER', 'CPU_TARGET',
               'OMP_NUM_THREADS', 'OMP_DYNAMIC', 'OMP_PROC_BIND', 'OMP_PLACES')

_spec = importlib.util.spec_from_file_location('trsm_record_helpers', ROOT / 'tools' / 'experiment.py')
_helpers = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_helpers)
parse_log = _helpers.parse_log
machine_profile = _helpers.machine_profile
scheduler_ok = _helpers.scheduler_ok
locked = _helpers.locked
write_json = _helpers.write_json


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def read_json(path):
    value = json.loads(Path(path).read_text())
    if not isinstance(value, dict):
        raise ValueError('Expected a JSON object: ' + str(path))
    return value


def version_id(value):
    if not isinstance(value, str) or not re.fullmatch(r'T\d+(?:-[A-Za-z0-9]+)*', value):
        raise ValueError('Invalid TRSM version: ' + str(value))
    return value


def within_runs(path):
    path = Path(path).resolve()
    path.relative_to(RUNS.resolve())
    return path


def record_path(version):
    return RECORDS / (version_id(version) + '.json')


def load_record(version):
    rec = read_json(record_path(version))
    if rec.get('problem') != 'trsm' or rec.get('version') != version:
        raise ValueError('Record identity mismatch: ' + version)
    return rec


def regular_bytes(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Required regular file missing or symlinked: ' + str(path))
    return path.read_bytes()


def same_bytes(left, right):
    try:
        return regular_bytes(left) == regular_bytes(right)
    except (OSError, ValueError):
        return False


def cpu_ids(value):
    values = set()
    for part in value.strip().split(','):
        if not re.fullmatch(r'\d+(?:-\d+)?', part):
            raise ValueError('Invalid CPU list')
        ends = list(map(int, part.split('-')))
        low, high = ends[0], ends[-1]
        if low > high or high - low > 65536:
            raise ValueError('Invalid CPU range')
        values.update(range(low, high + 1))
    return values


def scheduler_job_id(text):
    try:
        value = json.loads(text)
    except ValueError:
        matches = re.findall(r'^\s*(?:jobId|job_id)\s*[:=]?\s+(\d+)\s*$', text, re.M)
        return matches[0] if len(matches) == 1 else None
    if isinstance(value, dict) and 'jobs' in value:
        jobs = value['jobs']
        value = jobs[0] if isinstance(jobs, list) and len(jobs) == 1 else None
    if not isinstance(value, dict):
        return None
    job = value.get('jobId', value.get('job_id'))
    return str(job) if re.fullmatch(r'\d+', str(job)) else None


def audit(folder, meta):
    """Read only ordinary evidence; do not invoke the original record routine."""
    failures = []
    payloads = {}
    for name in ARTIFACTS:
        try:
            payloads[name] = regular_bytes(folder / name)
        except (OSError, ValueError) as exc:
            failures.append(str(exc))
    text = payloads.get('benchmark.log', b'').decode('utf-8', 'replace')
    status_text = payloads.get('scheduler-status.txt', b'').decode('utf-8', 'replace')
    try:
        cluster = json.loads(payloads.get('cluster.json', b'{}'))
        if not isinstance(cluster, dict):
            raise ValueError('cluster.json is not an object')
    except ValueError as exc:
        failures.append('Invalid cluster.json: ' + str(exc))
        cluster = {}
    settings = copy.deepcopy(cluster.get('settings', meta.get('settings', {})))
    if not isinstance(settings, dict):
        settings = {}
    env = settings.get('environment', {})
    if not isinstance(env, dict):
        env = {}
    env = {key: str(value) for key, value in env.items()}
    settings['environment'] = env
    job = str(cluster.get('job_id', cluster.get('jobId', '')))
    measurements = {'cases': [], 'repeats': 0, 'total_median_ms': None,
                    'official_score': None, 'ranking': None}
    parsed = False
    try:
        measurements = parse_log('trsm', text, 3)
        parsed = True
    except ValueError as exc:
        failures.append('Official suite: ' + str(exc))
    machine = machine_profile(folder, text)
    required = ('HOST', 'ARCH', 'NUMA_NODE', 'ALLOWED_CPUS', 'OMP_NUM_THREADS', 'CPU_TARGET')
    machine_ok = all(machine.get(key) for key in required) and bool(machine.get('compiler_banners'))
    try:
        machine_ok = bool(machine_ok and machine['ARCH'] == 'aarch64'
                          and machine['OMP_NUM_THREADS'] == '38'
                          and re.fullmatch(r'\d+', machine['NUMA_NODE'])
                          and len(cpu_ids(machine['ALLOWED_CPUS'])) == 38)
    except (KeyError, ValueError):
        machine_ok = False
    source_payloads = {}
    for name in SOURCES:
        try:
            source_payloads[name] = regular_bytes(folder / 'source' / name)
        except (OSError, ValueError) as exc:
            failures.append(str(exc))
    try:
        benchmark_ok = (source_payloads.get('bench_trsm.c')
                        == regular_bytes(ROOT / 'trsm' / 'bench_trsm.c'))
    except (OSError, ValueError):
        benchmark_ok = False
    checks = {
        'evidence_files_present': len(payloads) == len(ARTIFACTS),
        'job_id': bool(re.fullmatch(r'\d+', job)) and scheduler_job_id(status_text) == job,
        'scheduler_succeeded': scheduler_ok(status_text),
        'wrapper_exit_zero': payloads.get('exit-code.txt', b'').strip() == b'0',
        'three_complete_ordered_suites': parsed,
        'precision_at_most_1e_12': parsed and all(c['max_error'] <= 1e-12 for c in measurements['cases']),
        'machine_and_38_cpus': machine_ok,
        'settings_38_threads': env.get('OMP_NUM_THREADS') == '38',
        'settings_three_suites': str(settings.get('bench_repeats', '')) == '3',
        'test_runs_documented': bool(re.fullmatch(r'[1-9]\d*', env.get('TEST_RUNS', ''))),
        'reference_library_documented': bool(env.get('KBLAS_LIB')),
        'benchmark_matches_current_trsm_bytes': benchmark_ok,
        'local_source_files_present': len(source_payloads) == len(SOURCES),
    }
    for key, expected in (('problem', 'trsm'), ('version', meta['version'])):
        if key in cluster and cluster[key] != expected:
            checks['cluster_' + key] = False
    for key in ('OMP_NUM_THREADS', 'CPU_TARGET'):
        if key in env and env[key] != machine.get(key):
            checks['settings_match_' + key.lower()] = False
    failures.extend(key + ' failed' for key, value in checks.items() if not value)
    return dict(measurements=measurements, machine=machine, settings=settings,
                job_id=job, checks=checks, failures=failures,
                payloads=payloads, source_payloads=source_payloads)


def do_record(args):
    folder = within_runs(args.run_dir)
    meta = read_json(folder / 'experiment.json')
    version = version_id(meta.get('version'))
    if meta.get('problem') != 'trsm':
        raise ValueError('Only TRSM is supported')
    if meta.get('parent'):
        version_id(meta['parent'])
    target = record_path(version)
    previous = read_json(target) if target.exists() else None
    if previous and (previous.get('recorded_at') or previous.get('status') not in ('planned', 'prepared')):
        raise ValueError('A recorded result cannot be overwritten; create a new run/version')
    if not args.environment.strip() or not args.reference.strip():
        raise ValueError('Environment and actual reference library descriptions are required')
    result = copy.deepcopy(meta)
    observed = audit(folder, meta)
    snapshot = folder / 'nohash-recorded-evidence'
    if snapshot.exists():
        raise ValueError('Evidence snapshot already exists; do not overwrite earlier evidence')
    snapshot.mkdir()
    for name, data in observed['payloads'].items():
        (snapshot / name).write_bytes(data)
    for name, data in observed['source_payloads'].items():
        dest = snapshot / 'source' / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
    # Register the actual archived bytes, not a separate read of live logs.
    # This also prevents a concurrently replaced environment.log from making
    # a passed record describe a different machine than its evidence copy.
    observed = audit(snapshot, meta)
    live_matches = all(same_bytes(folder / name, snapshot / name) for name in ARTIFACTS)
    live_matches = live_matches and all(
        same_bytes(folder / 'source' / name, snapshot / 'source' / name) for name in SOURCES)
    observed['checks']['record_snapshot_matches_live_bytes'] = live_matches
    if not live_matches:
        observed['failures'].append('Live inputs changed or are missing during record snapshot creation')
    result.update(observed['measurements'])
    verified = all(observed['checks'].values())
    result.update(recorded_at=now(), environment=args.environment, reference=args.reference,
                  machine=observed['machine'], settings=observed['settings'],
                  job_id=observed['job_id'], checks=observed['checks'], verified=verified,
                  status='passed' if verified else ('unverified' if observed['measurements']['repeats'] == 3 else 'failed'),
                  validation_policy=POLICY, hash_validation='not performed: prohibited by user',
                  legacy_hash_fields='Any inherited hash values are preserved metadata only; not recomputed or validated',
                  source_identity_limit='Local byte snapshots only; remote source identity and transfer integrity are not verified',
                  run_dir=str(folder.relative_to(ROOT)),
                  nohash_evidence=str(snapshot.relative_to(ROOT)),
                  log=str((snapshot / 'benchmark.log').relative_to(ROOT)),
                  metric='sum of per-case median ms; not official score')
    if observed['failures']:
        result['failures'] = observed['failures']
    write_json(target, result)
    print(json.dumps({'version': version, 'status': result['status'], 'verified': verified,
                      'validation_policy': POLICY, 'total_median_ms': result['total_median_ms'],
                      'failures': result.get('failures', []), 'metric': result['metric']}, ensure_ascii=False, indent=2))
    return 0 if verified else 2


def evidence_folder(rec):
    return within_runs(ROOT / rec['nohash_evidence'])


def measured_source(rec, name='trsm.c'):
    if rec.get('nohash_evidence'):
        return evidence_folder(rec) / 'source' / name
    return within_runs(ROOT / rec.get('run_dir', str(Path('.runs/trsm') / rec['version']))) / 'source' / name


def record_reasons(rec):
    reasons = []
    version = rec['version']
    if rec.get('problem') != 'trsm' or rec.get('status') != 'passed' or rec.get('verified') is not True:
        reasons.append(version + ': not a passed, verified TRSM run')
    if rec.get('repeats') != 3 or [c.get('dims') for c in rec.get('cases', [])] != CASE_DIMS:
        reasons.append(version + ': exactly three complete suites required')
    if rec.get('validation_policy') != POLICY or not rec.get('nohash_evidence'):
        reasons.append(version + ': fresh evidence under the no-hash policy is required')
        return reasons
    try:
        snap = evidence_folder(rec)
        fresh = audit(snap, rec)
        if not all(fresh['checks'].values()):
            reasons.extend(version + ': ' + item for item in fresh['failures'])
        for key in ('cases', 'repeats', 'total_median_ms'):
            if rec.get(key) != fresh['measurements'][key]:
                reasons.append(version + ': recorded ' + key + ' differs from evidence')
        for key in ('machine', 'settings', 'job_id'):
            if rec.get(key) != fresh[key]:
                reasons.append(version + ': recorded ' + key + ' differs from evidence')
        live = within_runs(ROOT / rec['run_dir'])
        for name in SOURCES:
            if not same_bytes(live / 'source' / name, snap / 'source' / name):
                reasons.append(version + ': source changed since record: ' + name)
        for name in ARTIFACTS:
            if not same_bytes(live / name, snap / name):
                reasons.append(version + ': evidence changed since record: ' + name)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        reasons.append(version + ': evidence recheck failed: ' + str(exc))
    return reasons


def comparison(base, candidate):
    reasons = record_reasons(base) + record_reasons(candidate)
    for key in ('environment', 'reference', 'machine'):
        if not base.get(key) or base.get(key) != candidate.get(key):
            reasons.append(key + ' differs or is undocumented')
    for key in COMPARE_ENV:
        a = base.get('settings', {}).get('environment', {}).get(key)
        b = candidate.get('settings', {}).get('environment', {}).get(key)
        if a != b:
            reasons.append(key + ' differs; repeat together under the same conditions')
    try:
        if not same_bytes(measured_source(base, 'bench_trsm.c'), measured_source(candidate, 'bench_trsm.c')):
            reasons.append('benchmark bytes differ or are unavailable')
        a, b = measured_source(base), measured_source(candidate)
        if a.is_file() and b.is_file():
            different = regular_bytes(a) != regular_bytes(b)
        else:
            left, right = base.get('source_implementation_id'), candidate.get('source_implementation_id')
            different = bool(left and right and left != right)
        if not different:
            reasons.append('same implementation or implementation difference not evidenced; a repeat is not a new improvement')
    except (OSError, ValueError, KeyError) as exc:
        reasons.append('implementation comparison failed: ' + str(exc))
    rows, total_gain, noise = [], None, None
    if not reasons:
        for a, b in zip(base['cases'], candidate['cases']):
            gain = (a['median_ms'] - b['median_ms']) / a['median_ms'] * 100
            rows.append(dict(dims=a['dims'], base_ms=a['median_ms'], candidate_ms=b['median_ms'], gain_pct=gain))
        total_gain = (base['total_median_ms'] - candidate['total_median_ms']) / base['total_median_ms'] * 100
        noise = max([1.0] + [c['spread_pct'] for c in base['cases'] + candidate['cases']])
        if not math.isfinite(total_gain) or total_gain <= noise:
            reasons.append('total improvement %.4f%% does not exceed threshold %.4f%%' % (total_gain, noise))
        if any(row['gain_pct'] < -1.0 for row in rows):
            reasons.append('at least one official case regresses by more than 1%')
    return dict(eligible=not reasons, reasons=reasons, cases=rows,
                total_gain_pct=total_gain, noise_threshold_pct=noise,
                validation_policy=POLICY, hash_validation='not performed',
                metric='sum of per-case median ms; not official score')


def do_compare(args):
    result = comparison(load_record(version_id(args.base)), load_record(version_id(args.candidate)))
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result['eligible'] else 2


def do_promote(args):
    rec = load_record(version_id(args.version))
    reasons = record_reasons(rec)
    if reasons:
        raise ValueError('; '.join(reasons))
    best_path = ROOT / 'records' / 'best.json'
    best = read_json(best_path) if best_path.exists() else {}
    current = ROOT / 'trsm' / 'trsm.c'
    parent = rec.get('parent')
    if parent:
        version_id(parent)
        if best.get('trsm') != parent:
            raise ValueError('Parent is not the current TRSM best; do not overwrite another promotion')
        parent_rec = load_record(parent)
        if not same_bytes(current, measured_source(parent_rec)):
            raise ValueError('Current trsm.c differs from the recorded parent; do not overwrite local edits')
        verdict = comparison(parent_rec, rec)
        if not verdict['eligible']:
            raise ValueError('; '.join(verdict['reasons']))
    elif not same_bytes(current, measured_source(rec)):
        raise ValueError('A baseline without parent must be byte-identical to current trsm.c')
    # Only the kernel is promoted. Keep all other problems and all runners intact.
    shutil.copy2(measured_source(rec), current)
    best['trsm'] = rec['version']
    write_json(best_path, best)
    rec['promoted_at'] = now()
    rec['promotion_validation_policy'] = POLICY
    write_json(record_path(rec['version']), rec)
    print('Promoted TRSM ' + rec['version'] + ' under the no-hash policy; no competition submission was made')
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    p = sub.add_parser('record')
    p.add_argument('run_dir')
    p.add_argument('--environment', required=True)
    p.add_argument('--reference', required=True)
    p.set_defaults(action=do_record)
    p = sub.add_parser('compare')
    p.add_argument('base')
    p.add_argument('candidate')
    p.set_defaults(action=do_compare)
    p = sub.add_parser('promote')
    p.add_argument('version')
    p.set_defaults(action=do_promote)
    args = parser.parse_args()
    try:
        with locked():
            return args.action(args)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print('Error: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
