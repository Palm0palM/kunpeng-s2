"""Prepare C64 with textual boundary-body substitution only; no operator execution."""
from pathlib import Path
import hashlib,json,re,difflib
R=Path(__file__).resolve().parents[2];V='C64-row7boundaryrowwise';B=R/'.runs/conv'/V;P=R/'.runs/conv/C58-r1/source'
def read(p):return json.loads(p.read_text())
def sha(data):return hashlib.sha256(data).hexdigest()
assert read(R/'records/best.json')['conv']=='C58-r1'
parent=read(R/'records/experiments/conv/C58-r1.json')
assert {p.name:sha(p.read_bytes()) for p in P.iterdir()}==parent['source_hashes']
for name,path in [('creation-experiment-original.json',B/'experiment.json'),('creation-record-original.json',R/'records/experiments/conv'/f'{V}.json')]:
 with (B/name).open('xb') as f:f.write(path.read_bytes())
source=(P/'conv2d.c').read_text()
pattern=re.compile(r'(^            #pragma GCC unroll 2\n            for \(int ik = 0; ik < kw; \+\+ik\) \{\n)(.*?)(^            \}\n)',re.M|re.S)
matches=list(pattern.finditer(source));assert len(matches)==12
helper=source.index('static void conv_sve_rowseven(');endhelper=source.index('\n#endif',helper)
subsets=['abcdefg'[:n] for n in range(1,7)]+['abcdefg'[n:] for n in range(1,7)]
labels=[f'input_{n}' for n in range(6)]+[f'trailing_{n}' for n in range(6)]
parts=[];reverse=[];audit=[];cursor=0
for match,rows,label in zip(matches,subsets,labels):
 assert helper<match.start()<match.end()<endhelper
 header,old,footer=match.groups()
 weights=re.findall(r'const svfloat32_t ([a-g])k = svdup_n_f32\(k([a-g])\[ik\]\);',old)
 assert weights==[(r,r) for r in rows]
 counts=[old.count(t) for t in ['svmul_f32_x(','svadd_f32_x(','svld1(','svdup_n_f32(']]
 assert counts==[3*len(rows),3*len(rows),3,len(rows)]
 for lane in range(3):
  assert old.count(f'const svfloat32_t v = svld1(pg, row + ik + {lane} * lanes);')==1
  for row in rows:assert old.count(f'{row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v, {row}k));')==1
 lines=[f'                const svfloat32_t v{lane} = svld1(pg, row + ik + {lane} * lanes);' for lane in range(3)]
 for row in rows:
  lines+=['                {',f'                    const svfloat32_t weight = svdup_n_f32(k{row}[ik]);']
  lines += [f'                    {row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v{lane}, weight));' for lane in range(3)]
  lines += ['                }']
 new='\n'.join(lines)+'\n'
 assert [new.count(t) for t in ['svmul_f32_x(','svadd_f32_x(','svld1(','svdup_n_f32(']]==counts
 for lane in range(3):
  assert new.count(f'svld1(pg, row + ik + {lane} * lanes)')==1
  for row in rows:assert new.count(f'{row}{lane} = svadd_f32_x(pg, {row}{lane}, svmul_f32_x(pg, v{lane}, weight));')==1
 parts += [source[cursor:match.start()],header+new+footer]
 reverse += [source[cursor:match.start()],header+old+footer]
 audit.append(dict(boundary=label,participating_rows=list(rows),mul=counts[0],add=counts[1],loads=counts[2],broadcasts=counts[3],original_start_line=source[:match.start()].count('\n')+1,addresses_predicates_and_per_chain_expression_preserved=True))
 cursor=match.end()
parts.append(source[cursor:]);reverse.append(source[cursor:]);result=''.join(parts)
assert ''.join(reverse)==source
result_matches=list(pattern.finditer(result));assert len(result_matches)==12
# Replace each generated body by the exact old body; reconstruct the entire C7 file.
restored=[];cursor=0
for newer,older in zip(result_matches,matches):
 restored += [result[cursor:newer.start()],older.group(0)];cursor=newer.end()
restored.append(result[cursor:]);assert ''.join(restored)==source
shared_start=source.index('        /* Shared input rows advance all seven outputs',helper)
shared_end=source.index('        /* Trailing input row kh+0:',shared_start)
assert source[shared_start:shared_end] in result
assert source.count('#pragma GCC unroll 2')==result.count('#pragma GCC unroll 2')==12
assert source.count('svmla')==result.count('svmla')
for name in ['README.md','bench_conv.c','run.sh']:assert (B/'source'/name).read_bytes()==(P/name).read_bytes()
(B/'source/conv2d.c').write_text(result)
meta=read(B/'experiment.json');meta.update(source_parent='C58-r1',source_parent_label='C7',own_diagnostic_passed=False,performance_measured=False,executed_locally=False,prepared_only=True)
(B/'experiment.json').write_text(json.dumps(meta,indent=2)+'\n')
(B/'candidate.patch').write_text(''.join(difflib.unified_diff(source.splitlines(True),result.splitlines(True),fromfile='C58-r1/conv2d.c',tofile=V+'/conv2d.c')))
data=dict(candidate=V,source_parent='C58-r1',bytes=len(result.encode()),source_sha256=sha(result.encode()),boundary_count=12,boundaries=audit,totals={k:sum(x[k] for x in audit) for k in ['mul','add','loads','broadcasts']},reverse_reconstructs_entire_C7_bytes=True,shared2_and_remainder_bytes_unchanged=True,all_nonboundary_body_bytes_unchanged=True,all12_unroll2_hints_unchanged=True,companions_unchanged=True,compiled=False,executed=False,verified=False,performance_measured=False)
(B/'SOURCE_AUDIT.json').write_text(json.dumps(data,indent=2)+'\n')
(B/'STRATEGY.md').write_text('# C64: rowwise weights in twelve C7 boundary loops\n\nOnly C7 rowseven boundary column bodies change: first load three input vectors, then broadcast one participating row coefficient in its own scope and update that row’s three accumulators. Input boundaries use a/ab/abc/abcd/abcde/abcdef; trailing boundaries use bcdefg/cdefg/defg/efg/fg/g. Shared2 and its scalar-column remainder remain C7 bytes.\n\nThis aims to shorten simultaneous coefficient lifetimes in the boundary loops where C7 emitted scalable spills. It lengthens simultaneous input-window lifetime; GCC can reschedule, retain or add spills. There is no correctness, spill-reduction or speed claim until own scheduled-node diagnostics and performance.\n')
lines=['# C64 source-only static review','', 'Exactly12 pragma-marked boundary bodies replaced; loop headers, pragma2, input/kernel pointer definitions, predicates, block bounds, accumulator initialization/stores, shared2/remainder and dispatch remain byte-identical to C7. Replacing each generated body by its saved old body reconstructs the entire parent file exactly.','', '|Boundary|Rows|Mul|Add|Loads|Broadcasts|','LOCAL_USER---LOCAL_USER---LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER---:LOCAL_USER']
lines += [f"LOCAL_USER{x['boundary']}LOCAL_USER{''.join(x['participating_rows'])}LOCAL_USER{x['mul']}LOCAL_USER{x['add']}LOCAL_USER{x['loads']}LOCAL_USER{x['broadcasts']}LOCAL_USER" for x in audit]
lines += ['', 'For each active chain, symbolic matching preserves the same input window/predicate and same kernel row/ik coefficient with separate multiply then add. Only independent output chains reorder; t/ik traversal is unchanged. Loading v1/v2 earlier introduces no new address, including kw=1 and final full output block. Existing full-window bounds still apply.','', 'All12 unroll2 hints remain. Totals across one iteration of each boundary source body are126 mul,126 add,36 input loads,42 broadcasts. This is static source count, not dynamic execution or assembly. Official runner/benchmark/README match C7. No local operator compile/test, no diagnostic template, network or submission. Standard creation originals preserved before extended metadata; prepared is not verified.']
(B/'STATIC_REVIEW.md').write_text('\n'.join(lines)+'\n')
print(json.dumps(data,indent=2))
