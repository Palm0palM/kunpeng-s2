# AR root static review

Root read C62 preparation script, source shared/boundary sections, STATIC_REVIEW and all six AP-to-AR transport/checker/acceptor diffs. C62 changes the rowseven tile jointly to 2VL/14 accumulators/shared4; per-chain kernel row and column order is retained, third vector scopes/initializers/stores removed, twelve boundary unroll2 hints and all non-rowseven source remain.

Root checked main load bound i+2L<=ow and column<=kw-1, so last accessed element<=W-1. Quad guard kw-ik>=4 covers columnsik..ik+3; u1 covers0..3 remainder. No new access or arithmetic reassociation. Own GCC output and bitwise tests remain necessary.

Checker dimensions now cover2L-1/2L/2L+1 and4L-1/4L/4L+1, small/direct/larger widths adapted; kw4..8 retains one/two quad and all remainders. Family cardinalities unchanged:5744full+1212dispatch+432direct across6VL/thread configs=44328. Independently checked rowseven entries:6*2*3*21+6*2*5*8=1236, direct3*6*3*5*2*2=1080. Legacy fallback counters must remain nonzero, not inherit old fixedAPvalues. Bitwise/guard/canary checks and exact per-case entry deltas unchanged.

ARdriver gate must see originalAQ1590254 fullyrecorded and schedulerterminal, with unique own reservation; wrapper requests38CPU/24576MiB/singlepackedNUMA/1800s, strictGCC10.3.1 withEXPECTED_ACC2, nineteen stages. Acceptor requires actualARjob/logs and target/rootreturned reviews. No AR execution or acceptance is claimed by this static review. No local operator tests and no reset cards. User revoked40%stop.
