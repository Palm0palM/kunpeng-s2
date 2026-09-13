# C59: remove only input_5 unroll2 hint

Source parent is C58-row7boundaryu2. Delete only its input_5 pragma at parent line1445. Keep the other11 boundary hints, shared2/u1, all arithmetic and input indices, dispatch, strict flags and three companion files. The exact prior rationale is preserved in hypothesis-origin.md.

AH actual input_5 paired loop has3 Z loads/3 stores of temporary products each iteration. Removing its hint may reduce this repeated traffic; trailing transition6 loads/12 stores may remain. Default GCC lowering is not guaranteed u1, spills may move, and frame/ABI costs may persist. No speedup is claimed.

C58 AH1583350 proves only parent bytes. C59 has no own compilation, numerical diagnosis or performance result. Original C58 AI1583408 is independently managed; wait for its result, root decision and quota before deciding whether to execute C59. Preparation is not promotion or compute authorization.
