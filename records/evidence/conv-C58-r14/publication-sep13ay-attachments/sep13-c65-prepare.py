"""Prepare C65 balanced seven-row dispatch only; no compiler/operator/network."""
from pathlib import Path
import difflib,json,re,subprocess,sys,hashlib
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'));sys.dont_write_bytecode=True
import experiment as e
VERSION='C65-row7balanced';PARENT='C58-r1';run=ROOT/'.runs/conv'/VERSION
assert not run.exists() and not e.record_path('conv',VERSION).exists()
assert e.read_json(ROOT/'records/best.json')['conv']==PARENT
assert e.read_json(ROOT/'outputs/conv-best.json')['label']=='C7'
parent=ROOT/'.runs/conv'/PARENT/'source';source=(parent/'conv2d.c').read_text()
assert e.source_files(ROOT/'conv')==e.get_record('conv',PARENT)['source_hashes']
start=source.index('    if (use_sve && kernelHeight >= 7 && oh >= 7) {')
end=source.index('    if (use_sve) {',start)
old=source[start:end]
calls=old[old.index('            if (remaining >= 7) {'):old.rindex('        }\n        return;')]
calls=re.sub(r'\bow\b','slice_width',calls)
calls=''.join('    '+line if line.strip() else line for line in calls.splitlines(True))
new='''    if (use_sve && kernelHeight >= 7 && oh >= 7) {
        const size_t output_rows = (size_t)oh;
        const size_t output_stride = (size_t)ow;
        const size_t groups = output_rows / 7 + (output_rows % 7 != 0);
        /* AArch64 dimensions are positive signed ints. Their group/tile
         * product fits size_t; partitioning below never multiplies by tid. */
        _Static_assert(sizeof(size_t) >= 8 && sizeof(CONVINT) <= 4,
                       "Balanced SVE dispatch requires 64-bit sizes and <=32-bit dimensions");
        size_t partition_block = 1;
#pragma omp parallel shared(partition_block)
        {
            const size_t worker_lanes = conv_sve_dispatch_lanes();
            /* All workers partition the same domain even if their VL differs.
             * Existing helpers use each worker's own VL for each safe slice. */
#pragma omp single
            {
                partition_block = 3 * worker_lanes;
            }
#ifdef _OPENMP
            const size_t team = (size_t)omp_get_num_threads();
            const size_t worker = (size_t)omp_get_thread_num();
#else
            const size_t team = 1;
            const size_t worker = 0;
#endif
            const size_t tiles_per_group = output_stride / partition_block
                + (output_stride % partition_block != 0);
            const size_t total_tiles = groups * tiles_per_group;
            const size_t quotient = total_tiles / team;
            const size_t remainder = total_tiles % team;
            size_t cursor = worker * quotient
                + (worker < remainder ? worker : remainder);
            const size_t finish = cursor + quotient + (worker < remainder);
            while (cursor < finish) {
                const size_t group = cursor / tiles_per_group;
                const size_t first_tile = cursor % tiles_per_group;
                const size_t available = tiles_per_group - first_tile;
                const size_t take = finish - cursor < available
                    ? finish - cursor : available;
                const size_t last_tile = first_tile + take;
                const size_t first_column = first_tile * partition_block;
                /* Clamp before multiplying the rounded-up final tile. */
                const size_t last_column = last_tile == tiles_per_group
                    ? output_stride : last_tile * partition_block;
                const int slice_width = (int)(last_column - first_column);
                const size_t first_row = group * 7;
                const size_t remaining = output_rows - first_row;
                const float *base = input + first_row * stride + first_column;
                float *dst = output + first_row * output_stride + first_column;
'''+calls+'''                cursor += take;
            }
        }
        return;
    }
'''
lane_helper='''#if CONV_CAN_DISPATCH_SVE
/* Metadata only: generic conv2d must not inline an SVE-only intrinsic. */
__attribute__((target("arch=armv8-a+sve"), noinline))
static size_t conv_sve_dispatch_lanes(void)
{
    return (size_t)svcntw();
}
#endif

'''
header='#ifdef _OPENMP\n#include <omp.h>\n#endif\n\n'
candidate=source[:start]+new+source[end:]
candidate=candidate.replace('#include <stddef.h>\n\n','#include <stddef.h>\n\n'+header,1)
point=candidate.index('void conv2d(const CONVFLOAT *input,')
candidate=candidate[:point]+lane_helper+candidate[point:]
# Reverse only explicitly permitted additions/replacement; all existing
# computational helpers and other dispatch source must recover exactly.
reverse=candidate.replace(header,'',1).replace(lane_helper,'',1).replace(new,old,1)
assert reverse==source
assert candidate.count('static size_t conv_sve_dispatch_lanes(void)')==1
assert new.count('conv_sve_dispatch_lanes();')==1 and 'svcntw' not in new
assert new.count('#pragma omp parallel')==1 and new.count('#pragma omp single')==1
assert candidate.count('#pragma GCC unroll 2')==source.count('#pragma GCC unroll 2')
assert 'malloc' not in new and 'atomic' not in new and 'reduction' not in new
strategy='Balance only current C7 seven-row SVE dispatch: partition the flattened row-group/3VL-width-tile domain by actual OpenMP team using quotient/remainder intervals, merge each worker contiguous same-group tiles into one unchanged helper call, and preserve per-output arithmetic. One common 3VL partition width is selected after worker-local target-safe VL query. Existing helpers and all other dispatch remain unchanged. No fixed 256-column subcalls or timed allocation.'
def logged(label,args):
    subprocess.run([sys.executable,str(ROOT/'.runs/conv/sep13-run-logged.py'),'sep13-c65-'+label,*args],cwd=ROOT,check=True)
logged('new',[sys.executable,'tools/experiment.py','new','conv',VERSION,'--parent',PARENT,'--strategy',strategy])
(run/'creation-experiment-original.json').write_bytes((run/'experiment.json').read_bytes())
(run/'creation-record-original.json').write_bytes(e.record_path('conv',VERSION).read_bytes())
(run/'source/conv2d.c').write_text(candidate)
for name in ['README.md','bench_conv.c','run.sh']:assert (run/'source'/name).read_bytes()==(parent/name).read_bytes()
(run/'candidate.patch').write_text(''.join(difflib.unified_diff(source.splitlines(True),candidate.splitlines(True),fromfile=PARENT+'/conv2d.c',tofile=VERSION+'/conv2d.c')))
(run/'STRATEGY.md').write_text('# C65: coalesced balanced seven-row dispatch\n\n'+strategy+'\n\nC7 group counts580/872/601/902 give maximum per-worker counts16/23/16/24 at38 threads. Equal-group-cost imbalance model has a weighted ceiling about1.41 percent of C7 measured time; this is a hypothesis budget, not a score or prediction. Historical C30 flattened four-row/fixed256-column chunks. C65 differs by7-row C7,3VL alignment and coalescing: at mostP-1 worker boundaries add group fragments, avoiding a helper call per small chunk. Real setup, partial-row/tail costs, cache effects and uneven work can erase this small budget.\n\nNo compiler, test, diagnostic, benchmark, job, qualification or package exists for this candidate. It must not inherit existing rowseven entry-count expectations.\n')
(run/'STATIC_REVIEW.md').write_text('''# C65 source-only partition and safety reasoning

Only the seven-row SVE dispatch is replaced, plus a conditional omp.h include and an SVE-target/noinline metadata function returning svcntw. Removing these three additions/replacements reconstructs C7 exactly. All computational helpers, other dispatch and official companions are byte-unchanged. Generic conv2d calls a scalar-return target function, never an SVE intrinsic directly.

Every worker obtains local VL; omp single selects one shared B=3*lanes and its implicit barrier publishes B to all workers. Partitioning therefore uses one domain even if worker VL differs. The unchanged helpers handle arbitrary safe slice width using their own VL; heterogeneous VL may reduce alignment benefits but cannot create output overlap. Without OpenMP, pragmas are ignored and team/worker constants1/0 preserve a serial path. No mutable global state or per-output synchronization is added.

Let G=ceil(oh/7),T=ceil(ow/B),N=G*T,P=actual team size,r=N mod P,q=floor(N/P). Worker t owns [t*q+min(t,r),t*q+min(t,r)+q+(t<r)). These consecutive intervals cover [0,N) exactly once; when P>N, workers after N own empty intervals. No total-times-worker multiplication is used. Each iteration takes min(T-(cursor mod T),finish-cursor), a positive count until finish, so intervals never cross a group inside one helper call.

A static assertion restricts this AArch64 path to >=64-bit size_t and <=32-bit signed-int dimensions. Positive valid dimensions are <=INT_MAX, so G*T <= ceil(INT_MAX/7)*INT_MAX <2^63, even under the conservative bound T<=ow. All interval products/sums are bounded by N. group*7<=oh-1; first_tile<T gives first_column<ow. last_tile<=T; if equal, choose ow before multiplying the rounded-up last tile; otherwise last_tile*B<ow. Thus 0<slice_width<=ow<=INT_MAX and the int cast is safe. Existing pointer sizes remain bounded by valid original arrays.

For each assigned output group, base/dst shift by the same first_column and retain original full input/output row strides. Every original helper call for full or partial seven-row groups is retained with only width replaced by slice_width. Each output coordinate belongs to one group and one tile, hence one worker slice. Input/kernel remain shared read-only; no partial reduction or accumulation-order change occurs. All full slices end on B boundaries; only a group's final slice can have the original width tail. Adjacent workers may share a cache line but never a float output element.

At most P-1 interior worker boundaries split groups; same-group tiles are merged, so helpers run once per nonempty group/worker intersection rather than per tile. This limits added function setup, but no performance guarantee follows.

Own future diagnostics must independently derive per-case rowseven calls/masks from interval intersections, not old1236 aggregate expectations. Cover actual1/4/38 teams, empty workers, fewer tiles than threads, partial seven-row groups, VL16/32/64 and boundary/tail widths. Keep scalar bitwise/guard protection; inspect actual dispatcher and helper compile flags/assembly before matched performance. This document contains static reasoning only; no operator or executable partition test was run locally.
''')
audit=dict(candidate=VERSION,source_parent=PARENT,source_sha256=hashlib.sha256(candidate.encode()).hexdigest(),bytes=len(candidate.encode()),only_seven_row_dispatch_plus_target_query_and_omp_header=True,reverse_reconstructs_C7=True,existing_helpers_and_other_dispatch_unchanged=True,companions_unchanged=True,actual_team_partition=True,common_partition_width=True,coalesced_same_group=True,compiled=False,executed=False,verified=False,performance_measured=False)
(run/'SOURCE_AUDIT.json').write_text(json.dumps(audit,indent=2)+'\n')
logged('checkpoint',[sys.executable,'tools/experiment.py','checkpoint','conv',VERSION,'--note','Prepared balanced/coalesced 7-row dispatch only; helpers/other dispatch unchanged. No compiler/operator/checker/job/benchmark executed; entry expectations need new independent derivation. No promotion or ZIP.'])
(run/'prepare-source.py').write_bytes(Path(__file__).read_bytes())
print(VERSION,'prepared only',audit['source_sha256'])
