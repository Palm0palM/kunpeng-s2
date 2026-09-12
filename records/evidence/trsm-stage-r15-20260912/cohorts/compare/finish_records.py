#!/usr/bin/env python3
"""Register collected r15 logs without running task code or computing digests."""
from pathlib import Path
import json
import importlib.util
import re
import subprocess
import sys
import tarfile

from preflight_audit import audit_general, audit_wide
from cohort_driver import warmup_cases, cpus

sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
GROUP = json.loads((HERE / 'cohort-submission.json').read_text())
if GROUP['state'] != 'collected' or not re.fullmatch(r'\d+', str(GROUP.get('job_id', ''))):
    raise SystemExit('Collect succeeded known job before registering')
# One explicit attempt only, including failures after this point. Never replay partial registration.
with (HERE / 'finish-attempt.json').open('x') as handle:
    json.dump(dict(job_id=GROUP['job_id'], status='started', retry_allowed=False), handle)
    handle.write('\n')
spec = importlib.util.spec_from_file_location('r15_finish_nohash_records', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
config = json.loads((HERE / 'cohort-config.json').read_text())
frozen_config = json.loads((HERE / 'payload/cohort-config.json').read_text())
if config != frozen_config or config['cohort_id'] != GROUP['cohort_id']:
    raise SystemExit('Collected cohort differs from frozen submitted configuration')
names = ['T8-control12-repeat-r15', 'T18-budgetwide-repeat-r15']
versions = ['T8-control12', 'T18-budgetwide']
if (list(config['members']) != names or config['round_order'] != [names, names[::-1], names]
        or config['warmup_order'] != names or config['warmup_suites_per_member'] != 1
        or config['warmup_protocol'].get('protocol_id') != 'trsm-r15-one-official-warmup-v1'
        or config['warmup_protocol'].get('excluded_from_comparison') is not True
        or config['warmup_protocol'].get('formal_suites_per_member') != 3):
    raise SystemExit('r15 protocol identity changed')
for name, version in zip(names, versions):
    if config['members'][name].get('version') != version or config['members'][name].get('repeat_existing') is not True:
        raise SystemExit('r15 requires both original versions and repeat flags')
DEST = HERE / 'diagnostics'
DEST.mkdir()
with tarfile.open(HERE / 'diagnostics.tar.gz', 'r:gz') as archive:
    for member in archive:
        relative = Path(member.name)
        if relative.is_absolute() or '..' in relative.parts or not member.isfile():
            raise SystemExit('Unsafe diagnostic member')
        path = DEST / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        with archive.extractfile(member) as source, path.open('xb') as output:
            output.write(source.read())
if (DEST / 'cohort-exit-code.txt').read_text().strip() != '0':
    raise SystemExit('Cohort exit is not zero')
audit = dict(job_id=GROUP['job_id'], cohort_exit=0, measured_official_pass_count=0,
             warmup_official_pass_count=0, members={}, hash_operations=False)
prior_bytes = {}
for name, version in zip(names, versions):
    run = ROOT / '.runs/trsm' / name
    meta = json.loads((run / 'experiment.json').read_text())
    prior_path = ROOT / 'records/experiments/trsm' / (version + '.json')
    prior_bytes[version] = helper.regular_bytes(prior_path)
    prior = json.loads(prior_bytes[version])
    if prior.get('job_id') != '1579730' or meta.get('prior_job_id') != '1579730':
        raise SystemExit('r15 must preserve the declared r14 prior record')
    helper.validate_repeat_existing(run.resolve(), meta, prior)
    for field in ('version', 'parent', 'strategy', 'created_at', 'source_implementation_id', 'source_from'):
        if meta.get(field) != prior.get(field):
            raise SystemExit('Repeated implementation identity changed: ' + field)
    for filename in ('README.md', 'trsm.c', 'bench_trsm.c', 'run.sh', 'compat/kblas.h'):
        if helper.regular_bytes(run / 'source' / filename) != helper.regular_bytes(HERE / 'payload' / name / 'source' / filename):
            raise SystemExit('Source differs from frozen submitted source: ' + filename)
    observed = helper.audit(run, dict(problem='trsm', version=version))
    if observed['failures'] or not all(observed['checks'].values()) or observed['job_id'] != GROUP['job_id']:
        raise SystemExit('Formal original-log audit failed before registration: ' + name)
    warmup = json.loads((run / 'warmup/summary.json').read_text())
    if (warmup.get('passed') is not True or warmup.get('case_pass_count') != 3
            or warmup.get('job_id') != GROUP['job_id'] or warmup.get('member') != name
            or warmup.get('cohort_id') != config['cohort_id']
            or warmup.get('protocol') != config['warmup_protocol']
            or warmup.get('excluded_from_comparison') is not True
            or warmup.get('warmup_suites_completed') != 1 or warmup.get('runner_exit_code') != 0
            or warmup.get('dependency_audit', {}).get('passed') is not True):
        raise SystemExit('Incomplete or misidentified warm-up')
    warmtext = (run / 'warmup.log').read_text()
    cases, log_directory = warmup_cases(warmtext, observed['machine']['NUMA_NODE'],
                                        cpus(observed['machine']['ALLOWED_CPUS']))
    if (cases != warmup.get('cases') or log_directory != warmup.get('official_log_directory')
            or warmtext.splitlines().count('WARMUP_COMPLETE=1') != 1
            or warmtext.splitlines().count('WARMUP_REPEAT 1/1 END') != 1
            or warmtext.splitlines().count('WARMUP_EXCLUDED_FROM_COMPARISON=1') != 1
            or warmtext.splitlines().count('WARMUP_REPEAT 1/1 BEGIN COHORT={} MEMBER={}'.format(config['cohort_id'], name)) != 1):
        raise SystemExit('Warm-up raw log differs from completed summary')
    warm_linkage = (run / 'warmup-linkage.log').read_text()
    dependency = warmup['dependency_audit']
    for line in ('WARMUP_LINKAGE_REPEAT 1/1 BEGIN', 'WARMUP_LINKAGE_REPEAT 1/1 END',
                 'JOB_ID=' + GROUP['job_id'], 'LDD_EXIT_CODE=0', 'KML251_DEPENDENCY_AUDIT_PASS=1',
                 'KML251_LINKED_LIBRARY=' + dependency['kml251_linked_library'],
                 'GOMP_LINKED_LIBRARY=' + dependency['gomp_linked_library']):
        if warm_linkage.splitlines().count(line) != 1:
            raise SystemExit('Warm-up dependency evidence is incomplete')
    general = audit_general(DEST / 'preflight-results' / name,
                            HERE / 'payload' / name / 'source/trsm.c', name)
    formal = (run / 'benchmark.log').read_text()
    count = len(re.findall(r'^\s*\d+\s*x\s*\d+[^\n]*\bPASS\s*$', formal, re.M))
    if count != 9 or re.search(r'\bFAIL(?:ED)?\b', formal) or 'WARMUP_REPEAT' in formal:
        raise SystemExit('Formal suite count or correctness invalid')
    audit['members'][name] = dict(warmup_cases_pass=3, measured_cases_pass=count,
                                  general_preflight=general, formal_original_log_checks=observed['checks'],
                                  warmup_excluded_from_comparison=True)
    audit['measured_official_pass_count'] += count
    audit['warmup_official_pass_count'] += 3
audit['wide_preflight'] = audit_wide(DEST / 'preflight-wide32-results' / 'T18-budgetwide-repeat-r15')
if audit['measured_official_pass_count'] != 18 or audit['warmup_official_pass_count'] != 6:
    raise SystemExit('Expected 18 measured and 6 warm-up official case passes')
(HERE / 'actual-run-audit.json').write_text(json.dumps(audit, indent=2) + '\n')
environment = (DEST / 'environment.log').read_text()
host = re.search(r'^HOST=(\S+)$', environment, re.M).group(1)
numa = re.search(r'^NUMA_NODE=(\d+)$', environment, re.M).group(1)
env_id = '{}-numa{}-gcc1231-generic38-kml251-test3-warmup1-job{}'.format(host, numa, GROUP['job_id'])
reference = ('Huawei KML 25.1.0 real headers and default -lkblas; private GCC 12.3.1 libgomp; '
             'not specified official KML 25.2.0')
commands = dict(executed_argv=[], exit_codes=[], job_id=GROUP['job_id'], no_hash_operations=True)
for action in ('prepare', 'submit', 'collect'):
    if action == 'collect' and (HERE / 'collect-before-scheduler-terminal.log').is_file():
        commands['executed_argv'].append(['python3', str(HERE.relative_to(ROOT) / 'job_control.py'), action])
        commands['exit_codes'].append(1)
        commands['earlier_collect_attempt'] = 'collect-before-scheduler-terminal.log: refused while scheduler reported RUNNING; no registration occurred'
    commands['executed_argv'].append(['python3', str(HERE.relative_to(ROOT) / 'job_control.py'), action])
    commands['exit_codes'].append(0)
for name, version in zip(names, versions):
    if helper.regular_bytes(ROOT / 'records/experiments/trsm' / (version + '.json')) != prior_bytes[version]:
        raise SystemExit('Prior record changed before its repeat registration; do not replay finish')
    argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'record', '.runs/trsm/' + name,
            '--environment', env_id, '--reference', reference, '--repeat-existing']
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (HERE / (name + '-record.log')).write_bytes(result.stdout)
    commands['executed_argv'].append(argv)
    commands['exit_codes'].append(result.returncode)
    (HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    print(result.stdout.decode(), end='')
    if result.returncode:
        raise SystemExit('Record failed; preserve evidence and diagnose')
comparisons = {}
for candidate in ('T18-budgetwide',):
    argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'compare', 'T8-control12', candidate]
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (HERE / ('T8-control12-vs-' + candidate + '.json')).write_bytes(result.stdout)
    commands['executed_argv'].append(argv)
    commands['exit_codes'].append(result.returncode)
    (HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    print(result.stdout.decode(), end='')
    if result.returncode not in (0, 2):
        raise SystemExit('Unexpected comparison failure')
    comparisons[candidate] = json.loads(result.stdout)
medians = {name: json.loads((ROOT / 'records/experiments/trsm' / (name + '.json')).read_text())['total_median_ms']
           for name in ('T8-control12', 'T18-budgetwide')}
summary = dict(status='compared_pending_review', job_id=GROUP['job_id'], formal_pass_count=18,
               warmup_pass_count=6, baseline_version='T8-control12', best_implementation='T8-svepanel16',
               comparisons=comparisons, medians_ms=medians, reference='KML25.1/GCC12; not specified KML25.2',
               promoted=False)
(HERE / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
with (HERE / 'finish-complete.json').open('x') as handle:
    json.dump(dict(job_id=GROUP['job_id'], status='compared_pending_review', formal_pass_count=18,
                   warmup_pass_count=6, repeat_versions=versions, promoted=False), handle, indent=2)
    handle.write('\n')
