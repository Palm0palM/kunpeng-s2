# r20 T22 register-only constraints

T21 reduced MOVPRFX but regressed relative to T20 in r19; T22 tests the load-scheduling restriction hypothesis by removing only memory clobbers while retaining accumulator constraints. Keep all official conditions and source arithmetic unchanged. No claim of compiler behavior or gain before the allocated-node result. Two repeats reference r19 job1582129. New T22 parent T19-control13. Actual KML25.1/GCC12, not specified KML25.2. No local task execution or hashes.
