#!/usr/bin/env python3
"""Register collected r20 logs without running task code or computing digests."""
from pathlib import Path
import json
import importlib.util
import re
import subprocess
import sys
import tarfile

from preflight_audit import audit_wide
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
spec = importlib.util.spec_from_file_location('r20_finish_nohash_records', ROOT / '.runs/trsm/nohash-tools/records-kml.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
config = json.loads((HERE / 'cohort-config.json').read_text())
frozen_config = json.loads((HERE / 'payload/cohort-config.json').read_text())
if config != frozen_config or config['cohort_id'] != GROUP['cohort_id']:
    raise SystemExit('Collected cohort differs from frozen submitted configuration')
names = ['T19-control13-repeat-r20', 'T20-wideunroll2-repeat-r20', 'T22-unrollreg']
versions = ['T19-control13', 'T20-wideunroll2', 'T22-unrollreg']
if (list(config['members']) != names or config['round_order'] != [names[i:] + names[:i] for i in range(3)]
        or config['warmup_order'] != names or config['warmup_suites_per_member'] != 1
        or config['warmup_protocol'].get('protocol_id') != 'trsm-r20-one-official-warmup-v1'
        or config['warmup_protocol'].get('excluded_from_comparison') is not True
        or config['warmup_protocol'].get('formal_suites_per_member') != 3):
    raise SystemExit('r20 protocol identity changed')
for index, (name, version) in enumerate(zip(names, versions)):
    if config['members'][name].get('version') != version or config['members'][name].get('repeat_existing') is not (index < 2):
        raise SystemExit('r20 requires two repeats and one new T22 version')
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
prepared_bytes = {}
for index, (name, version) in enumerate(zip(names, versions)):
    run = ROOT / '.runs/trsm' / name
    meta = json.loads((run / 'experiment.json').read_text())
    record_path = ROOT / 'records/experiments/trsm' / (version + '.json')
    if index < 2:
        prior_bytes[version] = helper.regular_bytes(record_path)
        prior = json.loads(prior_bytes[version])
        if prior.get('job_id') != '1582129' or meta.get('prior_job_id') != '1582129':
            raise SystemExit('r20 must preserve its declared r19 prior records')
        helper.validate_repeat_existing(run.resolve(), meta, prior)
        for field in ('version', 'parent', 'strategy', 'created_at', 'source_implementation_id', 'source_from'):
            if meta.get(field) != prior.get(field):
                raise SystemExit('Repeated implementation identity changed: ' + field)
    else:
        prepared_bytes[version] = helper.regular_bytes(record_path)
        if (prepared_bytes[version] != helper.regular_bytes(run / 'experiment.json')
                or meta.get('problem') != 'trsm' or meta.get('version') != version
                or meta.get('parent') != 'T19-control13' or meta.get('status') != 'prepared'
                or meta.get('verified') is not False or meta.get('recorded_at') is not None
                or meta.get('repeat_existing', False) is not False
                or meta.get('prior_job_id') is not None):
            raise SystemExit('The new T22 member already has changed or recorded experiment evidence')
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
    formal = (run / 'benchmark.log').read_text()
    count = len(re.findall(r'^\s*\d+\s*x\s*\d+[^\n]*\bPASS\s*$', formal, re.M))
    if count != 9 or re.search(r'\bFAIL(?:ED)?\b', formal) or 'WARMUP_REPEAT' in formal:
        raise SystemExit('Formal suite count or correctness invalid')
    audit['members'][name] = dict(warmup_cases_pass=3, measured_cases_pass=count,
                                  formal_original_log_checks=observed['checks'],
                                  warmup_excluded_from_comparison=True)
    audit['measured_official_pass_count'] += count
    audit['warmup_official_pass_count'] += 3
audit['wide_preflight'] = {name: audit_wide(DEST / 'preflight-wide32-results' / name) for name in names}
for name in names:
    guard = json.loads((DEST / 'preflight-wide32-results' / name / 'guard.json').read_text())
    if (guard.get('guard_pass') is not True or guard.get('scheduler_job_id') != GROUP['job_id']
            or guard.get('allowed_cpu_count') != 38):
        raise SystemExit('Wide preflight guard differs from the assigned job: ' + name)
if audit['measured_official_pass_count'] != 27 or audit['warmup_official_pass_count'] != 9:
    raise SystemExit('Expected 27 measured and 9 warm-up official case passes')
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
for index, (name, version) in enumerate(zip(names, versions)):
    expected_record = prior_bytes[version] if index < 2 else prepared_bytes[version]
    if helper.regular_bytes(ROOT / 'records/experiments/trsm' / (version + '.json')) != expected_record:
        raise SystemExit('Record changed before registration; do not replay finish')
    argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'record', '.runs/trsm/' + name,
            '--environment', env_id, '--reference', reference]
    if index < 2:
        argv.append('--repeat-existing')
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (HERE / (name + '-record.log')).write_bytes(result.stdout)
    commands['executed_argv'].append(argv)
    commands['exit_codes'].append(result.returncode)
    (HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    print(result.stdout.decode(), end='')
    if result.returncode:
        raise SystemExit('Record failed; preserve evidence and diagnose')
comparisons = {}
for candidate in ('T20-wideunroll2', 'T22-unrollreg'):
    argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'compare', 'T19-control13', candidate]
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (HERE / ('T19-control13-vs-' + candidate + '.json')).write_bytes(result.stdout)
    commands['executed_argv'].append(argv)
    commands['exit_codes'].append(result.returncode)
    (HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    print(result.stdout.decode(), end='')
    if result.returncode not in (0, 2):
        raise SystemExit('Unexpected comparison failure')
    comparisons[candidate] = json.loads(result.stdout)
# Mechanism comparison is informative only; the declared promotion parent remains T19-control13.
mechanism = {}
base, candidate = 'T20-wideunroll2', 'T22-unrollreg'
argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'compare', base, candidate]
result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
(HERE / (base + '-vs-' + candidate + '.json')).write_bytes(result.stdout)
commands['executed_argv'].append(argv)
commands['exit_codes'].append(result.returncode)
(HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
print(result.stdout.decode(), end='')
if result.returncode not in (0, 2):
    raise SystemExit('Unexpected mechanism comparison failure')
mechanism[base + '-vs-' + candidate] = dict(base=base, candidate=candidate,
                    promotion_authorization=False, result=json.loads(result.stdout))
recorded = {version: json.loads((ROOT / 'records/experiments/trsm' / (version + '.json')).read_text()) for version in versions}
summary = dict(status='compared_pending_root_review', job_id=GROUP['job_id'], formal_pass_count=27,
               warmup_pass_count=9, baseline_version='T19-control13', best_implementation='T19-panel8x16budget',
               comparisons=comparisons, mechanism_comparisons=mechanism, medians_ms={key: value['total_median_ms'] for key, value in recorded.items()},
               reference='KML25.1/GCC12; not specified KML25.2', promoted=False)
(HERE / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
with (HERE / 'finish-complete.json').open('x') as handle:
    json.dump(dict(job_id=GROUP['job_id'], status='compared_pending_root_review', formal_pass_count=27,
                   warmup_pass_count=9, repeat_versions=versions[:2], new_versions=versions[2:], promoted=False), handle, indent=2)
    handle.write('\n')
