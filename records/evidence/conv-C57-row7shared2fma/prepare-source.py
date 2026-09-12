"""One-shot lightweight C57 text preparation; no compiler or operator invocation."""
from collections import Counter
from datetime import datetime, timezone
import difflib
import fcntl
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
PARENT = ROOT / '.runs/conv/C52-row7x3shared2'
PARENT_SHA = '8cf5dc086d0fd6c7ce21f0f5cfd2bbf50da820a9c18e12de328e970a28712bf7'
BEGIN = '        /* Shared input rows advance all seven outputs in strict kernel-column order. */\n'
END = '        /* Trailing input row kh+0: finish output 1 and advance later outputs. */\n'
REMAINDER = '            for (; ik < kw; ++ik) {\n'
PATTERN = re.compile(r'(?m)^([ \t]*)([a-g][0-2]) = svadd_f32_x\(pg, \2, svmul_f32_x\(pg, v, ([a-g]k)\)\);$')


def sha(data):
    return hashlib.sha256(data).hexdigest()


with (ROOT / '.runs/.workflow.lock').open('a+') as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    assert not (BASE / 'source-audit.json').exists(), 'Already prepared; never overwrite'
    meta_path = BASE / 'experiment.json'
    creation_bytes = meta_path.read_bytes()
    meta = json.loads(creation_bytes)
    assert meta['status'] == 'planned' and meta['parent'] == 'C52-row7x3shared2'
    current = BASE / 'source/conv2d.c'
    original = (PARENT / 'source/conv2d.c').read_bytes()
    assert sha(original) == PARENT_SHA and current.read_bytes() == original
    assert original == (PARENT / 'sve-correctness-sep13t/raw/conv2d.c').read_bytes()
    text = original.decode('utf-8')
    assert text.count(BEGIN) == 1 and text.count(END) == 1
    start = text.index(BEGIN)
    end = text.index(END, start)
    shared = text[start:end]
    assert shared.count(REMAINDER) == 1
    main, remainder = shared.split(REMAINDER)
    main_matches = list(PATTERN.finditer(main))
    remainder_matches = list(PATTERN.finditer(remainder))
    expected_order = [row + str(lane) for lane in range(3) for row in 'abcdefg']
    assert [m[2] for m in main_matches] == expected_order * 2
    assert [m[2] for m in remainder_matches] == expected_order
    assert all(m[3] == m[2][0] + 'k' for m in main_matches + remainder_matches)
    assert len(main_matches) == 42 and len(remainder_matches) == 21
    changed_shared, count = PATTERN.subn(lambda m: f'{m[1]}{m[2]} = svmla_f32_x(pg, {m[2]}, v, {m[3]});', shared)
    assert count == 63 and changed_shared.count('svmla_f32_x(') == 63
    changed = text[:start] + changed_shared + text[end:]
    inverse = re.compile(r'(?m)^([ \t]*)([a-g][0-2]) = svmla_f32_x\(pg, \2, v, ([a-g]k)\);$')
    restored = inverse.sub(lambda m: f'{m[1]}{m[2]} = svadd_f32_x(pg, {m[2]}, svmul_f32_x(pg, v, {m[3]}));', changed)
    assert restored.encode('utf-8') == original
    assert changed[:start] == text[:start] and changed[start + len(changed_shared):] == text[end:]
    old_lines, new_lines = text.splitlines(), changed.splitlines()
    changed_lines = [i + 1 for i, (a, b) in enumerate(zip(old_lines, new_lines)) if a != b]
    assert len(old_lines) == len(new_lines) and len(changed_lines) == 63
    unchanged = {}
    for name in ['README.md', 'bench_conv.c', 'run.sh']:
        data = (BASE / 'source' / name).read_bytes()
        assert data == (PARENT / 'source' / name).read_bytes()
        unchanged[name] = {'sha256': sha(data), 'bytes': len(data), 'equals_parent': True}
    current.write_bytes(changed.encode('utf-8'))
    patch = ''.join(difflib.unified_diff(text.splitlines(True), changed.splitlines(True),
        fromfile='C52-row7x3shared2/source/conv2d.c', tofile='C57-row7shared2fma/source/conv2d.c'))
    (BASE / 'candidate.patch').write_text(patch)
    assert meta_path.read_bytes() == creation_bytes
    hashes = {p.name: sha(p.read_bytes()) for p in sorted((BASE / 'source').iterdir()) if p.is_file()}
    audit = {
        'created_at': datetime.now(timezone.utc).isoformat(),
        'candidate': 'C57-row7shared2fma', 'parent': 'C52-row7x3shared2',
        'parent_diagnostic_job_id': '1582134',
        'parent_frozen_directory': '.runs/conv/C52-row7x3shared2/sve-correctness-sep13t',
        'parent_source_sha256': PARENT_SHA,
        'source_hashes': hashes, 'conv2d_bytes': current.stat().st_size,
        'changed_files': ['conv2d.c'], 'unchanged_submission_files': unchanged,
        'changed_source_lines': changed_lines,
        'shared_region_lines': [text[:start].count('\n') + 1, text[:end].count('\n')],
        'main_replacements': 42, 'remainder_replacements': 21, 'total_replacements': count,
        'per_accumulator_replacements': dict(Counter(m[2] for m in main_matches + remainder_matches)),
        'accumulator_statement_order_per_column': expected_order,
        'main_columns': ['ik', 'ik+1'], 'main_loop_condition': 'kw - ik >= 2',
        'remainder_loop_condition': 'ik < kw', 'remainder_max_columns': 1,
        'outside_shared_bytes_unchanged': True, 'inverse_restores_entire_parent_source': True,
        'other_twelve_stages_dispatch_fallback_unchanged': True,
        'source_explicit_svmla_count': changed.count('svmla_f32_x('),
        'creation_snapshot_sha256': sha(creation_bytes), 'creation_snapshot_modified': False,
        'compiled': False, 'executed': False, 'diagnostic_pass': None,
        'official_tolerance_feasibility': 'not_run', 'performance_measured': False,
        'note': 'Explicit fusion may change rounding. Original T bitwise/FMA0 evidence is parent provenance only, not C57 acceptance. First future gate is unchanged official four-case three-suite absolute-error feasibility under separate root GO.'
    }
    (BASE / 'source-audit.json').write_text(json.dumps(audit, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'candidate': audit['candidate'], 'conv2d_bytes': audit['conv2d_bytes'],
        'source_sha256': hashes['conv2d.c'], 'main_replacements': 42, 'remainder_replacements': 21,
        'total_replacements': count, 'creation_snapshot_modified': False}))
