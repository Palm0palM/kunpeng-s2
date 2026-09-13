#!/usr/bin/env python3
"""One-shot, text-only C56 source preparation. Never compiles or runs an operator."""
import difflib
import fcntl
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = Path(__file__).resolve().parent
PARENT = ROOT / '.runs/conv/C55-row7x3shared3/source'
FROZEN = ROOT / '.runs/conv/C55-row7x3shared3/sve-correctness-sep13ac'
RECORD = ROOT / 'records/experiments/conv/C56-row7shared3fence.json'
EXPECTED = 'cc6b51603928d7f7825f86ac09d139ec3e3846c8c40946e16fa9d110eb1a8138'
NAMES = ('README.md', 'bench_conv.c', 'conv2d.c', 'run.sh')
AFTER = (1530, 1571, 1612)
ASM = b'''                __asm__ __volatile__(""
                    :
                    : "w"(a0), "w"(a1), "w"(a2),
                      "w"(b0), "w"(b1), "w"(b2),
                      "w"(c0), "w"(c1), "w"(c2),
                      "w"(d0), "w"(d1), "w"(d2),
                      "w"(e0), "w"(e1), "w"(e2),
                      "w"(f0), "w"(f1), "w"(f2),
                      "w"(g0), "w"(g1), "w"(g2)
                    : "memory");
'''

def sha(data):
    return hashlib.sha256(data).hexdigest()

def write_new(name, data):
    with (BASE / name).open('xb') as handle:
        handle.write(data)

def main():
    with (ROOT / '.runs/.workflow.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        assert BASE.name == 'C56-row7shared3fence'
        assert not (BASE / 'source-audit.json').exists(), 'Preparation already performed'
        initial_record = json.loads(RECORD.read_text())
        assert initial_record['version'] == BASE.name and initial_record['parent'] == 'C55-row7x3shared3'
        assert initial_record['status'] == 'planned'
        assert (BASE / 'creation-experiment.json').read_bytes() == (BASE / 'experiment.json').read_bytes()
        assert (BASE / 'creation-record.json').read_bytes() == RECORD.read_bytes()
        before = {name: (BASE / 'source' / name).read_bytes() for name in NAMES}
        assert all(before[name] == (PARENT / name).read_bytes() for name in NAMES)
        original = before['conv2d.c']
        assert sha(original) == EXPECTED
        assert original == (FROZEN / 'source/conv2d.c').read_bytes()
        freeze = json.loads((FROZEN / 'freeze-source.json').read_text())
        assert freeze['candidate'] == 'C55-row7x3shared3' and freeze['job_id'] == '1582860'
        assert freeze['mode'] == 'passed'
        lines = original.splitlines(keepends=True)
        assert all(lines[n - 1] == b'                }\n' for n in AFTER)
        assert b'const int column = ik;' in b''.join(lines[1488:1530])
        assert b'const int column = ik + 1;' in b''.join(lines[1530:1571])
        assert b'const int column = ik + 2;' in b''.join(lines[1571:1612])
        assert ASM not in original and ASM.count(b'"w"(') == 21
        result = b''.join(line + (ASM if n in AFTER else b'') for n, line in enumerate(lines, 1))
        assert result.count(ASM) == 3 and result.replace(ASM, b'') == original
        patch = ''.join(difflib.unified_diff(
            original.decode('utf-8').splitlines(keepends=True),
            result.decode('utf-8').splitlines(keepends=True),
            fromfile='a/.runs/conv/C55-row7x3shared3/source/conv2d.c',
            tofile='b/.runs/conv/C56-row7shared3fence/source/conv2d.c')).encode('utf-8')
        assert patch.count(b'+                __asm__ __volatile__(""') == 3
        current = dict(before)
        current['conv2d.c'] = result
        audit = {
            'candidate': BASE.name,
            'source_parent': 'C55-row7x3shared3',
            'parent_diagnostic_job_id': '1582860',
            'parent_frozen_directory': str(FROZEN.relative_to(ROOT)),
            'parent_production_source_sha256': EXPECTED,
            'parent_assembly_sha256': '0843c7259fdcb63d78d37965de48c229f81a505f59df81eb579fd792452aa39c',
            'hypothesis_source': '.runs/conv/sep13-c55-next-hypothesis.md',
            'hypothesis_source_sha256': sha((ROOT / '.runs/conv/sep13-c55-next-hypothesis.md').read_bytes()),
            'prepared_at': datetime.now(timezone.utc).isoformat(),
            'creation_source_hashes': {name: sha(data) for name, data in before.items()},
            'current_source_hashes': {name: sha(data) for name, data in current.items()},
            'current_source_bytes': {name: len(data) for name, data in current.items()},
            'changed_submission_files': ['conv2d.c'],
            'unchanged_submission_files': [name for name in NAMES if name != 'conv2d.c'],
            'insert_after_parent_lines': list(AFTER),
            'inserted_candidate_line_ranges': [[1531, 1540], [1582, 1591], [1633, 1642]],
            'identical_insertions': 3,
            'lines_added': 30,
            'bytes_added': len(result) - len(original),
            'removing_only_inserted_asm_recovers_parent_bytes': True,
            'all_existing_source_bytes_preserved_in_order': True,
            'arithmetic_loop_remainder_other_stages_dispatch_unchanged': True,
            'asm': {
                'template': '',
                'volatile': True,
                'outputs': [],
                'read_only_w_inputs_in_order': [row + str(vector) for row in 'abcdefg' for vector in range(3)],
                'input_count': 21,
                'memory_clobber': True,
                'register_clobbers': [],
                'source_template_hardware_instructions': 0,
                'compiler_acceptance_verified': False,
                'emitted_instructions_or_markers_observed': False
            },
            'shared_main_columns': 3,
            'shared_remainder_source_columns': 1,
            'shared_remainder_max_columns': 2,
            'semantic_stage_count': 13,
            'compiled': False,
            'operator_executed': False,
            'verified': False,
            'own_diagnostic_pass': False,
            'parent_pass_inherited': False,
            'performance_measured': False,
            'job_created': False,
            'local_operations': ['read/copy source bytes', 'insert fixed text', 'SHA256', 'unified text diff'],
            'scope': 'Source-only preparation. Does not authorize compiler, diagnostic, performance, package or promotion.'
        }
        write_new('candidate.patch', patch)
        (BASE / 'source/conv2d.c').write_bytes(result)
        assert all((BASE / 'source' / name).read_bytes() == current[name] for name in NAMES)
        write_new('source-audit.json', (json.dumps(audit, ensure_ascii=False, indent=2) + '\n').encode('utf-8'))
        print('SOURCE_SHA256=' + sha(result))
        print('SOURCE_BYTES=' + str(len(result)))
        print('INSERTED_ASM=3 READ_ONLY_INPUTS_EACH=21 OUTPUTS_EACH=0 MEMORY_CLOBBER=true')
        print('ONLY_CONV2D_C_CHANGED=true PARENT_RECOVERED_BY_REMOVING_INSERTIONS=true')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
