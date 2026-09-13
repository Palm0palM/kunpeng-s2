# C59 preparation commands and original exits

The first inline preparation attempt failed to parse before executing any statement; preparation-first-failure files retain original chunk fda8ec/exit1 and error. Candidate/record absence was checked again. No new/checkpoint ran in that failed attempt.

Standard experiment.py new and checkpoint each ran exactly once; each original argv, UTC start/end, stdout, stderr and exit is retained. Both acquire the standard .runs/.workflow.lock. The single-line source edit and metadata/audit writes used the same lock; it was released before checkpoint to avoid nesting.

Actual new:
```json
{
  "argv": [
    "python3",
    "-B",
    "tools/experiment.py",
    "new",
    "conv",
    "C59-row7boundaryu2nofive",
    "--parent",
    "C58-row7boundaryu2",
    "--strategy",
    "Only remove the GCC unroll 2 pragma before rowseven input_5 from C58. Preserve the other11 boundary pragmas, shared2/u1, all arithmetic, dispatch, flags and three companion files. Test possible reduction of repeated input_5 temporary-product spills; source-only preparation, performance unmeasured, no inherited AH PASS."
  ],
  "started_at": "2026-09-12T20:30:38.165981+00:00",
  "standard_cli_workflow_lock": true,
  "ended_at": "2026-09-12T20:30:38.211625+00:00",
  "exit_code": 0
}
```

Actual checkpoint:
```json
{
  "argv": [
    "python3",
    "-B",
    "tools/experiment.py",
    "checkpoint",
    "conv",
    "C59-row7boundaryu2nofive",
    "--note",
    "Source-only: remove only C58 input_5 pragma at line1445; reinsertion restores full parent bytes. Other11 hints/shared2/u1/arithmetic/dispatch/three companion files unchanged. Creation hashes preserved. Own compilation, numerical diagnosis and performance unmeasured; no inherited AH1583350 PASS. Wait for C58 AI1583408 result and root/quota decision. No compute authorization or promotion."
  ],
  "started_at": "2026-09-12T20:32:02.638457+00:00",
  "standard_cli_workflow_lock": true,
  "ended_at": "2026-09-12T20:32:02.673369+00:00",
  "exit_code": 0
}
```

Text edit: locate the input_5-to-shared comment region and remove its unique GCC unroll2 pragma, restoring it to verify the complete original source bytes. candidate.patch and source-audit.json preserve the exact change and identities. Creation snapshots remain original; experiment.json preserves creation source hashes and adds only this candidate source-parent/unmeasured association. Checkpoint records current source hashes.

Only local text/standard metadata work. No local compilation, operator/test, SSH, job, diagnostic execution, or parent record modification. FINAL/STOP.
