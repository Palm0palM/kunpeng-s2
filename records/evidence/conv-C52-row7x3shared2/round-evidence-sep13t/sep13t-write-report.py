"""Write T documentation once from finalized frozen diagnostics and reviews.

Pure file/text processing. No import of execution tools, SSH, operator, record
mutation, acceptance, freeze, performance, ZIP, promotion or publication.
"""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
VERSION = 'C52-row7x3shared2'
FROZEN = ROOT/'.runs/conv'/VERSION/'sve-correctness-sep13t'


def read(path):
    return json.loads(path.read_text())


def load_actual():
    val = read(FROZEN/'validation.json')
    freeze = read(FROZEN/'freeze-source.json')
    helper = read(FROZEN/'assembly-helper-review.json')
    dispatch = read(FROZEN/'assembly-dispatch-review.json')
    assembly = val['assembly']
    job = read(FROZEN/'job.json')
    assert val['status']=='passed' and val['complete'] is True
    assert val['candidate']==freeze['candidate']==VERSION
    assert val['job_id']==freeze['job_id']=='1582134' and freeze['mode']=='passed'
    assert job['job_id']==val['job_id']
    assert job['resources']==dict(cpus=38,memory_mb=24576,numa_count=1,numa_distribution='pack',walltime_seconds=1800)
    assert val['exit_code']==0 and val['scheduler']['status']=='SUCCEEDED'
    assert val['scheduler']['jobId']==val['job_id']
    assert val['scheduler']['jobExitCode']==val['scheduler']['systemExitCode']==0
    stages = ['allocation','compiler','manifest','build-guard']
    stages += [f'guard-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-dispatch']+[f'dispatch-vl{v}-t{t}' for v in (16,32,64) for t in (1,4)]
    stages += ['build-assembly','complete']
    assert val['stage_exits']==[dict(stage=name,exit_code=0) for name in stages]
    assert (FROZEN/'raw/stage-exits.txt').read_text().splitlines()==['STAGE='+name+' EXIT=0' for name in stages]
    assert (FROZEN/'raw/exit-code.txt').read_text().strip()=='0'
    assert val['performance_measured'] is False and val['runner_cases']==0
    assert val['executed_locally'] is False and val['executed_remotely'] is True
    assert val['automatic_performance_submission'] is False and val['issues']==[]
    assert val['source_hashes_verified'] is True and val['source_manifest_remote_matches'] is True
    assert val['compiler_version']=='10.3.1' and len(set(val['allocation']['cpus']))==38
    assert freeze['original_source_and_raw_preserved'] is True
    assert freeze['original_metadata_preserved'] is True and freeze['validation_rewritten'] is False
    assert [(x['sve_bytes'],x['threads']) for x in val['configurations']]==[(v,t) for v in (16,32,64) for t in (1,4)]
    for config in val['configurations']:
        v,t = config['sve_bytes'],config['threads']
        assert config['passed'] is True and config['lanes']==v//4
        assert config['block_outputs_per_row']==3*config['lanes']
        assert [config[k] for k in ('full_cases','dispatch_cases','direct_cases')]==[4784,972,432]
        assert config['dispatch_entries']==756 and config['direct_entries']==1080
        assert config['dispatch_worker_mask']==config['direct_worker_mask']==(1 if t==1 else 15)
        assert all(x>0 for x in config['helper_entries'].values())
        full = (FROZEN/f'raw/guard-vl{v}-t{t}.log').read_text()
        probe = (FROZEN/f'raw/dispatch-vl{v}-t{t}.log').read_text()
        assert 'FULL_MATRIX_COUNTS core=3888 narrow=144 small=720 larger=32' in full
        assert 'PASS: 4784 convolution cases;' in full
        assert 'PASS: 972 dispatch cases;' in probe and 'PASS: 432 direct fallback cases;' in probe
        for route,entries in (('DISPATCH',756),('DIRECT',1080)):
            mask = config['dispatch_worker_mask']
            assert f'{route}_ROWSEVEN_ACTUAL_ENTRIES={entries} EXPECTED={entries} WORKER_MASK={mask} EXPECTED_MASK={mask}' in probe
    for key in ('full_cases','dispatch_cases','direct_cases'):
        assert val[key]==sum(x[key] for x in val['configurations'])
    assert val['total_cases']==val['full_cases']+val['dispatch_cases']+val['direct_cases']==37128
    assert assembly['helpers']==helper['helpers'] and assembly['dispatch_functions']==dispatch['dispatch_functions']
    assert assembly['stage_count']==13 and assembly['arithmetic_region_count_per_helper']==14
    assert assembly['whole_source_fma_count']==assembly['fma_count']==0
    assert assembly['production_object_disassembly_available'] is False
    assert assembly['whole_machine_code_identical_claimed'] is False
    for field in ('review_complete','dispatch_reviewed','whole_helper_stack_reviewed','all_stages_and_transitions_reviewed','shared_pair_and_remainder_reviewed','production_uninstrumented'):
        assert assembly[field] is True
    for part in (assembly,helper,dispatch):
        assert part['candidate']==VERSION and part['job_id']==val['job_id']
        assert part['source_sha256']==val['source_hashes']['conv2d.c']
        assert part['assembly_sha256']==assembly['assembly_sha256']
    origin = read(FROZEN/'assembly-source.json')
    assert origin['byte_identical'] is True
    assert origin['source_sha256']==origin['public_sha256']==assembly['assembly_sha256']
    h = assembly['helpers'][0]
    assert len(assembly['helpers'])==1 and h['symbol']=='conv_sve_rowseven'
    assert (h['line_start'],h['line_end'])==(5705,7053)
    assert h['vector_spill_loads']==h['vector_spill_stores']==0
    assert sum(len(item['registers']) for item in h['abi_saves'])==7
    assert h['stack_frame_description'].startswith('Fixed720byte frame:')
    regions=[]
    for stage in h['stages']:
        for block in stage.get('blocks',[stage]):
            count = block['derived_counts']
            work = block['kernel_columns_per_iteration']
            assert block['derived_counts_per_kernel_column']=={k:v/work for k,v in count.items()}
            assert block['vector_spill_loads']==block['vector_spill_stores']==0
            regions.append((stage['stage'],block))
    assert len(regions)==14
    pair,odd = h['stages'][6]['blocks']
    assert pair['block']=='paired' and odd['block']=='odd_remainder'
    assert pair['region_kind']==odd['region_kind']=='loop'
    assert [pair['derived_counts'][k] for k in ('instructions','fmul','fadd','ld1w','ld1rw')]==[123,42,42,6,14]
    assert [odd['derived_counts'][k] for k in ('instructions','fmul','fadd','ld1w','ld1rw')]==[63,21,21,3,7]
    parent = ROOT/'.runs/conv/C51-row7x3u1/sve-correctness-sep13q'
    q = read(parent/'validation.json')
    assert q['status']=='passed' and q['job_id']=='1581822'
    qshared = q['assembly']['helpers'][0]['stages'][6]
    assert qshared['stage']=='shared' and qshared['kernel_columns_per_iteration']==1
    assert qshared['derived_counts']['instructions']==63
    for name in ('check_conv_guard.c','check_sve_dispatch.c'):
        assert val['source_hashes'][name]==q['source_hashes'][name]
    record = read(ROOT/'records/experiments/conv'/(VERSION+'.json'))
    assert record['source_parent']=='C51-row7x3u1'
    assert record['source_hashes']['conv2d.c']==val['source_hashes']['conv2d.c']
    assert record['source_parent_source_hashes']['conv2d.c']==q['source_hashes']['conv2d.c']
    # This is a report at the completed diagnostic point, before any performance run.
    assert record['status']=='prepared' and 'job_id' not in record
    assert read(ROOT/'outputs/conv-best.json')['label']=='C6'
    assert read(ROOT/'records/best.json')['conv']=='C26-r1'
    s = read(ROOT/'.runs/conv/sep13s-campaign.json')
    assert s['performance_job']=='1582067' and s['status']=='performance_complete'
    assert s['confirmation_passed'] is False
    return val,freeze,assembly,h,regions,qshared


def render(val,freeze,assembly,helper,regions,qshared):
    text=['# CONV：仅 shared 两列展开的 C52 独立诊断','',
        f"**C52-row7x3shared2 的 T 作业 {val['job_id']} 已独立通过 {val['total_cases']}/{val['total_cases']} 项诊断并冻结。**"
        '本轮没有运行原 benchmark 或测量性能；生成本报告时，当前最佳仍为 **C6（C26-r1）**。', '',
        'C52 以已冻结 Q/C51-row7x3u1 为源码父版本，仅把 `conv_sve_rowseven` 的 shared 阶段 kernel 列循环展开为两列。'
        '安全条件为 `kw - ik >= 2`，每个累加器仍先加列 ik、再加列 ik+1，余列沿用原单列循环。'
        '七输出行×每行3个SVE向量、21累加器、13个语义阶段保持；其余12阶段、fallback、dispatch、benchmark、runner及其他提交文件保持父版本字节。'
        '使用普通独立乘法/加法，没有加入FMA、asm、prefetch或分段累加。', '',
        '## 实际运行与矩阵','',
        'scheduler SUCCEEDED，job/system/wrapper退出均为0，19个作业阶段实际全部退出0。GCC10.3.1、generic、原浮点设置；'
        '调度分配38 CPU、24576MiB、单NUMA，诊断团队分别使用1/4线程。编译、执行全部在超算计算节点完成。', '',
        '| 路径 | 每配置实际通过 | 六配置实际通过 |',
        '| --- | ---: | ---: |',
        f"| 未插桩生产 full | 4784 | {val['full_cases']} |",
        f"| 插桩 dispatch | 972 | {val['dispatch_cases']} |",
        f"| 直接 kh<7 防御回退 | 432 | {val['direct_cases']} |",
        f"| 合计 | 6188 | {val['total_cases']} |", '',
        '| SVE字节 | lanes / 每行主块输出 | 线程 | dispatch入口 / mask | direct入口 / mask |',
        '| ---: | --- | ---: | --- | --- |']
    for c in val['configurations']:
        text.append(f"| {c['sve_bytes']} | {c['lanes']} / {c['block_outputs_per_row']} | {c['threads']} | {c['dispatch_entries']} / {c['dispatch_worker_mask']} | {c['direct_entries']} / {c['direct_worker_mask']} |")
    text+=['', 'L为float lanes。四种分配组合为pad0/1×leading0/1。每配置full的实际细分是3888+144+720+32=4784：', '',
        '- core 3888：ow取3L−1/3L/3L+1/6L−1/6L/6L+1，kh6/7/8、kw1/2/3、oh1..15/21/22/28、四种分配。',
        '- narrow 144：ow1，kh6/7/8、kw1/2/3、oh1/7/13/28、四种分配。',
        '- small 720：ow1/3L−1/3L+1，kh1..5、kw1/2/3、同四个oh及四种分配。',
        '- larger 32：kernel10×7、9×8、15×15、81×81，ow3L+1、oh7/13、四种分配。', '',
        'dispatch使用core的972个几何组合，固定pad1/leading0；逐case检查rowseven入口增量，仅kh>=7且oh>=7时为floor(oh/7)，每配置累计756。'
        'direct为kh1..6、kw1/2/3、ow3L−1/3L/3L+1、oh7/28、四种分配，共432项、1080次rowseven入口；它进入quad+triple防御路径，不执行shared算术。', '',
        'kw1跳过paired、只走余列；kw2执行一对、无余列；kw3执行一对加余列。较大kernel另外覆盖kw7/15/81的多对加余列和kw8的多对无余列。'
        '正常入口中kh7/8、oh>=7、ow>=3L的子集可进入shared；kh6、窄宽和直接回退检查其边界。'
        '两个C检查器保留Q原字节，但这里的PASS来自T自己的作业和原日志。', '',
        '数值参考是独立ky/kx顺序的scalar实现，以memcmp逐位比较；input/kernel只读、分配两端PROT_NONE、外围canary和输出poison全部通过。'
        '没有逐行guard、sanitizer、invalid-dimension、屏蔽SVE或NaN/Inf专项。没有新增L/2L邻域864项，没有direct的ow1，也未覆盖建议中的9×7/8×8组合。'
        '五个旧helper的非零入口与worker mask为套件累计证据；没有对13阶段或paired/odd内部做动态计数，入口计数不代表每阶段动态覆盖次数。', '',
        '## 真实汇编：13语义阶段、14算术区域','',
        f"完整唯一 `conv_sve_rowseven` 从实际文本行{helper['line_start']}读至.size行{helper['line_end']}，所有转换、尾部和回退均已检查。"
        'shared在实际汇编中形成paired和odd两个loop；odd的条件/回边位于.L454，没有虚构直线块或机器PC。', '',
        '| 阶段/区域 | label | 实际.s行 | 每轮kernel列数 | 指令 | FMUL/FADD | LD1W/LD1RW | 指令/列 |',
        '| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for name,block in regions:
        ct=block['derived_counts']; work=block['kernel_columns_per_iteration']
        name += ('/'+block['block']) if 'block' in block else ''
        text.append(f"| {name} | {block['label']} | {block['line_start']}–{block['line_end']} | {work} | {ct['instructions']} | {ct['fmul']}/{ct['fadd']} | {ct['ld1w']}/{ct['ld1rw']} | {ct['instructions']/work:g} |")
    text+=['', f"paired的123/2=61.5条/列，对照[Q原shared](CONV_SEP13Q.md)的{qshared['derived_counts']['instructions']}条/列；odd仍为63条/列。"
        '这是静态指令归一化，不是提速、动态指令量或单独回边成本测量。更高地址状态、寄存器活跃期、ABI保存和代码体积都可能影响最终性能。', '',
        '实际两列的输入/系数确实交错调度并同时存活，局部花括号不能保证编译器分开活跃期。已逐个追踪21累加器的ik→ik+1 FADD；'
        'g1在6383行临时由z5转入z2，再于6390行读z2写回z5，仍是同一连续累加链。完整21项顺序表保存在helper片段。'
        '14区域均使用普通FMUL/FADD，没有indexed FMUL、LD1RQW、DUP、indexed MOV、EXT或MOVPRFX；整份返回汇编FMA词法计数为0。', '',
        '完整helper固定栈帧 **720字节**，没有Z/Q/谓词spill。实际保存D8/D9、D10/D11、D12/D13和D14，共 **7个低64位ABI寄存器**，均对应恢复；'
        '这些不等同于SVE累加器spill。sp+664的间接地址只访问标量X指针槽，其他栈槽为标量状态/出栈参数。'
        '13阶段转换、pair→odd→下一输入行、21个ST1W、每次i+=3L、横向quad+triple尾部、kh<7防御路径与early-return恢复均按实际产物核对。', '',
        '## 完整dispatch审查','',
        '| 实际函数 | 实际.s行 | 固定栈帧 | 路由/栈要点 |',
        '| --- | --- | ---: | --- |']
    summaries={
        'conv2d._omp_fn.2':'原非SVE逐输出行worker；局部32-float tile有14个STR Q写栈点，属于实际tile物化，区别于SVE累加器spill。',
        'conv2d._omp_fn.1':'四行worker；余3/2/1分别triple/pair/prefix，无向量/谓词栈访问。',
        'conv2d._omp_fn.0':'七行worker；余6为quad+pair，余5为quad+prefix，余4/3/2/1走旧helper；无向量/谓词栈访问。',
        'conv2d':'公共入口检查有效尺寸与HWCAP；SVE且kh>=7、oh>=7走七行，否则SVE四行或原非SVE；无向量/谓词栈访问。'}
    for part in assembly['dispatch_functions']:
        frame=re.search(r'(\d+)-byte',part['stack_notes'])[1]
        text.append(f"| {part['symbol']} | {part['line_start']}–{part['line_end']} | {frame}字节 | {summaries[part['symbol']]} |")
    text+=['', 'root完整读取三个改变布局的实际dispatch函数。非SVE .omp_fn.2的全部文本逐字等于Q原件，包括标签、指令和汇编指示符，'
        '因此保留Q已有完整审查（Q同时保存其与独立审过C47全文相同的依据）；没有用局部相似性替代完整函数证据。'
        '该非SVE函数没有Z/谓词栈访问，但明确保留上述NEON tile写栈，不声称全源没有向量栈流量。', '',
        '## 原件、身份与当前结论','',
        f"- C52源码SHA256：`{val['source_hashes']['conv2d.c']}`。",
        f"- 本次生产汇编SHA256：`{assembly['assembly_sha256']}`。",
        '- 源码父版本为已冻结Q/C51；T独立运行、审查与冻结自身产物，Q的PASS不代替T。',
        f"- 冻结目录：`.runs/conv/{VERSION}/sve-correctness-sep13t/`，保留原源码、原日志、scheduler、19阶段退出、首次清单、helper/dispatch片段、完整validation及工具文本。",
        '- 原生产.s与.assembly.txt逐字相同；没有生产.o，不宣称对象反汇编一致。', '',
        '冻结保留首次prepared README/INTERFACE和source checkpoint的原始历史语义，未把它们改写成运行结果；'
        '本轮最终状态以passed validation、root acceptance decision和freeze-source为准。接受/冻结是本机文本整理，接受器与冻结器各执行一次成功，无schema修改。', '',
        '诊断通过及零spill不提供性能晋级资格。C52尚无本轮原benchmark速度、官方分数、排名或新提交包；当前最佳仍是C6。'
        '[S作业1582067对C51的独立确认失败](CONV_SEP13S.md)保持原判，不重写、不重跑该失败确认，也不借它的样本证明C52。'
        '后续性能测量需root独立审查后另行安排。', '',
        '本报告生成器只读取已完成原件并写本页，不改源码、record、包或发布副本，没有创建/运行任何作业，没有在本机运行算子，也没有使用重置卡。','']
    return '\n'.join(text)


def main():
    destination=ROOT/'docs/CONV_SEP13T.md'
    assert not destination.exists(), 'Existing report is never overwritten'
    actual=load_actual()
    content=render(*actual)
    with destination.open('x') as handle:
        handle.write(content)
    assert destination.read_text()==content
    print(json.dumps(dict(report=str(destination),job_id=actual[0]['job_id'],checks=actual[0]['total_cases'],
        regions=len(actual[4]),semantic_stages=actual[2]['stage_count'],performance_measured=False,
        current_best='C6',source_record_unchanged=True,official_score=None),ensure_ascii=False,indent=2))


if __name__=='__main__':
    main()
