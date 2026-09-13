"""Prepared Q diagnostic transport for C51; explicit root --go only.

No work occurs on import. status/fetch reuse a saved unique job; no local
operator execution, automatic polling, acceptance, promotion or publication.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tarfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'tools'))
import cluster

VERSIONS = ('C51-row7x3u1',)
SOURCE_NAMES = {'conv2d.c', 'check_conv_guard.c', 'check_sve_dispatch.c', 'candidate.env', 'remote_job.sh'}
SOURCE_PARENTS = {'C51-row7x3u1': 'C40-row6x3u1'}
COUNTS = {'C51-row7x3u1': dict(full_per_configuration=4784, dispatch_per_configuration=972,
    direct_per_configuration=432, configurations=6, total=37128)}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
    numa_distribution='pack', walltime_seconds=1800)
STAGES = (['allocation', 'compiler', 'manifest', 'build-guard']
    + [f'guard-vl{vl}-t{threads}' for vl in (16, 32, 64) for threads in (1, 4)]
    + ['build-dispatch']
    + [f'dispatch-vl{vl}-t{threads}' for vl in (16, 32, 64) for threads in (1, 4)]
    + ['build-assembly', 'complete'])
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}
# The frozen Q wrapper builds no retained production object for separate transfer.
OBJECT_ARTIFACTS = {name: set() for name in VERSIONS}


def require(value, why):
    if not value:
        raise ValueError(why)


def read_json(path):
    return json.loads(path.read_text())


def save(path, data):
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(path)


def stamp():
    return datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')


def exception_text(exc):
    def decode(value):
        return value.decode('utf-8', errors='replace') if isinstance(value, bytes) else (value or '')
    return str(exc) + '\n' + decode(getattr(exc, 'stdout', None)) + decode(getattr(exc, 'stderr', None))


def query_scheduler(cfg, job_id, origins):
    command = shlex.join(part.replace('{job_id}', job_id) for part in cfg['scheduler']['status_argv'])
    try:
        result = cluster.remote(cfg, command, timeout=min(45, cfg['command_timeout']))
        output = cluster.output_text(result)
        status = cluster.parse_scheduler_status(output, job_id) if result.returncode == 0 else None
        return dict(job_id=job_id, origins=origins, command=command,
            query_exit=result.returncode, raw_status=output, scheduler=status)
    except (subprocess.TimeoutExpired, OSError, cluster.ClusterError) as exc:
        return dict(job_id=job_id, origins=origins, command=command,
            query_exit=None, raw_status=exception_text(exc), scheduler=None, query_error=type(exc).__name__)


def serial_gate(cfg):
    """Bounded latest N and present P/Q package jobs; no teammate scan.

    Prepared P/Q packages without job.json do not represent active jobs.
    Any actual unresolved reservation blocks. Only root is a compute submitter;
    this check is not a distributed scheduling lock and never cancels work.
    """
    identities = {}
    unresolved = []
    ignored_prepared = []
    job_paths = [ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json',
                 BASE / 'C51-row7x3u1/job.json']
    for path in job_paths:
        origin = str(path.relative_to(ROOT))
        if not path.exists():
            ignored_prepared.append(origin)
            continue
        data = read_json(path)
        job_id = data.get('job_id')
        if not re.fullmatch(r'[0-9]+', str(job_id or '')):
            unresolved.append(dict(path=origin, reason='Actual package reservation lacks reconciled job ID'))
            continue
        identities.setdefault(str(job_id), []).append(origin)
    path = ROOT / '.runs/conv/sep12n-campaign.json'
    origin = str(path.relative_to(ROOT))
    if not path.exists():
        unresolved.append(dict(path=origin, reason='Required latest N campaign evidence is missing'))
    else:
        job_id = read_json(path).get('performance_job')
        if str(job_id) != '1581459':
            unresolved.append(dict(path=origin, reason='N campaign differs from reviewed completed job1581459'))
        else:
            identities.setdefault(str(job_id), []).append(origin)
    evidence = [query_scheduler(cfg, job_id, origins) for job_id, origins in identities.items()]
    clear = not unresolved and all(
        row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), jobs=evidence,
        unresolved_submissions=unresolved,
        ignored_packages_without_job_reservations=ignored_prepared, clear=clear)


def frozen_source(base, version):
    expected = read_json(base / 'source-hashes.json')
    require(set(expected) == SOURCE_NAMES, 'Unexpected frozen transport source set')
    source = base / 'source'
    require(source.is_dir() and not source.is_symlink(), 'Source must be a real directory')
    actual = {}
    sizes = {}
    for path in sorted(source.iterdir()):
        require(path.is_file() and not path.is_symlink(), 'Only regular source files are allowed')
        content = path.read_bytes()
        actual[path.name] = hashlib.sha256(content).hexdigest()
        sizes[path.name] = len(content)
    require(actual == expected, 'Prepared source changed; never silently refresh its frozen manifest')
    extra_manifest = base / 'source-manifest.json'
    require(extra_manifest.is_file() and not extra_manifest.is_symlink(),
        'Frozen Q bytes/SHA source-manifest.json is required')
    require(read_json(extra_manifest) == {name: dict(bytes=sizes[name], sha256=actual[name]) for name in actual},
        'Supplementary bytes/SHA manifest mismatch')
    record = read_json(ROOT / 'records/experiments/conv' / (version + '.json'))
    require(record.get('version') == version and record.get('source_parent') == SOURCE_PARENTS[version],
        'Candidate checkpoint identity mismatch')
    require(record['source_hashes']['conv2d.c'] == expected['conv2d.c'], 'Candidate checkpoint/source mismatch')
    candidate_source = ROOT / '.runs/conv' / version / 'source/conv2d.c'
    require(hashlib.sha256(candidate_source.read_bytes()).hexdigest() == expected['conv2d.c'],
        'Candidate production source differs from the frozen diagnostic copy')
    prepared = read_json(base / 'prepared.json')
    counts = COUNTS[version]
    require(prepared.get('candidate') == prepared.get('source_experiment') == version
        and prepared.get('source_parent') == SOURCE_PARENTS[version], 'Prepared candidate identity mismatch')
    require(prepared.get('source_hashes') == expected and prepared.get('source_sha256') == expected['conv2d.c'],
        'Prepared source identity mismatch')
    require(prepared.get('status') == 'prepared' and prepared.get('compiled') is False
        and prepared.get('executed') is False and prepared.get('verified') is False, 'Expected initial prepared metadata')
    require(prepared.get('configurations') == 6 and prepared.get('sve_bytes') == [16, 32, 64]
        and prepared.get('threads') == [1, 4], 'Prepared VL/thread matrix mismatch')
    require(prepared.get('full_cases_per_configuration') == counts['full_per_configuration']
        and prepared.get('dispatch_cases_per_configuration') == counts['dispatch_per_configuration']
        and prepared.get('direct_cases_per_configuration', 0) == counts['direct_per_configuration']
        and prepared.get('total_cases_planned') == counts['total']
        and prepared.get('runner_cases_planned') == 0, 'Prepared planned counts mismatch')
    for field, per_field in (('full_cases', 'full_per_configuration'),
                            ('dispatch_cases', 'dispatch_per_configuration'),
                            ('direct_cases', 'direct_per_configuration')):
        require(prepared.get(field, 0) == counts[per_field] * 6, 'Prepared total mismatch: ' + field)
    require(prepared.get('expected_stages') == STAGES and prepared.get('expected_compiler_version') == '10.3.1',
        'Prepared stage/compiler expectations mismatch')
    require(prepared.get('resources_required') == {key: value for key, value in RESOURCES.items() if key != 'walltime_seconds'},
        'Prepared resource expectations mismatch')
    require(prepared.get('expected_acc') == 3 and prepared.get('expected_checks') == counts,
        'Q matrix schema mismatch')
    require(prepared.get('rows_per_group') == 7 and prepared.get('vectors_per_row') == 3
        and prepared.get('accumulators') == 21, 'C51 seven-row/three-vector shape mismatch')
    require(prepared.get('expected_rowseven_entries') == dict(dispatch_per_configuration=756, direct_per_configuration=1080),
        'Rowseven entry expectations mismatch')
    require(prepared.get('full_matrix_counts') == dict(core=3888, narrow=144, small=720, larger=32)
        and prepared.get('expected_worker_masks') == {'1': 1, '4': 15}, 'Full-matrix/worker expectations mismatch')
    return expected


def logged_remote(cfg, command, log_path, **kwargs):
    try:
        result = cluster.remote(cfg, command, **kwargs)
    except (subprocess.TimeoutExpired, OSError, cluster.ClusterError) as exc:
        log_path.write_text(exception_text(exc))
        raise ValueError('Remote operation uncertain; preserve ' + str(log_path) + ' and reconcile without resubmission') from exc
    log_path.write_text(cluster.output_text(result))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('version', choices=VERSIONS)
    parser.add_argument('config', help='Verified existing config; read only, never included in source or archive')
    parser.add_argument('action', choices=('gate', 'submit', 'status', 'fetch'))
    parser.add_argument('--go', action='store_true', help='Explicit one-shot root Q submission authorization')
    args = parser.parse_args()
    require(args.action == 'submit' or not args.go, '--go is valid only for submit')
    base = BASE / args.version
    manifest = base / 'job.json'
    cfg = cluster.load_config(args.config)
    require(all(cfg['scheduler'].get(key) == value for key, value in RESOURCES.items()),
        'Config must specify38 CPUs,24576 MiB,one packed NUMA,1800 seconds')
    require(cfg['scheduler'].get('status_argv'), 'Verified scheduler status argv required')
    if args.action == 'gate':
        gate = serial_gate(cfg)
        save(base / ('gate-' + stamp() + '.json'), gate)
        print(json.dumps(dict(known_job_evidence=gate, submit_authorized=False), indent=2))
        return
    if args.action == 'submit':
        require(args.go, 'Explicit root --go required; no automatic startup')
        require(not manifest.exists(), 'Refusing second submit; reconcile/reuse this package job.json')
        gate = serial_gate(cfg)
        save(base / ('gate-' + stamp() + '.json'), gate)
        require(gate['clear'], 'Known CONV work active/unresolved or query incomplete; retain gate evidence and stop')
        hashes = frozen_source(base, args.version)
        created = stamp()
        remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep13q-' + args.version + '-' + created
        data = dict(version=args.version, remote_dir=remote_dir, submitted=False,
            submit_attempted=False, created_at=created, resources=RESOURCES,
            expected_checks=COUNTS[args.version], expected_stages=STAGES,
            source_hashes=hashes, known_job_gate=gate, explicit_go=True, no_automatic_continuation=True)
        # Per-package exclusive reservation precedes upload/submission. It is retained on any failure.
        with manifest.open('x') as handle:
            json.dump(data, handle, indent=2)
            handle.write('\n')
        archive = io.BytesIO()
        with tarfile.open(fileobj=archive, mode='w:gz') as target:
            for name in sorted(SOURCE_NAMES):
                target.add(base / 'source' / name, arcname=name, recursive=False)
        command = 'umask 077; mkdir -p ' + shlex.quote(remote_dir) + ' && tar -xzf - -C ' + shlex.quote(remote_dir)
        result = logged_remote(cfg, command, base / 'upload.log', input=archive.getvalue(), timeout=cfg['transfer_timeout'])
        require(result.returncode == 0, 'Upload failed; keep reservation/log and do not resubmit')
        command = cluster.submit_command(cfg, remote_dir, 'conv-sep13q-' + args.version)
        data.update(command=command, submit_attempted=True)
        save(manifest, data)
        result = logged_remote(cfg, command, base / 'submit.log')
        ids = re.findall(cfg['scheduler']['job_id_pattern'], cluster.output_text(result))
        require(result.returncode == 0 and ids and len(set(ids)) == 1,
            'Uncertain scheduler submission; preserve submit.log and reconcile, never repeat submit')
        data.update(job_id=ids[0], submitted=True)
        save(manifest, data)
        print('JOB_ID=' + data['job_id'])
        return
    data = read_json(manifest)
    job_id = str(data.get('job_id', ''))
    require(data.get('version') == args.version and re.fullmatch(r'[0-9]+', job_id),
        'Missing/mismatched confirmed job ID; reconcile before status or fetch')
    require(data.get('resources') == RESOURCES and data.get('source_hashes') == read_json(base / 'source-hashes.json'),
        'Saved job resource/source association mismatch')
    if args.action == 'status':
        row = query_scheduler(cfg, job_id, [str(manifest.relative_to(ROOT))])
        if row['query_exit'] != 0 or row['scheduler'] is None:
            save(base / ('status-failed-' + stamp() + '.json'), row)
            raise ValueError('Status query failed/unparsed; retain returned evidence and previous successful state')
        (base / 'scheduler.log').write_text(row['raw_status'])
        data.update(scheduler_status=row['scheduler'], status_checked_at=datetime.now(timezone.utc).isoformat())
        save(manifest, data)
        print(json.dumps(row['scheduler'], indent=2))
        return
    status = data.get('scheduler_status') or {}
    require(str(status.get('jobId')) == job_id and status.get('status') in TERMINAL
        and type(status.get('jobExitCode')) is int and type(status.get('systemExitCode')) is int,
        'Fetch requires a known terminal job, including actual failed jobs and both exit codes')
    try:
        result = cluster.remote(cfg, 'tar -czf - -C ' + shlex.quote(data['remote_dir']) + ' .', timeout=cfg['transfer_timeout'])
    except (subprocess.TimeoutExpired, OSError, cluster.ClusterError) as exc:
        (base / ('fetch-failed-' + stamp() + '.log')).write_text(str(exc))
        raise ValueError('Fetch uncertain; existing raw evidence preserved') from exc
    if result.returncode != 0:
        stderr = result.stderr.decode('utf-8', errors='replace') if isinstance(result.stderr, bytes) else str(result.stderr or '')
        (base / ('fetch-failed-' + stamp() + '.log')).write_text(stderr)
        raise ValueError('Fetch failed; existing raw evidence preserved')
    dest = base / 'raw'
    require(not dest.is_symlink(), 'Returned evidence directory must not be a symlink')
    allowed_suffixes = {'.c', '.h', '.sh', '.env', '.md', '.log', '.txt', '.s', '.json'}
    with tarfile.open(fileobj=io.BytesIO(result.stdout), mode='r:gz') as archive:
        payload = {}
        for member in archive.getmembers():
            name = Path(member.name)
            if not member.isfile() or len(name.parts) != 1 or member.size > 16 * 1024 * 1024:
                continue
            if name.suffix not in allowed_suffixes and name.name not in OBJECT_ARTIFACTS[args.version]:
                continue
            require(name.name not in payload, 'Duplicate returned tar member')
            payload[name.name] = archive.extractfile(member).read()
        require(payload, 'No allowed diagnostic evidence returned')
        # Validate every returned member before the first write; never replace differing bytes.
        for name, content in payload.items():
            path = dest / name
            require(not path.is_symlink() and (not path.exists() or path.read_bytes() == content),
                'Fetched evidence differs or is unsafe; preserve raw file: ' + name)
        dest.mkdir(exist_ok=True)
        for name, content in payload.items():
            path = dest / name
            if not path.exists():
                path.write_bytes(content)
    print('Fetched immutable Q diagnostic text/assembly. Fetch is not acceptance or performance.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, tarfile.TarError, cluster.ClusterError) as exc:
        raise SystemExit(str(exc))
