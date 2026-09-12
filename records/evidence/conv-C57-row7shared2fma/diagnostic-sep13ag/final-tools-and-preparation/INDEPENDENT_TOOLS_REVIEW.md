# AG independent transport and wrapper review

Final static result: no remaining blocker in the reviewed revision after two preexecution corrections. Root explicitly confirmed final/STOP before the last read. This reviews root-authored AG transport and wrapper; reviewer Q authored the C57 source preparation, so it does not replace root's independent C57 source review. Only this report is written. No AG tool import/execution, AST/pycompile, compiler/test, SSH, reservation or job was performed.

## Findings and corrections

1. Initial wrapper used getauxval(AT_HWCAP=16) bit8 (ATOMICS) as an SVE test. That could accept a non-SVE machine and allow fallback. Root corrected the sole constant to bit22 (SVE), verified it against Linux UAPI, and retained the original wrapper/first three manifests/prepared/diff with CORRECTION.md in preparation-revisions/r0-hwcap-bit8. I read that record and independently compared r0/r1 text: only bit8→bit22 differs in the wrapper. Current wrapper and transport copy are identical; prepared explicitly records revision1. No draft ran or uploaded.
2. Initial AF member group comparison allowed missing group equality (None==None). Final driver first requires a string matching kp-conv-group-[0-9a-f]+, then every explicit member must carry that group and original campaign job ID. I read the final changed gate. README/STATIC record this correction. Driver changed from 265 to 268 lines; no submitted evidence was rewritten.

## Source, numerical and execution contract

Actual first transport file set is exactly conv2d.c, bench_conv.c, run.sh, README.md and remote_job.sh. All five actual sizes/SHA match source-manifest/source-hashes/prepared; four submission files equal final production C57 byte-for-byte, and the wrapper equals the reviewed root wrapper. C57 SHA is 3cc03ec4d13422238b1e461dd7213876cc50283a7433132ee94b41c4724ec6c5; official benchmark SHA is 2548861ae7e29826e454b4c0b098d682f7f04996222e664cd1ea9bc92dd2e927. Driver pins both, checks the prepared checkpoint and original C52 parent, and rejects changed source or manifests. Initial compiled/executed/verified remain false and actual_job_id null.

Read the unchanged official run.sh and full benchmark. The wrapper builds the original benchmark and C57 together with the same strict Linux gcc argv under fixed generic/block32/unroll2, -fno-fast-math and -ffp-contract=off; no global fusion is enabled. Only explicit candidate intrinsics can supply the intended fusion. Three actual compile commands will be logged via xtrace, with candidate and reference .s files retained for the later focused machine-code check. Source syntax and SVE capability alone are not accepted as proof of actual shared FMA or reference nonfusion.

Allocation requires Linux/aarch64, actual SVE bit22, exactly38 allowed CPUs in one NUMA; configured scheduler resources are38 CPU/24576MiB/one packed NUMA/1800 seconds, OMP38/FALSE/close/cores and GCC10.3.1. The four original argument tuples appear in A/B/C/D order inside suites1/2/3, with final test_runs=1: exactly12 original calls. Seeds, float reference order, tolerance1e-5, validation before timing, warmup and timing body remain untouched. The original benchmark explicitly reports FAIL for max_err>tol or NaN; its main may still return0. Each call therefore preserves combined stdout/stderr in its own log and separately records real process exit and exactly-one-PASS/no-FAIL text check. Runtime nonzero or absent/multiple PASS sets failure but still returns from the outer helper to collect the remaining predetermined calls. No failed sample is dropped.

Allocation/compiler/build/assembly or log-I/O errors stop as incomplete with actual stage/outer exit evidence. Numerical failure after all12 calls produces nonzero numerical-check and wrapper; in that case planned complete stage is correctly absent. Successful planned stage count is8, plus12 separately recorded process/check results, not AE's19-stage/44328 contract. Exit trap preserves the command status and catches tee completion failure. A failed job remains fetchable. Official maximum-error fields and all12 parameters/exits still require post-return review; the wrapper flag alone is not final acceptance. There is no AE memcmp/FMA0 acceptor, automatic comparison, promotion, ZIP or retry.

## Serialization and recovery

AF must exist and be performance_complete with a numeric original job and the explicit four-member order C26-r34/C56-row7shared3fence/C55-r1/C26-r35. The final nonempty group and each member job/group are checked. AE must remain1583102; an existing P reservation needs a reconciled numeric ID. Every known job is queried and must be a real terminal state with matching job ID and integer job/system exits. No peer scan occurs. AF was absent at final review, so GO is blocked until original AF is fully recorded; this report supplies no AF outcome or runtime authorization. Root must separately verify AF's complete48 originals and quota before its unique GO.

submit requires --go and no existing job.json, then exclusive open('x') reservation precedes transfer and submit. Any upload/submit failure or uncertain ID retains reservation/logs and cannot silently resubmit. status/fetch use the saved original ID and resource/source association; fetch requires actual terminal exits, allows the text/.s whitelist, validates all returned names and existing bytes before writing, and refuses differing overwrites. OSError/ValueError/KeyError/transport/tar errors fail closed with preserved logs where applicable; outer argv/stdout/stderr/exit preservation and >=45-second repeat polls remain the caller's explicit duty. No artifact is itself a PASS.

## Final byte identities

| File | Bytes | SHA256 |
|---|---:|---|
| driver.py | 14927 | `fbcb63c05be1e5f1233186d01fd337abc832185281eae3f3d54134bb6c73b9c3` |
| remote_job.sh | 3741 | `2b54b162ddadfc3e15925e070efdf02f8683d500bb508406edc7dd4a2c8bfb27` |
| README.md | 3493 | `37d8321072e6b6d41bd354ab7b53955c7bb84e86d52ee17c770b502b75369e98` |
| STATIC_REVIEW.md | 2360 | `8f1b2fd6fb813545bbbe159c1406748aa748c3dd69fa6776157b93778847fb97` |
| AE-to-AG.patch | 22965 | `1242507bd95913163cdba5744ab64b371aa62ff56804073283229c6d5c6fd32c` |
| C57-row7shared2fma/prepared.json | 1194 | `d0e5e1861718d6efbffab7fa94ed7821e1aecb2fd48c8b6c8cfec3e67cef7c49` |
| C57-row7shared2fma/source-hashes.json | 421 | `7ce105bafb6c6b0c46672bd4e75dd98e3590217115a8b1a07f51a5131c420aaf` |
| C57-row7shared2fma/source-manifest.json | 617 | `83b2856018ee02c7cb58c9d5a938d4c1d2eb314f1cacdfa3483c6d422e089754` |

Final AE-to-AG.patch exactly equals an independently regenerated text diff of both actual files against AE (lightweight text comparison only). Source/manifest association and explicit correction provenance have no unresolved mismatch. No local operator was run. Account main usage remained below40%; no reset card. FINAL/STOP.
