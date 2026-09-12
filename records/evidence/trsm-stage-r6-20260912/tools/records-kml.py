#!/usr/bin/env python3
"""TRSM KML 25.1 / private GCC 12.3.1 records without hash operations.

Only the existing pure parsers, status predicate, workflow lock and JSON writer
are reused. Historical hash fields are retained as unchecked metadata. No hash
is computed or verified, and remote source/transfer identity is not asserted.
KML 25.1 evidence must not be described as an official KML 25.2 revalidation.
"""
import argparse
import copy
import datetime
import importlib.util
import json
import math
from pathlib import Path, PurePosixPath
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[3]
RUNS = ROOT / '.runs' / 'trsm'
RECORDS = ROOT / 'records' / 'experiments' / 'trsm'
POLICY = 'user-requested-no-hash'
ARTIFACTS = ('benchmark.log', 'environment.log', 'exit-code.txt',
             'scheduler-status.txt', 'cluster.json', 'linkage.log')
SOURCES = ('trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h')
CASE_DIMS = [[512, 19968], [2432, 17024], [17024, 512]]
COMPARE_ENV = ('TEST_RUNS', 'KBLAS_LIB', 'CC', 'COMPILER', 'CPU_TARGET',
               'OMP_NUM_THREADS', 'OMP_DYNAMIC', 'OMP_PROC_BIND', 'OMP_PLACES',
               'KML251_ROOT', 'KML251_ARCH', 'KML251_LIBDIR', 'COMPILER_ROOT',
               'GOMP_LIBRARY', 'CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH',
               'COMPILER_VERSION')
KML_ENV = ('KML251_ROOT', 'KML251_ARCH', 'KML251_LIBDIR', 'COMPILER_ROOT',
           'GOMP_LIBRARY', 'CPATH', 'LIBRARY_PATH', 'LD_LIBRARY_PATH',
           'COMPILER_VERSION')
KML_EVIDENCE_SCHEMA = 'trsm-kml251-gcc1231-linkage-v1'

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


def remote_path(value):
    """Validate a target-side absolute path lexically, without local resolution."""
    if not isinstance(value, str) or not value or any(c.isspace() for c in value):
        raise ValueError('Missing or invalid remote path')
    path = PurePosixPath(value)
    if not path.is_absolute() or '..' in path.parts or str(path) != value:
        raise ValueError('Remote path must be absolute and normalized: ' + value)
    return path


def env_lines_match(text, env, keys):
    for key in keys:
        if key not in env:
            return False
        values = re.findall(r'^' + re.escape(key) + r'=(.*)$', text, re.M)
        if not values or any(value != env[key] for value in values):
            return False
    return True


def kml_environment(env):
    """Require the real-header, default -lkblas runner branch and private runtime."""
    try:
        if env.get('KBLAS_LIB') != '' or any(not env.get(key) for key in KML_ENV):
            return False
        root = remote_path(env['KML251_ROOT'])
        libdir = remote_path(env['KML251_LIBDIR'])
        compiler = remote_path(env['COMPILER_ROOT'])
        gomp = remote_path(env['GOMP_LIBRARY'])
        if root.name != 'KunpengHPCKit-kml.25.1.0':
            return False
        if env['KML251_ARCH'] not in ('sme', 'sve', 'neon'):
            return False
        if libdir != root / 'gcclib' / env['KML251_ARCH'] / 'kblas' / 'multi':
            return False
        if 'compiler-private' not in compiler.parts or '12.3.1' not in compiler.name:
            return False
        if gomp != compiler / 'lib64' / 'libgomp.so.1.0.0':
            return False
        if not re.search(r'\b12\.3\.1\b', env['COMPILER_VERSION']):
            return False
        if env.get('CC') not in ('gcc', str(compiler / 'bin' / 'gcc')):
            return False
        # Search paths are part of the measured environment, not synthetic metadata.
        if env['CPATH'].split(':')[0] != str(root / 'include'):
            return False
        for key in ('LIBRARY_PATH', 'LD_LIBRARY_PATH'):
            paths = env[key].split(':')
            if str(libdir) not in paths or str(compiler / 'lib64') not in paths:
                return False
            if any('openblas' in path.lower() for path in paths):
                return False
        return True
    except (KeyError, ValueError):
        return False


def linkage_audit(text, env, job):
    """Check three raw ldd captures and their target-side resolved library paths."""
    failures = []
    pattern = re.compile(
        r'^LINKAGE_REPEAT ([123])/3 BEGIN\n(.*?)^LINKAGE_REPEAT \1/3 END(?:\n|$)',
        re.M | re.S)
    blocks = list(pattern.finditer(text))
    if [match.group(1) for match in blocks] != ['1', '2', '3'] or pattern.sub('', text).strip():
        return ['linkage.log must contain exactly three ordered, complete blocks']
    try:
        libdir = remote_path(env['KML251_LIBDIR'])
        compiler_libdir = remote_path(env['COMPILER_ROOT']) / 'lib64'
        expected_kblas = libdir / 'libkblas.so.25.1.0'
        expected_gomp = remote_path(env['GOMP_LIBRARY'])
        if expected_gomp != compiler_libdir / 'libgomp.so.1.0.0':
            raise ValueError('GOMP_LIBRARY must name the private GCC runtime')
    except (KeyError, ValueError) as exc:
        return ['linkage environment invalid: ' + str(exc)]
    binaries = []
    for match in blocks:
        label = 'linkage repeat ' + match.group(1)
        block = match.group(2)
        try:
            fields = {}
            for key in ('JOB_ID', 'BINARY', 'LDD_EXIT_CODE', 'KML251_LINKED_LIBRARY',
                        'GOMP_LINKED_LIBRARY', 'KML251_DEPENDENCY_AUDIT_PASS'):
                values = re.findall(r'^' + key + r'=(.*)$', block, re.M)
                if len(values) != 1:
                    raise ValueError(key + ' must occur exactly once')
                fields[key] = values[0]
            if fields['JOB_ID'] != job or not re.fullmatch(r'\d+', fields['JOB_ID']):
                raise ValueError('JOB_ID differs from scheduler evidence')
            binaries.append(str(remote_path(fields['BINARY'])))
            if PurePosixPath(binaries[-1]).name != 'trsm_test':
                raise ValueError('BINARY must be the original runner output trsm_test')
            if fields['LDD_EXIT_CODE'] != '0' or fields['KML251_DEPENDENCY_AUDIT_PASS'] != '1':
                raise ValueError('ldd or target dependency audit did not succeed')
            if 'not found' in block.lower() or 'openblas' in block.lower():
                raise ValueError('unresolved dependency or OpenBLAS is present')
            for soname, prefix, expected_dir, resolved_key, expected_resolved in (
                    ('libkblas.so.25.1.0', 'libkblas', libdir,
                     'KML251_LINKED_LIBRARY', expected_kblas),
                    ('libgomp.so.1', 'libgomp', compiler_libdir,
                     'GOMP_LINKED_LIBRARY', expected_gomp)):
                raw_lines = re.findall(r'^\s*' + prefix + r'\S*\s+=>.*$', block, re.M)
                if len(raw_lines) != 1:
                    raise ValueError('exactly one raw ldd mapping is required for ' + prefix)
                loaded = re.fullmatch(r'\s*' + re.escape(soname)
                                      + r'\s+=>\s+(\S+)\s+\(0x[0-9a-fA-F]+\)\s*', raw_lines[0])
                if not loaded:
                    raise ValueError('invalid raw ldd mapping for ' + soname)
                loaded_path = remote_path(loaded.group(1))
                if loaded_path.parent != expected_dir:
                    raise ValueError(soname + ' was not loaded from its selected directory')
                if loaded_path.name not in (soname, expected_resolved.name):
                    raise ValueError('unexpected loaded filename for ' + soname)
                if remote_path(fields[resolved_key]) != expected_resolved:
                    raise ValueError('target-resolved path differs for ' + soname)
        except ValueError as exc:
            failures.append(label + ': ' + str(exc))
    if len(set(binaries)) != 1:
        failures.append('linkage repeats must audit the same member binary path')
    return failures


def benchmark_runtime_audit(text, env, machine):
    """The unmodified runner prints its compiler, CPU binding, and BLAS branch."""
    pattern = re.compile(r'^BENCH_REPEAT ([123])/3 BEGIN(?: [^\n]*)?\n'
                         r'(.*?)^BENCH_REPEAT \1/3 END\s*$', re.M | re.S)
    blocks = list(pattern.finditer(text))
    if [match.group(1) for match in blocks] != ['1', '2', '3']:
        return False
    try:
        for match in blocks:
            block = match.group(2)
            parse_log('trsm', block, 1)
            compilers = re.findall(r'^Compiler: (.+)$', block, re.M)
            if compilers != [env['COMPILER_VERSION']]:
                return False
            if len(re.findall(r'^Reference BLAS: official kblas$', block, re.M)) != 1:
                return False
            if 'Reference BLAS override:' in block:
                return False
            bindings = re.findall(r'^CPUs=(\S+) NUMA=(\d+) threads=(\d+)$', block, re.M)
            if len(bindings) != 1:
                return False
            cpus, numa, threads = bindings[0]
            if (cpu_ids(cpus) != cpu_ids(machine['ALLOWED_CPUS'])
                    or numa != machine['NUMA_NODE'] or threads != '38'):
                return False
        return True
    except (KeyError, ValueError):
        return False


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
    environment_text = payloads.get('environment.log', b'').decode('utf-8', 'replace')
    linkage_text = payloads.get('linkage.log', b'').decode('utf-8', 'replace')
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
        runner_ok = (source_payloads.get('run.sh')
                     == regular_bytes(ROOT / 'trsm' / 'run.sh'))
    except (OSError, ValueError):
        benchmark_ok = False
        runner_ok = False
    linkage_failures = linkage_audit(linkage_text, env, job)
    failures.extend(linkage_failures)
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
        'test_runs_exactly_three': env.get('TEST_RUNS') == '3',
        'fixed_thread_binding_settings': (env.get('OMP_DYNAMIC') == 'FALSE'
                                          and env.get('OMP_PROC_BIND') == 'close'
                                          and env.get('OMP_PLACES') == 'cores'
                                          and env.get('CPU_TARGET') == 'generic'),
        'real_kml251_and_private_gcc1231_documented': kml_environment(env),
        'runtime_environment_matches_settings': env_lines_match(
            environment_text, env, KML_ENV + ('KBLAS_LIB', 'TEST_RUNS', 'CC',
                                             'OMP_NUM_THREADS', 'OMP_DYNAMIC',
                                             'OMP_PROC_BIND', 'OMP_PLACES', 'CPU_TARGET')),
        'three_suites_link_true_kml251_and_private_gomp': not linkage_failures,
        'runner_compiler_reference_and_binding_match': benchmark_runtime_audit(text, env, machine),
        'benchmark_matches_current_trsm_bytes': benchmark_ok,
        'runner_matches_current_trsm_bytes': runner_ok,
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


def validate_repeat_existing(folder, meta, previous):
    """Only a promoted, unchanged current baseline may acquire a new run."""
    if not previous or previous.get('problem') != 'trsm' or previous.get('version') != meta['version']:
        raise ValueError('--repeat-existing requires an existing record for this exact TRSM version')
    if ('parent' not in meta or meta['parent'] is not None
            or 'parent' not in previous or previous['parent'] is not None):
        raise ValueError('--repeat-existing is restricted to baselines with explicit parent=null')
    for key in ('created_at', 'strategy', 'source_implementation_id', 'promoted_at'):
        if not isinstance(previous.get(key), str) or not previous[key].strip():
            raise ValueError('--repeat-existing requires the original baseline field: ' + key)
    if read_json(ROOT / 'records' / 'best.json').get('trsm') != meta['version']:
        raise ValueError('--repeat-existing requires this baseline to remain the current TRSM best')
    reasons = record_reasons(previous)
    if reasons:
        raise ValueError('--repeat-existing cannot replace an invalid prior record: ' + '; '.join(reasons))
    history = previous.get('previous_runs', [])
    if not isinstance(history, list) or any(not isinstance(item, dict) for item in history):
        raise ValueError('The prior record has invalid previous_runs metadata')
    protected_dirs = [within_runs(ROOT / previous['run_dir']), evidence_folder(previous)]
    for entry in history:
        for key in ('record_file', 'run_dir', 'nohash_evidence'):
            if not isinstance(entry.get(key), str) or not entry[key]:
                raise ValueError('Every historical run must retain ' + key)
        prior_file = within_runs(ROOT / entry['record_file'])
        historical_record = json.loads(regular_bytes(prior_file))
        if (not isinstance(historical_record, dict)
                or historical_record.get('problem') != 'trsm'
                or historical_record.get('version') != meta['version']
                or historical_record.get('parent') is not None
                or historical_record.get('run_dir') != entry['run_dir']
                or historical_record.get('nohash_evidence') != entry['nohash_evidence']):
            raise ValueError('A preserved previous run no longer matches its record reference')
        protected_dirs.extend((prior_file.parent, within_runs(ROOT / entry['run_dir']),
                               within_runs(ROOT / entry['nohash_evidence'])))
    for protected in protected_dirs:
        if folder == protected or folder in protected.parents or protected in folder.parents:
            raise ValueError('A repeat run directory must be disjoint from every earlier run and evidence directory')
    for name in ('prior-record.json', 'repeat-attempt.json'):
        if (folder / name).exists() or (folder / name).is_symlink():
            raise ValueError('Do not overwrite previous repeat evidence: ' + str(folder / name))
    for name in SOURCES:
        candidate = folder / 'source' / name
        if (not same_bytes(candidate, measured_source(previous, name))
                or not same_bytes(candidate, ROOT / 'trsm' / name)):
            raise ValueError('A repeated baseline source must match its prior snapshot and current trsm bytes: ' + name)


def preserve_repeat_identity(result, previous):
    # A new measurement must not redefine the original strategy or source lineage.
    keys = {'created', 'created_at', 'strategy', 'parent', 'promoted_at',
            'promotion_validation_policy'}
    keys.update(key for key in result if key.startswith('source_'))
    keys.update(key for key in previous if key.startswith('source_'))
    for key in keys:
        if key in previous:
            result[key] = copy.deepcopy(previous[key])
        else:
            result.pop(key, None)


def exclusive_json(path, value):
    with Path(path).open('x') as handle:
        handle.write(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def report_repeat_audit_exception(folder, meta, previous, error):
    report = dict(problem='trsm', version=meta['version'], parent=None,
                  status='failed', verified=False, repeat_existing=True,
                  record_updated=False, attempted_at=now(),
                  run_dir=str(folder.relative_to(ROOT)),
                  retained_record=str(record_path(meta['version']).relative_to(ROOT)),
                  retained_recorded_at=previous['recorded_at'], retained_job_id=previous['job_id'],
                  validation_policy=POLICY, hash_validation='not performed',
                  failures=['New repeat audit could not be completed: ' + str(error)])
    exclusive_json(folder / 'repeat-attempt.json', report)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 2


def do_record(args):
    folder = within_runs(args.run_dir)
    meta = read_json(folder / 'experiment.json')
    version = version_id(meta.get('version'))
    if meta.get('problem') != 'trsm':
        raise ValueError('Only TRSM is supported')
    if meta.get('parent'):
        version_id(meta['parent'])
    target = record_path(version)
    previous_bytes = regular_bytes(target) if target.exists() else None
    previous = json.loads(previous_bytes) if previous_bytes is not None else None
    if previous is not None and not isinstance(previous, dict):
        raise ValueError('The prior record must be a JSON object')
    if args.repeat_existing:
        validate_repeat_existing(folder, meta, previous)
    elif previous and (previous.get('recorded_at') or previous.get('status') not in ('planned', 'prepared')):
        raise ValueError('A recorded result cannot be overwritten; create a new run/version')
    if not args.environment.strip() or not args.reference.strip():
        raise ValueError('Environment and actual reference library descriptions are required')
    result = copy.deepcopy(meta)
    snapshot = folder / 'nohash-recorded-evidence'
    if snapshot.exists() or snapshot.is_symlink():
        raise ValueError('Evidence snapshot already exists; do not overwrite earlier evidence')
    try:
        observed = audit(folder, meta)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        if args.repeat_existing:
            return report_repeat_audit_exception(folder, meta, previous, exc)
        raise
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
    try:
        observed = audit(snapshot, meta)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        if args.repeat_existing:
            return report_repeat_audit_exception(folder, meta, previous, exc)
        raise
    live_matches = all(same_bytes(folder / name, snapshot / name) for name in ARTIFACTS)
    live_matches = live_matches and all(
        same_bytes(folder / 'source' / name, snapshot / 'source' / name) for name in SOURCES)
    observed['checks']['record_snapshot_matches_live_bytes'] = live_matches
    if not live_matches:
        observed['failures'].append('Live inputs changed or are missing during record snapshot creation')
    if args.repeat_existing:
        try:
            if regular_bytes(target) != previous_bytes:
                raise ValueError('The current record changed during repeat registration')
            validate_repeat_existing(folder, meta, previous)
            if any(not same_bytes(snapshot / 'source' / name, measured_source(previous, name))
                   or not same_bytes(snapshot / 'source' / name, ROOT / 'trsm' / name)
                   for name in SOURCES):
                raise ValueError('The repeat snapshot differs from the prior baseline or current source')
            observed['checks']['repeat_existing_preconditions_still_valid'] = True
        except (OSError, ValueError, KeyError, TypeError) as exc:
            observed['checks']['repeat_existing_preconditions_still_valid'] = False
            observed['failures'].append('Repeat preservation checks failed: ' + str(exc))
    result.update(observed['measurements'])
    verified = all(observed['checks'].values())
    result.update(recorded_at=now(), environment=args.environment, reference=args.reference,
                  machine=observed['machine'], settings=observed['settings'],
                  job_id=observed['job_id'], checks=observed['checks'], verified=verified,
                  status='passed' if verified else ('unverified' if observed['measurements']['repeats'] == 3 else 'failed'),
                  kml_evidence_schema=KML_EVIDENCE_SCHEMA,
                  intended_reference_version='KML 25.1.0',
                  actual_reference_version=(
                      'KML 25.1.0' if observed['checks']['real_kml251_and_private_gcc1231_documented']
                      and observed['checks']['three_suites_link_true_kml251_and_private_gomp'] else None),
                  actual_compiler_version=(
                      'GCC 12.3.1' if observed['checks']['real_kml251_and_private_gcc1231_documented']
                      and observed['checks']['runner_compiler_reference_and_binding_match'] else None),
                  official_kml252_revalidated=False,
                  validation_policy=POLICY, hash_validation='not performed: prohibited by user',
                  legacy_hash_fields='Any inherited hash values are preserved metadata only; not recomputed or validated',
                  source_identity_limit='Local byte snapshots only; remote source identity and transfer integrity are not verified',
                  run_dir=str(folder.relative_to(ROOT)),
                  nohash_evidence=str(snapshot.relative_to(ROOT)),
                  log=str((snapshot / 'benchmark.log').relative_to(ROOT)),
                  metric='sum of per-case median ms; not official score')
    if observed['failures']:
        result['failures'] = observed['failures']
    if args.repeat_existing:
        preserve_repeat_identity(result, previous)
        result['repeat_existing'] = True
        result['repeat_requested_at'] = meta.get('created_at')
        if verified:
            prior_path = folder / 'prior-record.json'
            # Preserve the entire prior record byte-for-byte before atomic replacement.
            # Existing run directories and evidence files are never written here.
            with prior_path.open('xb') as handle:
                handle.write(previous_bytes)
            result['previous_runs'] = copy.deepcopy(previous.get('previous_runs', [])) + [{
                'record_file': str(prior_path.relative_to(ROOT)),
                'run_dir': previous['run_dir'],
                'nohash_evidence': previous['nohash_evidence'],
                'recorded_at': previous['recorded_at'],
                'job_id': previous['job_id'],
                'promoted_at': previous['promoted_at'],
            }]
            write_json(target, result)
        else:
            result['record_updated'] = False
            result['retained_record'] = str(target.relative_to(ROOT))
            result['retained_recorded_at'] = previous['recorded_at']
            result['retained_job_id'] = previous['job_id']
            exclusive_json(folder / 'repeat-attempt.json', result)
    else:
        write_json(target, result)
    print(json.dumps({'version': version, 'status': result['status'], 'verified': verified,
                      'record_updated': not args.repeat_existing or verified,
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
    if (rec.get('kml_evidence_schema') != KML_EVIDENCE_SCHEMA
            or rec.get('actual_reference_version') != 'KML 25.1.0'
            or rec.get('actual_compiler_version') != 'GCC 12.3.1'
            or rec.get('official_kml252_revalidated') is not False):
        reasons.append(version + ': this helper requires explicit KML 25.1 / GCC 12.3.1 evidence')
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
    p.add_argument('--repeat-existing', action='store_true',
                   help='Record a fresh run of the unchanged, promoted current parent=null baseline; preserve prior evidence')
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
