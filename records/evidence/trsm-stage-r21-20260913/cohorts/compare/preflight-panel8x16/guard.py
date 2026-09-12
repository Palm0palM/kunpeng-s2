#!/usr/bin/env python3
"""Read-only guard, to run inside the scheduler-bound compute allocation."""
import glob
import json
import os
import platform
import re
from pathlib import Path


def expand(value):
    result = set()
    for part in value.strip().split(","):
        if not part:
            continue
        bounds = part.split("-")
        result.update(range(int(bounds[0]), int(bounds[-1]) + 1))
    return result


if platform.system() != "Linux" or platform.machine() != "aarch64":
    raise SystemExit("PREFLIGHT_BLOCKED requires Linux aarch64 compute node")
job = next((os.environ[k] for k in ("TRSM_SCHEDULER_JOB_ID", "SLURM_JOB_ID", "LSB_JOBID", "CCS_JOB_ID", "JOB_ID") if os.environ.get(k)), None)
if not job or not re.fullmatch(r"[0-9]+", job):
    raise SystemExit("PREFLIGHT_BLOCKED scheduler job ID is required")
cpus = set(os.sched_getaffinity(0))
if len(cpus) != 38:
    raise SystemExit(f"PREFLIGHT_BLOCKED expected 38 allowed CPUs, found {len(cpus)}")
nodes = []
for filename in glob.glob("/sys/devices/system/node/node[0-9]*/cpulist"):
    if cpus & expand(Path(filename).read_text()):
        nodes.append(Path(filename).parent.name)
if len(nodes) != 1:
    raise SystemExit(f"PREFLIGHT_BLOCKED affinity spans NUMA nodes: {nodes}")
print(json.dumps({"guard_pass": True, "scheduler_job_id": job, "host": platform.node(), "allowed_cpu_count": len(cpus), "allowed_cpus": sorted(cpus), "numa_nodes": nodes}, sort_keys=True))
