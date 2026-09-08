#!/usr/bin/env python3
"""Run immutable candidates sequentially in one allocation for matched CPU/NUMA.

Each member keeps its own wrapper, source hashes, logs and exit status. The
group fails if any member fails; normal cluster.py status/fetch still apply.
"""
import argparse
import json
from pathlib import Path
import re
import shlex
import shutil
import tempfile
from uuid import uuid4

import cluster as c


def group_script(directories):
    return ('#!/usr/bin/env bash\nset -uo pipefail\nfailed=0\n' +
            ''.join('/bin/bash -l ' + shlex.quote(d + '/remote_job.sh') +
                    ' || failed=1\n' for d in directories) +
            'exit "$failed"\n')


def submit_group(cfg, runs):
    if len(runs) < 2 or len(set(runs)) != len(runs):
        raise c.ClusterError('Need at least two distinct run directories')
    plans = []
    token = uuid4().hex[:12]
    name = 'kp-conv-group-' + token
    remote_group = cfg['remote_root'] + '/' + name
    for index, run in enumerate(runs):
        if (run / 'cluster.json').exists():
            raise c.ClusterError('Already submitted: ' + run.name)
        experiment = c.read_json(run / 'experiment.json')
        if experiment.get('problem') != 'conv':
            raise c.ClusterError('This grouped runner currently supports CONV only')
        hashes = c.source_hashes(run / 'source')
        settings = c.effective_settings(cfg, experiment)
        manifest = dict(state='preparing', created_at=c.now(),
                        remote_dir=remote_group + '/member-' + str(index),
                        host=cfg['host'], user=cfg.get('user', ''), port=cfg['port'],
                        settings=settings, source_hashes=hashes, job_id=None,
                        group=name, group_index=index,
                        measurement_order=[p.name for p in runs])
        plans.append((run, manifest))
    # Reserve every local member before any network operation; never auto-retry.
    for run, manifest in plans:
        with (run / 'cluster.json').open('x') as out:
            json.dump(manifest, out, indent=2)
    try:
        made = c.remote(cfg, shlex.join(['mkdir', remote_group]))
        if made.returncode:
            raise c.ClusterError('Could not create unique remote group')
        for run, manifest in plans:
            with tempfile.TemporaryDirectory(prefix='kp-group-upload-') as tmp:
                tmp = Path(tmp)
                shutil.copytree(run / 'source', tmp / 'source', symlinks=True)
                hashes = c.source_hashes(tmp / 'source')
                manifest['source_hashes'] = hashes
                c.write_json(run / 'cluster.json', manifest)
                archive = tmp / 'payload.tar.gz'
                c.archive_source(tmp, hashes, manifest['settings'], archive)
                command = (shlex.join(['mkdir', manifest['remote_dir']]) + ' && ' +
                           shlex.join(['tar', '-xzf', '-', '-C', manifest['remote_dir']]))
                with archive.open('rb') as data:
                    result = c.remote(cfg, command, stdin=data, timeout=cfg['transfer_timeout'])
                (run / 'upload.log').write_text(c.output_text(result))
                if result.returncode:
                    raise c.ClusterError('Group upload failed before submission')
        script = group_script([m['remote_dir'] for _, m in plans])
        command = 'cat > ' + shlex.quote(remote_group + '/remote_job.sh')
        result = c.remote(cfg, command, input=script.encode())
        if result.returncode:
            raise c.ClusterError('Group script upload failed before submission')
        submit_command = c.submit_command(cfg, remote_group, name)
        for run, manifest in plans:
            manifest.update(state='submit_unknown', submission_started_at=c.now(),
                            submit_command=submit_command)
            c.write_json(run / 'cluster.json', manifest)
        result = c.remote(cfg, submit_command)
        output = c.output_text(result)
        for run, _ in plans:
            (run / 'submit.log').write_text(output)
        ids = re.findall(cfg['scheduler']['job_id_pattern'], output)
        if result.returncode or len(set(ids)) != 1 or not ids or not ids[0].isdigit():
            raise c.ClusterError('Submission outcome uncertain; inspect logs, do not resubmit')
        for run, manifest in plans:
            manifest.update(state='submitted', job_id=ids[0], submitted_at=c.now())
            c.write_json(run / 'cluster.json', manifest)
        print('Submitted group job ' + ids[0] + ': ' + ', '.join(p.name for p in runs))
    except Exception as exc:
        for run, manifest in plans:
            if manifest['state'] == 'preparing':
                manifest['state'] = 'upload_failed'
            manifest['error'] = str(exc)
            c.write_json(run / 'cluster.json', manifest)
        raise


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, default=c.ROOT / 'config/cluster.local.json')
    parser.add_argument('runs', type=Path, nargs='+')
    args = parser.parse_args()
    submit_group(c.load_config(args.config), [p.resolve() for p in args.runs])
