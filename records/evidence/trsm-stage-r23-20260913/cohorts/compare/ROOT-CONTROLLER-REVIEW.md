# r23 controller review

Reviewed T25 pair-load source and complete controller diffs from executed r22. Changes limited to new experiment/protocol identifiers,prior1582526andhypothesis; fullpanel8x16/reference inputs identical. OriginalABwarmup/AB,BA,ABformal,38CPU/singleNUMA,TEST_RUNS3,strictpreflight/originallog/linkage/jobguards and originalcomparison gate remain. Bothmembers freshly run fullsmallpathpreflight.

PythonAST,shellsyntax,inlinePython checked locally. Pair loads explicitly readtwo8-byte operands with onebase at0/+8; outputsSVE,inputpredicate/GPRdifferentclasses, no hidden memory or flags modified. FourXloads,32FMA perpair and originalsingle-step tail maintain eachaccumulator order. Sourceoutsidehistory andsupportfiles matchT19. Actualcompiler/asm/correctness/performancependingtargetvalidation. Exclusiveprepare/submit/finishretained,no automaticpromotion,hashes orlocaltaskexecution. Gate releasedafterreview.
