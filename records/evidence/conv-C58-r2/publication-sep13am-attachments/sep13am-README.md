# AM: C59 input_5 pragma removal versus current C7

Prepared only. Source C59 differs from C7/C58 by removal of one input_5 unroll2 hint; retain all other source and benchmark settings. Requires own original AJ1589289 accepted/frozen44328 and targeted actual assembly report. C7 confirmed/published source is the control, not historical C6.

Unique order C58-r2 / C59-row7boundaryu2nofive / C58-r3, three full official suites each,36 samples, same single allocation38CPU24576MiBpackedNUMA1800/GCC10.3.1/generic. Comparison calls unchanged standard experiment.comparison against both controls, requires gain exceed max(1%,all case spreads) and no case worse than1%. Keep every slow/failed sample. Passing only qualifies for a separate independent confirmation; no automatic promotion or ZIP.

Submit reserves campaign before new controls or upload. Standard new/checkpoint retain creation metadata; C59 source_parent stays originalC58 while comparison parent changes to closing C58-r3. Standard cluster_group allocates one group, uses existing runners unmodified. Record/fetch original job only; numerical failures immutable. All argv/UTC/stdout/stderr/exit are captured by sep13-run-logged.py. Root must read account main quota before each stage; >=40 stop, never reset. No local operator compilation or tests.

Interfaces (not yet executed):
python3 .runs/conv/sep13am-performance.py submit --go
python3 tools/cluster.py --config config/conv-sep12.local.json status .runs/conv/C58-r2
python3 .runs/conv/sep13am-performance.py record-compare
