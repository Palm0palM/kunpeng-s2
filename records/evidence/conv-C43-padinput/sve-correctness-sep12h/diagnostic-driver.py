"""H diagnostic transport. Preparation is inert; only explicit --go submits.

Run from the repository root. status/fetch reuse the single saved job ID.
No local operator compilation, execution, acceptance, or automatic polling.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import re
import shlex
import sys
import tarfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'tools'))
import cluster

VERSIONS = ('C43-padinput', 'C44-copyinput')
SOURCE_NAMES = {'README.md', 'bench_conv.c', 'conv2d.c', 'run.sh',
    'check_conv_guard.c', 'copy_probe.h', 'copy_probe.c',
    'instrumented_candidate.c', 'candidate.env', 'remote_job.sh'}
RESOURCES = dict(cpus=38, memory_mb=24576, numa_count=1,
    numa_distribution='pack', walltime_seconds=1800)
COUNTS = dict(configurations=6, production_per_configuration=24100,
    copy_success_per_configuration=6048, copy_failure_per_configuration=6048,
    production_cases=144600, copy_success_cases=36288, copy_failure_cases=36288,
    total_cases=217176, runner_cases=0)
TERMINAL = {'SUCCEEDED', 'FAILED', 'CANCELLED', 'CANCELED', 'TIMEOUT', 'TERMINATED'}


def require(value, why):
    if not value:
        raise ValueError(why)


def read_json(path):
    return json.loads(path.read_text())


def save(path, data):
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(path)


def serial_gate(cfg):
    """Refresh only this coordinator's current J/K/H/I/L/package identities.

    No historical or teammate-job scan. Prepared source packages without a job
    file are inert. Unknown reserved submissions block, and explicit root --go
    remains necessary even when all known computations have terminated.
    """
    identities={'1579660':['J performance'],'1579677':['K confirmation']}
    unresolved=[]
    prior_evidence=[]
    expected_prior={
        'sep12j':('1579660',['C26-r16','C40-r1','C26-r17']),
        'sep12k':('1579677',['C26-r18','C40-r2','C26-r19'])}
    for round_name,(expected_id,order) in expected_prior.items():
        campaign=ROOT/'.runs/conv'/(round_name+'-campaign.json')
        try:
            data=read_json(campaign)
            require(data.get('status')=='performance_complete' and data.get('performance_job')==expected_id and data.get('measurement_order')==order,'J/K formal completion identity mismatch')
            records=[]
            for name in order:
                rec=read_json(ROOT/'records/experiments/conv'/(name+'.json'))
                require(rec.get('status')=='passed' and rec.get('verified') is True and rec.get('repeats')==3 and rec.get('job_id')==expected_id,'J/K record not fully verified: '+name)
                run=read_json(ROOT/'.runs/conv'/name/'cluster.json')
                status=run.get('scheduler_status') or {}
                require(run.get('job_id')==expected_id and str(status.get('jobId'))==expected_id and status.get('status')=='SUCCEEDED' and status.get('jobExitCode')==status.get('systemExitCode')==0,'J/K saved terminal exits not successful: '+name)
                records.append(dict(version=name,verified=True,repeats=3,job_id=expected_id))
            prior_evidence.append(dict(round=round_name,job_id=expected_id,status='performance_complete',records=records,confirmation_passed=data.get('confirmation_passed')))
        except (ValueError,OSError,KeyError) as exc:
            unresolved.append(dict(path=str(campaign.relative_to(ROOT)),reason=str(exc)))
    paths=[BASE/name/'job.json' for name in VERSIONS]
    paths += [ROOT/'.runs/conv/sep12i-checks'/name/'job.json' for name in ('C45-row4dup4','C46-row5x5asmfix')]
    paths += [ROOT/'.runs/conv/sep12l-checks/C47-row6x4u1/job.json']
    paths += [ROOT/'.runs/conv'/name/'cluster.json' for name in (
        'C26-r16','C40-r1','C26-r17','C26-r18','C40-r2','C26-r19',
        'C40-package','C43-padinput','C44-copyinput','C45-row4dup4','C46-row5x5asmfix','C47-row6x4u1')]
    for path in paths:
        if not path.exists(): continue
        data=read_json(path)
        job_id=data.get('job_id')
        if not re.fullmatch(r'[0-9]+',str(job_id or '')):
            unresolved.append(dict(path=str(path.relative_to(ROOT)),reason='Reserved job has no reconciled numeric ID'))
            continue
        identities.setdefault(str(job_id),[]).append(str(path.relative_to(ROOT)))
    for round_name in ('sep12h','sep12i','sep12j','sep12k','sep12l'):
        path=ROOT/'.runs/conv'/(round_name+'-campaign.json')
        if not path.exists(): continue
        data=read_json(path)
        job_id=data.get('performance_job')
        if not job_id and data.get('status') in ('planned','prepared') and not data.get('submit_attempted'):
            continue
        if not re.fullmatch(r'[0-9]+',str(job_id or '')):
            unresolved.append(dict(path=str(path.relative_to(ROOT)),reason='Active/uncertain campaign lacks a numeric job ID'))
            continue
        identities.setdefault(str(job_id),[]).append(str(path.relative_to(ROOT)))
    evidence=[]
    for job_id,origins in identities.items():
        command=shlex.join(part.replace('{job_id}',job_id) for part in cfg['scheduler']['status_argv'])
        result=cluster.remote(cfg,command)
        output=cluster.output_text(result)
        status=cluster.parse_scheduler_status(output,job_id) if result.returncode==0 else None
        evidence.append(dict(job_id=job_id,origins=origins,command=command,query_exit=result.returncode,raw_status=output,scheduler=status))
    clear=not unresolved and all(row['query_exit']==0 and row['scheduler'] is not None and
        str(row['scheduler'].get('jobId'))==row['job_id'] and row['scheduler'].get('status') in TERMINAL and
        type(row['scheduler'].get('jobExitCode')) is int and type(row['scheduler'].get('systemExitCode')) is int and
        (row['job_id'] not in ('1579660','1579677') or (row['scheduler'].get('status')=='SUCCEEDED' and row['scheduler'].get('jobExitCode')==row['scheduler'].get('systemExitCode')==0)) for row in evidence)
    return dict(checked_at=datetime.now(timezone.utc).isoformat(),jobs=evidence,prior_campaigns=prior_evidence,
        unresolved_submissions=unresolved,clear=clear)


def frozen_source(base, version):
    expected = read_json(base / 'source-hashes.json')
    require(set(expected) == SOURCE_NAMES, 'Unexpected frozen transport source set')
    actual = {}
    for path in sorted((base / 'source').iterdir()):
        require(path.is_file() and not path.is_symlink(), 'Only regular source files are allowed')
        actual[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
    require(actual == expected, 'Prepared source changed; stop rather than silently rebuild the manifest')
    record = read_json(ROOT / 'records/experiments/conv' / (version + '.json'))
    require(record.get('version') == version and record.get('source_parent') == 'C26-row4loads',
        'Frozen experiment identity mismatch')
    require(record['source_hashes'] == {name:expected[name] for name in
        ('README.md','bench_conv.c','conv2d.c','run.sh')}, 'Candidate checkpoint/source mismatch')
    prepared = read_json(base / 'prepared.json')
    require(prepared.get('candidate') == version and prepared.get('total_cases_planned') == 217176
        and prepared.get('runner_cases_planned') == 0, 'Prepared diagnostic count/identity mismatch')
    return expected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('version', choices=VERSIONS)
    parser.add_argument('config', help='Verified existing cluster config; never copied into the package')
    parser.add_argument('action', choices=('gate','submit','status','fetch'))
    parser.add_argument('--go', action='store_true', help='Explicit one-shot coordinated H submission authorization')
    args = parser.parse_args()
    require(args.action == 'submit' or not args.go, '--go is valid only for submit')
    base = BASE / args.version
    manifest = base / 'job.json'
    cfg = cluster.load_config(args.config)
    require(all(cfg['scheduler'].get(k) == v for k,v in RESOURCES.items()),
        'Config must specify exactly 38 CPUs, 24576 MiB, one packed NUMA, 1800 seconds')
    require(cfg['scheduler'].get('status_argv'), 'Verified scheduler status argv required')
    if args.action == 'gate':
        gate = serial_gate(cfg)
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        save(base / ('gate-' + stamp + '.json'), gate)
        print(json.dumps(dict(known_job_evidence=gate, submit_authorized=False), indent=2))
        return
    if args.action == 'submit':
        require(args.go, 'Submission requires explicit --go from the coordinator; no automatic startup')
        require(not manifest.exists(), 'Refusing second submit of the same package; reuse/reconcile existing job.json')
        gates = serial_gate(cfg)
        gate_stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        save(base / ('gate-' + gate_stamp + '.json'), gates)
        require(gates['clear'], 'Known current CONV job active or status query incomplete; preserve gate log and stop')
        hashes = frozen_source(base, args.version)
        stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
        remote_dir = cfg['remote_root'] + '/diagnostics/conv-sep12h-' + args.version + '-' + stamp
        data = dict(version=args.version, remote_dir=remote_dir, submitted=False,
            submit_attempted=False, created_at=stamp, resources=RESOURCES,
            expected_checks=COUNTS, source_hashes=hashes, known_job_gate=gates,
            explicit_go=True, no_automatic_continuation=True)
        # Exclusive creation precedes all network activity; uncertain attempts block retry.
        with manifest.open('x') as handle:
            json.dump(data, handle, indent=2)
            handle.write('\n')
        archive = io.BytesIO()
        with tarfile.open(fileobj=archive, mode='w:gz') as target:
            for name in sorted(SOURCE_NAMES):
                target.add(base / 'source' / name, arcname=name, recursive=False)
        command = 'umask 077; mkdir -p ' + shlex.quote(remote_dir) + ' && tar -xzf - -C ' + shlex.quote(remote_dir)
        result = cluster.remote(cfg, command, input=archive.getvalue())
        (base / 'upload.log').write_text(cluster.output_text(result))
        require(result.returncode == 0, 'Upload failed; retain job.json and upload.log, do not repeat submit')
        command = cluster.submit_command(cfg, remote_dir, 'conv-sep12h-' + args.version)
        data.update(command=command, submit_attempted=True)
        save(manifest, data)
        result = cluster.remote(cfg, command)
        output = cluster.output_text(result)
        (base / 'submit.log').write_text(output)
        ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
        require(result.returncode == 0 and ids and len(set(ids)) == 1,
            'Submission uncertain; preserve submit.log and reconcile scheduler. Never resubmit this package.')
        data.update(job_id=ids[0], submitted=True)
        save(manifest, data)
        print('JOB_ID=' + data['job_id'])
        return
    data = read_json(manifest)
    job_id = data.get('job_id', '')
    require(data.get('version') == args.version and re.fullmatch(r'[0-9]+', job_id),
        'Missing/mismatched confirmed job ID; reconcile first')
    if args.action == 'status':
        command = shlex.join(part.replace('{job_id}', job_id) for part in cfg['scheduler']['status_argv'])
        result = cluster.remote(cfg, command)
        output = cluster.output_text(result)
        if result.returncode:
            stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
            (base / ('status-failed-' + stamp + '.log')).write_text(output)
            raise ValueError('Status query failed; previous successful state preserved')
        status = cluster.parse_scheduler_status(output, job_id)
        if status is None:
            stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
            (base / ('status-unparsed-' + stamp + '.log')).write_text(output)
            raise ValueError('Unparseable status; returned text retained, previous state preserved')
        (base / 'scheduler.log').write_text(output)
        data.update(scheduler_status=status, status_checked_at=datetime.now(timezone.utc).isoformat())
        save(manifest, data)
        print(json.dumps(status, indent=2))
        return
    status = data.get('scheduler_status') or {}
    require(str(status.get('jobId')) == job_id and status.get('status') in TERMINAL,
        'Fetch requires known terminal scheduler state, including failed jobs')
    result = cluster.remote(cfg, 'tar -czf - -C ' + shlex.quote(data['remote_dir']) + ' .', timeout=120)
    require(result.returncode == 0, 'Fetch failed; existing evidence preserved')
    dest = base / 'raw'
    dest.mkdir(exist_ok=True)
    allowed_suffixes = ('.c','.h','.sh','.env','.md','.log','.txt','.s','.json')
    with tarfile.open(fileobj=io.BytesIO(result.stdout), mode='r:gz') as archive:
        payload = {}
        for member in archive.getmembers():
            name = Path(member.name)
            if not member.isfile() or len(name.parts) != 1 or member.size > 16*1024*1024:
                continue
            if name.suffix not in allowed_suffixes and name.name != 'production-conv2d.o':
                continue
            require(name.name not in payload, 'Duplicate returned tar member')
            payload[name.name] = archive.extractfile(member).read()
        # Never replace already-fetched differing bytes, even after a failed job.
        for name, content in payload.items():
            path = dest / name
            require(not path.exists() or path.read_bytes() == content,
                'Fetched evidence differs; preserve existing raw file: ' + name)
        for name, content in payload.items():
            path = dest / name
            if not path.exists():
                path.write_bytes(content)
    print('Fetched immutable diagnostic evidence. Fetch is not validation; run no operator locally.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, cluster.ClusterError) as exc:
        raise SystemExit(str(exc))
