"""Root C8 finalization after real AY/AZ and exact original ZIP PASS. No network."""
import argparse,importlib.util,json,shutil,zipfile,io,hashlib,sys
sys.dont_write_bytecode=True
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('ba_contract',Path(__file__).with_name('sep13ba-submit-package.py'))
contract=importlib.util.module_from_spec(spec);spec.loader.exec_module(contract)
e,c=contract.e,contract.c

def verified():
    initial,confirm,source,cfg=contract.preflight()
    run=ROOT/'.runs/conv'/contract.VERSION
    rec=e.get_record('conv',contract.VERSION);manifest=e.read_json(run/'cluster.json');package=e.read_json(run/'package-manifest.json')
    contract.need(rec['status']=='passed' and rec['verified'] is True and rec['repeats']==3,'Complete original package record')
    contract.need(set(rec['checks'])=={'scheduler','fetched_log','benchmark','wrapper','source_hashes','machine'} and all(rec['checks'].values()),'All package checks')
    contract.need(rec['reference_only'] is True and rec['promotion_allowed'] is False and rec['package_validation_only'] is True,'Package is verification only')
    contract.need(rec['parent']==rec['source_parent']==contract.CONFIRMATION and rec['source_origin']==contract.SOURCE,'Package source lineage')
    contract.need(rec['source_hashes']==manifest['source_hashes']==source==e.source_files(run/'source'),'Package source association')
    contract.need(rec['settings']==manifest['settings']==confirm['settings'] and rec['job_id']==manifest['job_id'],'Package job/settings')
    contract.need(str(rec['job_id']).isdigit() and str(rec['job_id']) not in ['1591086',str(initial['performance_job']),str(confirm['performance_job'])],'Independent package allocation')
    status=manifest['scheduler_status'];contract.need(status['status']=='SUCCEEDED' and status['jobExitCode']==status['systemExitCode']==0,'Package actual terminal exits')
    contract.need(str(status['jobId'])==str(rec['job_id']) and (run/'exit-code.txt').read_text().strip()=='0','Original job/wrapper exit')
    contract.need(all(e.digest(run/f)==manifest['artifacts_sha256'][f] for f in ['benchmark.log','environment.log','exit-code.txt','source-sha256.txt']),'Original package fetched artifacts')
    raw=(run/'benchmark.log').read_text();parsed=e.parse_log('conv',raw,3)
    contract.need(e.machine_profile(run,raw)==rec['machine'],'Original package machine profile')
    contract.need(parsed['cases']==rec['cases'] and parsed['total_median_ms']==rec['total_median_ms'],'All12 original numerical samples')
    contract.need(len(rec['cases'])==4 and all(len(x['times_ms'])==3 and x['max_error']==0 for x in rec['cases']),'Exact12PASS/error0')
    machine=rec['machine'];contract.need(machine['compiler_banners']==['gcc (GCC) 10.3.1'] and machine['ARCH']=='aarch64' and machine['OMP_NUM_THREADS']=='38' and machine['CPU_TARGET']=='generic','Package compiler/threads')
    contract.need(len(set(machine['ALLOWED_CPUS'].split(',')))==38 and bool(machine['NUMA_NODE']),'Package allocation')
    archive=(run/'conv.zip').read_bytes();sha=hashlib.sha256(archive).hexdigest()
    contract.need(package==manifest['package_verification'] and package['source_hashes']==source and package['zip_sha256']==sha,'Exact original package identity')
    contract.need((run/'wrapper.stdout.log').read_text().splitlines().count('PACKAGE_SHA256_VERIFIED='+sha)==1,'Original ZIP verified/extracted on compute')
    with zipfile.ZipFile(io.BytesIO(archive)) as z:
        infos=z.infolist();contract.need(len(infos)==4 and {x.filename for x in infos}=={'conv/'+n for n in source},'Submission package members')
        for x in infos:
            name=x.filename.removeprefix('conv/')
            contract.need(z.read(x.filename)==(run/'source'/name).read_bytes(),'ZIP differs from measured source')
            if name=='run.sh':contract.need((x.external_attr>>16)&0o111,'Runner permission')
    contract.need(e.read_json(run/'package-submit-exit.json')['exit_code']==0,'Package submit outcome')
    return initial,confirm,source,rec,package,archive

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--apply',action='store_true');args=parser.parse_args()
    initial,confirm,source,pack,package,archive=verified()
    rec=e.get_record('conv',contract.CONFIRMATION);base=e.get_record('conv','C58-r17');opening=e.get_record('conv','C58-r16')
    contract.need(base['parent'] is None and base['source_hashes']==e.source_files(ROOT/'conv'),'Closing control can reset same-source baseline')
    contract.need(rec['parent']==base['version'] and rec['source_parent']==contract.SOURCE and rec['confirmation_passed'] is True and rec['promotion_allowed'] is True,'Standard confirmation promotion lineage')
    lineage=e.read_json(ROOT/'records/conv-lineage.json');contract.need(lineage['current_label']=='C7' and lineage['current_measurement']=='C58-r1' and not any(x['label']=='C8' for x in lineage['versions']),'C8 not yet finalized')
    gain=(base['total_median_ms']-rec['total_median_ms'])/base['total_median_ms']*100;summary=dict(mode='apply' if args.apply else 'read-only',candidate=contract.CONFIRMATION,new_label='C8',confirmation_job=confirm['performance_job'],package_job=pack['job_id'],total_median_ms=rec['total_median_ms'],baseline_ms=base['total_median_ms'],gain_pct=gain)
    print(json.dumps(summary,indent=2))
    if not args.apply:return
    with e.locked():
        contract.need(verified()==(initial,confirm,source,pack,package,archive),'Evidence changed before promotion')
        contract.need(e.read_json(ROOT/'records/conv-lineage.json')==lineage,'Lineage changed before promotion')
        backup=ROOT/'.runs/conv/sep13ba-before-promotion';backup.mkdir()
        for name in ['outputs/conv-best.json','outputs/conv-best.zip','outputs/conv-best.zip.sha256','records/best.json','records/conv-lineage.json']:
            dst=backup/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/name,dst)
        other={k:v for k,v in e.read_json(ROOT/'records/best.json').items() if k!='conv'}
        other_sources={p:e.source_files(ROOT/p) for p in other}
        e.promote(argparse.Namespace(problem='conv',version='C58-r17'))
        e.promote(argparse.Namespace(problem='conv',version=contract.CONFIRMATION))
        contract.need({k:v for k,v in e.read_json(ROOT/'records/best.json').items() if k!='conv'}==other,'Other best changed')
        contract.need({p:e.source_files(ROOT/p) for p in other_sources}==other_sources,'Other problem source changed')
        rec=e.get_record('conv',contract.CONFIRMATION)
        zipcheck=dict(experiment=contract.VERSION,job_id=pack['job_id'],total_median_ms=pack['total_median_ms'],suites=3,cases_per_suite=4,all_pass=True,max_error=0,archive_verified_and_extracted_on_compute_node=True,same_source_as_promoted=True)
        metadata=dict(label='C8',parent_label='C7',experiment=contract.CONFIRMATION,source_experiment=contract.SOURCE,source_hashes=source,package_sha256=package['zip_sha256'],total_median_ms=rec['total_median_ms'],metric='sum of four per-case medians; not official score',controlled_comparison=dict(baseline=base['version'],baseline_total_median_ms=base['total_median_ms'],candidate_total_median_ms=rec['total_median_ms'],time_reduction_pct=gain,opening_baseline=opening['version'],opening_baseline_total_median_ms=opening['total_median_ms'],initial_candidate=contract.SOURCE,initial_candidate_job=initial['performance_job'],initial_candidate_total_median_ms=e.get_record('conv',contract.SOURCE)['total_median_ms'],confirmation_job=confirm['performance_job'],samples_mixed_with_initial_round=False),verification=rec['checks'],zip_verification=zipcheck,specialized_correctness=dict(source_experiment=contract.SOURCE,job_id='1591086',checks=80100,all_pass=True,threads=[1,4,38],sve_bits=[128,256,512]),official_submission=False)
        shutil.copy2(ROOT/'.runs/conv'/contract.VERSION/'conv.zip',ROOT/'outputs/conv-best.zip')
        e.write_json(ROOT/'outputs/conv-best.json',metadata)
        (ROOT/'outputs/conv-best.zip.sha256').write_text(package['zip_sha256']+'  conv-best.zip\n')
        lineage['versions'].append(dict(label='C8',experiment=contract.CONFIRMATION,source_experiment=contract.SOURCE,parent_label='C7',comparison_baseline=base['version'],kernel_sha256=source['conv2d.c'],total_median_ms=rec['total_median_ms'],time_reduction_pct=gain,strategy='Balance seven-row/three-SVE-vector tiles across the actual OpenMP team, coalescing contiguous same-group slices; original C7 arithmetic helpers unchanged',promoted_at=rec['promoted_at'],official_score=None,repeat_measurements=[dict(experiment=contract.SOURCE,job_id=initial['performance_job'],total_median_ms=e.get_record('conv',contract.SOURCE)['total_median_ms'])],package_verification=dict(zipcheck,sha256=package['zip_sha256'])))
        lineage.update(current_label='C8',current_measurement=contract.CONFIRMATION,current_total_median_ms=rec['total_median_ms']);e.write_json(ROOT/'records/conv-lineage.json',lineage)
        contract.need((ROOT/'outputs/conv-best.zip').read_bytes()==archive and e.source_files(ROOT/'conv')==source,'Final exact package/source')
    print('Raw C8 finalized; public GitHub copy remains a separate step.')
if __name__=='__main__':main()
