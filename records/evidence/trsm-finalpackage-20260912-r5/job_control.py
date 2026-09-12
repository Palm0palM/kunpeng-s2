#!/usr/bin/env python3
"""TRSM-only source-ZIP KML 25.1 verification controller, no digest operations."""
from pathlib import Path
import json,sys,shlex,shutil,tarfile,uuid,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import cluster
cfg=cluster.load_config(ROOT/'.runs/trsm/optimization-20260912-r5/cluster.local.json')
meta=HERE/'submission.json'
if sys.argv[1:]==['prepare']:
    package=cluster.read_json(ROOT/'outputs/trsm-best.json')
    group='trsm-kml251-'+uuid.uuid4().hex[:12]
    info=dict(state='preparing',cohort_id=group,job_id=None,remote_dir=cfg['remote_root']+'/'+group,source_version=package['version'],created_at=cluster.now(),reference='KML 25.1.0; not specified KML 25.2.0',hash_validation='not performed at user request')
    with meta.open('x') as f:json.dump(info,f,indent=2)
    payload=HERE/'payload';payload.mkdir()
    shutil.copy2(ROOT/'outputs/trsm-best.zip',payload/'trsm.zip')
    for name in ['probe.sh','run-three-suites.sh','target-environment.sh','required-symbols.c','audit-dependencies.py']:
        shutil.copy2(HERE/name,payload/name)
    (payload/'remote_job.sh').write_text('''#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir unpacked
unzip -q trsm.zip -d unpacked
# Use the supplied HPCKit compiler in this private job directory only.
compiler_archive=/opt/donaudata/donau/HPCKit_25.1.0_Linux-aarch64/package/gcc-12.3.1-2025.03-aarch64-linux.tar.gz
[[ -f "$compiler_archive" ]]
source ./target-environment.sh
compiler_exe=/CLUSTER_USER_HOME/kunpeng-experiments/trsm-kml251-f6110e522b93/compiler-private/gcc-12.3.1-2025.03-aarch64-linux/bin/gcc
if [[ ! -x "$compiler_exe" ]]; then
    mkdir compiler-private
    tar -xzf "$compiler_archive" -C compiler-private
    compiler_exe=$(find "$PWD/compiler-private" -path '*/bin/gcc' -print -quit)
fi
[[ -n "$compiler_exe" && -x "$compiler_exe" ]]
compiler_bin=$(dirname "$compiler_exe")
compiler_root=$(dirname "$compiler_bin")
export PATH="$compiler_bin:$PATH"
export LIBRARY_PATH="$compiler_root/lib64:$compiler_root/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export LD_LIBRARY_PATH="$compiler_root/lib64:$compiler_root/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
{ gcc --version; gcc -print-file-name=libgomp.so.1; } > compiler-environment.log 2>&1
readelf --dyn-syms --wide "$compiler_root/lib64/libgomp.so.1" | grep omp_get_supported_active_levels > omp-runtime-symbol.log
exec bash ./run-three-suites.sh ./unpacked/trsm ./results
''')
    with tarfile.open(HERE/'payload.tar.gz','w:gz') as tar:
        for p in sorted(payload.iterdir()):tar.add(p,arcname=p.name)
    info['state']='prepared';cluster.write_json(meta,info)
    print('Prepared',group)
elif sys.argv[1:]==['submit']:
    info=cluster.read_json(meta)
    if info['state']!='prepared':raise RuntimeError('Submission already attempted; do not repeat')
    cmd=shlex.join(['mkdir',info['remote_dir']])+' && '+shlex.join(['tar','-xzf','-','-C',info['remote_dir']])
    info.update(state='uploading',upload_command=cmd);cluster.write_json(meta,info)
    with (HERE/'payload.tar.gz').open('rb') as f:r=cluster.remote(cfg,cmd,stdin=f,timeout=cfg['transfer_timeout'])
    (HERE/'upload.log').write_text(cluster.output_text(r))
    if r.returncode:raise RuntimeError('Upload failed')
    cmd=cluster.submit_command(cfg,info['remote_dir'],info['cohort_id'])
    info.update(state='submit_unknown',submit_command=cmd);cluster.write_json(meta,info)
    r=cluster.remote(cfg,cmd);output=cluster.output_text(r);(HERE/'submit.log').write_text(output)
    ids=re.findall(cfg['scheduler']['job_id_pattern'],output)
    if r.returncode or len(set(ids))!=1:raise RuntimeError('Submission uncertain; inspect saved log, never resubmit')
    info.update(state='submitted',job_id=ids[0],submitted_at=cluster.now());cluster.write_json(meta,info)
    print('Submitted KML 25.1 verification',ids[0])
elif sys.argv[1:]==['collect']:
    import experiment
    info=cluster.read_json(meta);r=cluster.remote(cfg,'djob -ll '+info['job_id'])
    (HERE/'scheduler-status.txt').write_bytes(r.stdout+r.stderr)
    if r.returncode or not experiment.scheduler_ok(cluster.output_text(r)):raise RuntimeError('Job has not succeeded')
    for remote in ['benchmark.log','environment.log','exit-code.txt','probe.log','probe-ldd.log','benchmark-ldd-1.log','benchmark-ldd-2.log','benchmark-ldd-3.log','compiler-environment.log','omp-runtime-symbol.log','wrapper.stdout.log']:
        location=remote if remote in ['wrapper.stdout.log','compiler-environment.log','omp-runtime-symbol.log'] else 'results/'+remote
        r=cluster.remote(cfg,'cat '+shlex.quote(info['remote_dir']+'/'+location))
        if r.returncode:raise RuntimeError('Download failed: '+remote)
        (HERE/remote).write_bytes(r.stdout)
    if (HERE/'exit-code.txt').read_text().strip()!='0':raise RuntimeError('Wrapper did not succeed')
    result=experiment.parse_log('trsm',(HERE/'benchmark.log').read_text(),3)
    result.update(job_id=info['job_id'],source_version=info['source_version'],package_extracted_and_tested=True,reference=info['reference'],recorded_at=cluster.now(),hash_validation=info['hash_validation'])
    cluster.write_json(HERE/'result.json',result)
    print(json.dumps(result,ensure_ascii=False,indent=2))
else:raise SystemExit('Use prepare, submit or collect')
