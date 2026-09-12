#!/usr/bin/env python3
"""Register collected r11 logs without running task code or computing digests."""
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
names = ['T8-control12-repeat-r11', 'T13-sve4x32-repeat-r11']
audit = dict(job_id=GROUP['job_id'], cohort_exit=0, measured_official_pass_count=0,
             warmup_official_pass_count=0, members={}, hash_operations=False)
expected_general = ('TRSM_PREFLIGHT_COMPLETE=1 MICRO_CASES=14 WHOLE_CASES=406 '
                    'NOOP_CASES=28 OLD_MICRO_CASES=14 PACKED_MICRO_CASES=0 SHARED_FAIL_CASES=0')
for name in names:
    run = ROOT / '.runs/trsm' / name
    warmup = json.loads((run / 'warmup/summary.json').read_text())
    if not warmup['passed'] or warmup['case_pass_count'] != 3 or warmup['job_id'] != GROUP['job_id']:
        raise SystemExit('Incomplete warm-up')
    completion = (DEST / 'preflight-results' / name / 'completion.txt').read_text().strip()
    if completion != expected_general:
        raise SystemExit('General preflight evidence missing')
    formal = (run / 'benchmark.log').read_text()
    count = len(re.findall(r'^\s*\d+\s*x\s*\d+[^\n]*\bPASS\s*$', formal, re.M))
    if count != 9 or re.search(r'\bFAIL(?:ED)?\b', formal):
        raise SystemExit('Formal suite count or correctness invalid')
    audit['members'][name] = dict(warmup_cases_pass=3, measured_cases_pass=count,
                                  preflight_completion=completion, warmup_excluded_from_comparison=True)
    audit['measured_official_pass_count'] += count
    audit['warmup_official_pass_count'] += 3
wide = (DEST / 'preflight-wide32-results/T13-sve4x32-repeat-r11/completion.txt').read_text().strip()
if wide != ('TRSM_WIDE32_PREFLIGHT_COMPLETE=1 MICRO_CASES=28 WHOLE_CASES=22 '
            'SHARED_FAIL_CASES=1 NO_SVE_CASES=1 NARROW_VL_CASES=1'):
    raise SystemExit('Wide preflight completion missing')
audit['wide_preflight_completion'] = wide
wide_summary = json.loads((DEST / 'preflight-wide32-results/T13-sve4x32-repeat-r11/summary.json').read_text())
if (wide_summary.get('complete') is not True or wide_summary.get('micro_cases') != 28
        or wide_summary.get('whole_cases') != 22 or wide_summary.get('argument_checked_cases') != 50
        or wide_summary.get('kernel_argument_mismatches') != 0
        or wide_summary.get('original_candidate_modified') is not False):
    raise SystemExit('Wide preflight argument evidence missing')
audit['wide_preflight_summary'] = wide_summary
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
for name in names:
    argv = ['python3', '.runs/trsm/nohash-tools/records-kml.py', 'record', '.runs/trsm/' + name,
            '--environment', env_id, '--reference', reference]
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
for candidate in ('T13-sve4x32',):
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
           for name in ('T8-control12', 'T13-sve4x32')}
summary = dict(status='compared_pending_review', job_id=GROUP['job_id'], formal_pass_count=18,
               warmup_pass_count=6, baseline_version='T8-control12', best_implementation='T8-svepanel16',
               comparisons=comparisons, medians_ms=medians, reference='KML25.1/GCC12; not specified KML25.2',
               promoted=False)
(HERE / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
