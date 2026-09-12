# C57 preparation commands and exits

The repository had existing collaborator changes on conv/next-measured; none were reverted. Before new, the candidate directory/record were absent and all four original C52 source hashes matched its record; parent conv2d.c matched frozen T1582134. Standard experiment.py uses the shared .runs/.workflow.lock and refuses occupied IDs.

| Action | Original argv and timestamps | stdout / stderr / exit files | Tool result | Exit |
|---|---|---|---|---:|
| Standard new, once | commands-new.json | commands-new.stdout.txt / commands-new.stderr.txt / commands-new.exit.txt | 755ade | 0 |
| Lightweight text preparation, once | commands-prepare.json | commands-prepare.stdout.txt / commands-prepare.stderr.txt / commands-prepare.exit.txt | f5a4fd | 0 |
| Standard checkpoint, once | commands-checkpoint.json | commands-checkpoint.stdout.txt / commands-checkpoint.stderr.txt / commands-checkpoint.exit.txt | a8a51e | 0 |

The argv in JSON is the exact subprocess command, with actual UTC start/end and exit; stdout/stderr bytes are preserved separately. prepare-source.py is the exact executed standard-library text transformer. It holds the shared lock, refuses repeated preparation, writes only this candidate source/patch/audit, and invokes no compiler/operator. All three stderr files are empty. There was no failed new, prepare or checkpoint attempt and no retry.

Local finishing work only read the complete candidate.patch and compared source/record bytes, then wrote STRATEGY.md, STATIC_REVIEW.md and this file. Creation metadata was not rewritten. Source and preparation documents are final; STOP. Future execution requires root's separate GO under the FMA feasibility plan. No reset card.
