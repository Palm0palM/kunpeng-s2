#!/usr/bin/env python3
"""Export a new, redacted public CONV evidence tree without changing originals."""
import argparse
import datetime
import difflib
import hashlib
import ipaddress
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_VERSIONS = ['C0-r3', 'C0-r4', 'C4-b24', 'C5-b48', 'C6-row2']
TEXT_SUFFIXES = {'.json', '.log', '.txt', '.md', '.c', '.h', '.py', '.sh', '.patch', '.diff', '.csv'}
MAX_BYTES = 2 * 1024 * 1024
IP_RE = re.compile(r'(?<![\w.])(?:\d{1,3}\.){3}\d{1,3}(?![\w.])')
NODE_RE = re.compile(r'(?<![A-Za-z0-9_])(?:cn\d+|login\d+)(?![A-Za-z0-9_])', re.I)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def encoded(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode()


def private_ip(value):
    try:
        address = ipaddress.ip_address(value)
        return address.is_private or address.is_loopback or address.is_link_local
    except ValueError:
        return False


class Redactor:
    def __init__(self, texts):
        # Read only host/user values into memory; never serialize the config or map.
        self.values = {}
        for path in sorted((ROOT / 'config').glob('*.local.json')):
            try:
                config = json.loads(path.read_text())
            except (OSError, ValueError):
                continue
            def visit(item):
                if isinstance(item, dict):
                    for key, value in item.items():
                        if key.lower() in {'host', 'hostname', 'ssh_host'} and isinstance(value, str) and value:
                            self.values[value] = 'CLUSTER_HOST'
                        elif key.lower() in {'user', 'username', 'ssh_user'} and isinstance(value, str) and value:
                            self.values[value] = 'REDACTED_USER'
                        else:
                            visit(value)
                elif isinstance(item, list):
                    for value in item:
                        visit(value)
            visit(config)
        corpus = '\n'.join(texts)
        for user in sorted(set(re.findall(r'/Users/([^/\s"\'\\]+)', corpus))):
            self.values.setdefault(user, 'LOCAL_USER')
        nodes = sorted(set(NODE_RE.findall(corpus)), key=str.lower)
        counters = {'cn': 0, 'login': 0}
        for node in nodes:
            kind = 'cn' if node.lower().startswith('cn') else 'login'
            counters[kind] += 1
            self.values[node] = ('COMPUTE_NODE_' if kind == 'cn' else 'LOGIN_NODE_') + str(counters[kind])
        addresses = sorted({x for x in IP_RE.findall(corpus) if private_ip(x)})
        for index, address in enumerate(addresses, 1):
            self.values.setdefault(address, 'PRIVATE_IP_' + str(index))

    def __call__(self, text):
        # Paths must be replaced before usernames to avoid leaving personal homes.
        text = re.sub(r'/Users/[^/\s"\'\\]+', 'LOCAL_USER_HOME', text)
        text = re.sub(r'/home/share/[^/\s"\'\\]+', 'CLUSTER_USER_HOME', text)
        text = re.sub(r'/home/[^/\s"\'\\]+', 'CLUSTER_USER_HOME', text)
        # Scheduler output may be a JSON string containing an escaped tab/newline.
        # The final t/n/r is a serialization delimiter, not a username prefix.
        left = r'(?:(?<![A-Za-z0-9_])|(?<=\\[nrt])|(?<=\\u000[9aAdD]))'
        for value in sorted(self.values, key=len, reverse=True):
            text = re.sub(left + re.escape(value) + r'(?![A-Za-z0-9_])', self.values[value], text)
        return text


def markdown(value):
    return str(value or '').replace('|', '\\|').replace('\n', ' ')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path, help='New directory; existing paths are refused')
    parser.add_argument('--versions', nargs='+', default=DEFAULT_VERSIONS)
    args = parser.parse_args()
    output = args.output.expanduser().absolute()
    if output.exists() or output.is_symlink():
        parser.error('--output 必须是不存在的新目录，不覆盖任何文件')
    resolved = output.resolve()
    protected = ['.runs', '.git', 'records', 'conv', 'zgemm', 'trsm', 'config', 'tools', 'tests', 'docs', 'prompts']
    if resolved == ROOT or any(resolved == ROOT / x or ROOT / x in resolved.parents for x in protected):
        parser.error('--output 不能位于源码、原记录或内部配置目录内')
    versions = list(dict.fromkeys(args.versions))
    if any(not re.fullmatch(r'C\d+(?:-[A-Za-z0-9]+)*', v) for v in versions):
        parser.error('--versions 只接受完整 CONV 版本 ID，不接受路径或通配符')
    payloads, records, skipped = {}, {}, []
    def collect(target, data, origin):
        data.decode('utf-8')
        if target in payloads:
            raise ValueError('重复导出路径: ' + target)
        payloads[target] = (data, origin)
    for version in versions:
        record_path = ROOT / 'records/experiments/conv' / (version + '.json')
        raw = record_path.read_bytes()
        record = json.loads(raw)
        if record.get('version') != version or record.get('problem') != 'conv':
            raise ValueError('记录身份不匹配: ' + version)
        records[version] = record
        collect('records/experiments/conv/' + version + '.json', raw, record_path.relative_to(ROOT).as_posix())
        run = ROOT / '.runs/conv' / version
        if run.exists():
            for path in sorted(run.rglob('*')):
                rel = path.relative_to(run)
                if path.is_symlink() or not path.is_file() or 'source' in rel.parts or any(p.endswith('.dSYM') for p in rel.parts):
                    continue
                if path.suffix.lower() not in TEXT_SUFFIXES or path.stat().st_size > MAX_BYTES:
                    skipped.append({'version': version, 'path': rel.as_posix(), 'reason': '非文本白名单或超过2MiB'})
                    continue
                data = path.read_bytes()
                try:
                    data.decode('utf-8')
                except UnicodeDecodeError:
                    skipped.append({'version': version, 'path': rel.as_posix(), 'reason': '非UTF-8文本'})
                    continue
                if b'\x00' in data:
                    skipped.append({'version': version, 'path': rel.as_posix(), 'reason': '二进制内容'})
                    continue
                collect('records/evidence/conv-' + version + '/' + rel.as_posix(), data, path.relative_to(ROOT).as_posix())
        parent = record.get('parent')
        if parent:
            if not re.fullmatch(r'C\d+(?:-[A-Za-z0-9]+)*', parent):
                raise ValueError('非法父版本 ID')
            parent_record = json.loads((ROOT / 'records/experiments/conv' / (parent + '.json')).read_text())
            parent_source = ROOT / '.runs/conv' / parent / 'source'
            if not parent_source.exists():
                parent_source = ROOT / 'conv'
            candidate_source = run / 'source'
            patch = []
            for name in sorted(set(parent_record['source_hashes']) | set(record['source_hashes'])):
                rel = Path(name)
                if rel.is_absolute() or '..' in rel.parts:
                    raise ValueError('非法源码路径')
                old_path, new_path = parent_source / rel, candidate_source / rel
                old = old_path.read_bytes() if name in parent_record['source_hashes'] else b''
                new = new_path.read_bytes() if name in record['source_hashes'] else b''
                for blob, expected in ((old, parent_record['source_hashes'].get(name)), (new, record['source_hashes'].get(name))):
                    if expected is not None and sha(blob) != expected:
                        raise ValueError('源码与记录哈希不符: ' + version + '/' + name)
                patch.extend(difflib.unified_diff(old.decode().splitlines(True), new.decode().splitlines(True), fromfile='a/' + name, tofile='b/' + name))
            collect('records/patches/conv-' + version + '.patch', ''.join(patch).encode(), 'generated:parent-to-candidate-diff')
    redactor = Redactor([data.decode() for data, _ in payloads.values()])
    manifest = {'schema_version': 1, 'exported_at': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'versions': versions,
                'notice': '公开文件已脱敏，不是原件；原记录中的SHA保留原始意义。只用public_sha256验证此公开副本。', 'files': [], 'skipped': skipped}
    output.mkdir(parents=True)
    for target, (raw, origin) in sorted(payloads.items()):
        public = redactor(raw.decode()).encode()
        dest = output / target
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(public)
        manifest['files'].append({'path': target, 'source': origin, 'original_sha256': sha(raw), 'public_sha256': sha(public), 'original_bytes': len(raw), 'public_bytes': len(public), 'redacted': raw != public})
    table = ['# CONV 版本与测量记录', '', '所有耗时均为内部比较指标，不是官方分数。空白表示尚无测量；未完成、失败与退化实验也保留。每版完整策略、环境、原始测量字段与结论见 JSON，所有公开证据经过脱敏。', '', '| 版本 | 父版本 | 状态 | 优化策略 | 各用例中位数 ms（按记录顺序） | 总中位数 ms | 可晋级 | 结论 |', '| --- | --- | --- | --- | --- | --- | --- | --- |']
    for version, record in records.items():
        comparison = record.get('comparison', {})
        if record.get('reference_only') is True or record.get('promotion_allowed') is False:
            eligible = '仅参考，不晋级'
        else:
            eligible = '是' if comparison.get('eligible') is True else '否' if comparison.get('eligible') is False else '已晋级' if record.get('promoted_at') else '待判定' if record.get('parent') else '基线复测'
        cases = '; '.join('×'.join(map(str, c['dims'])) + ': ' + format(c['median_ms'], '.2f') for c in record.get('cases', []) if c.get('median_ms') is not None)
        total = format(record['total_median_ms'], '.2f') if record.get('total_median_ms') is not None else ''
        conclusion = record.get('decision_note') or record.get('failure') or '; '.join(comparison.get('reasons', [])) or record.get('decision') or ('尚未取得完整远程测量' if not record.get('verified') else '已验证；按共同基线比较后决定')
        version_link = '[' + version + '](../records/experiments/conv/' + version + '.json)'
        row = [version_link, record.get('parent'), record.get('status'), record.get('strategy'), cases, total, eligible, conclusion]
        table.append('| ' + ' | '.join(markdown(redactor(str(x))) if x is not None else '' for x in row) + ' |')
    summary = '\n'.join(table) + '\n'
    (output / 'docs').mkdir(exist_ok=True)
    (output / 'docs/CONV_ROUND_RECORDS.md').write_text(summary)
    publication = '''# CONV 公开证据说明

本目录是选定 CONV 实验的公开副本。实际私网地址、计算账号、个人目录及内部节点已替换为明显且在本次导出内一致的占位符。原始实验 JSON 字段、性能数值、正确性、用例、编译条件与原始源码/产物 SHA 保留。

**公开日志经过脱敏，不再与超算下载的原件逐字节相同。原件继续保存在本地 `.runs/conv/<版本>/`，导出器没有修改原始文件。** 不得用公开日志冒充原件通过自动验证，也不要改写原记录中的 source_hashes、artifacts_sha256 或其他 SHA 字段以匹配公开日志。

`records/conv-publication.json` 为每个导出源文件和生成的候选补丁分别登记 original_sha256 与 public_sha256。前者是脱敏前内容的 SHA，后者才用于公开副本完整性校验。补丁的 original_sha256 指生成但尚未脱敏的补丁内容；其源码身份由实验 source_hashes 核对。生成的中文表和本说明没有对应原始文件。占位符映射及认证配置不公开。

只有指定版本被导出。局部测试仅包括小于等于2MiB的 UTF-8 白名单文本；可执行文件、共享库、调试二进制和大文件不发布。跳过项目见 manifest。候选补丁基于父版本逐文件哈希核实后生成，可复核改动；公开基线与代码由发布者另外保存。没有成绩的版本留空并标明当前状态，不填估算值。
'''
    (output / 'PUBLICATION-CONV.md').write_text(publication)
    (output / 'records/conv-publication.json').write_bytes(encoded(json.loads(redactor(json.dumps(manifest)))))
    print('已导出 %d 个版本、%d 份文本证据；原始文件未修改。' % (len(versions), len(payloads)))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        # Error paths may contain personal directories: only generic error category.
        print('导出失败：请检查版本记录、源码哈希、输出目录及UTF-8文本完整性（%s）。' % type(error).__name__, file=sys.stderr)
        sys.exit(1)
