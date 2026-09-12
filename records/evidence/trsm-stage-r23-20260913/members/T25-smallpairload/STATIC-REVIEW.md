# T25 static review

Source generator checked all text outside original historical loop is identical T19, including final8rowforwardsolve, allallocation/dispatchandlargepath; four supportingfiles unchanged. Pair block fourXloads and8coefficientpairs,32vectorFMA;tailoriginal2Xloads8scalarcoefficients16FMA. k thenk+1order holds separately for every output. No new floating-point arithmetic inloadasm. Explicit memory inputs coverexacttwo8bytedoubles, sameGPRaddressplus8bytes, pgunchanged. Two outputs arebothused; no input shares outputregisterclass or requires earlyclobber. No newbounds/allocation/fallbackchanges.

Compileracceptance, exacttargetFMAresults andperformanceremainpendingfullcomputevalidation. Static review is not a correctness or speedclaim. No localtaskexecution/hashoperations.
