"""Publication integration checks use only synthetic local data; never connect."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    'conv_exporter', Path(__file__).resolve().parents[1] / 'tools/export_conv_records.py')
exporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exporter)


def digest(data):
    return hashlib.sha256(data).hexdigest()


class ExportConvRecordsTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / 'repo'
        self.root.mkdir()
        self.root = self.root.resolve()
        self.output = self.root.parent / 'publication'
        self.root_patch = patch.object(exporter, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)
        config = self.root / 'config'
        config.mkdir()
        (config / 'cluster.local.json').write_text(json.dumps({
            'host': '10.23.45.67', 'user': 'fixture_calc_user',
            'unrelated_setting': 'CONFIG_ONLY_VALUE_MUST_NOT_BE_PUBLISHED'}))
        self.records = self.root / 'records/experiments/conv'
        self.records.mkdir(parents=True)
        self.runs = self.root / '.runs/conv'
        self.originals = {}
        for version, parent, source in [
            ('C0-r3', None, b'void conv2d(void) { /* baseline */ }\n'),
            ('C4-b24', 'C0-r3', b'void conv2d(void) { /* candidate */ }\n'),
        ]:
            run = self.runs / version
            (run / 'source').mkdir(parents=True)
            (run / 'local').mkdir()
            (run / 'source/conv2d.c').write_bytes(source)
            (run / 'source/run.sh').write_text('#!/bin/sh\nexit 0\n')
            record = {
                'problem': 'conv', 'version': version, 'parent': parent,
                'strategy': 'Compare a smaller tile while retaining strict accumulation',
                'status': 'passed', 'verified': True,
                'source_hashes': {
                    'conv2d.c': digest(source),
                    'run.sh': digest((run / 'source/run.sh').read_bytes())},
                'cases': [{'dims': [20, 30, 3, 3], 'times_ms': [12.25, 12.5, 12.375],
                           'median_ms': 12.375, 'max_error': 0.0}],
                'total_median_ms': 12.375,
                'log_sha256': 'b' * 64,
                'artifacts_sha256': {'benchmark.log': 'c' * 64},
                'machine': {'HOST': 'cn90081'},
            }
            self.originals[version] = record
            (self.records / (version + '.json')).write_text(json.dumps(record))
            (run / 'benchmark.log').write_text(
                'Host=10.23.45.67 user=fixture_calc_user node=cn90081 via login87\n'
                'Source=/Users/fixture_local_user/project/source.c\n'
                'Remote=/home/share/fixture_calc_user/results\n'
                'Other private address=172.20.3.4; time=12.375; max_error=0\n')
            (run / 'local/check_conv.c').write_text(
                '/* Build under /Users/fixture_local_user/checks */\n'
                'int main(void) { return 0; }\n')
            (run / 'local/results.json').write_text(json.dumps({'cases': 418, 'exit_code': 0}))

    def export(self, output=None):
        args = ['export_conv_records.py', '--output', str(output or self.output),
                '--versions', 'C0-r3', 'C4-b24']
        with patch.object(exporter.sys, 'argv', args), contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            exporter.main()

    def test_redaction_preserves_measurements_source_hashes_and_originals(self):
        before = {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        self.export()
        corpus = '\n'.join(p.read_text() for p in self.output.rglob('*') if p.is_file())
        for sensitive in ['10.23.45.67', '172.20.3.4', 'fixture_calc_user',
                          'fixture_local_user', '/Users/', '/home/share/', 'cn90081',
                          'login87', 'CONFIG_ONLY_VALUE_MUST_NOT_BE_PUBLISHED']:
            with self.subTest(sensitive=sensitive):
                self.assertNotIn(sensitive, corpus)
        for placeholder in ['CLUSTER_HOST', 'REDACTED_USER', 'LOCAL_USER_HOME',
                            'CLUSTER_USER_HOME', 'COMPUTE_NODE_', 'LOGIN_NODE_']:
            self.assertIn(placeholder, corpus)
        for version, original in self.originals.items():
            public = json.loads((self.output / 'records/experiments/conv' / (version + '.json')).read_text())
            for key in ['strategy', 'parent', 'cases', 'total_median_ms', 'source_hashes',
                        'log_sha256', 'artifacts_sha256']:
                self.assertEqual(public[key], original[key], key)
        self.assertEqual(before, {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()})
        local_source = self.output / 'records/evidence/conv-C4-b24/local/check_conv.c'
        self.assertIn('int main(void) { return 0; }', local_source.read_text())

    def test_manifest_hashes_track_both_raw_and_public_content(self):
        self.export()
        manifest = json.loads((self.output / 'records/conv-publication.json').read_text())
        changed = []
        for entry in manifest['files']:
            public = (self.output / entry['path']).read_bytes()
            self.assertEqual(entry['public_sha256'], digest(public))
            self.assertEqual(entry['public_bytes'], len(public))
            if not entry['source'].startswith('generated:'):
                raw = (self.root / entry['source']).read_bytes()
                self.assertEqual(entry['original_sha256'], digest(raw))
                self.assertEqual(entry['original_bytes'], len(raw))
                self.assertEqual(entry['redacted'], raw != public)
                if raw != public:
                    changed.append(entry)
        self.assertTrue(changed)
        patch_text = (self.output / 'records/patches/conv-C4-b24.patch').read_text()
        self.assertIn('-void conv2d(void) { /* baseline */ }', patch_text)
        self.assertIn('+void conv2d(void) { /* candidate */ }', patch_text)
        self.assertIn('12.38', (self.output / 'docs/CONV_ROUND_RECORDS.md').read_text())

    def test_binary_disguised_as_log_and_large_files_are_not_exported(self):
        local = self.runs / 'C4-b24/local'
        excluded = {'kernel_test': b'\x7fELF\x00binary', 'libkernel.so': b'\x7fELF\x00binary',
                    'binary.log': b'looks like text\x00but is binary',
                    'non_utf8.log': b'\xff\xfe\xfd',
                    'oversized.log': b'x' * (exporter.MAX_BYTES + 1)}
        for name, content in excluded.items():
            (local / name).write_bytes(content)
        self.export()
        target = self.output / 'records/evidence/conv-C4-b24/local'
        for name in excluded:
            self.assertFalse((target / name).exists(), name)
        self.assertTrue((target / 'check_conv.c').is_file())
        skipped = json.loads((self.output / 'records/conv-publication.json').read_text())['skipped']
        self.assertTrue(set(excluded).issubset({Path(x['path']).name for x in skipped}))

    def test_existing_and_protected_output_directories_are_refused(self):
        self.output.mkdir()
        sentinel = self.output / 'keep.txt'
        sentinel.write_text('User content must survive')
        for output in [self.output, self.root / '.runs/new-export', self.root / 'records/new-export',
                       self.root / 'conv/new-export', self.root / 'tools/new-export']:
            with self.subTest(output=str(output.relative_to(self.root.parent))):
                with self.assertRaises(SystemExit) as caught:
                    self.export(output)
                self.assertEqual(caught.exception.code, 2)
                if output != self.output:
                    self.assertFalse(output.exists())
        self.assertEqual(sentinel.read_text(), 'User content must survive')

    def test_changed_candidate_source_is_rejected_before_publication(self):
        (self.runs / 'C4-b24/source/conv2d.c').write_text('unmeasured changed source\n')
        with self.assertRaisesRegex(ValueError, '源码与记录哈希不符'):
            self.export()
        self.assertFalse(self.output.exists())


if __name__ == '__main__':
    unittest.main()
