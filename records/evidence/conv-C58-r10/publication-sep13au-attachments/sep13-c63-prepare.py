"""C63 source-only preparation; no operator compilation, execution or network."""
from pathlib import Path
import hashlib,json,re,difflib,shutil
R=Path(__file__).resolve().parents[2]
V='C63-row7x2shared4rowwise';B=R/'.runs/conv'/V
DESIGN=R/'.runs/conv/C62-row7x2shared4/source'
PARENT=R/'.runs/conv/C58-r1/source'
def read(p):return json.loads(p.read_text())
def digest(data):return hashlib.sha256(data).hexdigest()
record=read(R/'records/experiments/conv/C62-row7x2shared4.json')
names={'README.md','run.sh','bench_conv.c','conv2d.c'}
design_hashes={n:digest((DESIGN/n).read_bytes()) for n in names}
assert design_hashes==record['source_hashes']
assert read(R/'records/best.json')['conv']=='C58-r1'
for name,path in [('creation-experiment-original.json',B/'experiment.json'),('creation-record-original.json',R/'records/experiments/conv'/f'{V}.json')]:
 with (B/name).open('xb') as f:f.write(path.read_bytes())
source=(DESIGN/'conv2d.c').read_text()
start_marker='            for (; kw - ik >= 4; ik += 4) {\n'
assert source.count(start_marker)==1
start=source.index(start_marker)
end=source.index('            for (; ik < kw; ++ik) {\n',start)
old=source[start:end]
blocks=[start_marker.rstrip('\n')]
for col in range(4):
 column='ik' if col==0 else f'ik + {col}'
 blocks += ['                {',f'                    const int column = {column};']
 blocks += [f'                    const svfloat32_t v{lane} = svld1(pg, row + column + {lane} * lanes);' for lane in range(2)]
 for row in 'abcdefg':
  blocks += ['                    {',f'                        const svfloat32_t weight = svdup_n_f32(k{row}[column]);']
  blocks += [f'                        {row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v{lane}, weight));' for lane in range(2)]
  blocks += ['                    }']
 blocks += ['                }']
blocks += ['            }']
new='\n'.join(blocks)+'\n'
assert [old.count(t) for t in ('svmul_f32_x(', 'svadd_f32_x(', 'svld1(', 'svdup_n_f32(')]==[56,56,8,28]
assert [new.count(t) for t in ('svmul_f32_x(', 'svadd_f32_x(', 'svld1(', 'svdup_n_f32(')]==[56,56,8,28]
old_columns=re.split(r'                    const int column = (ik(?: \+ [123])?);\n',old)
new_columns=re.split(r'                    const int column = (ik(?: \+ [123])?);\n',new)
assert old_columns[1::2]==new_columns[1::2]==['ik','ik + 1','ik + 2','ik + 3']
for oi,ni in zip(old_columns[2::2],new_columns[2::2]):
 for row in 'abcdefg':
  assert oi.count(f'const svfloat32_t {row}k = svdup_n_f32(k{row}[column]);')==1
  assert ni.count(f'const svfloat32_t weight = svdup_n_f32(k{row}[column]);')==1
  for lane in range(2):
   assert oi.count(f'{row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v, {row}k));')==1
   assert ni.count(f'{row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v{lane}, weight));')==1
 for lane in range(2):
  assert oi.count(f'svld1(pg, row + column + {lane} * lanes)')==ni.count(f'svld1(pg, row + column + {lane} * lanes)')==1
result=source[:start]+new+source[end:]
assert result[:start]+old+result[start+len(new):]==source
assert result.count('#pragma GCC unroll 2')==source.count('#pragma GCC unroll 2')
assert result.count('svmla')==source.count('svmla')
for name in names:
 if name=='conv2d.c':(B/'source'/name).write_text(result)
 else:
  assert (DESIGN/name).read_bytes()==(PARENT/name).read_bytes()
  shutil.copy2(DESIGN/name,B/'source'/name)
meta=read(B/'experiment.json')
meta.update(source_parent='C58-r1',source_parent_label='C7',design_source='C62-row7x2shared4',design_source_hashes=design_hashes,own_diagnostic_passed=False,performance_measured=False,executed_locally=False,prepared_only=True)
(B/'experiment.json').write_text(json.dumps(meta,indent=2)+'\n')
for name,left,label in [('candidate.patch',(PARENT/'conv2d.c').read_text(),'C58-r1'),('delta-from-C62.patch',source,'C62-row7x2shared4')]:
 (B/name).write_text(''.join(difflib.unified_diff(left.splitlines(True),result.splitlines(True),fromfile=label+'/conv2d.c',tofile=V+'/conv2d.c')))
audit=dict(candidate=V,source_parent='C58-r1',design_source='C62-row7x2shared4',bytes=len(result.encode()),source_sha256=digest(result.encode()),quad_start_line=result[:start].count('\n')+1,quad_end_line=result[:start+len(new)].count('\n'),source_quad_counts=dict(mul=56,add=56,input_load=8,broadcast=28),accumulators=14,column_order=['ik','ik+1','ik+2','ik+3'],outside_quad_bytes_equal_to_C62=True,companions_equal_to_C62_and_C7=True,boundary_pragma_count_unchanged=True,per_chain_symbolic_operations_and_addresses_unchanged=True,compiled=False,executed=False,verified=False,performance_measured=False)
(B/'SOURCE_AUDIT.json').write_text(json.dumps(audit,indent=2)+'\n')
(B/'STRATEGY.md').write_text('# C63: 7 rows, 2VL, shared4 with rowwise weights\n\nStandard parent is current C7/C58-r1. C62 is the design source, not a measured performance baseline for this candidate. Only C62 quad body changes: each ordered column loads v0/v1, then each row broadcasts one coefficient and updates its two accumulators. All other C62 bytes remain, including 14 accumulators, twelve boundary unroll2 hints, remainder and dispatch. Companion files match C7.\n\nHypothesis: shorter coefficient lifetime may help the jointly narrowed/shared4 tile after C62 emitted substantial scalable spills. GCC may reorder and retain spills; no spill reduction or speed claim. Each chain keeps ik0..3, separate mul then add, with unchanged addresses and predicates. Own scheduled-node numerical validation and real assembly are required before performance measurement.\n')
(B/'STATIC_REVIEW.md').write_text('# C63 source-only static review\n\nGenerated from the recorded C62 source with one bounded quad-loop replacement; reverse replacement reproduces C62 bytes exactly. Each of four columns retains identical input offsets, seven weight addresses and two updates per row. Statement order changes only between independent output chains; each chain still processes ik, ik+1, ik+2, ik+3. Source body counts remain 56 separate mul + 56 add + 8 input loads + 28 broadcasts.\n\nInput windows/predicate and kw-ik>=4 guard are unchanged from C62. Earlier loading of v1 accesses the same valid window; no extra memory read or full-width tail access is introduced. Seven-row/2VL layout, all 12 boundary unroll2 hints, remainder, stores, dispatch and other helpers are original C62 bytes. Official benchmark and runner match C7.\n\nTextual address/expression checks and reverse-byte proof are preparation checks only: no operator compilation, correctness run, sanitizer, assembly or performance measurement was performed. Prepared status is not PASS. Standard creation metadata remains separately preserved; extended metadata identifies C7 parent and C62 design source.\n')
print(json.dumps(audit,indent=2))
