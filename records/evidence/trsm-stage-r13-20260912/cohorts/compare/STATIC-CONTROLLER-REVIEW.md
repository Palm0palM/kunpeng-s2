# r13 controller 与 packed-L 门禁独立静态审查

**结论：READY，未发现阻塞缺陷。** 本次仅只读代码、记录、既有证据及轻量文本/JSON核对，唯一新写文件为本审查说明。未执行被审脚本、prepare/submit/collect/record/promote、SSH、本机题目编译或测试、哈希操作。审查时 r13 的 cohort-submission.json、cohort-config.json 和 payload 均不存在；以下覆盖数量是待执行协议，不能视为 r13 已通过结果。

## 三成员与重复登记

| 顺序 | run | version / 性能 parent | 登记方式 |
| --- | --- | --- | --- |
| A | T8-control12-repeat-r13 | T8-control12 / null | --repeat-existing |
| B | T10-lhistbarrier-repeat-r13 | T10-lhistbarrier / T8-control12 | --repeat-existing |
| C | T14-lhistcyclic | T14-lhistcyclic / T8-control12 | 新 record |

job_control 的 prepare 保留 A/B 原 version、parent、strategy、source_implementation_id，并检查其 passed、verified、KML25.1声明和此前测量源码快照。A 必须仍为 promoted/current best；B 必须仍未晋级且 parent 是当前已晋级T8。finish_records 只对前两个成员附加 --repeat-existing，新T14使用普通登记。

独立资格复核确认当前 A 来自 r12，B 来自 r7 作业1579401；B依然passed/verified、parent=T8且无promoted_at，旧live四源码和六证据文件与其保存快照相同。私有helper不限制候选距当前轮次的间隔，r7来源不会使T10重复失效。两者计划身份逐字段一致，新r13重复目录不存在，T14原源码存在但record/experiment尚未创建。

record helper 在登记前后再次验证旧证据、当前parent和源码快照，保护旧目录，并在成功替换前保存完整prior-record。preserve_repeat_identity保留原created、strategy、parent及全部source_*；T8的物理取源目录source_from=T8-control12最终仍恢复历史实现来源T8-svepanel16，不重新定义其身份。

## 按实际源码特征选择预检

本轮 preflight 的run.sh、check-panel.c、guard.py、README.md与r7对应四输入逐字节相同；没有复制旧结果。实际源码特征为A只有原panel16核，B/C同时有原panel16和packed-L核。三个源码的大路径均KB256/CT64且不含4×32核；T14相对T10的完整源码diff仅共享packed_history生产循环的schedule(static)→schedule(static,1)。本轮没有wide32目录或调用，也不改变CT。

| 成员 | 原微核 | packed-L微核 | 整算子 | no-op | 共享历史分配失败 |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 14 | 0 | 406 | 28 | 0 |
| B / C（各） | 14 | 14 | 486 | 36 | 80 |

五组full各80例、38线程smoke4例及boundary2例合成406；七个whole进程各4个no-op合成28。packed-L候选另有1/4线程各40个shared-fail例，因此486 whole、36 no-op、80注入。两种直接核各使用7个history start×2个padding，共14例，保留逐位有序FMA参考、历史/输入/padding检查与实际函数入口计数。

shared-fail用例覆盖8个m值（均m≥32）×5个n值，分别在1/4线程运行。第一次被拦截posix_memalign必须在omp level0，alignment64，字节数等于128×full_blocks×(full_blocks−1)×sizeof(double)，且只失败这一次；之后所有X分配须成功（calls≥2且later_success=calls−1）。检查packed入口为0、原核入口等于完整预期且非0，不能把全部分配失败或退入无核路径当作共享历史回退成功。runner严格核对每个原始SHARED_ALLOC_PASS和聚合数量。

原预检同时保留一般非dyadic long-double RHS、L完整字节及B行padding、边界、全部分配失败、no-SVE和实际窄VL检查。driver对每个预检退出码、实际源特征和精确completion逐一核对；finish_records再对本轮冻结payload源码特征和取回标记复核，三成员不会错误套用同一计数。

## 预热、正式轮次与同环境

真实KML头文件/链接probe与全部三成员通用预检及源特征门禁先完成，随后才执行每成员一套原run.sh预热。每套TEST_RUNS=3，预热原行、完成标记、资源绑定和真实KML/libgomp依赖单独保存；collect还核对member、job、cohort和预声明protocol。只有三者预热全部成功后才排他创建正式benchmark/wrapper日志。

正式固定ABC / BCA / CAB，每成员三个完整官方套件；预期27 formal PASS和9 warm-up PASS，保留全部三轮，不排除慢样本。finish_records先核对每成员9正式/3预热，再核对27/9总量；私有record helper进一步严格解析三套有序原用例、原精度、调度job、环境/线程绑定及三套真实依赖，预热不进入正式中位数。

reference四输入、remote_job及私有cfg均与r12对应文件逐字节相同。实际运行仍要求调度Linux aarch64、38 CPU单NUMA、GCC12.3.1、KML25.1和私有libgomp。三成员共用同一固定env和同一allocation，登记environment ID含相同节点/NUMA/job；比较helper再要求environment/reference/machine和关键环境相同。原runner/benchmark/compat字节门禁保留，全部编译、汇编生成及题目运行只会在计算节点执行。

## 登记、机理比较与晋级边界

finish_records仅在collect状态后展开新诊断目录，拒绝非普通文件/逃逸路径；检查cohort退出0、预检和27/9计数后登记A/B/C。登记失败立即停止并保留证据，不自动重跑。控制器collect先要求SUCCEEDED；record helper还核对精确job ID、退出码和原日志，不能将仍RUNNING的结果登记为通过。

T8→T10和T8→T14是父基线比较；T10→T14仅为机理对照，result.json明确promotion_authorization=false。comparison函数不要求T14.parent=T10，因此这份对照不会仅因parent仍为T8而被拒绝；即使其返回eligible=true，也不替代T8门槛。finish_records没有promote调用；后续do_promote按T14.parent=T8重新检查current best、父源码及T8→T14收益/噪声/退化门槛。

本审查未给出性能预测或晋级授权。KML25.1/GCC12结果仍不能称为指定KML25.2复验或官方得分；实际r13日志和目标汇编仍待计算节点产生。
