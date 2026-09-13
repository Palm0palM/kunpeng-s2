# C47 package static review

Source ownership is confined to this new L package; candidate source, C40's frozen evidence, K/I work and formal conv were not changed.

- Production conv2d.c is a direct immutable copy of C47, with its checkpoint identity captured by the new five-file transport manifest.
- The two harness C files differ from C40 frozen raw copies only by width expressions3*lanes→4*lanes and6*lanes→8*lanes. No replacement affects literal six-row groups, kh<6 guards, callback names, global output stride, scalar reference, RNG, canaries, VL checks or expected-entry logic.
- The six adapted widths are distinct at every supported lane count. Actual loop-array cardinalities yield2808+144+576+32=3560 production checks,432 dispatch and360 direct; total26112. Counts are recomputed from the new code structure rather than copied as a C40 PASS result. Exact guard assertions are retained because cardinalities are unchanged.
- Public kh5 requires zero rowsix entries; kh6/7 usesfloor(oh/6). Atomic before/after counts are read only after each call and OMP join. Direct fallback passes six distinct global-stride destinations and onlykh1..5 withoh6/24. Phase masks1/15 require every actual worker, and the original old-helper entry checks remain in place.
- The wrapper follows the reviewed19-stage I format. Fixed candidate/count assertions use EXPECTED_ACC=4 and rowsix432/900. Actual compiler command lines retain original strict diagnostic flags. Only the second executable is instrumented. Its invocation has one VL argument and no smoke argument, matching the included main interface.
- No current assembly/count/spill or correctness result exists. No raw/job/binary/accepted validation was copied. C40's previous eleven-stage review does not establish the new24-accumulator allocation. All production stages, transitions, indirect stack traffic, ABI saves and full-source FMA require target review.

Prepared only; no local compilation/test, SSH, scheduler submission or reset.
