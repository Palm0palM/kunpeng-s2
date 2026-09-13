"""One-shot C58 source text insertion only; no compiler/operator/SSH/job."""
from pathlib import Path
import difflib
import fcntl
import hashlib
import json

BASE = Path(__file__).resolve().parent
ROOT = Path(__file__).resolve().parents[3]
VERSION = 'C58-row7boundaryu2'
PARENT = 'C52-row7x3shared2'
PARENT_SHA = '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'
FROZEN = ROOT / '.runs/conv' / PARENT / 'sve-correctness-sep13t'
FILES = ['README.md', 'bench_conv.c', 'run.sh', 'conv2d.c']
LOOP = '            for (int ik = 0; ik < kw; ++ik) {\n'
PRAGMA = '            #pragma GCC unroll 2\n'


def hashes(folder):
    return {name: hashlib.sha256((folder / name).read_bytes()).hexdigest() for name in FILES}


with (ROOT / '.runs/.workflow.lock').open('a') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    record_path = ROOT / 'records/experiments/conv' / (VERSION + '.json')
    record = json.loads(record_path.read_text())
    assert record['status'] == 'planned' and record['parent'] == PARENT
    assert not (BASE / 'source-audit.json').exists(), 'One-shot source preparation; do not overwrite'
    assert (BASE / 'experiment.json').read_bytes() == (BASE / 'creation-experiment.json').read_bytes()
    assert record_path.read_bytes() == (BASE / 'creation-record.json').read_bytes()
    parent_record = json.loads((ROOT / 'records/experiments/conv' / (PARENT + '.json')).read_text())
    before = hashes(BASE / 'source')
    assert before == hashes(ROOT / '.runs/conv' / PARENT / 'source') == parent_record['source_hashes']
    assert before['conv2d.c'] == PARENT_SHA
    validation = json.loads((FROZEN / 'validation.json').read_text())
    freeze = json.loads((FROZEN / 'freeze-source.json').read_text())
    assert validation['candidate'] == PARENT and str(validation['job_id']) == '1582134'
    assert validation['status'] == 'passed' and validation['complete'] is True and validation['total_cases'] == 37128
    assert freeze['candidate'] == PARENT and str(freeze['job_id']) == '1582134' and freeze['mode'] == 'passed'
    original = (BASE / 'source/conv2d.c').read_bytes()
    assert original == (FROZEN / 'source/conv2d.c').read_bytes() == (FROZEN / 'raw/conv2d.c').read_bytes()
    text = original.decode()
    begin = text.index('static void conv_sve_rowseven(')
    end = text.index('\n#endif', begin)
    shared = text.index('        /* Shared input rows advance all seven outputs in strict kernel-column order. */', begin)
    trailing = text.index('        /* Trailing input row kh+0:', shared)
    assert text[begin:end].count(LOOP) == 12
    assert text[begin:shared].count(LOOP) == text[trailing:end].count(LOOP) == 6
    assert LOOP not in text[shared:trailing] and PRAGMA not in text
    markers = [f'        /* Input row {i}: start output {i} and advance earlier outputs. */' for i in range(6)]
    markers += [f'        /* Trailing input row kh+{i}: finish output {i+1} and advance later outputs. */' for i in range(6)]
    offsets = []
    for marker in markers:
        assert text[begin:end].count(marker) == 1
        anchor = text.index(marker, begin)
        position = text.index(LOOP, anchor)
        assert position < text.index('        /*', anchor + len(marker)) < end
        offsets.append(position)
    assert offsets == sorted(set(offsets)) and len(offsets) == 12
    expected = [1280,1302,1329,1361,1398,1440,1623,1668,1708,1743,1773,1798]
    assert [text[:p].count('\n') + 1 for p in offsets] == expected
    result = text
    for position in reversed(offsets):
        result = result[:position] + PRAGMA + result[position:]
    assert result.count(PRAGMA) == 12 and result.replace(PRAGMA, '') == text
    assert result[result.index('        /* Shared input rows'):result.index('        /* Trailing input row kh+0:')] == text[shared:trailing]
    candidate = BASE / 'source/conv2d.c'
    candidate.write_bytes(result.encode())
    after = hashes(BASE / 'source')
    assert all(after[name] == before[name] for name in FILES if name != 'conv2d.c')
    patch = ''.join(difflib.unified_diff(text.splitlines(True), result.splitlines(True),
        fromfile='C52-T-frozen/source/conv2d.c', tofile=VERSION + '/source/conv2d.c'))
    with (BASE / 'candidate.patch').open('x') as output:
        output.write(patch)
    locations = [dict(stage=('input_' + str(i) if i < 6 else 'trailing_' + str(i-6)),
        parent_loop_line=line, candidate_pragma_line=line+i, candidate_loop_line=line+i+1)
        for i,line in enumerate(expected)]
    audit = dict(candidate=VERSION, source_parent=PARENT, parent_diagnostic_job_id='1582134',
        parent_frozen_directory=str(FROZEN.relative_to(ROOT)), source_hashes=after,
        parent_source_hashes=before, changed_files=['conv2d.c'], pragma='GCC unroll 2',
        inserted_lines=12, inserted_bytes=len(result.encode())-len(original), loop_locations=locations,
        removing_only_inserted_pragma_lines_restores_full_parent_bytes=True,
        shared_two_column_main_and_u1_remainder_unchanged=True, arithmetic_statements_unchanged=True,
        other_helpers_dispatch_tails_fallback_unchanged=True, other_three_submission_files_unchanged=True,
        compiler_flags_unchanged=True, compiled=False, executed=False,
        own_diagnostic_pass=False, performance_measured=False,
        parent_pass_applies_to_parent_bytes_only=True)
    with (BASE / 'source-audit.json').open('x') as output:
        json.dump(audit, output, ensure_ascii=False, indent=2)
        output.write('\n')
    print(json.dumps(dict(candidate=VERSION, source_sha256=after['conv2d.c'],
        source_bytes=len(result.encode()), inserted_lines=12, status='prepared_source_text_only'), indent=2))
