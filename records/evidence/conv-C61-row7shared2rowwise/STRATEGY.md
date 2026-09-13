# C61 row-wise coefficient lifetime

Within each shared pair column, load three original input vectors then update each output row across all three vectors using one scoped coefficient broadcast. Shorten source-level coefficient lifetimes; preserve per-output arithmetic order,6 direct loads,14 broadcasts,all boundary hints,remainder and runner. No EXT, prefetch or fast math.

Hypothesis: three vector inputs plus one current coefficient may give GCC a better schedule than seven simultaneously scoped coefficients. GCC may already reorder similarly; no improvement is assumed. C59 and C60 regressions are retained; this candidate starts from measured C7, not either rejected source.
