# AF original48 lifecycle summary

Original job1583230 / group kp-conv-group-01b8f067516e completed. All48 benchmark samples PASS and recorded max_error0; allfour scheduler/job/system/wrapper exits0. First record-group and first compare both exit0, stderr empty. Four status calls all exit0, with subsequent intervals96.109542/83.460300/83.102910 seconds; waits were <=45 seconds. Root performed the sole submit (cae803); its original four outputs are referenced in JSON.

C56 initial qualification is false at both ends; C6 retained, confirmation_pending=[], no AG execution, confirmation, ZIP or promotion from this lifecycle. C55-r1 remains reference_only=true, promotion_allowed=false and qualified=false. AD/Y/S history unchanged.

| Version | A samples ms | B samples ms | C samples ms | D samples ms | Sum of medians ms | Max spread % |
|---|---|---|---|---|---:|---:|
| C26-r34 | 51.41 / 51.51 / 51.51 | 61.98 / 61.94 / 61.90 | 107.32 / 107.31 / 107.32 | 235.87 / 234.13 / 231.69 | 454.90 | 1.785332935 |
| C56-row7shared3fence | 55.19 / 55.12 / 55.11 | 62.19 / 62.23 / 62.15 | 110.90 / 110.96 / 110.96 | 239.35 / 239.19 / 239.16 | 467.46 | 0.145137881 |
| C55-r1 | 55.46 / 55.44 / 55.37 | 60.98 / 60.98 / 61.05 | 131.20 / 111.64 / 111.67 | 238.53 / 238.62 / 238.55 | 466.64 | 17.515895048 |
| C26-r35 | 51.41 / 51.45 / 51.40 | 61.97 / 61.95 / 61.91 | 107.36 / 107.29 / 107.32 | 231.65 / 231.73 / 231.64 | 452.33 | 0.097257343 |

C56 opening gain -2.761046384% versus threshold 1.785332935%; closing gain -3.344903058% versus threshold 1.000000000%. Both gates false; cases A/C/D regress over1%. Parent-reference gain -0.175724327% versus threshold 17.515895048% is also false. The C55-r1 C sample131.20 ms and opening-C6 D235.87/234.13/231.69 ms are retained, not filtered.

Allfour records share the actual machine/compiler profile. Recorded settings are GCC10.3.1/generic,38 CPU/24576MiB/one packed NUMA/1800s, OMP38/FALSE/close/cores. Full per-case medians/spreads, both gates and source/diagnostic identities remain in JSON and original records. This is an internal sum of medians, not an official score.

## Exact outer and internal evidence files

- `.runs/conv/sep13af-root-submit.command.json`
- `.runs/conv/sep13af-root-submit.exit.txt`
- `.runs/conv/sep13af-root-submit.stderr.txt`
- `.runs/conv/sep13af-root-submit.stdout.txt`
- `.runs/conv/sep13af-lifecycle-compare.exit.txt`
- `.runs/conv/sep13af-lifecycle-compare.json`
- `.runs/conv/sep13af-lifecycle-compare.stderr.txt`
- `.runs/conv/sep13af-lifecycle-compare.stdout.txt`
- `.runs/conv/sep13af-lifecycle-record.exit.txt`
- `.runs/conv/sep13af-lifecycle-record.json`
- `.runs/conv/sep13af-lifecycle-record.stderr.txt`
- `.runs/conv/sep13af-lifecycle-record.stdout.txt`
- `.runs/conv/sep13af-lifecycle-status-001.exit.txt`
- `.runs/conv/sep13af-lifecycle-status-001.json`
- `.runs/conv/sep13af-lifecycle-status-001.stderr.txt`
- `.runs/conv/sep13af-lifecycle-status-001.stdout.txt`
- `.runs/conv/sep13af-lifecycle-status-002.exit.txt`
- `.runs/conv/sep13af-lifecycle-status-002.json`
- `.runs/conv/sep13af-lifecycle-status-002.stderr.txt`
- `.runs/conv/sep13af-lifecycle-status-002.stdout.txt`
- `.runs/conv/sep13af-lifecycle-status-003.exit.txt`
- `.runs/conv/sep13af-lifecycle-status-003.json`
- `.runs/conv/sep13af-lifecycle-status-003.stderr.txt`
- `.runs/conv/sep13af-lifecycle-status-003.stdout.txt`
- `.runs/conv/sep13af-lifecycle-status-004.exit.txt`
- `.runs/conv/sep13af-lifecycle-status-004.json`
- `.runs/conv/sep13af-lifecycle-status-004.stderr.txt`
- `.runs/conv/sep13af-lifecycle-status-004.stdout.txt`
- `.runs/conv/sep13af-lifecycle-submit-origin.json`
- `.runs/conv/sep13af-lifecycle-summary.json`
- `.runs/conv/sep13af-lifecycle-summary.md`
- `.runs/conv/C26-r34/status-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C26-r34/fetch-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C56-row7shared3fence/status-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C56-row7shared3fence/fetch-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C55-r1/status-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C55-r1/fetch-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C26-r35/status-driver-sep13af-20260912T195431369779Z.log`
- `.runs/conv/C26-r35/fetch-driver-sep13af-20260912T195431369779Z.log`

No first record/compare failure, retry, tool/source change or reset card. Lifecycle FINAL/STOP.
