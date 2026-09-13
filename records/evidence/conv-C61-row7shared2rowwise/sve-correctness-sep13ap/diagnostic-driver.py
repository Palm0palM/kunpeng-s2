"""Prepared AP diagnostic transport for C61; explicit root --go only.

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

VERSIONS = ('C61-row7shared2rowwise',)
SOURCE_SHA256 = '40a3184f346983864593de73b3e3ade7973b1af9d2d273d566432e882a6904fa'
SOURCE_NAMES = {'conv2d.c', 'check_conv_guard.c', 'check_sve_dispatch.c', 'candidate.env', 'remote_job.sh'}
SOURCE_PARENTS = {'C61-row7shared2rowwise': 'C58-r1'}
AO_JOB_ID = '1589611'
PARENT_SHA256 = 'c8d3fb6dc2a3b02ba509b029efe802dc1ec37430467642d23d5815f6beaea751'
PRODUCTION_NAMES = {'conv2d.c', 'README.md', 'bench_conv.c', 'run.sh'}
COUNTS = {'C61-row7shared2rowwise': dict(full_per_configuration=5744, dispatch_per_configuration=1212,
    direct_per_configuration=432, configurations=6, total=44328)}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
    numa_distribution='pack', walltime_seconds=1800)
STAGES = (['allocation', 'compiler', 'manifest', 'build-guard']
    + [f'guard-vl{vl}-t{threads}' for vl in (16, 32, 64) for threads in (1, 4)]
    + ['build-dispatch']
    + [f'dispatch-vl{vl}-t{threads}' for vl in (16, 32, 64) for threads in (1, 4)]
    + ['build-assembly', 'complete'])
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}
# The frozen AP wrapper builds no retained production object for separate transfer.
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


def completed_ao_evidence():
    path = ROOT / '.runs/conv/sep13ao-campaign.json'
    campaign = read_json(path)
    order = ['C58-r4', 'C60-row7shared2ext', 'C58-r5']
    require(campaign.get('performance_job') == AO_JOB_ID and campaign.get('status') == 'complete'
        and campaign.get('measurement_order') == order and campaign.get('expected_benchmark_cases') == 36,
        'Original AO must be completely recorded')
    rows = campaign.get('results', [])
    require([r.get('version') for r in rows] == order
        and all(len(r.get('cases', [])) == 4 and all(len(c.get('times_ms', [])) == 3 for c in r['cases']) for r in rows),
        'Original AO all36 samples required')
    return dict(path=str(path.relative_to(ROOT)), job_id=AO_JOB_ID, expected_samples=36, read_only=True)


def serial_gate(cfg):
    identities = {AO_JOB_ID: ['.runs/conv/sep13ao-campaign.json']}
    unresolved = []
    try:
        completed_ao_evidence()
    except (ValueError, OSError, KeyError) as exc:
        unresolved.append(str(exc))
    path = BASE / VERSIONS[0] / 'job.json'
    if path.exists():
        data = read_json(path); job_id = str(data.get('job_id') or '')
        if data.get('version') != VERSIONS[0] or not re.fullmatch(r'[0-9]+', job_id):
            unresolved.append('Original AP reservation unknown; reconcile without resubmission')
        else:
            identities.setdefault(job_id, []).append(str(path.relative_to(ROOT)))
    evidence = [query_scheduler(cfg, job_id, origins) for job_id, origins in identities.items()]
    clear = not unresolved and all(row['query_exit'] == 0 and row['scheduler'] is not None
        and str(row['scheduler'].get('jobId')) == row['job_id']
        and row['scheduler'].get('status') in TERMINAL
        and type(row['scheduler'].get('jobExitCode')) is int
        and type(row['scheduler'].get('systemExitCode')) is int for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(), jobs=evidence,
        unresolved_submissions=unresolved, clear=clear)


def frozen_source(base, version):
    expected = read_json(base / 'source-hashes.json')
    require(set(expected) == SOURCE_NAMES and expected['conv2d.c'] == SOURCE_SHA256, 'Own C61 transport identity')
    source = base / 'source'
    require(source.is_dir() and not source.is_symlink(), 'Real source directory required')
    actual, manifest = {}, {}
    for path in source.iterdir():
        require(path.is_file() and not path.is_symlink(), 'Only regular source files')
        content = path.read_bytes(); actual[path.name] = hashlib.sha256(content).hexdigest()
        manifest[path.name] = dict(bytes=len(content), sha256=actual[path.name])
    require(actual == expected and read_json(base / 'source-manifest.json') == manifest, 'Frozen five-file bytes changed')
    record = read_json(ROOT / 'records/experiments/conv' / (version + '.json'))
    require(record.get('version') == version and record.get('source_parent', record.get('parent')) == 'C58-r1'
        and record.get('status') == 'prepared' and record.get('verified') is False, 'Unmeasured C61 checkpoint')
    production = ROOT / '.runs/conv' / version / 'source'
    require({p.name for p in production.iterdir()} == PRODUCTION_NAMES, 'Four production files')
    hashes = {n: hashlib.sha256((production / n).read_bytes()).hexdigest() for n in PRODUCTION_NAMES}
    require(hashes == record['source_hashes'] and hashes['conv2d.c'] == SOURCE_SHA256, 'Current checkpoint/production bytes')
    parent = read_json(ROOT / 'records/experiments/conv/C58-r1.json')
    require(read_json(ROOT / 'outputs/conv-best.json')['label'] == 'C7'
        and read_json(ROOT / 'records/best.json')['conv'] == 'C58-r1'
        and parent.get('confirmation_passed') is True and parent.get('verified') is True, 'Current confirmed C7')
    parent_hashes = {n: hashlib.sha256((ROOT / '.runs/conv/C58-r1/source' / n).read_bytes()).hexdigest() for n in PRODUCTION_NAMES}
    current = {n: hashlib.sha256((ROOT / 'conv' / n).read_bytes()).hexdigest() for n in PRODUCTION_NAMES}
    require(parent_hashes == current == parent['source_hashes'] and current['conv2d.c'] == PARENT_SHA256, 'Confirmed parent/current source')
    require(all(hashes[n] == current[n] for n in PRODUCTION_NAMES if n != 'conv2d.c'), 'Official companion files unchanged')
    prepared = read_json(base / 'prepared.json')
    require(prepared['candidate'] == version and prepared['source_parent'] == 'C58-r1'
        and prepared['source_hashes'] == expected and prepared['production_source_hashes'] == hashes
        and prepared['expected_checks'] == COUNTS[version] and prepared['expected_stages'] == STAGES
        and prepared['compiled'] is False and prepared['executed'] is False and prepared['verified'] is False,
        'Own initial prepared metadata')
    creation = read_json(ROOT / '.runs/conv' / version / 'creation-experiment-original.json')
    require(creation['problem'] == 'conv' and creation['version'] == version and creation['parent'] == 'C58-r1'
        and creation['created_at'] == record['created_at'], 'Original creation identity; extended metadata may differ')
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
    parser.add_argument('--go', action='store_true', help='Explicit one-shot root AP submission authorization')
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
        ao_evidence = completed_ao_evidence()
        gate = serial_gate(cfg)
        save(base / ('gate-' + stamp() + '.json'), gate)
        require(gate['clear'], 'Known CONV work active/unresolved or query incomplete; retain gate evidence and stop')
        hashes = frozen_source(base, args.version)
        created = stamp()
        remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep13ap-' + args.version + '-' + created
        data = dict(version=args.version, remote_dir=remote_dir, submitted=False,
            submit_attempted=False, created_at=created, resources=RESOURCES,
            expected_checks=COUNTS[args.version], expected_stages=STAGES,
            source_hashes=hashes, known_job_gate=gate, completed_ao_evidence=ao_evidence, explicit_go=True, no_automatic_continuation=True)
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
        command = cluster.submit_command(cfg, remote_dir, 'conv-sep13ap-' + args.version)
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
    print('Fetched immutable AP diagnostic text/assembly. Fetch is not acceptance or performance.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, tarfile.TarError, cluster.ClusterError) as exc:
        raise SystemExit(str(exc))
