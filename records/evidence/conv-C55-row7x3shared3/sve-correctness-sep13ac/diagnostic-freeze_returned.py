"""Atomically freeze AC evidence; local file copying/text inspection only.

Usage: python3 .runs/conv/sep13ac-checks/freeze_returned.py VERSION [--failed]
This does not run acceptance, compile, test, submit, poll, SSH or publish.
Original metadata/source/raw files are copied unchanged. Existing destination
or staging trees are never removed or overwritten, including failed freezes.
"""
import argparse
from datetime import datetime, timezone
import fcntl
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys

sys.dont_write_bytecode = True
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
VERSIONS=('C55-row7x3shared3',)
EXPECTED={'C55-row7x3shared3':dict(full=5744,dispatch=1212,direct=432,total=44328)}
SOURCE_SHA256='cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138'
SOURCE_NAMES={'conv2d.c','check_conv_guard.c','check_sve_dispatch.c','remote_job.sh','candidate.env'}
TERMINAL={'SUCCEEDED','FAILED','CANCELLED','CANCELED','TIMEOUT','TERMINATED'}
ATTACHMENTS={
    'driver.py':'diagnostic-driver.py',
    'accept_returned.py':'diagnostic-accept_returned.py',
    'freeze_returned.py':'diagnostic-freeze_returned.py',
    'INTERFACE.md':'diagnostic-INTERFACE.md',
}


def require(value, why):
    if not value:
        raise ValueError(why)


def exists(path):
    return path.exists() or path.is_symlink()


def read_json(path):
    return json.loads(path.read_text())


def validate_archive_input(source,version,failed):
    result=read_json(source/'validation.json')
    job=read_json(source/'job.json')
    prepared=read_json(source/'prepared.json')
    hashes=read_json(source/'source-hashes.json')
    expected=EXPECTED[version]
    require(job.get('version')==version and result.get('candidate')==version
        and prepared.get('candidate')==version,'Candidate identity mismatch')
    job_id=job.get('job_id','')
    require(isinstance(job_id,str) and re.fullmatch(r'[0-9]+',job_id)
        and result.get('job_id')==job_id,'Unique job ID mismatch')
    scheduler=job.get('scheduler_status') or {}
    require(scheduler==result.get('scheduler') and str(scheduler.get('jobId'))==job_id
        and scheduler.get('status') in TERMINAL
        and type(scheduler.get('jobExitCode')) is int
        and type(scheduler.get('systemExitCode')) is int,'Real terminal scheduler evidence missing')
    require(prepared.get('total_cases_planned')==expected['total']
        and prepared.get('runner_cases_planned')==0 and prepared.get('configurations')==6,
        'Frozen prepared plan mismatch')
    require(isinstance(hashes,dict) and set(hashes)==SOURCE_NAMES
        and all(isinstance(value,str) and re.fullmatch(r'[0-9a-f]{64}',value) for value in hashes.values())
        and job.get('source_hashes')==hashes and prepared.get('source_hashes')==hashes
        and prepared.get('source_sha256')==hashes['conv2d.c'],
        'Original prepared/job source identity missing or inconsistent')
    require(hashes['conv2d.c']==SOURCE_SHA256 and prepared.get('source_parent')=='C52-row7x3shared2',
        'AC must retain the original independent C55 source identity')
    # Preserve the mandatory original AC byte-count manifest; compare existing
    # metadata only, with no additional source digest computation.
    manifest_path=source/'source-manifest.json'
    manifest=read_json(manifest_path)
    require(set(manifest)==SOURCE_NAMES and all(
        manifest[name].get('sha256')==hashes[name]
        and type(manifest[name].get('bytes')) is int and manifest[name]['bytes']>0
        for name in SOURCE_NAMES),'Original source-manifest identity mismatch')
    # Read saved scheduler text only. Importing the parser makes no connection.
    sys.path.insert(0,str(ROOT/'tools'))
    import cluster
    require(cluster.parse_scheduler_status((source/'scheduler.log').read_text(),job_id)==scheduler,
        'Scheduler fields do not match returned scheduler text')
    exit_path=source/'raw/exit-code.txt'
    wrapper_exit=None
    if exit_path.exists():
        value=exit_path.read_text().strip()
        require(re.fullmatch(r'-?[0-9]+',value),'Malformed returned wrapper exit')
        wrapper_exit=int(value)
        require(result.get('exit_code')==wrapper_exit,'Validation/wrapper exit mismatch')
    if failed:
        require(result.get('status')=='failed' and result.get('complete') is False
            and isinstance(result.get('reason'),str) and result['reason'].strip(),
            '--failed requires a real failed record with complete=false and a nonempty reason')
        # A compile failure can lack .s and every numerical log. Preserve it.
        nonzero_stage=False
        stage_path=source/'raw/stage-exits.txt'
        if stage_path.exists():
            nonzero_stage=any(int(value)!=0 for value in re.findall(
                r'^STAGE=\S+ EXIT=(-?\d+)$',stage_path.read_text(),re.M))
        require(scheduler['status']!='SUCCEEDED' or scheduler['jobExitCode']!=0
            or scheduler['systemExitCode']!=0 or (wrapper_exit is not None and wrapper_exit!=0)
            or nonzero_stage,
            'No actual scheduler/wrapper/stage failure; do not turn acceptance errors into fake failed runs')
    else:
        require(result.get('status')=='passed' and result.get('complete') is True,
            'Normal freeze requires accepted complete PASS')
        require(scheduler['status']=='SUCCEEDED' and scheduler['jobExitCode']==0
            and scheduler['systemExitCode']==0 and wrapper_exit==0,
            'PASS needs both scheduler exits and wrapper exit zero')
        require(result.get('total_cases')==expected['total'] and result.get('runner_cases',0)==0
            and result.get('full_cases')==6*expected['full']
            and result.get('dispatch_cases')==6*expected['dispatch']
            and result.get('direct_cases',0)==6*expected['direct'],
            'Accepted per-path/total counts differ from AC plan')
        configurations=result.get('configurations') or []
        require(isinstance(configurations,list) and len(configurations)==6 and
            {(row.get('sve_bytes'),row.get('threads')) for row in configurations}==
            {(vl,t) for vl in (16,32,64) for t in (1,4)},
            'Expected six unique real VL/thread configurations')
        require(all(row.get('passed') is True and row.get('full_cases')==expected['full']
            and row.get('dispatch_cases')==expected['dispatch']
            and row.get('direct_cases',0)==expected['direct']
            and row.get('full_matrix_counts')==dict(core=3888,narrow=144,small=720,larger=32,quad_boundary=960)
            and row.get('dispatch_matrix_counts')==dict(core=972,quad_boundary=240) for row in configurations),
            'Missing accepted per-configuration counts')
        require(result.get('source_hashes_verified') is True
            and result.get('source_manifest_remote_matches') is True
            and result.get('source_hashes')==hashes,'Accepted frozen-source verification missing')
        assembly=result.get('assembly') or {}
        require(assembly.get('review_complete') is True and assembly.get('production_uninstrumented') is True
            and assembly.get('stage_count')==13 and assembly.get('fma_count')==0
            and assembly.get('whole_source_fma_count')==0 and assembly.get('transitions_reviewed') is True
            and assembly.get('whole_helper_stack_reviewed') is True
            and assembly.get('all_stages_and_transitions_reviewed') is True
            and assembly.get('dispatch_reviewed') is True
            and assembly.get('shape')==dict(rows_per_group=7,vectors_per_row=3,accumulators=21),
            'Actual thirteen-stage rowseven and complete transition/dispatch review missing')
        require(assembly.get('candidate')==version and assembly.get('job_id')==job_id
            and assembly.get('source_sha256')==SOURCE_SHA256
            and assembly.get('compiler_version')=='10.3.1'
            and assembly.get('schema')=='ac-shared3-paths-v1'
            and assembly.get('shared_triple_and_remainder_reviewed') is True
            and assembly.get('shared_unroll')==dict(main_columns=3,remainder_source_columns=1,remainder_max_columns=2,other_stage_columns=1),
            'Accepted independent shared triple/u1-remainder identity or review missing')
        require(prepared.get('assembly_review_schema')=='ac-shared3-paths-v1'
            and prepared.get('shared_kernel_columns_per_iteration')==3
            and prepared.get('shared_remainder_source_columns_per_iteration')==1
            and prepared.get('shared_remainder_max_columns')==2,
            'Initial AC shared contract mismatch')
        phase_ids=[f'input_{i}' for i in range(6)]+['shared']+[f'trailing_{i}' for i in range(6)]
        helpers=assembly.get('helpers') or []
        require(helpers,'Missing accepted rowseven helpers')
        for helper in helpers:
            stages=helper.get('stages') or []
            require([stage.get('stage') for stage in stages]==phase_ids,'Accepted semantic phase layout changed')
            region_count=12
            for stage in stages:
                if stage['stage']!='shared':
                    require(stage.get('kernel_columns_per_iteration')==1,'Non-shared stage work changed')
                    continue
                blocks=stage.get('blocks') or []
                require({block.get('role') for block in blocks}=={'triple_main','u1_remainder'},
                    'Accepted shared triple/u1 evidence incomplete')
                ids=[block.get('block_id') for block in blocks]
                require(all(isinstance(x,str) and x for x in ids) and len(set(ids))==len(ids),'Accepted block IDs missing/duplicated')
                for block in blocks:
                    work=block.get('kernel_columns_per_iteration'); kind=block.get('region_kind')
                    derived=block.get('derived_counts') or {}
                    require(type(work) is int and (work==3 if block['role']=='triple_main' else 1<=work<=2)
                        and kind in ('loop','straight_line')
                        and (block['role']!='u1_remainder' or kind!='loop' or work==1)
                        and derived.get('fmul')==derived.get('fadd')==21*work,
                        'Accepted shared work normalization/arithmetic mismatch')
                    intervals=block.get('ranges') or []
                    require(intervals and all(type(r.get('line_start')) is int and type(r.get('line_end')) is int
                        and helper['line_start']<=r['line_start']<=r['line_end']<helper['line_end'] for r in intervals),
                        'Accepted actual shared intervals missing/invalid')
                    region_count+=len(intervals)
                require(any(b['role']=='triple_main' and b['region_kind']=='loop' for b in blocks),'Accepted triple backedge missing')
                paths=stage.get('remainder_paths') or []
                require({p.get('remainder_columns') for p in paths}=={0,1,2},'Accepted remainder coverage incomplete')
                lookup={b['block_id']:b for b in blocks}; used=set()
                for path in paths:
                    sequence=path.get('sequence'); work=0
                    require(isinstance(sequence,list) and bool(path.get('path_condition'))
                        and bool(path.get('execution_order_review')),'Accepted remainder path evidence missing')
                    for step in sequence:
                        block=lookup.get(step.get('block_id')); repeat=step.get('executions')
                        require(block is not None and block['role']=='u1_remainder'
                            and type(repeat) is int and 1<=repeat<=2
                            and (block['region_kind']=='loop' or repeat==1),'Invalid accepted remainder sequence')
                        work+=repeat*block['kernel_columns_per_iteration']; used.add(block['block_id'])
                    require(type(path['remainder_columns']) is int and work==path['remainder_columns'],'Accepted remainder path work mismatch')
                require(used=={b['block_id'] for b in blocks if b['role']=='u1_remainder'},'Accepted remainder region unused')
                require(stage.get('actual_arithmetic_region_count')==region_count-12,'Accepted shared interval count mismatch')
            require(helper.get('actual_arithmetic_region_count')==region_count
                and (assembly.get('arithmetic_region_counts') or {}).get(helper['symbol'])==region_count,
                'Accepted actual region count mismatch; never assume14')
        require(all(row.get('dispatch_entries')==1236 and row.get('direct_entries')==1080
            and row.get('dispatch_worker_mask')==row.get('direct_worker_mask')==(1<<row['threads'])-1
            and row.get('block_outputs_per_row')==3*(row['sve_bytes']//4)
            for row in configurations), 'Accepted rowseven entries/masks/block widths mismatch')
        require((source/'raw/conv2d-sve.s').is_file(),
            'PASS archive requires actual uninstrumented production assembly')
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('version',choices=VERSIONS)
    parser.add_argument('--failed',action='store_true')
    args=parser.parse_args()
    source=BASE/args.version
    target=BASE.parent/args.version/'sve-correctness-sep13ac'
    staging=target.with_name('.sve-correctness-sep13ac.preparing')
    require(source.is_dir() and target.parent.is_dir(),'Source/candidate directory missing')
    # Respect shared workflow locking, but do not modify any other evidence.
    with (ROOT/'.runs/.workflow.lock').open('a') as handle:
        fcntl.flock(handle,fcntl.LOCK_EX)
        require(not exists(target) and not exists(staging),'Refusing existing destination or staging tree')
        result=validate_archive_input(source,args.version,args.failed)
        require(not source.is_symlink() and all(not p.is_symlink() and (p.is_file() or p.is_dir())
            for p in source.rglob('*')),
            'Evidence tree must contain ordinary files/directories, not symlink references')
        for original,attached in ATTACHMENTS.items():
            require((BASE/original).is_file() and not (BASE/original).is_symlink(),'Missing ordinary helper attachment: '+original)
            require(not exists(source/attached),'Attachment would replace original evidence: '+attached)
        for reserved in ('assembly-source.json','freeze-source.json'):
            require(not exists(source/reserved),'Generated archive metadata would overwrite original: '+reserved)
        require(not exists(source/'raw/conv2d-sve.assembly.txt'),'Same-byte assembly export already present; stop rather than overwrite')
        # No cleanup on errors: an incomplete staging directory remains visible,
        # and the next invocation refuses to replace it without root review.
        shutil.copytree(source,staging)
        for original,attached in ATTACHMENTS.items():
            shutil.copy2(BASE/original,staging/attached)
        assembly=staging/'raw/conv2d-sve.s'
        if assembly.exists():
            content=assembly.read_bytes()
            public=assembly.with_suffix('.assembly.txt')
            with public.open('xb') as output:
                output.write(content)
            digest=hashlib.sha256(content).hexdigest()
            (staging/'assembly-source.json').write_text(json.dumps(dict(
                source='raw/conv2d-sve.s',public_copy='raw/conv2d-sve.assembly.txt',
                source_sha256=digest,public_sha256=digest,byte_identical=True,
                digest_computations=1,
                note='One SHA256 over the actual returned assembly bytes; the exact same bytes are written to the text export. No broad or repeated manual source-hash audit; original .s unchanged.'),indent=2)+'\n')
        else:
            require(args.failed,'Only a real failed run may lack production assembly')
        (staging/'freeze-source.json').write_text(json.dumps(dict(
            candidate=args.version,job_id=result['job_id'],mode='failed' if args.failed else 'passed',
            frozen_at=datetime.now(timezone.utc).isoformat(),source_directory=str(source.relative_to(ROOT)),
            original_metadata_preserved=True,original_source_and_raw_preserved=True,
            prepared_file='prepared.json',source_hash_manifest='source-hashes.json',
            original_source_manifest_preserved=(source/'source-manifest.json').exists(),
            validation_rewritten=False,acceptance_executed=False,operator_executed=False,
            assembly_available=assembly.exists(),helper_attachments=ATTACHMENTS,
            note='Atomic archive of existing reviewed evidence; failed-mode retains its true reason/counts and does not create missing .s or claim PASS.'),indent=2)+'\n')
        require(not exists(target),'Destination appeared during staging; retain staging and stop')
        staging.rename(target)
    print(str(target))


if __name__=='__main__':
    try:
        main()
    except (ValueError,OSError,KeyError) as exc:
        raise SystemExit(str(exc))
