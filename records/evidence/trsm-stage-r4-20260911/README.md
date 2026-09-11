公开副本说明：此文件及对应证据已替换个人路径、账号、内网地址与节点名，未脱敏原件保留本地；下文关于原始复制的描述指本地归档阶段，公开副本不能作为原件完整性证据或用于重新晋级。

# TRSM stage r4 evidence — 2026-09-11

This public archive contains redacted copies of local original evidence for scheduler job 1522032. Each member directory contains its nohash-recorded-evidence snapshot, final record.json, and wrapper stdout. The candidates also include preparation/strategy notes. cohort/ contains the measured configuration and submission metadata, raw shared logs, target preflight sources and assembly, reference probe, scheduler state, no-hash workflow scripts, and comparison/registration outputs. Preparation notes retain their original pre-run wording; measured results and final decisions are in the report and record.json files.

Personal paths, account identifiers, internal addresses and node names were redacted for publication; originals remain local. Public copies are not original-byte evidence. No hashes were computed or verified. Remote source identity and transfer integrity were not validated. cluster.local.json, known_hosts, authentication/connection logs, credentials, payload archives, and binary artifacts are excluded. ARCHIVE.json maps copied files to their local original paths without digests.

The summary is in [the r4 report](../../../docs/trsm-stage-r4-20260911.md). T7-diagpanel passed the promotion gate and was promoted; T7-sve24rows passed correctness but failed the promotion gate. All 27 official rows passed under OpenBLAS 0.3.28. The expanded environment probe found KML 25.1 files under /opt despite missing default module/header/link configuration. This job still used OpenBLAS; any separate KML 25.1 verification and final-package test are outside this archive. This is not official KML 25.2.0 revalidation or a formal competition submission.
