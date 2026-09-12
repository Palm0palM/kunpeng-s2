"""Prepared AG explicit-FMA feasibility transport for C57; explicit root --go only.

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

VERSIONS = ('C57-row7shared2fma',)
SOURCE_SHA256 = '3cc03ec4d13422238b1e461dd7213876cc50283a7433132ee94b41c4724ec6c5'
SOURCE_NAMES = {'conv2d.c', 'bench_conv.c', 'run.sh', 'README.md', 'remote_job.sh'}
SOURCE_PARENTS = {'C57-row7shared2fma': 'C52-row7x3shared2'}
COUNTS = {'C57-row7shared2fma': dict(official_cases_per_suite=4, suites=3, total=12)}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
    numa_distribution='pack', walltime_seconds=1800)
STAGES = ['allocation', 'compiler', 'manifest', 'build', 'assembly-candidate',
    'assembly-reference', 'numerical-check', 'complete']
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}
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
    """Only original AF, AE1583102 and present P reservation; no peer scan."""
    af_path = ROOT / '.runs/conv/sep13af-campaign.json'
    af = read_json(af_path)
    require(af.get('status') == 'performance_complete', 'Original AF must be fully recorded first')
    af_id = str(af.get('performance_job') or '')
    require(re.fullmatch(r'[0-9]+', af_id), 'Missing reconciled AF job ID')
    group = af.get('performance_group')
    require(isinstance(group, str) and re.fullmatch(r'kp-conv-group-[0-9a-f]+', group),
        'Missing or malformed original AF group')
    require(af.get('measurement_order') == ['C26-r34', 'C56-row7shared3fence', 'C55-r1', 'C26-r35'],
        'Unexpected AF original member order')
    for version in af['measurement_order']:
        member = read_json(ROOT / '.runs/conv' / version / 'cluster.json')
        require(str(member.get('job_id')) == af_id and member.get('group') == group,
            'AF member association differs from original campaign')
    ae_path = ROOT / '.runs/conv/sep13ae-checks/C56-row7shared3fence/job.json'
    require(str(read_json(ae_path).get('job_id')) == '1583102', 'Original AE job identity changed')
    identities = {af_id: [str(af_path.relative_to(ROOT))], '1583102': [str(ae_path.relative_to(ROOT))]}
    p = ROOT / '.runs/conv/sep13p-checks/C50-row4dupfencenomem/job.json'
    if p.exists():
        job_id = str(read_json(p).get('job_id') or '')
        require(re.fullmatch(r'[0-9]+', job_id), 'Unreconciled P reservation')
        identities.setdefault(job_id, []).append(str(p.relative_to(ROOT)))
    evidence = [query_scheduler(cfg, job_id, origins) for job_id, origins in identities.items()]
    clear = all(row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), jobs=evidence, clear=clear)


def frozen_source(base, version):
    expected = read_json(base / 'source-hashes.json')
    require(set(expected) == SOURCE_NAMES, 'Unexpected AG transport file set')
    require(expected['conv2d.c'] == SOURCE_SHA256, 'AG fixed source mismatch')
    require(expected['bench_conv.c'] == '2548861ae7e29826e454b4c0b098d682f7f04996222e664cd1ea9bc92dd2e927',
        'Original official benchmark changed')
    source = base / 'source'
    require(source.is_dir() and not source.is_symlink(), 'Expected actual source directory')
    actual, sizes = {}, {}
    for path in source.iterdir():
        require(path.is_file() and not path.is_symlink(), 'Source must contain only regular files')
        content = path.read_bytes()
        actual[path.name] = hashlib.sha256(content).hexdigest()
        sizes[path.name] = len(content)
    require(actual == expected, 'First source manifest changed; do not silently refresh')
    require(read_json(base / 'source-manifest.json') == {
        name: dict(bytes=sizes[name], sha256=actual[name]) for name in actual}, 'Bytes manifest mismatch')
    record = read_json(ROOT / 'records/experiments/conv' / (version + '.json'))
    require(record['version'] == version and record.get('source_parent', record.get('parent')) == SOURCE_PARENTS[version],
        'Candidate source parent mismatch')
    require(record['source_hashes'] == {name: actual[name] for name in SOURCE_NAMES - {'remote_job.sh'}},
        'Candidate checkpoint and transport source differ')
    for name in SOURCE_NAMES - {'remote_job.sh'}:
        require((ROOT / '.runs/conv' / version / 'source' / name).read_bytes() == (source / name).read_bytes(),
            'Production candidate changed after first transport copy')
    prepared = read_json(base / 'prepared.json')
    require(prepared.get('candidate') == version and prepared.get('source_hashes') == expected,
        'Initial preparation identity mismatch')
    require(prepared.get('expected_checks') == COUNTS[version] and prepared.get('expected_stages') == STAGES,
        'Predetermined official suite/stage contract changed')
    require(prepared.get('compiled') is False and prepared.get('executed') is False
        and prepared.get('verified') is False and prepared.get('actual_job_id') is None,
        'Initial preparation metadata must remain initial')
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
    parser.add_argument('--go', action='store_true', help='Explicit one-shot root AG submission authorization')
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
        remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep13ag-' + args.version + '-' + created
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
        command = cluster.submit_command(cfg, remote_dir, 'conv-sep13ag-' + args.version)
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
    print('Fetched immutable AG diagnostic text/assembly. Fetch is not acceptance or performance.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, tarfile.TarError, cluster.ClusterError) as exc:
        raise SystemExit(str(exc))
