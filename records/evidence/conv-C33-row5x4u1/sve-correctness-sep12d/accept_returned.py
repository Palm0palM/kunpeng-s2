"""Read returned diagnostic text only; never compiles or runs operator code."""
import json
import re
from pathlib import Path

base = Path(__file__).resolve().parent / 'C33-row5x4u1'
raw = base / 'raw'
job = json.loads((base / 'job.json').read_text())
scheduler = job['scheduler_status']
assert scheduler['jobId'] == job['job_id']
assert scheduler['status'] == 'SUCCEEDED'
assert scheduler['jobExitCode'] == scheduler['systemExitCode'] == 0
plan = dict(full_per_configuration=40804, smoke_per_configuration=864, configurations=6, total=250008)
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
        for kind, count in (('guard', 40804), ('dispatch', 864)):
            log = (raw / f'{kind}-vl{sve_bytes}-t{threads}.log').read_text()
            assert len(re.findall('^' + re.escape(header) + '$', log, re.M)) == 1
            assert len(re.findall(r'^PASS: ' + str(count) + r' convolution cases;', log, re.M)) == 1
            assert not re.search(r'\bFAIL(?:ED)?\b', log)
            texts.append(log)
        entries = {}
        for name in ('prefix', 'tail', 'rowpair', 'rowtriple', 'rowquad', 'rowquint'):
            values = re.findall('SVE_' + name.upper() + r'_ACTUAL_ENTRIES=(\d+)', texts[1])
            assert len(values) == 1
            entries[name] = int(values[0])
        assert all(entries[name] > 0 for name in ('rowpair', 'rowtriple', 'rowquad', 'rowquint'))
        configs.append(dict(sve_bytes=sve_bytes, threads=threads, lanes=lanes,
                            block_outputs_per_row=lanes*4, full_cases=40804,
                            smoke_cases=864, helper_entries=entries, passed=True))
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
    extra_manual_hash_audit=False, accumulators_per_row=4, rows_per_group=5, total_accumulators=20,
    configurations=configs, full_cases=244824, smoke_cases=5184, total_cases=250008,
    coverage_extension=dict(kernel_shapes_added=[[5,1],[5,2],[5,3],[5,4],[5,5],[5,6],[6,5]], output_heights=[1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,19,20], purpose='Five-row core and remaining1-4 rows, kh4/5/6 fallback boundaries, four quint workers.'),
    executed_locally=False, executed_remotely=True, sanitizer='not_run', issues=[],
    assembly=assembly, evidence_directory='raw')
(base / 'validation.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(candidate=job['version'], job_id=job['job_id'], complete=True, total_cases=250008, configurations=configs), indent=2))
