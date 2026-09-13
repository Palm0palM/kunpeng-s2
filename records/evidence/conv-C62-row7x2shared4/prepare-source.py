"""Prepare C62 source only: joint 7x2VL/shared4 tile hypothesis; no operator work."""
from pathlib import Path
import difflib,json,re,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'));sys.dont_write_bytecode=True
import experiment as e
VERSION='C62-row7x2shared4';PARENT='C58-r1'
run=ROOT/'.runs/conv'/VERSION
assert not run.exists() and not e.record_path('conv',VERSION).exists()
assert e.read_json(ROOT/'records/best.json')['conv']==PARENT
assert e.read_json(ROOT/'outputs/conv-best.json')['label']=='C7'
parent=ROOT/'.runs/conv'/PARENT/'source'
s=(parent/'conv2d.c').read_text()
assert e.source_files(ROOT/'conv')==e.get_record('conv',PARENT)['source_hashes']
begin=s.index('static void conv_sve_rowseven(')
end=s.index('\n}\n#endif',begin)+2
old=s[begin:end];f=old
assert f.count('const int block = 3 * lanes;')==1
f=f.replace('const int block = 3 * lanes;','const int block = 2 * lanes;')
# Remove only explicit vector-2 input scopes in this helper. Each scope has
# one full input load and updates some subset of independent output rows.
lines=f.splitlines(True);kept=[];removed_scopes=0;i=0
while i<len(lines):
    if lines[i].strip()=='{' and i+1<len(lines) and re.fullmatch(r'\s*const svfloat32_t v = svld1\(pg, row \+ (?:ik|column) \+ 2 \* lanes\);\n',lines[i+1]):
        indent=lines[i][:-2]
        j=i+2
        while j<len(lines) and lines[j]!=indent+'}\n':j+=1
        assert j<len(lines)
        body=''.join(lines[i+2:j])
        assert body and all(re.fullmatch(r'\s*[a-g]2 = svadd_f32_x\(pg, [a-g]2, svmul_f32_x\(pg, v, [a-g]k\)\);\n',x) for x in lines[i+2:j])
        removed_scopes+=1;i=j+1
    else:
        kept.append(lines[i]);i+=1
f=''.join(kept)
assert removed_scopes==15  # 12 boundary scopes, two shared columns, one u1 remainder
f,ninit=re.subn(r'^        svfloat32_t [a-g]2 = svdup_n_f32\(0\.0f\);\n','',f,flags=re.M)
f,nstore=re.subn(r'^        svst1\(pg, dst[0-6] \+ i \+ 2 \* lanes, [a-g]2\);\n','',f,flags=re.M)
assert ninit==nstore==7
start=f.index('            for (; kw - ik >= 2; ik += 2) {')
stop=f.index('            for (; ik < kw; ++ik) {',start)
body=['            for (; kw - ik >= 4; ik += 4) {']
for offset in range(4):
    column='ik' if offset==0 else 'ik + '+str(offset)
    body+=['                {',f'                    const int column = {column};']
    for row in 'abcdefg':body.append(f'                    const svfloat32_t {row}k = svdup_n_f32(k{row}[column]);')
    body.append('                    /* One source-level input window; GCC may reschedule. */')
    for vector in range(2):
        body+=['                    {',f'                        const svfloat32_t v = svld1(pg, row + column + {vector} * lanes);']
        for row in 'abcdefg':body.append(f'                        {row}{vector} = svadd_f32_x(pg, {row}{vector}, svmul_f32_x(pg, v, {row}k));')
        body.append('                    }')
    body.append('                }')
body.append('            }');shared='\n'.join(body)+'\n'
f=f[:start]+shared+f[stop:]
f=f.replace('/* Preserve each accumulator order: column ik, then column ik+1. */','/* Preserve each accumulator order: columns ik, ik+1, ik+2, ik+3. */')
assert not re.search(r'\b[a-g]2\b|\+ 2 \* lanes',f)
assert old.count('#pragma GCC unroll 2')==f.count('#pragma GCC unroll 2')==12
assert shared.count('svmul_f32_x(')==shared.count('svadd_f32_x(')==56
assert shared.count('svld1(')==8 and shared.count('svdup_n_f32(')==28
for row in 'abcdefg':
    for vector in range(2):assert len(re.findall(rf'\b{row}{vector} =',shared))==4
assert f.count('svfloat32_t ')==old.count('svfloat32_t ')-4  # -7 accumulators -15 vector scopes +18 quad declarations
candidate=s[:begin]+f+s[end:]
assert candidate[:begin]==s[:begin] and candidate[begin+len(f):]==s[end:]
strategy='Joint tile hypothesis from C7: reduce only rowseven width from 3VL/21 accumulators to 2VL/14 accumulators to make room for shared four-column unrolling. Preserve seven-row dispatch, twelve boundary unroll2 hints, strict per-output ik0..3 separate mul/add, scalar-column remainder and all fallback/companion code. This jointly changes vector width and shared unroll, not an isolated single-parameter experiment.'
def logged(label,args):
    subprocess.run([sys.executable,str(ROOT/'.runs/conv/sep13-run-logged.py'),'sep13-c62-'+label,*args],cwd=ROOT,check=True)
logged('new',[sys.executable,'tools/experiment.py','new','conv',VERSION,'--parent',PARENT,'--strategy',strategy])
(run/'creation-experiment-original.json').write_bytes((run/'experiment.json').read_bytes())
(run/'creation-record-original.json').write_bytes(e.record_path('conv',VERSION).read_bytes())
(run/'source/conv2d.c').write_text(candidate)
for name in ['README.md','bench_conv.c','run.sh']:assert (run/'source'/name).read_bytes()==(parent/name).read_bytes()
(run/'candidate.patch').write_text(''.join(difflib.unified_diff(s.splitlines(True),candidate.splitlines(True),fromfile=PARENT+'/conv2d.c',tofile=VERSION+'/conv2d.c')))
(run/'STRATEGY.md').write_text('# C62: 7 rows, two vectors, four shared columns\n\n'+strategy+'\n\nThis is a combined register-budget hypothesis. C54 tried 7x3VL/shared4 and regressed with substantial scalable spills; C48 tried 8x2VL/u1. Neither is this tile. Reducing width raises coefficient-broadcast work per output by about 50 percent, which may outweigh improved scheduling or fewer spills. GCC can reorder independently; no spill reduction or speedup is claimed. C7 remains best.\n')
(run/'STATIC_REVIEW.md').write_text('''# C62 static scope, arithmetic and bounds

Prepared source only; no compilation, checker, sanitizer, benchmark, remote job or score exists.

Only conv_sve_rowseven changes. Seven output rows and thirteen input-row phases remain; every phase now has two full SVE vectors per output, fourteen independent accumulators. Each lane still receives the original kernel row order; shared columns are ik, ik+1, ik+2, ik+3, each separate mul/add. The remainder runs one column for zero through three columns. Twelve boundary unroll-2 pragmas remain. The dispatch, kh<7 defensive fallback, width fallback calls and all other helper functions are byte-unchanged; fallback width argument naturally becomes ow-i after a 2VL tile.

For main width tiles, ow-i>=2L implies i+2L<=ow. Maximum loaded column is column<=kw-1. The last active element of vector one is i+column+2L-1 <= ow+kw-2 = inputWidth-1. Shared quad condition kw-ik>=4 ensures ik+3<=kw-1; no signed ik+4 guard overflow is introduced. After each quad ik advances by four and u1 covers every residual column in original order. No new pointers or predicates are added. Existing vertical t/kh and seven-output dispatch bounds remain unchanged.

Static shared body: 56 ordinary svmul plus 56 svadd, eight full input loads, 28 coefficient broadcasts, four updates for each of fourteen chains. Source vector-two scopes, initializers and stores are removed only inside this function. This is source-level reasoning, not a proof of generated code or runtime behavior.

Future own diagnostic must use EXPECTED_ACC=2, BLOCK_OUTPUTS=2L and widths around 2L and 4L, including the existing kw4..8 remainder coverage. Retaining the same family cardinalities permits 5744 full/1212 dispatch/432 direct per configuration, but the new checker and expected entry/fallback coverage must be independently reviewed before execution. It may not inherit C61 or C7 acceptance. Future shared4 assembly expects 56 FMUL/56 FADD/8 LD1W/28 LD1RW in semantic work, with actual schedule/spills to be measured; u1 expects 14/14/2/7.
''')
logged('checkpoint',[sys.executable,'tools/experiment.py','checkpoint','conv',VERSION,'--note','Prepared joint 7x2VL/shared4 tile only; no operator compilation/test/job/performance, no inferred speed or inherited diagnostic, no promotion or ZIP.'])
(run/'prepare-source.py').write_bytes(Path(__file__).read_bytes())
print(VERSION,'prepared only; current C7 untouched; no diagnostic template or operator work')
