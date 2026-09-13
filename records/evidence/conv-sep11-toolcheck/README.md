# CONV Sep 11 tooling validation evidence

Job 1507649 completed SUCCEEDED with scheduler job/system exits 0 and wrapper
exit 0. All 68 unittest cases passed in 10.442 seconds on the allocated
Linux/AArch64 compute node; no tests ran locally. The compute-node source check
validated 28 files against a 29-entry staged package manifest (the additional
entry identifies the checksum file itself).

`validation.json` binds the tested tool/test source hashes to their artifacts.
`raw/test.log` includes intentionally failing negative-test fixtures after the
successful unittest summary; those lines are expected test output, not failed
unit test results. `raw/source-verification.log` retains the source-check result.

These are redacted public copies. The original SHA values inside source lists
and validation retain their original meaning and must not be used as the public
files' checksums. `manifest.json` gives separate original_sha256 and
public_sha256 for each exported source file. Only public_sha256 validates this
public attachment. Its relative source labels locate private originals without
publishing host/user mapping or connection details. The original evidence and
all original hashes were left unchanged.

Only validation, source hashes, scheduler completion, tool-test logs and the
compute wrapper are included. Configuration files, connection drivers, SSH
transport/authentication records and binaries are excluded. The public README
and manifest are generated export metadata, not claimed to be raw artifacts.
