"""Generate S report once from actual completed original records/logs only.

No SSH, operator, reservation, record update, ZIP, promotion or publication.
Import defines functions only. The output must not already exist.
"""
from pathlib import Path
import json
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
import cluster as c
import experiment as e
ORDER = ['C26-r24','C51-r1','C26-r25']
DIMS = [[4096,6144,39,39],[6144,4096,41,41],[4256,6390,55,55],[6390,4256,81,81]]


def read(path):
    return json.loads(path.read_text())


def load_completed():
    plan = read(ROOT/'.runs/conv/sep13s-campaign.json')
    assert plan['round']=='sep13s' and plan['status']=='performance_complete'
    assert plan['measurement_order']==ORDER and plan['candidate_versions']==['C51-r1']
    assert plan['opening_control']==ORDER[0] and plan['primary_baseline']==ORDER[-1]
    assert plan['suites_per_member']==3 and plan['expected_benchmark_cases']==36
    assert plan['submitted'] is True and plan['submit_attempted'] is True
    assert isinstance(plan['performance_job'],str) and plan['performance_job'].isdigit()
    assert plan['performance_job'] not in ('1581911','1581822')
    assert type(plan['confirmation_passed']) is bool
    assert plan['samples_mixed_with_initial_round'] is False
    assert plan['confirmation_pending']==[] and plan['failed_confirmation_retry_allowed'] is False
    assert all(plan[k] is False for k in ('automatic_confirmation','automatic_promotion','automatic_packaging'))
    records = {name:read(ROOT/'records/experiments/conv'/(name+'.json')) for name in ORDER}
    rows = {row['version']:row for row in plan['results']}
    assert list(rows)==ORDER
    for name,rec in records.items():
        run = ROOT/'.runs/conv'/name
        manifest = read(run/'cluster.json')
        assert rec['version']==name and rec['status']=='passed' and rec['verified'] is True and rec['repeats']==3
        assert rec['job_id']==manifest['job_id']==plan['performance_job']
        assert rec['settings']==manifest['settings']==plan['settings']
        assert rec['environment']==plan['record_environment'] and rec['reference']==plan['record_reference']
        assert set(rec['checks'])=={'scheduler','fetched_log','benchmark','wrapper','source_hashes','machine'}
        assert all(value is True for value in rec['checks'].values())
        assert manifest['measurement_order']==ORDER and manifest['group_index']==ORDER.index(name)
        assert manifest['group']==plan['performance_group']
        scheduler=manifest['scheduler_status']
        assert scheduler['status']=='SUCCEEDED' and str(scheduler['jobId'])==plan['performance_job']
        assert type(scheduler['jobExitCode']) is int and type(scheduler['systemExitCode']) is int
        assert scheduler['jobExitCode']==scheduler['systemExitCode']==0
        assert c.parse_scheduler_status((run/'scheduler-status.txt').read_text(),plan['performance_job'])==scheduler
        assert (run/'exit-code.txt').read_text().strip()=='0'
        raw=(run/'benchmark.log').read_text()
        actual=e.parse_log('conv',raw,3)
        assert actual['cases']==rec['cases'] and actual['total_median_ms']==rec['total_median_ms']
        assert [case['dims'] for case in rec['cases']]==DIMS
        assert all(len(case['times_ms'])==3 for case in rec['cases'])
        assert re.findall(r'^BENCH_REPEAT ([1-3])/3 (BEGIN|END)$',raw,re.M)==[(str(i),phase) for i in (1,2,3) for phase in ('BEGIN','END')]
        assert rec['machine']==e.machine_profile(run,raw)==records[ORDER[-1]]['machine']
        assert rec['machine']['compiler_banners']==['gcc (GCC) 10.3.1']
        assert rec['machine']['ARCH']=='aarch64' and rec['machine']['OMP_NUM_THREADS']=='38' and rec['machine']['CPU_TARGET']=='generic'
        assert rows[name]['total_median_ms']==rec['total_median_ms']
        assert rows[name]['cases_ms']==[case['median_ms'] for case in rec['cases']]
        assert rows[name]['all_samples_ms']==[case['times_ms'] for case in rec['cases']]
        assert rows[name]['case_spreads_pct']==[case['spread_pct'] for case in rec['cases']]
        assert rows[name]['max_spread_pct']==max(case['spread_pct'] for case in rec['cases'])
        assert rows[name]['gain_pct']==(1-rec['total_median_ms']/records[ORDER[-1]]['total_median_ms'])*100
    assert sum(len(case['times_ms']) for rec in records.values() for case in rec['cases'])==36
    candidate=records['C51-r1']
    assert candidate['confirmation_passed']==plan['confirmation_passed']==rows['C51-r1']['confirmation_passed']
    assert candidate['qualified_for_confirmation'] is False
    assert candidate['source_parent']==plan['source_parents']['C51-r1']=='C51-row7x3u1'
    assert candidate['diagnostic_source_version']==plan['diagnostic_source_versions']['C51-r1']=='C51-row7x3u1'
    assert str(candidate['diagnostic_job_id'])==str(plan['diagnostic_jobs']['C51-r1'])=='1581822'
    assert plan['diagnostic_expected_checks']['C51-r1']==37128
    gates=[]
    for control_name,field in ((ORDER[0],'opening_control_comparison'),(ORDER[-1],'comparison')):
        control=records[control_name]; stored=candidate[field]
        actual=e.comparison(control,candidate)
        assert stored['baseline']==control_name
        assert all(stored[k]==actual[k] for k in ('eligible','reasons','cases','metric'))
        assert rows['C51-r1'][field]==stored
        gain=(control['total_median_ms']-candidate['total_median_ms'])/control['total_median_ms']*100
        threshold=max([1.0]+[case['spread_pct'] for case in control['cases']+candidate['cases']])
        assert stored['total_gain_pct']==gain and stored['threshold_pct']==threshold
        assert actual['eligible'] == (gain>threshold and all(row['gain_pct']>=-1 for row in actual['cases']))
        gates.append(stored)
    assert candidate['confirmation_passed']==all(g['eligible'] for g in gates)
    rp=read(ROOT/'.runs/conv/sep13r-campaign.json')
    initial=read(ROOT/'records/experiments/conv/C51-row7x3u1.json')
    assert rp['status']=='performance_complete' and rp['performance_job']=='1581911'
    assert initial['status']=='passed' and initial['verified'] is True and initial['job_id']=='1581911'
    assert initial['qualified_for_confirmation'] is True
    assert initial['opening_control_comparison']['eligible'] is True and initial['comparison']['eligible'] is True
    assert candidate['source_hashes']==initial['source_hashes']==plan['candidate_source_hashes']['C51-r1']
    assert records[ORDER[0]]['source_hashes']==records[ORDER[-1]]['source_hashes']==e.get_record('conv','C26-row4loads')['source_hashes']
    assert plan['settings']==rp['settings'] and plan['prior_job']=='1581911'
    settings=plan['settings']; resources=settings['scheduler_resources']
    assert settings['bench_repeats']==3 and resources['cpus']==38 and resources['memory_mb']==24576
    assert resources['numa_count']==1 and resources['numa_distribution']=='pack' and resources['walltime_seconds']==1800
    best=read(ROOT/'outputs/conv-best.json'); best_version=read(ROOT/'records/best.json')['conv']
    assert best['source_hashes']==e.get_record('conv',best_version)['source_hashes']
    return plan,records,rows,gates,initial,best['label'],best_version


def generate(plan,records,rows,gates,initial,best_label,best_version):
    candidate=records['C51-r1']; passed=candidate['confirmation_passed']
    best_sentence=(f'生成报告时，已登记的当前最佳仍为 **C6（{best_version}）**。' if best_label=='C6'
        else f'生成报告时，已登记的当前最佳为 **{best_label}（{best_version}）**，C6已不是登记的当前最佳。')
    verdict=('S 独立确认通过两端 C6 门槛。' if passed else 'S 独立确认未通过两端 C6 的全部门槛。')
    text=['# CONV：C51 的一次独立确认', '', verdict+best_sentence+'本报告只记录真实 S 结果，不修改最佳版本。', '',
        f"超算作业 **{plan['performance_job']}**，固定顺序 **C26-r24（C6）→ C51-r1 → C26-r25（C6）**。"
        '每成员三个独立完整原 benchmark 套件，合计 **36/36 PASS**；调度器成功、job/system/wrapper退出均为0。'
        '数值正确性通过与优化确认是否通过分别判断。', '',
        '实际为同一次分配、GCC10.3.1、generic、38线程、24GiB、单NUMA，原benchmark、runner、输入、参考、浮点与精度设置保持。'
        '每个样本是原benchmark在该套件打印的耗时，不把套件样本与内部重复次数混为一谈。'
        '合计是四个用例三套打印值各取中位数后相加，只作内部耗时指标，不是官方分数或排名。', '',
        '| 版本 | A/B/C/D 中位数 ms | 合计 ms | 对结束C6合计改善 | 最大逐例波动 | 角色/结论 |',
        '| --- | --- | ---: | ---: | ---: | --- |']
    for name in ORDER:
        rec,row=records[name],rows[name]
        role='不改源码的C6对照' if name!='C51-r1' else '独立确认通过' if passed else '独立确认未通过'
        text.append('| '+name+' | '+' / '.join(f'{case["median_ms"]:.2f}' for case in rec['cases'])
            +f' | {rec["total_median_ms"]:.2f} | {row["gain_pct"]:.6f}% | {row["max_spread_pct"]:.6f}% | {role} |')
    text+=['', '## 两端门槛与逐例变化', '',
        '候选必须分别对开头和结束C6满足：总中位耗时改善严格大于max(1%,双方全部case波动)，且**任何case，包括A，都不得退步超过1%**。'
        '波动=(最大样本−最小样本)/中位数。百分比显示6位小数，判定使用完整精度；所有慢样本保留。', '',
        '| 对照 | 合计改善 | 实际门槛 | A改善 | B改善 | C改善 | D改善 | 通过 | 实际原因 |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |']
    for gate in gates:
        reasons='；'.join(gate['reasons']) or '总改善严格超过门槛，且各case退步均未超过1%'
        text.append(f'| {gate["baseline"]} | {gate["total_gain_pct"]:.6f}% | {gate["threshold_pct"]:.6f}% | '
            +' | '.join(f'{row["gain_pct"]:.6f}%' for row in gate['cases'])
            +' | '+('是' if gate['eligible'] else '否')+' | '+reasons.replace('|','\\|')+' |')
    text+=['',f'`confirmation_passed={str(passed).lower()}`。'
        +('本页确认通过不能替代最终原ZIP在独立作业中的验证。' if passed else '失败确认保留为本次最终结果，不重试该确认、不放宽第一组门槛，也不使用R样本补救S。'), '',
        '## 全部36个原始样本', '',
        '| 版本 | 用例 | 三套打印值 ms | 中位数 ms | 波动 | 最大误差 |',
        '| --- | --- | --- | ---: | ---: | ---: |']
    sample_lines=[]
    for name in ORDER:
        for index,case in enumerate(records[name]['cases']):
            row='| '+name+' | '+'ABCD'[index]+' | '+' / '.join(f'{x:.2f}' for x in case['times_ms'])
            row+=f' | {case["median_ms"]:.2f} | {case["spread_pct"]:.6f}% | {case["max_error"]:.8g} |'
            sample_lines.append(row)
    text+=sample_lines
    text+=['', 'A=4096×6144 / 39×39；B=6144×4096 / 41×41；C=4256×6390 / 55×55；D=6390×4256 / 81×81。', '',
        '## R初筛与S独立确认的关系', '',
        f'此前[R作业1581911](CONV_SEP13R.md)的C51初筛通过两端C6，候选四例中位数合计为 **{initial["total_median_ms"]:.2f}ms**。'
        f'本S作业 **{plan["performance_job"]}** 使用新的两个C6控制和同一C51源码，独立产生36个样本。'
        'R的48样本与S的36样本没有合并或挑选；R的初筛资格不预先决定S结论。', '',
        'C51-r1的source parent和自身诊断来源分别登记，当前都指向C51-row7x3u1；复用的是它自己'
        '[Q作业1581822的37128项验证](CONV_SEP13Q.md)。本轮未改变七行×3VL/21acc的实现。'
        'C40只在R作为参考，原G/J/K/N/R历史判定保持，不提供S的通过依据。', '',
        best_sentence+'S记录的自动确认、自动晋级和自动打包均关闭，失败确认不允许自动重试。'
        '本页生成只读取实际campaign、记录及原始日志，未创建作业、修改record、生成ZIP或写入发布副本。'
        '所有题目编译/正确性/benchmark仅在超算计算节点执行；本机仅整理文本，没有使用重置卡。', '',
        '逐版本源码、设置、完整原日志、调度状态和比较原因均留档。公开副本应对计算账号、个人目录和内部节点脱敏。'
        '正式比赛仍由队友手动提交；没有估算官方分数、排名或提交结果。', '']
    output='\n'.join(text)
    # Check the rendered numerical rows against the actual original arrays,
    # not synthetic tests or operator execution. No numeric field is guessed.
    assert len(sample_lines)==12
    rendered=[]
    for line in sample_lines:
        cells=[x.strip() for x in line.split('|')]
        rendered+=list(map(float,cells[3].split(' / ')))
    original=[x for name in ORDER for case in records[name]['cases'] for x in case['times_ms']]
    assert len(rendered)==36 and rendered==original, 'Printed report would lose/change an original sample'
    return output


def main():
    path=ROOT/'docs/CONV_SEP13S.md'
    assert not path.exists(), 'Existing report is never overwritten'
    loaded=load_completed()
    content=generate(*loaded)
    with path.open('x') as handle:
        handle.write(content)
    assert path.read_text()==content
    plan,records,_,gates,_,best_label,best_version=loaded
    print(json.dumps(dict(report=str(path),job_id=plan['performance_job'],samples=36,
        confirmation_passed=plan['confirmation_passed'],current_best=best_label,current_best_record=best_version,
        totals_ms={name:rec['total_median_ms'] for name,rec in records.items()},
        gates=[dict(baseline=g['baseline'],eligible=g['eligible'],gain=g['total_gain_pct'],threshold=g['threshold_pct'],
                    case_gains=[row['gain_pct'] for row in g['cases']],reasons=g['reasons']) for g in gates],
        original_samples_rendered_exactly=True,new_operator_execution=False),ensure_ascii=False,indent=2))


if __name__=='__main__':
    main()
