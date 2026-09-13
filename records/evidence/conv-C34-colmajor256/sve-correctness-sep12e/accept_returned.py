"""Read returned diagnostic text only; never compiles or runs operator code."""
import json
import sys
import re
from pathlib import Path

version = sys.argv[1]
full_count, smoke_count, probe_count = {'C34-colmajor256': (21748,96,0), 'C35-prefetch2': (29668,168,18)}[version]
base = Path(__file__).resolve().parent / version
raw = base / 'raw'
job = json.loads((base / 'job.json').read_text())
scheduler = job['scheduler_status']
assert scheduler['jobId'] == job['job_id']
assert scheduler['status'] == 'SUCCEEDED'
assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
plan = dict(full_per_configuration=full_count, smoke_per_configuration=smoke_count, prefetch_probe_per_configuration=probe_count, configurations=6, total=(full_count+smoke_count+probe_count)*6)
assert job['expected_checks'] == plan
assert (raw / 'exit-code.txt').read_text().strip() == '0'
probe = (raw / 'probe.log').read_text()
assert re.search(r'^PROBE_COMPLETE=1$', probe, re.M)
assert 'SANITIZER_STATUS=NOT_RUN' in probe
expected = json.loads((base / 'source-hashes.json').read_text())
remote_pairs = re.findall(r'^([0-9a-f]{64})  ([^\s]+)$', (raw / 'source-sha256.txt').read_text(), re.M)
assert len(remote_pairs) == len(expected)
assert {name: digest for digest, name in remote_pairs} == expected
configs = []
for sve_bytes in (16, 32, 64):
    for threads in (1, 4):
        lanes = sve_bytes // 4
        header = f'SVE_BYTES={sve_bytes} SVE_LANES={lanes} BLOCK_OUTPUTS={lanes * 4} THREADS={threads}'
        texts = []
        for kind, count in (('guard', full_count), ('dispatch', smoke_count)):
            log = (raw / f'{kind}-vl{sve_bytes}-t{threads}.log').read_text()
            assert len(re.findall('^' + re.escape(header) + '$', log, re.M)) == 1
            assert len(re.findall(r'^PASS: ' + str(count) + r' convolution cases;', log, re.M)) == 1
            assert not re.search(r'\bFAIL(?:ED)?\b', log)
            texts.append(log)
        entries = {}
        for name in ('prefix', 'tail', 'rowpair', 'rowtriple', 'rowquad'):
            values = re.findall('SVE_' + name.upper() + r'_ACTUAL_ENTRIES=(\d+)', texts[1])
            assert len(values) == 1
            entries[name] = int(values[0])
        assert all(entries[name] > 0 for name in ('rowpair', 'rowtriple', 'rowquad'))
        configs.append(dict(sve_bytes=sve_bytes, threads=threads, lanes=lanes,
                            block_outputs_per_row=lanes*4, full_cases=full_count,
                            smoke_cases=smoke_count, helper_entries=entries, passed=True))
        if version == "C34-colmajor256":
            workers = {int(a):int(b) for a,b in re.findall(r"SVE_WORKER_(\d+)_ACTUAL_ENTRIES=(\d+)", texts[1])}
            assert set(workers) == set(range(threads)) and all(workers.values())
            configs[-1]["worker_entries"] = workers
        else:
            found = re.findall(r"^PREFETCH_CASE kh=(\d+) ow=(\d+) oh=(\d+) hints=(\d+) expected=(\d+)$", texts[1], re.M)
            want = [(kh,lanes*4+delta,height,4*((lanes*4+delta)//(lanes*4))*(height//4)*(kh-5)) for kh in (5,6,7) for delta in (-1,0,1) for height in (4,16)]
            assert len(found) == len(want) == 18
            for actual,expected_case in zip(found,want):
                kh,width,height,hints,expected_hints = map(int,actual)
                assert (kh,width,height,hints) == expected_case and hints == expected_hints
            assert re.findall(r"^PREFETCH_PROBE_PASS cases=(\d+) total_hints=(\d+)$",texts[1],re.M) == [("18","120")]
            configs[-1]["prefetch_probe_cases"] = 18
            configs[-1]["prefetch_hints"] = 120
            configs[-1]["prefetch_case_counts_verified"] = True
for name in ('build-guard.log', 'build-dispatch.log', 'build-assembly.log'):
    assert (raw / name).is_file()
    assert not re.search(r'\berror:', (raw / name).read_text(), re.I)
assembly = json.loads((base / 'assembly-review.json').read_text())
assert assembly['review_complete'] is True
actual_fma = len(re.findall(r'^\s*(?:fmla|fmls|fmadd|fmsub|fnmadd|fnmsub)\b', (raw / 'conv2d-sve.s').read_text(), re.M))
assert actual_fma == assembly['whole_source_fma_count'] == 0
result = dict(status='passed', complete=True, candidate=job['version'], job_id=job['job_id'],
    scheduler=scheduler, exit_code=0, source_hashes_verified=True, source_hashes=expected,
    source_manifest_remote_matches=True,
    source_hash_verification_scope='Existing automated transport manifest matches remote wrapper SHA entries; no separate repeated manual byte-hash audit.',
    extra_manual_hash_audit=False, accumulators_per_row=4, rows_per_group=4, total_accumulators=16,
    configurations=configs, full_cases=full_count*6, smoke_cases=smoke_count*6, prefetch_probe_cases=probe_count*6, total_cases=plan["total"],
    coverage_extension=dict(purpose='C34: 256-column chunk boundaries and all-worker participation. C35: kh5/6/7 prefetch trigger counts at 4VL boundary and one/four row groups.'),
    executed_locally=False, executed_remotely=True, sanitizer='not_run', issues=[],
    assembly=assembly, evidence_directory='raw')
(base / 'validation.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(candidate=job['version'], job_id=job['job_id'], complete=True, total_cases=plan["total"], configurations=configs), indent=2))
