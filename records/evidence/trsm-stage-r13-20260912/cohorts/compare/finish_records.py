#!/usr/bin/env python3
"""Register collected r13 logs without running task code or computing digests."""
from pathlib import Path
import json
import re
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
GROUP = json.loads((HERE / 'cohort-submission.json').read_text())
if GROUP['state'] != 'collected':
    raise SystemExit('Collect succeeded job before registering')
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
names = ['T8-control12-repeat-r13', 'T10-lhistbarrier-repeat-r13', 'T14-lhistcyclic']
audit = dict(job_id=GROUP['job_id'], cohort_exit=0, measured_official_pass_count=0,
             warmup_official_pass_count=0, members={}, hash_operations=False)
expected_general_by_packed = {
    False: ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES=14 WHOLE_CASES=406 '
            'NOOP_CASES=28 OLD_MICRO_CASES=14 PACKED_MICRO_CASES=0 SHARED_FAIL_CASES=0'),
    True: ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES=28 WHOLE_CASES=486 '
           'NOOP_CASES=36 OLD_MICRO_CASES=14 PACKED_MICRO_CASES=14 SHARED_FAIL_CASES=80'),
}
for name in names:
    run = ROOT / '.runs/trsm' / name
    warmup = json.loads((run / 'warmup/summary.json').read_text())
    if not warmup['passed'] or warmup['case_pass_count'] != 3 or warmup['job_id'] != GROUP['job_id']:
        raise SystemExit('Incomplete warm-up')
    completion = (DEST / 'preflight-results' / name / 'completion.txt').read_text().strip()
    source_text = (HERE / 'payload' / name / 'source/trsm.c').read_text()
    features = ('static void solve16x8_panel_sve(' in source_text,
                'static void solve16x8_panel_packedL_sve(' in source_text)
    if features != (True, name != names[0]):
        raise SystemExit('Frozen source differs from declared general-preflight features: ' + name)
    if completion != expected_general_by_packed[features[1]]:
        raise SystemExit('General preflight evidence missing or counts differ: ' + name)
    formal = (run / 'benchmark.log').read_text()
    count = len(re.findall(r'^\s*\d+\s*x\s*\d+[^\n]*\bPASS\s*$', formal, re.M))
    if count != 9 or re.search(r'\bFAIL(?:ED)?\b', formal):
        raise SystemExit('Formal suite count or correctness invalid')
    audit['members'][name] = dict(warmup_cases_pass=3, measured_cases_pass=count,
                                  preflight_completion=completion, source_features=dict(panel16=features[0], packedL16=features[1]),
                                  warmup_excluded_from_comparison=True)
    audit['measured_official_pass_count'] += count
    audit['warmup_official_pass_count'] += 3
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
for index, name in enumerate(names):
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
for candidate in ('T10-lhistbarrier', 'T14-lhistcyclic'):
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
# This pair is a mechanism control only. T14's promotion parent remains T8.
argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'compare',
        'T10-lhistbarrier', 'T14-lhistcyclic']
result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
(HERE / 'T10-lhistbarrier-vs-T14-lhistcyclic.json').write_bytes(result.stdout)
commands['executed_argv'].append(argv)
commands['exit_codes'].append(result.returncode)
(HERE / 'record-compare-commands.json').write_text(json.dumps(commands, indent=2) + '\n')
print(result.stdout.decode(), end='')
if result.returncode not in (0, 2):
    raise SystemExit('Unexpected mechanism comparison failure')
mechanism = dict(base='T10-lhistbarrier', candidate='T14-lhistcyclic',
                 promotion_authorization=False, result=json.loads(result.stdout))
medians = {name: json.loads((ROOT / 'records/experiments/trsm' / (name + '.json')).read_text())['total_median_ms']
           for name in ('T8-control12', 'T10-lhistbarrier', 'T14-lhistcyclic')}
summary = dict(status='compared_pending_review', job_id=GROUP['job_id'], formal_pass_count=27,
               warmup_pass_count=9, baseline_version='T8-control12', best_implementation='T8-svepanel16',
               comparisons=comparisons, mechanism_comparison=mechanism, medians_ms=medians, reference='KML25.1/GCC12; not specified KML25.2',
               promoted=False)
(HERE / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
